
# **03 — Building CI Pipelines**

## **3.1 What is a CI Pipeline?**

A **Continuous Integration (CI) pipeline** automatically verifies your code whenever you push or open a pull request.

A typical CI workflow includes:

1. **Code checkout**
2. **Dependency installation**
3. **Build the source code**
4. **Lint & format checks**
5. **Unit tests**
6. **Integration tests**
7. **Code quality tools**
8. **Artifact packaging** (optional)
9. **Caching for speed**

The CI pipeline ensures that **every commit is safe** before merging into main.

---

# **3.2 Best Practices for CI**

Before building the pipeline, understand these core best practices:

### ✔️ Keep CI fast (goal: < 10 minutes)

* Use caching
* Use matrix builds only when needed
* Split heavy tests into separate jobs

### ✔️ Fail fast

Tests should be the very first step after installing deps.

### ✔️ Run CI on pull requests

Never allow untested code to merge.

### ✔️ Upload artifacts

* Test results
* Coverage
* Build outputs

### ✔️ Run multiple runtime versions

Test your app on multiple Node/Python/Java versions.

### ✔️ Use linting + formatting

Avoid code-quality issues early.

---

# **3.3 A Real CI Pipeline Structure**

We will build a CI pipeline with these jobs:

| Job                   | Purpose                                      |
| --------------------- | -------------------------------------------- |
| **lint**              | Check formatting & code style                |
| **test**              | Run unit tests using matrix builds           |
| **build**             | Build the application and generate artifacts |
| **integration-tests** | Run slower integration tests                 |
| **report**            | Aggregate results / upload artifacts         |

The pipeline should look like this:

```
lint → test → build → integration-tests → report
     └─────────── dependencies ────────────┘
```

---

# **3.4 Creating the Workflow File**

Create:

```
.github/workflows/ci.yml
```

---

# **🚀 3.5 Full CI Pipeline (Professional Example)**

This workflow includes everything:

```yaml
name: CI Pipeline

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint --if-present

  test:
    runs-on: ubuntu-latest
    needs: lint
    strategy:
      matrix:
        node: [18, 20]

    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}

      - name: Cache dependencies
        uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-npm-${{ hashFiles('package-lock.json') }}

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm test --if-present

      - name: Upload test coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-${{ matrix.node }}
          path: coverage/

  build:
    runs-on: ubuntu-latest
    needs: test

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Build project
        run: npm run build --if-present

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: dist/

  integration-tests:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - uses: actions/checkout@v4

      - name: Run integration tests
        run: npm run test:integration --if-present
        env:
          API_URL: ${{ secrets.API_URL }}
          API_KEY: ${{ secrets.API_KEY }}

      - name: Upload integration test logs
        uses: actions/upload-artifact@v4
        with:
          name: integration-logs
          path: logs/

  report:
    runs-on: ubuntu-latest
    needs: [build, test, integration-tests]

    steps:
      - name: Final summary
        run: echo "CI pipeline completed successfully."
```

---

# ✔️ **3.6 Breaking Down Each Part**

### **(1) Lint Job**

Keeps code formatting standards clean.

### **(2) Test Job With Matrix**

Tests code on Node 18 & 20 simultaneously.

### **(3) Build Job**

Builds the production-ready version.

### **(4) Integration Tests**

Runs more expensive tests after build artifacts are produced.

### **(5) Report Job**

Aggregates and finishes the pipeline.

---

# **3.7 Adding Job Dependencies**

You control the job order with:

```yaml
needs: lint
```

Multiple dependencies:

```yaml
needs: [test, build]
```

This creates a **directed workflow**, ensuring jobs run in the right order.

---

# **3.8 Common CI Pipeline Add-Ons**

You can extend CI with:

### ✔️ Code scanning

```yaml
uses: github/codeql-action/init@v3
```

### ✔️ Dependency scanning

```yaml
uses: snyk/actions/node@master
```

### ✔️ Automatic tagging

```yaml
run: git tag v1.${{ github.run_number }}
```

### ✔️ Slack/Teams notifications

```yaml
uses: slackapi/slack-github-action@v1.24
```

---

# **3.9 CI Pipeline Troubleshooting Tips**

| Problem                 | Solution                              |
| ----------------------- | ------------------------------------- |
| Cache not working       | Ensure correct hash key               |
| Job failing at checkout | Missing permissions                   |
| Secrets not available   | Ensure repo → Settings → Secrets      |
| Test artifacts empty    | Check test output path                |
| Matrix job slow         | Use narrower versions/parallelization |

---

# **3.10 Summary of Chapter 03**

In this chapter, you learned how to build:

* A real production-grade CI pipeline
* Multiple jobs with dependencies
* Matrix testing (Node versions)
* Caching for faster builds
* Linting, testing, building
* Artifacts and logs storage
* Integration testing
* Reporting jobs

You now have a **solid CI backbone**, which we’ll extend into Docker, CD, Kubernetes, and Azure pipelines.

---

