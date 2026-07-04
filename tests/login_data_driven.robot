*** Settings ***
Documentation     Data-driven login suite. DataDriver reads every row of
...               ``variables/login_data.csv`` and generates one test case per
...               row, all sharing the Test Template below — so each credential
...               set gets its own clearly-labelled pass/fail line in the report.
Library           DataDriver    file=../variables/login_data.csv
Resource          ../resources/common.robot
Resource          ../resources/pages/login_page.robot
Resource          ../resources/pages/inventory_page.robot
Variables         ../variables/environments.py

# Each row opens a fresh browser (Test Setup) and closes it (Test Teardown), so
# every credential set runs in a clean, isolated session — the most reliable
# isolation for a suite that exercises the login form many times in a row.
Test Setup        Open Test Browser
Test Teardown     Close Browser After Test

Test Template     Login Should Give Expected Result
Force Tags        login    regression    data-driven


*** Test Cases ***
Login as ${username} expecting ${expected}    Default    UserData


*** Keywords ***
Login Should Give Expected Result
    [Documentation]    Attempt a login and assert either a successful landing on
    ...    the inventory page (``expected == success``) or the exact error text.
    [Arguments]    ${username}    ${password}    ${expected}
    Login Page Should Be Open
    Login With Credentials    ${username}    ${password}
    IF    '${expected}' == 'success'
        Inventory Page Should Be Open
    ELSE
        Login Error Message Should Be    ${expected}
    END
