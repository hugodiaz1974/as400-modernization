             PGM        PARM(&XFECHOY)

             DCL        VAR(&XFECHOY)  TYPE(*CHAR) LEN(08)
             DCL        VAR(&XREG)     TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&DIRORI)   TYPE(*CHAR) LEN(20)
             DCL        VAR(&DIRDES)   TYPE(*CHAR) LEN(20)
             RTVDTAARA  DTAARA(*LDA (811 20)) RTNVAR(&DIRORI)
             RTVDTAARA  DTAARA(*LDA (831 20)) RTNVAR(&DIRDES)

             DLTF       FILE(QGPL/DDAMAEAHOX)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(QGPL/DDACODTRNX)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(QGPL/DDAHISTORX)
             MONMSG     MSGID(CPF2105)

             RTVMBRD    FILE(*LIBL/CCAMAEAHO) NBRCURRCD(&XREG)

             IF         COND(&XREG *NE 0) THEN(DO)
             CPYF       FROMFILE(FINCCADAT/CCAMAEAHO) +
                          TOFILE(QGPL/DDAMAEAHOX) CRTFILE(*YES)
             CALL       PGM(QGPL/TRANSFERCL) PARM('DDAMAEAHOX' +
                          'QGPL' 'MULPLTENT' &DIRDES)
             ENDDO

             RTVMBRD    FILE(*LIBL/CCACODTRN) NBRCURRCD(&XREG)

             IF         COND(&XREG *NE 0) THEN(DO)
             CPYF       FROMFILE(FINCCADAT/CCACODTRN) +
                          TOFILE(QGPL/DDACODTRNX) CRTFILE(*YES)
             CALL       PGM(QGPL/TRANSFERCL) PARM('DDACODTRNX' +
                          'QGPL' 'MULPLTENT' &DIRDES)
             ENDDO

             RTVMBRD    FILE(*LIBL/CCAHISTMP) NBRCURRCD(&XREG)

             IF         COND(&XREG *NE 0) THEN(DO)
             CPYF       FROMFILE(FINHISDAT/CCAHISTMP) +
                          TOFILE(QGPL/DDAHISTORX) CRTFILE(*YES) +
                          INCREL((*IF FORIGE *EQ &XFECHOY))
             CALL       PGM(QGPL/TRANSFERCL) PARM('DDAHISTORX' +
                          'QGPL' 'MULPLTENT' &DIRDES)
             ENDDO

             DLTF       FILE(QGPL/DDAMAEAHOX)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(QGPL/DDACODTRNX)
             MONMSG     MSGID(CPF2105)
             DLTF       FILE(QGPL/DDAHISTORX)
             MONMSG     MSGID(CPF2105)

             ENDPGM
