FROM node:18-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends tini && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /usr/local/app
COPY package*.json .
RUN npm ci && npm cache clean --force
COPY . .
EXPOSE 3000
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]