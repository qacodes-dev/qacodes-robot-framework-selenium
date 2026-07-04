# qacodes-robot-framework-selenium

[![robot](https://github.com/qacodes-dev/qacodes-robot-framework-selenium/actions/workflows/robot.yml/badge.svg?branch=main)](https://github.com/qacodes-dev/qacodes-robot-framework-selenium/actions/workflows/robot.yml)

Keyword-driven UI automation with **Robot Framework** and **SeleniumLibrary**,
built against the [Sauce Demo](https://www.saucedemo.com) storefront. Tests read
almost like plain English, while real engineering discipline lives underneath:
reusable keywords in resource files, locators and config in variable files, and
the **Page Object pattern expressed as one resource file per page**.

This repository backs the qa.codes project sample:
**<https://qa.codes/practice/project-samples/robot-framework-selenium>**

## Overview

- **Tech stack** — Python 3.9+, Robot Framework, SeleniumLibrary, DataDriver,
  webdriver-manager.
- **System under test** — Sauce Demo (`https://www.saucedemo.com`), a stable
  public demo storefront for login, inventory, cart and checkout flows.
- **What it demonstrates** — high-level readable suites, reusable keyword
  resource files, page objects, environment-driven variable files, tag-based
  test selection, data-driven testing with Test Templates, and Robot's
  `report.html` / `log.html` triage artifacts.

## Prerequisites

- **Python 3.9+** (CI runs on 3.11).
- **Google Chrome** installed. Selenium 4's built-in Selenium Manager resolves
  the matching ChromeDriver at runtime (webdriver-manager is a declared
  fallback), so no manual driver download is required.

## Install

```bash
# 1. Clone
git clone https://github.com/qacodes-dev/qacodes-robot-framework-selenium.git
cd qacodes-robot-framework-selenium

# 2. Create and activate a virtual environment
python -m venv .venv
source .venv/bin/activate            # Windows: .venv\Scripts\activate

# 3. Upgrade pip and install everything
python -m pip install --upgrade pip
pip install -r requirements.txt

# 4. Verify
robot --version

# 5. List the tests without running them
robot --dryrun tests/
```

Credentials default to the public Sauce Demo account, so the suites run out of
the box. To point them elsewhere, copy `.env.example` to `.env` and edit it (see
[Environment configuration](#environment-configuration)).

## Run commands

```bash
# Run all tests — writes report.html, log.html, output.xml to results/
robot --outputdir results tests/

# Run only smoke tests by tag — fast feedback
robot --include smoke --outputdir results tests/

# Exclude slow or WIP tests
robot --exclude slow --outputdir results tests/

# Override the environment via command-line variables (override variable files)
robot --variable ENV:staging --variable BROWSER:chrome --outputdir results tests/

# Run a single suite during development
robot --outputdir results tests/login.robot

# Run the data-driven suite (Test Templates) — one result line per input row
robot --outputdir results tests/login_data_driven.robot

# Run headless via a variable (CI / fast local runs)
robot --variable HEADLESS:true --outputdir results tests/

# Merge results from parallel runs (e.g. pabot) into one report and log
rebot --merge --outputdir results results/output-*.xml
```

> `.env` is not read automatically by Robot. Export the variables into your
> shell first (e.g. `set -a; source .env; set +a`) or pass them with
> `--variable`. In CI they are provided as job environment variables.

## Environment configuration

`variables/environments.py` resolves configuration from `os.environ`, so the
same suites run against any environment without edits. Command-line
`--variable` values always take precedence.

| Variable | Required | Description | Example |
| --- | --- | --- | --- |
| `BASE_URL` | yes | Root URL of the application under test | `https://www.saucedemo.com` |
| `BROWSER` | yes | Browser SeleniumLibrary opens — `chrome`, `firefox`, or `headlesschrome` | `chrome` |
| `ENV` | no | Environment name selecting the matching config block | `staging` |
| `HEADLESS` | no | Set to `true` to run the browser headless (used in CI) | `true` |
| `TEST_USER` | yes | Username for the standard test account; a CI secret | `standard_user` |
| `TEST_PASSWORD` | yes | Password for the standard test account; a CI secret | `secret_sauce` |

Secrets live only in a gitignored `.env` locally or in GitHub Actions secrets in
CI — never in committed suites, variable files or data files. The Sauce Demo
credentials shipped as defaults are published openly on the demo's own login
page and are used purely to keep the sample runnable.

## Folder structure

```
requirements.txt                     # Pinned dependencies
tests/                               # .robot suites — one file per feature/journey
  login.robot                        # Valid login, invalid credentials, lockout — smoke/regression
  login_data_driven.robot            # Data-driven login via a Test Template over login_data.csv
  checkout.robot                     # End-to-end add-to-cart → checkout journey
resources/                           # Reusable keyword resource files
  common.robot                       # Open/close browser, screenshot on failure
  pages/                             # Page Objects as resource files
    login_page.robot                 # Login page locators + keywords
    inventory_page.robot             # Inventory page locators + keywords
    checkout_page.robot              # Multi-step checkout page locators + keywords
variables/                           # Environment config and test data
  environments.py                    # Resolves BASE_URL, BROWSER, ENV, ... from os.environ
  login_data.csv                     # username/password/expected rows for the data-driven suite
results/                             # Generated output.xml, report.html, log.html, screenshots (gitignored)
.github/workflows/robot.yml          # CI: install, run headless, upload results
```

## Architecture

**Keyword-driven layers with page objects as resource files.** Suites contain
only high-level, business-readable steps; each step maps to a user keyword; each
page is its own resource file that owns that page's locators and actions.
Variable files supply environment config and test data, keeping the `.robot`
suites free of hard-coded literals.

- **tests/** — readable suites and tags only.
- **resources/** — reusable keyword libraries (common + one file per page).
- **variables/** — variable files (`.py` / `.csv`) for URLs, browser,
  credentials and data-driven inputs.
- **results/** — generated `output.xml`, `report.html`, `log.html` and
  failure screenshots.

Practices baked in: explicit `Wait Until ...` keywords instead of `Sleep`;
stable `id` / `data-*` locators; tags (`smoke`, `regression`, `slow`) for
slicing runs; Test Templates for data-driven cases; and browser open/close in
`Test Setup` / `Test Teardown` (a fresh, isolated browser per test) so cleanup
always runs and each test starts from a clean, logged-out session — Sauce Demo
keeps its login state in the browser and is unreliable when re-signed-in
repeatedly in one session, so per-test isolation keeps the suites deterministic.

## Reporting

Every run writes three artifacts to `results/`:

- **`report.html`** — high-level pass/fail summary.
- **`log.html`** — step-by-step execution detail with keyword arguments;
  SeleniumLibrary embeds a **screenshot automatically on failure**.
- **`output.xml`** — the machine-readable source of truth both HTML files are
  generated from.

Use **`rebot`** to regenerate reports from an existing `output.xml`, or to merge
several `output.xml` files from parallel/re-run executions into one combined
report:

```bash
rebot --outputdir results results/output.xml
rebot --merge --outputdir results results/output-*.xml
```

`--outputdir results` keeps everything in `results/` so CI uploads the whole
folder as one downloadable bundle.

## Continuous integration

[`.github/workflows/robot.yml`](.github/workflows/robot.yml) runs on every
`push` and `pull_request`:

1. Checks out the repo and sets up **Python 3.11** with pip caching.
2. Installs with `pip install -r requirements.txt`.
3. Runs the suites headless — `robot --variable HEADLESS:true --outputdir results tests/`
   (Chrome is preinstalled on the runner; Selenium Manager resolves the driver).
4. Uploads `results/` (`report.html`, `log.html`, `output.xml`, screenshots)
   with `if: always()` so failing runs stay debuggable.

`BASE_URL`, `TEST_USER` and `TEST_PASSWORD` are read from repository secrets when
set, falling back to the public demo defaults — no secret is committed.

## Contributing

Contributions are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for setup, how
to run the suite, and how to add a test within the keyword-driven layering. A
[pull request template](.github/PULL_REQUEST_TEMPLATE.md) and weekly
[Dependabot](.github/dependabot.yml) updates keep changes consistent and current.

## License

[MIT](LICENSE) © qa.codes
