#! /usr/bin/python
# -*- coding: UTF-8 -*-

#  Copyright 2016-2025 Luiko Czub, Smallcases Software GmbH
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

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.Process import Process, logger, timestr_to_secs
import os
from scripts.robot_start_magik_image import MagikSession


class RobotMagikLauncher(object):
    """ Robot Framework test library for starting and stopping Magik images
    (SW GIS 4.x) and sessions (SW GIS 5.x)

        Example starts cambridge session, calculates a distance and closes the session:
        | * Settings * |
        | Suite Setup | Start And Wait For Magik Session |
        | Suite Teardown | Stop Magik Session |
        | Library | Process |
        | Library | ../resources/RobotMagikLauncher.py | swproduct=${SWPRODUCT} | cli_port=${CLI_PORT} | wait=${START_WAIT} |
        | Resource | ../resources/robot_magik_base.txt |

        | * Variables * |
        | ${CLI_PORT}  |  14001 |
        | ${START_WAIT}  | 30s |
        | ${SWPRODUCT}   |  C:${/}Smallworld${/}core |
        | ${ALIASFILE}  |  ${SWPRODUCT}${/}..${/}cambridge_db${/}config${/}gis_aliases |
        | ${ALIASNAME}  |  cambridge_db_open |
        | ${JAVA_HOME}   |  C:${/}Tools${/}jre |

        | * Test Cases * |
        | Calculate Distance with Magik |
        |  | Open Magik Connection  | cli_port=${CLI_PORT} |
        |  | ${out}= | Execute Magik Command | coordinate.new(0,0).distance_to(coordinate.new(3,4)) |
        |  | Should Be Equal as Numbers | 5.0 | ${out} |
        |  | Close Magik Connection |

        | * Keywords * |
        | Start And Wait For Magik Session |
        |  | Start Magik Session | aliasfile=${ALIASFILE} | gis_alias=${ALIASNAME} | java_home=${JAVA_HOME} |
        |  | Session Should Be Reachable |

        == Arguments ==
        | =Argument= | =Intention=                                      |
        | swproduct  | Smallworld Core product path                     |
        | gis_alias  | Magik image / session ``ALIAS``                      |
        | cli_port   | port, the remote_cli listens on (default: 14001) |
        | aliasfile  | alias file which includes the ``ALIAS`` definition   |
        | envfile    | file with session specific environment settings  |
        | java_home  | special jre/jdk to use for acp or sw5x sessions  |
        | logdir     | directory for the session logfile                |
        | login      | Username/password for login                      |
        | script     | Script adding remote_cli startup procedure via image command line argument -run_script. |
        |            | Unfortunately only supported in 4.2 /4.3 startup images. |
        |            | Has no effect in closed images and raise error on 5.x sessions. |
        |            | Will be ignored, when *msf_startup* is defined. |        
        |            | default: _robotframework-magik/resources/scripts/start_robot_remote_cli.script_ |     
        | msf_startup | If set, environment variable ``SW_MSF_STARTUP_MAGIK`` will be defined with | 
        |             | script _robotframework-magik/resources/scripts/start_robot_remote_cli.magik_ |
        |             | for starting the remote_cli. Mandatory for none 4.2/4.3 sessions / images | 
        |             | and useful for 4.2/4.3 closed images (missing or incomplete script engine support) |
        | wait        | Time, how long the process should wait till checking, |
        |             | if the image / session is reachable via telnet. (default: 30s) |
        | nested_alias | If set, gis launcher started without setting argument ``-l logfile``. | 
        |              | Useful when working with nested ``ALIAS`` definitions. | 
        |              | DEPRECATED with Win11 RF7x: starting gis launcher without ``-l logfile`` does not work stable anymore | 
        | gis_args | additional gis args, extending args defined in ``ALIAS``. | 
        |              | Sample ``-cli -login uname/pw`` | 
        | test_launch  | Hook to start a test script instead the gis launcher. | 

        == Requirements ==
        Robot Framework Version >= 7.2 is required and Python 3.11 recommended.
        
        == Licence info ==
        | Copyright 2016-2025 Luiko Czub, Smallcases Software GmbH
        |
        | Licensed under the Apache License, Version 2.0 (the "License");
        | you may not use this file except in compliance with the License.
        | You may obtain a copy of the License at
        |
        | http://www.apache.org/licenses/LICENSE-2.0
        |
        | Unless required by applicable law or agreed to in writing, software
        | distributed under the License is distributed on an "AS IS" BASIS,
        | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        | See the License for the specific language governing permissions and
        | limitations under the License.        

    """

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, swproduct=None, gis_alias=None, cli_port=14001,
                 aliasfile=None, envfile=None, java_home=None, logdir=None, login=None,
                 script=None, msf_startup=None, wait='30s', nested_alias=None, 
                 gis_args=None, test_launch=None):

        self._swproduct = swproduct
        self._gis_alias = gis_alias
        self.cli_port = cli_port or 14001
        self._aliasfile = aliasfile
        self._envfile = envfile
        self._java_home = java_home
        self._logdir = logdir
        self._login = login
        self._script = script
        self._msf_startup = msf_startup
        self._wait = wait or '30s'
        self._nested_alias = nested_alias
        self._other_gis_args = gis_args
        self._test_launch = test_launch

        self._sessions = {}
        self._current_session = None
        script_dir = self._get_script_dir()
        self._start_script = os.path.join(script_dir,
                                          'robot_start_magik_image.py')
        self._stop_script = os.path.join(script_dir,
                                         'robot_stop_magik_image.py')

        test_script_dir = self._get_test_script_dir()
        self._dummy_gis_launcher = os.path.join(test_script_dir,
                                                'dummy_gis_launcher.py')
        self._dummy_remote_cli = os.path.join(test_script_dir,
                                              'dummy_remote_cli.py')

    def _get_script_dir(self):
        resouce_path = os.path.dirname(__file__)
        script_path = os.path.join(resouce_path, 'scripts')
        return os.path.normpath(script_path)

    def _get_test_script_dir(self):
        resouce_path = os.path.dirname(__file__)
        test_path = os.path.join(resouce_path, '..', 'tests', 'scripts')
        return os.path.normpath(test_path)

    def _log_result(self, process_result):
        BuiltIn().log(process_result.stdout)
        BuiltIn().log(process_result.stderr)

    def _ProcessInstance(self):
        return BuiltIn().get_library_instance('Process')

    def _register_session(self, a_magik_session):
        """ register the magik session with its cli_port as key """
        session_alias = self._port_alias(a_magik_session.cli_port)
        self._sessions[session_alias] = a_magik_session
        self._current_session = a_magik_session

    def _unregister_session(self, a_magik_session):
        """ unregister the magik session with its cli_port as key """
        session_alias = self._port_alias(a_magik_session.cli_port)
        logger.debug(f'_unregister_session {session_alias}')
        a_session = self._sessions.pop(session_alias )

        if self._current_session is a_session:
            self._current_session = None
        return a_session

    def _port_alias(self, cli_port=None):
        " Build a session alias for CLI_PORT. If not defined, None is returned "
        alias = None
        if cli_port != None:
            alias = int(cli_port)
        return alias

    def _check_cli_port_in_use(self, cli_port):
        " Checks if a session already uses the CLI_PORT"

        alias = self._port_alias(cli_port)
        if alias in self._sessions:
            error_msg = f'Port {cli_port} is already in use by another session!'
            raise AssertionError(error_msg)
        else:
            logger.info(f'Port {cli_port} is free to use')

    def start_magik_session(self, swproduct=None, gis_alias=None, cli_port=None,
                            aliasfile=None, envfile=None, java_home=None, logdir=None, login=None, 
                            script=None, msf_startup=None, wait=None, nested_alias=None,
                            gis_args=None, test_launch=None):
        """starts a new Magik session / image with the given SWPRODUCT and ALIAS

        The [#Arguments|arguments] get default values when the library is [#Importing|imported].
        Setting them here overrides those values for the new connection.

        This keyword just starts the session and does not check, if its reachable.
        Use keyword `Session Should Be Reachable` to wait till the session response.
        """

        outputdir = BuiltIn().replace_variables('${OUTPUTDIR}')

        swproduct = swproduct or self._swproduct
        gis_alias = gis_alias or self._gis_alias
        envfile = envfile or self._envfile
        java_home = java_home or self._java_home
        cli_port = cli_port or self.cli_port
        aliasfile = aliasfile or self._aliasfile
        logdir = logdir or self._logdir or outputdir
        login = login or self._login
        script = script or self._script
        msf_startup = msf_startup or self._msf_startup
        wait = wait or self._wait
        nested_alias = nested_alias or self._nested_alias
        other_gis_args = gis_args or self._other_gis_args
        test_launch = test_launch or self._test_launch

        if swproduct is None:
            error_msg = 'swproduct is not defined - assign a sw product path!'
            raise AssertionError(error_msg)
        elif gis_alias is None:
            error_msg = 'gis_alias is not defined - assign a session alias'
            raise AssertionError(error_msg)

        self._check_cli_port_in_use(cli_port)

        if test_launch:
            prompt = BuiltIn().get_variable_value("$DUMMY_PROMPT", "MagikSF")
            prompt = prompt.replace(' ', '_')
            other_gis_args =  f"{other_gis_args or ''} --dummyPrompt {prompt}"
            
        a_session = RobotMagikSession(self._ProcessInstance(),
                                    swproduct, gis_alias, cli_port, aliasfile,
                                    envfile, java_home, logdir, login, script, 
                                    msf_startup, timestr_to_secs(wait),
                                    nested_alias, other_gis_args, test_launch)
        a_session.start_session()
        self._register_session(a_session)
        return a_session

    def get_session_object(self, cli_port=None):
        """ Returns the underlying ``RobotMagikSession`` object.

        If ``cli_port`` is not given, uses the current `active session`.
        """
        session_alias = self._port_alias(cli_port)
        a_session = None
        if session_alias is None:
            a_session = self._current_session
            if a_session is None:
                raise AssertionError('No active session!')
        else:
            a_session = self._sessions.get(session_alias)
            if a_session is None:
                raise AssertionError(f'No registered {cli_port} session!')

        return a_session

    def switch_magik_session(self, cli_port):
        """Makes the magik session using CLI_PORT the current `active session`.

        Example:
        | Start Magik Session  | gis_alias=A_GIS_ALIAS_1  | cli_port=14001 |
        | Start Magik Session  | gis_alias=A_GIS_ALIAS_2  | cli_port=14002 |
        | # currently active session is A_GIS_ALIAS_2 14002 |
        | Switch Magik Session | 14001 |
        | # now active process  is A_GIS_ALIAS_1 14001 |

        Attention: this has no influence to the current active Magik Connection.
        To switch this telnet communication, use the Telnet keyword ``Switch Connection``.
        """
        a_session = self.get_session_object(cli_port)
        self._current_session = a_session
        return a_session

    def session_should_be_reachable(self, cli_port=None):
        """ Verifies that the magik session is reachable via the telnet

        If ``cli_port`` is not given, uses the current `active session`. """

        a_session = self.get_session_object(cli_port)
        a_session.check_telnet_connection()

    def stop_magik_session(self, cli_port=None, kill=True):
        """ Stops the current running magik session

        If ``cli_port`` is not given, uses the current `active session`.

        Currently, the session is stopped with a hard kill

        """
        a_session = self.get_session_object(cli_port)
        logger.debug(f'stop_magik_session {a_session}')
        self._unregister_session(a_session)
        return a_session.stop_session(kill)


    def stop_all_magik_sessions(self):
        ''' Stops the all Magik session '''

        # ensure working with a list and not a view
        # otherwise py3 can abort with an error
        # - dictionary changed size during iteration
        session_list = list( self._sessions.values() )
        for a_session in session_list:
            self._current_session = a_session
            self.stop_magik_session()
        self._sessions = {}

class RobotMagikSession(MagikSession):

    def __init__(self, ProcessInstance, *args):
        super(RobotMagikSession,self).__init__(*args)
        self._ProcessInstance = ProcessInstance
        self.log_info('Robot Magik Starter is initialised!')

    def _config_logger(self):
        self._logger = logger

    def log_error(self, error_message):
        raise AssertionError(error_message)

    def _start_process(self):
        ''' start the gis launcher program '''

        temp_dir = BuiltIn().replace_variables('${TEMPDIR}')

        temp_stdout = f'{temp_dir}/magik_session_{self.cli_port}-STDOUT.log'
        temp_stderr = f'{temp_dir}/magik_session_{self.cli_port}-STDERR.log'
        configurations = {'stdout' : temp_stdout, 'stderr' : temp_stderr,
                          'env' : self.gis_envs}

        a_handle = self._ProcessInstance.start_process(*self.gis_args,
                                                       **configurations)
        self.process_handle = a_handle
        self.process_id     = self._ProcessInstance.get_process_id(a_handle)
        self.process_popen  = self._ProcessInstance.get_process_object(a_handle)

    def stop_session(self, kill=True):
        ''' Stops the Magik session - currently just killing the process '''

        # ToDo - soft terminate by sending quit via telnet
        # ToDo - hard kill does not close log file in a clean way - the log file
        #        is still locked
        result = self._ProcessInstance.terminate_process(self.process_handle)
        BuiltIn().log(result.stdout)
        if result.stderr:
            BuiltIn().log(result.stderr, 'WARN')
        return result