*** Settings ***
Documentation     End-to-end checkout journey — log in, add products to the
...               cart and complete the Sauce Demo checkout flow.
Resource          ../resources/common.robot
Resource          ../resources/pages/login_page.robot
Resource          ../resources/pages/inventory_page.robot
Resource          ../resources/pages/checkout_page.robot
Variables         ../variables/environments.py

# Each test opens a fresh browser (Test Setup) and closes it (Test Teardown).
# Sauce Demo keeps a logged-in session in the browser, and re-logging into the
# store repeatedly in one session is unreliable, so a clean browser per test is
# the robust isolation for journeys that each sign in and mutate the cart.
Test Setup        Open Test Browser
Test Teardown     Close Browser After Test

Force Tags        checkout


*** Test Cases ***
Add To Cart Updates The Cart Badge
    [Documentation]    Adding two products bumps the cart badge to 2.
    [Tags]    smoke    regression
    Login Page Should Be Open
    Login With Credentials    ${TEST_USER}    ${TEST_PASSWORD}
    Inventory Page Should Be Open
    Add Product To Cart    sauce-labs-backpack
    Add Product To Cart    sauce-labs-bike-light
    Cart Badge Should Show    2

Complete Checkout Journey
    [Documentation]    Add a product and drive the full checkout to completion.
    [Tags]    regression    slow
    Login Page Should Be Open
    Login With Credentials    ${TEST_USER}    ${TEST_PASSWORD}
    Inventory Page Should Be Open
    Add Product To Cart    sauce-labs-backpack
    Cart Badge Should Show    1
    Open Cart
    Cart Should Contain Items    1
    Start Checkout
    Fill Customer Information    Ada    Lovelace    2QT
    Finish Checkout
    Order Should Be Complete
