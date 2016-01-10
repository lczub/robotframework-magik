#! /usr/bin/python
# -*- coding: UTF-8 -*-

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

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.Process import Process, logger
import os
# from resources.scripts.robot_start_magik_image import MagikStart
#from scripts import robot_start_magik_image
from scripts.robot_start_magik_image import MagikStart


class RobotMagikLauncher(object):
    """ Robot Framework test library for starting and stopping Magik images 
    (SW GIS 4.x) and sessions (SW GIS 5.x) """
            
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    def __init__(self):
        self._sessions = {}
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
        
    def start_dummy_gis(self, cli_port=14001, gis_alias='ALIAS_start_telnet'):
        ''' starts a dummy gis session , using python script 
        robot_start_magik_image.py '''
        
        a_starter = RobotMagikStart()
        
        wait_telnet = 0.1
        wait_process = wait_telnet + 2.0
        
        arguments = [self._start_script, 
                     '--cli_port', cli_port, '--wait', wait_telnet, 
                    '--test_launch', self._dummy_gis_launcher, 
                    'A_SWPRODUCT', gis_alias]
        
        temp_stdout = '{}_start-STDOUT.log'.format(cli_port)
        temp_stderr = '{}_start-STDERR.log'.format(cli_port)
        configurations = {'stdout' : temp_stdout, 'stderr' : temp_stderr}
                           
        start_handle = self._ProcessInstance().start_process('python', *arguments, 
                                                           **configurations)
        a_result = self._ProcessInstance().wait_for_process(handle=start_handle, 
                                    timeout=wait_process, on_timeout='terminate')
        self._log_result(a_result)
        self._sessions[cli_port] = gis_alias
        return a_result
        
    def stop_dummy_gis(self, cli_port=14001):
        ''' stops a running dummy gis session , using python script 
        robot_start_magik_image.py '''
        
        wait_telnet = 0.1
        wait_process = wait_telnet + 2.0
        
        arguments = [self._stop_script, '--cli_port', cli_port]
        
        temp_stdout = '{}_stop-STDOUT.log'.format(cli_port)
        temp_stderr = '{}_stop-STDERR.log'.format(cli_port)
        configurations = {'stdout' : temp_stdout, 'stderr' : temp_stderr}
                           
        a_result = self._ProcessInstance().run_process('python', *arguments,
                                                         **configurations)
        self._log_result(a_result)
        self._sessions[cli_port] = None
        return a_result        
        
class RobotMagikStart(MagikStart):
    
    def __init__(self):
        super(RobotMagikStart,self).__init__()
        self.log_info('Robot Magik Starter initialised!')
    
    def _config_logger(self):
        self._logger = logger
        
    