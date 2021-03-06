#  Copyright 2012-2020 Luiko Czub, Smallcases Software GmbH
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
Documentation     Robot Framework Magik keywords for testing Smallworld ds_views, ds_collections and rwo records.
...
...               Sample see [../examples/cs_collection_tests.robot|cs_collection_tests]
...
...               These keywords are an extension of [./robot_magik_base.html|robot_magik_base]
...
Resource          robot_magik_base.robot

*** Variables ***
${CLI_DSVIEW_NAME}    gis

*** Keywords ***
Get DsView
    [Arguments]    ${dsview_name}=${CLI_DSVIEW_NAME}    ${objkey}=default
    [Documentation]    Returns expression for the ds_view _dsview_name_
    ...
    ...    - _dsview_name_ == *ace* or *style* will return the ace|style view
    ...    - other _dsview_name_ will return the named dataset view
    ...    - Default _dsview_name_ is ${CLI_DSVIEW_NAME}
    ...
    ...    === Side effect ===
    ...    ds_view _dsview_name_ is stored inside the global ${CLI_OBJ_HASH}
    ...    under the key _objkey_. (Default = _dsview_name_)
    ${objkey}    Set Variable If    '${objkey}'=='default'    ${dsview_name}    ${objkey}
    ${command}    Set Variable If    '${dsview_name}'=='ace' or '${dsview_name}'=='style'    ${dsview_name}_view    cached_dataset(:${dsview_name})
    ${dsview_expr}=    Store Magik Object    ${objkey}    gis_program_manager.${command}
    [Return]    ${dsview_expr}

Rollback DsView
    [Arguments]    ${dsview_name}=${CLI_DSVIEW_NAME}
    [Documentation]    Rollback changes on dsview _dsview_name_
    ${a_view}=    Get DsView    ${dsview_name}
    Execute Magik Command    ${a_view}.rollback()

Get DsCollection
    [Arguments]    ${dscoll_name}    ${dsview_name}=${CLI_DSVIEW_NAME}    ${objkey}=default
    [Documentation]    Returns expression for the ds_collection _dscoll_name_
    ...
    ...    - Search the collection inside the dsview _dsview_name_
    ...    - Default _dsview_name_ is ${CLI_DSVIEW_NAME}
    ...
    ...    === Side effect ===
    ...    ds_collection _dscoll_name_ is stored inside the global ${CLI_OBJ_HASH}
    ...    under the key _objkey_. (Default = _dscoll_name_)
    ...
    ...    === Precondition ===
    ...    `Get DsView` must be called one time before for _dsview_name_,
    ...    so that it is stored (known) inside the global ${CLI_OBJ_HASH}
    ${objkey}    Set Variable If    '${objkey}'=='default'    ${dscoll_name}    ${objkey}
    ${dsview_expr}=    Build Magik Object Expression    ${dsview_name}
    ${dscoll_expr}=    Store Magik Object    ${objkey}    ${dsview_expr}.collections[:${dscoll_name}]
    [Return]    ${dscoll_expr}

Get SelectCollection
    [Arguments]    ${coll_name}    ${predicate}    ${objkey}=default
    [Documentation]    Returns expression for selection of collection _coll_name_ with _predicate_
    ...
    ...    === Side effect ===
    ...    select_collection _coll_name_ with _predicate_ is stored inside the global ${CLI_OBJ_HASH}
    ...    under the key _objkey_. (Default = _coll_name_s_)
    ...
    ...    === Precondition ===
    ...    `Get DsCollection` or `Get SelectCollection` must be called one time before for _coll_name_,
    ...    so that it is stored (known) inside the global ${CLI_OBJ_HASH}
    ${objkey}    Set Variable If    '${objkey}'=='default'    ${coll_name}_s    ${objkey}
    ${coll_expr}=    Build Magik Object Expression    ${coll_name}
    ${coll_expr_s}=    Store Magik Object    ${objkey}    ${coll_expr}.select(${predicate})
    [Return]    ${coll_expr_s}

Get Record
    [Arguments]    ${coll_name}    ${objkey}=a_rec
    [Documentation]    Returns expression for record from collection _coll_name_
    ...
    ...    - Selects first found record from _coll_name_
    ...
    ...    === Side effect ===
    ...    the record is stored inside the global ${CLI_OBJ_HASH}
    ...    under the key _objkey_. (Default = a_rec)
    ...
    ...    === Precondition ===
    ...    `Get DsCollection` or `Get SelectCollection` must be called one time before for _coll_name_,
    ...    so that it is stored (known) inside the global ${CLI_OBJ_HASH}
    ${coll_expr}=    Build Magik Object Expression    ${coll_name}
    ${rec_expr}=    Store Magik Object    ${objkey}    ${coll_expr}.an_element()
    [Return]    ${rec_expr}

Get Record With Predicate
    [Arguments]    ${coll_name}    ${predicate}    ${objkey}=a_pred_rec
    [Documentation]    Returns expression for record from selection of collection _coll_name_ with _predicate_
    ...
    ...    === Side effect A ===
    ...    Calls `Get SelectCollection` to build the select_collection _coll_name_ with _predicate_
    ...    This will stored it inside the global ${CLI_OBJ_HASH} with the default key (_coll_name_s_)
    ...
    ...    === Side effect B ===
    ...    the record is stored inside the global ${CLI_OBJ_HASH}
    ...    under the key _objkey_. (Default = a_pred_rec)
    ...
    ...    === Precondition ===
    ...    `Get DsCollection` or `Get SelectCollection` must be called one time before for _coll_name_,
    ...    so that it is stored (known) inside the global ${CLI_OBJ_HASH}
    ${coll_expr}=    Get SelectCollection    ${coll_name}    ${predicate}
    ${rec_expr}=    Store Magik Object    ${objkey}    ${coll_expr}.an_element()
    [Return]    ${rec_expr}
