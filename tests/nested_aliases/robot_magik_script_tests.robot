#  Copyright 2019 Luiko Czub, Smallcases Software GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

*** Settings ***
Documentation     Test Python Scripts , delivered with robotframework magik, for starting and stopping Smallworld Magik images with nested aliases
...
...               == Precondition ==
...
...               This test suite works with a specific SW 4.1 environment configured wih nested aliases
...
...               == Known Issue ==
...
...               The process id detecting for images started with nested alias does not work currently.
...               Effect is, that the image can be started with *robot_start_magik_image.py*, but not stopped with *robot_stop_magik_image.py*
...
...               == Background information ==
...
...               see issue discussion [https://github.com/lczub/robotframework-magik/issues/22| robotframework-magik #22: Support Starting Magik Images with Nested Aliases]
Force Tags        ScriptTest    notReady    nestedAlias
Library           OperatingSystem
Library           Process
Library           String
Variables         ../../resources/params/variables_sw41_cbg.py
Library           DateTime

*** Variables ***
${SCRIPTDIR}      ${CURDIR}${/}..${/}..${/}resources${/}scripts
${START_IMAGE_SCRIPT}    ${SCRIPTDIR}${/}robot_start_magik_image.py    # script under test for starting magik images
${STOP_IMAGE_SCRIPT}    ${SCRIPTDIR}${/}robot_stop_magik_image.py    # script under test for starting magik images
${RF_LOG_STDOUT}    ${TEMPDIR}${/}rf_stdout.log
${RF_LOG_STDERR}    ${TEMPDIR}${/}rf_stderr.log
${DEFAULT_CLI_PORT}    ${14001}    # default port defined in start script
${ALIAS_CBG}      ${ALIASNAME}
${ALIAS_CBG_NESTED}    ${ALIAS_CBG}_nested
${LOGIN_CBG}      ${LOGIN}
${GIS_VERSION}    41
${ALIASFILE_CBG}    ${CURDIR}${/}gis_aliases_sw${GIS_VERSION}

*** Test Cases ***
Start and stop - cambridge with nested alias
    [Documentation]    == known issue ==
    ...
    ...    Script *robot_start_magik_image* can onl ydetect the PID of the first gis process, started by nested alias.
    ...    The PID of the final gis process, which starts the image / session, is not detected.
    ...
    ...    Effect is, that the PID file caches a wrong process id and the image / session can not be stopped with the script *robot_stop_magik_image*
    [Tags]    withTelnet    knownIssue
    ${alias}=    Set Variable    ${ALIAS_CBG_NESTED}
    ${aliasfile}=    Set Variable    ${ALIASFILE_CBG}
    ${cli_port}=    Set Variable    ${DEFAULT_CLI_PORT+1}
    ${wait}=    Convert Time    ${START_WAIT}
    ${swproduct}    Set Variable    ${SWPRODUCT}
    ${logdir}=    Create Empty Test Directory    cbg_nested_log
    ${piddir}=    Create Empty Test Directory    cbg_nested_pid
    ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --nested_alias    --logdir    ${logdir}    --piddir    ${piddir}    --msf_startup    --wait    ${wait}    --cli_port    ${cli_port}    --aliasfile    ${aliasfile}    --login
    ...    ${LOGIN_CBG}    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR
    Log Result    ${result_start}
    Run Keyword And Continue On Failure    Directory Should Not Be Empty    ${piddir}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    Directory Should Be Empty    ${logdir}
    Directory Should Be Empty    ${piddir}
    Should Not Contain    ${result_stop.stdout}    WinError

Start and stop - cambridge none nested alias but start arg --nested_alias
    [Tags]    withTelnet
    ${alias}=    Set Variable    ${ALIAS_CBG}
    ${aliasfile}=    Set Variable    ${ALIASFILE_CBG}
    ${cli_port}=    Set Variable    ${DEFAULT_CLI_PORT+1}
    ${wait}=    Convert Time    ${START_WAIT}
    ${swproduct}    Set Variable    ${SWPRODUCT}
    ${logdir}=    Create Empty Test Directory    cbg_nested_log
    ${piddir}=    Create Empty Test Directory    cbg_nested_pid
    ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --nested_alias    --logdir    ${logdir}    --piddir    ${piddir}    --msf_startup    --wait    ${wait}    --cli_port    ${cli_port}    --aliasfile    ${aliasfile}    --login
    ...    ${LOGIN_CBG}    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR
    Log Result    ${result_start}
    Run Keyword And Continue On Failure    Directory Should Not Be Empty    ${piddir}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}    --piddir    ${piddir}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    Directory Should Be Empty    ${logdir}
    Directory Should Be Empty    ${piddir}
    Should Not Contain    ${result_stop.stdout}    WinError

Start and stop - cambridge default
    [Tags]    withTelnet
    ${alias}=    Set Variable    ${ALIAS_CBG}
    ${aliasfile}=    Set Variable    ${ALIASFILE_CBG}
    ${cli_port}=    Set Variable    ${DEFAULT_CLI_PORT+1}
    ${wait}=    Convert Time    ${START_WAIT}
    ${swproduct}    Set Variable    ${SWPRODUCT}
    ${logdir}=    Create Empty Test Directory    cbg_nested_log
    ${piddir}=    Create Empty Test Directory    cbg_nested_pid
    ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --logdir    ${logdir}    --piddir    ${piddir}    --msf_startup    --wait    ${wait}    --cli_port    ${cli_port}    --aliasfile    ${aliasfile}    --login    ${LOGIN_CBG}
    ...    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR
    Log Result    ${result_start}
    Run Keyword And Continue On Failure    Directory Should Not Be Empty    ${piddir}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}    --piddir    ${piddir}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    Directory Should Not Be Empty    ${logdir}
    Directory Should Be Empty    ${piddir}
    Should Not Contain    ${result_stop.stdout}    WinError

*** Keywords ***
Log Result
    [Arguments]    ${result}
    Log    ${result.stdout}
    Log    ${result.stderr}

Create Empty Test Directory
    [Arguments]    ${dname}=t1    ${dpath}=${TEMPDIR}
    ${test_dir}=    Set Variable    ${dpath}${/}${dname}
    Remove Directory    ${test_dir}    recursive=True
    Create Directory    ${test_dir}
    Directory Should Be Empty    ${test_dir}
    [Return]    ${test_dir}
