### Argocd Github Actions Project

## 1️⃣ Prerequisites

| Item                   | Purpose                                                                                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **AWS Account**        | EKS cluster hosting                                                                                                                              |
| **EKS cluster**        | Kubernetes cluster already created (`eksctl create cluster …`)                                                                                   |
| **Argo CD installed**  | `kubectl create namespace argocd && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml` |
| **Docker Hub account** | To host container images                                                                                                                         |
| **GitHub repository**  | Contains: `src` code, `Dockerfile`, `deploymentfiles/deployment.yml`, and workflow in `.github/workflows/cicd.yml`                               |
| **Java/Maven app**     | Your Java code that builds a JAR/WAR                                                                                                             |


## 2️⃣ Local Repository Layout

```
argocd_github_actions_project/
 ├─ src/...
 ├─ Dockerfile
 ├─ pom.xml
 └─ deploymentfiles/
      └─ deployment.yml   # Kubernetes Deployment + Service
```

## 3️⃣ GitHub Secrets

In **Repository → Settings → Secrets and variables → Actions → New repository secret**, add:

| Secret            | Example                         |
| ----------------- | ------------------------------- |
| `DOCKER_USERNAME` | your-dockerhub-username         |
| `DOCKER_PASSWORD` | your-dockerhub-password         |
| `ARGOCD_SERVER`   | `<LoadBalancer-IP or hostname>` |
| `ARGOCD_PASSWORD` | Argo CD admin password          |



## 4️⃣ Enable Workflow Write Access

1. Repo **Settings → Actions → General → Workflow permissions**
2. Select **“Read and write permissions”** and save.


## 5️⃣ GitHub Actions Workflow

Create file: `.github/workflows/cicd.yml`

```
https://github.com/jadalaramani/argocd_github_actions_project/blob/main/.github/workflows/cicd.yaml
```

## 6️⃣ Argo CD Application

In the Argo CD web UI:

1. **+ New App**
2. Name: `my-app`
3. Repo URL: `https://github.com/jadalaramani/argocd_github_actions_project.git`
4. Path: `deploymentfiles`
5. Cluster URL: `https://kubernetes.default.svc`
6. Namespace: `default`
7. Create.
8. Optionally set **Sync Policy → Automatic** so deployments happen without manual clicks.


## 7️⃣ Pipeline Flow

1. Developer pushes code to **main**.
2. **GitHub Actions**:

   * Builds JAR/WAR with Maven.
   * Builds Docker image `ramanijadala/webapp:<run_number>`.
   * Pushes to Docker Hub.
   * Replaces `:tag` in `deployment.yml` with that run number.
   * Commits the updated manifest back to the repository.
     
3. **Argo CD** detects the Git change and deploys the updated image to EKS.
4. Pods in EKS pull the exact image tag and run.


## 8️⃣ Verification

* **GitHub Actions Logs**: should show the new image tag and a successful commit.
* **GitHub Repo**: `deployment.yml` contains `ramanijadala/webapp:<number>`.
* **Docker Hub**: new tag appears.
* **Argo CD UI**: Application health = **Healthy**, pods running with the correct image.


## 9️⃣ Troubleshooting Tips

* **403 push error**: confirm “Read and write permissions” enabled and `GITHUB_TOKEN` env is present.
* **ImagePullBackOff**: check that `deployment.yml` really contains the latest numeric tag and that the image exists in Docker Hub.
* **Namespace errors**: ensure Destination namespace is `default` (no spaces).
