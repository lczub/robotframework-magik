#  Copyright 2012-2021 Luiko Czub, Smallcases Software GmbH
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
Documentation     Example - Test Smallworld coordinate system collection with RobotFramework
...
...               Uses dataset, defined in ${CLI_DSVIEW_NAME}
Suite Setup       Run Keywords    Open Magik Connection    Prepare Magik Image    Get DsView
Suite Teardown    Run Keywords    Rollback DsView    Clean Magik Image    Close Magik Connection
Force Tags        ExampleTest    CoordinateTest    DsViewTest
Resource          ../resources/robot_magik_dsview.robot

*** Test Cases ***
Test example - Get coordinate_system collection
    ${coll_cs}=    Get DsCollection    sw_gis!coordinate_system

Test example - Get coordinate_system record wgs84
    ${a_cs_rec}=    Get Record With Predicate    sw_gis!coordinate_system    predicate.wild(:name, "*longlat_wgs84*")
    ${cs_name}=    Execute Magik Command    ${a_cs_rec}.name
    Should Contain    ${cs_name}    world_longlat_wgs84_degree
    ${cs_id}=    Execute Magik Command    ${a_cs_rec}.abbrev
    Should Contain    ${cs_id}    EPSG:4326
