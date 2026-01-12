#! /usr/bin/python
# -*- coding: UTF-8 -*-

# ------------------------------------------------------------------------
#  Copyright 2025     Luiko Czub, Smallcases Software GmbH
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
#
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# variables for robot magik example test agains DUMMY smallworld 530 - cbg
# ------------------------------------------------------------------------

from variables_sw53_cbg import *
from variables_sw53_cbg import __rfm_root_dir

ALIASNAME=ALIASNAME+"start_telnet"
CLI_PORT=14003
CLI_TIMEOUT = 60.0
DUMMY_LAUNCHER=os.path.join( __rfm_root_dir, "tests", "scripts", "dummy_gis_launcher.py" )
DUMMY_PROMPT="MagikSF"

