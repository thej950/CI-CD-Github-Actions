Great — here is **Chapter 05: CD Pipelines (Continuous Deployment)**.
This is where your CI becomes a full **CI/CD pipeline**, enabling automated deployments after your code passes all checks.

This chapter gives you:

* CD fundamentals
* Environments & approvals
* Deploying after CI
* Reusable deployment workflows
* Branch-based deployment strategies
* Rollback strategies
* Secrets, versioning, and best practices

---

# **05 — CD Pipelines (Advanced)**

## **5.1 What is Continuous Deployment?**

CD is the automated process of deploying your **tested, verified, stable** build to your environments:

* Development
* QA / Testing
* Staging
* Production

A CD pipeline typically includes:

1. Downloading build artifacts
2. Using secrets / environment variables
3. Running deployment scripts (kubectl, helm, SSH, Azure CLI, etc.)
4. Switching versions
5. Health checks
6. Rollback if deployment fails

---

# **5.2 Triggering Deployment Only After CI Passes**

You should **never deploy directly** from the push event.
CD must depend on CI.

Example:

```
CI → Build Docker → Push image → CD
```

The CD pipeline “listens” for:

* Successful CI
* Tagged release
* Manual approval

---

# **5.3 Deployment Environments in GitHub**

GitHub provides managed environments:

* `dev`
* `staging`
* `prod`

Each environment can have:

* Environment-specific secrets
* Protection rules
* Required reviewers
* Wait timers
* Custom secrets per environment

### Example environment secrets:

| Environment | Secrets      |
| ----------- | ------------ |
| dev         | DB_CONN_DEV  |
| staging     | DB_CONN_STG  |
| prod        | DB_CONN_PROD |

This allows **safe deployments** depending on environment.

---

# **5.4 Creating a Deployment Workflow**

Create file:

```
.github/workflows/deploy.yml
```

### **Step 1 — Set up the trigger**

Deploy only when a new release tag is pushed:

```yaml
on:
  push:
    tags:
      - "v*.*.*"
```

This means:

* Push a Git tag `v1.0.0`
* A release deployment begins automatically

---

# **5.5 Basic Deployment Template**

Here is the simplest CD pipeline that downloads the build artifact and deploys it.

```yaml
name: Deploy App

on:
  push:
    tags:
      - "v*"

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: prod
      url: https://myapp.com

    steps:
      - uses: actions/checkout@v4

      - uses: actions/download-artifact@v4
        with:
          name: build-output

      - name: Deploy
        run: |
          echo "Deploying version ${{ github.ref_name }}"
```

This shows the concept, but we will move to real deployment soon (Kubernetes in Chapter 6).

---

# **5.6 Releasing New Versions from GitHub Actions**

CI should produce versions automatically:

### Step → Tag version → Deploy

```yaml
- name: Create release
  uses: softprops/action-gh-release@v2
  with:
    tag_name: v1.${{ github.run_number }}
```

This automatically triggers your CD workflow.

---

# **5.7 Deployment Strategies**

### ✔️ Strategy 1: Branch-Based

* Merge to `dev` → deploy to development
* Merge to `staging` → deploy to staging
* Merge to `main` → deploy to production

```yaml
on:
  push:
    branches:
      - dev
      - staging
      - main
```

### ✔️ Strategy 2: Tag-Based

* Push `v1.0.0` → deploy to production
* Push `v1.0.0-rc1` → deploy to staging

### ✔️ Strategy 3: Manual Deployment (workflow_dispatch)

For controlled releases:

```yaml
on:
  workflow_dispatch:
    inputs:
      version:
        type: string
```

You run it manually from the GitHub UI.

---

# **5.8 Using Secrets & Environment-Specific Config**

GitHub separates secrets by environment:

* Only `dev` jobs can use `dev` secrets
* Only `prod` jobs can use `prod` secrets

Example:

```yaml
env:
  DB_URL: ${{ secrets.DB_URL }}
  API_KEY: ${{ secrets.API_KEY }}
```

---

# **5.9 Deployment Job Structure (Recommended)**

A real deployment job should:

1. **Checkout code**
2. **Download build artifacts**
3. **Authenticate with cloud provider**
4. **Deploy container** (Docker, Kubernetes, Azure)
5. **Run health checks**
6. **Rollback on failure**

Example rollback logic:

```yaml
- name: Health check
  run: curl -f https://myapp.com/health || exit 1
```

If this step fails → GitHub Actions marks job failed → triggers rollback workflow.

---

# **5.10 Real Example: Container Deployment**

Below is a CD job that:

* Pulls Docker image from registry
* Runs container on a VM / self-hosted server

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: SSH to Server and Deploy
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_KEY }}
          script: |
            docker pull myapp:latest
            docker stop app || true
            docker rm app || true
            docker run -d --name app -p 80:80 myapp:latest
```

This is simple VM-based CD.

The next chapter takes this further to **full Kubernetes deployment**.

---

# **5.11 Deployment Rollback Strategies**

### ✔️ Automatic rollback

Deployments should fail if health check fails.

### ✔️ Manual rollback

Trigger a rollback workflow:

```yaml
on:
  workflow_dispatch:
    inputs:
      version:
```

### ✔️ Kubernetes rollback (built-in)

```sh
kubectl rollout undo deployment/myapp
```

---

# **5.12 Summary of Chapter 05**

You learned:

* CD pipeline fundamentals
* GitHub Environments (dev/stage/prod)
* Manual approvals
* Release-based deployments
* Branch-based deployments
* Using artifacts in deployment
* Using secrets securely
* Real deployment examples
* Rollback strategy basics



---

