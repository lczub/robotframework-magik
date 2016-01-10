#! /usr/bin/python
# -*- coding: UTF-8 -*-

#  Copyright 2012-2016 Luiko Czub, Smallcases Software GmbH
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
#
# Examples:
#
# python robot_start_magik_image.py -h
#
# python robot_start_magik_image.py --msf_startup e:\Smallworld\CST42\product swaf
#
# python robot_start_magik_image.py --aliasfile e:\test\gis_aliases
#                                   --piddir e:\tmp\robot\pids
#                                   --logdir e:\tmp\robot\logs
#                                   --login root/
#                                   --cli_port 14003
#                                   --wait 10
#                                   e:\Smallworld\CST42\product cam_db_open_swaf
# ------------------------------------------------------------------------


import os, sys, logging
from argparse import ArgumentParser
from subprocess import Popen
from tempfile import gettempdir
from time import strftime, sleep
from telnetlib import Telnet
from symbol import try_stmt

logging.basicConfig(level=logging.INFO,
                    format='%(name)-10s: %(message)s',
                    datefmt='%m-%d %H:%M',
                    stream=sys.stdout)

class MagikStart(object):
    
    def __init__(self):
        self._defaultargs = self._defaults_for_start()
        self.argparser = self._argparser_for_start(self._defaultargs)
        self.log_fname = None
        self.cli_port  = None
        self._config_logger()
        self.gis_args = [] # command line arguments gis start
        self.gis_envs = {} # special robot environment variables gis session
        
    def _config_logger(self):
        self._logger = logging.getLogger('start_gis')
        
    def log_info(self, messsage):
        self._logger.info(messsage)
        
    def log_error(self, messsage):
        self._logger.error(messsage)
        
    def _defaults_for_start(self):
        'default start parameters'
        defaults = {}
    
        # temp directory for msfext files
        tmp_dir = gettempdir()
        defaults['msfextdir'] = tmp_dir
    
        # log and pid directory - %TEMP%\robot_magik
        a_dir   = os.path.join(tmp_dir, 'robot_magik')
        defaults['logdir'] = a_dir
        defaults['piddir'] = a_dir
    
        # start script - .\start_robot_remote_cli.script
        # -> loads .\robot_remote_cli.magik and starts the remote_cli
        a_dir = os.path.abspath(os.path.dirname(sys.argv[0]))
        defaults['robmag_script_dir'] = a_dir
        defaults['robmag_dir'] = os.path.dirname(a_dir)
        defaults['script'] = os.path.join(a_dir, 'start_robot_remote_cli.script')
        defaults['magikfile'] = os.path.join(a_dir, 'start_robot_remote_cli.magik')
    
        return defaults

    def _argparser_for_start(self, defaultargs):
        'parser for start command line arguments'
        
        defaultargs = self._defaultargs
        a_parser = ArgumentParser(
                    description='starts a Magik image and activates the remote cli.')
    
        # default parameter without inspection of the command line
        a_parser.set_defaults(robmag_dir=defaultargs['robmag_dir'])
        a_parser.set_defaults(magikfile=defaultargs['magikfile'])
        a_parser.set_defaults(msfextdir=defaultargs['msfextdir'])
    
        # required command line parameters
        a_parser.add_argument('swproduct',
                              help='Smallworld Core product path')
        a_parser.add_argument('alias',
                              help='Magik image alias')
    
        # optional command line parameters
        a_parser.add_argument('--aliasfile',
                              help='alias file which includes the ALIAS definition')
        a_parser.add_argument('--cli_port', type=int, default=14001,
                              help='port, the remote_cli listens on (default: %(default)s)')
        a_parser.add_argument('--piddir', default=defaultargs['piddir'],
                              help='directory for the pidfile (default: %(default)s) ')
        a_parser.add_argument('--logdir', default=defaultargs['logdir'],
                              help='directory for the session logfile (default: %(default)s) ')
        a_parser.add_argument('--login',
                              help='Username/password for login')
        help_info = 'script to add remote_cli startup procedure via image command line argument -run_script. '
        help_info += 'Only useful for startup image. Has no effect in closed image. '
        help_info += 'Argument --script will not used, when --msf_startup is defined. '
        help_info += '(default: %(default)s)'
        a_parser.add_argument('--script', default=defaultargs['script'],
                              help=help_info)
        help_info = 'If set, the  environment variable SW_MSF_STARTUP_MAGIK '
        help_info += 'will be defined with the script %s' % defaultargs['magikfile']
        help_info += ' to start the remote_cli. '
        help_info += 'Useful for closed images, where startup actions not work.'
        a_parser.add_argument('--msf_startup', action='store_true', help=help_info)
        help_info =  'seconds, how long the process should wait for the check, '
        help_info += 'that the image is really reachable via telnet. '
        help_info += '(default: %(default)s)'
        a_parser.add_argument('--wait', type=float, default=30, help=help_info)
    
        help_info = 'Hook to start a test script instead the gis launcher.'
        a_parser.add_argument('--test_launch', help=help_info)
    
        return a_parser

    def _check_telnet_connection(self, port, maxwait=30):
        # checks, if localhost:PORT is reachable via telnet
        # if the telnet connection is not reachable in MAXWAIT seconds,
        # an IOError is raised
        # returns the cli prompt
    
        a_connection = Telnet()
        duration = 0
        prompt = 'unknown'
        connected = False
        while (duration < maxwait) and not connected:
            duration += 1
            try:
                a_connection.open('localhost', port, 10)
                prompt = a_connection.read_until( '>' )
                a_connection.close()
                connected = True
            except IOError:
                # connection not established - we will sleep for 1 second
                sleep(1)
    
        return prompt
    
    def _prepare_gis_args_and_envs(self, args):
        ''' Build from parser generated ARGS gis command start arguments and 
        environment variables'''

        # robot framework magik directory
        # - evaluated in .\start_robot_remote_cli.script
        self.gis_envs['ROBOT_MAGIK_DIR'] = args.robmag_dir
        
        # port the remote_cli should listen
        # - evaluated in .\robot_remote_cli.magik
        self.cli_port = args.cli_port
        self.gis_envs['ROBOT_CLI_PORT'] = '%i' % self.cli_port
    
        # gis launcher program
        gis_exe = os.path.join(args.swproduct, 'bin', 'x86', 'gis.exe')
        self.gis_args.append(gis_exe)
    
        # check, if special alias file required
        aliasfile = args.aliasfile
        if aliasfile:
            self.gis_args.extend(["-a", aliasfile])
    
        # check if log file directory exists
        log_dir = args.logdir
        if not os.path.exists(log_dir):
            os.mkdir(log_dir)
    
        # log file
        alias = args.alias
        info = strftime("%m%d_%H%M")
        self.log_fname = os.path.join(log_dir, 
                                '%s-%s-%i.log' % (alias, info, self.cli_port))
        self.gis_args.extend(['-l', self.log_fname, '-i', alias])
    
        # Temp Path for msfext.xxxx file
        # some nrm images seams to requires this parameter.
        # for swaf and cbg images, this parameter seams to be optional
        self.gis_args.append(args.msfextdir)
    
        # Check, if how the remote cli should be started via Startup Magik File with
        # environment variable SW_MSF_STARTUP_MAGIK
        if args.msf_startup is True:
            # remote cli will be started via Startup Magik File, defined in
            # environment variable SW_MSF_STARTUP_MAGIK
            self.gis_envs['SW_MSF_STARTUP_MAGIK'] = args.magikfile
            self.log_info('SW_MSF_STARTUP_MAGIK set to {}'.format(args.magikfile))
        else:
            # remote cli will be started via an startup action via run_script
            self.gis_args.extend(['-run_script', args.script])
    
        # login
        login = args.login
        if login:
            self.gis_args.extend(["-login", login])
            
    
    def _prepare_test_launch(self, test_script):
        ''' manipulate collected gis command line arguments to  call a python 
        test script instead default gis launcher '''
        self.gis_args[0] = test_script
        self.gis_args[:0] = ['python']
        

    def start_image(self, args):
        'Starts a Magik image via windows launcher gis.exe'
        
        self._prepare_gis_args_and_envs(args)
    
        # check if pid file directory exists
        pid_dir = args.piddir
        if not os.path.exists(pid_dir):
            os.mkdir(pid_dir)
    
        # TODO: check if pid file already exist
        pid_fname  = os.path.join(pid_dir, '%i.pid' % self.cli_port)
    
        # start the gis (or test) launcher
        test_launch = args.test_launch
        if test_launch:
            # call a python test script instead default gis launcher
            self._prepare_test_launch(test_launch)
            self.log_info('Start test session with: {}'.format(' '.join(self.gis_args)))
        else:
            self.log_info('Start gis session with: {}'.format(' '.join(self.gis_args)))
        # add general parent environment settings to special child environments
        self.gis_envs.update(os.environ)
        a_image = Popen(self.gis_args, env=self.gis_envs)
        process_id = a_image.pid
        self.log_info('Logfile see {}'.format(self.log_fname))
    
        # write pid file
        pid_file = open(pid_fname, 'w')
        pid_file.write('%i\n%s\n' % (process_id, self.log_fname))
        pid_file.close()
        self.log_info('pidfile see {}'.format(pid_fname))
    
        # check telnet connection
        wait = args.wait
        prompt = self._check_telnet_connection(self.cli_port, wait)
        if prompt <> 'unknown':
            self.log_info('Image is now reachable via telnet localhost:{} with prompt {}'.format(self.cli_port, prompt))
        else:
            msg = 'Image is NOT reachable via telnet localhost:{}'.format(self.cli_port)
            self.log_error(msg)
            sys.exit(msg)


if __name__ == '__main__':
#     start_defaults = defaults_for_start()
#     start_parser = argparser_for_start(start_defaults)
#     start_args = start_parser.parse_args()
#     start_image(start_args)
    a_starter = MagikStart()
    start_args = a_starter.argparser.parse_args()
    a_starter.start_image(start_args)