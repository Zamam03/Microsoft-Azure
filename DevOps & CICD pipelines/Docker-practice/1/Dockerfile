FROM python:3.11-slim 
RUN apt-get update && \ apt-get install -y --no-install-recommends curl && \ rm -rf /var/lib/apt/lists/*
WORKDIR /usr/local/app
COPY requirements.txt 
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]