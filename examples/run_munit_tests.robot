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
    ...
    ...
    ${munit_log_content}=    Load Module with MUnit Tests and Start Test Runner    munit_base_tests
    File Should Exist    ${ROBOT_MUNIT_LOG_DIR}${/}*munit_base_tests*.log
    Evaluate MUnit Text Log    ${munit_log_content}    failure_count=4    error_count=16    testsuite_name=munit_base_tests

Load and Run Single Module Test - XML Logging
    [Documentation]    Sample loading and running munit tests defined in module *munit_base_tests* with the *xml_text_runner*
    ...    - the munit output will be stored in a separated log file \*munit_base_tests_SWVERSION_*.xml
    ${munit_log_content}=    Load Module with MUnit Tests and Start Test Runner    munit_base_tests    log_extension=xml
    File Should Exist    ${ROBOT_MUNIT_LOG_DIR}${/}*munit_base_tests*.log

Load and Run Multiple Module Tests - Text Logging
    [Documentation]    Sample loading and running multiple modul munit tests
    ...
    ...    Expected behaviour running in SW523 and SW43
    ...    - all module tests passed
    ...
    ...    Expected behaviour running in SW41 - it failed
    ...    - magik_mock_test reports 0 failures and 56 errors
    ...    - simple_dataset_test reports 9 failures and 2 errors
    [Template]    Run Modul Tests and Evaluate Text Log
    magik_mock_test    0    0
    simple_dataset_test    0    0

*** Keywords ***
Setup MUnit Session
    Open Magik Connection
    Prepare Magik Image
    Prepare MUnit    ${ROBOT_MUNIT_LOAD_FILE}    ${ROBOT_MUNIT_DIR}

Run Modul Tests and Evaluate Text Log
    [Arguments]    ${module_name}    ${failures_expected}    ${errors_expected}
    ${munit_log_content}=    Load Module with MUnit Tests and Start Test Runner    ${module_name}
    MUnit Text Log ${munit_log_content} for ${module_name} Should Contain ${failures_expected} Failures and ${errors_expected} Errors
