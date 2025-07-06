*** Settings ***
Documentation     Test Parsing different Magik Prompt Variations.
...
...               - SW GIS 4.x and corresponding remote_cli uses as prompt *MagikSF>*
...               - SW GIS 5.0 uses as prompt *Magik>*, corresponding remote_cli still uses as prompt *MagikSF>*
...               - future SW GIS 5.x should use as prompt *Magik>* also for the corresponding remote_cli
...
...               This test suite uses the script _dummy_remte_cli.py_ to simulate a remote_cli with different prompt variations and prepared return values.
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
Test Tags         PromptTest
Library           Process
Library           ../../resources/RobotMagikLauncher.py    cli_port=${DUMMY_CLI_PORT}    wait=10s
Library           OperatingSystem
Resource          ../../resources/robot_magik_base.robot

*** Variables ***
${DUMMY_LAUNCHER}    ${CURDIR}${/}dummy_gis_launcher.py
${DUMMY_CLI_PORT}    14012
${CLI_PORT}       ${DUMMY_CLI_PORT}

*** Test Cases ***
Test Open Magik Connection - MagikSF>
    ${prompt}=    Set Variable    MagikSF
    ${out}=    Open Magik Connection with special prompt    ${prompt}
    Should Match Regexp    ${out}    \\S+:\\d+:${prompt}>
    [Teardown]    Stop All Magik Sessions


Test Open Magik Connection - Magik>
    ${prompt}=    Set Variable    Magik
    ${out}=    Open Magik Connection with special prompt    ${prompt}
    Should Match Regexp    ${out}    \\S+:\\d+:${prompt}>
    [Teardown]    Stop All Magik Sessions


Test Read Magik Output - MagikSF>
    Open Magik Connection with special prompt    MagikSF
    Write Bare    write("1 ernie", %newline, "2 bert", %newline, "3 bibo")\n$\n
    ${out}=    Read Magik Output
    Should Match Regexp    ${out}    ^1 ernie\\s2 bert\\s3 bibo$
    Write Bare    \n$\n
    ${out}=    Read Magik Output
    Write Bare    1.as_error()\n$\n
    Run Keyword And Expect Error    *traceback*    Read Magik Output
    [Teardown]    Stop All Magik Sessions


Test Read Magik Output - Magik>
    Open Magik Connection with special prompt    Magik
    Write Bare    write("1 ernie", %newline, "2 bert", %newline, "3 bibo")\n$\n
    ${out}=    Read Magik Output
    Should Match Regexp    ${out}    ^1 ernie\\s2 bert\\s3 bibo$
    Write Bare    \n$\n
    ${out}=    Read Magik Output
    Write Bare    1.as_error()\n$\n
    Run Keyword And Expect Error    *traceback*    Read Magik Output
    [Teardown]    Stop All Magik Sessions

Test Open Magik Connection - special prompt>
    ${prompt}=    Set Variable    special prompt
    Set Test Variable    $CLI_PROMPT_REGEXP    \\S+:\\d+:(MagikSF|Magik|${prompt})>
    ${out}=    Open Magik Connection with special prompt    ${prompt}
    Should Match Regexp    ${out}    \\S+:\\d+:${prompt}>
    [Teardown]    Stop All Magik Sessions

Test Read Magik Output - special prompt>
    ${prompt}=    Set Variable    special prompt
    Set Test Variable    $CLI_PROMPT_REGEXP    \\S+:\\d+:(MagikSF|Magik|${prompt})>
    ${out}=    Open Magik Connection with special prompt    ${prompt}
    Write Bare    write("1 ernie", %newline, "2 bert", %newline, "3 bibo")\n$\n
    ${out}=    Read Magik Output
    Should Match Regexp    ${out}    ^1 ernie\\s2 bert\\s3 bibo$
    Write Bare    \n$\n
    ${out}=    Read Magik Output
    Write Bare    1.as_error()\n$\n
    Run Keyword And Expect Error    *traceback*    Read Magik Output
    [Teardown]    Stop All Magik Sessions

debug prompt regexp
    [Tags]    notReady
    ${out_orig1}=    Set Variable     1 ernie\n2 bert\n3 bibo\ndummy:14012:Magik>
    ${output_regexp1}=    Set Variable    (?s)\\s(.*)\\s\\S+:\\d+:(MagikSF|Magik)>
    ${match}    ${out}    ${other}=    Should Match Regexp    ${out_orig1}    ${output_regexp1}
    Log    match<${match}> out<${out}> other<${other}>
    ${out_orig2}=    Set Variable     1 ernie\n2 bert\n3 bibo\ndummy:14012:special prompt>
    ${output_regexp2}=    Set Variable    (?s)\\s(.*)\\s\\S+:\\d+:(MagikSF|Magik|special.prompt)>
    ${match}    ${out}    ${other}=    Should Match Regexp    ${out_orig2}    ${output_regexp2}
    Log    match<${match}> out<${out}> other<${other}>
    ${out_orig3}=    Set Variable     1 ernie\n2 bert\n3 bibo\ndummy:14012:special prompt>
    ${output_regexp3}=    Set Variable    (?s)\\s(.*)\\s\\S+:\\d+:(MagikSF|Magik|special prompt)>
    ${match}    ${out}    ${other}=    Should Match Regexp    ${out_orig3}    ${output_regexp3}
    Log    match<${match}> out<${out}> other<${other}>

*** Keywords ***
Open Magik Connection with special prompt
    [Arguments]    ${prompt}    ${port}=${DUMMY_CLI_PORT}    ${host}=localhost
    [Documentation]    Starts a telnet server process, simulating a SW GIS remote_cli with a special prompt.
    ...                waits till telnet session is reachable and opens Magik connection
    Set Test Variable    $DUMMY_PROMPT    ${prompt}
    ${msession}=    Start Magik Session    A_SWPRODUCT_PATH    ALIAS_prompt_start_telnet    cli_port=${DUMMY_CLI_PORT}    gis_args=-cli    test_launch=${DUMMY_LAUNCHER}
    Session Should Be Reachable
    ${out}=    Open Magik Connection    host=${host}    port=${port}
    RETURN    ${out}
