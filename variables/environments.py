"""Python variable file — resolves environment configuration from ``os.environ``.

Robot Framework imports this module via ``Variables    environments.py`` and
exposes every module-level UPPER_CASE name as a suite variable (``${BASE_URL}``,
``${BROWSER}`` ...). Because everything is read from the environment, the same
suites run against any environment without edits, and command-line
``--variable`` values still override these by design.

The defaults below are the *public* Sauce Demo values (the demo prints its own
credentials on the login page), so a fresh clone is runnable out of the box.
For real applications, supply ``TEST_USER`` / ``TEST_PASSWORD`` through a
gitignored ``.env`` locally or GitHub Actions secrets in CI — never commit them.
"""

import os

# --- Per-environment configuration blocks ----------------------------------
# ``ENV`` selects which block supplies defaults; individual environment
# variables still win over the block so CI can point the same suites anywhere.
_ENVIRONMENTS = {
    "production": {"BASE_URL": "https://www.saucedemo.com"},
    "staging": {"BASE_URL": "https://www.saucedemo.com"},
}

ENV = os.environ.get("ENV", "production")
_config = _ENVIRONMENTS.get(ENV, _ENVIRONMENTS["production"])

# --- Resolved suite variables ----------------------------------------------
BASE_URL = os.environ.get("BASE_URL", _config["BASE_URL"])
BROWSER = os.environ.get("BROWSER", "chrome")
HEADLESS = os.environ.get("HEADLESS", "false")

# Public demo credentials — override via .env / CI secrets for real systems.
TEST_USER = os.environ.get("TEST_USER", "standard_user")
TEST_PASSWORD = os.environ.get("TEST_PASSWORD", "secret_sauce")

# Default explicit-wait budget used by the ``Wait Until ...`` keywords.
TIMEOUT = os.environ.get("TIMEOUT", "10s")
