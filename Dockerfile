FROM python:3.10-slim

WORKDIR /app

RUN pip install --no-cache-dir python-digitalocean kubernetes


COPY . .

CMD ["python", "k8s.py"]
