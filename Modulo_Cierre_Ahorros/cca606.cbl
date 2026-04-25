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
       PROGRAM-ID.    CCA606.
      ******************************************************************
      * FUNCION: PROGRAMA DE GENERACION DE ABONOS AUTOMATICOS DE INCEN *
      *          TIVOS DE CUENTAS DE AHORRO JUVENIL.                   *
      ******************************************************************
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  ENERO/2001.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO6
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT CCAMOVINT
               ASSIGN          TO DATABASE-CCAMOVINT
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CLIMAE
               ASSIGN          TO DATABASE-CLIMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLIMAEL01
               ASSIGN          TO DATABASE-CLIMAEL01
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLITAB
               ASSIGN          TO DATABASE-CLITAB
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLIVINCLI
               ASSIGN          TO DATABASE-CLIVINCLI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTAUTCTA
               ASSIGN          TO DATABASE-PLTAUTCTA
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIMAE.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *
       FD  CLIMAEL01
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIMAEL01.
           COPY DDS-ALL-FORMATS OF CLIMAEL01.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO6.
      *
       FD  CCAMOVINT
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVINT.
           COPY DDS-ALL-FORMATS OF CCAMOVINT.
      *
       FD  CLITAB
           LABEL RECORDS ARE STANDARD.
       01  REG-CLITAB.
           COPY DDS-ALL-FORMATS OF CLITAB.
      *
       FD  CLIVINCLI
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIVINCLI.
           COPY DDS-ALL-FORMATS OF CLIVINCLI.
      *
       FD  PLTAUTCTA
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTAUTCTA.
           COPY DDS-ALL-FORMATS OF PLTAUTCTA.
      *
       WORKING-STORAGE SECTION.
      *
           COPY CATABPRO OF CCACPY.
      *
       01  W-VALOR-X                   PIC X(50)      VALUE SPACES.
       01  FILLER REDEFINES W-VALOR-X.
           03 W-VALOR-N                PIC X(17).
           03 W-FILLER                 PIC X(33).
       01  W-VALOR                     PIC 9(17)      VALUE ZEROS.
       01  W-VALOR-T                   PIC S9(15)V99  VALUE ZEROS.
       01  FILLER REDEFINES W-VALOR-T.
           03 W-ENTERO                 PIC 9(15).
           03 W-DECIMALES              PIC 99.
       01  W-SMMLV                     PIC 9(13)V99   VALUE ZEROS.
       01  W-VLRTRN                    PIC 9(13)V99   VALUE ZEROS.
       01  W-NITCLI                    PIC 9(17)      VALUE ZEROS.
       01  W-NUMINT                    PIC 9(17)      VALUE ZEROS.
       77  W-USERID                 PIC X(10)            VALUE SPACES.
       01  W-FECHA                  PIC 9(08) VALUE ZEROS.
       01  FILLER REDEFINES W-FECHA.
           03 W-AA                  PIC 9(04).
           03 W-MM                  PIC 9(02).
           03 W-DD                  PIC 9(02).
      *
       01  ACUMULADOS.
           05  W-CANDEU             PIC  9(02)           VALUE ZEROS.
           05  W-SALDEU             PIC S9(15)V99   COMP VALUE ZEROS.
           05  W-CANACR             PIC  9(02)           VALUE ZEROS.
           05  W-SALACR             PIC S9(15)V99   COMP VALUE ZEROS.
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO                  VALUE "SI".
               88  NO-FIN-CCAMAEAHO               VALUE "NO".
           05  CTL-PLTAUTCTA            PIC X(02) VALUE "NO".
               88  FIN-PLTAUTCTA                  VALUE "SI".
               88  NO-FIN-PLTAUTCTA               VALUE "NO".
           05  CTL-REGISTRO-MOV        PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO-MOV           VALUE "SI".
               88  REGISTRO-NO-VALIDO-MOV        VALUE "NO".
           05  W-EXISTE-CLIMAE         PIC 9     VALUE 0.
               88  SI-EXISTE-CLIMAE              VALUE 1.
               88  NO-EXISTE-CLIAME              VALUE 0.
           05  W-EXISTE-CLIMAEL01      PIC 9     VALUE 0.
               88  SI-EXISTE-CLIMAEL01           VALUE 1.
               88  NO-EXISTE-CLIAMEL01           VALUE 0.
           05  CTL-CLITAB               PIC X(02) VALUE "SI".
               88  EXISTE-CLITAB                  VALUE "SI".
               88  NO-EXISTE-CLITAB               VALUE "NO".
           05  CTL-REGISTRO-MAE        PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO-MAE           VALUE "SI".
               88  REGISTRO-NO-VALIDO-MAE        VALUE "NO".
           05  CTL-PROGRAMA            PIC X(02) VALUE "NO".
               88  FIN-PROGRAMA                  VALUE "SI".
               88  NO-FIN-PROGRAMA               VALUE "NO".
       01  W-EXISTE-CLIVINCLI         PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-CLIVINCLI                   VALUE 0.
           88  SI-EXISTE-CLIVINCLI                   VALUE 1.
      * -----------------
       01  W-PROCESADO                 PIC 9(01) VALUE ZEROS.
       01  W-FECFIN                    PIC 9(08) VALUE ZEROS.
       01  PA-CODEMP                   PIC 9(05) VALUE ZEROS.
      * -----------------
           COPY PARGEN OF CCACPY.
           COPY FECHAS OF CCACPY.
           COPY PLT219 OF CCACPY.
      * -----------------
       LINKAGE SECTION.
       77  XUSERID PIC X(10).
      *----------------------------------------------------------------
       PROCEDURE DIVISION USING XUSERID.
      *----------------------------------------------------------------
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMAEAHO.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           MOVE XUSERID TO W-USERID.
      *
           OPEN INPUT  CLIMAE CLITAB CLIVINCLI PLTAUTCTA CLIMAEL01
           OPEN I-O    CCAMAEAHO.
           OPEN EXTEND CCAMOVINT.
           CALL "PLTCODEMPP"         USING PA-CODEMP
      *
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
           PERFORM CALCULAR-FECHA-HASTA
      *
           MOVE "NO" TO CTL-PROGRAMA.
           MOVE "NO" TO CTL-CCAMAEAHO.
      *
           MOVE "NO" TO CTL-REGISTRO-MAE.
           MOVE ZEROS      TO FAPERT OF CCAMAEAHO
           MOVE ZEROS      TO AGCCTA OF CCAMAEAHO
           MOVE ZEROS      TO CODPRO OF CCAMAEAHO
           MOVE ZEROS      TO CTANRO OF CCAMAEAHO
           START CCAMAEAHO KEY NOT < EXTERNALLY-DESCRIBED-KEY
                    INVALID KEY MOVE "SI" TO CTL-CCAMAEAHO
           END-START
           IF (NO-FIN-CCAMAEAHO)
              PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                 OR FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       CALCULAR-FECHA-HASTA.
           MOVE LK-FECHA-HOY TO LK219-FECHA1
           MOVE ZEROS        TO LK219-FECHA2
           MOVE ZEROS        TO LK219-FECHA3
           MOVE 1            TO LK219-TIPFMT
           MOVE 2            TO LK219-BASCLC
           MOVE 180          TO LK219-NRODIA
           MOVE 2            TO LK219-INDDSP
           MOVE 9            TO LK219-DIASEM
           MOVE SPACES       TO LK219-NOMDIA
           MOVE SPACES       TO LK219-NOMMES
           MOVE ZEROS        TO LK219-CODRET
           MOVE SPACES       TO LK219-MSGERR
           MOVE 2            TO LK219-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE LK219-FECHA3 TO W-FECFIN.
      *----------------------------------------------------------------
       PROCESAR.
           MOVE 0                  TO W-PROCESADO
           PERFORM LEER-CLIMAE
           IF (SI-EXISTE-CLIMAE)
              MOVE NITCLI OF CLIMAE   TO NITCLI OF CLIVINCLI
              PERFORM LEER-CLIVINCLI
              IF ( SI-EXISTE-CLIVINCLI )
                 IF NOT ( TIPVIN OF CLIVINCLI = 1 OR 3 )
                    MOVE 1             TO W-PROCESADO
                    MOVE 1             TO IND003 OF REG-MAESTR
                    REWRITE REG-MAESTR
                 END-IF
              END-IF
              IF ( W-PROCESADO = ZEROS )
                 IF FAPERT OF REG-MAESTR < 20020101
                    MOVE 1 TO IND003 OF REG-MAESTR
                    REWRITE REG-MAESTR
                 ELSE
                    IF FAPERT OF REG-MAESTR < W-FECFIN
                       MOVE 1 TO IND003 OF REG-MAESTR
                       MOVE LK-FECHA-HOY TO FULMOV OF REG-MAESTR
                       PERFORM GENERAR-PAGO
                       PERFORM ACTUALIZAR-CCAMAEAHO
                    END-IF
                 END-IF
              END-IF
           ELSE
              DISPLAY "CLIENTE NO EXISTE: " NITCTA OF REG-MAESTR
           END-IF.
           MOVE "NO" TO CTL-REGISTRO-MAE
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                   OR FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       GENERAR-PAGO.
           MOVE ZEROS TO W-VALOR W-VLRTRN.
           PERFORM CALCULAR-VALOR
           IF W-VLRTRN > ZEROS
              PERFORM LLENAR-FIJOS
              MOVE W-VLRTRN  TO IMPORT OF REG-MOVINT
              MOVE 910                 TO CODTRA OF REG-MOVINT
              MOVE 1                   TO DEBCRE OF REG-MOVINT
              WRITE REG-MOVINT
              PERFORM LLENAR-FIJOS
              MOVE W-VLRTRN  TO IMPORT OF REG-MOVINT
              MOVE 712                 TO CODTRA OF REG-MOVINT
              MOVE 2                   TO DEBCRE OF REG-MOVINT
              WRITE REG-MOVINT
           END-IF.
      *----------------------------------------------------------------
       CALCULAR-VALOR.
           MOVE FAPERT OF REG-MAESTR TO W-FECHA.
           MOVE 206          TO CODTAB OF CLITAB
           MOVE W-AA         TO CODINT OF CLITAB
           MOVE ZEROS        TO W-SMMLV W-VLRTRN
           MOVE "SI"         TO CTL-CLITAB.
           READ CLITAB INVALID KEY
                MOVE "NO" TO CTL-CLITAB
           END-READ.
           IF ( EXISTE-CLITAB )
              MOVE CODNOM OF REGTABMAE TO W-VALOR-X
              CALL "CCA805" USING W-VALOR-N
                                  W-VALOR
              END-CALL
           END-IF.
           IF W-VALOR NOT = ZEROS
              MOVE W-VALOR TO W-SMMLV
           END-IF.
           MOVE ZEROS TO W-VLRTRN.
           IF W-SMMLV > ZEROS
              COMPUTE W-VLRTRN ROUNDED = (W-SMMLV * 10 ) / 100
           END-IF.
      *----------------------------------------------------------------
       ACTUALIZAR-CCAMAEAHO.
           ADD 1              TO   W-CANACR
           ADD W-VLRTRN       TO   W-SALACR.
           ADD      W-VLRTRN  TO   CREDIA OF REG-MAESTR
      *    ADD      W-VLRTRN  TO   SALANT OF REG-MAESTR
           ADD      W-VLRTRN  TO   SALACT OF REG-MAESTR
      *
           COMPUTE SALCON OF REG-MAESTR = SALACT OF REG-MAESTR +
                                          DEP24  OF REG-MAESTR +
                                          DEP48  OF REG-MAESTR +
                                          DEP72  OF REG-MAESTR .
      *
           MOVE W-CANACR TO CANT-ACREED  (1)
           MOVE W-SALACR TO SALDO-ACREED (1)
           MOVE W-CANDEU TO CANT-DEUDOR  (1)
           MOVE W-SALDEU TO SALDO-DEUDOR (1).
           MOVE TABLA-PROMEDIOS TO TABSAL OF REGMAEAHO.
      *
           REWRITE REG-MAESTR.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE "SI" TO CTL-REGISTRO-MAE.
           READ CCAMAEAHO NEXT RECORD AT END
                MOVE "SI"              TO CTL-CCAMAEAHO
           END-READ.
           IF NO-FIN-CCAMAEAHO
              IF FAPERT OF REG-MAESTR > W-FECFIN
                 MOVE "SI" TO CTL-CCAMAEAHO
              ELSE
                 IF CTANRO OF REG-MAESTR = 999999
                    MOVE "NO" TO CTL-REGISTRO-MAE
                 ELSE
                    MOVE ZEROS                TO W-CANDEU
                    MOVE ZEROS                TO W-SALDEU
                    MOVE ZEROS                TO W-CANACR
                    MOVE ZEROS                TO W-SALACR
                    MOVE ZEROS                TO W-VLRTRN
                    MOVE TABSAL OF REGMAEAHO  TO TABLA-PROMEDIOS.
      *----------------------------------------------------------------
       LLENAR-FIJOS.
           INITIALIZE REGMOVIM       OF REG-MOVINT
           MOVE CODMON OF REG-MAESTR TO CODMON OF REG-MOVINT
           MOVE CODSIS OF REG-MAESTR TO CODSIS OF REG-MOVINT
           MOVE CODPRO OF REG-MAESTR TO CODPRO OF REG-MOVINT
           MOVE AGCCTA OF REG-MAESTR TO AGCCTA OF REG-MOVINT
           MOVE CTANRO OF REG-MAESTR TO CTANRO OF REG-MOVINT
           MOVE REGION OF REG-MAESTR TO NROBNV OF REG-MOVINT
           MOVE DESCRI OF REG-MAESTR TO INFDEP OF REG-MOVINT
           MOVE LK-FECHA-HOY         TO FORIGE OF REG-MOVINT
           MOVE LK-FECHA-HOY         TO FVALOR OF REG-MOVINT
           MOVE W-NUMINT             TO NROREF OF REG-MOVINT
           MOVE W-NITCLI             TO NRONIT OF REG-MOVINT
           MOVE 1                    TO FECVAL OF REG-MOVINT
           MOVE 6                    TO TIPVAL OF REG-MOVINT
           MOVE ZEROS                TO ESTTRN OF REG-MOVINT
           MOVE AGCCTA OF REG-MAESTR TO AGCORI OF REG-MOVINT
           MOVE W-USERID             TO CODCAJ OF REG-MOVINT.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.

      *----------------------------------------------------------------
       CALL-PLT219.
           CALL "PLT219" USING  PA-CODEMP
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
       LEER-CLIMAE.
           MOVE NITCTA OF REG-MAESTR TO NUMINT OF REG-CLIMAE
                                        W-NUMINT W-NITCLI.
           MOVE 1 TO W-EXISTE-CLIMAE
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO W-EXISTE-CLIMAE.
           IF (SI-EXISTE-CLIMAE)
              MOVE NITCLI OF CLIMAE TO W-NITCLI
              IF TIPCLI OF CLIMAE = 2 AND
                 (TIPDOC OF CLIMAE = 4 OR 6)
                 IF (NITCT2 OF REG-MAESTR NOT = ZEROS)
                    MOVE NITCT2 OF REG-MAESTR TO NUMINT OF REG-CLIMAE
                    MOVE 1 TO W-EXISTE-CLIMAE
                    READ CLIMAE INVALID KEY
                         MOVE ZEROS TO W-EXISTE-CLIMAE
                    END-READ
                 ELSE
                    PERFORM BUSCAR-AUTORIZADOS
                 END-IF
              END-IF
           END-IF.
      *----------------------------------------------------------------
       BUSCAR-AUTORIZADOS.
           MOVE PA-CODEMP              TO CODEMP OF PLTAUTCTA.
           MOVE CODMON OF CCAMAEAHO    TO CODMON OF PLTAUTCTA.
           MOVE CODSIS OF CCAMAEAHO    TO CODSIS OF PLTAUTCTA.
           MOVE CODPRO OF CCAMAEAHO    TO CODPRO OF PLTAUTCTA.
           MOVE AGCCTA OF CCAMAEAHO    TO CODAGE OF PLTAUTCTA.
           MOVE CTANRO OF CCAMAEAHO    TO NUMCTA OF PLTAUTCTA.
           MOVE ZEROS                  TO NROCNS OF PLTAUTCTA.
           MOVE "NO" TO CTL-PLTAUTCTA.
           START PLTAUTCTA KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE "SI" TO CTL-PLTAUTCTA
           END-START.
           PERFORM UNTIL (FIN-PLTAUTCTA)
             READ PLTAUTCTA NEXT RECORD AT END
                  MOVE "SI" TO CTL-PLTAUTCTA
             END-READ
             IF (NO-FIN-PLTAUTCTA)
                IF CODEMP OF PLTAUTCTA NOT = PA-CODEMP OR
                   CODMON OF PLTAUTCTA NOT = CODMON OF CCAMAEAHO OR
                   CODSIS OF PLTAUTCTA NOT = CODSIS OF CCAMAEAHO OR
                   CODPRO OF PLTAUTCTA NOT = CODPRO OF CCAMAEAHO OR
                   CODAGE OF PLTAUTCTA NOT = AGCCTA OF CCAMAEAHO OR
                   NUMCTA OF PLTAUTCTA NOT = CTANRO OF CCAMAEAHO
                   MOVE "SI" TO CTL-PLTAUTCTA
                ELSE
                    MOVE NITAUT OF PLTAUTCTA TO NITCLI OF CLIMAEL01
                    MOVE 1 TO W-EXISTE-CLIMAEL01
                    READ CLIMAEL01 INVALID KEY
                         MOVE ZEROS TO W-EXISTE-CLIMAEL01
                    END-READ
                    IF (SI-EXISTE-CLIMAEL01)
                       MOVE NITCLI OF CLIMAEL01 TO NITCLI OF CLIVINCLI
                       PERFORM LEER-CLIVINCLI
                       IF (SI-EXISTE-CLIVINCLI )
                          IF TIPVIN OF CLIVINCLI = 1 OR 3
                             MOVE CORR REGCLIMAE OF CLIMAEL01 TO
                                       REGCLIMAE OF CLIMAE
                             MOVE 1 TO W-EXISTE-CLIMAE
                             MOVE "SI" TO CTL-PLTAUTCTA
                          ELSE
                             MOVE 1 TO W-EXISTE-CLIMAE
                          END-IF
                       ELSE
                          MOVE ZEROS TO W-EXISTE-CLIMAE
                       END-IF
                    ELSE
                       MOVE ZEROS TO W-EXISTE-CLIMAE
                    END-IF
                END-IF
             END-IF
           END-PERFORM.
      *----------------------------------------------------------------
       LEER-CLIVINCLI.
           MOVE 1                      TO W-EXISTE-CLIVINCLI
           READ CLIVINCLI              INVALID KEY
                                       MOVE 0 TO W-EXISTE-CLIVINCLI
           END-READ.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMAEAHO .
           CLOSE CCAMOVINT .
           CLOSE CLIMAE CLITAB CLIMAEL01 PLTAUTCTA
           CLOSE CLIVINCLI .
           STOP  RUN.
      *----------------------------------------------------------------
