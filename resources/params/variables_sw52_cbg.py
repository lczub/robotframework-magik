#! /usr/bin/python
# -*- coding: UTF-8 -*-

# ------------------------------------------------------------------------
#  Copyright 2019-2022 Luiko Czub, Smallcases Software GmbH
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
# variables for robot magik example test agains smallworld 52x - cbg
# ------------------------------------------------------------------------

# ========================================================================
# settings for starting the magik session
# ========================================================================

# time in sec to wait while starting the magik image / session till a telnet
# communication should be available
START_WAIT = "60s"
# path to smallworld core product
SWPRODUCT = r"S:\nrm52103\core"
# file with gis alias definitions
ALIASFILE = SWPRODUCT + r"\..\cambridge_db\config\gis_aliases"
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

# Starting Smallworld 5.x sessions must define jre / jdk to be used
# - 5.2.10 works with open jdk17, 5.1 requires 1.8 
# Starting Smallworld 4.3 images doesn't requires this, except images works with java acp
JAVA_HOME = r"C:\Testing\robot-magik\devenv\jre-17.0.6-x64"

# Hook for debugging  / analysing
# Set AUTO_START_MAGIK SESSION to False, when test run should use a manual 
# started session instead starting an own one
AUTO_START_MAGIK_SESSION=True

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

# ========================================================================
# settings for munit test
# ========================================================================
# Defines magik file loading munit base modules and other required 
# base test code - modules with tests should be loaded separately
ROBOT_MUNIT_LOADFILE = r"C:\Testing\robot-magik\robotframework-magik\resources\magik\load_opensmallworld_munit_52.magik"
# Define which MUnit product should be used by above file
ROBOT_MUNIT_DIR = r"C:\Testing\robot-magik\OpenSmallworld_munit"
# ========================================================================
# settings for other robot magik self tests
# ========================================================================
GIS_VERSION=52