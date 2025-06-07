*** Settings ***
Documentation     Test Python Scripts , delivered with robotframework magik, for starting and stopping Smallworld Magik images with nested aliases
...
...               == Precondition ==
...
...               This test suite works with a specific SW 4.1 environment configured wih nested aliases
...
...               == Known Issue ==
...
...               Script *robot_start_magik_image* must start gis launcher without option _-l log_file_ when nested aliases are used.
...               Site effect is, gis launcher immediatly stops after starting gis session and PID cached by *robot_start_magik_image*
...               can not be used by *robot_stop_magik_image.py* to stop session, cause its _sw_magik_win32_ process has a different PID. 
...
...               == Background information ==
...
...               see issue discussion [https://github.com/lczub/robotframework-magik/issues/22| robotframework-magik #22: Support Starting Magik Images with Nested Aliases]
...               == Licence info ==
...               | Copyright 2019-2025 Luiko Czub, Smallcases Software GmbH
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
Force Tags        gisLaunch
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
    ...    PID file caches a wrong process id and the image / session can not be stopped with the script *robot_stop_magik_image*
    [Tags]    withTelnet    knownIssue    nestedAlias
    ${result_stop}=    Start and Stop    ${ALIAS_CBG_NESTED}    ${ALIASFILE_CBG}    ${DEFAULT_CLI_PORT+102}    nested=${True}
    Should Not Contain    ${result_stop.stdout}    WinError

Start and stop - cambridge none nested alias but start arg --nested_alias
    [Documentation]    == known issue ==
    ...
    ...    PID file caches a wrong process id and the image / session can not be stopped with the script *robot_stop_magik_image*
    [Tags]    withTelnet    knownIssue    nestedAlias
    ${result_stop}=    Start and Stop    ${ALIAS_CBG}    ${ALIASFILE_CBG}    ${DEFAULT_CLI_PORT+103}    nested=${True}
    Should Not Contain    ${result_stop.stdout}    WinError

Start and stop - cambridge default
    [Tags]    withTelnet
    ${result_stop}=    Start and Stop    ${ALIAS_CBG}    ${ALIASFILE_CBG}    ${DEFAULT_CLI_PORT+104}    nested=${False}
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
    RETURN    ${test_dir}

Start and Stop
    [Arguments]    ${alias}    ${aliasfile}    ${cli_port}    ${nested}=${True}
    ${wait}=    Convert Time    ${START_WAIT}
    ${swproduct}    Set Variable    ${SWPRODUCT}
    ${logdir}=    Create Empty Test Directory    cbg_nested_log
    ${piddir}=    Create Empty Test Directory    cbg_nested_pid
    IF    ${nested}
        ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --logdir    ${logdir}    --piddir    ${piddir}    --msf_startup    --wait    ${wait}    --cli_port    ${cli_port}    --aliasfile    ${aliasfile}    --nested_alias    --login    ${LOGIN_CBG}    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR}
    ELSE
        ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --logdir    ${logdir}    --piddir    ${piddir}    --msf_startup    --wait    ${wait}    --cli_port    ${cli_port}    --aliasfile    ${aliasfile}    --login    ${LOGIN_CBG}    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR}
    END
    Log Result    ${result_start}
    Run Keyword And Continue On Failure    Directory Should Not Be Empty    ${piddir}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}    --piddir    ${piddir}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    IF    ${nested}
        Directory Should Be Empty    ${logdir}
    ELSE
        Directory Should Not Be Empty    ${logdir}
    END  
    Directory Should Be Empty    ${piddir}
    RETURN    ${result_stop}

