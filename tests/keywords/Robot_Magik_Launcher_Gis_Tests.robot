*** Settings ***
Documentation     minimal test workflow - start session, calculate something , close the session
Force Tags        gisLaunch
Library           Process
Variables         ../../resources/params/variables_sw43_cbg.py
Library           ../../resources/RobotMagikLauncher.py    swproduct=${SWPRODUCT}    cli_port=${CLI_PORT}    wait=${START_WAIT}
Resource          ../../resources/robot_magik_base.robot

*** Variables ***

*** Test Cases ***
start magik session
    [Documentation]    start magik session, prepare telnet connection and check that the telnet connection
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    aliasfile=${ALIASFILE}    gis_alias=${ALIASNAME}    msf_startup=${MSFSTARTUP}    login=${LOGIN}
    Session Should Be Reachable
    #    Stop Magik Session

calc with magik session
    [Documentation]    calculate something with the magik session with a telent connection, check if the telent connection works and stop the session
    [Tags]    withTelnet
    ${out}=    Open Magik Connection
    ${out}=    Execute Magik Command    3 - 2
    Should Be Equal As Integers    ${out}    1
    ${out}=    Close Magik Connection

stop magik session
    [Documentation]    stop the magik session
    [Tags]    withTelnet
    Stop Magik Session
