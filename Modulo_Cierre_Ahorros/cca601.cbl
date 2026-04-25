       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CCA601.
      ***********************************************************
      * FUNCION: PROGRAMA DE GENERACION DE CAUSACION DIARIA     *
      *          (CCACAUHOY) CON SALDOS ANTERIORES, CREA TAMBIEN*
      *          ARCHIVO DE CONTROL DE SALDOS DIARIOS X CUENTA  *
      *          (CCACAUSAC). TEMPORAL(CCACAUSAS)               *
      *          CAUSA LOS INTERESES DEL DIA Y DIAS ANTERIORES  *
      *          NO HABILES                                     +      *
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
               ASSIGN          TO DATABASE-CCAMAEAHO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACAUSAC
               ASSIGN          TO DATABASE-CCACAUSAC
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCACAUHOY
               ASSIGN          TO DATABASE-CCACAUHOY
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCATRAPRO
               ASSIGN          TO DATABASE-CCATRAPRO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACODPRO
               ASSIGN          TO DATABASE-CCACODPRO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLIMAE
               ASSIGN          TO DATABASE-CLIMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
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
           COPY DDS-ALL-FORMATS OF CCACAUSAS.
      *
       FD  CCACAUHOY
           LABEL RECORDS ARE STANDARD.
       01  REG-CAUHOY.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *
       FD  CCATRAPRO
           LABEL RECORDS ARE STANDARD.
       01  REG-TRAPRO.
           COPY DDS-ALL-FORMATS OF CCATRAPRO.
      *
       FD  CCACODPRO
           LABEL RECORDS ARE STANDARD.
       01  REG-CODPRO.
           COPY DDS-ALL-FORMATS OF CCACODPRO.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIMAE.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *
       WORKING-STORAGE SECTION.
      *
       01  W-DIAS-SOBREGIRO            PIC 9(05) VALUE ZEROS.
       01  W-FECHAANT                  PIC 9(08)          VALUE ZEROS.
       01  W-FECHAHOY                  PIC 9(08)          VALUE ZEROS.
       01  R-FECHAHOY                  REDEFINES W-FECHAHOY.
           05  ANO-HOY                 PIC 9(04).
           05  MES-HOY                 PIC 9(02).
           05  DIA-HOY                 PIC 9(02).
       01  W-FECHA24                   PIC 9(08)          VALUE ZEROS.
       01  R-FECHA24                   REDEFINES W-FECHA24.
           05  ANO-24                  PIC 9(04).
           05  MES-24                  PIC 9(02).
           05  DIA-24                  PIC 9(02).
       01  W-FECHA                     PIC 9(08)          VALUE ZEROS.
       01  R-FECHA                     REDEFINES W-FECHA.
           05  ANO-FECHA               PIC 9(04).
           05  MES-FECHA               PIC 9(02).
           05  DIA-FECHA               PIC 9(02).
      *
       77  W-FECHACTL                  PIC 9(08)          VALUE ZEROS.
       77  W-USERID                    PIC X(10)          VALUE SPACES.
       77  W-IND                       PIC 9(02)          VALUE ZEROS.
      *--------------------------------------------------------------*
       01 PAR-CODCPT       PIC 9(05) VALUE ZEROS.
       01 PAR-AGENCIA      PIC 9(05) VALUE ZEROS.
       01 PAR-CUENTA       PIC 9(17) VALUE ZEROS.
       01 PAR-AGENVA       PIC 9(05) VALUE ZEROS.
       01 PAR-CODRET       PIC 9(01) VALUE ZEROS.
      *--------------------------------------------------------------*
       01  W-CODPRO-ANT                 PIC 999 VALUE ZEROS.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO                  VALUE "SI".
               88  NO-FIN-CCAMAEAHO               VALUE "NO".
           05  CTL-CCATRAPRO            PIC X(02) VALUE "NO".
               88  FIN-CCATRAPRO                  VALUE "SI".
               88  NO-FIN-CCATRAPRO               VALUE "NO".
           05  CTL-CLIMAE               PIC X(02) VALUE "NO".
               88  FIN-CLIMAE                     VALUE "SI".
               88  NO-FIN-CLIMAE                  VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
      * -------------------------------------
      * PARAMETROS RUTINA CALCULO FECHAS (PLT219).
      * -------------------------------------
       77  F-FECHA1                    PIC 9(08) VALUE ZEROS.
       77  F-FECHA2                    PIC 9(08) VALUE ZEROS.
       77  F-FECHA3                    PIC 9(08) VALUE ZEROS.
       77  F-TIPFMT                    PIC 9(01) VALUE ZEROS.
       77  F-BASCLC                    PIC 9(01) VALUE ZEROS.
       77  F-NRODIA                    PIC 9(05) VALUE ZEROS.
       77  F-INDDSP                    PIC 9(01) VALUE ZEROS.
       77  F-DIASEM                    PIC 9(01) VALUE ZEROS.
       77  F-NOMDIA                    PIC X(10) VALUE SPACES.
       77  F-NOMMES                    PIC X(10) VALUE SPACES.
       77  F-CODRET                    PIC 9(01) VALUE ZEROS.
       77  F-MSGERR                    PIC X(40) VALUE SPACES.
       77  F-TIPOPR                    PIC 9(01) VALUE ZEROS.
       77  W-NROPER                    PIC 9(04) VALUE ZEROS.
      *
      * VARIABLES RUTINA CALCULO INTERESES.
      *
       01  PAR-CCA492.
           05  P492-CODPRO             PIC 9(03)       .
           05  P492-PLNINT             PIC 9(05)       .
           05  P492-FORIGE             PIC 9(08)       .
           05  P492-NROPER             PIC 9(04)       .
           05  P492-SALACT             PIC S9(13)V99   .
           05  P492-PUNADI             PIC S9(03)V9(04).
           05  P492-TIPOPR             PIC 9(01)       .
           05  P492-INTERES            PIC S9(13)V99   .
           05  P492-EQUEFE             PIC 9(04)V9(07) .
           05  P492-EQUDIA             PIC 9(04)V9(07) .
           05  P492-RETENCI            PIC S9(13)V99   .
           05  P492-RETCOD             PIC 9(02)       .
      * ----------------------
       01  W-FIN-MES                   PIC X VALUE "N".
       01  W-FIN-TRI                   PIC X VALUE "N".
       01  W-SDO-DIA                   PIC X VALUE "N".
      * ----------------------
       01  PAR-CCA491.
           05  P491-CODTAR             PIC 9(05)    .
           05  P491-TIPTAR             PIC 9(01)    .
           05  P491-VALOR-TRA          PIC S9(13)V99.
           05  P491-VALOR-TAR          PIC S9(13)V99.
      * ----------------------
           COPY PARGEN OF CCACPY.
           COPY FECHAS OF CCACPY.
      * ----------------------
       LINKAGE SECTION.
       77  XUSERID PIC X(10).
      ***************************************************************
       PROCEDURE DIVISION USING XUSERID.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMAEAHO.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           MOVE XUSERID TO W-USERID.
      *
           OPEN INPUT  CCATRAPRO CCACODPRO CLIMAE
           OPEN I-O    CCAMAEAHO
           OPEN OUTPUT CCACAUSAC.
           OPEN EXTEND CCACAUHOY.
      *
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
           PERFORM CALL-CCA502.
           PERFORM CALL-CCA503.
           PERFORM CALCULA-DIAS-A-CAUSAR.
      *
           MOVE "NO" TO CTL-CCAMAEAHO
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              MOVE CODPRO OF CCAMAEAHO      TO W-CODPRO-ANT
              PERFORM LEER-CCACODPRO
           END-IF.
      *----------------------------------------------------------------
       CALCULA-DIAS-A-CAUSAR.
           MOVE W-FECHAANT TO F-FECHA1
           MOVE W-FECHAHOY TO F-FECHA2
           IF W-FIN-MES = "S"
              MOVE W-FECHA24 TO W-FECHA
      *       MOVE F-FECHA2 TO W-FECHA
              MOVE 1        TO DIA-FECHA
              MOVE W-FECHA  TO F-FECHA2
           ELSE
              IF HOY-MM NOT = AYER-MM
                 MOVE W-FECHAHOY  TO W-FECHA
      *       IF W-SDO-DIA = "S"
      *          MOVE F-FECHA1 TO W-FECHA
                 MOVE 1        TO DIA-FECHA
                 MOVE W-FECHA  TO F-FECHA1
              END-IF
           END-IF
           MOVE ZEROS      TO F-FECHA3
           MOVE 1          TO F-TIPFMT
           MOVE 2          TO F-BASCLC
           MOVE 0          TO F-NRODIA
           MOVE 1          TO F-INDDSP
           MOVE ZEROS      TO F-DIASEM
           MOVE SPACES     TO F-NOMDIA
           MOVE SPACES     TO F-NOMMES
           MOVE ZEROS      TO F-CODRET
           MOVE SPACES     TO F-MSGERR
           MOVE 4          TO F-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE F-NRODIA   TO W-NROPER.
      *----------------------------------------------------------------
       PROCESAR.
           IF CODPRO OF CCAMAEAHO NOT = W-CODPRO-ANT
              PERFORM LEER-CCACODPRO
              MOVE CODPRO OF CCAMAEAHO  TO W-CODPRO-ANT
           END-IF.
           MOVE NITCTA OF CCAMAEAHO TO NUMINT OF CLIMAE.
           PERFORM LEER-CLIMAE.
           PERFORM GRABAR-CAUSACION.
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMAEAHO AT END
                MOVE "SI" TO CTL-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              IF INDBAJ OF REG-MAESTR NOT = 0
                 MOVE "NO" TO CTL-REGISTRO
              ELSE
                 PERFORM CALCULAR-CTA-ESPECIAL
                 IF CTANRO OF REG-MAESTR = PAR-CUENTA
                    MOVE "NO" TO CTL-REGISTRO.
      *----------------------------------------------------------------
       CALCULAR-CTA-ESPECIAL.
           MOVE 1                     TO PAR-CODCPT
           MOVE AGCCTA OF REG-MAESTR  TO PAR-AGENCIA
           MOVE ZEROS                 TO PAR-CUENTA PAR-AGENVA
                                         PAR-CODRET
           CALL "CCA990" USING PAR-CODCPT
                               PAR-AGENCIA
                               PAR-CUENTA
                               PAR-AGENVA
                               PAR-CODRET
           END-CALL.
      *----------------------------------------------------------------
       GRABAR-CAUSACION.
           INITIALIZE REGCAUSAC.
           MOVE CODMON OF REG-MAESTR TO CODMON OF REG-CAUSAC
           MOVE CODSIS OF REG-MAESTR TO CODSIS OF REG-CAUSAC
           MOVE CODPRO OF REG-MAESTR TO CODPRO OF REG-CAUSAC
           MOVE AGCCTA OF REG-MAESTR TO AGCCTA OF REG-CAUSAC
           MOVE CTANRO OF REG-MAESTR TO CTANRO OF REG-CAUSAC
           MOVE W-FECHAHOY           TO FORIGE OF REG-CAUSAC
           IF TIPLIQ OF CCACODPRO = 2
              MOVE SALANT OF REG-MAESTR TO SALACT OF REG-CAUSAC
           ELSE
              IF TIPLIQ OF CCACODPRO = 1
                 PERFORM CALCULAR-PROMEDIO
              ELSE
                 MOVE SALACT OF REG-MAESTR TO SALACT OF REG-CAUSAC
              END-IF
           END-IF
           MOVE ZEROS                TO VALCAU OF REG-CAUSAC
           MOVE ZEROS                TO VLRRET OF REG-CAUSAC
           MOVE ZEROS                TO EQUEFE OF REG-CAUSAC.
           MOVE PERCAU OF CCACODPRO  TO INDMRT OF REG-CAUSAC
           IF SALACT OF REG-CAUSAC NOT < VMLINT OF CCACODPRO
              PERFORM CALCULAR-CAUSACION
              IF P492-RETCOD = ZEROS
                 MOVE P492-INTERES TO VALCAU OF REG-CAUSAC
                 MOVE P492-RETENCI TO VLRRET OF REG-CAUSAC
                 MOVE P492-EQUEFE  TO EQUEFE OF REG-CAUSAC
                 IF RETFTE OF CLIMAE = 2
                    MOVE ZEROS TO VLRRET OF REG-CAUSAC
                 END-IF
              END-IF
           END-IF.
      *
           PERFORM GRABAR-REGISTROS.
      *----------------------------------------------------------------
       CALCULAR-PROMEDIO.
      *----------------------------------------------------------------
       GRABAR-REGISTROS.
           IF VALCAU OF REG-CAUSAC > ZEROS
              PERFORM LLENAR-FIJOS
              MOVE LK-TRACAU TO CODPRO OF REG-TRAPRO
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
                    IF CODPRO OF CCATRAPRO NOT = LK-TRACAU
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF CCAMAEAHO
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-IF
              PERFORM UNTIL FIN-CCATRAPRO
                 PERFORM LLENAR-FIJOS
                 IF TRADEB OF CCATRAPRO NOT = ZEROS
                    PERFORM EVALUAR-VALOR
                    MOVE TRADEB OF CCATRAPRO TO CODTRA OF REG-CAUHOY
                    MOVE 1                   TO DEBCRE OF REG-CAUHOY
                    WRITE REG-CAUHOY
                 END-IF
                 PERFORM LLENAR-FIJOS
                 IF TRACRE OF CCATRAPRO NOT = ZEROS
                    MOVE TRACRE OF CCATRAPRO TO CODTRA OF REG-CAUHOY
                    MOVE 2                   TO DEBCRE OF REG-CAUHOY
                    WRITE REG-CAUHOY
                 END-IF
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRACAU
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF CCAMAEAHO
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-PERFORM
              MOVE PERCAU OF CCACODPRO TO INDMRT OF REG-CAUSAC
           END-IF.
           WRITE   REG-CAUSAC.
           IF SALACT OF REG-MAESTR < ZEROS
              IF FINSOB OF REG-MAESTR = ZEROS
                 MOVE FULMOV OF REG-MAESTR TO FINSOB OF REG-MAESTR
              END-IF
              PERFORM CALCULAR-DIAS-SOBREGIRO
              MOVE W-DIAS-SOBREGIRO TO NRODSO OF REG-MAESTR
      *       ADD W-NROPER          TO DDSBGO OF REG-MAESTR
           ELSE
              MOVE ZEROS           TO FINSOB OF REG-MAESTR
              MOVE ZEROS           TO NRODSO OF REG-MAESTR
           END-IF
           REWRITE REG-MAESTR.
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
           MOVE IMPORT OF REG-CAUHOY TO P491-VALOR-TRA
           MOVE ZEROS  TO P491-VALOR-TAR
           MOVE CODTAR OF CCATRAPRO TO P491-CODTAR
           CALL "CCA491" USING PAR-CCA491.
           MOVE P491-VALOR-TAR TO IMPORT OF REG-CAUHOY.
      *----------------------------------------------------------------
       LLENAR-FIJOS.
           INITIALIZE REGMOVIM OF REG-CAUHOY
           MOVE CODMON OF REG-CAUSAC TO CODMON OF REG-CAUHOY
           MOVE CODSIS OF REG-CAUSAC TO CODSIS OF REG-CAUHOY
           MOVE CODPRO OF REG-CAUSAC TO CODPRO OF REG-CAUHOY
           MOVE AGCCTA OF REG-CAUSAC TO AGCCTA OF REG-CAUHOY
           MOVE CTANRO OF REG-CAUSAC TO CTANRO OF REG-CAUHOY
           MOVE W-FECHAHOY           TO FORIGE OF REG-CAUHOY
           MOVE VALCAU OF REG-CAUSAC TO IMPORT OF REG-CAUHOY
           MOVE W-FECHAANT           TO FVALOR OF REG-CAUHOY
           MOVE NITCTA OF REG-MAESTR TO NROREF OF REG-CAUHOY
           MOVE NITCLI OF CLIMAE     TO NRONIT OF REG-CAUHOY
           MOVE DESCRI OF REG-MAESTR TO INFDEP OF REG-CAUHOY
           MOVE ZEROS                TO FECVAL OF REG-CAUHOY
           MOVE ZEROS                TO TIPVAL OF REG-CAUHOY
           MOVE ZEROS                TO ESTTRN OF REG-CAUHOY
           MOVE AGCCTA OF REG-CAUSAC TO AGCORI OF REG-CAUHOY
           MOVE REGION OF REG-MAESTR TO NROBNV OF REG-CAUHOY
           MOVE W-USERID             TO CODCAJ OF REG-CAUHOY.
      *----------------------------------------------------------------
       CALCULAR-CAUSACION.
           MOVE W-NROPER             TO P492-NROPER
           MOVE CODPRO OF REG-MAESTR TO P492-CODPRO
           MOVE PLNINT OF REG-MAESTR TO P492-PLNINT
           MOVE W-FECHAHOY           TO P492-FORIGE
           MOVE SALACT OF REG-CAUSAC TO P492-SALACT
           MOVE PUNADI OF REG-MAESTR TO P492-PUNADI
           MOVE 1                    TO P492-TIPOPR
           MOVE ZEROS                TO P492-INTERES
           MOVE ZEROS                TO P492-EQUEFE
           MOVE ZEROS                TO P492-EQUDIA
           MOVE ZEROS                TO P492-RETENCI
           MOVE ZEROS                TO P492-RETCOD.
           CALL "CCA492" USING PAR-CCA492.
      *----------------------------------------------------------------
       CALCULAR-DIAS-SOBREGIRO.
           MOVE FINSOB OF REG-MAESTR TO F-FECHA1
           MOVE LK-FECHA-HOY         TO F-FECHA2
           MOVE ZEROS      TO F-FECHA3
           MOVE 1          TO F-TIPFMT
           MOVE 2          TO F-BASCLC
           MOVE 0          TO F-NRODIA
           MOVE 1          TO F-INDDSP
           MOVE ZEROS      TO F-DIASEM
           MOVE SPACES     TO F-NOMDIA
           MOVE SPACES     TO F-NOMMES
           MOVE ZEROS      TO F-CODRET
           MOVE SPACES     TO F-MSGERR
           MOVE 4          TO F-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE F-NRODIA   TO W-DIAS-SOBREGIRO.
      *----------------------------------------------------------------
       CALL-CCA500.
           INITIALIZE LK-FECHAS.
           CALL "CCA500" USING LK-FECHAS.
           MOVE LK-FECHA-AYER   TO W-FECHAANT
           MOVE LK-FECHA-HOY    TO W-FECHAHOY
           MOVE LK-FECHA-MANANA TO W-FECHA24.
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.
      *----------------------------------------------------------------
       CALL-CCA502.
           CALL "CCA502" USING W-FIN-MES W-FIN-TRI.
      *----------------------------------------------------------------
       CALL-CCA503.
           CALL "CCA503" USING W-SDO-DIA.
      *----------------------------------------------------------------
       CALL-PLT219.
           CALL "PLT219" USING
                         F-FECHA1
                         F-FECHA2
                         F-FECHA3
                         F-TIPFMT
                         F-BASCLC
                         F-NRODIA
                         F-INDDSP
                         F-DIASEM
                         F-NOMDIA
                         F-NOMMES
                         F-CODRET
                         F-MSGERR
                         F-TIPOPR.
      *----------------------------------------------------------------
       LEER-CCACODPRO.
           MOVE CODPRO OF CCAMAEAHO TO CODPRO OF CCACODPRO.
           READ CCACODPRO INVALID KEY
                DISPLAY "PRODUCTO NO EXISTE " CODPRO OF CCAMAEAHO
                PERFORM TERMINAR.
      *----------------------------------------------------------------
       LEER-CCATRAPRO-NEXT.
           READ CCATRAPRO NEXT AT END
                MOVE "SI" TO CTL-CCATRAPRO.
      *----------------------------------------------------------------
       LEER-CLIMAE.
           MOVE "NO" TO CTL-CLIMAE.
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO RETFTE OF CLIMAE
                MOVE "SI" TO CTL-CLIMAE.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMAEAHO  CCATRAPRO CLIMAE
           CLOSE CCACAUSAC .
           CLOSE CCACAUHOY .
           CLOSE CCACODPRO .
           STOP  RUN       .
      *----------------------------------------------------------------
