#! /usr/bin/python
# -*- coding: UTF-8 -*-

#  Copyright 2012 Luiko Czub, Smallcases GmbH
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
#                                   e:\Smallworld\CST42\product cam_db_open_swaf
# ------------------------------------------------------------------------


import os, sys
from argparse import ArgumentParser
from subprocess import Popen
from tempfile import gettempdir
from time import strftime


def defaults_for_start():
    'default start parameters'
    defaults = {}
    
    # log and pid directory - %TEMP%\robot_magik
    a_dir   = os.path.join(gettempdir(), 'robot_magik')
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
                          help='directory for the pidfile (default: %(default)s ')
    a_parser.add_argument('--logdir', default=defaultargs['logdir'],
                          help='directory for the session logfile (default: %(default)s ')
    a_parser.add_argument('--login', 
                          help='Username/password for login')
    help_info = 'script to add remote_cli startup procedure via image command line argument -run_script.'
    help_info += 'Only useful for startup image. Has no effect in closed image.'
    help_info += 'Argument --script will not used, when --msf_startup is defined.'
    help_info += '(default: %(default)s'
    a_parser.add_argument('--script', default=defaultargs['script'],
                          help=help_info)
    help_info = 'If set, the  environment variable SW_MSF_STARTUP_MAGIK '
    help_info += 'will be defined with the script %s' % defaultargs['magikfile']
    help_info += ' to start the remote_cli. '
    help_info += 'Useful for closed images, where startup actions not work.'
    a_parser.add_argument('--msf_startup', action='store_true', help=help_info)
    
    return a_parser
    
 
def start_image(args):
    'Starts a Magik image via windows launcher gis.exe'
    
    command_args = []
        
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
    
    # Check, if how the remote cli should be started via Startup Magik File with
    # environment variable SW_MSF_STARTUP_MAGIK
    if args.msf_startup is True:
        # remote cli will be started via Startup Magik File, defined in 
        # environment variable SW_MSF_STARTUP_MAGIK
        os.putenv('SW_MSF_STARTUP_MAGIK', args.magikfile)
    else:
        # remote cli will be started via an startup action via run_script
        command_args.extend(['-run_script', args.script])
    
    # login 
    login = args.login
    if login:
        command_args.extend(["-login", login])
        
    # launch the image
    a_image = Popen(command_args)
    process_id = a_image.pid
    print 'Image %s started. gis.exe has the pid %i' % (alias, process_id)
    print 'Logfile see %s' % log_fname
    
    # write pid file
    pid_file = open(pid_fname, 'w')
    pid_file.write('%i\n%s\n' % (process_id, log_fname))
    pid_file.close()
    print 'pidfile see %s' % pid_fname
    
    # TODO: check if remote_cli is realy running?        


if __name__ == '__main__':
    start_defaults = defaults_for_start()
    start_parser = argparser_for_start(start_defaults)
    start_args = start_parser.parse_args()
    start_image(start_args)