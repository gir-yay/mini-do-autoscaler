FROM python:3.10-slim

RUN bash -c '\
    set -e; \
    KUBECTL_VERSION=$(curl -sSL https://dl.k8s.io/release/stable.txt); \
    echo "Installing kubectl version $KUBECTL_VERSION"; \
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
    rm kubectl'



# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir python-digitalocean kubernetes

# Copy your application code
COPY . .

# Run the autoscaler
CMD ["python", "k8s.py"]
