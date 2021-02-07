*** Settings ***
Documentation     === Robot Framework Magik keywords wrapping RobotMagikLauncher ===
...
...               Wrapper starting and stopping Magik images (SW GIS 4.x) and sessions (SW GIS 5.x) calling[./RobotMagikLauncher.html|RobotMagikLauncher] keywords depended on robot variables \ `AUTO_START_MAGIK_SESSION` and `AUTO_STOP_MAGIK_SESSION` .
...
...               Helpful for \ debugging / testing when robot tests should run against an already manuall started Magik session or not to close the Magik session after test runs for further analysis.
Library           RobotMagikLauncher.py

*** Variables ***
${AUTO_START_MAGIK_SESSION}    ${TRUE}    # Set to False, when Test Run should not start an own Magik Session
${AUTO_STOP_MAGIK_SESSION}    ${AUTO_START_MAGIK_SESSION}    # Set to False, when Magik Session should not be closed after Test Run

*** Keywords ***
Auto Start Magik Session
    [Arguments]    @{args}    &{further_key_value_pairs}
    [Documentation]    Wrapper calling RobotMagikLauncher keywords [./RobotMagikLauncher.html#Start%20Magik%20Session| Start Magik Session] plus [./RobotMagikLauncher.html#Session%20Should%20Be%20Reachable| Session Should Be Reachable]
    ...
    ...    Possible arguments / key value pairs see [./RobotMagikLauncher.html#Start%20Magik%20Session| Start Magik Session]
    ...
    ...    Returns launcher session object handling the started session process
    Run Keyword And Return If    ${AUTO_START_MAGIK_SESSION} == ${False}    Log To Console    Starting Magik Session was disabled by AUTO_START_MAGIK_SESSION
    ${msession}=    Start Magik Session    @{args}    &{further_key_value_pairs}
    Session Should Be Reachable    ${msession.cli_port}
    [Return]    ${msession}

Auto Stop Magik Session
    [Arguments]    ${cli_port}=${None}    ${kill}=${True}
    [Documentation]    Wrapper calling RobotMagikLauncher keyword [./RobotMagikLauncher.html#Stop%20Magik%20Session| Stop Magik Session]
    ...
    ...    Arguments see [./RobotMagikLauncher.html#Stop%20Magik%20Session| Stop Magik Session]
    ...
    ...    Returns [http://robotframework.org/robotframework/latest/libraries/Process.html#Result%20object|Process result object]
    Run Keyword And Return If    ${AUTO_STOP_MAGIK_SESSION} == ${False}    Log To Console    Stopping Magik Session was disabled by AUTO_STOP_MAGIK_SESSION
    ${result}=    Stop Magik Session    ${cli_port}    ${kill}
    [Return]    ${result}
