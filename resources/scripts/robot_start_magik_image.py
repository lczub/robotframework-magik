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

class MagikSession(object):
    ''' Class for starting Magik Sessions '''

    def __init__(self, swproduct, gis_alias, cli_port=14001, aliasfile=None,
                 logdir=None, login=None, script=None, msf_startup=False,
                 wait=30, test_launch=None):
        self._defaults = self._defaults_for_start()
        self._swproduct = swproduct
        self._gis_alias = gis_alias
        self.cli_port = int(cli_port or 14001)
        self._aliasfile = aliasfile
        self._logdir = logdir or self._defaults['logdir']
        self._login = login
        self._script = script or self._defaults['script']
        self._msf_startup = msf_startup or False
        self._wait = wait or 30
        self._test_launch = test_launch

        self._log_fname = None
        self._config_logger()
        self.process_popen = None
        self.process_id    = None
        self.remote_cli    = False

        # build gis start command line and environment variables
        self.gis_args = [] # command line arguments gis start
        self.gis_envs = {} # special robot environment variables gis session
        self._prepare_gis_args_and_envs()

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

        # start script - .\start_robot_remote_cli.script
        # -> loads .\robot_remote_cli.magik and starts the remote_cli
        a_dir = os.path.abspath(os.path.dirname(__file__))
        defaults['robmag_script_dir'] = a_dir
        defaults['robmag_dir'] = os.path.abspath(os.path.join(a_dir, '..', '..'))
        defaults['script'] = os.path.join(a_dir, 'start_robot_remote_cli.script')
        defaults['magikfile'] = os.path.join(a_dir, 'start_robot_remote_cli.magik')

        return defaults


    def _prepare_gis_args_and_envs(self):
        ''' Build gis command start arguments and environment variables'''

        # robot framework magik directory
        # - evaluated in .\start_robot_remote_cli.script
        self.gis_envs['ROBOT_MAGIK_DIR'] = self._defaults['robmag_dir']

        # port the remote_cli should listen
        # - evaluated in .\robot_remote_cli.magik
        self.gis_envs['ROBOT_CLI_PORT'] = '%i' % self.cli_port

        # gis launcher program
        gis_exe = os.path.join(self._swproduct, 'bin', 'x86', 'gis.exe')
        self.gis_args.append(gis_exe)

        # check, if special alias file required
        if self._aliasfile:
            self.gis_args.extend(["-a", self._aliasfile])

        # check if log file directory exists
        if not os.path.exists(self._logdir):
            os.mkdir(self._logdir)

        # log file
        alias = self._gis_alias
        info = strftime("%m%d_%H%M")
        self._log_fname = os.path.join(self._logdir,
                                '%s-%s-%i.log' % (alias, info, self.cli_port))
        self.gis_args.extend(['-l', self._log_fname, '-i', alias])

        # Temp Path for msfext.xxxx file
        # some nrm images seams to requires this parameter.
        # for swaf and cbg images, this parameter seams to be optional
        self.gis_args.append(self._defaults['msfextdir'])

        # Check, if how the remote cli should be started via Startup Magik File with
        # environment variable SW_MSF_STARTUP_MAGIK
        if self._msf_startup is True:
            # remote cli will be started via Startup Magik File, defined in
            # environment variable SW_MSF_STARTUP_MAGIK
            mfile = self._defaults['magikfile']
            self.gis_envs['SW_MSF_STARTUP_MAGIK'] = mfile
            self.log_info('SW_MSF_STARTUP_MAGIK set to {}'.format(mfile))
        else:
            # remote cli will be started via an startup action via run_script
            self.gis_args.extend(['-run_script', self._script])

        # login
        if self._login:
            self.gis_args.extend(["-login", self._login])

        # start the gis (or test) launcher
        test_launch = self._test_launch
        if test_launch:
            # call a python test script instead default gis launcher
            self._prepare_test_launch(test_launch)

    def _prepare_test_launch(self, test_script):
        ''' manipulate collected gis command line arguments to  call a python
        test script instead default gis launcher '''

        self.gis_args[0] = test_script
        self.gis_args[:0] = ['python']
        self.log_info('GIS start will be simulated with {}'.format(test_script))

    def start_session(self):
        ''' Starts a Magik session or image via windows launcher gis.exe and
        checks, if it is reachable via telnet '''

        # start the gis (or test) launcher
        self.log_info('Start gis session with: {}'.format(' '.join(self.gis_args)))

        # add general parent environment settings to special child environments
        self.gis_envs.update(os.environ)
        self._start_process()
        self.log_info('Logfile see {}'.format(self._log_fname))


    def _start_process(self):
        ''' start this gis launcher program '''
        self.process_popen = Popen(self.gis_args, env=self.gis_envs)
        self.process_id    = self.process_popen.pid

    def check_telnet_connection(self):
        ' Check if a telnet communication via self.cli_port is possible '

        exit_code = 0
        port = self.cli_port
        prompt = self._get_telnet_prompt(port, self._wait)
        if prompt is None:
            msg = 'Image is NOT reachable via telnet localhost:{}'.format(port)
            self.log_error(msg)
            exit_code = msg
        else:
            self.log_info('Image is now reachable via telnet localhost:{} with prompt {}'.format(port, prompt))

        return exit_code


    def _get_telnet_prompt(self, port, maxwait=30):
        ''' checks, if localhost:PORT is reachable via telnet during MAXWAIT
        seconds. returns the found cli prompt.
        If no telnet connection is reachable during MAXWAIT seconds,
        return value is 'unknown' is returned '''

        a_connection = Telnet()
        duration = 0
        prompt = None
        connected = False
        while (duration < maxwait) and not connected:
            duration += 1
            self._logger.debug('check telnet loop {}, will wait till {}'.format(duration, maxwait))
            try:
                a_connection.open('localhost', port, 10)
                prompt = a_connection.read_until( '>' )
                a_connection.close()
                connected = True
            except IOError:
                # connection not established - we will sleep for 1 second
                sleep(1)

        return prompt

    def stop_session(self):
        ''' Stops the Magik session just killing the process '''

        #pass
        sleep(2)


class CmdMagikSession(MagikSession):
    ''' Start Magik Session with Command Line Arguments '''

    def __init__(self):

        # special slots for pid file handling
        self._piddir = None
        self._pid_fname = None

        # dummy values for mandatory arguments swproduct and gis_alias
        # they will be replaced with mandatory command line arguments
        super(CmdMagikSession, self).__init__('DummySWProduct', 'DummyGisAlias')


    def _defaults_for_start(self):
        'default start parameters - additional piddir arg'

        defaults = super(CmdMagikSession, self)._defaults_for_start()
        defaults['piddir'] = defaults['logdir']
        print("defaults['piddir'] {}".format(defaults['piddir']))

        return defaults

    def _argparser_for_start(self):
        'parser for start command line arguments'

        defaultargs = self._defaults
        a_parser = ArgumentParser(
                    description='starts a Magik image and activates the remote cli.')

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

    def _prepare_gis_args_and_envs(self):
        ''' Build gis command start arguments and environment variables from
        command line parameters'''

        argparser = self._argparser_for_start()
        start_args = argparser.parse_args()

        self._swproduct = start_args.swproduct
        self._gis_alias = start_args.alias
        self.cli_port = start_args.cli_port
        self._aliasfile = start_args.aliasfile
        self._logdir = start_args.logdir
        self._login = start_args.login
        self._script = start_args.script
        self._msf_startup = start_args.msf_startup
        self._wait = start_args.wait
        self._test_launch = start_args.test_launch or self._test_launch

        self._piddir = start_args.piddir
        self._pid_fname = os.path.join(self._piddir, '%i.pid' % self.cli_port)

        print('self._piddir 1 {}'.format(self._piddir))

        super(CmdMagikSession, self)._prepare_gis_args_and_envs()

    def _start_process(self):
        ''' additional call _write_pid_file, after super starts the magik
        session '''

        super(CmdMagikSession, self)._start_process()
        self._write_pid_file()

    def _write_pid_file(self):
        ' write the pid file with pid and log file info'

        # check if pid file directory exists
        if not os.path.exists(self._piddir):
            os.mkdir(self._piddir)

        # write pid file
        pid_file = open(self._pid_fname, 'w')
        pid_file.write('%i\n%s\n' % (self.process_id, self._log_fname))
        pid_file.close()
        self.log_info('pidfile see {}'.format(self._pid_fname))

if __name__ == '__main__':
    a_starter = CmdMagikSession()
    a_starter.start_session()
    exit_code = a_starter.check_telnet_connection()
    sys.exit(exit_code)