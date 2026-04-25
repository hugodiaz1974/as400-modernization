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
       PROGRAM-ID.    CCA580.
      ******************************************************************
      * FUNCION: PROGRAMA DE ACTUALIZACION DE MOVIMIENTO MONETARIO     *
      *          Y REGENERACION DE MOVIMIENTO DIFERIDO.                *
      ******************************************************************
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  97/09/26.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAMOVACE
               ASSIGN          TO DATABASE-CCAMOVAC01
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT CCAMOVDIF
               ASSIGN          TO DATABASE-CCAMOVDIF
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCAMOVIMR
               ASSIGN          TO DATABASE-CCAMOVIMR
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCAMOVACER
               ASSIGN          TO DATABASE-CCAMOVACER
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *
       FD  CCAMOVACE
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVACE.
           COPY DDS-ALL-FORMATS OF CCAMOVAC01.
      *
       FD  CCAMOVDIF
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVDIF.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *
       FD  CCAMOVIMR
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIMR.
           COPY DDS-ALL-FORMATS OF CCAMOVIMR.
      *
       FD  CCAMOVACER
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVACER.
           COPY DDS-ALL-FORMATS OF CCAMOVACER.
      *
       WORKING-STORAGE SECTION.
      *
       COPY CATABPRO OF CCACPY.
      *
       77  W-FECHA48                   PIC 9(08)          VALUE ZEROS.
       77  W-FECHA72                   PIC 9(08)          VALUE ZEROS.
       77  W-FECHA96                   PIC 9(08)          VALUE ZEROS.
       77  W-DIAS                      PIC 9(05)          VALUE ZEROS.
       77  W-ACUM                      PIC S9(13)V99 COMP VALUE ZEROS.
       77  W-SALCON                    PIC S9(13)V99 COMP VALUE ZEROS.
      *
       01  W-CL-CCAMOVACE.
           05  W-CODMON-CCAMOVACE       PIC 9(03) VALUE ZEROS.
           05  W-CODSIS-CCAMOVACE       PIC 9(03) VALUE ZEROS.
           05  W-CODPRO-CCAMOVACE       PIC 9(03) VALUE ZEROS.
           05  W-AGCCTA-CCAMOVACE       PIC 9(05) VALUE ZEROS.
           05  W-CTANRO-CCAMOVACE       PIC 9(17) VALUE ZEROS.
      *
       01  W-CL-CCAMAEAHO.
           05  W-CODMON-CCAMAEAHO       PIC 9(03) VALUE ZEROS.
           05  W-CODSIS-CCAMAEAHO       PIC 9(03) VALUE ZEROS.
           05  W-CODPRO-CCAMAEAHO       PIC 9(03) VALUE ZEROS.
           05  W-AGCCTA-CCAMAEAHO       PIC 9(05) VALUE ZEROS.
           05  W-CTANRO-CCAMAEAHO       PIC 9(17) VALUE ZEROS.
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO                  VALUE "SI".
               88  NO-FIN-CCAMAEAHO               VALUE "NO".
           05  CTL-CCAMOVACE            PIC X(02) VALUE "NO".
               88  FIN-CCAMOVACE                  VALUE "SI".
               88  NO-FIN-CCAMOVACE               VALUE "NO".
           05  CTL-REGISTRO-MOV        PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO-MOV           VALUE "SI".
               88  REGISTRO-NO-VALIDO-MOV        VALUE "NO".
           05  CTL-REGISTRO-MAE        PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO-MAE           VALUE "SI".
               88  REGISTRO-NO-VALIDO-MAE        VALUE "NO".
           05  CTL-PROGRAMA            PIC X(02) VALUE "NO".
               88  FIN-PROGRAMA                  VALUE "SI".
               88  NO-FIN-PROGRAMA               VALUE "NO".
      *
      * VARIABLES-ENCADENAR.
           COPY FECHAS  OF CCACPY.
           COPY PLT219  OF CCACPY.
      *--------------------------------------------------------------*
       01 PAR-CODCPT       PIC 9(05) VALUE ZEROS.
       01 PAR-AGENCIA      PIC 9(05) VALUE ZEROS.
       01 PAR-CUENTA       PIC 9(17) VALUE ZEROS.
       01 PAR-AGENVA       PIC 9(05) VALUE ZEROS.
       01 PAR-CODRET       PIC 9(01) VALUE ZEROS.
        01 PA-CODEMP     PIC 9(05).
      ***************************************************************
       LINKAGE SECTION.
      ***************************************************************
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN I-O    CCAMOVACE.
           OPEN I-O    CCAMAEAHO.
           OPEN OUTPUT CCAMOVDIF.
           OPEN EXTEND CCAMOVIMR.
           OPEN EXTEND CCAMOVACER.
      *
           CALL "PLTCODEMPP"        USING PA-CODEMP
           PERFORM CALL-CCA500.
           PERFORM CALC-F48.
           PERFORM CALC-DIAS.
      *
           MOVE "NO" TO CTL-PROGRAMA.
           MOVE "NO" TO CTL-CCAMOVACE.
           MOVE "NO" TO CTL-CCAMAEAHO.
      *
           MOVE "NO" TO CTL-REGISTRO-MOV.
           MOVE ZEROS TO CODMON OF CCAMOVACE
                         CODSIS OF CCAMOVACE
                         CODPRO OF CCAMOVACE
                         AGCCTA OF CCAMOVACE
                         CTANRO OF CCAMOVACE
                         FORIGE OF CCAMOVACE
                         DEBCRE OF CCAMOVACE
                         CODTRA OF CCAMOVACE
                         IMPORT OF CCAMOVACE.
           START CCAMOVACE KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE "SI" TO CTL-CCAMOVACE.
           PERFORM LEER-CCAMOVACE UNTIL REGISTRO-VALIDO-MOV
                                 OR    FIN-CCAMOVACE.
           MOVE "NO" TO CTL-REGISTRO-MAE.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                 OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       CALC-F48.
           MOVE LK-FECHA-HOY TO LK219-FECHA1
           MOVE ZEROS      TO LK219-FECHA2
           MOVE ZEROS      TO LK219-FECHA3
           MOVE 1          TO LK219-TIPFMT
           MOVE 2          TO LK219-BASCLC
VGQ   *    MOVE 2          TO LK219-NRODIA
VGQ        MOVE 3          TO LK219-NRODIA
           MOVE 1          TO LK219-INDDSP
           MOVE 9          TO LK219-DIASEM
           MOVE SPACES     TO LK219-NOMDIA
           MOVE SPACES     TO LK219-NOMMES
           MOVE ZEROS      TO LK219-CODRET
           MOVE SPACES     TO LK219-MSGERR
           MOVE 3          TO LK219-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE LK219-FECHA3   TO W-FECHA48.
           MOVE 4          TO LK219-NRODIA
           PERFORM CALL-PLT219.
           MOVE LK219-FECHA3   TO W-FECHA72.
           MOVE 5          TO LK219-NRODIA
           PERFORM CALL-PLT219.
           MOVE LK219-FECHA3   TO W-FECHA96.
      *----------------------------------------------------------------
       CALC-DIAS.
           MOVE LK-FECHA-HOY TO LK219-FECHA1
           MOVE LK-FECHA-MANANA  TO LK219-FECHA2
           MOVE ZEROS      TO LK219-FECHA3
           MOVE 1          TO LK219-TIPFMT
           MOVE 2          TO LK219-BASCLC
           MOVE ZEROS      TO LK219-NRODIA
           MOVE 1          TO LK219-INDDSP
           MOVE 9          TO LK219-DIASEM
           MOVE SPACES     TO LK219-NOMDIA
           MOVE SPACES     TO LK219-NOMMES
           MOVE ZEROS      TO LK219-CODRET
           MOVE SPACES     TO LK219-MSGERR
           MOVE 4          TO LK219-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE LK219-NRODIA   TO W-DIAS.
      *----------------------------------------------------------------
       PROCESAR.
           IF FIN-CCAMOVACE
              IF FIN-CCAMAEAHO
                 MOVE "SI" TO CTL-PROGRAMA
              ELSE
                 PERFORM GRABAR-CCAMAEAHO
                 MOVE "NO" TO CTL-REGISTRO-MAE
                 PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                       OR    FIN-CCAMAEAHO
           ELSE
              IF W-CL-CCAMOVACE < W-CL-CCAMAEAHO
                 PERFORM ERROR-FATAL
              ELSE
                 IF W-CL-CCAMOVACE = W-CL-CCAMAEAHO
      *             PERFORM CALCULAR-SALDO-CONTABLE
      *             IF DEBCRE OF REG-MOVACE = 1
      *                AND IMPORT OF REG-MOVACE > W-SALCON
      *                PERFORM ASIGNAR-CUENTA-RECHAZOS
      *                IF CTANRO OF REG-MOVACE NOT = PAR-CUENTA
      *                   PERFORM GRABAR-RECHAZO
      *                ELSE
      *                   PERFORM ACT-CCAMAEAHO
      *                END-IF
      *             ELSE
                       PERFORM ACT-CCAMAEAHO
      *             END-IF
                    MOVE "NO" TO CTL-REGISTRO-MOV
                    PERFORM LEER-CCAMOVACE UNTIL REGISTRO-VALIDO-MOV
                                          OR    FIN-CCAMOVACE
                 ELSE
                    PERFORM GRABAR-CCAMAEAHO
                    MOVE "NO" TO CTL-REGISTRO-MAE
                    PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                          OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       ERROR-FATAL.
           DISPLAY "CL-CCAMOVACE < CL-CCAMAEAHO..."
                    W-CL-CCAMOVACE " " W-CL-CCAMAEAHO.
           DISPLAY "ERROR FATAL, CANCELAR EL PROCESO...".
           DISPLAY
                CODMON OF REG-MOVACE   , "  "   ,
                CODSIS OF REG-MOVACE   ,  "  "  ,
                CODPRO OF REG-MOVACE   ,  "  "  ,
                AGCCTA OF REG-MOVACE   ,  "  "  ,
                CTANRO OF REG-MOVACE   ,  "  "   ,
                IMPORT OF REG-MOVACE.
           MOVE "NO" TO CTL-REGISTRO-MOV
           PERFORM LEER-CCAMOVACE UNTIL REGISTRO-VALIDO-MOV
                                     OR    FIN-CCAMOVACE .
      *----------------------------------------------------------------
       CALCULAR-SALDO-CONTABLE.
           COMPUTE W-SALCON             = SALACT OF REG-MAESTR +
                                          DEP24  OF REG-MAESTR +
                                          DEP48  OF REG-MAESTR +
                                          DEP72  OF REG-MAESTR
           END-COMPUTE.
      *----------------------------------------------------------------
       LEER-CCAMOVACE.
           MOVE "SI" TO CTL-REGISTRO-MOV.
           READ CCAMOVACE AT END
                MOVE "SI"              TO CTL-CCAMOVACE
                MOVE 999               TO CODMON OF REG-MOVACE
                MOVE 999               TO CODSIS OF REG-MOVACE
                MOVE 999               TO CODPRO OF REG-MOVACE
                MOVE 99999             TO AGCCTA OF REG-MOVACE
                MOVE 99999999999999999 TO CTANRO OF REG-MOVACE.
           MOVE CODMON OF REG-MOVACE TO W-CODMON-CCAMOVACE
           MOVE CODSIS OF REG-MOVACE TO W-CODSIS-CCAMOVACE
           MOVE CODPRO OF REG-MOVACE TO W-CODPRO-CCAMOVACE
           MOVE AGCCTA OF REG-MOVACE TO W-AGCCTA-CCAMOVACE
           MOVE CTANRO OF REG-MOVACE TO W-CTANRO-CCAMOVACE.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE "SI" TO CTL-REGISTRO-MAE.
           READ CCAMAEAHO AT END
                MOVE "SI"              TO CTL-CCAMAEAHO
                MOVE 999               TO CODMON OF REG-MAESTR
                MOVE 999               TO CODSIS OF REG-MAESTR
                MOVE 999               TO CODPRO OF REG-MAESTR
                MOVE 99999             TO AGCCTA OF REG-MAESTR
                MOVE 99999999999999999 TO CTANRO OF REG-MAESTR.
           MOVE CODMON OF REG-MAESTR TO W-CODMON-CCAMAEAHO
           MOVE CODSIS OF REG-MAESTR TO W-CODSIS-CCAMAEAHO
           MOVE CODPRO OF REG-MAESTR TO W-CODPRO-CCAMAEAHO
           MOVE AGCCTA OF REG-MAESTR TO W-AGCCTA-CCAMAEAHO
           MOVE CTANRO OF REG-MAESTR TO W-CTANRO-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              IF INDBAJ OF REG-MAESTR NOT = 0
VG               AND FCIERR OF REG-MAESTR NOT = LK-FECHA-HOY
                 MOVE "NO" TO CTL-REGISTRO-MAE
              ELSE
                 MOVE ZEROS  TO DEP24  OF REG-MAESTR
                 MOVE ZEROS  TO DEP48  OF REG-MAESTR
                 MOVE ZEROS  TO DEP72  OF REG-MAESTR
                 MOVE ZEROS  TO CREDIA OF REG-MAESTR
                 MOVE ZEROS  TO DEBDIA OF REG-MAESTR
                 MOVE TABSAL OF REGMAEAHO  TO TABLA-PROMEDIOS
                 MOVE SALACT OF REGMAEAHO  TO SALANT OF REGMAEAHO .
      *----------------------------------------------------------------
       ACT-CCAMAEAHO.
      *    IF FVALOR OF REG-MOVACE NOT > LK-FECHA-HOY
           IF FVALOR OF REG-MOVACE NOT > LK-FECHA-MANANA
              IF DEBCRE OF REG-MOVACE = 1
VG               IF INDCNJ OF REG-MOVACE NOT = 2
                    SUBTRACT IMPORT OF REG-MOVACE
                          FROM SALACT OF REG-MAESTR
                    IF FORIGE OF REG-MOVACE < LK-FECHA-HOY
                       SUBTRACT IMPORT OF REG-MOVACE
                             FROM SALANT OF REG-MAESTR
                    ELSE
                       NEXT SENTENCE
VG                  END-IF
VG               ELSE
VG                  IF INDCNJ OF REG-MOVACE = 2
VG                     SUBTRACT IMPORT OF REG-MOVACE FROM
VG                              VALCOB OF REG-MAESTR
VG                  END-IF
VG               END-IF
              ELSE
                 ADD IMPORT OF REG-MOVACE
                     TO SALACT OF REG-MAESTR
                 IF FORIGE OF REG-MOVACE < LK-FECHA-HOY
                    ADD IMPORT OF REG-MOVACE
                        TO SALANT OF REG-MAESTR
                 ELSE
                    NEXT SENTENCE
VG               END-IF
VG               IF INDCNJ OF REG-MOVACE = 2
VG                  SUBTRACT IMPORT OF REG-MOVACE FROM
VG                           VALCOB OF REG-MAESTR
VG               END-IF
           ELSE
              MOVE  REG-MOVACE TO REG-MOVDIF
              WRITE REG-MOVDIF
VG            IF INDCNJ OF REG-MOVACE = 2
VG               IF FORIGE OF REG-MOVACE = LK-FECHA-HOY
VG                  IF DEBCRE OF REG-MOVACE = 1
VG                     SUBTRACT IMPORT OF REG-MOVACE FROM
VG                              VALCOB OF REG-MAESTR
VG                  ELSE
VG                     ADD IMPORT OF REG-MOVACE
VG                         TO VALCOB OF REG-MAESTR
VG                  END-IF
VG               END-IF
              ELSE
                 IF FVALOR OF REG-MOVACE = LK-FECHA-PASMAN
                    IF DEBCRE OF REG-MOVACE = 1
                       NEXT SENTENCE
                    ELSE
                       ADD IMPORT OF REG-MOVACE
                           TO DEP24 OF REG-MAESTR
                    END-IF
                 ELSE
                    IF FVALOR OF REG-MOVACE = W-FECHA48
                       IF DEBCRE OF REG-MOVACE = 1
                          NEXT SENTENCE
                       ELSE
                          ADD IMPORT OF REG-MOVACE
                              TO DEP48 OF REG-MAESTR
                       END-IF
                    ELSE
                       IF DEBCRE OF REG-MOVACE = 1
                          NEXT SENTENCE
                       ELSE
                          ADD IMPORT OF REG-MOVACE
                              TO DEP72 OF REG-MAESTR
                       END-IF
                    END-IF
                 END-IF
              END-IF
           END-IF.
      *
           IF FORIGE OF REG-MOVACE > FULMOV OF REG-MAESTR
      *       AND INDPAT OF REG-MOVACE = ZEROS
              MOVE FORIGE OF REG-MOVACE TO FULMOV OF REG-MAESTR.
      *
           IF FORIGE OF REG-MOVACE = LK-FECHA-HOY
              IF DEBCRE OF REG-MOVACE = 1
                 ADD IMPORT OF REG-MOVACE
                     TO DEBDIA OF REG-MAESTR
              ELSE
                 ADD IMPORT OF REG-MOVACE
                     TO CREDIA OF REG-MAESTR.
      *----------------------------------------------------------------
       GRABAR-CCAMAEAHO.
           COMPUTE SALCON OF REG-MAESTR = SALACT OF REG-MAESTR +
                                          DEP24  OF REG-MAESTR +
                                          DEP48  OF REG-MAESTR +
                                          DEP72  OF REG-MAESTR
      *
           COMPUTE W-ACUM = SALCON OF REG-MAESTR * W-DIAS
           IF CANT-ACREED (1) IS NOT NUMERIC
              MOVE ZEROS TO CANT-ACREED (1)
           END-IF
           IF SALDO-ACREED (1) IS NOT NUMERIC
              MOVE ZEROS TO SALDO-ACREED (1)
           END-IF
           IF CANT-DEUDOR (1) IS NOT NUMERIC
              MOVE ZEROS TO CANT-DEUDOR (1)
           END-IF
           IF SALDO-DEUDOR (1) IS NOT NUMERIC
              MOVE ZEROS TO SALDO-DEUDOR (1)
           END-IF
           IF SALCON OF REG-MAESTR NOT < ZEROS
              ADD W-DIAS TO CANT-ACREED  (1)
              ADD W-ACUM TO SALDO-ACREED (1)
           ELSE
              COMPUTE W-ACUM = W-ACUM * -1
              ADD W-DIAS TO CANT-DEUDOR  (1)
              ADD W-ACUM TO SALDO-DEUDOR (1).
           MOVE TABLA-PROMEDIOS TO TABSAL OF REGMAEAHO.
      *
           REWRITE REG-MAESTR.
      *----------------------------------------------------------------
       GRABAR-RECHAZO.
           INITIALIZE REGMOVIMR.
           MOVE CORR REGMOVIM OF CCAMOVACE TO REGMOVIMR OF CCAMOVIMR.
           MOVE CODMON OF CCAMOVACE  TO RODMON OF REGMOVIMR.
           MOVE CODSIS OF CCAMOVACE  TO RODSIS OF REGMOVIMR.
           MOVE CODPRO OF CCAMOVACE  TO RODPRO OF REGMOVIMR.
           MOVE ZEROS                TO NODMON OF REGMOVIMR
                                        NODSIS OF REGMOVIMR
                                        NODPRO OF REGMOVIMR
                                        NGCCTA OF REGMOVIMR
                                        NTANRO OF REGMOVIMR
                                        NODTRA OF REGMOVIMR
                                        ESTADO OF REGMOVIMR.
           MOVE 16                   TO CODER1 OF REGMOVIMR.
           MOVE PAR-AGENVA           TO RGCCTA OF REGMOVIMR
                                        AGCCTA OF REG-MOVACE
           MOVE PAR-CUENTA           TO RTANRO OF REGMOVIMR
                                        CTANRO OF REG-MOVACE
           WRITE REG-MOVIMR.
           INITIALIZE REGMOVIM OF CCAMOVACER
           MOVE CORR REGMOVIM OF CCAMOVACE TO REGMOVIM OF CCAMOVACER.
           WRITE REG-MOVACER.
           DELETE CCAMOVACE.
      *--------------------------------------------------------------*
       ASIGNAR-CUENTA-RECHAZOS.
           MOVE 1                        TO PAR-CODCPT
           MOVE AGCCTA OF REG-MOVACE     TO PAR-AGENCIA
           MOVE ZEROS                    TO PAR-CUENTA  PAR-AGENVA
                                            PAR-CODRET
           CALL "CCA990" USING PAR-CODCPT
                               PAR-AGENCIA
                               PAR-CUENTA
                               PAR-AGENVA
                               PAR-CODRET
           END-CALL.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
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
           CLOSE CCAMAEAHO CCAMOVACER.
           CLOSE CCAMOVACE .
           CLOSE CCAMOVDIF .
           STOP  RUN      .
      *----------------------------------------------------------------
