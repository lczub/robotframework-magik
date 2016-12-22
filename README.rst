Robot Framework Magik
=====================

Copyright 2012-2016 Luiko Czub, `Smallcases Software GmbH`_
License `Apache License 2.0`_

Introduction
------------

Provides `Robot Framework`_ high level keywords for automated testing 
`Smallworld Magik`_ images / sessions and Python scripts to start and stop 
Smallworld Images with a remote_cli.

The Robot Magik keywords robot_magik_base.txt_ uses the `TelnetLibrary`_ to send
commands to Magik images and read there response. 

- Precondition is, that the Magik image or session must have started remote_cli.
  See library RobotMagikLauncher.py_ or script robot_start_magik_image.py_
- Details, how to start a remote_cli manually and which keywords exists, see 
  `Keyword Documentation robot_magik_base`_.
- Use library RobotMagikLauncher.py_ to start an image or session directly 
  inside the robot test suite (for example as setup )
- or use the Python script robot_start_magik_image.py_ to 
  start automatically an image with a remote_cli outside the robot test

The Robot Magik keywords robot_magik_dsview.txt_ defines additional keywords 
for testing Smallworld ds_views, ds_collections and rwo records.

- see `Keyword Documentation robot_magik_dsview`_.

The Robot Magik library RobotMagikLauncher.py_ defines keyword to start and stop 
Magik images (SW4.x) or sessions (SW5.x) directly inside a robot test suite

- see `Keyword Documentation RobotMagikLauncher`_.

The Python script robot_start_magik_image.py_
- starts a Smallworld Magik image via the gis.exe launcher program on Windows
- starts a remote_cli inside this image
- stores the process id in a Pid-File

The Python script robot_stop_magik_image.py_

- reads the Pid-File and stops the Smallworld Magik image by sending a kill 
  signal to the process

Directory Layout
----------------

resources/
    Definition of Robot Framework Magik keywords

resources/scripts/
    Python and Magik scripts to start and stop automatically an image with a 
    remote_cli

doc/
    Documentation for Robot Framework Magik keywords

tests/
    Test suites for Robot Framework Magik keywords

examples/
    Examples, how Robot Framework Magik keywords could be used for automated 
    testing `Smallworld Magik`_ images

Download
--------

download current `master as zip`_ or latest `releases`_

- Attention: the tags are listed in an alphabetic order and not after the date!

Tutorial
--------

The library RobotMagikLauncher.py_ (and also the Python script 
robot_start_magik_image.py_) implements two different start mechanism for 
closed and startup images.

- for closed images, the environment variable *SW_MSF_STARTUP_MAGIK* is used 
  to load the Magik script start_robot_remote_cli.magik_, which starts 
  remote_cli. 
- for startup images, the gis launcher command line option *-run_script* is 
  used to load the script start_robot_remote_cli.script_, which adds a 
  startup_procedur to start the remote_cli as last startup action.
- Cause Smallworld 5.0 does not support the gis launcher command line option
  *-run_script*, Smallworld 5.0 sessions must be started using the environment
  variable *SW_MSF_STARTUP_MAGIK*
	
The following examples explains, how the start, test and stop of an image 
works.

Example A - start gis and run example test completly inside robot
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Precondition

- Adjust variable file .\\resources\\params\\variables_sw43_cbg.py for your SW4.x product 
- Adjust variable file .\\resources\\params\\variables_sw51_cbg.py for your SW5.x product

start gis and run example test under Smallworld 4.x
####################################################
::

 SET PATH=%PATH%;C:\Python-27;C:\Python-27\Scripts
 pybot --critical DsView* --variablefile variables_sw43_cbg.py examples

run example test under Smallworld 5.x
####################################################
::

 SET PATH=%PATH%;C:\Python-27;C:\Python-27\Scripts
 pybot --critical DsView* --variablefile variables_sw51_cbg.py examples

Example B - run tests in a closed image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Precondition

- Alias *swaf* is defined in the products gis_alias file
- current working directory is *robotframework-magik*

start the closed image with remote_cli
####################################################
::

 SET PATH=%PATH%;C:\Python-27
 python resources\scripts\robot_start_magik_image.py --msf_startup e:\Smallworld\CST42\product swaf

- The *swaf* image is running with a remote_cli, listening on port 14001.
- The gis buffer log-file *swaf-mmdd-hhmm-PID.log* and pid-file 
  *14001.pid* are written to the users temp directory.

run example tests on the closed image
####################################################
::

 SET PATH=%PATH%;C:\Python-27;C:\Python-27\Scripts
 pybot --exclude DsView* examples\c*

- run all *Non DsView* example tests - see *[TAGS]* label inside the test definition files
- The `Robot Framework`_ test reports are written into the current working 
  directory.

stop the closed image
####################################################
::

 SET PATH=%PATH%;C:\Python-27
 python resources\scripts\robot_stop_magik_image.py

- The image is closed and the pid-file *14001.pid* is deleted.

Example C - run tests in a startup image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Precondition
- Alias *cam_db_open_swaf* is defined in a separate gis_alias file
- current working directory is *robotframework-magik*

start the startup image with remote_cli
####################################################
::

 SET PATH=%PATH%;C:\Python-27
 python resources\scripts\robot_start_magik_image.py 
        --aliasfile e:\test\gis_aliases 
        --piddir e:\tmp\robot\pids --logdir e:\tmp\robot\logs 
        --login root/  --cli_port 14003 --wait 10
        e:\Smallworld\CST42\product cam_db_open_swaf

- Now the cam_db_open_swaf image is running with a remote_cli, listening on 
  port 14003 under user *root*.
- The gis buffer log-file *cam_db_open_swaf image-mmdd-hhmm-PID.log* is 
  written to *e:\\tmp\\robot\\logs*.
- The pid-file *14003.pid* is written to *e:\\tmp\\robot\\pids*
- The start process has wait *10 seconds* for checking the telnet connection.

run example and self tests on the startup image
####################################################
::

 SET PATH=%PATH%;C:\Python-27;C:\Python-27\Scripts
 pybot --include Keyword* --include Example* --variable CLI_PORT:14003
       --outputdir e:\tmp\robot\logs --xunitfile cbg_tests.xml 
	   .\tests .\examples\c*

- The `Robot Framework`_ test reports are written into *e:\\tmp\\robot\\logs*
- Additional XUnit test report *cbg_tests.xml* is written, which can be used 
  as input for tools that process XUnit data (like CI Server Jenkins).
- Only tests with *Keyword* and *Example* tags are run.
 

stop the startup image
####################################################
::

 SET PATH=%PATH%;C:\Python-27
 python resources\scripts\robot_stop_magik_image.py 
        --piddir e:\tmp\robot\pids --cli_port 14003

The image is closed and the pid-file *14003.pid* is deleted.



.. _Smallcases Software GmbH: http://www.smallcases.de
.. _Apache License 2.0: http://www.apache.org/licenses/LICENSE-2.0
.. _Robot Framework: http://robotframework.org
.. _Smallworld Magik: https://en.wikipedia.org/wiki/Magik_%28programming_language%29
.. _TelnetLibrary: http://robotframework.org/robotframework/latest/libraries/Telnet.html
.. _Keyword Documentation robot_magik_base: http://lczub.github.com/robotframework-magik/doc/robot_magik_base.html
.. _Keyword Documentation robot_magik_dsview: http://lczub.github.com/robotframework-magik/doc/robot_magik_dsview.html
.. _Keyword Documentation RobotMagikLauncher: http://lczub.github.com/robotframework-magik/doc/RobotMagikLauncher.html
.. _releases: https://github.com/lczub/robotframework-magik/releases
.. _master as zip: https://github.com/lczub/robotframework-magik/archive/master.zip
.. _RobotMagikLauncher.py: resources/RobotMagikLauncher.py
.. _robot_start_magik_image.py: resources/scripts/robot_start_magik_image.py
.. _robot_magik_base.txt: resources/robot_magik_base.txt
.. _robot_magik_dsview.txt: resources/robot_magik_dsview.txt
.. _robot_stop_magik_image.py: resources/scripts/robot_stop_magik_image.py
.. _start_robot_remote_cli.magik: resources/scripts/start_robot_remote_cli.magik
.. _start_robot_remote_cli.script: resources/scripts/start_robot_remote_cli.script
