#! /usr/bin/python
# -*- coding: UTF-8 -*-

#  Copyright 2012-2021 Luiko Czub, Smallcases Software GmbH
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
# python robot_stop_magik_image.py -h
#
# python robot_stop_magik_image.py
#
# python robot_stop_magik_image.py --piddir e:\tmp\robot\pids
#                                   --cli_port 14003 
# ------------------------------------------------------------------------

import os, sys, logging
from argparse import ArgumentParser
from tempfile import gettempdir

logging.basicConfig(level=logging.INFO,
                    format='%(name)-10s: %(message)s',
                    datefmt='%m-%d %H:%M',
                    stream=sys.stdout)

def defaults_for_stop():
    'default stop parameters'
    defaults = {}
    
    # pid directory - %TEMP%\robot_magik
    a_dir   = os.path.join(gettempdir(), 'robot_magik')
    defaults['piddir'] = a_dir

    return defaults
    
def argparser_for_stop(defaultargs):
    'parser for stop command line arguments'
    a_parser = ArgumentParser(
                description='stops a Magik image and his remote cli.')
    
    # optional command line parameters
    a_parser.add_argument('--cli_port', type=int, default=14001, 
                          help='port, the remote_cli listens on (default: %(default)s)')
    a_parser.add_argument('--piddir', default=defaultargs['piddir'],
                          help='directory for the pidfile (default: %(default)s ')
    
    return a_parser
    
 
def stop_image(args):
    'stops a Magik image via windows launcher gis.exe'
    
    logger = logging.getLogger('stop_gis')
    
    # pid file name
    pid_dir = args.piddir
    pid_fname  = os.path.join(pid_dir, '%i.pid' % args.cli_port)
    
    if not os.path.exists(pid_fname):
        msg = 'required PID file does not exist: {}'.format(pid_fname)
        logger.error(msg)
        sys.exit(msg)

    # open pid file and read pid and log file name
    # TODO: check if pid file still exists
    pid_file = open(pid_fname, 'r')
    process_id = int(pid_file.readline())
    log_fname  = pid_file.readline()
    pid_file.close()
    
    # TODO: check if process is really active
    # TODO: the soft way: send quit() via telnet to remote cli
    
    # the hard way: kill process
    # TODO: try exception block 
    try:
        os.kill(process_id, 2)
        logger.info( 'Image process {} is killed.'.format(process_id) )
    except WindowsError as msg:
        logger.info( 'Process {} doesn\'t run anymore, kill response an error: {}'.format(process_id, msg) )
    
    # delete the pid file
    os.remove(pid_fname)
    logger.info( 'pidfile {} is removed.'.format( pid_fname ) )
    logger.info( 'Logfile see {}'.format( log_fname) )
    
    
        


if __name__ == '__main__':
    stop_defaults = defaults_for_stop()
    stop_parser = argparser_for_stop(stop_defaults)
    stop_args = stop_parser.parse_args()
    stop_image(stop_args)
