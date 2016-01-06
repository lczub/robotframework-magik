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
from subprocess import Popen, PIPE
from tempfile import gettempdir
from time import strftime, sleep
from telnetlib import Telnet
from symbol import try_stmt

logging.basicConfig(level=logging.INFO,
                    format='%(name)-10s: %(message)s',
                    datefmt='%m-%d %H:%M',
                    stream=sys.stdout)


def defaults_for_start():
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

def argparser_for_start(defaultargs):
    'parser for start command line arguments'
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

def check_telnet_connection(port, maxwait=30):
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


def start_image(args):
    'Starts a Magik image via windows launcher gis.exe'

    command_args = []
    logger = logging.getLogger('start_gis')

    # robot framework magik directory
    # - evaluated in .\start_robot_remote_cli.script
    os.putenv('ROBOT_MAGIK_DIR', args.robmag_dir)

    # port the remote_cli should listen
    # - evaluated in .\robot_remote_cli.magik
    cli_port = args.cli_port
    os.putenv('ROBOT_CLI_PORT', '%i' % cli_port)

    # gis launcher program
    gis_exe = os.path.join(args.swproduct, 'bin', 'x86', 'gis.exe')
    command_args.append(gis_exe)

    # check, if special alias file required
    aliasfile = args.aliasfile
    if aliasfile:
        command_args.extend(["-a", aliasfile])

    # check if pid file directory exists
    pid_dir = args.piddir
    if not os.path.exists(pid_dir):
        os.mkdir(pid_dir)

    # TODO: check if pid file already exist
    pid_fname  = os.path.join(pid_dir, '%i.pid' % cli_port)

    # check if log file directory exists
    log_dir = args.logdir
    if not os.path.exists(log_dir):
        os.mkdir(log_dir)

    # log file
    alias = args.alias
    info = strftime("%m%d_%H%M")
    log_fname = os.path.join(log_dir, '%s-%s-%i.log' % (alias, info, cli_port))
    command_args.extend(['-l', log_fname, '-i', alias])

    # Temp Path for msfext.xxxx file
    # some nrm images seams to requires this parameter.
    # for swaf and cbg images, this parameter seams to be optional
    command_args.append(args.msfextdir)

    # Check, if how the remote cli should be started via Startup Magik File with
    # environment variable SW_MSF_STARTUP_MAGIK
    if args.msf_startup is True:
        # remote cli will be started via Startup Magik File, defined in
        # environment variable SW_MSF_STARTUP_MAGIK
        os.putenv('SW_MSF_STARTUP_MAGIK', args.magikfile)
        logger.info('SW_MSF_STARTUP_MAGIK set to {}'.format(args.magikfile))
    else:
        # remote cli will be started via an startup action via run_script
        command_args.extend(['-run_script', args.script])

    # login
    login = args.login
    if login:
        command_args.extend(["-login", login])

    # start the gis (or test) launcher
    test_launch = args.test_launch
    if test_launch:
        # call a python test script instead default gis launcher
        command_args[0] = test_launch
        command_args[:0] = ['python']
        logger.info('Start test session with: {}'.format(' '.join(command_args)))
    else:
        logger.info('Start gis session with: {}'.format(' '.join(command_args)))
#    a_image = Popen(command_args, stdout=PIPE, stderr=PIPE)
    a_image = Popen(command_args)
    process_id = a_image.pid
    logger.info('Logfile see {}'.format(log_fname))

    # write pid file
    pid_file = open(pid_fname, 'w')
    pid_file.write('%i\n%s\n' % (process_id, log_fname))
    pid_file.close()
    logger.info('pidfile see {}'.format(pid_fname))

    # check telnet connection
    wait = args.wait
    prompt = check_telnet_connection(cli_port, wait)
    if prompt <> 'unknown':
        logger.info('Image is now reachable via telnet localhost:{} with prompt {}'.format(cli_port, prompt))
    else:
        msg = 'Image is NOT reachable via telnet localhost:{}'.format(cli_port)
        logger.error(msg)
        sys.exit(msg)


if __name__ == '__main__':
    start_defaults = defaults_for_start()
    start_parser = argparser_for_start(start_defaults)
    start_args = start_parser.parse_args()
    start_image(start_args)