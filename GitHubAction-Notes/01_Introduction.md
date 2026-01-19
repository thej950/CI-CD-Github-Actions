
# **01 — Introduction to GitHub Actions**

## **1.1 What is GitHub Actions?**

GitHub Actions is a **CI/CD automation platform built directly into GitHub**.
It allows you to automate tasks such as:

* Running tests automatically
* Building source code
* Packaging applications into Docker images
* Deploying to servers, cloud platforms, Kubernetes clusters
* Running scheduled jobs (cron)
* Managing releases
* Security scanning and code quality checks

Actions are defined using **YAML workflow files** under:

```
.github/workflows/
```

Example:

```
.github/workflows/ci.yml
```

Everything happens **inside your GitHub repository**, with no external tools required.

---

## **1.2 What is CI/CD?**

### **CI — Continuous Integration**

The process of **integrating code frequently** and verifying it automatically by:

* Running tests
* Validating code quality
* Checking security vulnerabilities
* Building artifacts

A CI pipeline ensures code works before merging to the main branch.

---

### **CD — Continuous Delivery/Deployment**

The process of **automatically releasing tested code** to environments such as:

* Development
* Staging
* Production

CD can deploy to:

* Virtual machines
* Docker containers
* Kubernetes clusters
* Cloud platforms (Azure, AWS, GCP)

GitHub Actions supports **both Delivery and Deployment** depending on how automated you want to be.

---

## **1.3 Why Use GitHub Actions? (Benefits)**

###  **1. Integrated with GitHub**

No need for external CI servers like Jenkins or Azure DevOps — everything stays in your repo.

### ⚙️ **2. Fully automatable**

Any repetitive task can be automated:
tests → build → docker image → deploy → notify → monitor

### ☁️ **3. Cloud hosted runners**

GitHub provides runners like:

* `ubuntu-latest`
* `windows-latest`
* `macos-latest`

No setup required.

###  **4. Extensible through Marketplace**

Over **25,000+ ready-made actions**, including:

* Setup Node/Python/Java/.NET
* Build Docker images
* Login to Azure/AWS/GCP
* Deploy to Kubernetes
* Code scanning

###  **5. Supports advanced CI/CD**

* Matrix builds
* Job parallelization
* Caching
* Reusable workflows
* Deployment environments
* Approvals
* OIDC authentication

### 🔐 **6. Secure**

* GitHub Secrets
* Environment protections
* Fine-grained permissions
* Encrypted logs

All perfect for enterprise use.

---

## **1.4 How GitHub Actions Works (Concept Overview)**

### **Workflow**

A complete automation pipeline defined in a `.yml` file.

Example:

```yaml
name: CI Pipeline
on: push
jobs:
  build:
    runs-on: ubuntu-latest
```

---

### **Event**

A trigger that starts a workflow, such as:

* `push`
* `pull_request`
* `release`
* `workflow_dispatch`
* `schedule`

---

### **Job**

A collection of steps executed on a runner.

* Jobs can run in **parallel**
* Or run **in sequence** using `needs:`

---

### **Step**

An individual automation command:

* Running a script (`npm test`)
* Calling an action (`actions/checkout`)
* Logging into Azure
* Building a Docker image

Steps run **inside the same machine**.

---

### **Runner**

The actual machine where jobs run.

Types:

1. **GitHub-hosted runners** (free)

   * Ubuntu, Windows, macOS

2. **Self-hosted runners**

   * You provide your own server/VM
   * Useful for:

     * Private networks
     * GPU workloads
     * Long-running jobs
     * Custom hardware

---

## **1.5 Understanding YAML (for Workflows)**

GitHub uses simple YAML syntax.

### Basics:

```yaml
key: value
list:
  - item1
  - item2
jobs:
  build:
    runs-on: ubuntu-latest
```

### Indentation

* Must use **spaces**, not tabs
* 2 spaces is recommended

### Interpolations:

```yaml
${{ github.sha }}
${{ env.IMAGE_TAG }}
${{ secrets.AZURE_CREDENTIALS }}
```

---

## **1.6 Where Workflows Live in a Repo**

All workflows are stored in:

```
.github/workflows/
```

Examples:

```
ci.yml
build.yml
deploy.yml
docker-publish.yml
```

You can have unlimited workflows.

---

Got it — you want **Section 1.8** (your “0.18”).
Here it is.

---

# **1.8 — Hands-On: Creating Your First GitHub Actions Workflow**

This section gives you a **practical, step-by-step exercise** to create your very first workflow.
You will learn how to:

* Create the `.github/workflows/` directory
* Add your first workflow file
* Trigger a workflow on `push`
* Run simple commands
* View workflow runs

This is the foundation for all advanced CI/CD work later.

---

# ✅ **Step 1 — Create the Workflow Folder**

Inside your repository, create:

```
.github/workflows/
```

The folder must be exactly that name (all lowercase).

---

# ✅ **Step 2 — Create Your First Workflow File**

Create:

```
.github/workflows/hello.yml
```

Paste this minimal workflow:

```yaml
name: Hello GitHub Actions

on:
  push:
    branches:
      - main
      - master

jobs:
  hello-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print a greeting
        run: echo "Hello from GitHub Actions!"

      - name: Show current time
        run: date

      - name: Show repository files
        run: ls -la
```

---

# ✅ **Step 3 — Commit and Push**

Commit and push your file:

```
git add .github/workflows/hello.yml
git commit -m "Add first GitHub Actions workflow"
git push
```

As soon as you push, your workflow **automatically triggers**.

---

# ✅ **Step 4 — Check the Workflow Run**

1. Go to your GitHub repository
2. Click **Actions** (top menu)
3. You’ll see a new workflow named:
   **Hello GitHub Actions**
4. Open it to see detailed logs for each step

You should see:

```
Hello from GitHub Actions!
Sun Nov 12 10:33:21 UTC 2025
(total file list...)
```

This confirms your runner executed your commands successfully.

---

# ✅ **Step 5 — Modify a Workflow and Trigger Again**

Try updating:

```yaml
- name: Print workflow context
  run: echo "Triggered by: ${{ github.event_name }}"
```

Push again.
You’ll now see which event triggered the workflow (push, PR, etc).

---

# 🎉 What You Have Learned

By completing section **1.8**, you now know:

* How to create workflow YAML files
* Where to store them
* How events trigger workflows
* How jobs and steps work
* How to read output logs


