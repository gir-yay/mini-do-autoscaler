FROM python:3.10-slim

# Install curl and kubectl
RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt) && \
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    apt-get purge -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir python-digitalocean kubernetes

# Copy your application code
COPY . .

# Run the autoscaler
CMD ["python", "k8s.py"]
