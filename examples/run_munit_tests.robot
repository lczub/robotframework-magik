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
Documentation     Sample loading , running and evaluating MUnit tests
...
...               To make it runnable, customise your [http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#variable-files|variable files]
...               - ${ROBOT_MUNIT_DIR} - Default [../../OpenSmallworld_munit]
...               - ${ROBOT_MUNIT_LOADFILE} - Default [../resources/magik/load_opensmallworld_munit_43.magik]
Suite Setup       Setup MUnit Session
Suite Teardown    Run Keywords    Clean Magik Image    Close Magik Connection
Force Tags        ExampleTest    MUnitTest
Resource          ../resources/robot_magik_munit.robot

*** Variables ***
${ROBOT_MUNIT_DIR}    ${CURDIR}${/}..${/}..${/}OpenSmallworld_munit

*** Test Cases ***
Load and Run Single Module Test - Text Logging
    [Documentation]    Sample loading and running munit tests defined in module *munit_base_tests* with the *text_runner*
    ...    - the munit output will be stoed in a separated log file \*munit_base_tests_SWVERSION_*.log
    ...
    ...    Expected results - MUnit will report errors and failures. Test should pass with SW43 and fail reporting unexpected numbers of errors / failures.
    ...
    ...    | =Gis Version= | =Failures= | =Errors= |
    ...    | 523 | 0 | 18 |
    ...    | 43 | 4 | 16 |
    ...    | 41 | 0 | 199 |
    ${munit_log_content}=    Load Module with MUnit Tests and Start Test Runner    munit_base_tests
    File Should Exist    ${ROBOT_MUNIT_LOG_DIR}${/}*munit_base_tests*.log
    Evaluate MUnit Text Log    ${munit_log_content}    expected_failures=4    expected_errors=16    testsuite_name=munit_base_tests

Load and Run Single Module Test - XML Logging
    [Documentation]    Sample loading and running munit tests defined in module *munit_base_tests* with the *xml_text_runner*
    ...    - the munit output will be stored in a separated log file \*munit_base_tests_SWVERSION_*.xml
    ...
    ...    Expected results - MUnit will report errors and failures. Test should pass with SW43 and fail reporting unexpected numbers of errors / failures.
    ...
    ...    | =Gis Version= | =Failures= | =Errors= |
    ...    | 523 | 0 | 18 |
    ...    | 43 | 4 | 16 |
    ...    | 41 | 0 | 199 |
    ${munit_log_content}=    Load Module with MUnit Tests and Start Test Runner    munit_base_tests    log_extension=xml
    File Should Exist    ${ROBOT_MUNIT_LOG_DIR}${/}*munit_base_tests*.xml
    Evaluate MUnit XML Log    ${munit_log_content}    4    16    munit_base_tests

Load and Run Multiple Module Tests
    [Documentation]    Sample loading and running multiple modul munit tests via a template. MUnit logs will be deleted, when test passed and stay , when it fails.
    ...
    ...    Each module will be tested twice - with test_runner and xml_test_runner
    ...
    ...    Expected behaviour running in SW523 and SW43
    ...    - all module tests passed - munit log files should be deleted
    ...
    ...    Expected behaviour running in SW41 - it failed
    ...    - magik_mock_test reports 0 failures and 56 errors
    ...    - simple_dataset_test reports 9 failures and 2 errors
    ...    - munit logs should not be deleted
    [Template]    Run Modul Tests and Evaluate Log
    magik_mock_test    0    0
    magik_mock_test    0    0    xml
    simple_dataset_test    0    0
    simple_dataset_test    0    0    xml

*** Keywords ***
Setup MUnit Session
    Open Magik Connection
    Prepare Magik Image
    Prepare MUnit    ${ROBOT_MUNIT_LOAD_FILE}    ${ROBOT_MUNIT_DIR}

Run Modul Tests and Evaluate Log
    [Arguments]    ${module_name}    ${failures_expected}    ${errors_expected}    ${log_type}=log
    [Documentation]    Wrapper defining MUnit workflow _Load Module - Run Tests - Evaluate Log - Delete Log If Passed_ .
    ...
    ...    Used as \ template \ `Load and Run Multiple Module Tests´
    ${munit_log_content}=    Load Module with MUnit Tests and Start Test Runner    ${module_name}    ${log_type}
    Run Keyword Unless    '${log_type}' == 'xml'    Evaluate MUnit Text Log    ${munit_log_content}    ${failures_expected}    ${errors_expected}    ${module_name}
    Run Keyword If    '${log_type}' == 'xml'    Evaluate MUnit XML Log    ${munit_log_content}    ${failures_expected}    ${errors_expected}    ${module_name}
    Delete Current MUnit Log
