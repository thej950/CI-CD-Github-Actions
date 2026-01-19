# **02 — GitHub Actions Fundamentals (Beginner Level)**

## **2.1 Understanding the Structure of a Workflow**

A GitHub Actions workflow is a YAML file with 4 main parts:

1. **name** – What the workflow is called
2. **on** – What triggers it
3. **jobs** – What tasks it runs
4. **steps** – Commands/actions inside each job

Example structure:

```yaml
name: Example Workflow

on: push

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Step 1
        run: echo "Hello"
```

Everything we learn next expands on these core parts.

---

# **2.2 Triggers (Events)**

Triggers define **when** your workflow runs.

### Common triggers:

| Trigger             | Description                   |
| ------------------- | ----------------------------- |
| `push`              | Runs when someone pushes code |
| `pull_request`      | Runs on PR creation/update    |
| `schedule`          | Cron-based scheduled jobs     |
| `workflow_dispatch` | Manual run button             |
| `release`           | When creating GitHub releases |
| `workflow_call`     | Called by another workflow    |

### Example: Run on push to main only

```yaml
on:
  push:
    branches:
      - main
```

### Example: Run on schedule (every day at 2 AM)

```yaml
on:
  schedule:
    - cron: "0 2 * * *"
```

### Example: Manual trigger

```yaml
on:
  workflow_dispatch:
```

---

# **2.3 Jobs**

Jobs group related work and run **on runners**.

### Basic job example:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building..."
```

### Key points:

* Each workflow can have **multiple jobs**
* Jobs run in **parallel** by default
* Use `needs:` to control job order

Example:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Testing..."

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: echo "Build only after tests"
```

---

# **2.4 Runners**

A **runner** is the machine that executes your jobs.

GitHub provides 3 main types of hosted runners:

| Runner           | OS      |
| ---------------- | ------- |
| `ubuntu-latest`  | Linux   |
| `windows-latest` | Windows |
| `macos-latest`   | Mac     |

---

### Self-Hosted Runners

You can register your own machine to run jobs:

* Your own server
* A cloud VM
* A Kubernetes pod
* A GPU machine

Useful when:

* You need custom dependencies
* Your builds take long
* You want full control

---

# **2.5 Steps**

Steps run inside the job in order.

Two types:

### **1. run:** → Direct shell command

```yaml
steps:
  - name: Print branch
    run: echo "Branch: $GITHUB_REF"
```

### **2. uses:** → Pre-built action

```yaml
steps:
  - name: Check out code
    uses: actions/checkout@v4
```

---

# **2.6 Using Marketplace Actions**

GitHub Actions Marketplace has thousands of prebuilt actions.

### Example: Setting up Node.js

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 18
```

### Example: Uploading artifacts

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/
```

---

# **2.7 Environment Variables**

Two forms:

### **1. `env:` block**

```yaml
env:
  NODE_ENV: production
```

### **2. Using inside steps**

```yaml
run: echo "Current env: $NODE_ENV"
```

### Built-in environment variables

GitHub provides many defaults:

* `${{ github.sha }}`
* `${{ github.ref }}`
* `${{ github.actor }}`
* `${{ github.event_name }}`

Example:

```yaml
run: echo "Commit SHA: ${{ github.sha }}"
```

---

# **2.8 Secrets**

Secrets store sensitive values like:

* API keys
* Cloud access credentials
* Tokens
* Passwords

Add them at:

**GitHub Repo → Settings → Secrets and Variables → Actions**

Use in workflow:

```yaml
run: echo ${{ secrets.MY_API_KEY }}
```

Secrets are **masked in logs**.

---

# **2.9 Artifacts**

Artifacts let you store files generated during workflow execution.

### Upload:

```yaml
- name: Upload build files
  uses: actions/upload-artifact@v4
  with:
    name: my-artifact
    path: dist/
```

### Download:

```yaml
- uses: actions/download-artifact@v4
  with:
    name: my-artifact
```

Useful for:

* Build outputs
* Test reports
* Docker image tar files
* Log bundles

---

# **2.10 Caching (Huge Performance Boost)**

Caching dependencies saves build time.

Example: cache npm dependencies

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('package-lock.json') }}
```

Also works for:

* pip
* Maven
* Gradle
* Docker layers
* Yarn

---

# **2.11 Matrix Builds (Multi-Version Testing)**

Matrix lets you run the **same job on multiple environments**.

Example: test on Node versions 16, 18, 20:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: [16, 18, 20]

    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
      - run: npm test
```

You can also matrix **OS × version**:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    python: [3.9, 3.10, 3.11]
```

---

# **2.12 Summary of Chapter 02**

You now understand:

* How workflows are structured
* Events and triggers
* Jobs and runners
* Steps and marketplace actions
* Environment variables and secrets
* Artifacts
* Caching for faster builds
* Matrix builds (multi-version testing)


Perfect — here is a **full hands-on practical exercise** based on everything you learned in **Chapter 02**.
By the end of this exercise, you will build a complete beginner-level CI workflow that:

* Checks out code
* Sets up a runtime environment
* Installs dependencies
* Uses caching
* Runs tests
* Stores test reports as artifacts
* Demonstrates matrix builds
* Uses secrets
* Uses environment variables

This is the foundation for the advanced CI/CD pipelines later.

---

# **🧪 Practical Exercise: Build a Real CI Workflow**

We will create a workflow called **“CI Pipeline”** that includes:

1. Trigger on push & pull request
2. Run tests on **Node 18 & 20** (matrix)
3. Cache Node dependencies
4. Run tests
5. Upload test results
6. Use environment variables
7. Access a secret

This workflow applies equally for Node/Python/Java — you can adapt it easily.

---

# ✅ **Step 1 — Create the Workflow File**

Create:

```
.github/workflows/ci.yml
```

Add this full workflow:

---

# **🚀 Full CI Workflow Example (Complete)**

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  APP_ENV: "testing"
  LOG_LEVEL: "debug"

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node: [18, 20]

    steps:
      # Step 1: Checkout the code
      - name: Checkout repository
        uses: actions/checkout@v4

      # Step 2: Use Node (matrix version)
      - name: Setup Node ${{ matrix.node }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}

      # Step 3: Cache dependencies
      - name: Cache npm dependencies
        uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-npm-

      # Step 4: Install dependencies
      - name: Install dependencies
        run: npm ci

      # Step 5: Print environment variables
      - name: Print env vars
        run: |
          echo "Environment: $APP_ENV"
          echo "Log level: $LOG_LEVEL"

      # Step 6: Use a secret (create SECRET_MESSAGE manually)
      - name: Print a secret (masked)
        run: echo "Secret message is ${{ secrets.SECRET_MESSAGE }}"

      # Step 7: Run tests
      - name: Run tests
        run: npm test --if-present

      # Step 8: Upload test results
      - name: Upload test reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results-${{ matrix.node }}
          path: |
            ./tests/results
            ./coverage
```

---

# 🚀 **What This Workflow Demonstrates**

### ✔️ **1. Triggers**

Runs on push & PR into main.

### ✔️ **2. Environment Variables**

Defined globally:

```yaml
env:
  APP_ENV: "testing"
```

### ✔️ **3. Secrets Usage**

Uses a secret named `SECRET_MESSAGE`:

```yaml
echo ${{ secrets.SECRET_MESSAGE }}
```

### ✔️ **4. Matrix Builds**

Runs the job twice:

* Node 18
* Node 20

### ✔️ **5. Caching**

Caches npm dependencies:

```yaml
uses: actions/cache@v4
```

### ✔️ **6. Artifact Storage**

Uploads test results per Node version.

### ✔️ **7. Installing Dependencies and Running Tests**

Standard CI tasks.

---

# ✔️ **Step 2 — Create a Secret**

Go to:

**GitHub Repo → Settings → Secrets and Variables → Actions → New Repository Secret**

Name:

```
SECRET_MESSAGE
```

Value:

```
hello-from-secrets
```

---

# ✔️ **Step 3 — Trigger the Workflow**

Do any of these:

* Push a commit
* Re-run an existing failed job
* Open a PR to main

---

# ✔️ **Step 4 — Open the Results**

Go to the **Actions** tab.

You will see:

* 2 matrices: Node 18, Node 20
* Logs for each step
* Artifacts at the bottom
* Secrets masked in logs
* Cache hit/miss

This is your first *real* CI pipeline.

---

# 🎯 **What You Have Learned in This Exercise**

You now practiced:

* Creating workflow files
* Using steps and actions
* Caching dependencies
* Using matrix builds
* Working with environment variables
* Using GitHub Secrets securely
* Uploading and viewing artifacts
* Understanding logs and build output

This knowledge is essential before we build:

* Docker CI
* Docker image pushing
* Kubernetes deployment
* Azure integration

  ### Nodejs Code
  Sure! Here is a **simple Node.js project** you can use for GitHub Actions, CI/CD, Docker, or any tutorial.

I'll give you:

✔ Folder structure
✔ package.json
✔ index.js
✔ a simple test
✔ .gitignore

---

# 📁 **Project Structure**

```
simple-node-app/
│
├── package.json
├── index.js
├── .gitignore
└── test/
    └── app.test.js
```

---

# 📦 **package.json**

```json
{
  "name": "simple-node-app",
  "version": "1.0.0",
  "description": "A simple Node.js app for GitHub Actions demo",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "jest"
  },
  "author": "Your Name",
  "license": "MIT",
  "devDependencies": {
    "jest": "^29.7.0"
  }
}
```

---

# 🟩 **index.js**

```js
function sum(a, b) {
  return a + b;
}

console.log("App is running… Sum(2,3) =", sum(2, 3));

module.exports = sum;
```

---

# 🧪 **test/app.test.js**

```js
const sum = require('../index');

test('adds 2 + 3 = 5', () => {
  expect(sum(2, 3)).toBe(5);
});
```

---

# 📝 **.gitignore**

```
node_modules/
npm-debug.log
.env
```

---

# 🚀 Want GitHub Actions workflow too?

Here’s a simple workflow for CI:

```yaml
name: Node.js CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test
```

---



---

