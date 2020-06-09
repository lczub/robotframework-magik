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
Documentation     Robot Framework Magik keywords running OpenSmallworld MUnit tests
...
...               These keywords are tested against [https://github.com/OpenSmallworld/munit|OpenSmallworld MUnit],
Resource          robot_magik_base.robot
Library           OperatingSystem

*** Variables ***
${ROBOT_MUNIT_LOADFILE}    ${CURDIR}${/}magik${/}load_opensmallworld_munit_43.magik    # Defines default magik file loading munit base modules and other required base test code - modules with tests should be loaded separately
${ROBOT_MUNIT_LOG_DIR}    ${OUTPUT_DIR}
${ROBOT_MUNIT_MAX_LOAD_WAIT}    20s    # Defines default max wait time for prompt, when loading munit code (files or modules)

*** Keywords ***
Prepare MUnit
    [Arguments]    ${munit_load_file}=${ROBOT_MUNIT_LOADFILE}    ${munit_dir}=
    [Documentation]    Setup for MUnit tests. Loads file ${munit_load_file} to import required MUnit functions and additional required magik functions
    ...
    ...    if ${munit_dir} is defined, environment variable ``ROBOT_MUNIT_DIR`` is set, before loading ${munit_load_file}

    Run Keyword If    '${munit_dir}' != ''    Execute Magik Command    system.putenv("ROBOT_MUNIT_DIR", "${munit_dir}")
    ${out}=    Load Magik File    ${munit_load_file}    max_load_wait=${ROBOT_MUNIT_MAX_LOAD_WAIT}
    [Return]    ${out}

Load Module and Run MUnit Tests
    [Arguments]    ${module_with_tests}    ${munit_log_dir}=${ROBOT_MUNIT_LOG_DIR}
    [Documentation]    Loads ${module_with_tests} , creates MUnit test suite with all test classes defined in ${module_with_tests} and starts MUnit test runner.
    ...
    ...    test runner output will be written into log file in ${munit_log_dir}
    ${swv}=    Execute Magik Command    write(smallworld_product.sw!version.write_string)
    ${tid}=    Set Variable    ${module_with_tests}${swv}
    ${log_extension}=    Set Variable    log
    ${logfile_pattern}=    Set Variable    ${munit_log_dir}${/}*${tid}*.${log_extension}
    Remove File    ${logfile_pattern}
    ${out}=    Load Magik Module    ${module_with_tests}    max_load_wait=${ROBOT_MUNIT_MAX_LOAD_WAIT}
    ${tsm_exp}=    Store Magik Object    tsm    test_suite.new_from_module(:${module_with_tests} )
    ${tr_exp}=    Store Magik Object    tr    test_runner.new(_unset, :output_dir, "${munit_log_dir}", :output_format, "${log_extension}", :output_identifier, "${tid}" )
    ${out}=    Execute Magik Command    ${tr_exp}.run_in_new_stream(${tsm_exp})
    ${munit_log_file}=    Remove String    ${out}    "
    File Should Exist    ${munit_log_file}
    ${munit_log_content}=    Get File    ${munit_log_file}
    Should Not Contain    ${munit_log_content}    errors    Unexpected errors in ${munit_log_file}
    Should Not Contain    ${munit_log_content}    failures    Unexpected failures in ${munit_log_file}
