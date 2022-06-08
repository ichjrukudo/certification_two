*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.HTTP


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download the Csv file


*** Keywords ***
Download the Csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
