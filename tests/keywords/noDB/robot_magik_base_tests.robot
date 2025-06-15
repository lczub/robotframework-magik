*** Settings ***
Documentation     Test Robot Framework high level keywords for Smallworld Magik
...
...               Tests base connection to a smallworld swaf image with remote_cli via telnet
...               == Licence info ==
...               | Copyright 2012-2023 Luiko Czub, Smallcases Software GmbH
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
Suite Teardown    Close All Connections
Test Tags        KeywordTest    BaseTest
Resource          ../../../resources/robot_magik_base.robot
Variables         ../../../resources/params/variables_sw43_cbg.py

*** Variables ***
${CUR_TEST_DATA_DIR}    ${CURDIR}${/}test_data
${TEST_MAGIK_FILE_OK}    ${CUR_TEST_DATA_DIR}${/}hello_world_ok.magik
${TEST_MAGIK_FILE_TB}    ${CUR_TEST_DATA_DIR}${/}hello_world_tb.magik
${TEST_MAGIK_FILE_FAILURE}    ${CUR_TEST_DATA_DIR}${/}hello_world_failure.magik

*** Test Cases ***
Test keyword 'Open Magik Connection'
    ${out}=    Open Magik Connection
    Should Match Regexp    ${out}    \\S+:\\d+:(MagikSF|Magik)>

Test keyword 'Write Magik Command'
    ${out}=    Write Magik Command    1 + 1
    Should Be Equal    ${out}    ${none}
    ${out}=    Read Until Prompt
    Should Match Regexp    ${out}    \\s2 \\s\\S+:\\d+:(MagikSF|Magik)>

Test keyword 'Read Magik Output'
    Write Bare    write("1 ernie", %newline, "2 bert", %newline, "3 bibo")\n$\n
    ${out}=    Read Magik Output
    Should Match Regexp    ${out}    ^1 ernie\\s2 bert\\s3 bibo$
    Write Bare    \n$\n
    ${out}=    Read Magik Output
    Write Bare    1.as_error()\n$\n
    Run Keyword And Expect Error    *traceback*    Read Magik Output

Test keyword 'Read Magik Output' - should accept method names with substring traceback
    Write Magik Command    write("Defining method short_traceback_text() in SmallBird")
    Read Magik Output

Test keyword 'Read Magik Output' - should search parser_error
    Write Magik Command    write("Defining method short_parser_error() in SmallBird")
    Read Magik Output
    Write Magik Command    :BigBird_:SmallBird
    Run Keyword And Expect Error    *parser_error*    Read Magik Output

Test keyword 'Read Magik Output' - should get an optinal regular expression argument error_regexp
    Write Magik Command    write("a BigBird is not small")
    Read Magik Output
    Write Magik Command    write("a_BigBird is not small")
    Run Keyword And Expect Error    *BigBird*    Read Magik Output    .*[B|b]ird
    Write Magik Command    write("a traceback: is not small")
    Run Keyword And Expect Error    *traceback*    Read Magik Output    .*[B|b]ird
    Write Magik Command    write("a (parser_error) is not small")
    Run Keyword And Expect Error    *parser_error*    Read Magik Output    .*[B|b]ird

Test keyword 'Execute Magik Command'
    ${out}=    Execute Magik Command    write("1 erwin", %newline, "2 ulf", %newline, "3 hein")
    Should Be Equal As Strings    ${out}    3 hein
    ${out}=    Execute Magik Command    3 - 2
    Should Be Equal As Integers    ${out}    1

Test keyword 'Execute Magik Command' - should handle empty results
    Write Magik Command    write()
    ${out}=    Read Magik Output
    Should Be Equal    '${out}'    ''
    ${out}=    Execute Magik Command    write()
    Should Be Equal    ${out}    ${none}

Test keyword 'Execute Magik Command' - should remove trailing spaces
    ${out}=    Execute Magik Command    write("1 BigBird ")
    Should Contain    ${out}    1 BigBird
    Should Be Equal    '${out}'    '1 BigBird'

Test keyword 'Execute Magik Output' - should get an optinal regular expression argument error_regexp
    Execute Magik Command    write("a_BigBird is not small")
    Run Keyword And Expect Error    *BigBird*    Execute Magik Command    write("a_BigBird is not small")    .*[B|b]ird

Test keyword 'Prepare Magik Image'
    Prepare Magik Image
    Write Magik Command    ${CLI_OBJ_HASH}
    ${out}=    Read Until Prompt
    Should Match Regexp    ${out}    (?s)\\ssw:hash_table(\\d*).+(MagikSF|Magik)>

Test keyword 'Build Magik Object Expression'
    ${obj_exp}=    Build Magik Object Expression    bibo
    Should Be Equal As Strings    ${obj_exp}    ${CLI_OBJ_HASH}\[:bibo]

Test keyword 'Store Magik Object'
    ${obj_exp}=    Store Magik Object    ernie    2 * 11
    Should Be Equal As Strings    ${obj_exp}    ${CLI_OBJ_HASH}\[:ernie]
    ${obj}=    Execute Magik Command    ${obj_exp}
    Should Be Equal As Integers    ${obj}    22

Test keyword 'Get Magik Object'
    Execute Magik Command    ${CLI_OBJ_HASH}\[:monster] << :no_bird
    ${obj}=    Get Magik Object    monster
    Should Be Equal    ${obj}    :no_bird
    Should Match Regexp    ${obj}    ^:no_bird$

Test keyword 'Get Magik Environment Variable'
    Execute Magik Command    system.putenv("ROBOT_MAGIK_KWTEST", "")
    ${out}=    Get Magik Environment Variable    ROBOT_MAGIK_KWTEST
    Should Be Equal As Strings    '${out}'    'unset'    Falscher Wert fuer unbestimmte Environment Variable
    Execute Magik Command    system.putenv("ROBOT_MAGIK_KWTEST", "A Text 12")
    ${out}=    Get Magik Environment Variable    ROBOT_MAGIK_KWTEST
    Should Be Equal As Strings    ${out}    "A Text 12"
    Execute Magik Command    system.putenv("ROBOT_MAGIK_KWTEST", "\\\\hostname\\file.txt")
    ${out}=    Get Magik Environment Variable    ROBOT_MAGIK_KWTEST
    Should Be Equal As Strings    ${out}    "\\\\hostname\\file.txt"

bug-009 Execute Magik Command - should handle strings with \n \t \f
    [Documentation]    problems with strings including '\ ', '\\t' or '\\f'
    ${out}=    Execute Magik Command    write("12\\t23\\\\45\\n78\\f90")
    Should Be Equal As Strings    ${out}    12\\t23\\\\45\\n78\\f90

Test special characters
    [Documentation]    This Test requires an image with :de_de as first entry in !current_languages!
    ...
    ...    For non german images exclude this test with pybot arg '--exclude LanguageDE'
    [Tags]    LanguageDE
    ${special}=    Set Variable    äöüßÄÖÜ
    ${out}=    Execute Magik Command    write("${special}")
    Should Be Equal As Strings    ${out}    ${special}
    ${out}=    Execute Magik Command    message_handler(:gis_program_manager).text_for_message(:save_environment)
    Should Contain    ${out}    Änderung
    # ATTENTION : insert new test above this line
    #    the following tests handle the image cleanup and connection closure

Test keyword 'Load Magik File' - File does not exist
    ${not_existing_fname}=    Set Variable    ${CUR_TEST_DATA_DIR}${/}hello_world_does_not_exist.magik
    Run Keyword And Expect Error    *file_does_not_exist*    Load Magik File    ${not_existing_fname}

Test keyword 'Load Magik File' - Hello World OK
    ${out}=    Execute Magik Command    sw:package[:robot_hello_world]
    Should Be Equal As Strings    '${out}'    'unset'    before loading - unexpected value for global robot_hello_world
    ${out}=    Load Magik File    ${TEST_MAGIK_FILE_OK}
    Should Contain    ${out}    Hello World - all fine and very well    missing expected load file output
    ${out}=    Execute Magik Command    sw:package[:robot_hello_world]
    Should Be Equal As Strings    ${out}    "Hello World - all fine"    after loading - unexpected value for global robot_hello_world

Test keyword 'Load Magik File' - Hello World with TB
    ${out}=    Execute Magik Command    sw:package[:robot_hello_world_tb]
    Should Be Equal As Strings    '${out}'    'unset'    before loading - unexpected value for global robot_hello_world_tb
    Run Keyword And Expect Error    *Hello World - so sad we must raise an expected tb*    Load Magik File    ${TEST_MAGIK_FILE_TB}
    ${out}=    Execute Magik Command    sw:package[:robot_hello_world_tb]
    Should Be Equal As Strings    ${out}    "Hello World - so sad"    after loading - unexpected value for global robot_hello_world_tb

Test keyword 'Load Magik File' - Hello World with Failure
    ${out}=    Execute Magik Command    sw:package[:robot_hello_world_failure]
    Should Be Equal As Strings    '${out}'    'unset'    before loading - unexpected value for global robot_hello_world_failure
    Run Keyword And Expect Error    *Hello World - so sad we have wrong content*    Load Magik File    ${TEST_MAGIK_FILE_FAILURE}    error_regexp=wrong content
    ${out}=    Execute Magik Command    sw:package[:robot_hello_world_failure]
    Should Be Equal As Strings    ${out}    "Hello World - so sad"    after loading - unexpected value for global robot_hello_world_failure

Test keyword 'Load Magik Module' - Module does not exist
    ${not_existing_mname}=    Set Variable    my_not_existing_module
    Run Keyword And Expect Error    *sw_module_no_such_module*    Load Magik Module    ${not_existing_mname}

Test keyword 'Load Magik Module' - Module exist
    ${existing_mname}=    Set Variable    tree_examples
    ${out}=    Load Magik Module    ${existing_mname}
    Should Match    ${out}    *${existing_mname}.*loaded*

Test keyword 'Get Smallworld Version'
    ${swv}=    Get Smallworld Version
    Should Match Regexp    ${swv}    \\d\\d\\d(\\d)?

Test keyword 'Clean Magik Image'
    Clean Magik Image
    Write Magik Command    ${CLI_OBJ_HASH}
    ${out}=    Read Until Prompt
    Should Match Regexp    ${out}    (?s) unset.+(MagikSF|Magik)>

Test keyword 'Close Magik Connection'
    ${out}=    Close Magik Connection
    Should Match Regexp    '${out}'    '\\s*'
    Run Keyword And Expect Error    No connection open    Read Magik Output
