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

import os, sys
import socket
import logging
#import codecs



class dummy_remote_cli(object):
    # Echo server program

    response_templates = {
        # Test keyword 'Write Magik Command'
        '1 + 1' : '2 ',
        # Test keyword 'Read Magik Output'
        'write("1 ernie", %newline, "2 bert", %newline, "3 bibo")' : '1 ernie\n2 bert\n3 bibo' ,
        '1.as_error()' : '''*** Fehler: Object 1 does not understand message as_error()
     does_not_understand(object=1, selector=:|as_error()|, arguments=sw:simple_vector:[1-0], iterator?=False, private?=False)

---- traceback: remote_cli_client (heavy_thread 3779521) ----
time=04.01.2016 20:52:41
sw!version=4.3.0.6 (swaf)
os_text_encoding=cp1252
!snapshot_traceback?!=False

condition(information).raise(:does_not_understand, {{:object, 1, :selector, :|as_error()|, ... <size=10>}})
1.does_not_understand(a sw:message, False)
1.sys!send_error(:|as_error()|, method_table for sw:integer, False, 1, sw:simple_vector:[1-0])
*** top level ***()
a sw:remote_magik_rep.process(sw:simple_vector:[1-5])
a sw:remote_magik_rep.cli(a sw:remote_terminal, "{0.prompt} ")
remote_cli_client({0.port}, a sw:tcpip_connection)
remote_cli_client({0.port}, a sw:tcpip_connection)
light_thread_launcher_proc_990928()''',
        # Test keyword 'Read Magik Output' - should search parser_error
        ':BigBird_:SmallBird' : '''**** Fehler (parser_error): on line 1
:BigBird_:SmallBird
         ^
Missing end of statement''',
        # Test keyword 'Execute Magik Command'
        'write("1 erwin", %newline, "2 ulf", %newline, "3 hein")' : '1 erwin\n2 ulf\n3 hein',
        '3 - 2' : '1 ',
        # Test keyword 'Execute Magik Command' - should handle empty results
        'write()' : '',
        # Test keyword 'Execute Magik Command' - should remove trailing spaces
        'write("1 BigBird ")' : '1 BigBird ',
        # Test keyword 'Store Magik Object'
        'robot_objhash[:ernie]' : '22',
        # Test keyword 'Get Magik Object'
        'robot_objhash[:monster]' : ':no_bird',
        # bug-009 Execute Magik Command - should handle strings with \n \t \f
        'write("12\\t23\\\\45\\n78\\f90")' : '12\\t23\\\\45\\n78\\f90',
        # Test special characters
        u'write("äöüßÄÖÜ")' : u'äöüßÄÖÜ',
        'message_handler(:gis_program_manager).text_for_message(:save_environment)' : u'Änderung',
        }

    def __init__(self, port, max_count=1, prompt='MagikSF>', coding='iso-8859-1'):
        self.port = int(port)   # Arbitrary non-privileged port
        self.host = ''          # Symbolic name meaning all available interfaces
        self.coding = coding
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
        lastpart = prompt
        if lastpart[-1] != '>':
            # last sign must be '>'
            lastpart = '{}>'.format(lastpart)
        self.prompt = 'dummy:{}:{}'.format(self.port,lastpart)

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
            self.logger.info( 'dummy remote_cli quit - quit is requested' )
        else:
            self.logger.info( 'dummy remote_cli quit - number of connections %i' % self.connect_count)

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

                data = self.connection.recv(1024).decode(self.coding)
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
        a_response = self.get_prepared_response(a_magik_expression)

        return ' {}\n{}'.format(a_response,self.prompt)

    def get_prepared_response(self, magik_expression):
        ''' get a matching template for MAGIK_EXPRESSION from .response_template
        and format it with attributes from self '''

        if magik_expression.find('system.putenv') >= 0:
            # special case, we have to simulate to store environment variable
            # required for Test keyword 'Get Magik Environment Variable'
            magik_expression = self.store_putenv(magik_expression)
        elif magik_expression.find('robot_objhash <<') >= 0:
            # special case, we have to simulate to store robot objhash
            # required for Test keyword 'Prepare Magik Image'
            # and Test keyword 'Clean Magik Image'
            magik_expression = self.store_objhash(magik_expression)

        a_template = self.response_templates.get(magik_expression,
                                                 magik_expression)
        a_response = a_template.format(self)
        return a_response

    def store_putenv(self, putenv_expression):
        ''' extract from putenv expression the env value and store a getenv
        expression with this value inside .response_templates '''

        # split 'system.putenv("ROBOT_MAGIK_KWTEST", "huhu")' into
        # ['system.putenv(', 'ROBOT_MAGIK_KWTEST', ', ', 'huhu', ')']
        splitter = putenv_expression.split('"')
        env_name  = splitter[1]
        env_value = splitter[3]
        # getenv expression to store
        # 'system.getenv("ROBOT_MAGIK_KWTEST")' : "huhu")
        getenv_expression = 'system.getenv("{}")'.format(env_name)
        getenv_value = '"{}"'.format(env_value)
        if env_value == '':
            # special case env variable not defined
            getenv_value = 'unset'
        self.response_templates[getenv_expression] = getenv_value
        return getenv_value

    def store_objhash(self, objhash_expression):
        ''' extract from objhash expression the state of the robot_objhash and
        store a robot_objhash expression with the state ubset or hash_table '''

        # split '_global robot_objhash << _unset' into
        #      ['_global', 'robot_objhash', '<<', '_unset']
        # or    '_global robot_objhash << hash_table.new()' into
        #      ['_global', 'robot_objhash', '<<', 'hash_table.new()']
        splitter = objhash_expression.split(' ')
        # state objhash is set
        state  = 'sw:hash_table(10)'

        if splitter[3] == '_unset':
            # state objhash is reset
            state = 'unset '

        self.response_templates['robot_objhash'] = state

        return state


    def send_response(self, data, first=False):
        ''' Calculates the CLI reponses.
        First response is just the Prompt, the following a combination out of
        data and the prompt '''

        # the special case - just the prompt
        response = self.prompt

        if not first:
            # the default case - special data plus prompt
            response = self.calc_response(data)
        self.connection.sendall( response.encode(self.coding) )
        self.logger.info( "send data: {}".format(response) )

    def check_close_socket(self, data):
        ' When quit() is required , the hole simulated cli session is closed '

        return ( data.find('quit()') == 0 )

    def check_close_connection(self, data):
        ' check if client will close the connection '
        check_close = False
        if not data:
            self.logger.info('close connection requested')
            check_close = True

        return (check_close) or (self.check_close_socket(data) )

def main():
    a_cli = dummy_remote_cli(*sys.argv[1:])
    a_cli.listen_socket()

if __name__ == '__main__':
    main()
