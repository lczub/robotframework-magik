*** Settings ***
Documentation     cli_port=${DUMMY_CLI_PORT} | wait=0.1s
...
...               == Licence info ==
...               | Copyright 2021-2025 Luiko Czub, Smallcases Software GmbH
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
Library           OperatingSystem
Resource          ../../resources/robot_magik_session.robot

*** Variables ***
${DUMMY_LAUNCHER}    ${CURDIR}${/}..${/}scripts${/}dummy_gis_launcher.py
${DUMMY_CLI_PORT}    ${14012}
${DUMMY_ENVFILE}    ${CURDIR}${/}dummy_envfile.bat
${DUMMY_JRE}      ${CURDIR}${/}jre_dummy
${DUMMY_WAIT}     2s

*** Test Cases ***
auto start magik session - no swproduct
    [Documentation]    auto auto start magik session fails, cause required SWPRODUCT information is missing.
    Run Keyword And Expect Error    swproduct is not defined - *    Auto Start Magik Session    gis_alias=A_ALIAS    test_launch=haha

auto start magik session - no gis_alias
    [Documentation]    auto start magik session fails, cause required GIS_ALIAS information is missing.
    Run Keyword And Expect Error    gis_alias is not defined - *    Auto Start Magik Session    A_SWPRODUCT_PATH    test_launch=haha

auto start magik session
    [Documentation]    auto start magik session returns a session object with process informations
    [Tags]    noTelnet
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    ${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    ${pid}=    Get Process Id    ${msession.process_handle}
    Should Be Equal As Integers    ${msession.process_id}    ${pid}
    Session Should Be Reachable    ${DUMMY_CLI_PORT}
    [Teardown]    Stop Magik Session

auto start magik session - disabled start
    [Documentation]    auto start magik session returns a session object with process informations
    [Tags]    noTelnet
    Set Test Variable    ${AUTO_START_MAGIK_SESSION}    ${False}
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    ${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}
    Should Be Equal    ${msession}    ${None}
    Run Keyword And Expect Error    No registered ${DUMMY_CLI_PORT} session!    Session Should Be Reachable    ${DUMMY_CLI_PORT}
    [Teardown]    Stop All Magik Sessions

auto start magik session - cli_port already in use
    [Documentation]    Starting a second session for an alrready in used cli_port fails
    [Tags]    noTelnet
    ${DUMMY_CLI_port2}=    Set Variable    ${DUMMY_CLI_PORT+1}
    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    cli_port=${DUMMY_CLI_port2}    test_launch=${DUMMY_LAUNCHER}
    Run Keyword And Expect Error    Port ${DUMMY_CLI_port2} is already in use by another session!    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    ${DUMMY_CLI_port2}    test_launch=${DUMMY_LAUNCHER}
    [Teardown]    Stop Magik Session

auto start and stop dummy magik session
    [Documentation]    auto start magik session with a telnet connection, check if the telent connection works and stop the session
    [Tags]    withTelnet
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    Session Should Be Reachable
    ${result}=    Auto Stop Magik Session
    Should Contain    ${result.stdout}    session started with -l - LOGFILE is
    [Teardown]    Stop All Magik Sessions

auto start and stop dummy magik session - disabled start and stop
    [Documentation]    call start stop magik session keywords with disabled start and stop
    ...    - check telnet connection is not opened
    [Tags]    withTelnet
    Set Test Variable    ${AUTO_START_MAGIK_SESSION}    ${False}
    Set Test Variable    ${AUTO_STOP_MAGIK_SESSION}    ${False}
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    ${result}=    Auto Stop Magik Session
    Run Keyword And Expect Error    No registered ${DUMMY_CLI_PORT} session!    Session Should Be Reachable    ${DUMMY_CLI_PORT}
    ${result}=    Auto Stop Magik Session
    Should Be Equal    ${result}    ${None}
    [Teardown]    Stop All Magik Sessions

auto start and stop dummy magik session - disabled stop
    [Documentation]    call start stop magik session keywords with enabled start and disabled stop
    ...    - check telnet connection is \ open and still works after calling auto stop
    [Tags]    withTelnet
    Set Test Variable    ${AUTO_START_MAGIK_SESSION}    ${True}
    Set Test Variable    ${AUTO_STOP_MAGIK_SESSION}    ${False}
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_start_telnet    cli_port=${DUMMY_CLI_PORT+2}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    Session Should Be Reachable    ${DUMMY_CLI_PORT+2}
    ${result}=    Auto Stop Magik Session
    Should Be Equal    ${result}    ${None}
    Session Should Be Reachable    ${DUMMY_CLI_PORT+2}
    [Teardown]    Stop All Magik Sessions

auto start session with special environment
    [Documentation]    auto starting a session with a special environment file should set the environment varibale SW_GIS_ENVIRONMENT_FILE
    [Tags]    withTelnet
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_envfile_start_telnet    envfile=${DUMMY_ENVFILE}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    Session Should Be Reachable
    ${result}=    Auto Stop Magik Session
    Should Contain    ${result.stdout}    SW_GIS_ENVIRONMENT_FILE=${DUMMY_ENVFILE}
    [Teardown]    Stop All Magik Sessions

auto start session with special java
    [Documentation]    auto starting a session with a special jre / jdk should set the environment variable JAVA_HOME
    [Tags]    withTelnet
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_special_java_start_telnet    java_home=${DUMMY_JRE}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    Session Should Be Reachable
    ${result}=    Auto Stop Magik Session
    Should Contain    ${result.stdout}    JAVA_HOME=${DUMMY_JRE}
    [Teardown]    Stop All Magik Sessions

auto start session with different java
    [Documentation]    auto starting a session with a jre different from current JAVA_HOME
    [Tags]    withTelnet
    Set Environment Variable    JAVA_HOME    NOT_WANTED_JRE
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_different_java_start_telnet    java_home=${DUMMY_JRE}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    Session Should Be Reachable
    ${result}=    Auto Stop Magik Session
    Should Contain    ${result.stdout}    JAVA_HOME=${DUMMY_JRE}
    [Teardown]    Stop All Magik Sessions

auto start session with default java
    [Documentation]    starting a session using the system JAVA_HOME
    [Tags]    withTelnet
    Set Environment Variable    JAVA_HOME    SYSTEM_JRE
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_default_java_start_telnet    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    Session Should Be Reachable
    ${result}=    Auto Stop Magik Session
    Should Contain    ${result.stdout}    JAVA_HOME=SYSTEM_JRE
    [Teardown]    Stop All Magik Sessions

auto start session with nested alias
    [Documentation]    starting a session with a argument *nested_alias* - no log file should be written to avoid gus launcher problems
    [Tags]    withTelnet
    ${msession}=    Auto Start Magik Session    A_SWPRODUCT_PATH    ALIAS_nested_start_telnet    nested_alias=${True}    cli_port=${DUMMY_CLI_PORT}    test_launch=${DUMMY_LAUNCHER}    wait=${DUMMY_WAIT}
    Session Should Be Reachable
    ${result}=    Auto Stop Magik Session
    Should Contain    ${result.stdout}    session started without -l - NO LOGFILE
    [Teardown]    Stop All Magik Sessions
