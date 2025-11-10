# DigitalOcean Kubernetes Autoscaler

This repository contains a Python-based autoscaler designed to run as a Kubernetes controller. It automatically scales your DigitalOcean droplets to meet pending workloads in your Kubernetes cluster. The autoscaler provisions preconfigured droplets from a snapshot whenever it detects pods that cannot be scheduled.

## Features

- Detects pending pods in the cluster.

- Creates new DigitalOcean droplets from a preconfigured snapshot.

- Newly created droplets automatically join the Kubernetes cluster.

- Runs as a Kubernetes controller, fully containerized.

- Uses RBAC and a ServiceAccount to securely access cluster resources.

## Architecture

- The autoscaler runs as a pod in your cluster.

- It monitors pending pods using the Kubernetes API.

- If pods remain pending beyond a configurable threshold:

- A new droplet is created on DigitalOcean from a snapshot.

- The droplet automatically joins the cluster.

- The cluster scales dynamically, allowing pending pods to be scheduled.

## Tech Stack

- Language: Python
- Containerization: Docker
- Cluster: Kubernetes
- Cloud Provider: DigitalOcean
- RBAC: ServiceAccount, ClusterRole, and ClusterRoleBinding

## Development

1. Clone the repository and move to the cloned folder.
2. Feel free to update the k8s.py ( change the DigitalOcean snapshot image id , the region etc..)
3. Build the Docker image:

**Note:**
The droplet snapshot must already have the necessary configuration to join the cluster (kubeadm, networking, etc.).


## Kubernetes Setup

1. Ensure the secret with your DigitalOcean token exists:

``` kubectl create secret generic do-secret --from-literal=DO_TOKEN=<your-token> ```

The deployment uses this secret to authenticate with DigitalOcean.


2. Apply the RBAC manifests (ServiceAccount, ClusterRole, ClusterRoleBinding):

``` kubectl apply -f k8s/service.yaml ```

RBAC ensures the controller has only the necessary permissions to watch pods, manage nodes, and evict pods if needed.


3. Update the deployment.yaml file to use the docker image you built and then deploy the autoscaler:

``` kubectl apply -f k8s/deployment.yaml ```


**Note:**
The autoscaler can **scale up** by adding droplets when pods are pending, and **scale down** by removing nodes that are not being used.  




