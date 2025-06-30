#  Copyright 2012-2023 Luiko Czub, Smallcases Software GmbH
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
Documentation     Test Robot Framework Magik keywords for Smallworld ds_views and ds_collections
...
...               Tests base dataset, alternative and collection access in a smallworld open image
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
Suite Setup       Run Keywords    Open Magik Connection    Prepare Magik Image
Suite Teardown    Run Keywords    Clean Magik Image    Close Magik Connection
Force Tags        KeywordTest    DsViewTest
Resource          ../../../resources/robot_magik_dsview.robot

*** Test Cases ***
Test keyword 'Get DsView' for ace view
    ${a_view}=    Get DsView    ace
    ${vname}=    Execute Magik Command    ${a_view}.name
    Should Be Equal    ${vname}    :|ACE|

Test keyword 'Get DsView' for style view
    ${a_view}=    Get DsView    style
    ${vname}=    Execute Magik Command    ${a_view}.name
    Should Be Equal    ${vname}    :|Style|

Test keyword 'Get DsView' for gis view
    ${a_view}=    Get DsView    gis
    ${vname}=    Execute Magik Command    ${a_view}.name
    Should Be Equal    ${vname}    :gis

Test keyword 'Get DsView' for default view
    ${a_view}=    Get DsView
    ${vname}=    Execute Magik Command    ${a_view}.name
    Should Be Equal    ${vname}    :${CLI_DSVIEW_NAME}

Test keyword 'Get DsView' with non default objkey
    ${objhash_expression}=    Get DsView    gis    BigBird
    Should Contain    ${objhash_expression}    BigBird
    ${vname}=    Execute Magik Command    ${objhash_expression}.name
    Should Be Equal    ${vname}    :gis

Test keyword 'Get DsCollection' for sw_gis!ace collection
    ${a_coll}=    Get DsCollection    sw_gis!ace    ace
    ${cname}=    Execute Magik Command    ${a_coll}.name
    Should Be Equal    ${cname}    :sw_gis!ace
    ${ctype}=    Get Magik Object    sw_gis!ace
    Should Contain    ${ctype}    ds_collection

Test keyword 'Get DsCollection' with non default objkey
    ${objhash_expression}=    Get DsCollection    sw_gis!ace    ace    BigBirdAce
    Should Contain    ${objhash_expression}    BigBirdAce
    ${cname}=    Execute Magik Command    ${objhash_expression}.name
    Should Be Equal    ${cname}    :sw_gis!ace
    ${ctype}=    Get Magik Object    BigBirdAce
    Should Contain    ${ctype}    ds_collection

Test keyword 'Get SelectCollection' for sw_gis!ace collection
    ${objhash_expression}=    Get SelectCollection    sw_gis!ace    predicate.eq(:name, 'default')
    Should Contain    ${objhash_expression}    sw_gis!ace_s
    ${cname}=    Execute Magik Command    ${objhash_expression}.name
    Should Be Equal    ${cname}    :sw_gis!ace
    ${ctype}=    Get Magik Object    sw_gis!ace_s
    Should Contain    ${ctype}    select_collection

Test keyword 'Get SelectCollection' with non default objkey
    ${objhash_expression}=    Get SelectCollection    sw_gis!ace    predicate.eq(:name, 'default')    BigBirdAce
    Should Contain    ${objhash_expression}    BigBirdAce
    ${cname}=    Execute Magik Command    ${objhash_expression}.name
    Should Be Equal    ${cname}    :sw_gis!ace
    ${ctype}=    Get Magik Object    BigBirdAce
    Should Contain    ${ctype}    select_collection

Test keyword 'Get Record' for sw_gis!ace collection
    ${an_ace}=    Get Record    sw_gis!ace
    ${an_ace_name}=    Execute Magik Command    ${an_ace}.name
    Should Not Be Empty    ${an_ace_name}

Test keyword 'Get Record' with non default objkey
    ${objhash_expression}=    Get Record    sw_gis!ace    BigBird
    Should Contain    ${objhash_expression}    BigBird
    ${an_ace_name}=    Execute Magik Command    ${objhash_expression}.name
    Should Not Be Empty    ${an_ace_name}

Test keyword 'Get Record With Predicate' for sw_gis!ace collection
    ${special_ace}=    Get Record With Predicate    sw_gis!ace    predicate.eq(:name, 'default')
    ${special_ace_name}=    Execute Magik Command    write(${special_ace}.name)
    Should Be Equal    ${special_ace_name}    Default
    ${scoll}=    Build Magik Object Expression    sw_gis!ace_s
    ${scoll_size}=    Execute Magik Command    ${scoll}.size
    Should Be Equal as Integers    1    ${scoll_size}

Test keyword 'Get Record With Predicate' with non default objkey
    Store Magik Object    sw_gis!ace_s    _unset
    ${objhash_expression}=    Get Record With Predicate    sw_gis!ace    predicate.eq(:name, 'Default')    BigBird
    Should Contain    ${objhash_expression}    BigBird
    ${special_ace_name}=    Execute Magik Command    write(${objhash_expression}.name)
    Should Be Equal    ${special_ace_name}    Default
    ${scoll}=    Build Magik Object Expression    sw_gis!ace_s
    ${scoll_size}=    Execute Magik Command    ${scoll}.size
    Should Be Equal as Integers    1    ${scoll_size}

Test keyword 'Rollback DsView'
    Rollback DsView    gis

Test keyword 'Report Datamodel History'
    ${report_fname_gis}=    Report Datamodel History    gis
    Should Match    ${report_fname_gis}    *_gis.txt
    File Should Exist    ${report_fname_gis}
    ${report_fname_ace}=    Report Datamodel History    ace
    Should Match    ${report_fname_ace}    *_ace.txt
    File Should Exist    ${report_fname_ace}
    ${history_gis}=    Get File    ${report_fname_gis}
    ${history_ace}=    Get File    ${report_fname_ace}
    ${history_gis_install}=    Get Lines Containing String    ${history_gis}    Install
    ${history_ace_install}=    Get Lines Containing String    ${history_ace}    Install
    Should Not Be Equal As Strings    ${history_gis_install}    ${history_ace_install}

Test keyword 'Get DsView' for auth view
    ${a_view}=    Get DsView    authorisation
    ${vname}=    Execute Magik Command    ${a_view}.name
    Should Be Equal    ${vname}    :|Auth|

Test keyword 'Get Datamodel History Entry' for datamodel_history
    ${histo_rec_expr}=    Get Datamodel History Entry    sw_kernel    datamodel_history    Install    gis
    ${histo_rec_mod_name}=    Execute Magik Command    write(${histo_rec_expr}.mod_name)
    Should Be Equal    ${histo_rec_mod_name}    ds_src

Test keyword 'Datamodel History Entry Should Exist'
    Datamodel History Entry Should Exist    sw_kernel    datamodel_history    Install    gis
    Run Keyword And Expect Error    History record*sw_KEMAL*Install    Datamodel History Entry Should Exist    sw_KEMAL    datamodel_history    Install    gis
