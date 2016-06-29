#! /usr/bin/python
# -*- coding: UTF-8 -*-

# ------------------------------------------------------------------------
#  Copyright 2016 Luiko Czub, Smallcases Software GmbH
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
# variables for robot magik example test agains smallworld 510 - cbg
# ------------------------------------------------------------------------

# ========================================================================
# settings for starting the magik session
# ========================================================================

# time in sec to wait while starting the magik image / session till a telnet
# communication should be available
START_WAIT = "30s"
# path to smallworld core product
SWPRODUCT = "C:\\Smallworld\\NRM51-B6-c18\\core"
# file with gis alias definitions
ALIASFILE = SWPRODUCT + "\\..\\cambridge_db\\config\\gis_aliases"
# gis alias name for cambridge image / session
ALIASNAME = "cambridge_db_open"
# Login for authorisation - user/password
LOGIN = "root/ "

# starting Smallworld 4.3 images should set MSFSTARTUP = None or False
# - the startup script to init the required telnet communication will be
#   loaded using the gis.exe switch'-run_script'
# cause Smallworld 5.0 does not support the gis.exe switch'-run_script',
# starting SW5 magik sessions must set MSFSTARTUP = True
# - the startup magik file to init the required telnet communication will be
#   loaded using the environment variable SW_MSF_STARTUP_MAGIK
MSFSTARTUP = True

# ========================================================================
# settings for communicate with the magik session
# ========================================================================

# used telnet port for communication with smallworld magik image / session
CLI_PORT = 14002
# default time to wait for a telnet response in sec
CLI_TIMEOUT = 10.0

# ========================================================================
# settings for dataset test
# ========================================================================
# Name of the dataset, which should be used for tests
CLI_DSVIEW_NAME = "gis"
