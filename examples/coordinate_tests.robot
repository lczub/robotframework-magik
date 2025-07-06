*** Settings ***
Documentation     Example - Test Smallworld Magik coordinates with RobotFramework
...
...               == Licence info ==
...               | Copyright 2012-2025 Luiko Czub, Smallcases Software GmbH
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
Suite Setup       Run Keywords    Open Magik Connection    Prepare Magik Image
Suite Teardown    Run Keywords    Clean Magik Image    Close Magik Connection
Force Tags        ExampleTest    CoordinateTest
Resource          ../resources/robot_magik_base.robot

*** Test Cases ***
Test example - single distance calculation between two coordinates
    Coordinate Distance Should Be    0.0    0.0    3.0    4.0    5.0

Test example - data driven distance calculation between coordinates
    [Template]    Coordinate Distance Should Be
    2.0    4.0    4.0    4.0    2.0
    -2.0    4.0    4.0    4.0    6.0
    -2.0    4.0    4.0    -4.0    10.0

Test example - failure in expected distance calculation between coordinates
    Run Keyword And Expect Error    6.*!= 10.*    Coordinate Distance Should Be    -2.0    4.0    4.0    -4.0
    ...    6.0

*** Keywords ***
Coordinate Distance Should Be
    [Arguments]    ${x1}    ${y1}    ${x2}    ${y2}    ${distance_exp}
    [Documentation]    Calculates the distance between to coordinates
    ${obj_c1}=    Store Magik Object    c1    coordinate.new(${x1}, ${y1})
    ${obj_c2}=    Store Magik Object    c2    coordinate.new(${x2}, ${y2})
    ${distance_calc}=    Execute Magik Command    ${obj_c1}.distance_to(${obj_c2})
    Should Be Equal as Numbers    ${distance_exp}    ${distance_calc}
