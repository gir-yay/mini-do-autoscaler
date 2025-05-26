FROM python:3.10-slim

# Install curl and kubectl
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
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
