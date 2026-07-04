*** Settings ***
Documentation     Inventory (products) page object — owns the product list,
...               add-to-cart actions and the cart badge for Sauce Demo.
Library           SeleniumLibrary
Resource          ../common.robot
Variables         ../../variables/environments.py


*** Variables ***
# --- Locators ---
${INVENTORY_CONTAINER}      id:inventory_container
${INVENTORY_TITLE}          css:.title
${CART_BADGE}               css:.shopping_cart_badge
${CART_LINK}                css:.shopping_cart_link
${CART_CHECKOUT_BUTTON}     id:checkout

# Add-to-cart buttons expose a stable data-test attribute keyed by product slug,
# e.g. data-test="add-to-cart-sauce-labs-backpack".


*** Keywords ***
Inventory Page Should Be Open
    [Documentation]    Assert the product grid rendered after a successful login.
    Wait Until Element Is Visible    ${INVENTORY_CONTAINER}    timeout=${TIMEOUT}
    Element Text Should Be    ${INVENTORY_TITLE}    Products

Add Product To Cart
    [Documentation]    Add a product by its Sauce Demo slug, e.g. ``sauce-labs-backpack``.
    ...    Confirms the add by waiting for the button to flip to "Remove".
    [Arguments]    ${product_slug}
    ${add}=    Set Variable    css:[data-test="add-to-cart-${product_slug}"]
    ${remove}=    Set Variable    css:[data-test="remove-${product_slug}"]
    Click And Confirm    ${add}    ${remove}

Cart Badge Should Show
    [Arguments]    ${count}
    Wait Until Element Is Visible    ${CART_BADGE}    timeout=${TIMEOUT}
    Element Text Should Be    ${CART_BADGE}    ${count}

Open Cart
    [Documentation]    Open the cart and confirm the cart page loaded.
    Click And Confirm    ${CART_LINK}    ${CART_CHECKOUT_BUTTON}
