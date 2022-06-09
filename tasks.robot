*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.HTTP
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Wait Until Keyword Succeeds    10x    0.1s    Preview the robot
        Wait Until Keyword Succeeds    10x    0.1s    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Close the annoying modal
    Wait Until Element Is Visible    xpath://div[@class='alert-buttons']/button[1]
    Click Button    OK

Fill the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath://input[@type='number']    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview the robot
    # ${is_robot_preview_image_visible}=    Is Element Visible    robot-preview-image
    # WHILE    ${is_robot_preview_image_visible} == ${FALSE}
    #    Click Button    preview
    #    ${is_robot_preview_image_visible}=    Is Element Visible    robot-preview-image
    # END
    Click Button    preview
    Wait Until Element Is Visible    robot-preview-image
    Wait Until Element Is Visible    //img[@alt='Head']
    Wait Until Element Is Visible    //img[@alt='Body']
    Wait Until Element Is Visible    //img[@alt='Legs']

Submit the order
    # ${is_robot_order_receipt_visible}=    Is Element Visible    receipt
    # WHILE    ${is_robot_order_receipt_visible} == ${FALSE}
    #    Click Button    order
    #    ${is_robot_order_receipt_visible}=    Is Element Visible    receipt
    # END
    Click Button    order
    Wait Until Element Is Visible    receipt

Store the receipt as a PDF file
    [Arguments]    ${orderNumber}
    ${robot_order_receipt_html}=    Get Element Attribute    receipt    outerHTML
    ${robot_order_receipt_pdf_path_name}=    Set Variable
    ...    ${OUTPUT_DIR}${/}receipts${/}robot_order_receipt_${orderNumber}.pdf

    Html To Pdf    ${robot_order_receipt_html}    ${robot_order_receipt_pdf_path_name}

    RETURN    ${robot_order_receipt_pdf_path_name}

Take a screenshot of the robot
    [Arguments]    ${orderNumber}
    ${roboo_image_path_name}=    Set Variable    ${OUTPUT_DIR}${/}images${/}robot_${orderNumber}.png
    Capture Element Screenshot    robot-preview-image    ${roboo_image_path_name}

    RETURN    ${roboo_image_path_name}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Add Watermark Image To Pdf    image_path=${screenshot}    source_path=${pdf}    output_path=${pdf}

Go to order another robot
    Click Button    order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.zip

# Export robot order receipt as a PDF
#    [Arguments]    ${order}
#    Wait Until Element Is Visible    id:receipt
#    ${robot_order_receipt}=    Get Element Attribute    id:receipt    outerHTML
#    Html To Pdf    ${robot_order_receipt}    ${OUTPUT_DIR}${/}receipts${/}receipt_${order}[Order number].pdf

# Add robot screenshot into PDF
#    [Arguments]    ${order}
#    Wait Until Element Is Visible    id:robot-preview-image
#    Wait Until Element Is Visible    //img[@alt='Head']
#    Wait Until Element Is Visible    //img[@alt='Body']
#    Wait Until Element Is Visible    //img[@alt='Legs']
#    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot_${order}[Order number].png
#    Add Watermark Image To Pdf
#    ...    image_path=${OUTPUT_DIR}${/}robot_${order}[Order number].png
#    ...    source_path=${OUTPUT_DIR}${/}receipts${/}receipt_${order}[Order number].pdf
#    ...    output_path=${OUTPUT_DIR}${/}receipts${/}receipt_${order}[Order number].pdf

# Fill the robot order from file
#    ${orders}=    Read table from CSV    orders.csv
#    FOR    ${order}    IN    @{orders}
#    Fill and submit the form for one robot order    ${order}
#    Export robot order receipt as a PDF    ${order}
#    Add robot screenshot into PDF    ${order}
#    Click Button    order-another
#    END
