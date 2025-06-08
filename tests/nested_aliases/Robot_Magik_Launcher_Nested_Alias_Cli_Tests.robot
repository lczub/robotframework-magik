*** Settings ***
Documentation     minimal test workflow - start session, calculate something , close the session
...
...               gis session is started using a nested alias and additional gis arg *-cli* and *-login USER/PW* are added
...
...               == not stable ==
...
...               session will stay cause cached PID does not reflect _sw_magik_win32_ process when starting nested alias
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
Force Tags        gisLaunch    nestedAlias    notStable
Library           Process
Variables         ../../resources/params/variables_sw41_cbg.py
Library           ../../resources/RobotMagikLauncher.py    swproduct=${SWPRODUCT}    cli_port=${CLI_PORT+100}    wait=${START_WAIT}
Resource          ../../resources/robot_magik_base.robot

*** Variables ***
${ALIAS_NESTED}    ${ALIASNAME}_nested
${LOGIN_CBG}      ${LOGIN}
${GIS_VERSION}    41
${ALIASFILE_NESTED}    ${CURDIR}${/}gis_aliases_sw${GIS_VERSION}

*** Test Cases ***
start magik session
    [Documentation]    start magik session, prepare telnet connection and check that the telnet connection
    [Tags]    withTelnet
    ${msession}=    Start Magik Session    aliasfile=${ALIASFILE_NESTED}    gis_alias=${ALIAS_NESTED}    nested_alias=${True}    msf_startup=${MSFSTARTUP}    gis_args=-cli -login ${LOGIN_CBG}
    Session Should Be Reachable
    #    Stop Magik Session

calc with magik session
    [Documentation]    calculate something with the magik session with a telent connection, check if the telent connection works and stop the session
    [Tags]    withTelnet
    ${out}=    Open Magik Connection    port=${CLI_PORT+100}
    ${out}=    Execute Magik Command    3 - 2
    Should Be Equal As Integers    ${out}    1
    ${out}=    Close Magik Connection

stop magik session
    [Documentation]    stop the magik session
    [Tags]    withTelnet
    Stop Magik Session
