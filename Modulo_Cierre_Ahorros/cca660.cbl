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
       PROGRAM-ID.    CCA660.
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
               ASSIGN          TO DATABASE-CCAMAEAHO5
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO5.
      *
       WORKING-STORAGE SECTION.
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
       01 PAR-CODCPT       PIC 9(05) VALUE ZEROS.
       01 PAR-AGENCIA      PIC 9(05) VALUE ZEROS.
       01 PAR-CUENTA       PIC 9(17) VALUE ZEROS.
       01 PAR-AGENVA       PIC 9(05) VALUE ZEROS.
       01 PAR-CODRET       PIC 9(01) VALUE ZEROS.
       01 PA-CODEMP        PIC 9(05) VALUE ZEROS.
      *
       01  W-CTANROX                   PIC 9(15)          VALUE ZEROS.
      *01  R-W-CTANROX                 REDEFINES W-CTANROX.
      *    05  FILLER                  PIC X(08).
      *    05  W-CUENTA                PIC 9(06).
      *        88  ES-ESPECIAL         VALUE 888888.
      *    05  W-DIGITO                PIC 9(01).
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO                  VALUE "SI".
               88  NO-FIN-CCAMAEAHO               VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
      *
      * PARAMETROS RUTINAS
           COPY FECHAS  OF CCACPY.
           COPY PLT219  OF CCACPY.
           COPY PARGEN  OF CCACPY.
      ***************************************************************
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMAEAHO.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           OPEN I-O    CCAMAEAHO.
           CALL "PLTCODEMPP"         USING PA-CODEMP
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
           MOVE LK-FECHA-HOY    TO W-FECINI.
           MOVE LK-FECHA-MANANA TO W-FECSIG
           PERFORM CALCULAR-FECHA-DESDE.
           MOVE "NO" TO CTL-CCAMAEAHO.
           MOVE "NO" TO CTL-REGISTRO.
           IF W-MESINI = W-MESSIG
              PERFORM TERMINAR
           ELSE
              MOVE ZEROS      TO FULMOV OF CCAMAEAHO
              START CCAMAEAHO KEY NOT < EXTERNALLY-DESCRIBED-KEY
                    INVALID KEY MOVE "SI" TO CTL-CCAMAEAHO
              END-START
              IF (NO-FIN-CCAMAEAHO)
                 PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                                      OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       CALCULAR-FECHA-DESDE.
           MOVE W-FECINI   TO LK219-FECHA1
           MOVE ZEROS      TO LK219-FECHA2
           MOVE ZEROS      TO LK219-FECHA3
           MOVE 1          TO LK219-TIPFMT
           MOVE 2          TO LK219-BASCLC
           MOVE LK-TRA003  TO LK219-NRODIA
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
           MOVE 1            TO INDINA OF REG-MAESTR
           MOVE LK-FECHA-HOY TO FCIERR OF REG-MAESTR
           MOVE LK-FECHA-HOY TO LIBRE  OF REG-MAESTR(93:8)
           MOVE "        "   TO LIBRE  OF REG-MAESTR(84:8)
           MOVE "1"          TO LIBRE  OF REG-MAESTR(92:1)
           REWRITE REG-MAESTR
           END-REWRITE
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMAEAHO NEXT RECORD AT END
                MOVE "SI"  TO CTL-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              IF FULMOV OF REG-MAESTR > W-FECFIN
                 MOVE "SI" TO CTL-CCAMAEAHO
              ELSE
                 IF ( FULMOV OF REG-MAESTR = 0 )  OR
                    ( CTANRO OF REG-MAESTR = 999999 ) OR
                    ( CODPRO OF REG-MAESTR = 16     ) OR
                    ( CODPRO OF REG-MAESTR = 5      )
                    MOVE "NO" TO CTL-REGISTRO
                 ELSE
                    MOVE "SI" TO CTL-REGISTRO
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
           CLOSE CCAMAEAHO .
           STOP  RUN      .
      *----------------------------------------------------------------
