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
       PROGRAM-ID.    CCA565.
       AUTHOR.        VGQ.
       DATE-WRITTEN.  NOVIEMBRE/2000.
      *--------------------------------------------------------------*
      * FUNCION: CEREO DE REGISTROS MALOS EN CCAMOERR Y AIGNACION DE  *
      *          CUENTA DE RECHAZOS EN LOS REGISTROS ERRONEOS.       *
      *          GENERACION DE REPORTE DE MOVIMIENTOS RECHAZADOS.    *
      *--------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMOERR
               ASSIGN          TO DATABASE-CCAMOERR01
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCATABLAS
               ASSIGN          TO DATABASE-CCATABLAS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTSUCURS
               ASSIGN          TO DATABASE-PLTSUCURS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT REPORTE
               ASSIGN          TO FORMATFILE-CCA565R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOERR
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMOERR.
           COPY DDS-ALL-FORMATS OF CCAMOERR01.
      *
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACODTRN.
           COPY DDS-ALL-FORMATS OF CCACODTRN.
      *
       FD  CCATABLAS
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCATABLAS.
           COPY DDS-ALL-FORMATS OF CCATABLAS.
      *                                                                 IBM-CT
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *                                                                 IBM-CT
       FD  PLTSUCURS
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTSUCURS.
           COPY DDS-ALL-FORMATS OF PLTSUCURS.
      *                                                                 IBM-CT
       FD  REPORTE
           LABEL RECORDS ARE STANDARD.
       01  REPORTE-REG.
           COPY DDS-ALL-FORMATS OF CCA565R.
      *                                                                 IBM-CT
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
           COPY CATABLASR1 OF CCACPY.
      *                                                                 IBM-CT
       01  CONTROLES.
           05  CTL-CCAMOERR             PIC 9(01) VALUE 0.
               88  ERROR-CCAMOERR                 VALUE 1.
           05  CTL-CCACODTRN             PIC 9(01) VALUE 0.
               88  ERROR-CCACODTRN                 VALUE 1.
           05  CTL-CCATABLAS            PIC 9(01) VALUE 0.
               88  ERROR-CCATABLAS                VALUE 1.
           05  CTL-PLTAGCORI              PIC 9(01) VALUE 0.
               88  ERROR-PLTAGCORI                  VALUE 1.
           05  CTL-OK                  PIC 9(01) VALUE 0.
               88  ERROR-OK                      VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01) VALUE 0.
               88  FIN-PROGRAMA                  VALUE 1.
      *Variable para control acceso directo del Archivo CCACODTRN.
       01  W-EXISTE-CCACODTRN          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-CCACODTRN                    VALUE 0.
           88  SI-EXISTE-CCACODTRN                    VALUE 1.
      *--------------------------------------------------------------*
       01 W-EXISTE-PLTSUCURS           PIC 9 VALUE ZEROS.
          88 SI-EXISTE-PLTSUCURS       VALUE 0.
          88 NO-EXISTE-PLTSUCURS       VALUE 1.
      * -----------------------------------------
       01  W-CUENTA PIC 9(12) VALUE ZEROS.
       01  FILLER REDEFINES W-CUENTA.
           03 W-OFICTA PIC 9(04).
           03 W-NROCTA PIC 9(06).
           03 W-CODPRO PIC 99.
      *--------------------------------------------------------------*
       01 PAR-CODCPT       PIC 9(05) VALUE ZEROS.
       01 PAR-AGENCIA      PIC 9(05) VALUE ZEROS.
       01 PAR-CUENTA       PIC 9(17) VALUE ZEROS.
       01 PAR-AGENVA       PIC 9(05) VALUE ZEROS.
       01 PAR-CODRET       PIC 9(01) VALUE ZEROS.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  I                       PIC 9(05) VALUE ZEROS.
           05  W-HORA                  PIC 9(08) VALUE ZEROS.
           05  RED-W-HORA              REDEFINES W-HORA.
               10 HORA                 PIC 9(06).
               10 FILLER               PIC 9(02).
           05  W-USRID                 PIC X(10) VALUE SPACES.
           05  AGEANTE                 PIC 9(05) VALUE ZEROS.
           05  SUCANTE                 PIC 9(05) VALUE ZEROS.
           05  CODERR                  PIC 9(02) VALUE ZEROS.
           05  W-FECHA                 PIC 9(08) VALUE ZEROS.
           05  RED-W-FECHA             REDEFINES W-FECHA.
               10 SIGLO                PIC 9(02).
               10 ANO                  PIC 9(02).
               10 MES                  PIC 9(02).
               10 DIA                  PIC 9(02).
           05  W-PAGINA                PIC 9(06) VALUE ZEROS.
           05  W-AGENCIA               PIC 9(05) VALUE ZEROS.
           05  W-CODSUC                PIC 9(05) VALUE ZEROS.
           05  CTAESP                  PIC 9(17) VALUE ZEROS.
           05  W-AGCORI                PIC 9(05) VALUE ZEROS.
           05  RED-CTAESP              REDEFINES CTAESP.
               10 W-AGEESP             PIC 9(05).
               10 W-CTAESP             PIC 9(09).
           05  W-DCNVA                 PIC 9(01) VALUE ZEROS.
           05  W-FVNVA                 PIC 9(01) VALUE ZEROS.
           05  W-TVNVA                 PIC 9(01) VALUE ZEROS.
           05  W-FORNVA                PIC 9(08) VALUE ZEROS.
           05  W-FVALNVA               PIC 9(08) VALUE ZEROS.
           05  W-AORNVA                PIC 9(05) VALUE ZEROS.
           05  W-TOTDEB                PIC 9(15)V99 VALUE ZEROS.
           05  W-TOTCRE                PIC 9(15)V99 VALUE ZEROS.
           05  W-TOTTEB                PIC 9(15)V99 VALUE ZEROS.
           05  W-TOTTRE                PIC 9(15)V99 VALUE ZEROS.
      *--------------------------------------------------------------*
      * PARAMETROS RUTINA CALCULO FECHAS (PLT219).
      *--------------------------------------------------------------*
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
      *--------------------------------------------------------------*
      * PARAMETROS RUTINA CALCULO FECHA
      *--------------------------------------------------------------*
           05  W-F48                   PIC 9(08) VALUE ZEROS.
           05  W-F72                   PIC 9(08) VALUE ZEROS.
           05  W-CODRET                PIC 9(05) VALUE ZEROS.
           05  PAR-TIPRET              PIC 9(01)   VALUE ZEROS.
      *--------------------------------------------------------------*
      * TABLAS.
      *--------------------------------------------------------------*
       01  TABLA-CODIGOS               PIC X(9999) VALUE ZEROS.
       01  RED-TABLA-CODIGOS           REDEFINES   TABLA-CODIGOS.
           05 TABLA-COD                OCCURS     9999 TIMES.
              10 DECRE                 PIC 9(01).
              10 TIVAL                 PIC 9(01).
              10 FECVA                 PIC 9(01).
       01  TABLA-CODIGOS2              PIC X(9999)  VALUE ZEROS.
       01  RED-TABLA-CODIGOS2          REDEFINES   TABLA-CODIGOS2.
           05 TABLA-COD2               OCCURS     9999 TIMES.
              10 EXISTE                PIC 9(01).
       01  TABLA-CODIGOS3              PIC X(9999) VALUE ZEROS.
       01  RED-TABLA-CODIGOS3          REDEFINES    TABLA-CODIGOS3.
           05 TABLA-COD3               OCCURS      9999 TIMES.
              10 W-VALORDB             PIC 9(13)V99.
              10 W-VALORCR             PIC 9(13)V99.
      * -----------------------------------------
       01  W-OVRPRTF.
           03  FILLER                  PIC X(13)      VALUE
               "OVRPRTF FILE(".
           03  W-NOMARC1               PIC X(07).
           03  FILLER                  PIC X(09)      VALUE
               ") TOFILE(".
           03  W-NOMARC2               PIC X(07).
           03  FILLER                  PIC X(11)      VALUE
               ") SPLFNAME(".
           03  W-NOMSPL                PIC X(07).
           03  W-NOMCOR                PIC X(03).
           03  FILLER                  PIC X(01)      VALUE
               ")".
           03  FILLER                  PIC X(06)      VALUE
               " OUTQ(".
           03  W-NOMIMP                PIC X(10).
           03  FILLER REDEFINES W-NOMIMP.
               05 FIL-1                PIC X(03).
               05 IMP-SUC              PIC 9(03).
               05 FIL-2                PIC 9(02).
               05 FIL-3                PIC XX.
           03  FILLER                  PIC X(01)      VALUE
               ")".
           03  FILLER                  PIC X(11)      VALUE
               " HOLD(*YES)".
       01  W-DLTOVR-PRT.
           03  FILLER                  PIC X(12)      VALUE
               "DLTOVR FILE(".
           03  W-NOMARC5               PIC X(07).
           03  FILLER                  PIC X(01)      VALUE
               ")".
       01  W-LNGCMD                    PIC S9(10)V9(05) COMP-3.
      *--------------------------------------------------------------*
           COPY PARGEN OF CCACPY.
           COPY FECHAS OF CCACPY.
       01  W-CONTL                     PIC 9(3).
       01  PA-CODEMP                   PIC 9(5) VALUE 0.
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       77  W-USR                       PIC X(10).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING W-USR.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN INPUT  CCAMOERR
                       CCACODTRN
                       CCATABLAS.
           OPEN INPUT  PLTAGCORI PLTSUCURS.
           OPEN OUTPUT REPORTE.
           MOVE W-USR TO W-USRID
           CALL "PLTCODEMPP"         USING PA-CODEMP
           CALL "CCA501" USING LK-CCAPARGEN.
           ACCEPT W-FECHA FROM DATE
           ACCEPT LK-FECHA-HOY FROM DATE
           IF ANO < 50 THEN
              MOVE 20 TO SIGLO
           ELSE
              MOVE 19 TO SIGLO.
           ACCEPT W-HORA  FROM TIME
           MOVE 1 TO CTL-OK
           MOVE ZEROS TO CTL-CCAMOERR
                         AGEANTE
           MOVE ZEROS TO CODMON OF CCAMOERR
                         CODSIS OF CCAMOERR
                         CODPRO OF CCAMOERR
                         AGCCTA OF CCAMOERR
                         CTANRO OF CCAMOERR
                         FORIGE OF CCAMOERR
                         DEBCRE OF CCAMOERR
                         CODTRA OF CCAMOERR
                         NROBNV OF CCAMOERR
                         IMPORT OF CCAMOERR.
           PERFORM CARGAR-FECHAS
           START CCAMOERR KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE 1     TO CTL-CCAMOERR.
           IF ERROR-CCAMOERR THEN
              PERFORM TERMINAR
           END-IF.
           PERFORM LEER-CCAMOERR UNTIL ERROR-CCAMOERR OR NOT ERROR-OK
           IF ERROR-CCAMOERR THEN
              MOVE 1 TO CTL-PROGRAMA
              MOVE LK-TRA004 TO NROBNV OF CCAMOERR
      *       PERFORM ABRIR-IMPRESION
      *       PERFORM IMPRIMIR-TITULOS
              WRITE REPORTE-REG FORMAT IS "FOOTER"
      *       PERFORM CERRAR-IMPRESION
           ELSE
              MOVE 1 TO I
              PERFORM INIC-TABLA     UNTIL I > 9999
              MOVE 1 TO I
              PERFORM INIC-TABLA-2   UNTIL I > 9999
              MOVE 1 TO I
              PERFORM INIC-TABLA-3   UNTIL I > 9999
              PERFORM CARGAR-TABLA   UNTIL ERROR-CCACODTRN
              PERFORM CARGAR-TABLA-2 UNTIL ERROR-PLTAGCORI
      *       PERFORM ABRIR-IMPRESION
              MOVE AGCCTA OF CCAMOERR TO W-AGENCIA
              PERFORM IMPRIMIR-TITULOS.
      *----------------------------------------------------------------
       ABRIR-IMPRESION.
           MOVE NROBNV OF CCAMOERR TO CODSUC OF PLTSUCURS.
           MOVE NROBNV OF CCAMOERR TO W-CODSUC SUCANTE.
           MOVE ZEROS TO W-EXISTE-PLTSUCURS
           MOVE PA-CODEMP          TO CODEMP OF PLTSUCURS
           READ PLTSUCURS INVALID KEY
                MOVE 1 TO W-EXISTE-PLTSUCURS
           END-READ.
           IF (SI-EXISTE-PLTSUCURS)
              MOVE "CCA565R"          TO W-NOMARC1
              MOVE "CCA565R"          TO W-NOMARC2
              MOVE "CCA565R"          TO W-NOMARC5
              MOVE "CCARECH"          TO W-NOMSPL
              MOVE 86                 TO W-LNGCMD
              MOVE NOMCOR OF REGSUCURS TO W-NOMCOR
              MOVE NOMIMP OF REGSUCURS TO W-NOMIMP
              CALL "QCMDEXC"          USING W-OVRPRTF , W-LNGCMD
              OPEN OUTPUT REPORTE
           END-IF.
      *--------------------------------------------------------------*
       CERRAR-IMPRESION.
           MOVE 20                 TO W-LNGCMD
           CLOSE REPORTE
           CALL "QCMDEXC"          USING W-DLTOVR-PRT , W-LNGCMD.
      *--------------------------------------------------------------*
       PROCESAR.
           PERFORM VALIDAR-AGENCIA
           IF W-AGENCIA NOT = AGEANTE
                PERFORM ASIGNAR-CTA-RECHAZOS
                PERFORM IMPRIMIR-TOT-CTA
                PERFORM IMPRIMIR-AGENCIA
                MOVE W-AGENCIA TO AGEANTE.
           IF W-CONTL > 60
                PERFORM IMPRIMIR-TITULOS
           END-IF
           PERFORM VALIDAR-REG
           MOVE 1 TO CTL-OK
           PERFORM LEER-CCAMOERR UNTIL ERROR-CCAMOERR OR NOT ERROR-OK
           IF ERROR-CCAMOERR THEN
              PERFORM IMPRIMIR-TOT-CTA
              WRITE REPORTE-REG FORMAT IS "FOOTER"
      *       PERFORM CERRAR-IMPRESION
              MOVE LK-TRA004 TO NROBNV OF CCAMOERR
      *       PERFORM ABRIR-IMPRESION
              PERFORM COLOCAR-TOTALES-GLOBALES
              WRITE REPORTE-REG FORMAT IS "FOOTER"
      *       PERFORM CERRAR-IMPRESION
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       ASIGNAR-CTA-RECHAZOS.
           MOVE 1              TO PAR-CODCPT
           MOVE W-AGENCIA      TO PAR-AGENCIA
           MOVE ZEROS          TO PAR-CUENTA  PAR-AGENVA
                                  PAR-CODRET
           CALL "CCA990" USING PAR-CODCPT
                               PAR-AGENCIA
                               PAR-CUENTA
                               PAR-AGENVA
                               PAR-CODRET
           END-CALL.
      *--------------------------------------------------------------*
       VALIDAR-REG.
           INITIALIZE DETALLE-O
           PERFORM IMPRIMIR-PARTE-ANT
           PERFORM ANALIZAR-ERRORES
           IF DEBCRE OF CCAMOERR  = 1 THEN
              ADD IMPORT OF CCAMOERR TO W-TOTDEB
                                        W-VALORDB(W-AGENCIA)
           ELSE
              ADD IMPORT OF CCAMOERR TO W-TOTCRE
                                        W-VALORCR(W-AGENCIA).
           WRITE REPORTE-REG FORMAT IS "DETALLE"
           INITIALIZE CODER1 OF CCAMOERR
                      CODER2 OF CCAMOERR
                      CODER3 OF CCAMOERR.
      *--------------------------------------------------------------*
       IMPRIMIR-PARTE-ANT.
           MOVE AGCCTA OF CCAMOERR TO W-OFICTA
           MOVE CTANRO OF CCAMOERR TO W-NROCTA
           MOVE CODPRO OF CCAMOERR TO W-CODPRO
           MOVE W-CUENTA           TO CTAANT  OF REPORTE-REG
           MOVE CODTRA OF CCAMOERR TO CODANT  OF REPORTE-REG
                                      CODTRA  OF REGCODTRN
           PERFORM LEER-CCACODTRN
           IF ( NO-EXISTE-CCACODTRN )
              MOVE "Transacción no definida "
                                   TO NOMTRN  OF REPORTE-REG
           ELSE
              MOVE NOLTRA OF REGCODTRN
                                   TO NOMTRN  OF REPORTE-REG
           END-IF
           MOVE NROREF OF CCAMOERR TO REFANT  OF REPORTE-REG
           MOVE IMPORT OF CCAMOERR TO IMPANT  OF REPORTE-REG
           MOVE DEBCRE OF CCAMOERR TO DCANT   OF REPORTE-REG
           MOVE FECVAL OF CCAMOERR TO FVANT   OF REPORTE-REG
           MOVE TIPVAL OF CCAMOERR TO TVANT   OF REPORTE-REG
           MOVE FORIGE OF CCAMOERR TO FORANT  OF REPORTE-REG
           MOVE FVALOR OF CCAMOERR TO FVALANT OF REPORTE-REG
           MOVE AGCORI OF CCAMOERR TO AORANT  OF REPORTE-REG
           MOVE CODCAJ OF CCAMOERR TO USRANT  OF REPORTE-REG
           MOVE INFDEP OF CCAMOERR TO NOMCTA  OF REPORTE-REG.
           ADD   1    TO W-CONTL.
      *--------------------------------------------------------------*
       ANALIZAR-ERRORES.
           IF CODER1 OF CCAMOERR NOT = ZEROS THEN
              MOVE CODER1 OF CCAMOERR TO CODERR
              PERFORM ASIGNAR-CODIGO-ERROR.
           IF CODER2 OF CCAMOERR NOT = ZEROS THEN
              MOVE CODER2 OF CCAMOERR TO CODERR
              PERFORM ASIGNAR-CODIGO-ERROR.
           IF CODER3 OF CCAMOERR NOT = ZEROS THEN
              MOVE CODER3 OF CCAMOERR TO CODERR
              PERFORM ASIGNAR-CODIGO-ERROR.
      *--------------------------------------------------------------*
       LEER-CCAMOERR.
           MOVE 0 TO CTL-CCAMOERR
           READ CCAMOERR NEXT RECORD AT END MOVE 1 TO CTL-CCAMOERR.
           IF NOT ERROR-CCAMOERR THEN
      *       IF CODER1 OF CCAMOERR NOT = ZEROS OR
      *          CODER2 OF CCAMOERR NOT = ZEROS OR
      *          CODER3 OF CCAMOERR NOT = ZEROS THEN
                 MOVE 0 TO CTL-OK.
      *--------------------------------------------------------------*
       CALCULAR-FECHA.
              MOVE FORIGE OF CCAMOERR TO LK219-FECHA1
              MOVE ZEROS              TO LK219-FECHA2
              MOVE ZEROS              TO LK219-FECHA3
              MOVE 1                  TO LK219-TIPFMT
              MOVE 2                  TO LK219-BASCLC
              MOVE FECVAL OF CCAMOERR TO LK219-NRODIA
              MOVE 1                  TO LK219-INDDSP
              MOVE 9                  TO LK219-DIASEM
              MOVE SPACES             TO LK219-NOMDIA
              MOVE SPACES             TO LK219-NOMMES
              MOVE ZEROS              TO LK219-CODRET
              MOVE SPACES             TO LK219-MSGERR
              MOVE 3                  TO LK219-TIPOPR
              PERFORM CALL-PLT219.
      *--------------------------------------------------------------*
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
      *--------------------------------------------------------------*
       CARGAR-FECHAS.
           CALL "CCA500" USING LK-FECHAS                                A
      *
      *SE AVERIGUA FECHA A 48 HORAS
      *
           MOVE LK-FECHA-HOY    TO LK219-FECHA1
           MOVE LK-FECHA-PASMAN TO W-F48
           MOVE ZEROS    TO LK219-FECHA2
           MOVE ZEROS    TO LK219-FECHA3
           MOVE 1        TO LK219-TIPFMT
           MOVE 2        TO LK219-BASCLC
           MOVE 3        TO LK219-NRODIA
           MOVE 1        TO LK219-INDDSP
           MOVE 9        TO LK219-DIASEM
           MOVE SPACES   TO LK219-NOMDIA
           MOVE SPACES   TO LK219-NOMMES
           MOVE ZEROS    TO LK219-CODRET
           MOVE SPACES   TO LK219-MSGERR
           MOVE 3        TO LK219-TIPOPR
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO W-F72.
      *--------------------------------------------------------------*
       INIC-TABLA.
           INITIALIZE DECRE(I)
                      TIVAL(I)
                      FECVA(I)
           ADD 1 TO I.
      *--------------------------------------------------------------*
       INIC-TABLA-2.
           INITIALIZE EXISTE(I)
           ADD 1 TO I.
      *--------------------------------------------------------------*
       INIC-TABLA-3.
           INITIALIZE W-VALORDB(I)
                      W-VALORCR(I)
           ADD 1 TO I.
      *--------------------------------------------------------------*
       CARGAR-TABLA.
           MOVE 0 TO CTL-CCACODTRN
           READ CCACODTRN NEXT RECORD AT END MOVE 1 TO CTL-CCACODTRN.
           IF NOT ERROR-CCACODTRN THEN
              MOVE DEBCRE OF REGCODTRN TO DECRE(CODTRA OF REGCODTRN)
              MOVE TIPVAL OF REGCODTRN TO TIVAL(CODTRA OF REGCODTRN)
              MOVE FECVAL OF REGCODTRN TO FECVA(CODTRA OF REGCODTRN).
      *--------------------------------------------------------------*
       CARGAR-TABLA-2.
           MOVE 0 TO CTL-PLTAGCORI
           MOVE PA-CODEMP      TO CODEMP OF PLTAGCORI
           READ PLTAGCORI NEXT RECORD AT END MOVE 1 TO CTL-PLTAGCORI.
           IF PA-CODEMP NOT = CODEMP OF PLTAGCORI
              MOVE 1 TO CTL-PLTAGCORI
           END-IF.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE 1 TO EXISTE(AGCORI OF PLTAGCORI)
           END-IF.
      *--------------------------------------------------------------*
       IMPRIMIR-TITULOS.
           INITIALIZE HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA565    "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "*** MOVIMIENTOS ASIGNADOS A CUENTAS DE RECHAZO ***"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
           MOVE HORA              TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER"
           PERFORM IMPRIMIR-AGENCIA
           WRITE REPORTE-REG FORMAT IS "TITREC"
           WRITE REPORTE-REG FORMAT IS "TITULOS".
           MOVE 5       TO W-CONTL.
      *--------------------------------------------------------------*
       IMPRIMIR-AGENCIA.
           INITIALIZE AGENCIA-O
           PERFORM TRAER-AGENCIA
           WRITE REPORTE-REG FORMAT IS "AGENCIA"
           ADD  3       TO W-CONTL.
      *--------------------------------------------------------------*
       TRAER-AGENCIA.
           MOVE 0 TO CTL-PLTAGCORI
           MOVE PA-CODEMP TO CODEMP OF PLTAGCORI
           MOVE W-AGENCIA TO AGCORI OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE W-AGENCIA             TO AGEN  OF REPORTE-REG
              MOVE NOMAGC OF PLTAGCORI   TO DEAGE OF REPORTE-REG
           ELSE
              MOVE W-AGENCIA             TO AGEN  OF REPORTE-REG
              MOVE "Agencia Inexistente" TO DEAGE OF REPORTE-REG.
      *--------------------------------------------------------------*
       IMPRIMIR-TOT-CTA.
           IF W-TOTDEB NOT = ZEROS OR
              W-TOTCRE NOT = ZEROS THEN
                MOVE W-TOTDEB TO TOTDB OF REPORTE-REG
                MOVE W-TOTCRE TO TOTCR OF REPORTE-REG
                WRITE REPORTE-REG FORMAT IS "TOTDEB"
                INITIALIZE W-TOTDEB W-TOTCRE
                WRITE REPORTE-REG FORMAT IS "FIRMA"
                ADD 4      TO W-CONTL.
      *--------------------------------------------------------------*
       VALIDAR-AGENCIA.
           IF AGCCTA OF CCAMOERR NOT > 9999 THEN
              IF EXISTE(AGCCTA OF CCAMOERR) NOT = 1 THEN
                 MOVE 9000               TO W-AGENCIA
                 MOVE 9000               TO W-CODSUC
              ELSE
                 MOVE AGCCTA OF CCAMOERR TO W-AGENCIA
                 MOVE NROBNV OF CCAMOERR TO W-CODSUC
           ELSE
              MOVE 9000                  TO W-CODSUC
              MOVE 9000                  TO W-AGENCIA.
      *--------------------------------------------------------------*
       ASIGNAR-CODIGO-ERROR.
           MOVE 0      TO CTL-CCATABLAS
           MOVE 1      TO CODTAB OF REGTABLAS
           MOVE CODERR TO NROTAB OF REGTABLAS
           READ CCATABLAS INVALID KEY MOVE 1 TO CTL-CCATABLAS.
           IF NOT ERROR-CCATABLAS THEN
              MOVE CAMPO2 OF REGTABLAS TO RESTO
              IF CODER1 OF CCAMOERR = CODERR THEN
                 MOVE W-DESCER TO ERRO1 OF REPORTE-REG
              ELSE
              IF CODER2 OF CCAMOERR = CODERR THEN
                 MOVE W-DESCER TO ERRO2 OF REPORTE-REG
              ELSE
              IF CODER3 OF CCAMOERR = CODERR THEN
                 MOVE W-DESCER TO ERRO3 OF REPORTE-REG
              ELSE
                 MOVE "*ER*"   TO ERRO1 OF REPORTE-REG
                                  ERRO2 OF REPORTE-REG
                                  ERRO3 OF REPORTE-REG
           ELSE
              MOVE "****"   TO ERRO1 OF REPORTE-REG
                               ERRO2 OF REPORTE-REG
                               ERRO3 OF REPORTE-REG
              INITIALIZE RESTO.
      *--------------------------------------------------------------*
       COLOCAR-TOTALES-GLOBALES.
           PERFORM IMP-TIT-I
           MOVE 1 TO I
           PERFORM RECORRER-TABLA UNTIL I > 9999.
           MOVE W-TOTTEB TO TOTOTDB OF REPORTE-REG
           MOVE W-TOTTRE TO TOTOTCR OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "TOTTOT".
      *--------------------------------------------------------------*
       RECORRER-TABLA.
           IF W-VALORDB(I) NOT = ZEROS OR
              W-VALORCR(I) NOT = ZEROS THEN
              MOVE W-VALORDB(I) TO TTOTDB  OF REPORTE-REG
              ADD  W-VALORDB(I) TO W-TOTTEB
              MOVE W-VALORCR(I) TO TTOTCR  OF REPORTE-REG
              ADD  W-VALORCR(I) TO W-TOTTRE
              MOVE I            TO TCODAGE OF REPORTE-REG
              PERFORM NOMBRE-AGENCIA
              WRITE REPORTE-REG FORMAT IS "DETTOT".
           ADD 1 TO I.
      *--------------------------------------------------------------*
       NOMBRE-AGENCIA.
           MOVE 0 TO CTL-PLTAGCORI
           MOVE PA-CODEMP TO CODEMP OF PLTAGCORI
           MOVE I TO AGCORI OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF PLTAGCORI     TO TDESAGE OF REPORTE-REG
           ELSE
              MOVE "AGENCIA INEXISTENTE" TO TDESAGE OF REPORTE-REG.
      *--------------------------------------------------------------*
       IMP-TIT-I.
           INITIALIZE HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA565    "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "***  TOTALES PARA LOS MOVIMIENTOS RECHAZADOS   ***"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
           MOVE W-HORA            TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER".
           WRITE REPORTE-REG FORMAT IS "TITADI".
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Ccacodtrn.                                  |
      * Descripcion   : Se lee un Código de transacción.              |
      *----------------------------------------------------------------
      *
       LEER-CCACODTRN.
           MOVE 1                      TO W-EXISTE-CCACODTRN
           READ CCACODTRN              INVALID KEY
                                       MOVE 0 TO W-EXISTE-CCACODTRN
           END-READ.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE CCAMOERR      PLTSUCURS
                 CCACODTRN     REPORTE
                 CCATABLAS
                 PLTAGCORI.
           STOP RUN.
