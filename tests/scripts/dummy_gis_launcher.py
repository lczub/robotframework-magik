#! /usr/bin/python
# -*- coding: UTF-8 -*-

#  Copyright 2012-2015 Luiko Czub, Smallcases Software GmbH
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

import os, sys
import logging
from dummy_remote_cli import dummy_remote_cli

class dummy_gis_launcher(object):
    def __init__(self, args):
        self.args = args
        log_fname = self.get_arg('-l')
        self.config_logger(log_fname)
        self.logger = logging.getLogger('dummy_gis')
        self.alias = self.get_arg('-i').lower()
        self.port = int(os.getenv('ROBOT_CLI_PORT', '14011'))
        self.max_connections = self.get_max_connections()


    def get_arg(self, arg_name):
        index = self.args.index(arg_name)
        return self.args[index+1]

    def get_max_connections(self):
        ''' Used port define the maximum number of connections. 
        Rule is: PORT modulo
        Examples: 
        - port 14004: max connections => 2
        - port 14011: max connections => 1'''
        return self.port % 10

    def run_dummy_gis(self):
        self.logger.info('Hello GIS World!')
        env_list = ['ROBOT_MAGIK_DIR', 'ROBOT_CLI_PORT', 'SW_MSF_STARTUP_MAGIK']
        for env_name in env_list:
            self.logger.info('%s=%s' % (env_name, os.getenv(env_name)) )
        self.logger.info('PID=%i' % os.getpid())
        self.start_dummy_cli()

    def start_dummy_cli(self):
        if 'start_telnet' in self.alias:
            self.logger.info('Start dummy remote_cli for ALIAS %s' % self.alias)
            a_cli = dummy_remote_cli(self.port, self.max_connections)
            a_cli.listen_socket()


    def config_logger(self, fname, level=logging.INFO):
        ''' set up logging INFO messages or higher to the sys.stdout and into 
            file FNAME '''
        logging.basicConfig(level=logging.INFO,
                    format='%(name)-10s: %(message)s',
                    datefmt='%m-%d %H:%M',
                    stream=sys.stdout)

        # define a filehHandler which writes INFO messages to file
        hfile = logging.FileHandler(fname, mode='w')
        hfile.setLevel(level)
        # set a format which is simpler for console use
        formatter = logging.Formatter('%(asctime)s %(name)-10s %(levelname)-8s %(message)s')
        # tell the handler to use this format
        hfile.setFormatter(formatter)
        # add the handler to the root logger
        logging.getLogger('').addHandler(hfile)


def main():
    a_launcher = dummy_gis_launcher(sys.argv[1:])
    a_launcher.run_dummy_gis()

if __name__ == '__main__':
    main()
