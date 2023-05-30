*** Settings ***
Documentation     Robot Framework Magik keywords for testing Smallworld ds_views, ds_collections and rwo records.
...
...               Sample see [../examples/cs_collection_tests.robot|cs_collection_tests]
...
...               These keywords are an extension of [./robot_magik_base.html|robot_magik_base]
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
Resource          robot_magik_base.robot
Library           OperatingSystem

*** Variables ***
${CLI_DSVIEW_NAME}    gis

*** Keywords ***
Get DsView
    [Arguments]    ${dsview_name}=${CLI_DSVIEW_NAME}    ${objkey}=default
    [Documentation]    Returns expression for the ds_view _dsview_name_
    ...
    ...    - _dsview_name_ == *ace*, *style* or *authorisation* will return the ace|style|auth view
    ...    - other _dsview_name_ will return the named dataset view
    ...    - Default _dsview_name_ is ${CLI_DSVIEW_NAME}
    ...
    ...    === Side effect ===
    ...    ds_view _dsview_name_ is stored inside the global ${CLI_OBJ_HASH}
    ...    under the key _objkey_. (Default = _dsview_name_)
    ${objkey}    Set Variable If    '${objkey}'=='default'    ${dsview_name}    ${objkey}
    ${command}    Set Variable If    '${dsview_name}' in ('ace', 'style', 'authorisation')     ${dsview_name}_view    cached_dataset(:${dsview_name})
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

Report Datamodel History
    [Arguments]    ${dsview_name}=${CLI_DSVIEW_NAME}    ${fname}=datamodel_history_${dsview_name}.txt    ${report_dir}=${OUTPUT DIR}
    [Documentation]    Writes list with existing :sw_gis!datamodel_history of dataset ${dsview_name} to file
    ${view}=    Get DsView    ${dsview_name}
    ${histo_coll}=    Get DsCollection    sw_gis!datamodel_history    ${dsview_name}    histo_${dsview_name}
    ${report_fname_full}=    Set Variable    ${report_dir}${/}${fname}
    ${view_search_path}=    Execute Magik Command    ${view}.searchpath[1]
    ${header_info}=    Set Variable    View: ${dsview_name} - :sw_gis!datamodel_history entries\nSearchpath: ${view_search_path}\n\n
    Write Magik Command    _for dh _over ${histo_coll}.fast_elements() _loop write(dh.product_name, %tab, dh.mod_name, %tab, dh.datamodel_name, %tab, dh.version, %tab, dh.sub_datamodel_name) _endloop
    ${out1}=    Read Magik Output
    ${checkpoint_list}=    Remove String Using Regexp    ${out1}    \\S+:\\d+:(MagikSF|Magik)>
    Create File    ${report_fname_full}    ${header_info}${checkpoint_list}
    [Return]    ${report_fname_full}

Get Datamodel History Entry
    [Arguments]    ${product}    ${model}    ${sub_model}    ${dsview_name}=${CLI_DSVIEW_NAME}
    [Documentation]    Returns expression for \ Datamodel History record, matching criteria ${product} & \ ${model} \ & ${sub_model}
    ...
    ...    Search criteria
    ...    | param | histo attribut |
    ...    | ${product} | .product_name |
    ...    | ${model} \ | \ .datamodel_name |
    ...    | ${sub_model} \ | \ .sub_datamodel_name |
    ...
    ${histo_key}=    Set Variable    histo_${dsview_name}
    ${histo_pred}=    Set Variable    predicate.eq(:product_name, "${product}") _and predicate.eq(:datamodel_name, "${model}" ) _and predicate.eq(:sub_datamodel_name, "${sub_model}")
    Get DsView    ${dsview_name}
    Get DsCollection    sw_gis!datamodel_history    ${dsview_name}    ${histo_key}
    ${rec_expr}=    Get Record With Predicate    ${histo_key}    ${histo_pred}    ${histo_key}_rec
    [Return]    ${rec_expr}

Datamodel History Entry Should Exist
    [Arguments]    ${product}    ${model}    ${sub_model}    ${dsview_name}=${CLI_DSVIEW_NAME}
    [Documentation]    Checks \ Datamodel History record exist, matching criteria ${product} & \ ${model} \ & ${sub_model}
    ...
    ...    Search criteria
    ...    | param | histo attribut |
    ...    | ${product} | .product_name |
    ...    | ${model} \ | \ .datamodel_name |
    ...    | ${sub_model} \ | \ .sub_datamodel_name |
    ...
    ${histo_rec_expr}=    Get Datamodel History Entry    ${product}     ${model}    ${sub_model}     ${dsview_name}
    ${output}=    Execute Magik Command    ${histo_rec_expr}
    Should Match    ${output}    sw_gis!datamodel_history*${model}*${sub_model})    History record not found in <${dsview_name}>: ${product} - ${model} - ${sub_model}    values=${False}
    [Return]    ${output}
