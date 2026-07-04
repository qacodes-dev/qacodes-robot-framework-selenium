*** Settings ***
Documentation     Shared keywords used across suites: opening/closing the browser
...               (with a screenshot on failure) and self-healing click helpers
...               that retry to absorb clicks headless Chrome occasionally drops.
Library           SeleniumLibrary
Variables         ../variables/environments.py


*** Keywords ***
Open Test Browser
    [Documentation]    Test Setup — open the configured browser at the application
    ...    root (the login screen). ``HEADLESS=true`` (used in CI) adds the flags a
    ...    headless runner needs. Selenium Manager resolves the driver automatically.
    ${options}=    Build Browser Options
    Open Browser    ${BASE_URL}    ${BROWSER}    options=${options}
    Set Selenium Timeout    ${TIMEOUT}

Build Browser Options
    [Documentation]    Assemble a SeleniumLibrary options string for Chrome. A fixed
    ...    window size keeps element visibility stable in headless runs.
    ${options}=    Set Variable    add_argument("--window-size=1920,1080")
    IF    '${HEADLESS}'.lower() == 'true'
        ${options}=    Catenate    SEPARATOR=;    ${options}
        ...    add_argument("--headless=new")
        ...    add_argument("--no-sandbox")
        ...    add_argument("--disable-dev-shm-usage")
        ...    add_argument("--disable-gpu")
    END
    RETURN    ${options}

Close Browser After Test
    [Documentation]    Test Teardown — capture a screenshot if the test failed
    ...    (SeleniumLibrary also auto-captures on keyword failure), then always
    ...    close the browser so cleanup runs even after a failure.
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Capture Page Screenshot
    Close All Browsers

Click And Confirm
    [Documentation]    Click an element (any locator) and confirm the expected
    ...    element appears, retrying until it does. Uses a scripted click on the
    ...    resolved element: native WebDriver clicks on Sauce Demo are intermittent
    ...    no-ops under headless CI (add-to-cart, cart link, and the React
    ...    Checkout / Continue / Finish buttons all drop clicks on slower runners).
    ...    A self-healing alternative to a hard sleep.
    [Arguments]    ${click_locator}    ${expected_locator}
    Wait Until Element Is Visible    ${click_locator}    timeout=${TIMEOUT}
    Wait Until Keyword Succeeds    5x    2s
    ...    Js Click And Wait For Element    ${click_locator}    ${expected_locator}

Js Click And Wait For Element
    [Arguments]    ${click_locator}    ${expected_locator}
    ${element}=    Get WebElement    ${click_locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    Wait Until Element Is Visible    ${expected_locator}    timeout=${TIMEOUT}
