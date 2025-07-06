*** Settings ***
Documentation     Test Python Scripts for starting and stopping Smallworld Magik images, delivered with robotframework magik
...
...               Background information about starting process with sub process see
...
...               - issue discussion [https://github.com/robotframework/robotframework/issues/2085| robotframework #2085: Process library Wait For Process keyword does not return when used with some adb commands] \ and
...               - examples [https://gist.github.com/lczub/22b0f2a12a27c30d0a14#file-wait_process_tests-txt|Gist - robot framework samples - Wait For Process]
...               == Licence info ==
...               | Copyright 2016-2025 Luiko Czub, Smallcases Software GmbH
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
Test Tags        ScriptTest
Library           OperatingSystem
Library           Process
Library           String
Variables         ../../resources/params/variables_sw43_cbg.py
Library           DateTime

*** Variables ***
${SCRIPTDIR}      ${CURDIR}${/}..${/}..${/}resources${/}scripts
${START_IMAGE_SCRIPT}    ${SCRIPTDIR}${/}robot_start_magik_image.py    # script under test for starting magik images
${STOP_IMAGE_SCRIPT}    ${SCRIPTDIR}${/}robot_stop_magik_image.py    # script under test for starting magik images
${DUMMY_LAUNCHER}    ${CURDIR}${/}dummy_gis_launcher.py
${RF_LOG_STDOUT}    ${TEMPDIR}${/}rf_stdout.log
${RF_LOG_STDERR}    ${TEMPDIR}${/}rf_stderr.log
${DUMMY_CLI_PORT}    ${14011}    # default port for communication with dummy_remote_cli
${DEFAULT_CLI_PORT}    ${14001}    # default port defined in start script
${ALIAS_CBG}      ${ALIASNAME}
${ALIASFILE_CBG}    ${ALIASFILE}
${ALIAS_SWAF}     swaf
${LOGIN_CBG}      ${LOGIN}
${DUMMY_ENVFILE}    ${CURDIR}${/}dummy_envfile.bat
${DUMMY_WAIT}    5    # sec to wait till telnet session should be reachable

*** Test Cases ***
Start Image Script without args
    [Tags]    noTelnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}
    Log Result    ${result}
    Should Contain    ${result.stderr}    the following arguments are required: swproduct, alias
    Should Be Equal As Integers    ${result.rc}    2

Start Image Script with -h
    [Tags]    noTelnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}    -h
    Log Result    ${result}
    Should Contain    ${result.stdout}    starts a Magik 4.x image or 5.x session and activates the remote cli.
    Should Contain    ${result.stdout}    swproduct alias
    Should Contain    ${result.stdout}    -h, --help
    Should Contain    ${result.stdout}    --envfile ENVFILE
    Should Contain    ${result.stdout}    --aliasfile ALIASFILE
    Should Contain    ${result.stdout}    --cli_port CLI_PORT
    Should Contain    ${result.stdout}    --piddir PIDDIR
    Should Contain    ${result.stdout}    --logdir LOGDIR
    Should Contain    ${result.stdout}    --login LOGIN
    Should Contain    ${result.stdout}    --script SCRIPT
    Should Contain    ${result.stdout}    --msf_startup
    Should Contain    ${result.stdout}    --wait WAIT
    Should Contain    ${result.stdout}    --nested_alias
    Should Contain    ${result.stdout}    --gis_args
    Should Contain    ${result.stdout}    --test_launch TEST_LAUNCH
    Should Be Equal As Integers    ${result.rc}    0

Stop Image Script with -h
    [Tags]    noTelnet
    ${result}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    -h
    Log Result    ${result}
    Should Contain    ${result.stdout}    stops a Magik image and his remote cli
    Should Contain    ${result.stdout}    -h, --help
    Should Contain    ${result.stdout}    --cli_port CLI_PORT
    Should Contain    ${result.stdout}    --piddir PIDDIR
    Should Be Equal As Integers    ${result.rc}    0

Start Image Script - not reachable via telnet
    [Tags]    dummyLaunch    noTelnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}    --wait    ${DUMMY_WAIT}    --test_launch    ${DUMMY_LAUNCHER}    A_SWPRODUCT    A_ALIAS
    Log Result    ${result}
    Should Contain    ${result.stderr}    Image is NOT reachable via telnet localhost:${DEFAULT_CLI_PORT}
    Should Be Equal As Integers    ${result.rc}    1

Stop Image Script - pid file does not exist
    [Tags]    noTelnet
    ${result}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    14111
    Log Result    ${result}
    Should Contain    ${result.stderr}    required PID file does not exist
    Should Contain    ${result.stdout}    14111.pid
    Should Be Equal As Integers    ${result.rc}    1

Start Image Script with default settings
    [Tags]    dummyLaunch    withTelnet
    ${alias}=    Set Variable    ALIAS_start_telnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}    --wait    ${DUMMY_WAIT}   --test_launch    ${DUMMY_LAUNCHER}    A_SWPRODUCT    ${alias}
    Log Result    ${result}
    ${robot_magik_dir}=    Normalize Path    ${CURDIR}${/}..${/}..
    Should Contain    ${result.stdout}    ROBOT_MAGIK_DIR=${robot_magik_dir}
    Should Not Contain    ${result.stdout}    ROBOT_MAGIK_DIR=${robot_magik_dir}${/}
    Should Contain    ${result.stdout}    ROBOT_CLI_PORT=${DEFAULT_CLI_PORT}
    Should Contain    ${result.stdout}    SW_MSF_STARTUP_MAGIK=None
    Should Contain    ${result.stdout}    SW_GIS_ENVIRONMENT_FILE=None
    ${robot_magik_script}=    Normalize Path    ${robot_magik_dir}${/}resources${/}scripts${/}start_robot_remote_cli.script
    Should Contain    ${result.stdout}    -run_script ${robot_magik_script}
    Should Contain    ${result.stdout}    -i ${alias} ${TEMPDIR}
    ${robot_temp_dir}=    Normalize Path    ${TEMPDIR}${/}robot_magik
    Directory Should Exist    ${robot_temp_dir}
    Should Contain    ${result.stdout}    -l ${robot_temp_dir}${/}${alias}
    ${pid}=    Check PID File    ${robot_temp_dir}${/}${DEFAULT_CLI_PORT}.pid
    Should Contain    ${result.stdout}    PID=${pid}
    Should Contain    ${result.stdout}    Image is now reachable via telnet localhost:${DEFAULT_CLI_PORT} with prompt b'dummy:${DEFAULT_CLI_PORT}:MagikSF>'
    Should Be Equal As Integers    ${result.rc}    0

Start Image Script with -msf_startup
    [Tags]    dummyLaunch    withTelnet
    ${alias}=    Set Variable    ALIAS_start_telnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}    --msf_startup    --wait    ${DUMMY_WAIT}    --test_launch    ${DUMMY_LAUNCHER}    A_SWPRODUCT    ${alias}
    Log Result    ${result}
    ${robot_magik_dir}=    Normalize Path    ${CURDIR}${/}..${/}..
    Should Contain    ${result.stdout}    ROBOT_MAGIK_DIR=${robot_magik_dir}
    Should Contain    ${result.stdout}    ROBOT_CLI_PORT=${DEFAULT_CLI_PORT}
    ${robot_magik_script}=    Normalize Path    ${robot_magik_dir}${/}resources${/}scripts${/}start_robot_remote_cli.magik
    Should Contain    ${result.stdout}    SW_MSF_STARTUP_MAGIK=${robot_magik_script}
    Should Not Contain    ${result.stdout}    -run_script
    Should Contain    ${result.stdout}    -i ${alias} ${TEMPDIR}
    ${robot_temp_dir}=    Normalize Path    ${TEMPDIR}${/}robot_magik
    Directory Should Exist    ${robot_temp_dir}
    Should Contain    ${result.stdout}    -l ${robot_temp_dir}${/}${alias}
    ${pid}=    Check PID File    ${robot_temp_dir}${/}${DEFAULT_CLI_PORT}.pid
    Should Contain    ${result.stdout}    PID=${pid}
    Should Be Equal As Integers    ${result.rc}    0

Start Image Script with additional gis args -cli
    [Tags]    dummyLaunch    withTelnet
    ${alias}=    Set Variable    ALIAS_start_telnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}    --msf_startup    --wait    ${DUMMY_WAIT}    --test_launch    ${DUMMY_LAUNCHER}    --gis_args    '-cli'    A_SWPRODUCT    ${alias}
    Log Result    ${result}
    Should Match    ${result.stdout}    *start_gis : Start gis session with: * -cli*
    Should Match    ${result.stdout}    *dummy_gis : start args= * -cli*
    ${robot_magik_dir}=    Normalize Path    ${CURDIR}${/}..${/}..
    Should Contain    ${result.stdout}    ROBOT_MAGIK_DIR=${robot_magik_dir}
    Should Contain    ${result.stdout}    ROBOT_CLI_PORT=${DEFAULT_CLI_PORT}
    ${robot_magik_script}=    Normalize Path    ${robot_magik_dir}${/}resources${/}scripts${/}start_robot_remote_cli.magik
    Should Contain    ${result.stdout}    SW_MSF_STARTUP_MAGIK=${robot_magik_script}
    Should Not Contain    ${result.stdout}    -run_script
    Should Contain    ${result.stdout}    -i ${alias} ${TEMPDIR}
    ${robot_temp_dir}=    Normalize Path    ${TEMPDIR}${/}robot_magik
    Directory Should Exist    ${robot_temp_dir}
    Should Contain    ${result.stdout}    -l ${robot_temp_dir}${/}${alias}
    ${pid}=    Check PID File    ${robot_temp_dir}${/}${DEFAULT_CLI_PORT}.pid
    Should Contain    ${result.stdout}    PID=${pid}
    Should Be Equal As Integers    ${result.rc}    0

Start Image Script with additional gis args multiple
    [Tags]    dummyLaunch    withTelnet
    ${alias}=    Set Variable    ALIAS_start_telnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}    --msf_startup    --wait    ${DUMMY_WAIT}    --test_launch    ${DUMMY_LAUNCHER}    --gis_args    "-cli -login root/huhu"    A_SWPRODUCT    ${alias}
    Log Result    ${result}
    Should Match    ${result.stdout}    *start_gis : Start gis session with: * -cli -login root/huhu*
    Should Match    ${result.stdout}    *dummy_gis : start args= * -cli -login root/huhu*
    ${robot_magik_dir}=    Normalize Path    ${CURDIR}${/}..${/}..
    Should Contain    ${result.stdout}    ROBOT_MAGIK_DIR=${robot_magik_dir}
    Should Contain    ${result.stdout}    ROBOT_CLI_PORT=${DEFAULT_CLI_PORT}
    ${robot_magik_script}=    Normalize Path    ${robot_magik_dir}${/}resources${/}scripts${/}start_robot_remote_cli.magik
    Should Contain    ${result.stdout}    SW_MSF_STARTUP_MAGIK=${robot_magik_script}
    Should Not Contain    ${result.stdout}    -run_script
    Should Contain    ${result.stdout}    -i ${alias} ${TEMPDIR}
    ${robot_temp_dir}=    Normalize Path    ${TEMPDIR}${/}robot_magik
    Directory Should Exist    ${robot_temp_dir}
    Should Contain    ${result.stdout}    -l ${robot_temp_dir}${/}${alias}
    ${pid}=    Check PID File    ${robot_temp_dir}${/}${DEFAULT_CLI_PORT}.pid
    Should Contain    ${result.stdout}    PID=${pid}
    Should Be Equal As Integers    ${result.rc}    0

Start Dummy Gis Launcher
    [Tags]    dummyLaunch    withTelnet
    ${cli_port}=    Set Variable    ${DUMMY_CLI_PORT+1}
    ${result_start}=    Start Dummy Gis Launcher    alias=ALIAS_start_telnet    cli_port=${cli_port}    wait_telnet=${DUMMY_WAIT}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Not Contain    ${result_start.stderr}    Traceback
    ${robot_temp_dir}=    Normalize Path    ${TEMPDIR}${/}robot_magik
    Directory Should Exist    ${robot_temp_dir}
    ${pid}=    Check PID File    ${robot_temp_dir}${/}${cli_port}.pid

stop with default settings
    [Tags]    dummyLaunch    withTelnet
    ${alias}=    Set Variable    ALIAS_start_telnet
    ${cli_port}=    Set Variable    ${DUMMY_CLI_PORT+1}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_stop.rc}    0

Start and stop with default settings
    [Tags]    dummyLaunch    withTelnet
    ${alias}=    Set Variable    ALIAS_start_telnet
    ${cli_port}=    Set Variable    ${DUMMY_CLI_PORT+1}
    ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --wait    ${DUMMY_WAIT}    --cli_port    ${cli_port}    --test_launch    ${DUMMY_LAUNCHER}    A_SWPRODUCT    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR}
    Log Result    ${result_start}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    Should Not Contain    ${result_stop.stdout}    WinError

Start and stop - swaf
    [Tags]    withTelnet    gisLaunch
    ${alias}=    Set Variable    ${ALIAS_SWAF}
    ${cli_port}=    Set Variable    ${DEFAULT_CLI_PORT+1}
    ${wait}=    Convert Time    ${START_WAIT}
    ${swproduct}=    Set Variable    ${SWPRODUCT}
    ${logdir}=    Create Empty Test Directory    swaf_with_log
    ${piddir}=    Create Empty Test Directory    swaf_pid
    ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --msf_startup    --logdir    ${logdir}    --piddir    ${piddir}    --wait    ${wait}    --cli_port    ${cli_port}    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR}
    Log Result    ${result_start}
    Run Keyword And Continue On Failure    Directory Should Not Be Empty    ${piddir}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}    --piddir    ${piddir}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    Directory Should Not Be Empty    ${logdir}
    Directory Should Be Empty    ${piddir}
    Should Not Contain    ${result_stop.stdout}    WinError

Start and stop - cambridge with -run_script
    [Tags]    withTelnet    gisLaunch
    Skip If    '${GIS_VERSION}'!='43'    gis launcher command line argumemt -run_script works only with 43 well
    ${alias}=    Set Variable    ${ALIAS_CBG}
    ${aliasfile}=    Set Variable    ${ALIASFILE_CBG}
    ${cli_port}=    Set Variable    ${DEFAULT_CLI_PORT+1}
    ${wait}=    Convert Time    ${START_WAIT}
    ${swproduct}    Set Variable    ${SWPRODUCT}
    ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --wait    ${wait}    --cli_port    ${cli_port}    --aliasfile    ${aliasfile}    --login    ${LOGIN_CBG}    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR}
    Log Result    ${result_start}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    Should Not Contain    ${result_stop.stdout}    WinError

Start and stop - cambridge with SW_MSF_STARTUP_MAGIK
    [Tags]    withTelnet    gisLaunch
    ${alias}=    Set Variable    ${ALIAS_CBG}
    ${aliasfile}=    Set Variable    ${ALIASFILE_CBG}
    ${cli_port}=    Set Variable    ${DEFAULT_CLI_PORT+1}
    ${wait}=    Convert Time    ${START_WAIT}
    ${swproduct}    Set Variable    ${SWPRODUCT}
    ${result_start}=    Run Process    python    ${START_IMAGE_SCRIPT}    --msf_startup    --wait    ${wait}    --cli_port    ${cli_port}    --aliasfile    ${aliasfile}    --login    ${LOGIN_CBG}    ${swproduct}    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR}
    Log Result    ${result_start}
    ${result_stop}=    Run Process    python    ${STOP_IMAGE_SCRIPT}    --cli_port    ${cli_port}
    Log Result    ${result_stop}
    Should Be Equal As Integers    ${result_start.rc}    0
    Should Be Equal As Integers    ${result_stop.rc}    0
    Should Not Contain    ${result_stop.stdout}    WinError

Start Image Script with special environment
    [Tags]    dummyLaunch    withTelnet
    ${alias}=    Set Variable    ALIAS_start_telnet
    ${result}=    Run Process    python    ${START_IMAGE_SCRIPT}    --envfile    ${DUMMY_ENVFILE}    --wait    ${DUMMY_WAIT}    --test_launch    ${DUMMY_LAUNCHER}    A_SWPRODUCT    ${alias}
    Log Result    ${result}
    Should Contain    ${result.stdout}    SW_GIS_ENVIRONMENT_FILE=${DUMMY_ENVFILE}
    Should Contain    ${result.stdout}    -e ${DUMMY_ENVFILE}
    Should Contain    ${result.stdout}    Image is now reachable via telnet localhost:${DEFAULT_CLI_PORT} with prompt b'dummy:${DEFAULT_CLI_PORT}:MagikSF>
    Should Be Equal As Integers    ${result.rc}    0

*** Keywords ***
Start Dummy Gis Launcher
    [Arguments]    ${alias}=ALIAS_start_telnet    ${cli_port}=14001    ${wait_telnet}=${DUMMY_WAIT}
    ${wait_process}=    Convert To Number    ${wait_telnet}
    ${wait_process}=    Set Variable    ${wait_process + 2.0}
    ${handle_start}=    Process.Start Process    python    ${START_IMAGE_SCRIPT}    --wait    ${wait_telnet}    --cli_port    ${cli_port}    --test_launch    ${DUMMY_LAUNCHER}    A_SWPRODUCT    ${alias}    stdout=${RF_LOG_STDOUT}    stderr=${RF_LOG_STDERR}
    ${result_start}=    Wait For Process    handle=${handle_start}    timeout=${wait_process}    on_timeout=terminate
    Log Result    ${result_start}
    RETURN    ${result_start}

Log Result
    [Arguments]    ${result}
    Log    ${result.stdout}
    Log    ${result.stderr}

Check PID File
    [Arguments]    ${pid_file}
    File Should Exist    ${pid_file}
    ${pid_info}=    Get File    ${pid_file}
    ${pid}=    Get Line    ${pid_info}    0
    RETURN    ${pid}

Create Empty Test Directory
    [Arguments]    ${dname}=t1    ${dpath}=${TEMPDIR}
    ${test_dir}=    Set Variable    ${dpath}${/}${dname}
    Remove Directory    ${test_dir}    recursive=True
    Create Directory    ${test_dir}
    Directory Should Be Empty    ${test_dir}
    RETURN    ${test_dir}
