*** Settings ***
Documentation     Example - Initialization file starting a Magik Session as Suite Setup and closing this Magik Session as Teardown
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
Suite Setup       Auto Start Magik Session    swproduct=${SWPRODUCT}    cli_port=${CLI_PORT}    wait=${START_WAIT}    java_home=${JAVA_HOME}    aliasfile=${ALIASFILE}    gis_alias=${ALIASNAME}    msf_startup=${MSFSTARTUP}    login=${LOGIN}
Suite Teardown    Auto Stop Magik Session
Library           Process
Variables         ../resources/params/variables_sw43_cbg.py
Resource          ../resources/robot_magik_session.robot

*** Keywords ***
