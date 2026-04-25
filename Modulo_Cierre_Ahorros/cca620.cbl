       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CCA620.
      ******************************************************************
      * FUNCION: PROGRAMA DE ACTUALIZACION DE ARCHIVO DE CAUSACION DEL *
      *          DIA (CCACAUHOY) CON SALDOS POTENCIALES DE HOY, Y DE LA *
      *          VERSION SECUENCIAL DEL ARCHIVO DE CONTROL DE SALDOS   *
      *          DIARIOS POR CUENTA (CCACAUSAC).                        *
      *          EL ARCHIVO CCAMOVIM (CCACAUHOYF) GUARDA LA CAUSACION A  *
      *          SER CONTABILIZADA EN EL PROCESO DEL SIGUIENTE         *
      *          DIA HABIL (EN ESTE CASO NO SE GUARDA EN CCACAUHOY).    *
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/10/07.
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
           SELECT CLIMAE
               ASSIGN          TO DATABASE-CLIMAE
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
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
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
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIMAE.
           COPY DDS-ALL-FORMATS OF CLIMAE.
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
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *
       FD  CCATRAPRO
           LABEL RECORDS ARE STANDARD.
       01  REG-TRAPRO
           COPY DDS-ALL-FORMATS OF CCATRAPRO.
      *
       WORKING-STORAGE SECTION.
      *
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
      *
       77  W-FECHACTL                  PIC 9(08)          VALUE ZEROS.
       77  W-USERID                    PIC X(10)          VALUE SPACES.
      *77  W-CODCAU                    PIC 9(03)          VALUE 992.
       77  W-IND                       PIC 9(02)          VALUE ZEROS.
      *
      *--------------------------------------------------------------*
       01 PAR-CODCPT       PIC 9(05) VALUE ZEROS.
       01 PAR-AGENCIA      PIC 9(05) VALUE ZEROS.
       01 PAR-CUENTA       PIC 9(17) VALUE ZEROS.
       01 PAR-AGENVA       PIC 9(05) VALUE ZEROS.
       01 PAR-CODRET       PIC 9(01) VALUE ZEROS.
      *--------------------------------------------------------------*
       01  TABLA-FECHAS                PIC X(80)          VALUE SPACES.
       01  R-TABLA-FECHAS              REDEFINES TABLA-FECHAS.
           05  TAB-FECHA OCCURS 10 TIMES.
               10  T-FECHA             PIC 9(08).
               10  R-T-FECHA           REDEFINES T-FECHA.
                   15  T-FECHA-ANO     PIC 9(04).
                   15  T-FECHA-MES     PIC 9(02).
                   15  T-FECHA-DIA     PIC 9(02).
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO                  VALUE "SI".
               88  NO-FIN-CCAMAEAHO               VALUE "NO".
           05  CTL-CCATRAPRO            PIC X(02) VALUE "NO".
               88  FIN-CCATRAPRO                  VALUE "SI".
               88  NO-FIN-CCATRAPRO               VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
           05  CTL-HABIL               PIC 9(01) VALUE 0.
               88  ERROR-HABIL                   VALUE 1.
      *
      * PARAMETROS RUTINA CALCULO FECHAS (PLT219).
      *
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
      *
      * VARIABLES RUTINA CALCULO INTERESES.
      *
       01  PAR-CCA490.
           05  P490-CODPRO             PIC 9(03)       .
           05  P490-PLNINT             PIC 9(05)       .
           05  P490-FORIGE             PIC 9(08)       .
           05  P490-SALACT             PIC S9(13)V99   .
           05  P490-PUNADI             PIC S9(03)V9(04).
           05  P490-TIPOPR             PIC 9(01)       .
           05  P490-INTERES            PIC S9(13)V99   .
           05  P490-EQUEFE             PIC 9(04)V9(07) .
           05  P490-EQUDIA             PIC 9(04)V9(07) .
           05  P490-RETENCI            PIC S9(13)V99   .
           05  P490-RETCOD             PIC 9(02)       .
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
      *
       LINKAGE SECTION.
       77  XUSERID PIC X(10).
      *
      ***************************************************************
      *
       PROCEDURE DIVISION USING XUSERID.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMAEAHO.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           MOVE XUSERID TO W-USERID.
      *
           OPEN INPUT  CCAMAEAHO CCATRAPRO CLIMAE
           OPEN OUTPUT CCACAUSAC.
           OPEN OUTPUT CCAMOVIM .
           OPEN EXTEND CCACAUHOY.
      *
           MOVE ZEROS TO CTL-HABIL
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
           IF MES-24 NOT = MES-HOY THEN
              MOVE 1 TO CTL-HABIL.
           PERFORM LLENAR-TABLA-FECHAS.
      *
           MOVE "NO" TO CTL-CCAMAEAHO
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       LLENAR-TABLA-FECHAS.
           MOVE ZEROS      TO W-IND.
           MOVE ZEROS      TO TABLA-FECHAS.
           MOVE W-FECHAHOY TO W-FECHACTL.
           PERFORM SUME-UN-DIA-CALENDARIO
                   UNTIL W-FECHACTL = W-FECHA24.
      *----------------------------------------------------------------
       SUME-UN-DIA-CALENDARIO.
           ADD  1          TO W-IND
           MOVE W-FECHACTL TO T-FECHA(W-IND).
      *
           MOVE W-FECHACTL TO F-FECHA1
           MOVE ZEROS      TO F-FECHA2
           MOVE ZEROS      TO F-FECHA3
           MOVE 1          TO F-TIPFMT
           MOVE 2          TO F-BASCLC
           MOVE 1          TO F-NRODIA
           MOVE 1          TO F-INDDSP
           MOVE 9          TO F-DIASEM
           MOVE SPACES     TO F-NOMDIA
           MOVE SPACES     TO F-NOMMES
           MOVE ZEROS      TO F-CODRET
           MOVE SPACES     TO F-MSGERR
           MOVE 2          TO F-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE F-FECHA3   TO W-FECHACTL.
      *----------------------------------------------------------------
       PROCESAR.
           PERFORM GRABAR-CAUSACION VARYING W-IND FROM 1 BY 1
                                    UNTIL   W-IND > 10
                                    OR      T-FECHA(W-IND) = ZEROS.
      *
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
           MOVE T-FECHA(W-IND)       TO W-FECHACTL
           MOVE CODMON OF REG-MAESTR TO CODMON OF REG-CAUSAC
           MOVE CODSIS OF REG-MAESTR TO CODSIS OF REG-CAUSAC
           MOVE CODPRO OF REG-MAESTR TO CODPRO OF REG-CAUSAC
           MOVE AGCCTA OF REG-MAESTR TO AGCCTA OF REG-CAUSAC
           MOVE CTANRO OF REG-MAESTR TO CTANRO OF REG-CAUSAC
           MOVE W-FECHACTL           TO FORIGE OF REG-CAUSAC
           MOVE SALCON OF REG-MAESTR TO SALACT OF REG-CAUSAC
           MOVE ZEROS                TO VALCAU OF REG-CAUSAC
           MOVE ZEROS                TO VLRRET OF REG-CAUSAC
           MOVE ZEROS                TO EQUEFE OF REG-CAUSAC.
           IF SALACT OF REG-CAUSAC > ZEROS
              PERFORM CALCULAR-CAUSACION
              IF P490-RETCOD = ZEROS
                 MOVE P490-INTERES TO VALCAU OF REG-CAUSAC
                 MOVE P490-RETENCI TO VLRRET OF REG-CAUSAC
                 MOVE P490-EQUEFE  TO EQUEFE OF REG-CAUSAC.
      *
           PERFORM GRABAR-AJUSTE.
      *
           WRITE   REG-CAUSAC.
      *----------------------------------------------------------------
       GRABAR-AJUSTE.
           IF VALCAU OF REG-CAUSAC > ZEROS
              PERFORM LLENAR-FIJOS
              MOVE LK-TRACAU TO CODPRO OF REG-TRAPRO
              MOVE CODPRO OF REG-CAUSAC TO PRODUC OF REG-TRAPRO
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
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF REG-CAUSAC
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-IF
              PERFORM UNTIL FIN-CCATRAPRO
                 PERFORM LLENAR-FIJOS
                 PERFORM EVALUAR-VALOR
                 MOVE TRADEB OF CCATRAPRO TO CODTRA OF REG-CAUHOY
                 MOVE 1                   TO DEBCRE OF REG-CAUHOY
                 IF T-FECHA-DIA(W-IND) NOT < DIA-HOY
                    WRITE REG-CAUHOY
                 ELSE
                    MOVE REG-CAUHOY TO REG-MOVIM
                    MOVE W-FECHA24 TO FORIGE OF REG-MOVIM
                    MOVE W-FECHA24 TO FVALOR OF REG-MOVIM
                    WRITE REG-MOVIM
                 END-IF
                 PERFORM LLENAR-FIJOS
                 MOVE TRACRE OF CCATRAPRO TO CODTRA OF REG-CAUHOY
                 MOVE 2                   TO DEBCRE OF REG-CAUHOY
                 IF T-FECHA-DIA(W-IND) NOT < DIA-HOY
                    WRITE REG-CAUHOY
                 ELSE
                    MOVE REG-CAUHOY TO REG-MOVIM
                    MOVE W-FECHA24 TO FORIGE OF REG-MOVIM
                    MOVE W-FECHA24 TO FVALOR OF REG-MOVIM
                    WRITE REG-MOVIM
                 END-IF
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRACAU
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF REG-CAUSAC
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
           MOVE W-FECHAHOY           TO FVALOR OF REG-CAUHOY
           MOVE NITCTA OF REG-MAESTR TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           MOVE NITCTA OF REG-MAESTR TO NROREF OF REG-CAUHOY
           MOVE NITCLI OF REG-CLIMAE TO NRONIT OF REG-CAUHOY
           MOVE ZEROS                TO FECVAL OF REG-CAUHOY
           MOVE ZEROS                TO TIPVAL OF REG-CAUHOY
           MOVE ZEROS                TO ESTTRN OF REG-CAUHOY
           MOVE AGCCTA OF REG-CAUSAC TO AGCORI OF REG-CAUHOY
           MOVE W-USERID             TO CODCAJ OF REG-CAUHOY.
      *----------------------------------------------------------------
       CALCULAR-CAUSACION.
           MOVE CODPRO OF REG-MAESTR TO P490-CODPRO
           MOVE PLNINT OF REG-MAESTR TO P490-PLNINT
           MOVE W-FECHAHOY           TO P490-FORIGE
           MOVE SALCON OF REG-MAESTR TO P490-SALACT
           MOVE PUNADI OF REG-MAESTR TO P490-PUNADI
           MOVE 2                    TO P490-TIPOPR
           MOVE ZEROS                TO P490-INTERES
           MOVE ZEROS                TO P490-EQUEFE
           MOVE ZEROS                TO P490-EQUDIA
           MOVE ZEROS                TO P490-RETENCI
           MOVE ZEROS                TO P490-RETCOD.
           IF ERROR-HABIL THEN
              MOVE W-FECHACTL        TO P490-FORIGE
              MOVE 1                 TO P490-TIPOPR.
           CALL "CCA490" USING PAR-CCA490.
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
       LEER-CLIMAE.
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO NITCLI OF CLIMAE
           END-READ.
      *----------------------------------------------------------------
       LEER-CCATRAPRO-NEXT.
           READ CCATRAPRO NEXT AT END
                MOVE "SI" TO CTL-CCATRAPRO.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMAEAHO  CCATRAPRO
           CLOSE CCACAUSAC  CLIMAE
           CLOSE CCACAUHOY .
           CLOSE CCAMOVIM  .
           STOP  RUN       .
      *----------------------------------------------------------------
