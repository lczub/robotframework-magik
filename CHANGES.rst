Changes in Robot Framework Magik
================================

Robot Framework Magik release notes v0.4.4 - under develop
----------------------------------------------------------

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
