#  Copyright 2012-2019 Luiko Czub, Smallcases Software GmbH
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
Documentation     [http://robotframework.org|Robot Framework] high level keywords for automated testing [https://en.wikipedia.org/wiki/Magik_%28programming_language%29|Smallworld Magik] images.
...
...               These keywords uses the [http://robotframework.org/robotframework/latest/libraries/Telnet.html|TelnetLibrary] to send commands to Magik images and read there response.
...
...               The Magik image must have started a remote_cli:
...               - remote_cli.new(_optional port auth_proc)
...               When Robot Framework runs on the same machine as the image, the remote_cli could be started with default settings.
...               | remote_cli.new()
...               | $
...               When Robot Framework and Magik image runs on different machines, remote_cli must be started with special port and auth proc to accept connections from other machine.
...               | _global example_auth_proc << _proc (hostname, hostaddr)
...               | \ \ \## a customised remote_cli auth_proc
...               | \ \ \ _if hostaddr = "127.0.0.1" _orif \ \ \ \ \ \ \ \ \ \ \ \ # default local host ip
...               | \ \ \ \ \ \ \ hostaddr.matches?("*.0.0.0.0.0.1") _orif # unconventional local ip under sw5
...               | \ \ \ \ \ \ \ hostaddr.matches?("111.222.333.*") \ \ \ \ \ \ # special authorised none local ip
...               | \ \ \ _then
...               | \ \ \ \ \ \ \ # trust localhost or local network
...               | \ \ \ \ \ \ \ _return _true
...               | \ \ \ _else
...               | \ \ \ \ \ \ \ # trust nobody
...               | \ \ \ \ \ \ \ _return _false
...               | \ \ \ _endif
...               | _endproc
...               | $
...               | remote_cli.new(14099, example_auth_proc)
...               | $
...
...               These connection parameters could be set for each test run separatly via variables (see `Open Magik Connection`).
...
...               Example, how to start the [../examples/coordinate_tests.txt|coordinate tests] with special connection settings:
...               | pybot --variable CLI_PORT:14099 --variable CLI_HOST:111.222.333.44 --variable CLI_TIMEOUT:15 coordinate_tests.txt
...
...               To minimise the number of global variables, tests should use the keywords `Store Magik Object`
...               and `Get Magik Object`.
...               They store the result of a Magik expression in a hash_table and returns another Magik expression,
...               which will return this result. So it is possible to share Magik objects between keywords (and tests)
...               and clean the image during the teardown from all created global variables. Only this hash_table must be set to *_unset*.
...
...               The name of this global hash_table could be set for each test run separatly via variables.
...
...               | *Variable* | *Default* | *Description* |
...               | ${CLI_OBJ_HASH} | robot_objhash | global variable name inside the Magik image to store objects |
...
...               Definition and cleaning of this global hash_table see `Prepare Magik Image` and `Clean Magik Image`.
...
...               Tests should use `Execute Magik Command` to send a Magik expression and read the response.
...
...               == Switching between sessions under test ==
...
...               Tests handling with more than one magik session should use the TelnetLibrary keyword
...               [http://robotframework.org/robotframework/latest/libraries/Telnet.html#Switch%20Connection|Switch Connection]
...               to switch the current connection between these sessions.
...
...               == Additional keyword definitions ==
...
...               - keywords for testing Smallworld ds_views, ds_collections and rwo records see [./robot_magik_dsview.html|robot_magik_dsview]
...
...               == Requirements ==
...               Robot Framework Version >= 2.8.2 is required, cause `Execute Magik Command` uses the String library keyword
...               [http://robotframework.org/robotframework/latest/libraries/String.html#Replace%20String%20Using%20Regexp|Remove String Using Regexp]
Library           Telnet    3.0
Library           String

*** Variables ***
${CLI_HOST}       localhost
${CLI_PORT}       14001
${CLI_TIMEOUT}    3.0
${CLI_NEWLINE}    \n
${CLI_OBJ_HASH}    robot_objhash
${CLI_ENCODING}    ISO-8859-1

*** Keywords ***
Open Magik Connection
    [Arguments]    ${host}=${CLI_HOST}    ${alias}=swimage    ${port}=${CLI_PORT}    ${timeout}=${CLI_TIMEOUT}    ${newline}=${CLI_NEWLINE}    ${encoding}=${CLI_ENCODING}
    [Documentation]    Opens a telnet connection to remote_cli of a Smallworld Magik image
    ...
    ...    The connection parameters could be set with following variables
    ...
    ...    | *Variable* | *Default* | *Description* |
    ...    | ${CLI_HOST} | localhost | hostname or ip of machine, where the Magik images run |
    ...    | ${CLI_PORT} | 14001 | port, the Magik image remote_cli listens |
    ...    | ${CLI_TIMEOUT} | 3.0 | max. secs, tests should wait for a response from the Magik image |
    ...    | ${CLI_ENCODING} | ISO-8859-1 | used text encoding for communication with remote_cli |
    ${prompt}=    Set Variable    \\S+:\\d+:(MagikSF|Magik)>
    Open Connection    host=${host}    alias=${alias}    port=${port}    timeout=${timeout}    newline=${newline}    prompt=${prompt}
    ...    prompt_is_regexp=True    encoding=${encoding}
    ${out}=    Read until prompt
    # LC 04.07.12: the prompt must be extended with a leading newline, otherwise tracebacks
    # will not be read completly. Reason is, that the traceback itself includes lines with
    # "xxx:iii:MagikSF>" strings. This would break the telnet prompt search.
    # Without this change, the "Test Execute Magik Command" in robot_magik_base_tests fails,
    # cause the prio running "Test Magik Output" could not read the complete (expected)
    # traceback block.
    Set Prompt    \\s${out}    True
    [Return]    ${out}

Write Magik Command
    [Arguments]    ${magik_expression}
    [Documentation]    Sends a Magik expression, followed by <newline>$<newline>
    ...
    ...    Did not return the output, this must be read separatly, for example with `Read Magik Output`.
    ...    The keyword `Execute Magik Command` combinates both keywords.
    Write Bare    ${magik_expression}\n$\n

Read Magik Output
    [Arguments]    ${error_regexp}=
    [Documentation]    Returns all output lines between the last Magik command and next prompt
    ...
    ...    Fails, if these lines include the strings *traceback:* or *(parser_error)* or
    ...    the optional regular expression _error_regexp_
    ${out_orig}=    Read until prompt
    Should Not Match Regexp    ${out_orig}    .*traceback:|.*\\(parser_error\\)
    Run Keyword If    '${error_regexp}'!=''    Should Not Match Regexp    ${out_orig}    ${error_regexp}
    ${match}    ${out}=    Should Match Regexp    ${out_orig}    (?s)\\s(.*)\\s\\S+:\\d+:(?:MagikSF|Magik)>
    [Return]    ${out}

Prepare Magik Image
    [Documentation]    Sends some initial Magik commands to prepare the test session.
    ...
    ...    - Defines a global hash_table with name ${CLI_OBJ_HASH},
    ...    - this is a precondition for the keywords `Store Magik Object` and `Get Magik Object`
    ...    - Set !current_package! to _package user
    ...
    ...    Should be used in a _Test Setup_ or _Suite Setup_ setting.
    ...
    ...    | *Setting* | *Value* | *Value* | *Value* |
    ...    | xxxxx Setup | Run Keywords | `Open Magik Connection` | `Prepare Magik Image` |
    Write Magik Command    _package user
    Read Magik Output
    Write Magik Command    _global ${CLI_OBJ_HASH} << hash_table.new()
    Read Magik Output

Clean Magik Image
    [Documentation]    Sends some final Magik commands to clean the test session.
    ...
    ...    - Sets the global hash_table with name ${CLI_OBJ_HASH} to _unset.
    ...
    ...    Should be used in a _Test Teardown_ or _Suite Teardown_ setting.
    ...
    ...    | *Setting* | *Value* | *Value* | *Value* |
    ...    | xxxxx Teardown | Run Keywords | `Clean Magik Image` | `Close Magik Connection` |
    Write Magik Command    _global ${CLI_OBJ_HASH} << _unset
    Read Magik Output

Close Magik Connection
    [Documentation]    Closes the telnet connection to remote_cli of a Smallworld Magik image
    ...
    ...    Returns any remaining output.
    ${out}=    Close Connection
    [Return]    ${out}

Execute Magik Command
    [Arguments]    ${magik_expression}    ${error_regexp}=
    [Documentation]    Sends a Magik command to remote_cli and returns the last line from the Magik response
    ...
    ...    Fails, if these lines include the strings *traceback:* or *(parser_error)* or
    ...    the optional regular expression _error_regexp_
    Log    ${magik_expression}
    Write Magik Command    ${magik_expression}
    ${out}=    Read Magik Output    ${error_regexp}
    ${count}=    Get Length    ${out}
    ${last_line}=    Run Keyword Unless    ${count}==0    Get Line    ${out}    -1
    ${result}=    Run Keyword Unless    ${count}==0    Remove String Using Regexp    ${last_line}    \\s*$
    [Return]    ${result}

Build Magik Object Expression
    [Arguments]    ${obj_name}
    [Documentation]    Returns a Magik expression, which will return a Magik object from the global hash_table
    ...
    ...    This is an internal keyword, used by `Store Magik Object` and `Get Magik Object`
    ${obj_expression}=    Convert To String    ${CLI_OBJ_HASH}[:${obj_name}]
    [Return]    ${obj_expression}

Store Magik Object
    [Arguments]    ${obj_name}    ${magik_expression}
    [Documentation]    Stores the result of a Magik expression in a global hash_table as an object.
    ...
    ...    Returns another Magik expression, which will return this object.
    ...    see although `Prepare Magik Image` and `Get Magik Object`
    ${obj_expression}=    Build Magik Object Expression    ${obj_name}
    Execute Magik Command    ${obj_expression} << ${magik_expression}
    [Return]    ${obj_expression}

Get Magik Object
    [Arguments]    ${obj_name}
    [Documentation]    Returns a Magik object, stored in the global hash_table.
    ...
    ...    see although `Prepare Magik Image` and `Store Magik Object`
    ${obj_expression}=    Build Magik Object Expression    ${obj_name}
    ${out}=    Execute Magik Command    ${obj_expression}
    [Return]    ${out}

Get Magik Environment Variable
    [Arguments]    ${env_name}
    [Documentation]    Returns value of the environment variable _env_name_
    ...
    ...    It's the value, as it is known inside the Magik Image
    ${out}=    Execute Magik Command    system.getenv("${env_name}")
    [Return]    ${out}
