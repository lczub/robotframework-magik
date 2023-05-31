Robot Framework Magik (RFM)
===========================

Copyright 2012-2023 Luiko Czub, `Smallcases Software GmbH`_
License `Apache License 2.0`_

Introduction
------------

Provides `Robot Framework`_ keywords for automated testing `Smallworld Magik`_
images (4.x) and sessions (5.x).
It includes also a Robot library and Python scripts to start and stop Magik 
images (4.x) / sessions (5.x) with a remote_cli. 


Some feature
^^^^^^^^^^^^

- each production image / session based on a *swaf* can be tested without loading additional modification code
- `Robot Framework`_ keyword-driven testing approach allows to hide complex Magik requests in readable keywords
- supports Smallworld 4.1/4.2/4.3 images and Smallworld 5.1/5.2 sessions
- supports loading, running and evaluating `OpenSmallworld MUnit`_ tests
- it is possible to handle several images / sessions during one test run, for example to test their interaction
- in combination with Robot Framework `Standard Test Libraries`_  like *XML /  OperatingSystem* or `External Test Libraries`_ like *Selenium2Library / Database Library / HTTP library* allows to test the interaction with external systems 
- the communication via telnet allows to test images / sessions running in a different network

**Robot Framework Magik** can also be used as a remote control for Magik images (4.x) and sessions (5.x)

Some details
^^^^^^^^^^^^

The Robot Magik keywords robot_magik_base.robot_ uses the TelnetLibrary_ sending
commands to Magik images / sessions and read their response. 
Precondition is, that  Magik image / session under test has started a 
remote_cli to allow a telnet communication.

- `Keyword Documentation robot_magik_base`_ explains, how to start a remote_cli
  manually and which keywords exists
- Use library RobotMagikLauncher.py_ to start an image / session directly 
  inside the robot tests (for example as suite setup )
- or use the Python script robot_start_magik_image.py_ to 
  start an image / session with a remote_cli from outside the robot test
  
The Robot Magik keywords robot_magik_munit.robot_ defines additional keywords 
for loading, running and evaluating `OpenSmallworld MUnit`_ tests.

- see `Keyword Documentation robot_magik_munit`_.

The Robot Magik keywords robot_magik_dsview.robot_ defines additional keywords 
for testing Smallworld ds_views, ds_collections and rwo_records.

- see `Keyword Documentation robot_magik_dsview`_.

The Robot Magik library RobotMagikLauncher.py_ defines keyword to start and stop 
Magik images (SW4.x) or sessions (SW5.x) directly inside a robot test suite via 
the gis.exe launcher program on Windows

- see `Keyword Documentation RobotMagikLauncher`_.
- uses the ProcessLibrary_ for handling the image / session process

The Python script robot_start_magik_image.py_ starts Magik images (SW4.x) or 
sessions (SW5.x) outside a robot test run via the gis.exe launcher program on Windows

- starts a remote_cli inside this image
- stores the process id in a Pid-File

The Python script robot_stop_magik_image.py_

- reads the Pid-File and stops the Smallworld Magik image by sending a kill 
  signal to the process

Installation
^^^^^^^^^^^^
A Python 3.11 environment is recommended with Robot Framework Version 6.0.2 .

good practice is to use a separate virtualenv::

 py -3.11 -m venv D:\pyenv\robot
 D:\pyenv\robot\scripts\activate
 pip install --no-cache-dir robotframework~=6.0
 
download current `master as zip`_ or latest `releases`_ and extract it (for example
to *D:\\robotframework-magik*). Now you are able to start the example test via::

 D:\pyenv\robot\scripts\activate
 cd D:\robotframework-magik
 robot --variablefile resources\params\variables_sw43_cbg.py examples
 
Alternative installations see `RobotFramework UserGuide Installation`_ .
Or install required packages using sample `requirements.txt`_ included in RFM download:: 

 py -3.11 -m venv my_robot_venv
 my_robot_venv\scripts\activate
 python -m pip install --upgrade pip
 python -m pip install --upgrade -r requirements.txt

History
^^^^^^^^^^^^
see `<CHANGES.rst>`_

Directory Layout
----------------

resources/
    Definition of Robot Framework Magik keywords

resources/scripts/
    Python and Magik scripts to start and stop an image / session with a remote_cli

doc/
    Documentation for Robot Framework Magik keywords

tests/
    self-testig suites for Robot Framework Magik keywords, library and scripts
    

examples/
    Examples, how Robot Framework Magik keywords could be used for automated 
    testing `Smallworld Magik`_ images / sessions


Tutorial
--------

The library RobotMagikLauncher.py_ (and also the Python script 
robot_start_magik_image.py_) implements two different start mechanism for 
closed and startup images.

- for closed images, the environment variable *SW_MSF_STARTUP_MAGIK* is used 
  to load the Magik script start_robot_remote_cli.magik_, which starts a
  remote_cli. 
- for startup images, the gis launcher command line option *-run_script* is 
  used to load the script start_robot_remote_cli.script_, which adds a 
  startup_procedure to start the remote_cli as last startup action.
- Cause Smallworld 5.x does not support the gis launcher command line option
  *-run_script*, Smallworld 5.x sessions must be started using the environment
  variable *SW_MSF_STARTUP_MAGIK*
	
The following examples explains, how the start, test and stop of an image 
works.

Example A - start gis and run example test completly inside robot
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Precondition

- Adjust variable file variables_sw43_cbg.py_ for your SW4.x image to test
- Adjust variable file variables_sw51_cbg.py_ or variables_sw52_cbg.py_ for your SW5.x session to test

Expectation:

- Test should start the image / session , run and check a calculation and stop the image / session

run example test under Smallworld 4.x
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 robot --variablefile resources/params/variables_sw43_cbg.py examples

run example test under Smallworld 5.x
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 robot --variablefile resources/params/variables_sw51_cbg.py examples

Example B - run tests in a closed image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Precondition

- Alias *swaf* is defined in the products gis_alias file
- current working directory is *robotframework-magik*

start the closed image with remote_cli
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 python resources\scripts\robot_start_magik_image.py --msf_startup e:\Smallworld\CST42\product swaf

- The *swaf* image is running with a remote_cli, listening on port 14001.
- The gis buffer log-file *swaf-mmdd-hhmm-PID.log* and pid-file 
  *14001.pid* are written to the users temp directory.

run example tests on the closed image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 robot --exclude DsView* examples\c*

- run all *Non DsView* example tests - see *[TAGS]* label inside the test definition files
- The `Robot Framework`_ test reports are written into the current working 
  directory.

stop the closed image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 python resources\scripts\robot_stop_magik_image.py

- The image is closed and the pid-file *14001.pid* is deleted.

Example C - run tests in a startup image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Precondition

- Alias *cam_db_open_swaf* is defined in a separate gis_alias file
- current working directory is *robotframework-magik*

start the startup image with remote_cli
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 python resources\scripts\robot_start_magik_image.py 
        --msf_startup --java_home e:\tools\jre
        --aliasfile e:\test\gis_aliases 
        --piddir e:\tmp\robot\pids --logdir e:\tmp\robot\logs 
        --login root/  --cli_port 14003 --wait 10
        e:\Smallworld\CST51\product cam_db_open_swaf

- Now the cam_db_open_swaf image is running with a remote_cli, listening on 
  port 14003 under user *root*.
- The gis buffer log-file *cam_db_open_swaf image-mmdd-hhmm-PID.log* is 
  written to *e:\\tmp\\robot\\logs*.
- The pid-file *14003.pid* is written to *e:\\tmp\\robot\\pids*
- The start process has wait *10 seconds* for checking the telnet connection.
- starting a SW5.x session requires to define a --java_home and --msf_startup
- definition --java_home can be replace with defining --env_file ENV_FILE, 
  when ENV_FILE includes a JAVA_HOME defintion or when JAVA_HOME is defined globaly

run example and self tests on the startup image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 robot --include Keyword* --include Example* --variable CLI_PORT:14003
       --outputdir e:\tmp\robot\logs --xunit cbg_tests.xml 
	   .\tests .\examples\c*

- The `Robot Framework`_ test reports are written into *e:\\tmp\\robot\\logs*
- Additional XUnit test report *cbg_tests.xml* is written, which can be used 
  as input for tools that process XUnit data (like CI Server Jenkins).
- Only tests with *Keyword* and *Example* tags are run.
 

stop the startup image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

 python resources\scripts\robot_stop_magik_image.py 
        --piddir e:\tmp\robot\pids --cli_port 14003

The image is closed and the pid-file *14003.pid* is deleted.



.. _Smallcases Software GmbH: http://www.smallcases.de
.. _Apache License 2.0: http://www.apache.org/licenses/LICENSE-2.0
.. _Robot Framework: http://robotframework.org
.. _Smallworld Magik: https://en.wikipedia.org/wiki/Magik_%28programming_language%29
.. _TelnetLibrary: http://robotframework.org/robotframework/latest/libraries/Telnet.html
.. _Keyword Documentation robot_magik_base: http://lczub.github.com/robotframework-magik/doc/robot_magik_base.html
.. _Keyword Documentation robot_magik_munit: http://lczub.github.com/robotframework-magik/doc/robot_magik_munit.html
.. _Keyword Documentation robot_magik_dsview: http://lczub.github.com/robotframework-magik/doc/robot_magik_dsview.html
.. _Keyword Documentation RobotMagikLauncher: http://lczub.github.com/robotframework-magik/doc/RobotMagikLauncher.html
.. _releases: https://github.com/lczub/robotframework-magik/releases
.. _master as zip: https://github.com/lczub/robotframework-magik/archive/master.zip
.. _RobotMagikLauncher.py: resources/RobotMagikLauncher.py
.. _robot_start_magik_image.py: resources/scripts/robot_start_magik_image.py
.. _robot_magik_base.robot: resources/robot_magik_base.robot
.. _robot_magik_munit.robot: resources/robot_magik_munit.robot
.. _robot_magik_dsview.robot: resources/robot_magik_dsview.robot
.. _robot_stop_magik_image.py: resources/scripts/robot_stop_magik_image.py
.. _start_robot_remote_cli.magik: resources/scripts/start_robot_remote_cli.magik
.. _start_robot_remote_cli.script: resources/scripts/start_robot_remote_cli.script
.. _Standard Test Libraries: http://robotframework.org/#libraries
.. _External Test Libraries: http://robotframework.org/#libraries
.. _ProcessLibrary: http://robotframework.org/robotframework/latest/libraries/Process.html
.. _RobotFramework UserGuide Installation: http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#installation-instructions
.. _Jython: http://jython.org/
.. _variables_sw43_cbg.py: resources/params/variables_sw43_cbg.py
.. _variables_sw51_cbg.py: resources/params/variables_sw51_cbg.py
.. _variables_sw52_cbg.py: resources/params/variables_sw52_cbg.py
.. _venv: https://docs.python.org/3/library/venv.html
.. _requirements.txt: https://pip.pypa.io/en/stable/reference/requirements-file-format/
.. _OpenSmallworld MUnit: https://github.com/OpenSmallworld/munit
