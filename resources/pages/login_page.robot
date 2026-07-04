*** Settings ***
Documentation     Login page object — owns the locators and keywords for the
...               Sauce Demo sign-in screen. No other file references these
...               locators directly; suites talk to the page through keywords.
Library           SeleniumLibrary
Variables         ../../variables/environments.py


*** Variables ***
# --- Locators (prefer stable ids over brittle CSS/XPath) ---
${LOGIN_USERNAME_INPUT}     id:user-name
${LOGIN_PASSWORD_INPUT}     id:password
${LOGIN_BUTTON}             id:login-button
${LOGIN_ERROR_MESSAGE}      css:[data-test="error"]


*** Keywords ***
Login Page Should Be Open
    Wait Until Element Is Visible    ${LOGIN_USERNAME_INPUT}    timeout=${TIMEOUT}
    Wait Until Element Is Visible    ${LOGIN_BUTTON}    timeout=${TIMEOUT}

Input Username
    [Arguments]    ${username}
    Input Text    ${LOGIN_USERNAME_INPUT}    ${username}

Input Password
    [Arguments]    ${password}
    # SeleniumLibrary's own ``Input Password`` keeps the secret out of the log.
    SeleniumLibrary.Input Password    ${LOGIN_PASSWORD_INPUT}    ${password}

Submit Login
    Click Button    ${LOGIN_BUTTON}

Login With Credentials
    [Documentation]    High-level page action: fill the form and submit.
    [Arguments]    ${username}    ${password}
    Input Username    ${username}
    Input Password    ${password}
    Submit Login

Login Error Message Should Be
    [Arguments]    ${expected}
    Wait Until Element Is Visible    ${LOGIN_ERROR_MESSAGE}    timeout=${TIMEOUT}
    Element Text Should Be    ${LOGIN_ERROR_MESSAGE}    ${expected}
