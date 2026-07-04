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
    Submit By Id And Wait    ${CHECKOUT_BUTTON}    ${FIRST_NAME_INPUT}

Fill Customer Information
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}    timeout=${TIMEOUT}
    Input Text    ${FIRST_NAME_INPUT}    ${first_name}
    Input Text    ${LAST_NAME_INPUT}    ${last_name}
    Input Text    ${POSTAL_CODE_INPUT}    ${postal_code}
    # Confirm we advanced to the order overview (the Finish button appears).
    Submit By Id And Wait    ${CONTINUE_BUTTON}    ${FINISH_BUTTON}

Finish Checkout
    [Documentation]    Submit the order and confirm the order-complete page loads.
    Submit By Id And Wait    ${FINISH_BUTTON}    ${COMPLETE_HEADER}

Order Should Be Complete
    Element Text Should Be    ${COMPLETE_HEADER}    Thank you for your order!
