# Contributing

Thanks for helping improve this sample! It's a **reference project** — the
keyword-driven layering and Page-Object-as-resource-file structure are the
product — so contributions that keep suites high-level and readable, with all
mechanics pushed down into keywords, are especially welcome.

## Prerequisites

- **Python 3.9+** (CI runs on 3.11)
- Google Chrome installed locally (Selenium Manager resolves the matching driver)

## Setup

```bash
git clone https://github.com/qacodes-dev/qacodes-robot-framework-selenium.git
cd qacodes-robot-framework-selenium
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
cp .env.example .env               # then set BASE_URL / credentials if needed
```

## Run the suite

```bash
robot --dryrun tests/                                      # validate suites/imports, no browser
robot --outputdir results tests/                           # full suite
robot --outputdir results tests/login.robot                # single suite
robot --include smoke --outputdir results tests/           # by tag
robot --variable HEADLESS:true --outputdir results tests/  # headless (as CI runs)
rebot --outputdir results results/output.xml               # regenerate report/log from output.xml
```

Before opening a PR, make sure **both** are green:

```bash
robot --dryrun tests/
robot --variable HEADLESS:true --outputdir results tests/
```

## How to add a test

The project keeps every concern in exactly one layer. Adding coverage usually
touches a suite and (sometimes) a page resource — never a suite full of raw
locators.

1. **Need a new page or new element?** Add a resource file under
   `resources/pages/` (or a locator + keyword to the existing one). Each page
   resource **owns that page's locators and single-intent keywords** — no
   assertions of business intent, no test data. Prefer stable `id` / `data-*`
   locators and explicit `Wait Until ...` keywords, never `Sleep`.
2. **Need shared setup or reusable steps?** Put browser/session and other
   cross-suite keywords in `resources/common.robot` and import it.
3. **Need config or test data?** Resolve environment config from `os.environ`
   in `variables/environments.py`; add data-driven rows to
   `variables/login_data.csv` (DataDriver's semicolon-delimited format).
4. **Write the suite** in `tests/` as a `*.robot` file — one per feature or user
   journey. Suites contain **high-level, readable steps and tags only**: no raw
   selectors, no waits, no browser wiring.
5. **Tag the test** (`smoke` / `regression` / `slow`) so `--include` / `--exclude`
   and the CI gate can select it. For repetitive credential/data scenarios, use a
   **Test Template** over a CSV rather than copy-pasting cases.
6. **Keep tests independent.** Each test opens a fresh browser via `Test Setup`
   and closes it in `Test Teardown`, so cases stay order-agnostic and start from a
   clean, logged-out session.

## Commit & PR conventions

- Keep commits small and focused; write imperative subject lines
  (`Add cart removal test`, not `added tests`).
- Branch off `main`; open a PR against `main`. The
  [PR template](.github/PULL_REQUEST_TEMPLATE.md) prompts for what/why, type of
  change, and verification steps — fill it in.
- CI (headless Chrome) must be green on the PR before merge.
- Keep locators, URLs, and credentials out of the `.robot` suites — never commit
  real secrets.
