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
       PROGRAM-ID.    CCA560.
       AUTHOR.        VGQ.
       DATE-WRITTEN.  NOVIEMBRE/2000.
      *--------------------------------------------------------------*
      * FUNCION: CEREO DE REGISTROS MALOS EN CCAMOVIM Y AIGNACION DE  *
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
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM03
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT CCAMOVIMR
               ASSIGN          TO DATABASE-CCAMOVIMR
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT PLTPARGEN
               ASSIGN          TO DATABASE-PLTPARGEN
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAMOVTMP
               ASSIGN          TO DATABASE-CCAMOVTMP
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
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
               ASSIGN          TO FORMATFILE-CCA560R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVIM03.
      *                                                                 IBM-CT
       FD  PLTPARGEN
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTPARGEN.
           COPY DDS-ALL-FORMATS OF PLTPARGEN.
      *
       FD  CCAMOVIMR
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMOVIMR.
           COPY DDS-ALL-FORMATS OF CCAMOVIMR.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *
       FD  CCAMOVTMP
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMOVTMP.
           COPY DDS-ALL-FORMATS OF CCAMOVTMP.
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
           COPY DDS-ALL-FORMATS OF CCA560R.
      *                                                                 IBM-CT
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
           COPY CATABLASR1 OF CCACPY.
      *                                                                 IBM-CT
       01  CONTROLES.
           05  CTL-CCAMOVIM             PIC 9(01) VALUE 0.
               88  ERROR-CCAMOVIM                 VALUE 1.
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
       01 W-EXISTE-CCAMAEAHO PIC 9 VALUE ZEROS.
          88 SI-EXISTE-CCAMAEAHO VALUE 1.
          88 NO-EXISTE-CCAMAEAHO VALUE 0.
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
      *    05  W-RECHAZOX              PIC 9(17) VALUE ZEROS.
      *    05  RED-W-RECHAZOX          REDEFINES W-RECHAZOX.
      *        10 W-NROAGE             PIC 9(05).
      *        10 W-NROCTA             PIC 9(10).
      *    05  W-RECHAZO               PIC 9(15) VALUE ZEROS.
      *    05  RED-W-RECHAZO           REDEFINES W-RECHAZO.
      *        10 W-CUENTA             PIC 9(14).
      *        10 W-DIGCHQ             PIC 9(01).
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
           05  W-F96                   PIC 9(08) VALUE ZEROS.
           05  W-F120                  PIC 9(08) VALUE ZEROS.
           05  W-CODRET                PIC 9(05) VALUE ZEROS.
           05  PAR-TIPRET              PIC 9(01)   VALUE ZEROS.
      *--------------------------------------------------------------*
      * TABLAS.
      *--------------------------------------------------------------*
       01  TABLA-CODIGOS               PIC X(9999) VALUE ZEROS.
       01  RED-TABLA-CODIGOS           REDEFINES   TABLA-CODIGOS.
           05 TABLA-COD                OCCURS      9999 TIMES.
              10 DECRE                 PIC 9(01).
              10 TIVAL                 PIC 9(01).
              10 FECVA                 PIC 9(01).
       01  TABLA-CODIGOS2              PIC X(9999)  VALUE ZEROS.
       01  RED-TABLA-CODIGOS2          REDEFINES   TABLA-CODIGOS2.
           05 TABLA-COD2               OCCURS      9999 TIMES.
              10 EXISTE                PIC 9(01).
       01  TABLA-CODIGOS3              PIC X(9999) VALUE ZEROS.
       01  RED-TABLA-CODIGOS3          REDEFINES    TABLA-CODIGOS3.
           05 TABLA-COD3               OCCURS       9999 TIMES.
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
       01  PA-CODEMP                   PIC 9(05)   VALUE 0.
      *--------------------------------------------------------------*
           COPY PARGEN OF CCACPY.
           COPY FECHAS OF CCACPY.
           COPY CATABPRO OF CCACPY.
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
           OPEN OUTPUT CCAMOVTMP REPORTE
           OPEN I-O    CCAMOVIM  CCAMAEAHO
                       CCACODTRN
                       CCATABLAS.
           OPEN INPUT  PLTAGCORI PLTSUCURS PLTPARGEN.
           OPEN EXTEND CCAMOVIMR.
           CALL "PLTCODEMPP"        USING PA-CODEMP
           PERFORM LEER-PLTPARGEN
           MOVE W-USR TO W-USRID
           CALL "CCA501" USING LK-CCAPARGEN.
           ACCEPT W-FECHA FROM DATE
           IF ANO < 50 THEN
              MOVE 20 TO SIGLO
           ELSE
              MOVE 19 TO SIGLO.
           ACCEPT W-HORA  FROM TIME
           MOVE 1 TO CTL-OK
           MOVE ZEROS TO CTL-CCAMOVIM.
           MOVE ZEROS TO CODMON OF CCAMOVIM
                         CODSIS OF CCAMOVIM
                         CODPRO OF CCAMOVIM
                         AGCCTA OF CCAMOVIM
                         CTANRO OF CCAMOVIM
                         FORIGE OF CCAMOVIM
                         DEBCRE OF CCAMOVIM
                         CODTRA OF CCAMOVIM
                         NROBNV OF CCAMOVIM
                         IMPORT OF CCAMOVIM.
           PERFORM CARGAR-FECHAS
           START CCAMOVIM KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE 1     TO CTL-CCAMOVIM.
           IF ERROR-CCAMOVIM THEN
              PERFORM TERMINAR
           END-IF.
           PERFORM LEER-CCAMOVIM UNTIL ERROR-CCAMOVIM OR NOT ERROR-OK
           IF ERROR-CCAMOVIM THEN
              MOVE 1 TO CTL-PROGRAMA
              MOVE LK-TRA004 TO NROBNV OF CCAMOVIM
      *       PERFORM ABRIR-IMPRESION
              PERFORM IMPRIMIR-TITULOS
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
              PERFORM CARGAR-TABLA-2 UNTIL ERROR-PLTAGCORI.
      *       PERFORM ABRIR-IMPRESION.
      *----------------------------------------------------------------
       ABRIR-IMPRESION.
           MOVE PA-CODEMP          TO CODEMP OF PLTSUCURS
           MOVE NROBNV OF CCAMOVIM TO CODSUC OF PLTSUCURS.
           MOVE NROBNV OF CCAMOVIM TO W-CODSUC SUCANTE.
           MOVE ZEROS TO W-EXISTE-PLTSUCURS
           READ PLTSUCURS INVALID KEY
                MOVE 1 TO W-EXISTE-PLTSUCURS
           END-READ.
           IF (SI-EXISTE-PLTSUCURS)
              MOVE "CCA560R"          TO W-NOMARC1
              MOVE "CCA560R"          TO W-NOMARC2
              MOVE "CCA560R"          TO W-NOMARC5
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
VG    *    IF W-CODSUC  NOT = SUCANTE OR
           IF W-AGENCIA NOT = AGEANTE
                PERFORM ASIGNAR-CTA-RECHAZOS
                PERFORM IMPRIMIR-TOT-CTA
VG    *         IF W-CODSUC NOT = SUCANTE
                   WRITE REPORTE-REG FORMAT IS "FOOTER"
      *            PERFORM CERRAR-IMPRESION
      *            PERFORM ABRIR-IMPRESION
VG    *         END-IF
                PERFORM IMPRIMIR-TITULOS
                MOVE W-CODSUC  TO SUCANTE
                MOVE W-AGENCIA TO AGEANTE.
           PERFORM VALIDAR-REG
           MOVE 1 TO CTL-OK
           PERFORM LEER-CCAMOVIM UNTIL ERROR-CCAMOVIM OR NOT ERROR-OK
           IF ERROR-CCAMOVIM THEN
              PERFORM IMPRIMIR-TOT-CTA
              WRITE REPORTE-REG FORMAT IS "FOOTER"
      *       PERFORM CERRAR-IMPRESION
              MOVE LK-TRA004 TO NROBNV OF CCAMOVIM
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
           INITIALIZE REGMOVIMR.
           PERFORM IMPRIMIR-PARTE-ANT
           PERFORM IMPRIMIR-PARTE-NVA
           PERFORM ANALIZAR-ERRORES
           WRITE ZONA-CCAMOVIMR.
           IF DEBCRE OF CCAMOVIM  = 1 THEN
              ADD IMPORT OF CCAMOVIM TO W-TOTDEB
                                        W-VALORDB(W-AGENCIA)
           ELSE
              ADD IMPORT OF CCAMOVIM TO W-TOTCRE
                                        W-VALORCR(W-AGENCIA).
           WRITE REPORTE-REG FORMAT IS "DETALLE"
           INITIALIZE CODER1 OF CCAMOVIM
                      CODER2 OF CCAMOVIM
                      CODER3 OF CCAMOVIM
           PERFORM REGRABAR.
      *--------------------------------------------------------------*
       IMPRIMIR-PARTE-ANT.
           MOVE AGCCTA OF CCAMOVIM TO W-OFICTA
           MOVE CTANRO OF CCAMOVIM TO W-NROCTA
           MOVE CODPRO OF CCAMOVIM TO W-CODPRO
           MOVE W-CUENTA           TO CTAANT  OF REPORTE-REG
           MOVE CODTRA OF CCAMOVIM TO CODANT  OF REPORTE-REG
           MOVE NROREF OF CCAMOVIM TO REFANT  OF REPORTE-REG
           MOVE IMPORT OF CCAMOVIM TO IMPANT  OF REPORTE-REG
           MOVE DEBCRE OF CCAMOVIM TO DCANT   OF REPORTE-REG
           MOVE FECVAL OF CCAMOVIM TO FVANT   OF REPORTE-REG
           MOVE TIPVAL OF CCAMOVIM TO TVANT   OF REPORTE-REG
           MOVE FORIGE OF CCAMOVIM TO FORANT  OF REPORTE-REG
           MOVE FVALOR OF CCAMOVIM TO FVALANT OF REPORTE-REG
           MOVE AGCORI OF CCAMOVIM TO AORANT  OF REPORTE-REG
           MOVE CODCAJ OF CCAMOVIM TO USRANT  OF REPORTE-REG
           MOVE "*"                TO SEPAR   OF REPORTE-REG.
           PERFORM MOVER-A-RECHAZO.
      * --------------------------------------------
       MOVER-A-RECHAZO.
VG         MOVE CORR REGMOVIM OF CCAMOVIM TO REGMOVIMR OF CCAMOVIMR.
VG         MOVE CODMON OF CCAMOVIM TO RODMON OF REGMOVIMR.
VG         MOVE CODSIS OF CCAMOVIM TO RODSIS OF REGMOVIMR.
VG         MOVE CODPRO OF CCAMOVIM TO RODPRO OF REGMOVIMR.
VG         MOVE ZEROS              TO NODMON OF REGMOVIMR
VG                                    NODSIS OF REGMOVIMR
VG                                    NODPRO OF REGMOVIMR
VG                                    NGCCTA OF REGMOVIMR
VG                                    NTANRO OF REGMOVIMR
VG                                    NODTRA OF REGMOVIMR
VG                                    ESTADO OF REGMOVIMR.
      *--------------------------------------------------------------*
       IMPRIMIR-PARTE-NVA.
           MOVE W-AGENCIA          TO AGENVA  OF REPORTE-REG
           MOVE AGCCTA OF CCAMOVIM TO W-OFICTA
           MOVE CTANRO OF CCAMOVIM TO W-NROCTA
           MOVE CODPRO OF CCAMOVIM TO W-CODPRO
           MOVE W-CUENTA           TO CTAANT  OF REPORTE-REG
      *    MOVE CTANRO OF CCAMOVIM TO CTANVA  OF REPORTE-REG
      *    MOVE CODTRA OF CCAMOVIM TO CODNVA  OF REPORTE-REG
      *    MOVE IMPORT OF CCAMOVIM TO IMPNVA  OF REPORTE-REG
      *    MOVE DEBCRE OF CCAMOVIM TO DCNVA   OF REPORTE-REG
      *                               W-DCNVA
      *    MOVE FECVAL OF CCAMOVIM TO FVNVA   OF REPORTE-REG
      *                               W-FVNVA
      *    MOVE TIPVAL OF CCAMOVIM TO TVNVA   OF REPORTE-REG
      *                               W-TVNVA
           MOVE FORIGE OF CCAMOVIM TO FORNVA  OF REPORTE-REG
                                      W-FORNVA
           MOVE FVALOR OF CCAMOVIM TO FVALNVA OF REPORTE-REG
                                      W-FVALNVA.
      *    MOVE AGCORI OF CCAMOVIM TO AORNVA  OF REPORTE-REG
      *                               W-AORNVA.
      *--------------------------------------------------------------*
       ANALIZAR-ERRORES.
           IF CODER1 OF CCAMOVIM NOT = ZEROS THEN
              MOVE CODER1 OF CCAMOVIM TO CODERR
              PERFORM ASIGNAR-CODIGO-ERROR.
           IF CODER2 OF CCAMOVIM NOT = ZEROS THEN
              MOVE CODER2 OF CCAMOVIM TO CODERR
              PERFORM ASIGNAR-CODIGO-ERROR.
           IF CODER3 OF CCAMOVIM NOT = ZEROS THEN
              MOVE CODER3 OF CCAMOVIM TO CODERR
              PERFORM ASIGNAR-CODIGO-ERROR.
           PERFORM CORREGIR-ERRORES
           PERFORM MODIFICAR-FILE-IMP.
      *--------------------------------------------------------------*
       CORREGIR-ERRORES.
           PERFORM REVISAR-PARAMETROS
           PERFORM REVISAR-FECORI
           PERFORM REVISAR-FECORI-FECHOY
           PERFORM REVISAR-FECVAL
           PERFORM REVISAR-AGCORI
           PERFORM REVISAR-USERID.
      *--------------------------------------------------------------*
       MODIFICAR-FILE-IMP.
      *    MOVE W-AGENCIA TO AGENVA  OF REPORTE-REG
           MOVE W-AGENCIA TO AGCCTA  OF CCAMOVIM
           MOVE CODPRO OF CCAMOVIM   TO W-CODPRO
                                        CODPRO OF CCAMAEAHO
           MOVE PAR-AGENVA TO AGENVA  OF REPORTE-REG
                              AGCCTA  OF CCAMOVIM
                              RGCCTA  OF CCAMOVIMR
                              W-OFICTA
                              AGCCTA OF CCAMAEAHO
           MOVE PAR-CUENTA TO CTANVA  OF REPORTE-REG
                             CTANRO  OF CCAMOVIM
                             RTANRO  OF CCAMOVIMR
                             W-NROCTA
                             CTANRO OF CCAMAEAHO
           MOVE W-CUENTA  TO CTANVA  OF REPORTE-REG
      *    MOVE W-DCNVA   TO DCNVA   OF REPORTE-REG
VG    *    MOVE W-DCNVA   TO DEBCRE  OF CCAMOVIM
      *    MOVE W-FVNVA   TO FVNVA   OF REPORTE-REG
           MOVE W-FVNVA   TO FECVAL  OF CCAMOVIM
      *    MOVE W-TVNVA   TO TVNVA   OF REPORTE-REG
           MOVE W-TVNVA   TO TIPVAL  OF CCAMOVIM
           MOVE W-FORNVA  TO FORNVA  OF REPORTE-REG
                             FORIGE  OF CCAMOVIM
           MOVE W-FVALNVA TO FVALNVA OF REPORTE-REG
VG    *                      FECVAL  OF CCAMOVIM
      *    MOVE W-AORNVA  TO AORNVA  OF REPORTE-REG
           MOVE W-AORNVA  TO AGCORI  OF CCAMOVIM.
           MOVE CODPRO OF CCAMOVIM TO CODPRO OF CCAMAEAHO
           MOVE CODMON OF CCAMOVIM TO CODMON OF CCAMAEAHO
           MOVE CODSIS OF CCAMOVIM TO CODSIS OF CCAMAEAHO
           PERFORM LEER-CCAMAEAHO
           IF (NO-EXISTE-CCAMAEAHO)
              PERFORM CREAR-CUENTA-RECHAZO
           END-IF.
      *--------------------------------------------------------------*
       CREAR-CUENTA-RECHAZO.
           INITIALIZE REGMAEAHO.
           MOVE CODPRO OF CCAMOVIM   TO CODPRO OF CCAMAEAHO
           MOVE PAR-AGENVA TO AGCCTA OF CCAMAEAHO
           MOVE PAR-CUENTA TO  CTANRO OF CCAMAEAHO
           MOVE CODPRO OF CCAMOVIM TO CODPRO OF CCAMAEAHO
           MOVE CODMON OF CCAMOVIM TO CODMON OF CCAMAEAHO.
           MOVE CODSIS OF CCAMOVIM TO CODSIS OF CCAMAEAHO.
           PERFORM VARYING I FROM 1 BY 1 UNTIL I = 13
               MOVE 0    TO  CANT-DEUDOR  ( I )
               MOVE 0    TO  SALDO-DEUDOR ( I )
               MOVE 0    TO  CANT-ACREED  ( I )
               MOVE 0    TO  SALDO-ACREED ( I )
           END-PERFORM
           MOVE ZEROS                  TO REGION OF REGMAEAHO
           MOVE LK-FECHA-HOY           TO FAPERT OF REGMAEAHO
           MOVE NITBAN OF PLTPARGEN    TO NITCTA OF REGMAEAHO
           MOVE ZEROS                  TO NITCT2 OF REGMAEAHO
           MOVE ZEROS                  TO NITCT3 OF REGMAEAHO
           MOVE ZEROS                  TO RESPON OF REGMAEAHO
           MOVE ZEROS                  TO SALACT OF REGMAEAHO
           MOVE ZEROES                 TO LIBRE  OF REGMAEAHO
           MOVE TABLA-PROMEDIOS        TO TABSAL OF REGMAEAHO

           WRITE ZONA-CCAMAEAHO
                 INVALID KEY
              DISPLAY  "Error al actualizar el Maestro de ahorros"
           END-WRITE.
      *--------------------------------------------------------------*
       REVISAR-PARAMETROS.
           IF DEBCRE OF CCAMOVIM NOT = DECRE(CODTRA OF CCAMOVIM)
              MOVE DECRE(CODTRA OF CCAMOVIM) TO W-DCNVA
                                                DEBCRE OF CCAMOVIM.
           IF TIPVAL OF CCAMOVIM NOT = TIVAL(CODTRA OF CCAMOVIM)
              MOVE TIVAL(CODTRA OF CCAMOVIM) TO W-TVNVA
                                                TIPVAL OF CCAMOVIM.
   VG *    IF FECVAL OF CCAMOVIM NOT = FECVA(CODTRA OF CCAMOVIM)
   VG *       MOVE FECVA(CODTRA OF CCAMOVIM) TO W-FVNVA
   VG *                                         FECVAL OF CCAMOVIM.
      *--------------------------------------------------------------*
       REVISAR-FECORI.
           IF FORIGE OF CCAMOVIM NOT = ZEROS THEN
              IF LK-FECHA-HOY NOT = FORIGE OF CCAMOVIM  THEN
                 CALL "CCA051P" USING FORIGE OF CCAMOVIM W-CODRET
                 IF W-CODRET NOT = 0 THEN
                    MOVE LK-FECHA-HOY TO W-FORNVA
                                   FORIGE OF CCAMOVIM
                 ELSE
                    NEXT SENTENCE
              ELSE
                NEXT SENTENCE
           ELSE
             MOVE LK-FECHA-HOY TO W-FORNVA
                            FORIGE OF CCAMOVIM.
      *--------------------------------------------------------------*
       REVISAR-FECORI-FECHOY.
           IF FORIGE OF CCAMOVIM NOT = ZEROS THEN
              IF FORIGE OF CCAMOVIM > LK-FECHA-HOY THEN
                 MOVE LK-FECHA-HOY TO W-FORNVA
                                FORIGE OF CCAMOVIM
              ELSE
                 NEXT SENTENCE
           ELSE
             MOVE LK-FECHA-HOY TO W-FORNVA
                            FORIGE OF CCAMOVIM.
      *--------------------------------------------------------------*
       REVISAR-FECVAL.
           IF FORIGE OF CCAMOVIM = ZEROS THEN
             MOVE LK-FECHA-HOY TO W-FORNVA
                            FORIGE OF CCAMOVIM
                            FVALOR OF CCAMOVIM
           ELSE
              IF LK-FECHA-HOY = FORIGE OF CCAMOVIM  THEN
                 IF FECVAL OF CCAMOVIM = 1 THEN
                    IF FVALOR OF CCAMOVIM = LK-FECHA-HOY THEN
                       NEXT SENTENCE
                    ELSE
                       MOVE LK-FECHA-HOY TO W-FVALNVA
                    END-IF
                 ELSE
                    IF FECVAL OF CCAMOVIM = 2 THEN
                       IF FVALOR OF CCAMOVIM = LK-FECHA-MANANA THEN
                          NEXT SENTENCE
                       ELSE
                          MOVE LK-FECHA-MANANA TO W-FVALNVA
                       END-IF
                    ELSE
                       IF FECVAL OF CCAMOVIM = 3 THEN
                          IF FVALOR OF CCAMOVIM = W-F48 THEN
                             NEXT SENTENCE
                          ELSE
                             MOVE W-F48 TO W-FVALNVA
                          END-IF
                       ELSE
                          IF FECVAL OF CCAMOVIM = 4 THEN
                             IF FVALOR OF CCAMOVIM = W-F72 THEN
                                NEXT SENTENCE
                             ELSE
                                MOVE W-F72 TO W-FVALNVA
                             END-IF
                          ELSE
                             IF FECVAL OF CCAMOVIM = 5 THEN
                                IF FVALOR OF CCAMOVIM = W-F96 THEN
                                   NEXT SENTENCE
                                ELSE
                                   MOVE W-F96 TO W-FVALNVA
                                END-IF
                             ELSE
                                IF FECVAL OF CCAMOVIM = 6 THEN
                                   IF FVALOR OF CCAMOVIM = W-F120 THEN
                                      NEXT SENTENCE
                                   ELSE
                                      MOVE W-F120 TO W-FVALNVA
                                ELSE
                                   MOVE 1 TO W-FVNVA
                                   MOVE LK-FECHA-HOY TO W-FVALNVA
                                END-IF
                             END-IF
                       END-IF
                    END-IF
                 END-IF
              ELSE
           IF FORIGE OF CCAMOVIM < LK-FECHA-HOY THEN
              IF FECVAL OF CCAMOVIM = 1 THEN
                 IF FVALOR OF CCAMOVIM = FORIGE OF CCAMOVIM
                    NEXT SENTENCE
                 ELSE
                 MOVE FORIGE OF CCAMOVIM TO W-FVALNVA
              ELSE
              IF FECVAL OF CCAMOVIM = 2 THEN
                 PERFORM CALCULAR-FECHA
                 IF LK219-FECHA3 NOT = FVALOR OF CCAMOVIM THEN
                    MOVE LK219-FECHA3 TO W-FVALNVA
                 ELSE
                    NEXT SENTENCE
              ELSE
              IF FECVAL OF CCAMOVIM = 3 THEN
                 PERFORM CALCULAR-FECHA
                 IF LK219-FECHA3 NOT = FVALOR OF CCAMOVIM THEN
                    MOVE LK219-FECHA3 TO W-FVALNVA
                 ELSE
                    NEXT SENTENCE
              ELSE
              IF FECVAL OF CCAMOVIM = 4 THEN
                 PERFORM CALCULAR-FECHA
                 IF LK219-FECHA3 NOT = FVALOR OF CCAMOVIM THEN
                    MOVE LK219-FECHA3 TO W-FVALNVA
                 ELSE
                    NEXT SENTENCE
              ELSE
              IF FECVAL OF CCAMOVIM = 5 THEN
                 PERFORM CALCULAR-FECHA
                 IF LK219-FECHA3 NOT = FVALOR OF CCAMOVIM THEN
                    MOVE LK219-FECHA3 TO W-FVALNVA
                 ELSE
                    NEXT SENTENCE
              ELSE
              IF FECVAL OF CCAMOVIM = 6 THEN
                 PERFORM CALCULAR-FECHA
                 IF LK219-FECHA3 NOT = FVALOR OF CCAMOVIM THEN
                    MOVE LK219-FECHA3 TO W-FVALNVA
                 ELSE
                    NEXT SENTENCE
              ELSE
                MOVE 1 TO W-FVNVA
                MOVE LK-FECHA-HOY TO W-FVALNVA.
      *--------------------------------------------------------------*
       REVISAR-AGCORI.
           IF AGCORI OF CCAMOVIM NOT = ZEROS THEN
              IF AGCORI OF CCAMOVIM NOT > 99999 THEN
                 IF EXISTE(AGCORI OF CCAMOVIM) NOT = 1 THEN
                    MOVE W-AGENCIA TO W-AORNVA
                 ELSE
                    NEXT SENTENCE
              ELSE
                MOVE W-AGENCIA TO W-AORNVA
           ELSE
             MOVE W-AGENCIA TO W-AORNVA.
      *--------------------------------------------------------------*
       REVISAR-USERID.
           IF CODCAJ OF CCAMOVIM = SPACES THEN
              MOVE W-USRID TO CODCAJ OF CCAMOVIM.
      *--------------------------------------------------------------*
       LEER-CCAMOVIM.
           MOVE 0 TO CTL-CCAMOVIM
           READ CCAMOVIM NEXT RECORD AT END MOVE 1 TO CTL-CCAMOVIM.
           IF NOT ERROR-CCAMOVIM THEN
              IF CODER1 OF CCAMOVIM NOT = ZEROS OR
                 CODER2 OF CCAMOVIM NOT = ZEROS OR
                 CODER3 OF CCAMOVIM NOT = ZEROS THEN
                 MOVE 0 TO CTL-OK
              ELSE
                 PERFORM REGRABAR.
      *--------------------------------------------------------------*
       REGRABAR.
           MOVE CORR REGMOVIM OF CCAMOVIM TO REGMOVIM OF CCAMOVTMP.
           WRITE ZONA-CCAMOVTMP.
      *    REWRITE ZONA-CCAMOVIM.
      *--------------------------------------------------------------*
       CALCULAR-FECHA.
              MOVE FORIGE OF CCAMOVIM TO LK219-FECHA1
              MOVE ZEROS              TO LK219-FECHA2
              MOVE ZEROS              TO LK219-FECHA3
              MOVE 1                  TO LK219-TIPFMT
              MOVE 2                  TO LK219-BASCLC
              MOVE FECVAL OF CCAMOVIM TO LK219-NRODIA
              SUBTRACT 1 FROM LK219-NRODIA
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
           MOVE 4        TO LK219-NRODIA
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO W-F96.
           MOVE 5        TO LK219-NRODIA
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO W-F120.
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
           MOVE PA-CODEMP         TO CODEMP OF PLTAGCORI
           READ PLTAGCORI NEXT RECORD AT END MOVE 1 TO CTL-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE 1 TO EXISTE(AGCORI OF PLTAGCORI).
      *--------------------------------------------------------------*
       IMPRIMIR-TITULOS.
           INITIALIZE HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA560    "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "*** MOVIMIENTOS ASIGNADOS A CUENTAS DE RECHAZO ***"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
           MOVE HORA              TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER"
           INITIALIZE AGENCIA-O
           PERFORM TRAER-AGENCIA
           WRITE REPORTE-REG FORMAT IS "AGENCIA"
           WRITE REPORTE-REG FORMAT IS "TITREC"
           WRITE REPORTE-REG FORMAT IS "TITULOS".
      *--------------------------------------------------------------*
       TRAER-AGENCIA.
           MOVE 0 TO CTL-PLTAGCORI
           MOVE PA-CODEMP         TO CODEMP OF PLTAGCORI
           MOVE W-AGENCIA TO AGCORI OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE W-AGENCIA             TO AGEN  OF REPORTE-REG
              MOVE NOMAGC OF PLTAGCORI   TO DEAGE OF REPORTE-REG
           ELSE
              MOVE W-AGENCIA             TO AGEN  OF REPORTE-REG
              MOVE "AGENCIA INEXISTENTE" TO DEAGE OF REPORTE-REG.
      *--------------------------------------------------------------*
       IMPRIMIR-TOT-CTA.
           IF W-TOTDEB NOT = ZEROS OR
              W-TOTCRE NOT = ZEROS THEN
                MOVE W-TOTDEB TO TOTDB OF REPORTE-REG
                MOVE W-TOTCRE TO TOTCR OF REPORTE-REG
                WRITE REPORTE-REG FORMAT IS "TOTDEB"
                INITIALIZE W-TOTDEB W-TOTCRE
                WRITE REPORTE-REG FORMAT IS "FIRMA".
      *--------------------------------------------------------------*
       VALIDAR-AGENCIA.
           IF AGCCTA OF CCAMOVIM NOT > 9999 THEN
              IF EXISTE(AGCCTA OF CCAMOVIM) NOT = 1 THEN
                 MOVE 9000               TO W-AGENCIA
                 MOVE 9000               TO W-CODSUC
              ELSE
                 MOVE AGCCTA OF CCAMOVIM TO W-AGENCIA
                 MOVE NROBNV OF CCAMOVIM TO W-CODSUC
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
              IF CODER1 OF CCAMOVIM = CODERR THEN
                 MOVE W-DESCER TO ERRO1 OF REPORTE-REG
              ELSE
              IF CODER2 OF CCAMOVIM = CODERR THEN
                 MOVE W-DESCER TO ERRO2 OF REPORTE-REG
              ELSE
              IF CODER3 OF CCAMOVIM = CODERR THEN
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
       LEER-CCAMAEAHO.
           MOVE 1 TO W-EXISTE-CCAMAEAHO
           READ CCAMAEAHO INVALID KEY
                MOVE ZEROS TO W-EXISTE-CCAMAEAHO
           END-READ.
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
           MOVE I TO AGCORI OF PLTAGCORI
           MOVE PA-CODEMP         TO CODEMP OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF PLTAGCORI     TO TDESAGE OF REPORTE-REG
           ELSE
              MOVE "AGENCIA INEXISTENTE" TO TDESAGE OF REPORTE-REG.
      *--------------------------------------------------------------*
       IMP-TIT-I.
           INITIALIZE HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA560    "      TO NROPRO  OF REPORTE-REG
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
      *--------------------------------------------------------------*
       LEER-PLTPARGEN.
TYJ        MOVE PA-CODEMP   TO CODEMP OF PLTPARGEN
           READ PLTPARGEN              INVALID KEY
                DISPLAY "Error al leer Parámetros Generales"
                STOP RUN
           END-READ.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE CCAMOVTMP     REPORTE
                 CCAMOVIM      PLTSUCURS
                 CCACODTRN     CCAMAEAHO
                 CCATABLAS     PLTPARGEN
                 PLTAGCORI.
           STOP RUN.
