*** Settings ***
Documentation     Login suite — valid login, invalid credentials and a
...               locked-out user, against the Sauce Demo storefront.
Resource          ../resources/common.robot
Resource          ../resources/pages/login_page.robot
Resource          ../resources/pages/inventory_page.robot
Variables         ../variables/environments.py

# A fresh browser per test (Test Setup / Test Teardown) gives every case a clean,
# logged-out session. Sauce Demo keeps the login state in the browser and is
# unreliable when re-signed-in repeatedly in one session, so per-test isolation
# keeps the suite deterministic — and the teardown still always runs on failure.
Test Setup        Open Test Browser
Test Teardown     Close Browser After Test

Force Tags        login


*** Test Cases ***
Valid User Can Log In
    [Documentation]    A standard user reaches the product inventory.
    [Tags]    smoke    regression
    Login Page Should Be Open
    Login With Credentials    ${TEST_USER}    ${TEST_PASSWORD}
    Inventory Page Should Be Open

Invalid Credentials Are Rejected
    [Documentation]    A wrong password shows the mismatch error.
    [Tags]    regression
    Login Page Should Be Open
    Login With Credentials    ${TEST_USER}    definitely_wrong
    Login Error Message Should Be
    ...    Epic sadface: Username and password do not match any user in this service

Locked Out User Is Blocked
    [Documentation]    The locked-out demo account cannot sign in.
    [Tags]    regression
    Login Page Should Be Open
    Login With Credentials    locked_out_user    ${TEST_PASSWORD}
    Login Error Message Should Be
    ...    Epic sadface: Sorry, this user has been locked out.
