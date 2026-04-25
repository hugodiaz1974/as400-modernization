       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CCA605.
      ******************************************************************
      * FUNCION: PROGRAMA DE ACTUALIZACION DE AJUSTES CON RETROFECHA   *
      *          EN LA GENERACION DE LA CAUSACION.                     *
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/10/06.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCARETROF
               ASSIGN          TO DATABASE-CCARETROF
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACAUSAC
               ASSIGN          TO DATABASE-CCACAUSAC
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCATRAPRO
               ASSIGN          TO DATABASE-CCATRAPRO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLIMAE
               ASSIGN          TO DATABASE-CLIMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCARETROF
           LABEL RECORDS ARE STANDARD.
       01  REG-RETROF.
           COPY DDS-ALL-FORMATS OF CCARETROF.
      *
       FD  CCACAUSAC
           LABEL RECORDS ARE STANDARD.
       01  REG-CAUSAC.
           COPY DDS-ALL-FORMATS OF CCACAUSAC.
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
       COPY CATABPRO OF CCACPY.
      *
       01  W-FECHAANT                  PIC 9(08)          VALUE ZEROS.
       01  R-FECHAANT                  REDEFINES W-FECHAANT.
           05  ANO-ANT                 PIC 9(04).
           05  MES-ANT                 PIC 9(02).
           05  DIA-ANT                 PIC 9(02).
       01  W-FECHAHOY                  PIC 9(08)          VALUE ZEROS.
       01  R-FECHAHOY                  REDEFINES W-FECHAHOY.
           05  ANO-HOY                 PIC 9(04).
           05  MES-HOY                 PIC 9(02).
           05  DIA-HOY                 PIC 9(02).
       01  W-FECHA24                   PIC 9(08)          VALUE ZEROS.
      *
       01  W-FECHACON                  PIC 9(08)          VALUE ZEROS.
      *
       01  W-FECHACAU                  PIC 9(08)          VALUE ZEROS.
       01  R-FECHACAU                  REDEFINES W-FECHACAU.
           05  ANO-CAU                 PIC 9(04).
           05  MES-CAU                 PIC 9(02).
           05  DIA-CAU                 PIC 9(02).
      *
       01  W-FECHALIQ                  PIC 9(08)          VALUE ZEROS.
       01  R-FECHALIQ                  REDEFINES W-FECHALIQ.
           05  ANO-LIQ                 PIC 9(04).
           05  MES-LIQ                 PIC 9(02).
           05  DIA-LIQ                 PIC 9(02).
      *
       77  W-USERID                    PIC X(10)          VALUE SPACES.
      *77  W-CODREV                    PIC 9(03)          VALUE 991.
      *77  W-CODAJU                    PIC 9(03)          VALUE 993.
      *
       01  W-CL-CCARETROF.
           05  W-CODMON                PIC 9(03)          VALUE ZEROS.
           05  W-CODSIS                PIC 9(03)          VALUE ZEROS.
           05  W-CODPRO                PIC 9(03)          VALUE ZEROS.
           05  W-AGCCTA                PIC 9(05)          VALUE ZEROS.
           05  W-CTANRO                PIC 9(17)          VALUE ZEROS.
           05  W-FORIGE                PIC 9(08)          VALUE ZEROS.
      *
       01  ACUMULADOS.
           05  W-ACUMOV                PIC S9(13)V99 COMP VALUE ZEROS.
           05  W-CANDEU-O              PIC  9(03)         VALUE ZEROS.
           05  W-SALDEU-O              PIC S9(15)V99 COMP VALUE ZEROS.
           05  W-CANACR-O              PIC  9(03)         VALUE ZEROS.
           05  W-SALACR-O              PIC S9(15)V99 COMP VALUE ZEROS.
           05  W-CANDEU-I              PIC  9(03)         VALUE ZEROS.
           05  W-SALDEU-I              PIC S9(15)V99 COMP VALUE ZEROS.
           05  W-CANACR-I              PIC  9(03)         VALUE ZEROS.
           05  W-SALACR-I              PIC S9(15)V99 COMP VALUE ZEROS.
      *
       01  CONTROLES.
           05  CTL-CCARETROF            PIC X(02) VALUE "NO".
               88  FIN-CCARETROF                  VALUE "SI".
               88  NO-FIN-CCARETROF               VALUE "NO".
           05  CTL-CCACAUSAC            PIC X(02) VALUE "NO".
               88  FIN-CCACAUSAC                  VALUE "SI".
               88  NO-FIN-CCACAUSAC               VALUE "NO".
           05  CTL-CCATRAPRO            PIC X(02) VALUE "NO".
               88  FIN-CCATRAPRO                  VALUE "SI".
               88  NO-FIN-CCATRAPRO               VALUE "NO".
      *
      * VARIABLES RUTINA CALCULO INTERESES.
      *
       01  PAR-CCA490.
           05  P490-CODPRO             PIC 9(03)           .
           05  P490-PLNINT             PIC 9(05)           .
           05  P490-FORIGE             PIC 9(08)           .
           05  P490-SALACT             PIC S9(13)V99       .
           05  P490-PUNADI             PIC S9(03)V9(04)    .
           05  P490-TIPOPR             PIC 9(01)           .
           05  P490-INTERES            PIC S9(13)V99       .
           05  P490-EQUEFE             PIC 9(04)V9(07)     .
           05  P490-EQUDIA             PIC 9(04)V9(07)     .
           05  P490-RETENCI            PIC S9(13)V99       .
           05  P490-RETCOD             PIC 9(02)           .
      * ----------------------
       01  PAR-CCA491.
           05  P491-CODTAR             PIC 9(05)    .
           05  P491-TIPTAR             PIC 9(01)    .
           05  P491-VALOR-TRA          PIC S9(13)V99.
           05  P491-VALOR-TAR          PIC S9(13)V99.
      * ------------------------------------
           COPY PARGEN OF CCACPY.
           COPY FECHAS OF CCACPY.
      * ------------------------------------
      *
       LINKAGE SECTION.
       77  XUSERID PIC X(10).
      *
      ***************************************************************
      *
       PROCEDURE DIVISION USING XUSERID.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCARETROF.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           MOVE XUSERID TO W-USERID.
      *
           OPEN INPUT  CCARETROF.
           OPEN INPUT  CCATRAPRO.
           OPEN I-O    CCACAUSAC.
           OPEN I-O    CCAMAEAHO.
           OPEN EXTEND CCAMOVIM .
      *
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
           MOVE LK-FECLIQ TO W-FECHALIQ.
      *
           MOVE "NO"  TO CTL-CCARETROF
           MOVE ZEROS TO CODMON OF REG-RETROF
           MOVE ZEROS TO CODSIS OF REG-RETROF
           MOVE ZEROS TO CODPRO OF REG-RETROF
           MOVE ZEROS TO AGCCTA OF REG-RETROF
           MOVE ZEROS TO CTANRO OF REG-RETROF
           MOVE ZEROS TO FORIGE OF REG-RETROF
           START CCARETROF KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY
                 MOVE "SI" TO CTL-CCARETROF.
           PERFORM MARCAR-CCACAUSAC UNTIL FIN-CCARETROF.
      *
           MOVE ZEROS TO W-CODMON
           MOVE ZEROS TO W-CODSIS
           MOVE ZEROS TO W-CODPRO
           MOVE ZEROS TO W-AGCCTA
           MOVE ZEROS TO W-CTANRO
           MOVE ZEROS TO W-FORIGE
           PERFORM START-CCARETROF.
           IF NO-FIN-CCARETROF
              PERFORM LEER-CCARETROF-NEXT.
      *----------------------------------------------------------------
       MARCAR-CCACAUSAC.
           READ CCARETROF NEXT AT END
                MOVE "SI" TO CTL-CCARETROF.
           IF NO-FIN-CCARETROF
              MOVE CODMON OF REG-RETROF TO CODMON OF REG-CAUSAC
              MOVE CODSIS OF REG-RETROF TO CODSIS OF REG-CAUSAC
              MOVE CODPRO OF REG-RETROF TO CODPRO OF REG-CAUSAC
              MOVE AGCCTA OF REG-RETROF TO AGCCTA OF REG-CAUSAC
              MOVE CTANRO OF REG-RETROF TO CTANRO OF REG-CAUSAC
              MOVE FORIGE OF REG-RETROF TO FORIGE OF REG-CAUSAC
              READ CCACAUSAC INVALID KEY DISPLAY
                                        CODMON OF REG-CAUSAC
                                        CODSIS OF REG-CAUSAC
                                        CODPRO OF REG-CAUSAC
                                        AGCCTA OF REG-CAUSAC
                                        CTANRO OF REG-CAUSAC
                                        FORIGE OF REG-CAUSAC
                             PERFORM GRABAR-CCACAUSAC
              NOT INVALID KEY
                  MOVE 1          TO INDMRT OF REG-CAUSAC
                  REWRITE REG-CAUSAC.
      *----------------------------------------------------------------
       GRABAR-CCACAUSAC.
           INITIALIZE REGCAUSAC.
           MOVE CODMON OF REG-RETROF TO CODMON OF REG-CAUSAC
           MOVE CODSIS OF REG-RETROF TO CODSIS OF REG-CAUSAC
           MOVE CODPRO OF REG-RETROF TO CODPRO OF REG-CAUSAC
           MOVE AGCCTA OF REG-RETROF TO AGCCTA OF REG-CAUSAC
           MOVE CTANRO OF REG-RETROF TO CTANRO OF REG-CAUSAC
           MOVE FORIGE OF REG-RETROF TO FORIGE OF REG-CAUSAC
           MOVE 1                    TO INDMRT OF REG-CAUSAC.
           MOVE ZEROS                TO SALACT OF REG-CAUSAC.
           MOVE ZEROS                TO VALCAU OF REG-CAUSAC.
           MOVE ZEROS                TO VLRRET OF REG-CAUSAC.
           MOVE ZEROS                TO EQUEFE OF REG-CAUSAC.
           WRITE REG-CAUSAC.
      *----------------------------------------------------------------
       PROCESAR.
           PERFORM INICIAR-ACUMULADOS.
      *
           MOVE CODMON OF REG-RETROF TO W-CODMON
           MOVE CODSIS OF REG-RETROF TO W-CODSIS
           MOVE CODPRO OF REG-RETROF TO W-CODPRO
           MOVE AGCCTA OF REG-RETROF TO W-AGCCTA
           MOVE CTANRO OF REG-RETROF TO W-CTANRO
           MOVE FORIGE OF REG-RETROF TO W-FORIGE.
      *
           PERFORM LEER-CCAMAEAHO.
      *
           PERFORM START-CCACAUSAC.
           PERFORM LEER-CCACAUSAC-NEXT.
           PERFORM BARRER-CCACAUSAC UNTIL FIN-CCACAUSAC.
           PERFORM ACTUALIZAR-PROMEDIOS.
      *
           REWRITE REG-MAESTR.
      *
           PERFORM START-CCARETROF.
           IF NO-FIN-CCARETROF
              PERFORM LEER-CCARETROF-NEXT.
      *----------------------------------------------------------------
       BARRER-CCACAUSAC.
           PERFORM GRABAR-REVERSION.
           PERFORM ACUMULAR-O.
           IF INDMRT OF REG-CAUSAC = 1
              MOVE CODMON OF REG-CAUSAC TO CODMON OF REG-RETROF
              MOVE CODSIS OF REG-CAUSAC TO CODSIS OF REG-RETROF
              MOVE CODPRO OF REG-CAUSAC TO CODPRO OF REG-RETROF
              MOVE AGCCTA OF REG-CAUSAC TO AGCCTA OF REG-RETROF
              MOVE CTANRO OF REG-CAUSAC TO CTANRO OF REG-RETROF
              MOVE FORIGE OF REG-CAUSAC TO FORIGE OF REG-RETROF
              READ CCARETROF
              IF DEBCRE OF REG-RETROF = 1
                 SUBTRACT IMPORT OF REG-RETROF FROM W-ACUMOV
              ELSE
                 ADD      IMPORT OF REG-RETROF TO   W-ACUMOV
              END-IF
              MOVE ZEROS TO INDMRT OF REG-CAUSAC
           END-IF
      *
           ADD  W-ACUMOV TO SALACT OF REG-CAUSAC
           MOVE ZEROS    TO VALCAU OF REG-CAUSAC
           MOVE ZEROS    TO VLRRET OF REG-CAUSAC
           MOVE ZEROS    TO EQUEFE OF REG-CAUSAC.
           IF SALACT OF REG-CAUSAC > ZEROS
              PERFORM CALCULAR-CAUSACION.
      *
           REWRITE REG-CAUSAC.
           PERFORM GRABAR-AJUSTE.
           PERFORM ACUMULAR-I.
      *
           PERFORM LEER-CCACAUSAC-NEXT.
           IF NO-FIN-CCACAUSAC
              IF (AGCCTA OF REG-CAUSAC NOT = W-AGCCTA) OR
                 (CODMON OF REG-CAUSAC NOT = W-CODMON) OR
                 (CODSIS OF REG-CAUSAC NOT = W-CODSIS) OR
                 (CODPRO OF REG-CAUSAC NOT = W-CODPRO) OR
                 (CTANRO OF REG-CAUSAC NOT = W-CTANRO)
                 MOVE "SI" TO CTL-CCACAUSAC.
      *----------------------------------------------------------------
       GRABAR-REVERSION.
           IF VALCAU OF REG-CAUSAC > ZEROS
              PERFORM LLENAR-FIJOS
              MOVE LK-TRAREV TO CODPRO OF REG-TRAPRO
              MOVE CODPRO OF REG-CAUSAC TO PRODUC OF REG-TRAPRO
              MOVE ZEROS     TO TRADEB OF REG-TRAPRO
              MOVE ZEROS     TO TRACRE OF REG-TRAPRO
              MOVE "NO" TO CTL-CCATRAPRO
              START CCARETROF KEY NOT < EXTERNALLY-DESCRIBED-KEY
                    INVALID KEY MOVE "SI" TO CTL-CCATRAPRO
              END-START
              IF NO-FIN-CCATRAPRO
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRAREV
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF REG-CAUSAC
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-IF
              PERFORM UNTIL FIN-CCATRAPRO
                 PERFORM LLENAR-FIJOS
                 PERFORM EVALUAR-VALOR
                 MOVE TRADEB OF CCATRAPRO TO CODTRA OF REG-MOVIM
                 MOVE 1                   TO DEBCRE OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LLENAR-FIJOS
                 MOVE TRACRE OF CCATRAPRO TO CODTRA OF REG-MOVIM
                 MOVE 2                   TO DEBCRE OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRAREV
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
           MOVE IMPORT OF REG-MOVIM TO P491-VALOR-TRA
           MOVE ZEROS  TO P491-VALOR-TAR
           MOVE CODTAR OF CCATRAPRO TO P491-CODTAR
           CALL "CCA491" USING PAR-CCA491.
           MOVE P491-VALOR-TAR TO IMPORT OF REG-MOVIM.
      *----------------------------------------------------------------
       GRABAR-AJUSTE.
           IF VALCAU OF REG-CAUSAC > ZEROS
              PERFORM LLENAR-FIJOS
              MOVE LK-TRAAJU TO CODPRO OF REG-TRAPRO
              MOVE CODPRO OF REG-CAUSAC TO PRODUC OF REG-TRAPRO
              MOVE ZEROS     TO TRADEB OF REG-TRAPRO
              MOVE ZEROS     TO TRACRE OF REG-TRAPRO
              MOVE "NO" TO CTL-CCATRAPRO
              START CCARETROF KEY NOT < EXTERNALLY-DESCRIBED-KEY
                    INVALID KEY MOVE "SI" TO CTL-CCATRAPRO
              END-START
              IF NO-FIN-CCATRAPRO
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRAAJU
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF REG-CAUSAC
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-IF
              PERFORM UNTIL FIN-CCATRAPRO
                 PERFORM LLENAR-FIJOS
                 PERFORM EVALUAR-VALOR
                 MOVE TRADEB OF CCATRAPRO TO CODTRA OF REG-MOVIM
                 MOVE 1                   TO DEBCRE OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LLENAR-FIJOS
                 PERFORM EVALUAR-VALOR
                 MOVE TRACRE OF CCATRAPRO TO CODTRA OF REG-MOVIM
                 MOVE 2                   TO DEBCRE OF REG-MOVIM
                 WRITE REG-MOVIM
                 PERFORM LEER-CCATRAPRO-NEXT
                 IF NO-FIN-CCATRAPRO
                    IF CODPRO OF CCATRAPRO NOT = LK-TRAAJU
                    OR PRODUC OF CCATRAPRO NOT = CODPRO OF REG-CAUSAC
                       MOVE "SI" TO CTL-CCATRAPRO
                    END-IF
                 END-IF
              END-PERFORM.
      *----------------------------------------------------------------
       LLENAR-FIJOS.
           INITIALIZE REGMOVIM
           MOVE CODMON OF REG-CAUSAC TO CODMON OF REG-MOVIM
           MOVE CODSIS OF REG-CAUSAC TO CODSIS OF REG-MOVIM
           MOVE CODPRO OF REG-CAUSAC TO CODPRO OF REG-MOVIM
           MOVE AGCCTA OF REG-CAUSAC TO AGCCTA OF REG-MOVIM
           MOVE CTANRO OF REG-CAUSAC TO CTANRO OF REG-MOVIM
           MOVE VALCAU OF REG-CAUSAC TO IMPORT OF REG-MOVIM
           MOVE DESCRI OF REG-MAESTR TO INFDEP OF REG-MOVIM
           MOVE NITCTA OF REG-MAESTR TO NROREF OF REG-MOVIM
           MOVE NITCLI OF CLIMAE     TO NRONIT OF REG-MOVIM
           MOVE ZEROS                TO FECVAL OF REG-MOVIM
           MOVE ZEROS                TO TIPVAL OF REG-MOVIM
           MOVE ZEROS                TO ESTTRN OF REG-MOVIM
           MOVE AGCCTA OF REG-CAUSAC TO AGCORI OF REG-MOVIM
           MOVE W-USERID             TO CODCAJ OF REG-MOVIM.
      *
      * SE DETERMINA LA FECHA CON LA CUAL DEBE SER
      * CONTABILIZADA LA REVERSION Y EL AJUSTE.
      *
           MOVE ZEROS                TO W-FECHACON
           MOVE FORIGE OF REG-CAUSAC TO W-FECHACAU
           IF MES-CAU = MES-LIQ
              IF MES-HOY = MES-LIQ
                 MOVE W-FECHAANT TO W-FECHACON
              ELSE
                 MOVE W-FECHALIQ TO W-FECHACON
           ELSE
              IF MES-ANT NOT = MES-HOY
                 MOVE W-FECHAHOY TO W-FECHACON
              ELSE
                 MOVE W-FECHAANT TO W-FECHACON.
      *
           MOVE W-FECHACON TO FORIGE OF REG-MOVIM
           MOVE W-FECHACON TO FVALOR OF REG-MOVIM.
      *----------------------------------------------------------------
       ACUMULAR-O.
           IF SALACT OF REG-CAUSAC NOT < ZEROS
              ADD 1                    TO W-CANACR-O
              ADD SALACT OF REG-CAUSAC TO W-SALACR-O
           ELSE
              ADD 1                    TO W-CANDEU-O
              COMPUTE W-SALDEU-O = W-SALDEU-O +
                                  (SALACT OF REG-CAUSAC * -1).
      *----------------------------------------------------------------
       ACUMULAR-I.
           IF SALACT OF REG-CAUSAC NOT < ZEROS
              ADD 1                    TO W-CANACR-I
              ADD SALACT OF REG-CAUSAC TO W-SALACR-I
           ELSE
              ADD 1                    TO W-CANDEU-I
              COMPUTE W-SALDEU-I = W-SALDEU-I +
                                  (SALACT OF REG-CAUSAC * -1).
      *----------------------------------------------------------------
       CALCULAR-CAUSACION.
           MOVE CODPRO OF REG-MAESTR TO P490-CODPRO
           MOVE PLNINT OF REG-MAESTR TO P490-PLNINT
           MOVE FORIGE OF REG-CAUSAC TO P490-FORIGE
           MOVE SALACT OF REG-CAUSAC TO P490-SALACT
           MOVE PUNADI OF REG-MAESTR TO P490-PUNADI
           MOVE 1                    TO P490-TIPOPR
           MOVE ZEROS                TO P490-INTERES
           MOVE ZEROS                TO P490-EQUEFE
           MOVE ZEROS                TO P490-EQUDIA
           MOVE ZEROS                TO P490-RETENCI
           MOVE ZEROS                TO P490-RETCOD.
           CALL "CCA490" USING PAR-CCA490.
           IF P490-RETCOD = ZEROS
              MOVE P490-INTERES TO VALCAU OF REG-CAUSAC
              MOVE P490-RETENCI TO VLRRET OF REG-CAUSAC
              MOVE P490-EQUEFE  TO EQUEFE OF REG-CAUSAC.
      *----------------------------------------------------------------
       START-CCARETROF.
           MOVE "NO"     TO CTL-CCARETROF
           MOVE W-CODMON TO CODMON OF REG-RETROF
           MOVE W-CODSIS TO CODSIS OF REG-RETROF
           MOVE W-CODPRO TO CODPRO OF REG-RETROF
           MOVE W-AGCCTA TO AGCCTA OF REG-RETROF
           MOVE W-CTANRO TO CTANRO OF REG-RETROF
           MOVE 99999999 TO FORIGE OF REG-RETROF
           START CCARETROF KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY
                 MOVE "SI" TO CTL-CCARETROF.
      *----------------------------------------------------------------
       LEER-CCARETROF-NEXT.
           READ CCARETROF NEXT AT END
                MOVE "SI" TO CTL-CCARETROF.
      *----------------------------------------------------------------
       LEER-CCATRAPRO-NEXT.
           READ CCATRAPRO NEXT AT END
                MOVE "SI" TO CTL-CCATRAPRO.
      *----------------------------------------------------------------
       START-CCACAUSAC.
           MOVE "NO"     TO CTL-CCACAUSAC
           MOVE W-CODMON TO CODMON OF REG-CAUSAC
           MOVE W-CODSIS TO CODSIS OF REG-CAUSAC
           MOVE W-CODPRO TO CODPRO OF REG-CAUSAC
           MOVE W-AGCCTA TO AGCCTA OF REG-CAUSAC
           MOVE W-CTANRO TO CTANRO OF REG-CAUSAC
           MOVE W-FORIGE TO FORIGE OF REG-CAUSAC.
           START CCACAUSAC KEY = EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY
                 MOVE "SI" TO CTL-CCACAUSAC.
      *----------------------------------------------------------------
       LEER-CCACAUSAC-NEXT.
           READ CCACAUSAC NEXT AT END
                MOVE "SI" TO CTL-CCACAUSAC.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE W-CODMON TO CODMON OF REG-MAESTR
           MOVE W-CODSIS TO CODSIS OF REG-MAESTR
           MOVE W-CODPRO TO CODPRO OF REG-MAESTR
           MOVE W-AGCCTA TO AGCCTA OF REG-MAESTR
           MOVE W-CTANRO TO CTANRO OF REG-MAESTR.
           READ CCAMAEAHO.
           MOVE TABSAL OF REGMAEAHO  TO TABLA-PROMEDIOS.
           PERFORM LEER-CLIMAE.
      *----------------------------------------------------------------
       LEER-CLIMAE.
           MOVE NITCTA OF REG-MAESTR TO NUMINT OF REG-CLIMAE.
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO RETFTE OF REG-CLIMAE.
      *----------------------------------------------------------------
       INICIAR-ACUMULADOS.
           MOVE ZEROS TO W-ACUMOV
           MOVE ZEROS TO W-CANDEU-O
           MOVE ZEROS TO W-SALDEU-O
           MOVE ZEROS TO W-CANACR-O
           MOVE ZEROS TO W-SALACR-O
           MOVE ZEROS TO W-CANDEU-I
           MOVE ZEROS TO W-SALDEU-I
           MOVE ZEROS TO W-CANACR-I
           MOVE ZEROS TO W-SALACR-I.
      *----------------------------------------------------------------
       ACTUALIZAR-PROMEDIOS.
           SUBTRACT W-CANDEU-O  FROM CANT-DEUDOR(1).
           SUBTRACT W-SALDEU-O  FROM SALDO-DEUDOR(1).
           SUBTRACT W-CANACR-O  FROM CANT-ACREED(1).
           SUBTRACT W-SALACR-O  FROM SALDO-ACREED(1).
           ADD      W-CANDEU-I  TO   CANT-DEUDOR(1).
           ADD      W-SALDEU-I  TO   SALDO-DEUDOR(1).
           ADD      W-CANACR-I  TO   CANT-ACREED(1).
           ADD      W-SALACR-I  TO   SALDO-ACREED(1).
           MOVE TABLA-PROMEDIOS TO   TABSAL OF REGMAEAHO.
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
       TERMINAR.
           CLOSE CCARETROF .
           CLOSE CCACAUSAC .
           CLOSE CCAMAEAHO .
           CLOSE CCAMOVIM  .
           STOP  RUN      .
      *----------------------------------------------------------------
