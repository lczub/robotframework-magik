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
import socket
import logging

class dummy_gis_launcher(object):
    def __init__(self, args):
        self.args = args
        log_fname = self.get_arg('-l')
        self.config_logger(log_fname)
        self.logger = logging.getLogger('dummy_gis')
        self.alias = self.get_arg('-i').lower()
        self.port = int(os.getenv('ROBOT_CLI_PORT', '14001'))
        self.max_connections = self.get_max_connections()


    def get_arg(self, arg_name):
        index = self.args.index(arg_name)
        return self.args[index+1]

    def get_max_connections(self):
        return self.port - 14000

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
        # set up logging INFO messages or higher to the sys.stdout
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

class dummy_remote_cli(object):
    # Echo server program

    def __init__(self, port, max_count=1):
        self.port = port        # Arbitrary non-privileged port
        self.host = ''          # Symbolic name meaning all available interfaces
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.bind((self.host, self.port))
        self.connection = None
        self.max_connect_count = max_count
        self.connect_count = 0
        self.socket.listen(1)
        self.logger = logging.getLogger('dummy_cli')


    def listen_socket(self):
        quit = False
        self.logger.info( 'dummy remote_cli listen on port %i' % self.port)
        while (not quit) and (self.connect_count < self.max_connect_count):
            self.connect_count += 1
            quit = self.listen_connection()
        if quit:
            self.logger.info( 'dummy remote_cli exit - quit is requested' )
        else:
            self.logger.info( 'dummy remote_cli exit - number of connections %i' % self.connect_count)

        self.socket.close()

    def listen_connection(self):
        self.connection, addr = self.socket.accept()
        self.logger.info( 'dummy remote_cli accpets connection to {}'.format(addr))
        while 1:
            data = self.connection.recv(1024)
            self.logger.info( "{} wrote:".format(addr) )
            self.logger.info( data )

            if self.check_close_connection(data) is True: break
            response = self.calc_response(data)
            self.connection.sendall(response)
        self.connection.close()
        self.logger.info( 'dummy remote_cli closes connection' )
        return self.check_close_socket(data)

    def calc_response(self, data):
        return data.upper()

    def check_close_socket(self, data):
        return data == 'Exit()'

    def check_close_connection(self, data):
        return (not data) or (self.check_close_socket(data) )



def main():
    a_launcher = dummy_gis_launcher(sys.argv[1:])
    a_launcher.run_dummy_gis()

if __name__ == '__main__':
    main()
