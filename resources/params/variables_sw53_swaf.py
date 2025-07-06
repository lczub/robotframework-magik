#! /usr/bin/python
# -*- coding: UTF-8 -*-

# ------------------------------------------------------------------------
#  Copyright 2023-2025 Luiko Czub, Smallcases Software GmbH
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
# variables for robot magik example test agains smallworld 53x - swaf
# ------------------------------------------------------------------------

# load general 53x settings from cbg att test data settings
from variables_sw53_cbg import *

# ========================================================================
# differing settings for starting the swaf session
# ========================================================================

# time in sec to wait while starting the magik image / session till a telnet
# communication should be available
START_WAIT = "30s"
# file with gis alias definitions
ALIASFILE = os.path.join( SWPRODUCT, "config", "gis_aliases")
# gis alias name for cambridge image / session
ALIASNAME = "swaf"
# Login for authorisation - user/password
# LOGIN = "root/ "

# ========================================================================
# settings for communicate with the magik session
# ========================================================================

# used telnet port for communication with smallworld magik image / session
CLI_PORT = 14002
# default time to wait for a telnet response in sec
CLI_TIMEOUT = 10.0
