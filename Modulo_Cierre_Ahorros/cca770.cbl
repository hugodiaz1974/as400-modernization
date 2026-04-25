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
       PROGRAM-ID.    CCA770.
      ******************************************************************
      * FUNCION: PROGRAMA DE REGENERACION DEL CCACAUSAC (CCACAUSAS). EL  *
      *          ARCHIVO SE DEPURA AL MOMENTO DEL CORTE Y LOS PROMEDIOS*
      *          DEL MAESTRO SON ROTADOS Y LOS DEL NUEVO MES SON       *
      *          REACTUALIZADOS PARA REFLEJAR EL PROMEDIO EXACTO.      *
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/10/14.
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
           SELECT CCACAUSAC
               ASSIGN          TO DATABASE-CCACAUSAC
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACAUSAS
               ASSIGN          TO DATABASE-CCACAUSAS
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
       FD  CCACAUSAC
           LABEL RECORDS ARE STANDARD.
       01  REG-CAUSAC.
           COPY DDS-ALL-FORMATS OF CCACAUSAC.
      *
       FD  CCACAUSAS
           LABEL RECORDS ARE STANDARD.
       01  REG-CAUSAS.
           COPY DDS-ALL-FORMATS OF CCACAUSAS.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-FECHALIQ               PIC 9(08)            VALUE ZEROS.
       77  W-IND-I                  PIC 9(02)            VALUE ZEROS.
       77  W-IND-J                  PIC 9(02)            VALUE ZEROS.
      *
      * ALMACENA EL ULTIMO DIA CALENDARIO DEL MES QUE CORTA.
       01  W-FECHACTL-1             PIC 9(08)            VALUE ZEROS.
       01  R-FECHACTL-1             REDEFINES W-FECHACTL-1.
           05  ANO-CTL-1            PIC 9(04).
           05  MES-CTL-1            PIC 9(02).
           05  DIA-CTL-1            PIC 9(02).
      *
      * FECHA DE CONTROL.
       01  W-FECHACTL-0             PIC 9(08)            VALUE ZEROS.
       01  R-FECHACTL-0             REDEFINES W-FECHACTL-0.
           05  ANO-CTL-0            PIC 9(04).
           05  MES-CTL-0            PIC 9(02).
           05  DIA-CTL-0            PIC 9(02).
      *
       01  ACUMULADOS.
           05  W-CANDEU             PIC  9(02)           VALUE ZEROS.
           05  W-SALDEU             PIC S9(15)V99   COMP VALUE ZEROS.
           05  W-CANACR             PIC  9(02)           VALUE ZEROS.
           05  W-SALACR             PIC S9(15)V99   COMP VALUE ZEROS.
      *
       01  W-CL-CCACAUSAC.
           05  W-CODMON-CCACAUSAC    PIC 9(03)            VALUE ZEROS.
           05  W-CODSIS-CCACAUSAC    PIC 9(03)            VALUE ZEROS.
           05  W-CODPRO-CCACAUSAC    PIC 9(03)            VALUE ZEROS.
           05  W-AGCCTA-CCACAUSAC    PIC 9(05)            VALUE ZEROS.
           05  W-CTANRO-CCACAUSAC    PIC 9(17)            VALUE ZEROS.
      *
       01  W-CL-CCAMAEAHO.
           05  W-CODMON-CCAMAEAHO    PIC 9(03)            VALUE ZEROS.
           05  W-CODSIS-CCAMAEAHO    PIC 9(03)            VALUE ZEROS.
           05  W-CODPRO-CCAMAEAHO    PIC 9(03)            VALUE ZEROS.
           05  W-AGCCTA-CCAMAEAHO    PIC 9(05)            VALUE ZEROS.
           05  W-CTANRO-CCAMAEAHO    PIC 9(17)            VALUE ZEROS.
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO                  VALUE "SI".
               88  NO-FIN-CCAMAEAHO               VALUE "NO".
           05  CTL-CCACAUSAC            PIC X(02) VALUE "NO".
               88  FIN-CCACAUSAC                  VALUE "SI".
               88  NO-FIN-CCACAUSAC               VALUE "NO".
           05  CTL-REGISTRO-MOV        PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO-MOV           VALUE "SI".
               88  REGISTRO-NO-VALIDO-MOV        VALUE "NO".
           05  CTL-REGISTRO-MAE        PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO-MAE           VALUE "SI".
               88  REGISTRO-NO-VALIDO-MAE        VALUE "NO".
           05  CTL-CIERRE              PIC X(02) VALUE "NO".
               88  ES-CIERRE                     VALUE "SI".
               88  NO-ES-CIERRE                  VALUE "NO".
           05  CTL-PROGRAMA            PIC X(02) VALUE "NO".
               88  FIN-PROGRAMA                  VALUE "SI".
               88  NO-FIN-PROGRAMA               VALUE "NO".
      * ----------------------
       01  W-FIN-MES                   PIC X VALUE "N".
       01  W-FIN-TRI                   PIC X VALUE "N".
       01  W-SDO-DIA                   PIC X VALUE "N".
       01  PA-CODEMP                   PIC 9(05) VALUE ZEROS.
      *--------------------------------------------------------------*
           COPY CATABPRO OF CCACPY.
           COPY PARGEN   OF CCACPY.
           COPY FECHAS   OF CCACPY.
           COPY PLT219   OF CCACPY.
      *--------------------------------------------------------------*
      /
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN INPUT  CCACAUSAC.
           OPEN I-O    CCAMAEAHO.
           OPEN OUTPUT CCACAUSAS.
           CALL "PLTCODEMPP"        USING PA-CODEMP.
      *
           PERFORM CALL-CCA500.
      *
           PERFORM CALL-CCA501.
           PERFORM CALL-CCA502.
      * ------------------------------
VG         MOVE "NO"  TO CTL-CIERRE.
VG         IF W-FIN-MES = "S"
VG            MOVE "SI" TO CTL-CIERRE.
      * ------------------------------
VG    *    MOVE "NO"  TO CTL-CIERRE.
VG    *    IF LK-FECHA-HOY > LK-FECLIQ
VG    *       IF LK-INDCIE = 1
VG    *          MOVE "SI" TO CTL-CIERRE.
      *
           MOVE LK-FECLIQ              TO W-FECHALIQ.
      *
           IF ES-CIERRE
              PERFORM CALCULAR-FIN-MES.
      *
           MOVE "NO" TO CTL-PROGRAMA.
           MOVE "NO" TO CTL-CCACAUSAC.
           MOVE "NO" TO CTL-CCAMAEAHO.
      *
           MOVE "NO" TO CTL-REGISTRO-MOV.
           PERFORM LEER-CCACAUSAC UNTIL REGISTRO-VALIDO-MOV
                                 OR    FIN-CCACAUSAC.
           MOVE "NO" TO CTL-REGISTRO-MAE.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                 OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       PROCESAR.
           IF FIN-CCACAUSAC
              IF FIN-CCAMAEAHO
                 MOVE "SI" TO CTL-PROGRAMA
              ELSE
                 PERFORM GRABAR-CCAMAEAHO
                 MOVE "NO" TO CTL-REGISTRO-MAE
                 PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                       OR    FIN-CCAMAEAHO
           ELSE
              IF W-CL-CCACAUSAC < W-CL-CCAMAEAHO
      *          PERFORM ERROR-FATAL UNTIL FIN-PROGRAMA
                    MOVE "NO" TO CTL-REGISTRO-MOV
                    PERFORM LEER-CCACAUSAC UNTIL REGISTRO-VALIDO-MOV
                                          OR    FIN-CCACAUSAC
              ELSE
                 IF W-CL-CCACAUSAC = W-CL-CCAMAEAHO
                    PERFORM ACT-ACUMULADO
                    MOVE "NO" TO CTL-REGISTRO-MOV
                    PERFORM LEER-CCACAUSAC UNTIL REGISTRO-VALIDO-MOV
                                          OR    FIN-CCACAUSAC
                 ELSE
                    PERFORM GRABAR-CCAMAEAHO
                    MOVE "NO" TO CTL-REGISTRO-MAE
                    PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                          OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       ERROR-FATAL.
           DISPLAY "CL-CCACAUSAC < CL-CCAMAEAHO..."
                    W-CL-CCACAUSAC " " W-CL-CCAMAEAHO.
           DISPLAY "ERROR FATAL, CANCELAR EL PROCESO...".
      *----------------------------------------------------------------
       LEER-CCACAUSAC.
           MOVE "SI" TO CTL-REGISTRO-MOV.
           READ CCACAUSAC AT END
                MOVE "SI"            TO CTL-CCACAUSAC
                MOVE 999             TO CODMON OF REG-CAUSAC
                MOVE 999             TO CODSIS OF REG-CAUSAC
                MOVE 999             TO CODPRO OF REG-CAUSAC
                MOVE 99999           TO AGCCTA OF REG-CAUSAC
                MOVE 99999999999999999 TO CTANRO OF REG-CAUSAC.
           MOVE CODMON OF REG-CAUSAC TO W-CODMON-CCACAUSAC
           MOVE CODSIS OF REG-CAUSAC TO W-CODSIS-CCACAUSAC
           MOVE CODPRO OF REG-CAUSAC TO W-CODPRO-CCACAUSAC
           MOVE AGCCTA OF REG-CAUSAC TO W-AGCCTA-CCACAUSAC
           MOVE CTANRO OF REG-CAUSAC TO W-CTANRO-CCACAUSAC.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE "SI" TO CTL-REGISTRO-MAE.
           READ CCAMAEAHO AT END
                MOVE "SI"            TO CTL-CCAMAEAHO
                MOVE 999             TO CODMON OF REG-MAESTR
                MOVE 999             TO CODSIS OF REG-MAESTR
                MOVE 999             TO CODPRO OF REG-MAESTR
                MOVE 99999           TO AGCCTA OF REG-MAESTR
                MOVE 99999999999999999 TO CTANRO OF REG-MAESTR.
           MOVE CODMON OF REG-MAESTR TO W-CODMON-CCAMAEAHO
           MOVE CODSIS OF REG-MAESTR TO W-CODSIS-CCAMAEAHO
           MOVE CODPRO OF REG-MAESTR TO W-CODPRO-CCAMAEAHO
           MOVE AGCCTA OF REG-MAESTR TO W-AGCCTA-CCAMAEAHO
           MOVE CTANRO OF REG-MAESTR TO W-CTANRO-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              IF INDBAJ OF REG-MAESTR NOT = 0
                 MOVE "NO" TO CTL-REGISTRO-MAE
              ELSE
                 MOVE ZEROS                TO W-CANDEU
                 MOVE ZEROS                TO W-SALDEU
                 MOVE ZEROS                TO W-CANACR
                 MOVE ZEROS                TO W-SALACR
                 MOVE TABSAL OF REGMAEAHO  TO TABLA-PROMEDIOS.
      *----------------------------------------------------------------
       ACT-ACUMULADO.
           MOVE REG-CAUSAC TO REG-CAUSAS.
           IF NO-ES-CIERRE
              WRITE REG-CAUSAS
           ELSE
      *       IF FORIGE OF REG-CAUSAC > W-FECHACTL-1
      *          WRITE REG-CAUSAS
                 IF SALACT OF REG-CAUSAC NOT < ZEROS
                    ADD 1                    TO W-CANACR
                    ADD SALACT OF REG-CAUSAC TO W-SALACR
                 ELSE
                    ADD 1                    TO W-CANDEU
                    COMPUTE W-SALDEU = W-SALDEU +
                                      (SALACT OF REG-CAUSAC * -1).
      *----------------------------------------------------------------
       GRABAR-CCAMAEAHO.
           IF ES-CIERRE
              PERFORM ROTAR-PROMEDIOS VARYING W-IND-I FROM 12 BY -1
                                      UNTIL   W-IND-I = ZEROS
              MOVE W-CANACR TO CANT-ACREED  (1)
              MOVE W-SALACR TO SALDO-ACREED (1)
              MOVE W-CANDEU TO CANT-DEUDOR  (1)
              MOVE W-SALDEU TO SALDO-DEUDOR (1)
              MOVE TABLA-PROMEDIOS TO TABSAL OF REGMAEAHO
              REWRITE REG-MAESTR.
      *----------------------------------------------------------------
       ROTAR-PROMEDIOS.
           MOVE W-IND-I TO W-IND-J
           ADD  1       TO W-IND-J.
           IF CANT-DEUDOR (W-IND-I) IS NOT NUMERIC
              MOVE ZEROS TO CANT-DEUDOR (W-IND-I)
           END-IF
           MOVE CANT-DEUDOR (W-IND-I) TO CANT-DEUDOR (W-IND-J)
           IF SALDO-DEUDOR (W-IND-I) IS NOT NUMERIC
              MOVE ZEROS TO SALDO-DEUDOR (W-IND-I)
           END-IF
           MOVE SALDO-DEUDOR(W-IND-I) TO SALDO-DEUDOR(W-IND-J)
           IF CANT-ACREED (W-IND-I) IS NOT NUMERIC
              MOVE ZEROS TO CANT-ACREED (W-IND-I)
           END-IF
           MOVE CANT-ACREED (W-IND-I) TO CANT-ACREED (W-IND-J)
           IF SALDO-ACREED (W-IND-I) IS NOT NUMERIC
              MOVE ZEROS TO SALDO-ACREED (W-IND-I)
           END-IF
           MOVE SALDO-ACREED(W-IND-I) TO SALDO-ACREED(W-IND-J).
      *----------------------------------------------------------------
       CALCULAR-FIN-MES.
           MOVE W-FECHALIQ           TO W-FECHACTL-0
           MOVE W-FECHACTL-0         TO W-FECHACTL-1.
           PERFORM PROYECTAR-DIAS    UNTIL MES-CTL-0 NOT = MES-CTL-1.
      *    W-FECHACTL-1 ES EL ULTIMO DIA CALENDARIO DEL MES.
      *----------------------------------------------------------------
       PROYECTAR-DIAS.
           MOVE W-FECHACTL-0 TO W-FECHACTL-1.
           PERFORM SUMAR-UN-DIA-CALENDARIO.
      *----------------------------------------------------------------
       SUMAR-UN-DIA-CALENDARIO.
           MOVE W-FECHACTL-0 TO LK219-FECHA1
           MOVE ZEROS        TO LK219-FECHA2
           MOVE ZEROS        TO LK219-FECHA3
           MOVE 1            TO LK219-TIPFMT
           MOVE 2            TO LK219-BASCLC
           MOVE 1            TO LK219-NRODIA
           MOVE 1            TO LK219-INDDSP
           MOVE 9            TO LK219-DIASEM
           MOVE SPACES       TO LK219-NOMDIA
           MOVE SPACES       TO LK219-NOMMES
           MOVE ZEROS        TO LK219-CODRET
           MOVE SPACES       TO LK219-MSGERR
           MOVE 2            TO LK219-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE LK219-FECHA3   TO W-FECHACTL-0.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.
      *----------------------------------------------------------------
       CALL-CCA502.
           CALL "CCA502" USING W-FIN-MES W-FIN-TRI.
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
           CLOSE CCACAUSAC .
           CLOSE CCAMAEAHO .
           CLOSE CCACAUSAS .
           STOP  RUN      .
      *----------------------------------------------------------------
