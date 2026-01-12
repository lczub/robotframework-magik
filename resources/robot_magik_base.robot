*** Settings ***
Documentation     [http://robotframework.org|Robot Framework] high level keywords for automated testing [https://en.wikipedia.org/wiki/Magik_%28programming_language%29|Smallworld Magik] images.
...
...               These keywords uses the [http://robotframework.org/robotframework/latest/libraries/Telnet.html|TelnetLibrary] sending commands to Magik images / sessions and read their response.
...
...               The Magik image / session must have started a remote_cli:
...               - remote_cli.new(_optional port auth_proc)
...               When Robot Framework runs on same machine as the image, remote_cli could be started with default settings.
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
...               Example, how to start the [../examples/coordinate_tests.robot|coordinate tests] with special connection settings:
...               | robot --variable CLI_PORT:14099 --variable CLI_HOST:111.222.333.44 --variable CLI_TIMEOUT:15 coordinate_tests.txt
...
...               To minimise the number of global Magik variables, tests should use the keywords `Store Magik Object`, `Build Magik Object Expression` and `Get Magik Object`.
...               They store the result of a Magik command in a hash_table and returns Magik expression,
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
...               - keywords loading and executing MUnit tests like [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit] see [./robot_magik_munit.html|robot_magik_munit]
...               - keywords testing Smallworld ds_views, ds_collections and rwo records see [./robot_magik_dsview.html|robot_magik_dsview]
...
...               == Requirements ==
...               Robot Framework Version 7.3 is required and Python 3.12 or 3.14 recommended.
...
...               == Customisations ==
...
...               Use [http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#variable-files|variable files] to define different gis configurations under test. Sample compare [../resources/params/variables_sw43_cbg.py|resources/params/variables_sw43_cbg.py] vs. [../resources/params/variables_sw43_cbg.py|resources/params/variables_sw52_cbg.py]
...
...               *Timeout, when `Load Magik File` or `Load Magik Module`*
...               - if several files / modules affected, define / extend \ ``${MAGIK_MAX_LOAD_WAIT}`` in variable file
...               - if just one file / module affected, assign specific ${max_load_wait} argument, when test calls the keyword
...
...               *Errors are ignored, \ when `Load Magik File` or `Load Magik Module`*
...               - if several files / modules affected (e.g. localisation issue), define / extend \ ``${MAGIK_LOAD_ERROR_REGEXP}`` in variable file
...               - if just one specific file / module affected, assign specific ${error_regexp} argument, when test calls the keyword
...
...               *Magik Image / Session uses None Standard Magik Prompt*
...               - define / extend ``${MAGIK_PROMT_REGEXP}`` in variable file
...
...               *Timeout, when calling a Magik function - `Read Magik Output`*
...               - if all Magik calls effected, maybe network connection or gis machine is slow - extend variable ``${CLI_TIMEOUT}`` in variable file
...               - if just one test is effected, magik function itself might be a longrunner.
...               - test should extend timeout temporary with keyword ``Set Timeout``
...               - test *MUST* switch timeout back to default ``${CLI_TIMEOUT}`` in teardown
...               - sample see `Load Magik File` or `Load Magik Module`
...
...               == Licence info ==
...               | Copyright 2012-     Luiko Czub, Smallcases Software GmbH
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
Library           Telnet    3.0
Library           String

*** Variables ***
${CLI_HOST}       localhost
${CLI_PORT}       14001
${CLI_TIMEOUT}    3.0    # Defines default wait time for prompt, when executing simple command. Extend it when telent connection between Robot and Magik prompt is slow.
${CLI_NEWLINE}    \n
${CLI_OBJ_HASH}    robot_objhash
${CLI_ENCODING}    ISO-8859-1
${CLI_PROMPT_REGEXP}    \\S+:\\d+:(MagikSF|Magik)>    # Defines default regular expression to search for telnet CLI prompt \ like ``MagikSF>`` or `Magik>``
${MAGIK_LOAD_ERROR_REGEXP}    \\*\\*\\*\\*.(Error|Fehler):    # Defines default regular expression to search for load errors like ``**** Fehler:`` or ``**** Error:``
${MAGIK_OUTPUT_REGEXP}    (?s)\\s(.*)\\s    # Defines default regular expression used to read CLI output - will be combined with ``CLI_PROMPT_REGEXP``
${MAGIK_MAX_LOAD_WAIT}    10.0    # Defines default max wait time for prompt, when loading magik code (file or module)

*** Keywords ***
Open Magik Connection
    [Arguments]    ${host}=${CLI_HOST}    ${alias}=swimage    ${port}=${CLI_PORT}    ${timeout}=${CLI_TIMEOUT}    ${newline}=${CLI_NEWLINE}    ${encoding}=${CLI_ENCODING}    ${prompt}=${CLI_PROMPT_REGEXP}
    [Documentation]    Opens a telnet connection to remote_cli of a Smallworld Magik image
    ...
    ...    The connection parameters could be set with following variables
    ...
    ...    | *Variable* | *Default* | *Description* |
    ...    | ${CLI_HOST} | localhost | hostname or ip of machine, where the Magik images run |
    ...    | ${CLI_PORT} | 14001 | port, the Magik image remote_cli listens |
    ...    | ${CLI_TIMEOUT} | 3.0 | max. secs, tests should wait for a response from the Magik image |
    ...    | ${CLI_ENCODING} | ISO-8859-1 | used text encoding for communication with remote_cli |
    ...    | ${CLI_PROMPT_REGEXP} | \\S+:\\d+:(MagikSF|Magik)> | regular expression to search for telnet CLI prompt \ like ``MagikSF>`` or `Magik>`` |
    Open Connection    host=${host}    alias=${alias}    port=${port}    timeout=${timeout}    newline=${newline}    prompt=${prompt}    prompt_is_regexp=True    encoding=${encoding}
    ${out}=    Read until prompt
    # LC 04.07.12: the prompt must be extended with a leading newline, otherwise tracebacks
    # will not be read completly. Reason is, that the traceback itself includes lines with
    # "xxx:iii:MagikSF>" strings. This would break the telnet prompt search.
    # Without this change, the "Test Execute Magik Command" in robot_magik_base_tests fails,
    # cause the prio running "Test Magik Output" could not read the complete (expected)
    # traceback block.
    Set Prompt    \\s${out}    True
    RETURN    ${out}

Write Magik Command
    [Arguments]    ${magik_expression}
    [Documentation]    Sends a Magik expression, followed by <newline>$<newline>
    ...
    ...    Did not return the output, this must be read separatly, for example with `Read Magik Output`.
    ...    The keyword `Execute Magik Command` combinates both keywords.
    Write Bare    ${magik_expression}\n$\n

Read Magik Output
    [Arguments]    ${error_regexp}=
    [Documentation]    Returns all output lines between the last Magik command and next prompt.
    ...
    ...    Fails, if these lines include the strings *traceback:* or *(parser_error)* or
    ...    the optional regular expression _error_regexp_
    ...
    ...    === Hint - how to customize prompt search ===
    ...
    ...    adjust variables ``${MAGIK_OUTPUT_REGEXP}`` + ``${CLI_PROMPT_REGEXP}``
    ${output_regexp}=    Set Variable    ${MAGIK_OUTPUT_REGEXP}${CLI_PROMPT_REGEXP}
    ${out_orig}=    Read until prompt
    Should Not Match Regexp    ${out_orig}    .*traceback:|.*\\(parser_error\\)
    Run Keyword If    r'${error_regexp}'!=''    Should Not Match Regexp    ${out_orig}    ${error_regexp}
    ${match}    ${out}    ${prompt}=    Should Match Regexp    ${out_orig}    ${output_regexp}
    RETURN    ${out}

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
    RETURN    ${out}

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
    ${last_line}=    Run Keyword If    ${count}!=0    Get Line    ${out}    -1
    ${result}=    Run Keyword If    ${count}!=0    Remove String Using Regexp    ${last_line}    \\s*$
    RETURN    ${result}

Build Magik Object Expression
    [Arguments]    ${obj_name}
    [Documentation]    Returns a Magik expression, which will return a Magik object from the global hash_table stored with key ${obj_name}.
    ...
    ...    Use this, when methods should be called on the stored object.
    ...
    ...    see although `Store Magik Object` and `Get Magik Object`
    ${obj_expression}=    Convert To String    ${CLI_OBJ_HASH}\[:${obj_name}]
    RETURN    ${obj_expression}

Store Magik Object
    [Arguments]    ${obj_name}    ${magik_expression}
    [Documentation]    Stores the result of a Magik expression in a global hash_table as an object.
    ...
    ...    Returns another Magik expression, which will return this object.
    ...
    ...    see although `Build Magik Object Expression`, \ `Get Magik Object` and `Prepare Magik Image`
    ${obj_expression}=    Build Magik Object Expression    ${obj_name}
    Execute Magik Command    ${obj_expression} << ${magik_expression}
    RETURN    ${obj_expression}

Get Magik Object
    [Arguments]    ${obj_name}
    [Documentation]    It is more a call as a get of a Magik object, stored in the global hash_table with key ${obj_name}.
    ...    - will create output like ``a sw:test_suite`` at the prompt
    ...
    ...    Use `Build Magik Object Expression` instead , when methods should be called on it.
    ...
    ...    see although `Store Magik Object` and \ `Prepare Magik Image`
    ${obj_expression}=    Build Magik Object Expression    ${obj_name}
    ${out}=    Execute Magik Command    ${obj_expression}
    RETURN    ${out}

Get Magik Environment Variable
    [Arguments]    ${env_name}
    [Documentation]    Returns value of the environment variable _env_name_
    ...
    ...    It's the value, as it is known inside the Magik Image
    ${out}=    Execute Magik Command    system.getenv("${env_name}")
    RETURN    ${out}

Load Magik File
    [Arguments]    ${magik_file}    ${max_load_wait}=${MAGIK_MAX_LOAD_WAIT}    ${error_regexp}=${MAGIK_LOAD_ERROR_REGEXP}
    [Documentation]    Load ${magik_file} into the Magik Image / Session
    ...
    ...    Fails, if output includes strings *traceback:* or *(parser_error)* or
    ...    the optional regular expression ${error_regexp}
    ...
    ...    Waits ${max_load_wait} (e.g. 10s) till loading file must be finished.
    ...
    ...    == Site effect ==
    ...
    ...    extends connection timeout to ${max_load_wait} and switch it back to default ``${CLI_TIMEOUT}`` during the teardown.
    Set Timeout    ${max_load_wait}
    Write Magik Command    load_file("${magik_file}")
    ${out}=    Read Magik Output    ${error_regexp}
    [Teardown]    Set Timeout    ${CLI_TIMEOUT}
    RETURN    ${out}

Load Magik Module
    [Arguments]    ${module_name}    ${module_version}=_unset    ${max_load_wait}=${MAGIK_MAX_LOAD_WAIT}    ${error_regexp}=${MAGIK_LOAD_ERROR_REGEXP}
    [Documentation]    Load Magik ${module_name} using _sw_module_manager_ \ into the Magik Image / Session
    ...    - define ${module_name} as string not as symbol, e.g. _method_checker_ instead _:method_checker_
    ...
    ...    Fails, if output during loading the module includes strings *traceback:* or *(parser_error)* or
    ...    the optional regular expression ${error_regexp}
    ...
    ...    Waits ${max_load_wait} (e.g. 10s) till loading module must be finished.
    ...
    ...    === Used settings to avoid conflicts ===
    ...
    ...    :save_magikc - *_false* (SW4)
    ...    - avoids conflicts loading shared test modules into sessions with different SW version
    ...    - avoids failing the test with missing system write access of used test account, when storing _*.magikc_ files
    ...
    ...    === Used settings to minimize code infection ===
    ...
    ...    :force_reload - *_false*
    ...    - avoids reloadings an already loaded module
    ...
    ...    :update_image? - *_false*
    ...    - avoids loading additional patches, which may override current behaviour
    ...    - might be a problem, when test code itself requires core patches which are not loaded
    ...
    ...    == Site effect ==
    ...
    ...    extends connection timeout to ${max_load_wait} and switch it back to default ``${CLI_TIMEOUT}`` during the teardown.
    Set Timeout    ${max_load_wait}
    ${opt_magikc}=    Set Variable    :save_magikc, _false
    ${opt_reload}=    Set Variable    :force_reload, _false
    ${opt_update}=    Set Variable    :update_image?, _false
    Write Magik Command    sw_module_manager.load_module( :${module_name}, ${module_version}, ${opt_magikc}, ${opt_reload}, ${opt_update} )
    ${out}=    Read Magik Output    ${error_regexp}
    [Teardown]    Set Timeout    ${CLI_TIMEOUT}
    RETURN    ${out}

Get Smallworld Version
    [Documentation]    Returns Magik Image Smallworld Version as string
    ...    - sw43 and sw52 returns xxxx
    ...    - sw41 returns xxx
    ${out}=    Execute Magik Command    write(smallworld_product.sw!version.write_string)
    ${swv}=    Remove String    ${out}    .
    RETURN    ${swv}
