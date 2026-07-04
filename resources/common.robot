*** Settings ***
Documentation     Shared keywords used across suites: opening/closing the browser
...               (with a screenshot on failure) and self-healing click helpers
...               that retry to absorb clicks headless Chrome occasionally drops.
Library           SeleniumLibrary
Library           String
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

Click Until Visible
    [Documentation]    Click an element and confirm the expected element appears,
    ...    retrying the click to absorb the occasional click headless Chrome drops
    ...    before a page has settled. A self-healing alternative to a hard sleep.
    [Arguments]    ${click_locator}    ${expected_locator}
    Wait Until Element Is Visible    ${click_locator}    timeout=${TIMEOUT}
    Wait Until Keyword Succeeds    4x    2s
    ...    Click Then Wait For Element    ${click_locator}    ${expected_locator}

Click Then Wait For Element
    [Arguments]    ${click_locator}    ${expected_locator}
    Run Keyword And Ignore Error    Click Element    ${click_locator}
    Wait Until Element Is Visible    ${expected_locator}    timeout=${TIMEOUT}

Submit By Id And Wait
    [Documentation]    Click an ``id:``-located element via a scripted click,
    ...    retrying until the expected element appears. Sauce Demo's checkout
    ...    navigation buttons (Checkout / Continue / Finish) are occasionally a
    ...    no-op under a headless WebDriver click, so a scripted click is the
    ...    reliable path. Takes the same ``id:...`` locator the page object owns.
    [Arguments]    ${id_locator}    ${expected_locator}
    ${element_id}=    Remove String    ${id_locator}    id:
    Wait Until Element Is Visible    ${id_locator}    timeout=${TIMEOUT}
    Wait Until Keyword Succeeds    4x    2s
    ...    Js Click Then Wait For Element    ${element_id}    ${expected_locator}

Js Click Then Wait For Element
    [Arguments]    ${element_id}    ${expected_locator}
    Execute Javascript    var b = document.getElementById(arguments[0]); if (b) { b.click(); }
    ...    ARGUMENTS    ${element_id}
    Wait Until Element Is Visible    ${expected_locator}    timeout=${TIMEOUT}
