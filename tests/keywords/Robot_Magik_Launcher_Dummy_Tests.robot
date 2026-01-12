*** Settings ***
Documentation     test start stop gis sesson using dummy gis
...
...               == Licence info ==
...               | Copyright 2016-     Luiko Czub, Smallcases Software GmbH
...               |
...               | Licensed under the Apache License, Version 2.0 (the "License");
...               | you may not use this file except in compliance with the License.
...               | You may obtain a copy of the License at
...               |
...               | http://www.apache.org/licenses/LICENSE-2.0
...               |
...               | Unless required by applicable law or agreed to in writing, software
...               | distributed under the License is distributed on an "AS IS" BASIS,
...               | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
...               | See the License for the specific language governing permissions and
...               | limitations under the License.
Force Tags        dummyLaunch
Library           Process
Library           ../../resources/RobotMagikLauncher.py    cli_port=${DUMMY_CLI_PORT}    wait=10s
Library           OperatingSystem

*** Variables ***
${DUMMY_LAUNCHER}    ${CURDIR}${/}..${/}scripts${/}dummy_gis_launcher.py
${DUMMY_CLI_PORT}    ${14011}
${DUMMY_ENVFILE}    ${CURDIR}${/}dummy_envfile.bat
${DUMMY_JRE}      ${CURDIR}${/}jre_dummy

*** Test Cases ***
start magik session - no swproduct
    [Documentation]    start magik session fails, cause required SWPRODUCT information is missing.
    Run Keyword And Expect Error    swproduct is not defined - *    Start Magik Session    gis_alias=A_ALIAS    test_launch=haha

start magik session - no gis_alias
    [Documentation]    start magik session fails, cause required GIS_ALIAS information is missing.
    Run Keyword And Expect Error    gis_alias is not defined - *    Start Magik Session    A_SWPRODUCT_PATH    test_launch=haha

start magik session
    [Documentation]    start magik session returns a session object with process informations
    [Tags]    noTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    A_GIS_ALIAS    test_launch=${DUMMY_LAUNCHER}
    ${pid}=    Get Process Id    ${msession.process_handle}
    Should Be Equal As Integers    ${msession.process_id}    ${pid}
    [Teardown]    Stop Magik Session

start magik session - cli_port already in use
    [Documentation]    Starting a second session for an alrready in used cli_port fails
    [Tags]    noTelnet
    ${DUMMY_CLI_port2}=    Set Variable    ${DUMMY_CLI_PORT+1}
    Start Magik Session    A_SWPRODUCT_PATH    A_GIS_ALIAS    cli_port=${DUMMY_CLI_port2}    test_launch=${DUMMY_LAUNCHER}
    Run Keyword And Expect Error    Port ${DUMMY_CLI_port2} is already in use by another session!    Start Magik Session    A_SWPRODUCT_PATH    A_GIS_ALIAS    cli_port=${DUMMY_CLI_port2}    test_launch=${DUMMY_LAUNCHER}
    [Teardown]    Stop Magik Session

start and stop dummy magik session
    [Documentation]    start magik session with a telent connection, check if the telent connection works and stop the session
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Contain    ${result.stdout}    session started with -l - LOGFILE is
    [Teardown]    Stop All Magik Sessions

get session object - no active session
    [Documentation]    get session object should fail, cause no session is started
    Run Keyword And Expect Error    No active session!    Get Session Object
    Run Keyword And Expect Error    No registered ${DUMMY_CLI_PORT} session!    Get Session Object    ${DUMMY_CLI_PORT}

get session object
    [Documentation]    get a session object returns the current active session or a session, registered for a specific cli_port
    [Tags]    noTelnet
    ${DUMMY_CLI_port1}=    Set Variable    ${DUMMY_CLI_PORT}
    ${DUMMY_CLI_port2}=    Set Variable    ${DUMMY_CLI_PORT+1}
    ${msession1}=    Start Magik Session    A_SWPRODUCT_PATH    A_GIS_ALIAS    cli_port=${DUMMY_CLI_port1}    test_launch=${DUMMY_LAUNCHER}
    ${msession}=    Get Session Object
    Should Be Equal    ${msession}    ${msession1}
    ${msession2}=    Start Magik Session    A_SWPRODUCT_PATH    A_GIS_ALIAS    cli_port=${DUMMY_CLI_port2}    test_launch=${DUMMY_LAUNCHER}
    ${msession}=    Get Session Object
    Should Be Equal    ${msession}    ${msession2}
    ${msession}=    Get Session Object    ${DUMMY_CLI_port1}
    Should Be Equal    ${msession}    ${msession1}
    [Teardown]    Stop All Magik Sessions

switch magik session
    [Documentation]    the active session can be switch between registered session for special cli_ports
    [Tags]    noTelnet
    ${DUMMY_CLI_port1}=    Set Variable    ${DUMMY_CLI_PORT}
    ${DUMMY_CLI_port2}=    Set Variable    ${DUMMY_CLI_PORT+1}
    ${msession1}=    Start Magik Session    A_SWPRODUCT_PATH    A_GIS_ALIAS    cli_port=${DUMMY_CLI_port1}    test_launch=${DUMMY_LAUNCHER}
    ${msession2}=    Start Magik Session    A_SWPRODUCT_PATH    A_GIS_ALIAS    cli_port=${DUMMY_CLI_port2}    test_launch=${DUMMY_LAUNCHER}
    ${msession}=    Get Session Object
    Should Be Equal    ${msession}    ${msession2}
    ${msession}=    Switch Magik Session    ${DUMMY_CLI_port1}
    Should Be Equal    ${msession}    ${msession1}
    ${msession}=    Get Session Object
    Should Be Equal    ${msession}    ${msession1}
    [Teardown]    Stop All Magik Sessions

switch magik session - unknown session
    [Documentation]    switch a magik session fails, when the the cli_port is not registeredd
    [Tags]    noTelnet
    ${DUMMY_CLI_port1}=    Set Variable    ${DUMMY_CLI_PORT}
    ${DUMMY_CLI_port2}=    Set Variable    ${DUMMY_CLI_PORT+1}
    ${msession1}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_unknown_session    cli_port=${DUMMY_CLI_port1}    test_launch=${DUMMY_LAUNCHER}
    ${msession}=    Get Session Object
    Should Be Equal    ${msession}    ${msession1}
    Run Keyword And Expect Error    No registered ${DUMMY_CLI_port2} session!    Switch Magik Session    ${DUMMY_CLI_port2}
    ${msession}=    Get Session Object
    Should Be Equal    ${msession}    ${msession1}
    [Teardown]    Stop All Magik Sessions

session should be reachable - no telnet connection
    [Documentation]    checking the telnet connection fails, when no session is active or the required cli_port is not registered for a session
    [Tags]    noTelnet
    ${wait}=    Set Variable    ${0.2}
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_no_telnet    cli_port=${DUMMY_CLI_PORT}    wait=${wait}    test_launch=${DUMMY_LAUNCHER}
    Run Keyword And Expect Error    Image is NOT reachable via telnet localhost:${DUMMY_CLI_PORT} waiting ${wait}s    Session Should Be Reachable
    Run Keyword And Expect Error    Image is NOT reachable via telnet localhost:${DUMMY_CLI_PORT} waiting ${wait}s    Session Should Be Reachable    ${DUMMY_CLI_PORT}
    Run Keyword And Expect Error    No registered ${DUMMY_CLI_PORT+11} session!    Session Should Be Reachable    ${DUMMY_CLI_PORT+11}
    Stop Magik Session
    Run Keyword And Expect Error    No active session!    Session Should Be Reachable
    [Teardown]    Stop All Magik Sessions

session should be reachable - open telnet connection
    [Documentation]    checking the telnet connection works with the current active session or a session, registerd for a specific cli_port
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    cli_port=${DUMMY_CLI_PORT+1}    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    Session Should Be Reachable    ${DUMMY_CLI_PORT+1}
    [Teardown]    Stop Magik Session

start session with special environment
    [Documentation]    starting a session with a special environment file should set the environment varibale SW_GIS_ENVIRONMENT_FILE
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_envfile_start_telnet    envfile=${DUMMY_ENVFILE}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Contain    ${result.stdout}    SW_GIS_ENVIRONMENT_FILE=${DUMMY_ENVFILE}
    [Teardown]    Stop All Magik Sessions

start session with special java
    [Documentation]    starting a session with a special jre / jdk should set the environment variable JAVA_HOME
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_special_java_start_telnet    java_home=${DUMMY_JRE}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Contain    ${result.stdout}    JAVA_HOME=${DUMMY_JRE}
    [Teardown]    Stop All Magik Sessions

start session with different java
    [Documentation]    starting a session with a jre different from current JAVA_HOME
    [Tags]    withTelnet
    Set Environment Variable    JAVA_HOME    NOT_WANTED_JRE
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_different_java_start_telnet    java_home=${DUMMY_JRE}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Contain    ${result.stdout}    JAVA_HOME=${DUMMY_JRE}
    [Teardown]    Stop All Magik Sessions

start session with default java
    [Documentation]    starting a session using the system JAVA_HOME
    [Tags]    withTelnet
    Set Environment Variable    JAVA_HOME    SYSTEM_JRE
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_default_java_start_telnet    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Contain    ${result.stdout}    JAVA_HOME=SYSTEM_JRE
    [Teardown]    Stop All Magik Sessions

start session with nested alias
    [Documentation]    starting a session with a argument *nested_alias* - no log file should be written to avoid gus launcher problems
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_nested_start_telnet    nested_alias=${True}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Contain    ${result.stdout}    session started without -l - NO LOGFILE
    [Teardown]    Stop All Magik Sessions

start session with additional gis args -cli
    [Documentation]    starting a session with one additional gis arg *-cli*
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_gisarg1_start_telnet    cli_port=${DUMMY_CLI_PORT}    gis_args=-cli    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Match    ${result.stdout}    *dummy_gis : start args= * -cli*
    [Teardown]    Stop All Magik Sessions

start session with additional gis args multiple
    [Documentation]    starting a session with two additional gis arg *-cli* and *-login user/pw*
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_gisarg2_start_telnet    cli_port=${DUMMY_CLI_PORT}    gis_args=-cli -login root/huhu    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${result}=    Stop Magik Session
    Should Match    ${result.stdout}    *dummy_gis : start args= * -cli -login root/huhu*
    [Teardown]    Stop All Magik Sessions
