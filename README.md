Robot Framework Magik
=====================

Copyright 2012 Luiko Czub, [Smallcases GmbH]
License [Apache License 2.0]

Introduction
------------

Provides [Robot Framework] high level keywords for automated testing 
[Smallworld Magik] images and Python scripts to start and stop Smallworld 
Images with a remote_cli.

The Robot Magik keywords *robot_magik_base.txt* uses the [TelnetLibrary] to send
commands to Magik images and read there response. 
*   Precondition is, that the Magik image must have started a remote_cli.
*   Details, how to start a remote_cli manually and which keywords exists, see 
    [Keyword Documentation].
*   Use the Python script *scripts/robot_start_magik_image.py* to start 
    automatically an image with a remote_cli

The Python script *robot_start_magik_image.py*
*   starts a Smallworld Magik image via the gis.exe launcher program on Windows
*   starts a remote_cli inside this image
*   stores the process id in a Pid-File

The Python script *robot_stop_magik_image.py*
*   reads the Pid-File and stops the Smallworld Magik image by sending a kill 
    signal to the process

Directory Layout
----------------

resources/
*   Definition of Robot Framework Magik keywords

scripts/
*   Python and Magik scripts to start and stop automatically an image with a 
    remote_cli

doc/
*   Documentation for Robot Framework Magik keywords

tests/
*   Test suites for Robot Framework Magik keywords

examples/
*   Examples, how Robot Framework Magik keywords could be used for automated 
    testing [Smallworld Magik] images

Download
--------

see [downloads] or latest [tag zip or tar ball]

Tutorial
--------

The Python script *robot_start_magik_image.py* implements two different start
mechanism for closed and startup images.
*   for closed images, the environment variable *SW_MSF_STARTUP_MAGIK* is used 
    to load the Magik script *start_robot_remote_cli.magik*, which starts 
	remote_cli. 
*   for startup images, the image command line option *-run_script* is used to 
    load the script *start_robot_remote_cli.script*, which adds a 
	startup_procedur to start the remote_cli as last startup action.
	
The following examples explains, how the start, test and stop of an image 
works.

### Example A - run tests in a closed image

Precondition
*   Alias *swaf* is defined in the products gis_alias file
*   current working directory is *robotframework-magik*

#### start the closed image with remote_cli

```
SET PATH=%PATH%;C:\Python-27
python scripts\robot_start_magik_image.py --msf_startup e:\Smallworld\CST42\product swaf
```

*   The *swaf* image is running with a remote_cli, listening on port 14001.
*   The gis buffer log-file *swaf-mmdd-hhmm-PID.log* and pid-file 
    *14001.pid* are written to the users temp directory.

#### run example tests on the closed image

```
SET PATH=%PATH%;C:\Python-27;C:\Python-27\Scripts
pybot examples
```

*   The [Robot Framework] test reports are written into the current working 
    directory.

#### stop the closed image

```
SET PATH=%PATH%;C:\Python-27
python robot_stop_magik_image.py
```

*   The image is closed and the pid-file *14001.pid* is deleted.

### Example B - run tests in a startup image

Precondition
*   Alias *cam_db_open_swaf* is defined in a separate gis_alias file
*   current working directory is *robotframework-magik*

#### start the startup image with remote_cli

```
SET PATH=%PATH%;C:\Python-27
python scripts\robot_start_magik_image.py --aliasfile e:\test\gis_aliases 
       --piddir e:\tmp\robot\pids --logdir e:\tmp\robot\logs 
       --login root/  --cli_port 14003 --wait 10
       e:\Smallworld\CST42\product cam_db_open_swaf
```

*   Now the cam_db_open_swaf image is running with a remote_cli, listening on 
    port 14003 under user *root*.
*   The gis buffer log-file *cam_db_open_swaf image-mmdd-hhmm-PID.log* is 
    written to *e:\tmp\robot\logs *.
*	The pid-file *14003.pid* is written to *e:\tmp\robot\pids*
*   The start process has wait *10 seconds* for checking the telnet connection.

#### run example and self tests on the startup image

```
SET PATH=%PATH%;C:\Python-27;C:\Python-27\Scripts
pybot --include Keyword* --include Example* --variable CLI_PORT:14003
      --outputdir e:\tmp\robot\logs --xunitfile cbg_tests.xml 
	  .\tests .\examples
```

*   The [Robot Framework] test reports are written into *e:\tmp\robot\logs*
*   Additional XUnit test report *cbg_tests.xml* is written, which can be used 
    as input for tools that process XUnit data (like CI Server Jenkins).
*   Only tests with *Keyword* and *Example* tags are run.
 

#### stop the startup image

```
SET PATH=%PATH%;C:\Python-27
python robot_stop_magik_image.py --piddir e:\tmp\robot\pids --cli_port 14003
```

The image is closed and the pid-file *14003.pid* is deleted.



[Smallcases GmbH]: http://www.smallcases.de
[Apache License 2.0]: http://www.apache.org/licenses/LICENSE-2.0
[Robot Framework]: http://code.google.com/p/robotframework
[Smallworld Magik]: https://en.wikipedia.org/wiki/Magik_%28programming_language%29
[TelnetLibrary]: http://code.google.com/p/robotframework/wiki/TelnetLibrary
[Keyword Documentation]: http://lczub.github.com/robotframework-magik/doc/robot_magik_base.html
[tag zip or tar ball]: https://github.com/lczub/robotframework-magik/tags
[downloads]: https://github.com/lczub/robotframework-magik/downloads