

# **04 — Docker Integration (Intermediate Level)**

## **4.1 Why Use Docker in CI/CD Pipelines?**

Docker helps you:

* Package your application + dependencies
* Create consistent environments across dev/staging/prod
* Build immutable, versioned images
* Deploy the same container to Kubernetes, Azure, or any cloud

GitHub Actions makes this easy by automating:

* Build
* Test
* Tag
* Push
* Scan (optional)

---

# **4.2 Preparing Your Repository**

### **Dockerfile Example (Node.js)**

```dockerfile
# Stage 1: Builder
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Production image
FROM node:20-alpine AS prod
WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY package*.json ./

RUN npm ci --only=production

CMD ["node", "dist/index.js"]
```

This is an optimized multi-stage Dockerfile:

* Faster builds
* Smaller image size
* Best practice for CI/CD pipelines

---

# **4.3 GitHub Actions Setup for Docker Builds**

### Use the official Docker GitHub Actions:

| Purpose                    | Action                       |
| -------------------------- | ---------------------------- |
| Set up QEMU for cross-arch | `docker/setup-qemu-action`   |
| Set up Buildx              | `docker/setup-buildx-action` |
| Login to registry          | `docker/login-action`        |
| Build & push image         | `docker/build-push-action`   |

---

# **4.4 Building a Docker Image (CI)**

Create file:

```
.github/workflows/docker-ci.yml
```

Add:

```yaml
name: Docker Build (CI)

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          platforms: linux/amd64
          push: false
          tags: myapp:ci
```

This builds your Docker image **without pushing it** — great for CI testing.

---

# **4.5 Adding Docker Layer Caching (Huge Speed Gain)**

Docker builds can be slow. Use GitHub cache backend:

```yaml
with:
  cache-from: type=gha
  cache-to: type=gha,mode=max
```

Updated example:

```yaml
      - name: Build Docker image with cache
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          platforms: linux/amd64
          push: false
          tags: myapp:ci
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

This can **cut build time by 50–70%**.

---

# **4.6 Pushing Docker Images to Registries**

You can push Docker images to:

* GitHub Container Registry (GHCR)
* Docker Hub
* Azure Container Registry (ACR)
* AWS ECR
* GCP GAR

Here we cover all major registries.

---

# **4.7 Push Image to GitHub Container Registry (GHCR)**

### Step 1 — Add secret

Create a secret:

```
GHCR_TOKEN
```

Value: GitHub PAT with `write:packages`

### Step 2 — Add workflow

```yaml
name: Build and Push to GHCR

on:
  push:
    branches: [ main ]
    tags:
      - "v*"

env:
  IMAGE_NAME: ghcr.io/${{ github.repository }}/myapp

jobs:
  push-image:
    runs-on: ubuntu-latest
    permissions:
      packages: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GHCR_TOKEN }}

      - name: Build & Push
        uses: docker/build-push-action@v5
        with:
          push: true
          platforms: linux/amd64
          tags: |
            ${{ env.IMAGE_NAME }}:latest
            ${{ env.IMAGE_NAME }}:${{ github.sha }}
            ${{ env.IMAGE_NAME }}:${{ github.ref_name }}
```

---

# **4.8 Push Image to Azure Container Registry (ACR)**

You need:

* ACR name
* OIDC permission OR Service Principal

### Recommended: OIDC (no passwords!)

Create:

```
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

Workflow:

```yaml
name: Build and Push to ACR

on:
  push:
    branches: [ main ]

env:
  ACR_NAME: myregistry.azurecr.io
  IMAGE_NAME: myapp

jobs:
  push-acr:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Login to ACR
        run: az acr login --name ${{ env.ACR_NAME }}

      - uses: docker/setup-buildx-action@v3

      - name: Build & Push Image to ACR
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: |
            ${{ env.ACR_NAME }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.ACR_NAME }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

---

# **4.9 Multi-Architecture Build (amd64 + arm64)**

Supports:

* Intel/AMD servers
* Apple Silicon (M1/M2)
* Raspberry Pi

Add:

```yaml
platforms: linux/amd64,linux/arm64
```

Example:

```yaml
      - name: Build multi-arch image
        uses: docker/build-push-action@v5
        with:
          platforms: linux/amd64,linux/arm64
          push: true
          tags: myapp:latest
```

---

# **4.10 Tagging Strategies (CI/CD Standard)**

Use multiple tag formats:

| Tag format    | Purpose                  |
| ------------- | ------------------------ |
| `latest`      | Default production image |
| `v1.0.0`      | Release version          |
| `sha-commit`  | Immutable build          |
| `branch-name` | Dev/staging environment  |
| `pr-123`      | PR previews              |

Example:

```yaml
tags: |
  myapp:latest
  myapp:${{ github.sha }}
  myapp:${{ github.ref_name }}
```

---

# **4.11 Docker Image Scanning (Security)**

Optional but highly recommended:

### Use Trivy

```yaml
- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
```

---

# **4.12 Summary of Chapter 04**

You now understand how to:

* Write optimized Dockerfiles
* Build Docker images in GitHub Actions
* Use Docker Buildx and caching
* Push images to GHCR, DockerHub, and ACR
* Authenticate using OIDC
* Perform multi-architecture builds
* Tag Docker images properly
* Scan images for vulnerabilities

This knowledge is required for the next chapter:
**Deploying to Kubernetes (AKS)**.

---



Say **“5”** to continue.
