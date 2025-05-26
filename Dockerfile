FROM python:3.10-slim

RUN apt-get update && \
    apt-get install -y curl bash ca-certificates && \
    bash -c '\
        set -e; \
        KUBECTL_VERSION=$(curl -sSL https://dl.k8s.io/release/stable.txt); \
        echo "Installing kubectl version $KUBECTL_VERSION"; \
        curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; \
        install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
        rm kubectl' && \
    apt-get purge -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



WORKDIR /app

RUN pip install --no-cache-dir python-digitalocean kubernetes

COPY . .

CMD ["python", "k8s.py"]
