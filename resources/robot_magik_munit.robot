#  Copyright 2020 Luiko Czub, Smallcases Software GmbH
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
Documentation     Robot Framework Magik keywords running and evaluating MUnit tests
...
...               Uses *base_test_runner.run‌_in_new_stream()* to run MUnit tests and 
...               directly writing test result for each test run into a separate log file - see `Run MUnit Testsuite Logging to File`
...
...               Sample see [../examples/run_munit_tests.robot|run_munit_tests]
...
...               These keywords are an extension of [./robot_magik_base.html|robot_magik_base]
...
...               == main workflow ==
...               - setup - load MUnit base classes - `Prepare MUnit` 
...               - load magik module with (MUnit) tests and run test - `Load Module with MUnit Tests and Start Test Runner`
...               - evaluate log file - `Evaluate MUnit Text Log`
...
...               == MUnit Versions ==
...               These keywords are tested against [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit], but other MUnit versions should be used in same way. Define in your variablefile a different ${ROBOT_MUNIT_LOADFILE}.
... 
Resource          robot_magik_base.robot
Library           OperatingSystem

*** Variables ***
${ROBOT_MUNIT_LOADFILE}    ${CURDIR}${/}magik${/}load_opensmallworld_munit_43.magik    # Defines default magik file loading munit base modules and other required base test code - modules with tests should be loaded separately
${ROBOT_MUNIT_LOG_DIR}    ${OUTPUT_DIR}
${ROBOT_MUNIT_MAX_LOAD_WAIT}    20s    # Defines default max wait time for prompt, when loading munit code (files or modules)
${ROBOT_MUNIT_MAX_RUN_WAIT}    30s    # Defines default max wait time for prompt, when running a munit test suite
${ROBOT_MUNIT_LOG_OK_REGEXP}    OK.*(\\d+).*(\\d+).*\\]    # regular expression searching a OK MUnit test result in a text log

*** Keywords ***
Prepare MUnit
    [Arguments]    ${munit_load_file}=${ROBOT_MUNIT_LOADFILE}    ${munit_dir}=
    [Documentation]    Setup for MUnit tests. Loads file ${munit_load_file} to import required MUnit functions and additional required magik functions
    ...
    ...    if ${munit_dir} is defined, environment variable ``ROBOT_MUNIT_DIR`` is set, before loading ${munit_load_file}
    Run Keyword If    '${munit_dir}' != ''    Execute Magik Command    system.putenv("ROBOT_MUNIT_DIR", "${munit_dir}")
    ${out}=    Load Magik File    ${munit_load_file}    max_load_wait=${ROBOT_MUNIT_MAX_LOAD_WAIT}
    [Return]    ${out}

Load Module with MUnit Tests and Start Test Runner
    [Arguments]    ${module_with_tests}    ${log_extension}=log    ${log_dir}=${ROBOT_MUNIT_LOG_DIR}
    [Documentation]    Loads ${module_with_tests} , creates MUnit test suite with all test classes defined in ${module_with_tests} and starts MUnit test runner
    ...
    ...    test runner logs will be written into file in ${munit_log_dir} and returned for separate evaluation.
    ...
    ...    see also `Run Munit Testsuite Logging to File`
    ${out}=    Load Magik Module    ${module_with_tests}    max_load_wait=${ROBOT_MUNIT_MAX_LOAD_WAIT}
    ${swv}=    Get Smallworld Version
    ${testsuite_name}=    Set Variable    ${module_with_tests}_${swv}
    Store Magik Object    ${testsuite_name}    test_suite.new_from_module(:${module_with_tests} )
    ${munit_log_content}=    Run MUnit Testsuite Logging to File    ${testsuite_name}    ${log_extension}    ${log_dir}
    [Return]    ${munit_log_content}

Run MUnit Testsuite Logging to File
    [Arguments]    ${testsuite_name}    ${log_extension}=log    ${log_dir}=${ROBOT_MUNIT_LOG_DIR}    ${max_run_wait}=${ROBOT_MUNIT_MAX_RUN_WAIT}
    [Documentation]    Start test runner for MUnit suite stored in global hash_table with key ${testsuite_name} and logs to file in ${log_dir}.
    ...
    ...    - ${log_extension} defines kind of test runner - *xml_test_runner* is used when _xml_ otherwise (default) *test_runner*
    ...    - log file will include the ${testsuite_name}
    ...
    ...    Waits ${max_run_wait} (e.g. 10s) till test runner must be finished.
    ...
    ...    returns log file \ content for separate evaluation.
    ...
    ...    == Site effect ==
    ...
    ...    extends connection timeout to ${max_run_wait} and switch it back to default ${CLI_TIMEOUT} during the teardown.
    ...
    ...    == Info ==
    ...
    ...    Uses [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit] method *base_test_runner.run‌_in_new_stream()*
    ...
    ...    This creates a new stream and a new runner which is not given back. It is not possible to this runner directly for test results. The log file name must be evaluated for this.
    ${test_runner}=    Set Variable If    '${log_extension}' == 'xml'    xml_test_runner    test_runner
    ${logfile_pattern}=    Set Variable    ${log_dir}${/}*${testsuite_name}*.${log_extension}
    Remove File    ${logfile_pattern}
    ${tsm_exp}=    Build Magik Object Expression    ${testsuite_name}
    ${tr_exp}=    Store Magik Object    tr    ${test_runner}.new(_unset, :output_dir, "${log_dir}", :output_format, "${log_extension}", :output_identifier, "${testsuite_name}" )
    Write Magik Command    ${tr_exp}.run_in_new_stream(${tsm_exp})
    ${out}=    Read Magik Output    ${tr_exp}.run_in_new_stream(${tsm_exp})
    ${munit_log_fname}=    Get MUnit Log File Name from Test Runner Output    ${out}    ${testsuite_name}
    ${munit_log_content}=    Get File    ${munit_log_fname}
    [Teardown]    Set Timeout    ${CLI_TIMEOUT}
    [Return]    ${munit_log_content}

Evaluate MUnit Text Log
    [Arguments]    ${munit_text_log}    ${failure_count}=0    ${error_count}=0    ${testsuite_name}=
    [Documentation]    Ensure, that ${munit_text_log} includes only expected number of errors or failures.
    ...
    ...    Will PASS, when expected number of errors / failures have occured or when no error AND no failure occurs.
    ${result_line_ok}=    Get Lines Matching Regexp    ${munit_text_log}    ${ROBOT_MUNIT_LOG_OK_REGEXP}
    Run Keyword If    '${result_line_ok}'    Set Test Message    *HTML* MUnit reports no failures ${testsuite_name} - ${result_line_ok}<br>    append=${TRUE}
    Run Keyword Unless    '${result_line_ok}'    Should Contain    ${munit_text_log}    Failures: ${failure_count}, \ Errors: ${error_count}    MUnit reports unexpected number of errors / failures ${test_suite_name}

MUnit Text Log ${munit_text_log} for ${testsuite_name} Should Contain ${failure_count} Failures and ${error_count} Errors
    [Documentation]    Alternative keyword definition for `Evaluate MUnit Text Log`
	...
	...    Calling 
	...    | MUnit Text Log ${a_log} for mysuite Should Contain 1 Failures and 2 Errors |
    ...    is equal to calling 
	...    | Evaluate MUnit Text Log | ${a_log} | 1 | 2 | mysuite |
	...
    Evaluate MUnit Text Log    ${munit_text_log}    ${failure_count}    ${error_count}    ${testsuite_name}

Get MUnit Log File Name from Test Runner Output
    [Arguments]    ${trunner_output}    ${testsuite_name}
    [Documentation]    internal keyword, searching in ${trunner_output} the log file name - line including ${testsuite_name}
    ...
    ...    This is required, cause unfortenatly \ [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit] method *base_test_runner.new_stream()* does not store the log file name in a property, it just write it out to the current terminal. And this can be surrounded with same noice. sample
    ...
    ...    | \ "C:\\Temp\\RIDE39_945pl.d\\test__munit_base_tests_4308__test_suite__erebus.log"
    ...    | \ **** Warnung: Changing nature of unset
    ...    | \ \ \ \ \ \ global_changing_nature()
    ...    | \ **** Warnung: unset
    ...    | \ \ \ \ \ \ warning()
    ...    | \ unset
    ...
    ...    Keywords fails , when
    ...    - no line with ${testsuite_name} can be found in ${trunner_output}
    ...    - in ${trunner_output} detected file name does not exist
    ${matching_lines}=    Get Lines Containing String    ${trunner_output}    ${testsuite_name}
    Should Not Be Empty    ${matching_lines}    MUnit Log file name can not be extracted from ${trunner_output}
    ${first_matching_line}=    Get Line    ${matching_lines}    0
    ${munit_log_fname}=    Remove String    ${first_matching_line}    "
    File Should Exist    ${munit_log_fname}
    [Return]    ${munit_log_fname}
