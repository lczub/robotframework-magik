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
Load and Run Single Module Test
    Load Module and Run MUnit Tests    simple_dataset_test

*** Keywords ***
Setup MUnit Session
    Open Magik Connection
    Prepare Magik Image
    Prepare MUnit    ${ROBOT_MUNIT_LOAD_FILE}    ${ROBOT_MUNIT_DIR}
