import time
import os
from kubernetes import client, config
import digitalocean

DO_TOKEN = os.environ["DO_TOKEN"]
CHECK_INTERVAL = 180  
SCALE_UP_COOLDOWN = 300  

config.load_incluster_config()
v1 = client.CoreV1Api()
manager = digitalocean.Manager(token=DO_TOKEN)

last_scale_up = 0


def get_pending_pods():
    pods = v1.list_pod_for_all_namespaces().items
    return [p for p in pods if p.status.phase == "Pending" and not p.spec.node_name]


def get_worker_nodes():
    nodes = v1.list_node().items
    return [n for n in nodes if n.metadata.labels.get("node-role.kubernetes.io/control-plane") is None]


def is_node_idle(node_name):
    pods = v1.list_pod_for_all_namespaces(field_selector=f"spec.nodeName={node_name}").items

    non_ds_pods = [
        p for p in pods if not p.metadata.owner_references or all(
            owner.kind != "DaemonSet" for owner in p.metadata.owner_references
        )
    ]

    return len(non_ds_pods) == 0


def scale_up():
    name = f"node-{int(time.time())}"
    print(f"[INFO] Scaling up: creating droplet '{name}'")

    droplet = digitalocean.Droplet(
        token=manager.token,
        name=name,
        region='nyc3',
        image='187863098',  
        size_slug='s-2vcpu-4gb',
        ssh_keys=[46706575],  
        vpc_uuid='9263061d-54fb-4123-a46c-6d326318fe80',
        tags=['node']
    )
    droplet.create()
    print(f"[INFO] Droplet '{name}' creation triggered.")


def scale_down():
    nodes = get_worker_nodes()
    if len(nodes) <= 1:
        print("[INFO] Only one worker node remaining, skipping scale down.")
        return

    for node in nodes:
        node_name = node.metadata.name
        if is_node_idle(node_name):
            print(f"[INFO] Scaling down: draining and deleting node '{node_name}'")
            os.system(f"kubectl drain {node_name} --ignore-daemonsets --delete-local-data --force")
            os.system(f"kubectl delete node {node_name}")

            for droplet in manager.get_all_droplets():
                if droplet.name == node_name:
                    droplet.destroy()
                    print(f"[INFO] Droplet '{node_name}' deleted.")
                    break
            break


def main():
    global last_scale_up
    while True:
        try:
            pending = get_pending_pods()
            print(f"[INFO] Pending pods: {len(pending)}")

            if pending and (time.time() - last_scale_up > SCALE_UP_COOLDOWN):
                scale_up()
                last_scale_up = time.time()
            elif not pending:
                scale_down()
        except Exception as e:
            print(f"[ERROR] {e}")
        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    main()
