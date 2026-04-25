       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CCA610.
      ******************************************************************
      * FUNCION: PROGRAMA DE GENERACION DE INTERESES Y RETENCION A LAS *
      *          CUENTAS,  Y ACTUALIZACION DE LOS SALDOS Y DE LOS      *
      *          PROMEDIOS DE LAS MISMAS.                              *
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/10/08.
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
           SELECT CCAMOVINT
               ASSIGN          TO DATABASE-CCAMOVINT
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CLIMAE
               ASSIGN          TO DATABASE-CLIMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCATRAPRO
               ASSIGN          TO DATABASE-CCATRAPRO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCATRAPRO
           LABEL RECORDS ARE STANDARD.
       01  REG-TRAPRO.
           COPY DDS-ALL-FORMATS OF CCATRAPRO.
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
       FD  CCAMOVINT
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVINT.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIMAE.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *
       WORKING-STORAGE SECTION.
      *
           COPY CATABPRO OF CCACPY.
      *
       77  W-FECHALIQ               PIC 9(08)            VALUE ZEROS.
       77  W-INTERES                PIC S9(13)V99   COMP VALUE ZEROS.
       77  W-RETENCI                PIC S9(13)V99   COMP VALUE ZEROS.
       77  W-USERID                 PIC X(10)            VALUE SPACES.
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
           05  CTL-CCATRAPRO            PIC X(02) VALUE "NO".
               88  FIN-CCATRAPRO                  VALUE "SI".
               88  NO-FIN-CCATRAPRO               VALUE "NO".
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
           05  CTL-PROGRAMA            PIC X(02) VALUE "NO".
               88  FIN-PROGRAMA                  VALUE "SI".
               88  NO-FIN-PROGRAMA               VALUE "NO".
      * -----------------
       01  PAR-CCA491.
           05  P491-CODTAR             PIC 9(05)    .
           05  P491-TIPTAR             PIC 9(01)    .
           05  P491-VALOR-TRA          PIC S9(13)V99.
           05  P491-VALOR-TAR          PIC S9(13)V99.
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
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           MOVE XUSERID TO W-USERID.
      *
           OPEN INPUT  CCACAUSAC  CCATRAPRO.
           OPEN INPUT  CLIMAE  .
           OPEN I-O    CCAMAEAHO.
           OPEN OUTPUT CCAMOVINT.
           OPEN OUTPUT CCAMOVIM .
      *
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
      *
           IF LK-FECHA-HOY > LK-FECLIQ
              IF LK-INDCIE = 1
                 NEXT SENTENCE
              ELSE
                 PERFORM TERMINAR
           ELSE
              PERFORM TERMINAR.
           MOVE LK-FECLIQ TO W-FECHALIQ.
      *
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
                 PERFORM GRABAR-CCAMOVINT
                 MOVE "NO" TO CTL-REGISTRO-MAE
                 PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO-MAE
                                       OR    FIN-CCAMAEAHO
           ELSE
              IF W-CL-CCACAUSAC < W-CL-CCAMAEAHO
                 PERFORM ERROR-FATAL UNTIL FIN-PROGRAMA
              ELSE
                 IF W-CL-CCACAUSAC = W-CL-CCAMAEAHO
                    PERFORM ACT-ACUMULADO
                    MOVE "NO" TO CTL-REGISTRO-MOV
                    PERFORM LEER-CCACAUSAC UNTIL REGISTRO-VALIDO-MOV
                                          OR    FIN-CCACAUSAC
                 ELSE
                    PERFORM GRABAR-CCAMAEAHO
                    PERFORM GRABAR-CCAMOVINT
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
                MOVE "SI"              TO CTL-CCACAUSAC
                MOVE 999               TO CODMON OF REG-CAUSAC
                MOVE 999               TO CODSIS OF REG-CAUSAC
                MOVE 999               TO CODPRO OF REG-CAUSAC
                MOVE 99999             TO AGCCTA OF REG-CAUSAC
                MOVE 99999999999999999 TO CTANRO OF REG-CAUSAC.
           MOVE CODMON OF REG-CAUSAC   TO W-CODMON-CCACAUSAC
           MOVE CODSIS OF REG-CAUSAC   TO W-CODSIS-CCACAUSAC
           MOVE CODPRO OF REG-CAUSAC   TO W-CODPRO-CCACAUSAC
           MOVE AGCCTA OF REG-CAUSAC   TO W-AGCCTA-CCACAUSAC
           MOVE CTANRO OF REG-CAUSAC   TO W-CTANRO-CCACAUSAC.
           IF NO-FIN-CCACAUSAC
              IF FORIGE OF REG-CAUSAC > W-FECHACTL-1
                 MOVE "NO" TO CTL-REGISTRO-MOV.
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
                 MOVE "NO" TO CTL-REGISTRO-MAE
              ELSE
                 MOVE ZEROS                TO W-CANDEU
                 MOVE ZEROS                TO W-SALDEU
                 MOVE ZEROS                TO W-CANACR
                 MOVE ZEROS                TO W-SALACR
                 MOVE ZEROS                TO W-INTERES
                 MOVE ZEROS                TO W-RETENCI
                 MOVE TABSAL OF REGMAEAHO  TO TABLA-PROMEDIOS
                 PERFORM LEER-CLIMAE.
      *----------------------------------------------------------------
       LEER-CLIMAE.
           MOVE NITCTA OF REG-MAESTR TO NUMINT OF REG-CLIMAE.
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO RETFTE OF REG-CLIMAE.
      *----------------------------------------------------------------
       ACT-ACUMULADO.
           ADD VALCAU OF REG-CAUSAC TO W-INTERES.
           IF RETFTE OF REG-CLIMAE NOT = 2
              ADD VLRRET OF REG-CAUSAC TO W-RETENCI.
      *
           IF SALACT OF REG-CAUSAC NOT < ZEROS
              ADD 1                    TO W-CANACR
              ADD SALACT OF REG-CAUSAC TO W-SALACR
           ELSE
              ADD 1                    TO W-CANDEU
              COMPUTE W-SALDEU = W-SALDEU +
                                (SALACT OF REG-CAUSAC * -1).
      *----------------------------------------------------------------
       GRABAR-CCAMAEAHO.
           ADD      W-INTERES TO   SALANT OF REG-MAESTR
           ADD      W-INTERES TO   SALACT OF REG-MAESTR
           SUBTRACT W-RETENCI FROM SALANT OF REG-MAESTR
           SUBTRACT W-RETENCI FROM SALACT OF REG-MAESTR.
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
       GRABAR-CCAMOVINT.
           IF W-INTERES > ZEROS
              PERFORM LLENAR-FIJOS
              MOVE W-INTERES TO IMPORT OF REG-MOVINT
              MOVE LK-TRAINT TO CODPRO OF REG-TRAPRO
              MOVE CODPRO OF CCAMAEAHO TO PRODUC OF REG-TRAPRO
              MOVE ZEROS     TO TRADEB OF REG-TRAPRO
              MOVE ZEROS     TO TRACRE OF REG-TRAPRO
              MOVE "NO" TO CTL-CCATRAPRO
              START CCATRAPRO KEY NOT < EXTERNALLY-DESCRIBED-KEY
                    INVALID KEY MOVE "SI" TO CTL-CCATRAPRO
              END-START
              IF NO-FIN-CCATRAPRO
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRAINT
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF CCAMAEAHO
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-IF
              PERFORM UNTIL FIN-CCATRAPRO
                 PERFORM LLENAR-FIJOS
                 MOVE W-INTERES TO IMPORT OF REG-MOVINT
                 PERFORM EVALUAR-VALOR
                 MOVE TRADEB OF CCATRAPRO TO CODTRA OF REG-MOVINT
                 MOVE 1                   TO DEBCRE OF REG-MOVINT
                 MOVE REG-MOVINT          TO REG-MOVIM
                 WRITE REG-MOVINT
                 PERFORM LLENAR-FIJOS
                 MOVE W-INTERES TO IMPORT OF REG-MOVINT
                 MOVE W-FECHACTL-1        TO FORIGE OF REG-MOVIM
                 MOVE W-FECHACTL-1        TO FVALOR OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LLENAR-FIJOS
                 MOVE W-INTERES TO IMPORT OF REG-MOVINT
                 MOVE TRACRE OF CCATRAPRO TO CODTRA OF REG-MOVINT
                 MOVE 2                   TO DEBCRE OF REG-MOVINT
                 MOVE REG-MOVINT          TO REG-MOVIM
                 WRITE REG-MOVINT
                 PERFORM LLENAR-FIJOS
                 MOVE W-INTERES TO IMPORT OF REG-MOVINT
                 MOVE W-FECHACTL-1        TO FORIGE OF REG-MOVIM
                 MOVE W-FECHACTL-1        TO FVALOR OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRAINT
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF CCAMAEAHO
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-PERFORM.
           IF W-RETENCI > ZEROS
              PERFORM LLENAR-FIJOS
              MOVE W-RETENCI         TO IMPORT OF REG-MOVINT
              MOVE LK-TRARET         TO CODPRO OF REG-TRAPRO
              MOVE CODPRO OF CCAMAEAHO TO CODPRO OF REG-TRAPRO
              MOVE ZEROS             TO TRADEB OF REG-TRAPRO
              MOVE ZEROS             TO TRACRE OF REG-TRAPRO
              MOVE "NO" TO CTL-CCATRAPRO
              START CCATRAPRO KEY NOT < EXTERNALLY-DESCRIBED-KEY
                    INVALID KEY MOVE "SI" TO CTL-CCATRAPRO
              END-START
              IF NO-FIN-CCATRAPRO
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRARET
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF CCAMAEAHO
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-IF
              PERFORM UNTIL FIN-CCATRAPRO
                 PERFORM LLENAR-FIJOS
                 MOVE W-RETENCI         TO IMPORT OF REG-MOVINT
                 PERFORM EVALUAR-VALOR
                 MOVE TRADEB OF CCATRAPRO TO CODTRA OF REG-MOVINT
                 MOVE 1                   TO DEBCRE OF REG-MOVINT
                 MOVE REG-MOVINT          TO REG-MOVIM
                 WRITE REG-MOVINT
                 PERFORM LLENAR-FIJOS
                 MOVE W-RETENCI         TO IMPORT OF REG-MOVINT
                 MOVE W-FECHACTL-1        TO FORIGE OF REG-MOVIM
                 MOVE W-FECHACTL-1        TO FVALOR OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LLENAR-FIJOS
                 MOVE W-RETENCI         TO IMPORT OF REG-MOVINT
                 MOVE TRACRE OF CCATRAPRO TO CODTRA OF REG-MOVINT
                 MOVE 2                   TO DEBCRE OF REG-MOVINT
                 MOVE REG-MOVINT          TO REG-MOVIM
                 WRITE REG-MOVINT
                 PERFORM LLENAR-FIJOS
                 MOVE W-RETENCI         TO IMPORT OF REG-MOVINT
                 MOVE W-FECHACTL-1        TO FORIGE OF REG-MOVIM
                 MOVE W-FECHACTL-1        TO FVALOR OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRARET
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF CCAMAEAHO
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-PERFORM.
      *----------------------------------------------------------------
       EVALUAR-VALOR.
           IF TIPVAL OF CCATRAPRO = 2 OR 3
              IF TIPVAL OF CCATRAPRO = 2
                 MOVE 1 TO P491-TIPTAR
              ELSE
                 MOVE 2 TO P491-TIPTAR
              END-IF
              PERFORM CALCULAR-VLR-TARIFA
           END-IF.
      *----------------------------------------------------------------
       CALCULAR-VLR-TARIFA.
           MOVE IMPORT OF REG-MOVINT TO P491-VALOR-TRA
           MOVE ZEROS  TO P491-VALOR-TAR
           MOVE CODTAR OF CCATRAPRO TO P491-CODTAR
           CALL "CCA491" USING PAR-CCA491.
           MOVE P491-VALOR-TAR TO IMPORT OF REG-MOVINT.
      *----------------------------------------------------------------
       LLENAR-FIJOS.
           INITIALIZE REGMOVIM       OF REG-MOVINT
           MOVE CODMON OF REG-MAESTR TO CODMON OF REG-MOVINT
           MOVE CODSIS OF REG-MAESTR TO CODSIS OF REG-MOVINT
           MOVE CODPRO OF REG-MAESTR TO CODPRO OF REG-MOVINT
           MOVE AGCCTA OF REG-MAESTR TO AGCCTA OF REG-MOVINT
           MOVE CTANRO OF REG-MAESTR TO CTANRO OF REG-MOVINT
           MOVE W-FECHALIQ           TO FORIGE OF REG-MOVINT
           MOVE W-FECHALIQ           TO FVALOR OF REG-MOVINT
           MOVE NITCTA OF REG-MAESTR TO NROREF OF REG-MOVINT
           MOVE NITCLI OF CLIMAE     TO NRONIT OF REG-MOVINT
           MOVE DESCRI OF REG-MAESTR TO INFDEP OF REG-MOVINT
           MOVE 1                    TO FECVAL OF REG-MOVINT
           MOVE 6                    TO TIPVAL OF REG-MOVINT
           MOVE ZEROS                TO ESTTRN OF REG-MOVINT
           MOVE AGCCTA OF REG-MAESTR TO AGCORI OF REG-MOVINT
           MOVE W-USERID             TO CODCAJ OF REG-MOVINT.
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
       LEER-CCATRAPRO-NEXT.
           READ CCATRAPRO NEXT AT END
                MOVE "SI" TO CTL-CCATRAPRO.
      *----------------------------------------------------------------
       CALL-PLT219.
           CALL "PLT219" USING  LK219-FECHA1
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
           CLOSE CCACAUSAC  CCATRAPRO.
           CLOSE CCAMAEAHO .
           CLOSE CCAMOVINT .
           CLOSE CCAMOVIM  .
           CLOSE CLIMAE .
           STOP  RUN      .
      *----------------------------------------------------------------
