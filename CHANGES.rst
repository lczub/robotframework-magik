Changes in Robot Framework Magik
================================

Robot Framework Magik release notes v0.4.4 - under develop
----------------------------------------------------------

- Enh #16: keywords to start and stop Magik image / session - UNDER DEVELOP

  New Library *resources/RobotMagikLaunch*
  
  script directory with python and magik start stop scripts has moved to 
  *resources/scripts*

  new directory *resources/params* with variable files for different gis and sesion definition

- Bug #12: *Close Magik Connection* does not call exit() anymore #12 

  Keyword *Close Magik Connection* has called *exit()* before closing the connecting.
  This was not correct, cause *exit()* is only known inside the SW GIS internal cli client. 
  Under GIS 4.0, this failure has no negativ effect. But under GIS 5.0, the remote_cli tries to 
  write a traceback to the closed streams. This create than an endless traceback loop.
  
- Enh #13: prompt search works now with *MagikSF>* and *Magik>* 

  - future SW GIS 5.x releases maybe uses a *Magik>* instead *MagikSF>* prompt 

- Enh #15: internal tests for start stop scripts 

  - new robot suite tests/scripts/robot_magik_script_tests.txt
  - new python helper scripts _dummy_gis_launcher.py_ and _dummy_remote_cli.py_ 

- Enh #14: robot_start_remote_cli except know unconventional localhost IP addresses
  matching _*.0.0.0.0.0.0.1_


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
