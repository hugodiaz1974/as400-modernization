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
       PROGRAM-ID.    CCA512.
       AUTHOR.        M.H.D.
       DATE-WRITTEN.  97/09/23.
      ******************************************************************
      * FUNCION: PROCESA ARCHIVO DE INTERFASE MONETARIA.               *
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
      ******************************************************************
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN1
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT PLTCANCIU
               ASSIGN          TO DATABASE-PLTCANCIU
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT PLTFECHAS
               ASSIGN                  TO DATABASE-PLTFECHAS
               ORGANIZATION            IS INDEXED
               ACCESS MODE             IS DYNAMIC
               RECORD KEY              IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAMOVRECI
               ASSIGN                  TO DATABASE-CCAMOVRECI
               ORGANIZATION            IS INDEXED
               ACCESS MODE             IS DYNAMIC
               RECORD KEY              IS EXTERNALLY-DESCRIBED-KEY
                                          WITH DUPLICATES.
      *
           SELECT CCAINTERF
               ASSIGN          TO DATABASE-CCATRNMON
               ORGANIZATION    IS RELATIVE
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCAMOERR
               ASSIGN          TO DATABASE-CCAMOERR
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *                                                                -
      ******************************************************************
      *                                                                *
       DATA DIVISION.
       FILE SECTION.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  REG-AGCORI.
           COPY DDS-ALL-FORMATS        OF PLTAGCORI.
      *
       FD  PLTFECHAS
           LABEL RECORDS               ARE STANDARD.
       01  PLTFECHAS-REC.
           COPY DD-ALL-FORMATS         OF  PLTFECHAS.
      *
       FD  PLTCANCIU
           LABEL RECORDS               ARE STANDARD.
       01  PLTCANCIU-REC.
           COPY DD-ALL-FORMATS         OF  PLTCANCIU.
      *
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  REG-TABTR.
           COPY DDS-ALL-FORMATS        OF CCACODTRN1.
      *
       FD  CCAINTERF
           LABEL RECORDS ARE STANDARD.
       01  REG-CCAINTERF.
           COPY DDS-ALL-FORMATS        OF CCATRNMON.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS        OF CCAMOVIM.
      *
       FD  CCAMOVRECI
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVRECI.
           COPY DDS-ALL-FORMATS        OF CCAMOVRECI.
      *
       FD  CCAMOERR
           LABEL RECORDS ARE STANDARD.
       01  REG-CCAMOERR.
           COPY DDS-ALL-FORMATS        OF CCAMOVIM.
      *
      ******************************************************************
      *                                                                -
       WORKING-STORAGE SECTION.
      *
       01  FILSTAT.
           03  ERR-FLG            PIC  X(001).
           03  PFK-BYTE           PIC  X(001).
      *
       01  W-CNSTRN         PIC 9(09) VALUE ZEROS.
       01  VAR-TRABAJO.
           03  K                  PIC  9(006)             VALUE ZEROS.
           03  VAR-PARAMETRO      PIC  X(073)             VALUE ZEROS.
           03  RED-VAR-PARAMETRO    REDEFINES    VAR-PARAMETRO.
               05  FLG-TABLA      PIC  9(001)             VALUE ZEROS.
               05  FLG-LINEA      PIC  9(001)             VALUE ZEROS.
                   88 EN-LINEA                            VALUE 0.
                   88 EN-BATCH                            VALUE 1.
               05  NOM-BILBIOTECA PIC  X(010)             VALUE SPACES.
               05  NOM-INTERFASE  PIC  X(010)             VALUE SPACES.
               05  ACUM-CR-OK     PIC  9(013)V99 COMP-3   VALUE ZEROS.
               05  ACUM-DB-OK     PIC  9(013)V99 COMP-3   VALUE ZEROS.
               05  NUM-REG-OK     PIC  9(007)    COMP-3   VALUE ZEROS.
               05  ACUM-CR-ER     PIC  9(013)V99 COMP-3   VALUE ZEROS.
               05  ACUM-DB-ER     PIC  9(013)V99 COMP-3   VALUE ZEROS.
               05  NUM-REG-ER     PIC  9(007)    COMP-3   VALUE ZEROS.
               05  FILLER         PIC  X(011).
      *
       01  CONTROLES.
           03  CTL-CCAINTERF       PIC  X(002)             VALUE "NO".
               88  FIN-CCAINTERF                           VALUE "SI".
               88  NO-FIN-CCAINTERF                        VALUE "NO".
           03  CTL-CCACODTRN        PIC  X(002)             VALUE "NO".
               88  FIN-CCACODTRN                            VALUE "SI".
               88  NO-FIN-CCACODTRN                         VALUE "NO".
           03  CTL-PLTAGCORI        PIC  X(002)             VALUE "NO".
               88  FIN-PLTAGCORI                            VALUE "SI".
               88  NO-FIN-PLTAGCORI                         VALUE "NO".
           03  W-EXISTE-PLTCANCIU   PIC  9(01) VALUE ZEROS.
               88  NO-EXISTE-PLTCANCIU VALUE 0.
               88  SI-EXISTE-PLTCANCIU VALUE 1.
           03  W-FIN-PLTCANCIU      PIC  9(01) VALUE ZEROS.
               88  NO-FIN-PLTCANCIU VALUE 0.
               88  SI-FIN-PLTCANCIU VALUE 1.
           03  CTL-REGISTRO       PIC  X(002)             VALUE "NO".
               88  BUEN-REGISTRO                          VALUE "SI".
               88  MAL-REGISTRO                           VALUE "NO".
      *----------------------------------------------------------------
       01  CUENTA-COOMEVA.
           03  FILLER                      PIC 9(04).
           03  WS-AGENCIA                  PIC 9(04).
           03  WS-CUENTA                   PIC 9(06).
           03  WS-PRODUCTO                 PIC 99.
       01  DISENO                          PIC X(10) VALUE SPACES.
       01  PA-CODEMP                       PIC 9(05) VALUE ZEROS.
VGQ    01  W-FECHA-3                       PIC 9(08) VALUE ZEROS.
VGQ    01  W-FECHA-4                       PIC 9(08) VALUE ZEROS.
VGQ    01  W-FECHA-5                       PIC 9(08) VALUE ZEROS.
      *--------------------------------------------------------------*
      * PARAMETROS RUTINA CALCULO FECHAS (PLT219).
      *--------------------------------------------------------------*
        01 LK-PLT219.
           05  LK219-FECHA1                PIC 9(08) VALUE ZEROS.
           05  LK219-FECHA2                PIC 9(08) VALUE ZEROS.
           05  LK219-FECHA3                PIC 9(08) VALUE ZEROS.
           05  LK219-TIPFMT                PIC 9(01) VALUE ZEROS.
           05  LK219-BASCLC                PIC 9(01) VALUE ZEROS.
           05  LK219-NRODIA                PIC 9(05) VALUE ZEROS.
           05  LK219-INDDSP                PIC 9(01) VALUE ZEROS.
           05  LK219-DIASEM                PIC 9(01) VALUE ZEROS.
           05  LK219-NOMDIA                PIC X(10) VALUE SPACES.
           05  LK219-NOMMES                PIC X(10) VALUE SPACES.
           05  LK219-CODRET                PIC 9(01) VALUE ZEROS.
           05  LK219-MSGERR                PIC X(40) VALUE SPACES.
           05  LK219-TIPOPR                PIC 9(01) VALUE ZEROS.
      ***************************************************************
      *Verificar si la Oficina Compensa Con BanRepublica.
       01  PYC-CODEMP                           PIC 9(05).
       01  PYC-AGCORI                           PIC 9(05).
       01  PYC-INDCIE                           PIC 9(01).
      *
      ***************************************************************
      *
       LINKAGE SECTION.
       01  PARAMETRO1                  PIC  X(073).
      *
      ***************************************************************
      *
       PROCEDURE DIVISION  USING PARAMETRO1.
       0000-MAIN.
           PERFORM  0010-INICIAR
           PERFORM  0100-PROCESAR      UNTIL FIN-CCAINTERF
           PERFORM  9999-TERMINAR.
      *----------------------------------------------------------------
       0010-INICIAR.
           CALL "PLTCODEMPP"           USING PA-CODEMP
           OPEN INPUT PLTFECHAS
           MOVE 11 TO CODSIS OF PLTFECHAS
           MOVE PA-CODEMP  TO CODEMP OF PLTFECHAS
           READ PLTFECHAS INVALID KEY
                CLOSE PLTFECHAS
                STOP RUN
           END-READ.
           MOVE ZEROS                     TO NUM-REG-OK
                ACUM-DB-OK                   ACUM-CR-OK
           MOVE ZEROS                     TO NUM-REG-ER
                ACUM-DB-ER                   ACUM-CR-ER
           MOVE PARAMETRO1                TO VAR-PARAMETRO
           OPEN  INPUT  CCACODTRN  PLTAGCORI PLTCANCIU
           OPEN I-O     CCAINTERF
           OPEN OUTPUT  CCAMOVRECI
           OPEN EXTEND  CCAMOVIM   CCAMOERR
           MOVE PARAMETRO1(64:10)         TO DISENO.
           MOVE "NO"                      TO CTL-CCAINTERF
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0050-LEER-CCAINTERF UNTIL FIN-CCAINTERF
                                       OR    BUEN-REGISTRO.
      *----------------------------------------------------------------
       0030-LEER-CCACODTRN.
           MOVE "NO"                      TO CTL-CCACODTRN.
           READ  CCACODTRN INVALID KEY
              MOVE "SI"                   TO CTL-CCACODTRN.
      *----------------------------------------------------------------
       0050-LEER-CCAINTERF.
           INITIALIZE REG-CCAMOERR.
           MOVE ZEROS                       TO CODER1   OF CCAMOERR
                                               CODER2   OF CCAMOERR
                                               CODER3   OF CCAMOERR
           MOVE "SI"                      TO CTL-REGISTRO
           READ  CCAINTERF   NEXT RECORD AT END
              MOVE "SI"                   TO CTL-CCAINTERF.
           IF NO-FIN-CCAINTERF
              IF ESTTRN  OF REG-CCAINTERF > 0
                 MOVE "NO"                TO CTL-REGISTRO
                 MOVE 99                  TO CODER1 OF CCAMOERR
                 PERFORM  0150-PROCESAR-ERROR.
      *----------------------------------------------------------------
       0100-PROCESAR.
           IF CODSIS OF CCAINTERF = 11
              AND ESTTRN OF CCAINTERF = ZEROS
              IF DISENO = "PLTTRNMONX"
                 MOVE CTANRO OF CCAINTERF TO CUENTA-COOMEVA
                 MOVE WS-CUENTA           TO CTANRO OF CCAINTERF
              END-IF
              MOVE CODMON OF CCAINTERF    TO CODMON OF CCACODTRN
              MOVE CODSIS OF CCAINTERF    TO CODSIS OF CCACODTRN
              MOVE CODPRO OF CCAINTERF    TO CODPRO OF CCACODTRN
              MOVE CODTRN OF CCAINTERF    TO CODTRN OF CCACODTRN
              PERFORM 0030-LEER-CCACODTRN
              IF NO-FIN-CCACODTRN
                 PERFORM  0110-PROCESAR-OK
              ELSE
               MOVE CODMON OF CCAINTERF   TO CODMON OF CCACODTRN
               MOVE CODSIS OF CCAINTERF   TO CODSIS OF CCACODTRN
               MOVE 1                     TO CODPRO OF CCACODTRN
               MOVE CODTRN OF CCAINTERF   TO CODTRN OF CCACODTRN
               PERFORM 0030-LEER-CCACODTRN
               IF NO-FIN-CCACODTRN
                 PERFORM  0110-PROCESAR-OK
               ELSE
VGQ             PERFORM ARREGLAR-RECHAZO
VGQ   *         MOVE 98                  TO CODER2 OF CCAMOERR
VGA   *         PERFORM  0150-PROCESAR-ERROR
               END-IF
              END-IF
           END-IF.
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0050-LEER-CCAINTERF UNTIL FIN-CCAINTERF
                                       OR    BUEN-REGISTRO.
      *----------------------------------------------------------------
       ARREGLAR-RECHAZO.
      * -----------------------------------------------
           IF CODPRO OF CCAINTERF = ZEROS
              MOVE 1 TO CODPRO OF CCAINTERF
           END-IF
           IF AGCDST OF CCAINTERF = ZEROS
              MOVE AGCORI OF CCAINTERF TO AGCDST OF CCAINTERF
           END-IF
           MOVE 999999          TO CTANRO OF CCAINTERF
           IF TIPMOV OF CCAINTERF = ZEROS
              MOVE 5               TO CODTRN OF CCAINTERF
           ELSE
              MOVE 8               TO CODTRN OF CCAINTERF
           END-IF.
           MOVE CODMON OF CCAINTERF    TO CODMON OF CCACODTRN
           MOVE CODSIS OF CCAINTERF    TO CODSIS OF CCACODTRN
           MOVE CODPRO OF CCAINTERF    TO CODPRO OF CCACODTRN
           MOVE CODTRN OF CCAINTERF    TO CODTRN OF CCACODTRN
           PERFORM 0030-LEER-CCACODTRN
           IF NO-FIN-CCACODTRN
              MOVE 98                  TO CODER2 OF CCAMOERR
              PERFORM  0150-PROCESAR-ERROR
           ELSE
              MOVE 999  TO CODOPE OF CCAINTERF
              PERFORM  0110-PROCESAR-OK
           END-IF.
      *----------------------------------------------------------------
       0110-PROCESAR-OK.
           PERFORM 0111-MOVER-DATOS
           IF CODOPE OF CCAINTERF = 999
              MOVE 98 TO CODER1 OF CCAMOVIM
           END-IF
           WRITE  REG-MOVIM
           ADD  1                           TO NUM-REG-OK
           IF TIPMOV  OF REG-CCAINTERF = 1
              ADD  VLRTRN  OF REG-CCAINTERF  TO ACUM-DB-OK
           ELSE
              ADD  VLRTRN  OF REG-CCAINTERF  TO ACUM-CR-OK.
           MOVE CORR REGMOVIM OF CCAMOVIM  TO REGMOVIM OF CCAMOVRECI.
           WRITE REG-MOVRECI.
      *----------------------------------------------------------------
       0111-MOVER-DATOS.
           INITIALIZE REGMOVIM OF CCAMOVIM.
           MOVE CORR REGTRNMON OF CCAINTERF TO REGMOVIM OF CCAMOVIM.
      * ------------
           MOVE ZEROS                  TO CODER1 OF CCAMOVIM
                                          CODER2 OF CCAMOVIM
                                          CODER3 OF CCAMOVIM
           MOVE FECEFE OF CCAINTERF    TO FVALOR OF CCAMOVIM
           MOVE FECPRO OF CCAINTERF    TO FORIGE OF CCAMOVIM
           MOVE TIPMOV OF CCAINTERF    TO DEBCRE OF CCAMOVIM
           MOVE VLRTRN OF CCAINTERF    TO IMPORT OF CCAMOVIM
           MOVE AGCDST OF CCAINTERF    TO AGCCTA OF CCAMOVIM
           MOVE MEDPAG OF CCAINTERF    TO TIPVAL OF CCAMOVIM
           IF DISENO = "PLTTRNMONX"
              PERFORM AJUSTES-PLTTRNMONX
           END-IF
           IF DISENO = "PLTTRNMON "
              PERFORM AJUSTES-PLTTRNMON
           END-IF
           ADD 1                        TO W-CNSTRN
           MOVE W-CNSTRN                TO CNSTRN OF CCAMOVIM.
      * ------------
VGQ        IF (INDRES OF REGCODTRN = 5 OR 6 OR 9)
VGQ           OR (AGCORI OF CCAMOVIM = 9)
VGQ230        OR (USRING OF CCAMOVIM = 'RECHAZO')
VGQ           MOVE 1 TO INDPAT OF CCAMOVIM
VGQ        ELSE
VGQ           MOVE 0 TO INDPAT OF CCAMOVIM
VGQ        END-IF
      * ------------
           MOVE CODTRA OF REGCODTRN   TO CODTRA OF CCAMOVIM.
           MOVE TIPVAL OF REGCODTRN   TO TIPVAL OF CCAMOVIM.
           MOVE AGCORI OF CCAMOVIM TO AGCORI OF PLTAGCORI
           MOVE PA-CODEMP          TO CODEMP OF PLTAGCORI
           PERFORM LEER-PLTAGCORI
           IF (NO-FIN-PLTAGCORI)
              MOVE CODSUC OF PLTAGCORI TO NROBNV OF CCAMOVIM.
      *--------------------------------------------------------------*
       AJUSTES-PLTTRNMONX.
           IF FECEFE OF CCAINTERF  NOT > FECPRO OF CCAINTERF
              MOVE 1                    TO FECVAL OF CCAMOVIM
            ELSE
               IF FECEFE OF CCAINTERF  = FECPRS OF PLTFECHAS
                  MOVE 2                TO FECVAL OF CCAMOVIM
               ELSE
               IF FECEFE OF CCAINTERF  = FECPSS OF PLTFECHAS
                  MOVE 3                TO FECVAL OF CCAMOVIM
               ELSE
                  MOVE 4                TO FECVAL OF CCAMOVIM
               END-IF
           END-IF.
      * --------------------------------------------------
       AJUSTES-PLTTRNMON.
           IF TIPMOV OF CCAINTERF = 2
              IF MEDPAG OF CCAINTERF = 2 OR 8
                 PERFORM BUSCAR-CANJE-ESPECIAL
                 MOVE FECPRO OF CCAINTERF TO LK219-FECHA1
VGQ   *          MOVE 3                   TO LK219-NRODIA
VGQ              IF (SI-EXISTE-PLTCANCIU)
VGQ                 AND NRODIA OF PLTCANCIU NOT = ZEROS
                    PERFORM VERIFICAR-CANJE-BANREPUBLICA
VGQ                 MOVE NRODIA OF PLTCANCIU TO LK219-NRODIA
VGQ              ELSE
VGQ                 MOVE FECVAL OF CCACODTRN TO LK219-NRODIA
VGQ              END-IF
                 MOVE 1                   TO INDCNJ OF CCAMOVIM
                 PERFORM CALL-PLT219
                 MOVE LK219-FECHA3      TO FVALOR OF CCAMOVIM
                 MOVE LK219-FECHA3      TO FECEFE OF CCAINTERF
HHD   *Para liberacion de canje - FECEFE = FECPRO
                 IF ( USRING OF CCAINTERF = "LIBCANJE" )
                    MOVE FECPRO OF CCAINTERF TO FVALOR OF CCAMOVIM
                                                FECEFE OF CCAINTERF
                 END-IF
      *
VGQ              MOVE 5                 TO LK219-NRODIA
VGQ              PERFORM CALL-PLT219
VGQ              MOVE LK219-FECHA3      TO W-FECHA-5
VGQ              MOVE 4                 TO LK219-NRODIA
VGQ              PERFORM CALL-PLT219
VGQ              MOVE LK219-FECHA3      TO W-FECHA-4
VGQ              MOVE 3                 TO LK219-NRODIA
VGQ              PERFORM CALL-PLT219
VGQ              MOVE LK219-FECHA3      TO W-FECHA-3
              ELSE
                 IF MEDPAG OF CCAINTERF = 23
                    MOVE 2                 TO INDCNJ OF CCAMOVIM
                    MOVE FECPRO OF CCAINTERF TO LK219-FECHA1
                    MOVE 45                  TO LK219-NRODIA
                    PERFORM CALL-PLT219
                    MOVE LK219-FECHA3      TO FVALOR OF CCAMOVIM
                    MOVE LK219-FECHA3      TO FECEFE OF CCAINTERF
                 END-IF
              END-IF
           END-IF
           IF FECEFE OF CCAINTERF NOT > FECPRO OF CCAINTERF
              MOVE 1                    TO FECVAL OF CCAMOVIM
           ELSE
              IF FECEFE OF CCAINTERF = FECPRS OF PLTFECHAS
                 MOVE 2                TO FECVAL OF CCAMOVIM
              ELSE
                 IF FECEFE OF CCAINTERF = FECPSS OF PLTFECHAS
                    MOVE 3                TO FECVAL OF CCAMOVIM
                 ELSE
                    IF FECEFE OF CCAINTERF = W-FECHA-3
                       MOVE 4                TO FECVAL OF CCAMOVIM
                    ELSE
                       IF FECEFE OF CCAINTERF = W-FECHA-4
                          MOVE 5                TO FECVAL OF CCAMOVIM
                       ELSE
                          MOVE 6                TO FECVAL OF CCAMOVIM
                       END-IF
                    END-IF
                 END-IF
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       BUSCAR-CANJE-ESPECIAL.
           MOVE AGCORI OF CCAMOVIM TO AGCORI OF PLTAGCORI
           MOVE PA-CODEMP          TO CODEMP OF PLTAGCORI
           MOVE ZEROS TO W-EXISTE-PLTCANCIU.
           PERFORM LEER-PLTAGCORI
           IF (NO-FIN-PLTAGCORI)
              MOVE CODCIU OF PLTAGCORI TO CODCIU OF PLTCANCIU
              MOVE CODMON OF CCAINTERF TO CODMON OF PLTCANCIU
              MOVE CODSIS OF CCAINTERF TO CODSIS OF PLTCANCIU
              MOVE CODPRO OF CCAINTERF TO CODPRO OF PLTCANCIU
              MOVE CODTRN OF CCAINTERF TO CODTRN OF PLTCANCIU
              PERFORM LEER-PLTCANCIU
              IF (NO-EXISTE-PLTCANCIU)
                 MOVE ZEROS TO CODTRN OF PLTCANCIU
                 PERFORM LEER-PLTCANCIU
                 IF (NO-EXISTE-PLTCANCIU)
                    MOVE ZEROS TO CODTRN OF PLTCANCIU
                    MOVE ZEROS TO CODPRO OF PLTCANCIU
                    PERFORM LEER-PLTCANCIU
                    IF (NO-EXISTE-PLTCANCIU)
                       MOVE ZEROS TO CODTRN OF PLTCANCIU
                       MOVE ZEROS TO CODPRO OF PLTCANCIU
                       MOVE ZEROS TO CODSIS OF PLTCANCIU
                       PERFORM LEER-PLTCANCIU
                    END-IF
                 END-IF
              END-IF
           ELSE
              MOVE ZEROS TO W-EXISTE-PLTCANCIU
           END-IF.
      *----------------------------------------------------------------
       VERIFICAR-CANJE-BANREPUBLICA.
           INITIALIZE PYC-INDCIE
           MOVE PA-CODEMP            TO PYC-CODEMP
           MOVE AGCORI OF CCAINTERF  TO PYC-AGCORI
           CALL "PLTPYC" USING PYC-CODEMP PYC-AGCORI PYC-INDCIE
           IF ( PYC-INDCIE = 1 AND DIS002 OF CCAINTERF = "ADICIONAL" )
             COMPUTE NRODIA OF PLTCANCIU = NRODIA OF PLTCANCIU
                                         + 1
           END-IF
           .
      *--------------------------------------------------------------*
       CALL-PLT219.
           MOVE ZEROS              TO LK219-FECHA2
           MOVE ZEROS              TO LK219-FECHA3
           MOVE 1                  TO LK219-TIPFMT
           MOVE 2                  TO LK219-BASCLC
           MOVE 1                  TO LK219-INDDSP
           MOVE 9                  TO LK219-DIASEM
           MOVE SPACES             TO LK219-NOMDIA
           MOVE SPACES             TO LK219-NOMMES
           MOVE ZEROS              TO LK219-CODRET
           MOVE SPACES             TO LK219-MSGERR
           MOVE 3                  TO LK219-TIPOPR
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
       0150-PROCESAR-ERROR.
           PERFORM  0160-ESCRIBIR-ERROR
           PERFORM  0170-BORRAR-REGISTRO.
      *----------------------------------------------------------------
       0160-ESCRIBIR-ERROR.
           MOVE CORR REGTRNMON OF CCAINTERF TO REGMOVIM OF CCAMOERR.
           MOVE AGCDST OF REGTRNMON         TO AGCCTA   OF CCAMOERR
           MOVE FECPRO OF REGTRNMON         TO FORIGE   OF CCAMOERR
           MOVE FECEFE OF REGTRNMON         TO FVALOR   OF CCAMOERR
           MOVE TIPMOV OF REGTRNMON         TO DEBCRE   OF CCAMOERR
           MOVE VLRTRN OF REGTRNMON         TO IMPORT   OF CCAMOERR
           MOVE MEDPAG OF REGTRNMON         TO TIPVAL   OF CCAMOERR
           IF FECEFE OF CCAINTERF  NOT > FECPRO OF CCAINTERF
              MOVE 1                    TO FECVAL OF CCAMOERR
            ELSE
               IF FECEFE OF CCAINTERF  = FECPRS OF PLTFECHAS
                  MOVE 2                TO FECVAL OF CCAMOERR
               ELSE
               IF FECEFE OF CCAINTERF  = FECPSS OF PLTFECHAS
                  MOVE 3                TO FECVAL OF CCAMOERR
               ELSE
                  MOVE 4                TO FECVAL OF CCAMOERR
               END-IF
           END-IF.
           ADD 1                        TO W-CNSTRN
           MOVE W-CNSTRN                TO CNSTRN OF CCAMOERR.
      * ------------
           MOVE CODTRN OF CCAINTERF   TO CODTRA OF CCAMOERR.
      *    MOVE TIPVAL OF REGCODTRN   TO TIPVAL OF CCAMOERR.
           WRITE  REG-CCAMOERR.
           IF ESTTRN  OF REG-CCAINTERF = 0
              ADD  1                        TO NUM-REG-ER
              IF TIPMOV  OF REG-CCAINTERF = 1
                 ADD VLRTRN OF REG-CCAINTERF TO ACUM-DB-ER
              ELSE
                 ADD VLRTRN OF REG-CCAINTERF TO ACUM-CR-ER.
           MOVE AGCORI OF REG-CCAINTERF TO AGCORI OF PLTAGCORI
           MOVE PA-CODEMP               TO CODEMP OF PLTAGCORI
           PERFORM LEER-PLTAGCORI
           IF (NO-FIN-PLTAGCORI)
              MOVE CODSUC OF PLTAGCORI TO NROBNV OF CCAMOERR.
           MOVE CORR REGMOVIM OF CCAMOERR TO REGMOVIM OF CCAMOVRECI.
           WRITE REG-MOVRECI.
      *----------------------------------------------------------------
       0170-BORRAR-REGISTRO.
           IF EN-BATCH
              DELETE  CCAINTERF.
      *----------------------------------------------------------------
       LEER-PLTAGCORI.
           MOVE "NO"                      TO CTL-PLTAGCORI.
           MOVE PA-CODEMP               TO CODEMP OF PLTAGCORI
           READ  PLTAGCORI INVALID KEY
              MOVE "SI"                   TO CTL-PLTAGCORI.
      *----------------------------------------------------------------
       LEER-PLTCANCIU.
           MOVE 1                       TO W-EXISTE-PLTCANCIU.
           MOVE PA-CODEMP               TO CODEMP OF PLTCANCIU
           READ  PLTCANCIU INVALID KEY
              MOVE ZEROS TO W-EXISTE-PLTCANCIU.
      *----------------------------------------------------------------
       9999-TERMINAR.
           MOVE VAR-PARAMETRO               TO PARAMETRO1
           CLOSE CCAINTERF CCAMOVIM CCAMOERR CCACODTRN PLTAGCORI
           CLOSE PLTFECHAS CCAMOVRECI PLTCANCIU.
           GOBACK.
      *----------------------------------------------------------------
