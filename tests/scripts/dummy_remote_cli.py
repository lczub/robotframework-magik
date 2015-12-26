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



class dummy_remote_cli(object):
    # Echo server program
    
    prepared_responses = {'1 + 1' : '2 ',
                'write("1 ernie", %newline, "2 bert", %newline, "3 bibo")' : '1 ernie\n2 bert\n3 bibo' ,
                '1.as_error()' : ' OhOh a traceback:'}

    def __init__(self, port, max_count=1, prompt='MagikSF>'):
        self.port = int(port)   # Arbitrary non-privileged port
        self.host = ''          # Symbolic name meaning all available interfaces
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.bind((self.host, self.port))
        self.connection = None
        self.max_connect_count = int(max_count)
        self.connect_count = 0
        self.set_prompt(prompt)
        self.socket.listen(1)
        self.config_logger()
        self.logger = logging.getLogger('dummy_cli')
        
    def set_prompt(self, prompt):
        self.prompt = 'dummy:{}:{}'.format(self.port,prompt)
        
    def config_logger(self, level=logging.INFO):
        ' set up logging INFO messages or higher to the sys.stdout '
        logging.basicConfig(level=logging.INFO, 
                            format='%(asctime)s %(name)-10s %(levelname)-8s %(message)s',
                            datefmt='%m-%d %H:%M',
                            stream=sys.stdout)


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
        self.logger.info( 'dummy remote_cli accepts connection to {}'.format(addr))
        # first response must be the pure Magik prompt
        data = 'first data will be the prompt'
        first = True
        try:
            while (self.check_close_connection(data) is False):
                self.send_response(data, first)
                first = False
                
                data = self.connection.recv(1024)
                self.logger.info( "{} wrote:".format(addr) )
                self.logger.info( data )

        except socket.error as msg:
            self.logger.info('other site has closed the connection: {}'.format(msg))
        finally:
            self.connection.close()
            self.logger.info( 'dummy remote_cli closes connection' )

            
        return self.check_close_socket(data)

    def calc_response(self, data):
        ''' Response is composed out of DATA plus Magik-Prompt
        From data, only the first line includes a MAgik expression.
        For this, a prepared response must be search or new calculated '''
        
        a_magik_expression = data.split('\n')[0]
        # try to get a prepared response. 
        # Default response is the expression itself
        a_response = self.prepared_responses.get(a_magik_expression, 
                                                 a_magik_expression)
        
        return '\n{}\n{}'.format(a_response,self.prompt)
    
    def get_prepared_response(self, an_expression):
        ''
        self.prepared_responses.get
        
    
    def send_response(self, data, first=False):
        ''' Calculates the CLI reponses.
        First response is just the Prompt, the following a combination out of 
        data and the prompt '''
        
        # the special case - just the prompt
        response = self.prompt
        
        if not first:
            # the default case - special data plus prompt 
            response = self.calc_response(data)
        self.connection.sendall(response)
        self.logger.info( "send data: {}".format(response) )

    def check_close_socket(self, data):
        return data == 'Exit()'

    def check_close_connection(self, data):
        return (not data) or (self.check_close_socket(data) )

def main():
    a_cli = dummy_remote_cli(sys.argv[1], sys.argv[2])
    a_cli.listen_socket()

if __name__ == '__main__':
    main()
