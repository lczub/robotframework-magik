Changes in Robot Framework Magik (RFM)
======================================

Robot Framework Magik release notes v0.6.0 (under construction)
---------------------------------------------------------------

- Enh #26: Support RF 6.0 and PY 3.11

  - Running RFM using `RF Standalone JAR distribution  <http://robotframework.org/robotframework/4.1.2/RobotFrameworkUserGuide.html#standalone-jar-distribution>`_ is not possible anymore, cause since `RF 5.x Jython is not supported <https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-5.0.rst#python-2-is-not-supported-anymore>`_

- Enh #36: Cleanup Pipfile dependencies

  - pipenv pipfile installation sample replaced with venv pip requirements file

Robot Framework Magik release notes v0.5.2 (Jun. 2020)
------------------------------------------------------


- Enh #29: Support additional gis args
  
  - Library *RobotMagikLaunch* and Python script *robot_start_magik_image.py* are extend with new argument *gis_args*
  - allows to define additional args like ``-cli -login uname/pw`` beside the ones defined in ALIAS 

- Enh #23: Support running OpenSmallworld MUnit tests

  - adds in *robot_magik_base*:
  
    - new keywords: *Load Magik File*, *Load Magik Module*
    - new variable ${MAGIK_MAX_LOAD_WAIT} to define max wait time for prompt, when loading magik code (file or module)
    - new variable ${MAGIK_LOAD_ERROR_REGEXP} to define  regular expression to search for load errors like ``**** Fehler:`` or ``**** Error:``

  - new *robot_magik_munit* keyword resource file:
  
    - main keywords:
	  - *Prepare MUnit*, *Run MUnit Testsuite Logging to File*, *Load Module with MUnit Tests and Start Test Runner*
	  - *Evaluate MUnit Text Log*, *Evaluate MUnit XML Log*
    - main variables
	  - ${ROBOT_MUNIT_LOADFILE} to define magik file loading munit base modules and other required base test code. modules with tests should be loaded separately
      - ${ROBOT_MUNIT_MAX_LOAD_WAIT} to define max wait time for prompt, when loading munit code (files or modules)
      - ${ROBOT_MUNIT_MAX_RUN_WAIT} to define max wait time for prompt, when running a munit test suite
  
- Ant Build configuration added

  - main targets *robot_run*, *update_keywords_doc*, *make_release*, *test_release*, *test_examples*

- additional *robot_magik_base* changes

  - new variable ${MAGIK_PROMPT_REGEXP} to customized Magik prompt search
  - new keyword *Get Smallworld Version*
  - documenation updated for keywords *Build Magik Object Expresssion*, *Store Magik Object* and *Get Magik Object* and customisation
 
 
Robot Framework Magik release notes v0.5.1 (Nov. 2019)
---------------------------------------------------------------

- Enh #22: Support nested aliases

  - Library *RobotMagikLaunch* and Python script *robot_start_magik_image.py* are extend with new argument *nested_aliases*
  - if defined, Magik image is started without setting the argument ``-l logfile``

- Documentation references now also SW41 as supported

Robot Framework Magik release notes v0.5.0 (Sep. 2019)
----------------------------------------------------------

- Support Robot Standalone JAR Distribution

  - changes #19 and #20 allow to run Robot Framework Magik tests in a pure jave envrionment using the Robot Standalone JAR Distribution
  - a separate Python installation is not required
  - tested with robotframework-3.1.2.jar

- Enh #19: Support Robot Framework 3.1 and Python 3.7

  - Robot Framework Magik keywords are now compatible with Robot Framework Version 3.1.1
  - Library *RobotMagikLaunch* and Python script *robot_start_magik_image.py* are now compatible with Python 3.7
  - resource and test filename extension changed from *.txt* to *.robot*
 
- Enh #20: session start with special java environment

  - Library *RobotMagikLaunch* and Python script *robot_start_magik_image.py* are extend with new argument *java_home*
  - if defined, environment variable JAVA_HOME is set (or overwritten) for the process
  - required to start sw5x sessions or testing java acp with a specific java 

- Enh #21: SW 5.2 sample configuration added

Robot Framework Magik release notes v0.4.4 (Dec. 2016)
----------------------------------------------------------

- Enh #18: session start with special environment.bat files

  - Library *RobotMagikLaunch* and Python script *robot_start_magik_image.py* are extend with new argument *envfile*
  - if defined, environment variable SW_GIS_ENVIRONMENT_FILE is defined and *gis.exe* is call with param *-e*

- Enh #17: variablefiles for example and self tests

  - varibles for example and robot magik own test runs can no be defined in variablefiles
  - new directory *resources/params* includes templates for different gis and session definitions

- Enh #16: Robot library RobotMagikLaunch to start and stop Magik image / session

  - New Library *resources/RobotMagikLaunch* defines keyword to start, stop and handle several Magik images / sessions
  - library *RobotMagikLaunch* uses the Robot Framework library *Process* for handling the image / session process
  - Python script *robot_start_magik_image.py* and library *RobotMagikLaunch* uses new Python class *MagikSession* for handling imagee / sessions
  - script directory with Python and Magik start stop scripts are moved to *resources/scripts*

- Bug #12: *Close Magik Connection* does not call exit() anymore

  Keyword *Close Magik Connection* has called *exit()* before closing the connecting.
  This was not correct, cause *exit()* is only known inside the SW GIS internal cli client. 
  Under GIS 4.0, this failure has no negativ effect. But under GIS 5.0, the remote_cli tries to 
  write a traceback to the closed streams. This create than an endless traceback loop.
  
- Enh #13: prompt search works now with *MagikSF>* and *Magik>* 

  - future SW GIS 5.x releases maybe uses a *Magik>* instead *MagikSF>* prompt 

- Enh #15: internal tests for start stop scripts 

  - new robot suite tests/scripts/robot_magik_script_tests.txt
  - new python helper scripts *dummy_gis_launcher.py* and *dummy_remote_cli.py* 

- Enh #14: robot_start_remote_cli except know unconventional localhost IP addresses
  matching *\*.0.0.0.0.0.0.1*


Robot Framework Magik release notes v0.3.2 (Apr. 2015)
-------------------------------------------------------

- Enh #11: remote_cli connection uses now a specific text encoding 

  - default setting ISO-8859-1 can be changed via parameter CLI_ENCODING

Robot Framework Magik release notes v0.3.1 (Jan. 2014)
-------------------------------------------------------

- Fix #9: keyword 'Execute Magik Command' has problems with strings, including '\n', '\t' or '\f' substrings 
- Add #10: new keyword 'Get Magik Environment Variable'

Robot Framework Magik release notes v0.3.0 (Nov. 2012)
-------------------------------------------------------

new dsview keywords and improved base keywords
