
# End-to-End CI/CD with Azure DevOps, Docker, and ArgoCD for Kubernetes

This documentation walks you through a complete DevOps pipeline for microservices, starting from Dockerizing services, composing with Docker Compose, migrating to Azure Repos, building a multi-stage YAML pipeline in Azure DevOps, and finally deploying to Kubernetes using ArgoCD.

---

## Project Structure

```
/my-microservices-app
├── service-a/
│   ├── Dockerfile
│   └── src/
├── service-b/
│   ├── Dockerfile
│   └── src/
├── docker-compose.yml
└── azure-pipelines.yml
```

Each service is a microservice (e.g., Node.js, Flask, Spring Boot) with its own Dockerfile.

---

## Step 1: Dockerizing Microservices

Each microservice should contain a `Dockerfile`.

### Example: `service-a/Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

Repeat for other services using their respective languages.

---

## Step 2: Local Development with Docker Compose

Create a `docker-compose.yml` to test all microservices locally.

### `docker-compose.yml`

```yaml
version: "3.9"
services:
  service-a:
    build: ./service-a
    ports:
      - "3000:3000"
  service-b:
    build: ./service-b
    ports:
      - "4000:4000"
```

To run:

```bash
docker-compose up --build
```

---

## Step 3: Move Code to Azure Repos

1. Create a new project in Azure DevOps.
2. Go to Repos > Files > Import a Repository.
3. Paste your GitHub repo URL.

To push local code:

```bash
git remote set-url origin https://dev.azure.com/YOUR_ORG/YOUR_PROJECT/_git/YOUR_REPO
git push -u origin --all
```

---

## Step 4: Azure DevOps Multi-Stage Pipeline (CI/CD)

Create an `azure-pipelines.yml` in the root of the repo:

### `azure-pipelines.yml`

```yaml
trigger:
  branches:
    include:
      - main

stages:
  - stage: Build
    displayName: 'Build and Push Docker Images'
    jobs:
      - job: Build
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: DockerInstaller@0

          - script: |
              docker build -t yourregistry.azurecr.io/service-a:$(Build.BuildId) ./service-a
              docker build -t yourregistry.azurecr.io/service-b:$(Build.BuildId) ./service-b
            displayName: 'Build Docker Images'

          - script: |
              echo $(DOCKER_PASSWORD) | docker login yourregistry.azurecr.io -u $(DOCKER_USERNAME) --password-stdin
              docker push yourregistry.azurecr.io/service-a:$(Build.BuildId)
              docker push yourregistry.azurecr.io/service-b:$(Build.BuildId)
            displayName: 'Push Images to ACR'

  - stage: Deploy
    displayName: 'Deploy to Kubernetes via ArgoCD'
    dependsOn: Build
    jobs:
      - job: Deploy
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: |
              echo "Updating ArgoCD application manifests..."
              git clone https://$(GIT_USERNAME):$(GIT_PAT)@github.com/your-org/argocd-configs.git
              cd argocd-configs
              sed -i "s|service-a:.*|service-a:$(Build.BuildId)|" k8s/service-a/deployment.yaml
              sed -i "s|service-b:.*|service-b:$(Build.BuildId)|" k8s/service-b/deployment.yaml
              git config user.email "ci@azuredevops.com"
              git config user.name "Azure DevOps"
              git commit -am "Update images to build $(Build.BuildId)"
              git push
            displayName: 'Push Updated Manifests to Git (ArgoCD watches this repo)'
```

---

## Step 5: Create Azure DevOps Variable Group

Go to Project Settings > Pipelines > Library and create a variable group with:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `GIT_USERNAME`
- `GIT_PAT` (GitHub Personal Access Token)

Make sure to enable "Link secrets from Azure Key Vault" if applicable.

---

## Step 6: Setup Kubernetes Cluster (AKS)

```bash
az aks create --resource-group my-rg --name myAKSCluster --node-count 2 --generate-ssh-keys
az aks get-credentials --resource-group my-rg --name myAKSCluster
```

To allow AKS to pull from ACR:

```bash
az aks update -n myAKSCluster -g my-rg --attach-acr <your-acr-name>
```

---

## Step 7: Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Expose ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Get admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

---

## Step 8: Create ArgoCD Application

### Example: `argocd-app.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: microservices-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/argocd-configs.git
    targetRevision: HEAD
    path: k8s/
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply:

```bash
kubectl apply -f argocd-app.yaml
```

---

## Final Flow Summary

1. Developer pushes code to Azure Repos.
2. Azure DevOps pipeline builds Docker images and pushes them to Azure Container Registry.
3. Pipeline updates ArgoCD manifests with new image tags.
4. ArgoCD automatically syncs and deploys to Kubernetes.

---

## Requirements

- Azure DevOps organization and project
- Azure Container Registry (ACR)
- Kubernetes cluster (e.g., AKS)
- ArgoCD installed in the cluster
- Docker installed locally
- GitHub or Azure Repos

---

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Azure DevOps Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/)

---

## Troubleshooting

- Cannot push to ACR: Ensure the AKS identity is linked to ACR.
- Pipeline login issues: Verify Docker credentials in your variable group.
- ArgoCD not syncing: Check manifest paths and image tag updates.

---

## Contributions

Feel free to fork, open pull requests, or raise issues to improve this guide.
