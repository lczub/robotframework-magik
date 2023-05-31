*** Settings ***
Documentation     Test content of extracted Robot Framework Magik archive
...
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
Test Tags        ArchiveTest
Library           OperatingSystem
Library           String

*** Variables ***
${ROBOT_MAGIK_DIR}    ${CURDIR}${/}..${/}..
${ROBOT_MAGIK_COPYRIGHT}    Copyright*2023*Luiko Czub*Smallcases Software GmbH
${ROBOT_MAGIK_LICENSE}    Apache License*2.0


*** Test Cases ***
Test robot magik info files exist in main directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}README.rst
    ${ROBOT_MAGIK_DIR}${/}LICENSE-2.0.txt
    ${ROBOT_MAGIK_DIR}${/}CHANGES.rst

Test robot magik documentation files exist in doc directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}doc${/}robot_magik_base.html
    ${ROBOT_MAGIK_DIR}${/}doc${/}robot_magik_dsview.html
    ${ROBOT_MAGIK_DIR}${/}doc${/}RobotMagikLauncher.html

Test robot magik keyword definitions exist in resources directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}resources${/}robot_magik_base.robot
    ${ROBOT_MAGIK_DIR}${/}resources${/}robot_magik_dsview.robot
    ${ROBOT_MAGIK_DIR}${/}resources${/}RobotMagikLauncher.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}robot_magik_munit.robot
    ${ROBOT_MAGIK_DIR}${/}resources${/}robot_magik_session.robot

Test robot magik start and stop scripts exist in scripts directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts${/}robot_remote_cli.magik
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts${/}start_robot_remote_cli.magik
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts${/}start_robot_remote_cli.script
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts${/}robot_start_magik_image.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts${/}robot_stop_magik_image.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts${/}__init__.py

Test robot magik self tests exist in tests directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords${/}noDB${/}__init__.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords${/}noDB${/}robot_magik_base_tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords${/}withDB${/}robot_magik_dsview_tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords${/}withDB${/}__init__.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords${/}Robot_Magik_Launcher_Dummy_Tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords${/}Robot_Magik_Launcher_Gis_Tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}archive${/}robot_magik_archive_tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts${/}robot_magik_prompt_tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts${/}robot_magik_script_tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts${/}dummy_gis_launcher.py
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts${/}dummy_remote_cli.py

Test robot launcher nested aliases tests exist in tests directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}tests${/}nested_aliases${/}Robot_Magik_Launcher_Nested_Alias_Tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}nested_aliases${/}Robot_Magik_Launcher_Nested_Alias_Cli_Tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}nested_aliases${/}robot_magik_script_tests.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}nested_aliases${/}gis_aliases_sw41
    ${ROBOT_MAGIK_DIR}${/}tests${/}nested_aliases${/}gis_aliases_sw43

Test robot magik examples exist in examples directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}examples${/}__init__.robot
    ${ROBOT_MAGIK_DIR}${/}examples${/}coordinate_tests.robot
    ${ROBOT_MAGIK_DIR}${/}examples${/}cs_collection_tests.robot

Test robot magik default parameter exist in resources directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}resources${/}params${/}variables_sw41_cbg.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}params${/}variables_sw43_cbg.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}params${/}variables_sw51_cbg.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}params${/}variables_sw51_swaf.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}params${/}variables_sw52_cbg.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}params${/}variables_sw52_swaf.py

Test robot magik munit load scripts exist in resources directory
    [Template]    File Should Exist
    ${ROBOT_MAGIK_DIR}${/}resources${/}magik${/}load_opensmallworld_munit_41.magik
    ${ROBOT_MAGIK_DIR}${/}resources${/}magik${/}load_opensmallworld_munit_43.magik
    ${ROBOT_MAGIK_DIR}${/}resources${/}magik${/}load_opensmallworld_munit_52.magik

Test ant build resources not exist
    File Should Not Exist    ${ROBOT_MAGIK_DIR}${/}build.*

Test directory '.git' not exist
    Directory Should Not Exist    ${ROBOT_MAGIK_DIR}${/}.git

Test venv pip install requirements exist
    File Should Exist    ${ROBOT_MAGIK_DIR}${/}requirements.txt

Test robot magik resources includes copyright info
    [Tags]    HeaderTest
    [Template]    Check Header Info for directory
    ${ROBOT_MAGIK_DIR}${/}resources    ${ROBOT_MAGIK_COPYRIGHT}    *.robot
    ${ROBOT_MAGIK_DIR}${/}resources    ${ROBOT_MAGIK_COPYRIGHT}    *.py    2
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords    ${ROBOT_MAGIK_COPYRIGHT}    *.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts    ${ROBOT_MAGIK_COPYRIGHT}    *.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts    ${ROBOT_MAGIK_COPYRIGHT}    *.py
    ${ROBOT_MAGIK_DIR}${/}tests${/}nested_aliases    ${ROBOT_MAGIK_COPYRIGHT}    *.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}archive    ${ROBOT_MAGIK_COPYRIGHT}    *.robot    2
    ${ROBOT_MAGIK_DIR}${/}examples    ${ROBOT_MAGIK_COPYRIGHT}    *.robot
    ${ROBOT_MAGIK_DIR}${/}examples    ${ROBOT_MAGIK_COPYRIGHT}    *.py
    ${ROBOT_MAGIK_DIR}    ${ROBOT_MAGIK_COPYRIGHT}    README.md
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts    ${ROBOT_MAGIK_COPYRIGHT}    *.py
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts    ${ROBOT_MAGIK_COPYRIGHT}    *.magik

Test robot magik resources includes license info
    [Tags]    HeaderTest
    [Template]    Check Header Info for directory
    ${ROBOT_MAGIK_DIR}${/}resources    ${ROBOT_MAGIK_LICENSE}    *.robot
    ${ROBOT_MAGIK_DIR}${/}resources    ${ROBOT_MAGIK_LICENSE}    *.py
    ${ROBOT_MAGIK_DIR}${/}tests${/}keywords    ${ROBOT_MAGIK_LICENSE}    *.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts    ${ROBOT_MAGIK_LICENSE}    *.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts    ${ROBOT_MAGIK_LICENSE}    *.py
    ${ROBOT_MAGIK_DIR}${/}tests${/}nested_aliases    ${ROBOT_MAGIK_LICENSE}    *.robot
    ${ROBOT_MAGIK_DIR}${/}tests${/}archive    ${ROBOT_MAGIK_LICENSE}    *.robot    2
    ${ROBOT_MAGIK_DIR}${/}examples    ${ROBOT_MAGIK_LICENSE}    *.robot
    ${ROBOT_MAGIK_DIR}${/}examples    ${ROBOT_MAGIK_LICENSE}    *.py
    ${ROBOT_MAGIK_DIR}    ${ROBOT_MAGIK_LICENSE}    README.md    2
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts    ${ROBOT_MAGIK_LICENSE}    *.robot
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts    ${ROBOT_MAGIK_LICENSE}    *.py

Test no '*.pyc' should be included
    [Template]    File Should Not Exist
    ${ROBOT_MAGIK_DIR}${/}resources${/}scripts${/}*.pyc
    ${ROBOT_MAGIK_DIR}${/}tests${/}scripts${/}*.pyc

*** Keywords ***
Check Header Info for file
    [Arguments]    ${file_path}    ${header_info}    ${expected_count}=1
    Log    Suche '${header_info}'
    ${info_lines}=    Grep File    ${file_path}    ${header_info}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${info_lines}    Wrong or missing header info in ${file_path}
    ${info_counts}=    Get Line Count    ${info_lines}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${expected_count}    ${info_counts}    Unexpected number of header infos in ${file_path}

Check Header Info for directory
    [Arguments]    ${directory}    ${header_info}    ${file_pattern}=${None}    ${expected_count_per_file}=1
    @{filenames}=    List Files In Directory    ${directory}    ${file_pattern}    True
    FOR    ${fname}    IN    @{filenames}
        Check Header Info for file    ${fname}    ${header_info}    ${expected_count_per_file}
    END
