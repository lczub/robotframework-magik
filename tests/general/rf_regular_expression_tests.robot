*** Settings ***
Documentation    checking base robot framework regular expression keywords used by RFM

*** Variables ***
${MAGIK_LOAD_ERROR_REGEXP}    \\*\\*\\*\\*.(Error|Fehler):    # Defines default regular expression to search for load errors like ``**** Fehler:`` or ``**** Error:``
${MAGIK_ERROR_SAMPLE}    **** Error: We find an error
${MAGIK_NO_ERROR_SAMPLE}    This is no error

*** Test Cases ***

Test call regexp keyword directly - matching pattern
    Should Match Regexp    ${MAGIK_ERROR_SAMPLE}    ${MAGIK_LOAD_ERROR_REGEXP}

Test call regexp keyword directly - not matching pattern
    Should Not Match Regexp    ${MAGIK_NO_ERROR_SAMPLE}    ${MAGIK_LOAD_ERROR_REGEXP}

Test call regexp keyword via KW - matching pattern
    Check regexp inside KW - matching pattern    ${MAGIK_ERROR_SAMPLE}    ${MAGIK_LOAD_ERROR_REGEXP}

Test call regexp keyword via KW - not matching pattern
    Check regexp inside KW - not matching pattern    ${MAGIK_NO_ERROR_SAMPLE}    ${MAGIK_LOAD_ERROR_REGEXP}

Test call regexp keyword via cascading called KW - matching pattern
    Check regexp by calling other KW - matching pattern    ${MAGIK_ERROR_SAMPLE}    ${MAGIK_LOAD_ERROR_REGEXP}

Test call regexp keyword via cascading called KW - not matching pattern
    Check regexp by calling other KW - not matching pattern    ${MAGIK_NO_ERROR_SAMPLE}    ${MAGIK_LOAD_ERROR_REGEXP}

Test call regexp keyword via cascading called KW - matching pattern - default regexp
    Check regexp by calling other KW - matching pattern    ${MAGIK_ERROR_SAMPLE}

Test call regexp keyword via cascading called KW - not matching pattern - default regexp
    Check regexp by calling other KW - not matching pattern    ${MAGIK_NO_ERROR_SAMPLE}

Test call regexp keyword via KW if - matching pattern
    Run Keyword If    r'${MAGIK_LOAD_ERROR_REGEXP}'!=''    Should Match Regexp    ${MAGIK_ERROR_SAMPLE}    ${MAGIK_LOAD_ERROR_REGEXP}


*** Keywords ***

Check regexp inside KW - matching pattern
    [Arguments]    ${string2check}    ${regexp}
    Should Match Regexp    ${string2check}    ${regexp}

Check regexp inside KW - not matching pattern
    [Arguments]    ${string2check}    ${regexp}
    Should Not Match Regexp    ${string2check}    ${regexp}

Check regexp by calling other KW - matching pattern
    [Arguments]    ${string2check}    ${regexp}=${MAGIK_LOAD_ERROR_REGEXP}
    Check regexp inside KW - matching pattern    ${string2check}    ${regexp}

Check regexp by calling other KW - not matching pattern
    [Arguments]    ${string2check}    ${regexp}=${MAGIK_LOAD_ERROR_REGEXP}
    Check regexp inside KW - not matching pattern    ${string2check}    ${regexp}
