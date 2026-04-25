       IDENTIFICATION DIVISION.
      *----------------------------------------------------------------
      * Material Bajo Licencia de Taylor & Johnson Ltda.              |
      * Copyright : TAYLOR & JOHNSON 1996, 1999, 2000, 2001, 2002     |
      *             Todos los Derechos Reservados                     |
      *----------------------------------------------------------------
      * Derechos Restringidos para los usuarios, el uso, la duplica-  |
      * cion o publicacion quedan sujetos al contrato con Taylor &    |
      * Johnson                                                       |
      *----------------------------------------------------------------
       PROGRAM-ID.    CCA664.
      ******************************************************************
      * FUNCION: PROGRAMA DE INACTIVACION DE AQUELLAS CUENTAS CON MAS  *
      *          DE W-DIASINA DIAS DE NO RECIBIR MOVIMIENTO.           *
      ******************************************************************
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  97/09/29.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAH13
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT PLTCCAMUT
                  ASSIGN               TO DATABASE-PLTCCAMUT
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTINAMUT
                  ASSIGN               TO DATABASE-PLTINAMUT
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTPARMUT
                  ASSIGN               TO DATABASE-PLTPARMUT
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLIMAE
                  ASSIGN               TO DATABASE-CLIMAE
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTINAMUT1
                  ASSIGN               TO DATABASE-PLTINAMUT1
                  ORGANIZATION         IS SEQUENTIAL
                  ACCESS MODE          IS SEQUENTIAL
                  FILE STATUS          IS FILSTAT.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS OF CCAMAEAH13.
      *
       FD  PLTCCAMUT
           LABEL RECORDS ARE STANDARD.
       01  PLTCCAMUT-REC.
           COPY DDS-ALL-FORMATS OF PLTCCAMUT.
      *
       FD  PLTINAMUT
           LABEL RECORDS ARE STANDARD.
       01  PLTINAMUT-REC.
           COPY DDS-ALL-FORMATS OF PLTINAMUT.
      *
       FD  PLTPARMUT
           LABEL RECORDS ARE STANDARD.
       01  PLTPARMUT-REC.
           COPY DDS-ALL-FORMATS OF PLTPARMUT.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  CLIMAE-REC.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *
       FD  PLTINAMUT1
           LABEL RECORDS ARE STANDARD.
       01  PLTINAMUT1-REC.
           COPY DDS-ALL-FORMATS OF PLTINAMUT1.
      *-----------------------------------------------------------------
       WORKING-STORAGE SECTION.
      *-----------------------------------------------------------------
       01  FILSTAT.
           05  ERR-FLAG    PIC X(01).
           05  PFK-BYTE    PIC X(01).
      *
       77  W-DIAS                      PIC 9(05)          VALUE ZEROS.
       77  W-DIASINA                   PIC 9(05)          VALUE 90.
       77  W-ACUM                      PIC S9(13)V99 COMP VALUE ZEROS.
      *
       01  W-FECINI                    PIC 9(08)          VALUE ZEROS.
       01  R-W-FECINI                  REDEFINES W-FECINI.
           05  W-ANOINI                PIC 9(04).
           05  W-MESINI                PIC 9(02).
           05  W-DIAINI                PIC 9(02).
      *
       01  W-FECSIG                    PIC 9(08)          VALUE ZEROS.
       01  R-W-FECSIG                  REDEFINES W-FECSIG.
           05  W-ANOSIG                PIC 9(04).
           05  W-MESSIG                PIC 9(02).
           05  W-DIASIG                PIC 9(02).
      *
       01  W-FECFIN                    PIC 9(08)          VALUE ZEROS.
       01  R-W-FECFIN                  REDEFINES W-FECFIN.
           05  W-ANOFIN                PIC 9(04).
           05  W-MESFIN                PIC 9(02).
           05  W-DIAFIN                PIC 9(02).
      *--------------------------------------------------------------*
       01 W-LIBRE                      PIC X(100) VALUE ZEROES.
       01 FILLER REDEFINES W-LIBRE.
          03 W-CODPRO-ORI     PIC 9(03).
          03 W-FECHA-TRAS     PIC 9(08).
          03 W-TIPO-TRAS      PIC 9(01).
          03 W-NACION-TRAS    PIC X.
          03 W-FECHA-TRAS-NAC PIC 9(08).
          03 W-FILLER         PIC X(79).
      *--------------------------------------------------------------*
       01 PAR-CODCPT       PIC 9(05) VALUE ZEROS.
       01 PAR-AGENCIA      PIC 9(05) VALUE ZEROS.
       01 PAR-CUENTA       PIC 9(17) VALUE ZEROS.
       01 PAR-AGENVA       PIC 9(05) VALUE ZEROS.
       01 PAR-CODRET       PIC 9(01) VALUE ZEROS.
       01 PA-CODEMP        PIC 9(05) VALUE ZEROS.
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO            VALUE "SI".
               88  NO-FIN-CCAMAEAHO         VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
           05  CTL-PROCESAR            PIC X(02) VALUE "NO".
               88  SI-PROCESAR                   VALUE "SI".
               88  NO-PROCESAR                   VALUE "NO".
       01  W-ERROR-VALIDACION                    PIC 9(01) VALUE 0.
           88  NO-ERROR-VALIDACION        VALUE 0.
           88  SI-ERROR-VALIDACION        VALUE 1.
       01  W-EXISTE-PLTINAMUT                    PIC 9(01) VALUE 0.
           88  NO-EXISTE-PLTINAMUT        VALUE 0.
           88  SI-EXISTE-PLTINAMUT        VALUE 1.
       01  W-EXISTE-PLTPARMUT                    PIC 9(01) VALUE 0.
           88  NO-EXISTE-PLTPARMUT        VALUE 0.
           88  SI-EXISTE-PLTPARMUT        VALUE 1.
       01  W-EXISTE-CLIMAE                       PIC 9(01) VALUE 0.
           88  NO-EXISTE-CLIMAE           VALUE 0.
           88  SI-EXISTE-CLIMAE           VALUE 1.
       01  W-EXISTE-PLTINAMUT1                   PIC 9(01) VALUE 0.
           88  NO-EXISTE-PLTINAMUT1       VALUE 0.
           88  SI-EXISTE-PLTINAMUT1       VALUE 1.
      ***************************************************************
      * PARAMETROS RUTINAS
           COPY FECHAS  OF CCACPY.
           COPY PLT219  OF CCACPY.
           COPY PARGEN  OF CCACPY.
      *--------------------------------------------------------------*
       01  W-NROTRN                    PIC 9(09) VALUE 998877.
       01  W-CNSTRN                    PIC 9(09) VALUE ZEROS.
       01  W-CODMON                    PIC 9(03) VALUE ZEROS.
       01  W-ESTADO                    PIC 9(01) VALUE ZEROS.
      *--------------------------------------------------------------*
       01  CAMBIO.
           03  VALOR-IN                   PIC S9(15)V99.
           03  MONEDA-IN                  PIC S9(2)    .
           03  F-CAMBIO                   PIC  9(8)    .
           03  FILLER REDEFINES F-CAMBIO.
               05  AA-CAMBIO              PIC  9(4)    .
               05  MM-CAMBIO              PIC  9(2)    .
               05  DD-CAMBIO              PIC  9(2)    .
           03  VALOR-OUT                  PIC S9(15)V99.
           03  MONEDA-OUT                 PIC S9(2)    .
           03  COTIZ-OUT                  PIC S9(11)V9(6).
       01  W-FECHA   PIC 9(08) VALUE ZEROS.
       01  FILLER REDEFINES W-FECHA.
           03 W-FECHA-AA                  PIC 9(04).
           03 W-FECHA-TRI                 PIC 9(02).
           03 W-FECHA-DD                  PIC 99.
       01  FILLER REDEFINES W-FECHA.
           03 W-FECHA-AAMM                PIC 9(06).
           03 W-FECHA-DD                  PIC 99.
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       01  W-CODCAJ                    PIC X(10).
       01  W-AGCORI                    PIC 9(05).
      ***************************************************************
       PROCEDURE DIVISION USING W-CODCAJ W-AGCORI.
      ***************************************************************
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMAEAHO
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           OPEN I-O    CCAMAEAHO.
           OPEN I-O    PLTCCAMUT.
           OPEN I-O    PLTINAMUT.
           OPEN I-O    PLTINAMUT1.
           OPEN INPUT  CLIMAE PLTPARMUT.
           MOVE "NO"   TO CTL-PROCESAR.
           CALL "PLTCODEMPP"         USING PA-CODEMP
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
           MOVE LK-FECHA-HOY    TO W-FECINI.
           MOVE LK-FECHA-MANANA TO W-FECSIG
           MOVE 10              TO W-FECSIG
           IF W-MESINI = W-MESSIG
              PERFORM TERMINAR
           ELSE
              IF W-MESINI = 3 OR 6 OR 9 OR 12
                 NEXT SENTENCE
              ELSE
                 PERFORM TERMINAR
              END-IF
           END-IF.
           PERFORM CALCULAR-FECHA-DESDE.
           MOVE "NO" TO CTL-CCAMAEAHO.
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM EVALUAR-PROCESAR.
           IF (SI-PROCESAR)
              PERFORM START-CCAMAEAHO
              IF (NO-FIN-CCAMAEAHO)
                 PERFORM TOMAR-TRANSACCION
              END-IF
           ELSE
              MOVE "SI" TO CTL-CCAMAEAHO
           END-IF.
           MOVE LK-FECHA-HOY TO W-FECHA
           PERFORM MOVER-TRIMESTRE.
      * -------------------------------------------
       START-CCAMAEAHO.
           MOVE ZEROS      TO FCIERR OF CCAMAEAHO
           MOVE ZEROS      TO CODMON OF CCAMAEAHO
           MOVE ZEROS      TO CODSIS OF CCAMAEAHO
           MOVE ZEROS      TO CODPRO OF CCAMAEAHO
           MOVE ZEROS      TO AGCCTA OF CCAMAEAHO
           MOVE ZEROS      TO CTANRO OF CCAMAEAHO
           START CCAMAEAHO KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE "SI" TO CTL-CCAMAEAHO
           END-START.
           IF (NO-FIN-CCAMAEAHO)
              MOVE "NO" TO CTL-REGISTRO
              PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                                     OR FIN-CCAMAEAHO
           END-IF.
      * -------------------------------------------------
       EVALUAR-PROCESAR.
           PERFORM LEER-PLTPARMUT
           IF (SI-EXISTE-PLTPARMUT)
              IF ESTADO OF PLTPARMUT = 0
                 AND VLRMAX OF PLTPARMUT NOT = ZEROS
                 MOVE "SI" TO CTL-PROCESAR
                 PERFORM CALCULAR-VALOR-PARAMETRO
              ELSE
                 MOVE "NO" TO CTL-PROCESAR
              END-IF
           ELSE
              MOVE "NO" TO CTL-PROCESAR
           END-IF.
      *----------------------------------------------------------------
       CALCULAR-VALOR-PARAMETRO.
           MOVE 1              TO MONEDA-IN
           MOVE LK-FECHA-HOY   TO F-CAMBIO.
           MOVE VLRMAX OF PLTPARMUT TO VALOR-IN
           MOVE ZEROS          TO VALOR-OUT
                                  MONEDA-OUT
                                  COTIZ-OUT.
           CALL "PAPCAMBIO" USING CAMBIO.
           IF VALOR-OUT = ZEROS
              MOVE "NO" TO CTL-PROCESAR
           END-IF.
      *----------------------------------------------------------------
       TOMAR-TRANSACCION.
      *    CALL "PLT201"    USING PA-CODEMP , W-AGCORI , W-CODCAJ ,
      *                                       W-CODMON , W-NROTRN.
           MOVE 1                      TO W-CNSTRN.
      *----------------------------------------------------------------
       CALCULAR-FECHA-DESDE.
           MOVE W-FECINI   TO LK219-FECHA1
           MOVE ZEROS      TO LK219-FECHA2
           MOVE ZEROS      TO LK219-FECHA3
           MOVE 1          TO LK219-TIPFMT
           MOVE 2          TO LK219-BASCLC
           MOVE 360        TO LK219-NRODIA
           MOVE 2          TO LK219-INDDSP
           MOVE 9          TO LK219-DIASEM
           MOVE SPACES     TO LK219-NOMDIA
           MOVE SPACES     TO LK219-NOMMES
           MOVE ZEROS      TO LK219-CODRET
           MOVE SPACES     TO LK219-MSGERR
           MOVE 2          TO LK219-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE LK219-FECHA3   TO W-FECFIN.
      *----------------------------------------------------------------
       PROCESAR.
           MOVE NITCTA OF REGMAEAHO TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           IF (NO-EXISTE-CLIMAE)
              MOVE NITCTA OF REGMAEAHO TO NITCLI OF CLIMAE
           END-IF
           IF INDINA OF CCAMAEAHO = 1
              IF INDBAJ OF CCAMAEAHO NOT = ZEROS
                 PERFORM CONTABILIZAR-TRAS-CANCELADA
              ELSE
                 PERFORM CONTABILIZAR-TRAS-INACTIVA
              END-IF
           ELSE
              IF INDBAJ OF CCAMAEAHO NOT = ZEROS
                 PERFORM CONTABILIZAR-TRAS-CANCELADA
              ELSE
                 PERFORM CONTABILIZAR-TRAS-FALLECIDA
              END-IF
           END-IF
           PERFORM ACTUALIZAR-PLTINAMUT.
           MOVE LK-FECHA-HOY TO FPULRE OF REG-MAESTR.
           MOVE LK-FECHA-HOY TO LIBRE  OF REG-MAESTR(51:8)
           MOVE 1            TO COD001 OF REG-MAESTR.
           MOVE 2            TO INDINA OF REG-MAESTR.
           MOVE W-FECHA-AAMM TO LIBRE  OF REG-MAESTR(59:6).
           REWRITE REG-MAESTR.
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                                     OR FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       ACTUALIZAR-PLTINAMUT.
           MOVE CORR REGMAEAHO TO REGINAMUT.
           IF INDBAJ OF REGMAEAHO = ZEROS
              MOVE 1 TO W-ESTADO
           ELSE
              MOVE 2 TO W-ESTADO
           END-IF
           MOVE W-FECHA-AAMM TO FECPER OF PLTINAMUT
           PERFORM LEER-PLTINAMUT
           IF (NO-EXISTE-PLTINAMUT)
              MOVE CORR REGMAEAHO TO REGINAMUT
              MOVE LK-FECHA-HOY TO FECACT OF PLTINAMUT
              ACCEPT HORACT OF PLTINAMUT FROM TIME
              MOVE LK-FECHA-HOY TO FECMUT OF PLTINAMUT
              MOVE W-FECHA-AAMM TO FECPER OF PLTINAMUT
              MOVE W-CODCAJ     TO USRACT OF PLTINAMUT
              MOVE FCIERR OF REGMAEAHO TO FECINA OF PLTINAMUT
              MOVE NITCLI OF CLIMAE    TO NITCLI OF PLTINAMUT
              MOVE W-ESTADO            TO ESTADO OF PLTINAMUT
              MOVE VALOR-IN            TO CUPONE OF PLTINAMUT
              MOVE VALOR-OUT           TO CUPSOB OF PLTINAMUT
              WRITE PLTINAMUT-REC INVALID KEY
                    CONTINUE
              END-WRITE
           ELSE
              MOVE CORR REGMAEAHO TO REGINAMUT1
              MOVE LK-FECHA-HOY TO FECACT OF PLTINAMUT1
              ACCEPT HORACT OF PLTINAMUT1 FROM TIME
              MOVE LK-FECHA-HOY TO FECMUT OF PLTINAMUT1
              MOVE W-FECHA-AAMM TO FECPER OF PLTINAMUT1
              MOVE W-CODCAJ     TO USRACT OF PLTINAMUT1
              MOVE FCIERR OF REGMAEAHO TO FECINA OF PLTINAMUT1
              MOVE NITCLI OF CLIMAE    TO NITCLI OF PLTINAMUT1
              MOVE W-ESTADO            TO ESTADO OF PLTINAMUT1
              MOVE VALOR-IN            TO CUPONE OF PLTINAMUT1
              MOVE VALOR-OUT           TO CUPSOB OF PLTINAMUT1
              WRITE PLTINAMUT1-REC
              END-WRITE
           END-IF.
      *----------------------------------------------------------------
       MOVER-TRIMESTRE.
           IF HOY-MM = 1 OR 2 OR 3
              MOVE 1 TO W-FECHA-TRI
           ELSE
              IF HOY-MM = 4 OR 5 OR 6
                 MOVE 2 TO W-FECHA-TRI
              ELSE
                 IF HOY-MM = 7 OR 8 OR 9
                    MOVE 3 TO W-FECHA-TRI
                 ELSE
                    MOVE 4 TO W-FECHA-TRI
                 END-IF
              END-IF
           END-IF.
      *----------------------------------------------------------------
       CONTABILIZAR-TRAS-CANCELADA.
           INITIALIZE REGTRNMON OF PLTCCAMUT-REC
           MOVE PA-CODEMP            TO CODEMP OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCORI OF PLTCCAMUT-REC
           MOVE CODMON OF CCAMAEAHO  TO CODMON OF PLTCCAMUT-REC
           MOVE W-CODCAJ             TO CODCAJ OF PLTCCAMUT-REC
           MOVE W-NROTRN             TO NROTRN OF PLTCCAMUT-REC
           MOVE W-CNSTRN             TO CNSTRN OF PLTCCAMUT-REC
           ADD 1                     TO W-CNSTRN
           MOVE 99                   TO CODSIS OF PLTCCAMUT-REC
           MOVE CODPRO OF CCAMAEAHO  TO CODPRO OF PLTCCAMUT-REC
           MOVE 515                  TO CODTRN OF PLTCCAMUT-REC
           MOVE 515                  TO CODOPE OF PLTCCAMUT-REC
           MOVE 5                    TO MEDPAG OF PLTCCAMUT-REC
           MOVE 1                    TO TIPMOV OF PLTCCAMUT-REC
           MOVE NITCLI OF CLIMAE     TO NRONIT OF PLTCCAMUT-REC
           MOVE DESCRI OF CCAMAEAHO  TO INFDEP OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCDST OF PLTCCAMUT-REC
           MOVE CTANRO OF CCAMAEAHO  TO CTANRO OF PLTCCAMUT-REC
           MOVE SALACT OF CCAMAEAHO  TO VLRTRN OF PLTCCAMUT-REC
           IF SALACT OF CCAMAEAHO  < ZEROS
              MOVE 518               TO CODTRN OF PLTCCAMUT-REC
                                        CODOPE OF PLTCCAMUT-REC
              MOVE 2                 TO TIPMOV OF PLTCCAMUT-REC
              COMPUTE VLRTRN OF PLTCCAMUT = SALACT OF CCAMAEAHO
                                          * (-1)
           END-IF
           ACCEPT HORTRN OF PLTCCAMUT-REC  FROM TIME
           MOVE CTANRO OF CCAMAEAHO  TO NROREF OF PLTCCAMUT-REC
           MOVE LK-FECHA-HOY         TO FECEFE OF PLTCCAMUT-REC
                                        FECPRO OF PLTCCAMUT-REC
           MOVE 0                    TO ESTTRN OF PLTCCAMUT-REC
           MOVE W-CODCAJ             TO USRING OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCOPR OF PLTCCAMUT-REC
           WRITE PLTCCAMUT-REC
                 INVALID KEY DISPLAY "ERROR AL GRABAR PLTCCAMUT"
           END-WRITE.
           MOVE W-CNSTRN             TO CNSTRN OF PLTCCAMUT-REC
           ADD 1                     TO W-CNSTRN
           MOVE 99                   TO CODSIS OF PLTCCAMUT-REC
           MOVE CODPRO OF CCAMAEAHO  TO CODPRO OF PLTCCAMUT-REC
           MOVE 516                  TO CODTRN OF PLTCCAMUT-REC
           MOVE 516                  TO CODOPE OF PLTCCAMUT-REC
           MOVE 5                    TO MEDPAG OF PLTCCAMUT-REC
           MOVE 2                    TO TIPMOV OF PLTCCAMUT-REC
           IF SALACT OF CCAMAEAHO  < ZEROS
              MOVE 1                 TO TIPMOV OF PLTCCAMUT-REC
              MOVE 517               TO CODTRN OF PLTCCAMUT-REC
              MOVE 517               TO CODOPE OF PLTCCAMUT-REC
           END-IF
           WRITE PLTCCAMUT-REC
                 INVALID KEY DISPLAY "ERROR AL GRABAR PLTCCAMUT"
           END-WRITE.

      *----------------------------------------------------------------
       CONTABILIZAR-TRAS-INACTIVA.
           INITIALIZE REGTRNMON OF PLTCCAMUT-REC
           MOVE PA-CODEMP            TO CODEMP OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCORI OF PLTCCAMUT-REC
           MOVE CODMON OF CCAMAEAHO  TO CODMON OF PLTCCAMUT-REC
           MOVE W-CODCAJ             TO CODCAJ OF PLTCCAMUT-REC
           MOVE W-NROTRN             TO NROTRN OF PLTCCAMUT-REC
           MOVE W-CNSTRN             TO CNSTRN OF PLTCCAMUT-REC
           ADD 1                     TO W-CNSTRN
           MOVE 99                   TO CODSIS OF PLTCCAMUT-REC
           MOVE CODPRO OF CCAMAEAHO  TO CODPRO OF PLTCCAMUT-REC
           MOVE 519                  TO CODTRN OF PLTCCAMUT-REC
           MOVE 519                  TO CODOPE OF PLTCCAMUT-REC
           MOVE 5                    TO MEDPAG OF PLTCCAMUT-REC
           MOVE 1                    TO TIPMOV OF PLTCCAMUT-REC
           MOVE NITCLI OF CLIMAE     TO NRONIT OF PLTCCAMUT-REC
           MOVE DESCRI OF CCAMAEAHO  TO INFDEP OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCDST OF PLTCCAMUT-REC
           MOVE CTANRO OF CCAMAEAHO  TO CTANRO OF PLTCCAMUT-REC
           MOVE SALACT OF CCAMAEAHO  TO VLRTRN OF PLTCCAMUT-REC
           IF SALACT OF CCAMAEAHO  < ZEROS
              MOVE 522               TO CODTRN OF PLTCCAMUT-REC
                                        CODOPE OF PLTCCAMUT-REC
              MOVE 2                 TO TIPMOV OF PLTCCAMUT-REC
              COMPUTE VLRTRN OF PLTCCAMUT = SALACT OF CCAMAEAHO
                                          * (-1)
           END-IF
           ACCEPT HORTRN OF PLTCCAMUT-REC  FROM TIME
           MOVE CTANRO OF CCAMAEAHO  TO NROREF OF PLTCCAMUT-REC
           MOVE LK-FECHA-HOY         TO FECEFE OF PLTCCAMUT-REC
                                        FECPRO OF PLTCCAMUT-REC
           MOVE 0                    TO ESTTRN OF PLTCCAMUT-REC
           MOVE W-CODCAJ             TO USRING OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCOPR OF PLTCCAMUT-REC
           WRITE PLTCCAMUT-REC
                 INVALID KEY DISPLAY "ERROR AL GRABAR PLTCCAMUT"
           END-WRITE.
           MOVE W-CNSTRN             TO CNSTRN OF PLTCCAMUT-REC
           ADD 1                     TO W-CNSTRN
           MOVE 99                   TO CODSIS OF PLTCCAMUT-REC
           MOVE CODPRO OF CCAMAEAHO  TO CODPRO OF PLTCCAMUT-REC
           MOVE 520                  TO CODTRN OF PLTCCAMUT-REC
           MOVE 520                  TO CODOPE OF PLTCCAMUT-REC
           MOVE 5                    TO MEDPAG OF PLTCCAMUT-REC
           MOVE 2                    TO TIPMOV OF PLTCCAMUT-REC
           IF SALACT OF CCAMAEAHO  < ZEROS
              MOVE 1                 TO TIPMOV OF PLTCCAMUT-REC
              MOVE 521               TO CODTRN OF PLTCCAMUT-REC
              MOVE 521               TO CODOPE OF PLTCCAMUT-REC
           END-IF
           WRITE PLTCCAMUT-REC
                 INVALID KEY DISPLAY "ERROR AL GRABAR PLTCCAMUT"
           END-WRITE.
      *----------------------------------------------------------------
       CONTABILIZAR-TRAS-FALLECIDA.
           INITIALIZE REGTRNMON OF PLTCCAMUT-REC
           MOVE PA-CODEMP            TO CODEMP OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCORI OF PLTCCAMUT-REC
           MOVE CODMON OF CCAMAEAHO  TO CODMON OF PLTCCAMUT-REC
           MOVE W-CODCAJ             TO CODCAJ OF PLTCCAMUT-REC
           MOVE W-NROTRN             TO NROTRN OF PLTCCAMUT-REC
           MOVE W-CNSTRN             TO CNSTRN OF PLTCCAMUT-REC
           ADD 1                     TO W-CNSTRN
           MOVE 99                   TO CODSIS OF PLTCCAMUT-REC
           MOVE CODPRO OF CCAMAEAHO  TO CODPRO OF PLTCCAMUT-REC
           MOVE 523                  TO CODTRN OF PLTCCAMUT-REC
           MOVE 523                  TO CODOPE OF PLTCCAMUT-REC
           MOVE 5                    TO MEDPAG OF PLTCCAMUT-REC
           MOVE 1                    TO TIPMOV OF PLTCCAMUT-REC
           MOVE NITCLI OF CLIMAE     TO NRONIT OF PLTCCAMUT-REC
           MOVE DESCRI OF CCAMAEAHO  TO INFDEP OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCDST OF PLTCCAMUT-REC
           MOVE CTANRO OF CCAMAEAHO  TO CTANRO OF PLTCCAMUT-REC
           MOVE SALACT OF CCAMAEAHO  TO VLRTRN OF PLTCCAMUT-REC
           IF SALACT OF CCAMAEAHO  < ZEROS
              MOVE 526               TO CODTRN OF PLTCCAMUT-REC
                                        CODOPE OF PLTCCAMUT-REC
              MOVE 2                 TO TIPMOV OF PLTCCAMUT-REC
              COMPUTE VLRTRN OF PLTCCAMUT = SALACT OF CCAMAEAHO
                                          * (-1)
           END-IF
           ACCEPT HORTRN OF PLTCCAMUT-REC  FROM TIME
           MOVE CTANRO OF CCAMAEAHO  TO NROREF OF PLTCCAMUT-REC
           MOVE LK-FECHA-HOY         TO FECEFE OF PLTCCAMUT-REC
                                        FECPRO OF PLTCCAMUT-REC
           MOVE 0                    TO ESTTRN OF PLTCCAMUT-REC
           MOVE W-CODCAJ             TO USRING OF PLTCCAMUT-REC
           MOVE AGCCTA OF CCAMAEAHO  TO AGCOPR OF PLTCCAMUT-REC
           WRITE PLTCCAMUT-REC
                 INVALID KEY DISPLAY "ERROR AL GRABAR PLTCCAMUT"
           END-WRITE.
           MOVE W-CNSTRN             TO CNSTRN OF PLTCCAMUT-REC
           ADD 1                     TO W-CNSTRN
           MOVE 99                   TO CODSIS OF PLTCCAMUT-REC
           MOVE CODPRO OF CCAMAEAHO  TO CODPRO OF PLTCCAMUT-REC
           MOVE 524                  TO CODTRN OF PLTCCAMUT-REC
           MOVE 524                  TO CODOPE OF PLTCCAMUT-REC
           MOVE 5                    TO MEDPAG OF PLTCCAMUT-REC
           MOVE 2                    TO TIPMOV OF PLTCCAMUT-REC
           IF SALACT OF CCAMAEAHO  < ZEROS
              MOVE 1                 TO TIPMOV OF PLTCCAMUT-REC
              MOVE 525               TO CODTRN OF PLTCCAMUT-REC
              MOVE 525               TO CODOPE OF PLTCCAMUT-REC
           END-IF
           WRITE PLTCCAMUT-REC
                 INVALID KEY DISPLAY "ERROR AL GRABAR PLTCCAMUT"
           END-WRITE.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMAEAHO NEXT RECORD AT END
                MOVE "SI"  TO CTL-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              IF FCIERR OF CCAMAEAHO NOT = ZEROS AND
                 FCIERR OF CCAMAEAHO > W-FECFIN
                 MOVE "SI" TO CTL-CCAMAEAHO
              ELSE
                 IF CTANRO OF CCAMAEAHO = 999999
                    OR FCIERR OF CCAMAEAHO = ZEROS
                    OR SALACT OF CCAMAEAHO NOT > ZEROS
                    OR COD001 OF CCAMAEAHO NOT = ZEROS
                    OR INDBAJ OF CCAMAEAHO = 2
                    OR CODPRO OF CCAMAEAHO = 2
                    OR CODPRO OF CCAMAEAHO = 5
                    OR CODPRO OF CCAMAEAHO = 13
                    OR CODPRO OF CCAMAEAHO = 16
                    OR CODPRO OF CCAMAEAHO = 32
                    OR (CODPRO OF CCAMAEAHO = 31 AND
                        CTANRO OF CCAMAEAHO > 999999)
                    MOVE "NO" TO CTL-REGISTRO
                 ELSE
                    IF FCIERR OF REG-MAESTR NOT > W-FECFIN
                       AND FCIERR OF REG-MAESTR > ZEROS
                       AND SALACT OF REG-MAESTR NOT > VALOR-OUT
                       NEXT SENTENCE
                    ELSE
                       MOVE "NO" TO CTL-REGISTRO
                    END-IF
                 END-IF
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS   .
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.
      *----------------------------------------------------------------
       LEER-PLTINAMUT.
           MOVE 1 TO W-EXISTE-PLTINAMUT.
           READ PLTINAMUT INVALID KEY
                MOVE ZEROS TO W-EXISTE-PLTINAMUT
           END-READ.
      *----------------------------------------------------------------
       LEER-PLTPARMUT.
           MOVE 1 TO W-EXISTE-PLTPARMUT.
           MOVE PA-CODEMP TO CODEMP OF PLTPARMUT.
           MOVE 1         TO CODPAR OF PLTPARMUT.
           READ PLTPARMUT INVALID KEY
                MOVE ZEROS TO W-EXISTE-PLTPARMUT
           END-READ.
      *----------------------------------------------------------------
       LEER-CLIMAE.
           MOVE 1 TO W-EXISTE-CLIMAE.
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO W-EXISTE-CLIMAE
           END-READ.
      *----------------------------------------------------------------
       CALL-PLT219.
           CALL "PLT219" USING PA-CODEMP
                               LK219-FECHA1
                               LK219-FECHA2
                               LK219-FECHA3
                               LK219-TIPFMT
                               LK219-BASCLC
                               LK219-NRODIA
                               LK219-INDDSP
                               LK219-DIASEM
                               LK219-NOMDIA
                               LK219-NOMMES
                               LK219-CODRET
                               LK219-MSGERR
                               LK219-TIPOPR.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMAEAHO PLTCCAMUT PLTINAMUT CLIMAE PLTPARMUT
                 PLTINAMUT1
           STOP RUN.
      *----------------------------------------------------------------
