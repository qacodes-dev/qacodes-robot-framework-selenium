*** Settings ***
Documentation     Checkout page object — owns the cart, customer-information
...               and order-overview steps of the Sauce Demo checkout flow.
Library           SeleniumLibrary
Resource          ../common.robot
Variables         ../../variables/environments.py


*** Variables ***
# --- Cart page ---
${CART_ITEM}                css:.cart_item
${CHECKOUT_BUTTON}          id:checkout

# --- Customer information (step one) ---
${FIRST_NAME_INPUT}         id:first-name
${LAST_NAME_INPUT}          id:last-name
${POSTAL_CODE_INPUT}        id:postal-code
${CONTINUE_BUTTON}          id:continue

# --- Order overview (step two) & completion ---
${FINISH_BUTTON}            id:finish
${COMPLETE_HEADER}          css:.complete-header


*** Keywords ***
Cart Should Contain Items
    [Arguments]    ${count}
    Wait Until Element Is Visible    ${CART_ITEM}    timeout=${TIMEOUT}
    Page Should Contain Element    ${CART_ITEM}    limit=${count}

Start Checkout
    [Documentation]    Begin checkout and confirm the customer-information step loads.
    Click And Confirm    ${CHECKOUT_BUTTON}    ${FIRST_NAME_INPUT}

Fill Customer Information
    [Documentation]    Fill the customer form and advance to the order overview.
    ...    On a slow runner Sauce Demo's React inputs can drop values typed before
    ...    the page has settled, so the fill + submit is one retried unit: it
    ...    refills and re-submits until the Finish button (order overview) appears.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}    timeout=${TIMEOUT}
    Wait Until Keyword Succeeds    5x    2s
    ...    Submit Customer Information    ${first_name}    ${last_name}    ${postal_code}

Submit Customer Information
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Enter Text Reliably    ${FIRST_NAME_INPUT}    ${first_name}
    Enter Text Reliably    ${LAST_NAME_INPUT}    ${last_name}
    Enter Text Reliably    ${POSTAL_CODE_INPUT}    ${postal_code}
    ${continue}=    Get WebElement    ${CONTINUE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${continue}
    Wait Until Element Is Visible    ${FINISH_BUTTON}    timeout=${TIMEOUT}

Finish Checkout
    [Documentation]    Submit the order and confirm the order-complete page loads.
    Click And Confirm    ${FINISH_BUTTON}    ${COMPLETE_HEADER}

Order Should Be Complete
    Element Text Should Be    ${COMPLETE_HEADER}    Thank you for your order!
