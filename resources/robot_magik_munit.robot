*** Settings ***
Documentation     === Robot Framework Magik keywords running and evaluating MUnit tests ===
...
...               MUnit results are logged to separated files. Robot report includes for failed MUnit test runs \ link to open the log file.
...
...               These keywords are tested against [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit], but other MUnit versions should be usable in same way.
...
...               == Sample Workflow ==
...               - load MUnit base classes - `Prepare MUnit` (suite setup )
...               - load magik module with (MUnit) tests and run test - `Load Module with MUnit Tests and Start Test Runner`
...               - evaluate log file - `Evaluate MUnit Text Log`, `Evaluate MUnit XML Log`
...
...               Sample see [../examples/run_munit_tests.robot|run_munit_tests]
...
...               == Used MUnit Runner ==
...
...               MUnit test runs are started using *A_RUNNER.run‌_in_new_stream()*. Results are written directly into a log file. Content of this log file will be evaluated by Robot . The log file themself can be directly deleted afterwards by Robot, or keeped for further error analysis or import into test management tools.
...
...               Currently supported runner
...               - *test_runner* - simple text output, documents failed test and error with full tracebacks, good for error analysis
...               - \ *xml_test_runner* - creates [https://llg.cubic.org/docs/junit/|JUnit XML reporting file format] - documents each munit testcase with its status
...
...               Unsupported (future task):
...               - filter tests to run by MUnit aspects
...
...               == Customisations ==
...
...               Use [http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#variable-files|variable files] to customize the MUnit keywords. Sample see [../resources/params/variables_sw43_cbg.py|resources/params/variables_sw43_cbg.py]
...
...               *Loading other MUnit Product and / or additional test code*
...               - Define a load file like \ [../resources/magik/load_opensmallworld_munit_43.magik|resources/magik/load_opensmallworld_munit_43.magik] and adjust ``${ROBOT_MUNIT_LOADFILE}`` in variable file
...
...               *Timeout, when Loading MUnit Product / test code \ - `Prepare MUnit`*
...               - define / extend ``${ROBOT_MUNIT_MAX_LOAD_WAIT}`` in variable file
...
...               *Timeout, when Running MUnit Tests - `Run MUnit Testsuite Logging to File`*
...               - if several tests affected, define / extend \ ``${ROBOT_MUNIT_MAX_RUN_WAIT}`` in variable file
...               - if just one test affected, assign specific ``${max_run_wait}`` argument, when test calls the keyword
...
...               == Licence info ==
...               | Copyright 2020-2023 Luiko Czub, Smallcases Software GmbH
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
Resource          robot_magik_base.robot
Library           OperatingSystem
Library           XML

*** Variables ***
${ROBOT_MUNIT_LOADFILE}    ${CURDIR}${/}magik${/}load_opensmallworld_munit_43.magik    # Defines default magik file loading munit base modules and other required base test code - modules with tests should be loaded separately
${ROBOT_MUNIT_LOG_DIR}    ${OUTPUT_DIR}
${ROBOT_MUNIT_MAX_LOAD_WAIT}    20s    # Defines default max wait time for prompt, when loading munit code (files or modules)
${ROBOT_MUNIT_MAX_RUN_WAIT}    30s    # Defines default max wait time for prompt, when running a munit test suite
${ROBOT_MUNIT_LOG_OK_REGEXP}    OK.*(\\d+).*(\\d+).*\\]    # regular expression searching a OK MUnit test result in a text log
${ROBOT_MUNIT_LOG_KO_REGEXP}    Tests run: (\\d+).*(\\d+).*(\\d+).*(\\d+)


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
    ...    test runner results will be written into log file in ${munit_log_dir} and returned for separate evaluation.
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
    ...    extends connection timeout to ${max_run_wait} and switch it back to default ``${CLI_TIMEOUT}`` during the teardown.
    ...
    ...    == Info ==
    ...
    ...    Uses [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit] method *A_RUNNER.run‌_in_new_stream()*
    ...
    ...    This creates a new stream and a new runner which is not given back. It is not possible to this runner directly for test results. The log file name must be evaluated for this.
    ${test_runner}=    Set Variable If    '${log_extension}' == 'xml'    xml_test_runner    test_runner
    ${logfile_pattern}=    Set Variable    ${log_dir}${/}*${testsuite_name}*.${log_extension}
    Remove File    ${logfile_pattern}
    ${tsm_exp}=    Build Magik Object Expression    ${testsuite_name}
    ${tr_exp}=    Store Magik Object    tr    ${test_runner}.new(_unset, :output_dir, "${log_dir}", :output_format, "${log_extension}", :output_identifier, "${testsuite_name}" )
    Set Timeout    ${max_run_wait}
    Write Magik Command    ${tr_exp}.run_in_new_stream(${tsm_exp})
    ${out}=    Read Magik Output    ${tr_exp}.run_in_new_stream(${tsm_exp})
    ${munit_log_fname}=    Get MUnit Log File Name from Test Runner Output    ${out}    ${testsuite_name}
    ${munit_log_content}=    Get File    ${munit_log_fname}
    [Teardown]    Set Timeout    ${CLI_TIMEOUT}
    [Return]    ${munit_log_content}

Get MUnit Log File Name from Test Runner Output
    [Arguments]    ${trunner_output}    ${testsuite_name}
    [Documentation]    internal keyword, searching in ${trunner_output} the log file name - line including ${testsuite_name}
    ...
    ...    The file name will be returned \ and is stored as test variable ``${CURRENT_MUNIT_LOG_FNAME}`` (see `Delete Current MUnit Log`).
    ...
    ...    Keywords fails , when
    ...    - no line with ${testsuite_name} can be found in ${trunner_output}
    ...    - in ${trunner_output} detected file name does not exist
    ...
    ...    === Remarks ===
    ...
    ...    unfortunately \ \ [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit] method *base_test_runner.new_stream()* does not store the log file name in a property, it just write it out to the current terminal. And this can be surrounded with same noice. Sample
    ...
    ...    | \ "C:\\Temp\\RIDE39_945pl.d\\test__munit_base_tests_4308__test_suite__erebus.log"
    ...    | \ **** Warnung: Changing nature of unset
    ...    | \ \ \ \ \ \ global_changing_nature()
    ...    | \ **** Warnung: unset
    ...    | \ \ \ \ \ \ warning()
    ...    | \ unset
    ${matching_lines}=    Get Lines Containing String    ${trunner_output}    ${testsuite_name}
    Should Not Be Empty    ${matching_lines}    MUnit Log file name can not be extracted from ${trunner_output}
    ${first_matching_line}=    Get Line    ${matching_lines}    0
    ${munit_log_fname}=    Remove String Using Regexp    ${first_matching_line}    (^")|("\\s*$)
    File Should Exist    ${munit_log_fname}
    Set Test Variable    ${CURRENT_MUNIT_LOG_FNAME}    ${munit_log_fname}
    ${log_path_parts}=    Split Path    ${munit_log_fname}
    ${log_fname_parts}=    Split Extension    ${log_path_parts}[1]
    ${log_ex_name}=    Set Variable If    'xml' in '${log_fname_parts}[1]'    MUnit xml log    MUnit text log
    Set Test Variable    ${CURRENT_MUNIT_LOG_LINK}    <a href="./${log_path_parts}[1]">${log_ex_name}</a>
    [Return]    ${munit_log_fname}

Evaluate MUnit Text Log
    [Arguments]    ${munit_text_log}    ${expected_failures}=0    ${expected_errors}=0    ${testsuite_name}=
    [Documentation]    Ensure, that ${munit_text_log} includes only expected number of errors or failures.
    ...
    ...    Will PASS, when expected number of errors / failures have occured or when no error AND no failure occured.
    ${result_line_ok}=    Get Lines Matching Regexp    ${munit_text_log}    ${ROBOT_MUNIT_LOG_OK_REGEXP}
    ${result_line_failures}=    Get Lines Matching Regexp    ${munit_text_log}    ${ROBOT_MUNIT_LOG_KO_REGEXP}
    ${results_count_ok}=    Get Regexp Matches    ${result_line_ok}    (\\d+)
    ${results_count_failures}=    Get Regexp Matches    ${result_line_failures}    (\\d+)
    Run Keyword If    ${results_count_failures}    Should Be True    ${results_count_failures}[2] == ${expected_failures} and ${results_count_failures}[3] == ${expected_errors}    *HTML* ${test_suite_name} unexpected number of errors / failures in ${CURRENT_MUNIT_LOG_LINK} - ${result_line_failures}
    Run Keyword If    ${results_count_failures}    Set Test Message    *HTML* MUnit reports expected failures ${testsuite_name} - ${result_line_failures}<br>    append=${TRUE}
    Run Keyword If    ${results_count_ok}    Set Test Message    *HTML* MUnit results OK ${testsuite_name} - ${result_line_ok}<br>    append=${TRUE}

Evaluate MUnit XML Log
    [Arguments]    ${munit_xml_log}    ${expected_failures}=0    ${expected_errors}=0    ${testsuite_name}=
    [Documentation]    Ensure, that ${munit_xml_log} includes only expected number of failed testcases.
    ...
    ...    Will FAIL, when ${munit_xml_log} includes
    ...    - no testcase OR no passed testcase OR \ number of failed testcases is not expected
    ${count_testcases}=    Get Element Count    ${munit_xml_log}    */testcase
    ${count_passed}=    Get Element Count    ${munit_xml_log}    */testcase[@status="Passed"]
    Should Be True    ${count_testcases} > 0    ${test_suite_name} no testcases found in MUnit xml log
    Should Be True    ${count_passed} > 0    *HTML* ${test_suite_name} no passed testcases found in ${CURRENT_MUNIT_LOG_LINK}
    ${count_errors}=    Get Element Count    ${munit_xml_log}    */testcase/error
    ${count_failures}=    Get Element Count    ${munit_xml_log}    */testcase/failure
    Should Be True    ${expected_failures} == ${count_failures} and ${expected_errors} == ${count_errors}    *HTML* ${test_suite_name} unexpected number of \ ${count_errors} errors and ${count_failures} failures \ in ${CURRENT_MUNIT_LOG_LINK}
    Set Test Message    *HTML* \ MUnit results OK \ ${test_suite_name} - \ ${count_testcases} testcases - ${count_errors} errors - \ ${count_failures} failures<br>    append=${TRUE}

Delete Current MUnit Log
    [Documentation]    Deletes MUnit Log File, stored in test variable ``${CURRENT_MUNIT_LOG_FNAME}``.
    ...
    ...    Can be used in test teardown, e.g. in combination with _Run Keyword If Test Failed_ .
    ...
    ...    see also `Get MUnit Log File Name from Test Runner Output`
    Run Keyword And Ignore Error    Remove File    ${CURRENT_MUNIT_LOG_FNAME}
    Set Test Variable    ${CURRENT_MUNIT_LOG_LINK}    ${EMPTY}
    [Teardown]    Set Test Variable    ${CURRENT_MUNIT_LOG_FNAME}    ${EMPTY}
