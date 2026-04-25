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
       PROGRAM-ID.    CCA730.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: GENERACION DE EXTRACTOS MENSUALES Y A PEDIDO. SI    *
      *          EXISTE INDICACION DE CIERRE GERNERACION DE EXTRACTOS*
      *          MENSUALES Y DEPURACION CCAHISTOR ===> CCAHISTO1.      *
      *          ACTUALIZACION DE LA FECHA DE ULTIMO RESUMEN Y SALDOS*
      *          RESUMEN EN CCAMAEAHO. ASI NO SE LE GENERE EXTRACTO A *
      *          LA CUENTA. SI ES CIERRE SE DEBE CONTROLAR EL MANEJO *
      *          DE MIEMBROS EN EL CAEXTRAC PARA LOS DIFERENTES MESES*
      *--------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAHISTOR
               ASSIGN          TO DATABASE-CCAHISTOR
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCAHISTO1
               ASSIGN          TO DATABASE-CCAHISTO1
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAEXTRAS
               ASSIGN          TO DATABASE-CCAEXTRAS
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCATABLAS
               ASSIGN          TO DATABASE-CCATABLAS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
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
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTCIUDAD
               ASSIGN          TO DATABASE-PLTCIUDAD
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT REPORTE
               ASSIGN          TO FORMATFILE-CCA730R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAHISTOR
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAHISTOR.
           COPY DDS-ALL-FORMATS OF CCAHISTOR.
      *
       FD  CCAHISTO1
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAHISTO1.
           COPY DDS-ALL-FORMATS OF CCAHISTO1.
      *                                                                 IBM-CT
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *                                                                 IBM-CT
       FD  CCAEXTRAS
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAEXTRAS.
           COPY DDS-ALL-FORMATS OF CCAEXTRAS.
      *                                                                 IBM-CT
       FD  CCATABLAS
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCATABLAS.
           COPY DDS-ALL-FORMATS OF CCATABLAS.
      *                                                                 IBM-CT
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACODTRN.
           COPY DDS-ALL-FORMATS OF CCACODTRN.
      *                                                                 IBM-CT
       FD  CLIMAEL01
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CLIMAEL01.
           COPY DDS-ALL-FORMATS OF CLIMAEL01.
      *                                                                 IBM-CT
      *FD  CLIDIR
      *    LABEL RECORDS ARE STANDARD.
      *01  ZONA-CLIDIR.
      *    COPY DDS-ALL-FORMATS OF CLIDIR.
      *                                                                 IBM-CT
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *                                                                 IBM-CT
       FD  PLTCIUDAD
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTCIUDAD.
           COPY DDS-ALL-FORMATS OF PLTCIUDAD.
      *                                                                 IBM-CT
       FD  REPORTE
           LABEL RECORDS ARE STANDARD.
       01  REPORTE-REG.
           COPY DDS-ALL-FORMATS OF CCA730R.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
           COPY CATABLASR1 OF CCACPY.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCAHISTOR            PIC 9(01) VALUE 0.
               88  ERROR-CCAHISTOR                VALUE 1.
           05  CTL-CCAHISTO1            PIC 9(01) VALUE 0.
               88  ERROR-CCAHISTO1                VALUE 1.
           05  CTL-CCAMAEAHO            PIC 9(01) VALUE 0.
               88  ERROR-CCAMAEAHO                VALUE 1.
           05  CTL-CCAEXTRAS            PIC 9(01) VALUE 0.
               88  ERROR-CCAEXTRAS                VALUE 1.
           05  CTL-CCATABLAS            PIC 9(01) VALUE 0.
               88  ERROR-CCATABLAS                VALUE 1.
           05  CTL-CCACODTRN             PIC 9(01) VALUE 0.
               88  ERROR-CCACODTRN                 VALUE 1.
           05  CTL-CLIMAEL01              PIC 9(01) VALUE 0.
               88  ERROR-CLIMAEL01                  VALUE 1.
           05  CTL-CLIDIR              PIC 9(01) VALUE 0.
               88  ERROR-CLIDIR                  VALUE 1.
           05  CTL-PLTAGCORI              PIC 9(01) VALUE 0.
               88  ERROR-PLTAGCORI                  VALUE 1.
           05  CTL-PLTCIUDAD              PIC 9(01) VALUE 0.
               88  ERROR-PLTCIUDAD                  VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01) VALUE 0.
               88  FIN-PROGRAMA                  VALUE 1.
           05  CTL-OK                  PIC 9(01) VALUE 0.
               88  ERROR-OK                      VALUE 1.
           05  CTL-IMPRESION           PIC 9(01) VALUE 0.
               88  ERROR-IMPRESION               VALUE 1.
           05  CTL-PRIMERA             PIC 9(01) VALUE 0.
               88  ERROR-PRIMERA                 VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  W-FECHA                 PIC  9(08)    VALUE ZEROS.
           05  RED-W-FECHA             REDEFINES     W-FECHA.
               10 ANO                  PIC  9(04).
               10 MES                  PIC  9(02).
               10 DIA                  PIC  9(02).
           05  W-NIT                   PIC  9(13)    VALUE ZEROS.
           05  RED-W-NIT               REDEFINES     W-NIT.
               10 W-NITESP             PIC  9(12).
               10 W-NITRES             PIC  9(01).
           05  W-FEC                   PIC  9(04)    VALUE ZEROS.
           05  W-FECLIQ                PIC  9(08)    VALUE ZEROS.
           05  RED-W-FECLIQ            REDEFINES     W-FECLIQ.
               10 ANOLIQ               PIC  9(04).
               10 MESLIQ               PIC  9(02).
               10 DIALIQ               PIC  9(02).
           05  W-FECCIE                PIC  9(08)    VALUE ZEROS.
           05  RED-W-FECCIE            REDEFINES     W-FECCIE.
               10 ANOCIE               PIC  9(04).
               10 MESCIE               PIC  9(02).
               10 DIACIE               PIC  9(02).
           05  W-CODRET                PIC  9(01)    VALUE ZEROS.
           05  W-SALDO                 PIC S9(15)V99 VALUE ZEROS.
           05  CONT                    PIC  9(07)    VALUE ZEROS.
           05  CONX                    PIC  9(07)    VALUE ZEROS.
           05  W-AUDT                  PIC  X(080)   VALUE SPACES.
           05  TOT-VALDEB              PIC  9(15)V99 VALUE ZEROS.
           05  TOT-VALCRE              PIC  9(15)V99 VALUE ZEROS.
           05  W-SALDOX                PIC  9(15)V99 VALUE ZEROS.
           05  W-SALULR                PIC  9(15)V99 VALUE ZEROS.
           05  W-PAGINA                PIC  9(05)    VALUE ZEROS.
           05  I                       PIC  9(05)    VALUE ZEROS.
      *--------------------------------------------------------------*
      * ALMACENA EL ULTIMO DIA CALENDARIO DEL MES QUE CORTA.
      *--------------------------------------------------------------*
           05  W-FECHACTL-1            PIC 9(08)     VALUE ZEROS.
           05  R-FECHACTL-1            REDEFINES     W-FECHACTL-1.
               10  ANO-CTL-1           PIC 9(04).
               10  MES-CTL-1           PIC 9(02).
               10  DIA-CTL-1           PIC 9(02).
      *
      * FECHA DE CONTROL.
      *
           05  W-FECHACTL-0            PIC 9(08)     VALUE ZEROS.
           05  R-FECHACTL-0            REDEFINES     W-FECHACTL-0.
               10  ANO-CTL-0           PIC 9(04).
               10  MES-CTL-0           PIC 9(02).
               10  DIA-CTL-0           PIC 9(02).
      * RUTINA PARA QUITAR BLANCOS AL NOMBRE                         *
      *--------------------------------------------------------------*
           05  W-NOMENV                PIC X(50) VALUE SPACES.
           05  W-NOMREC                PIC X(50) VALUE SPACES.
           05  W-CODIGO                PIC X(01) VALUE SPACES.
      *--------------------------------------------------------------*
           05  W-DIRECC                PIC X(50) VALUE SPACES.
           05  RED-W-DIRECC            REDEFINES W-DIRECC.
               10 W-BASURA             PIC X(02).
               10 W-NOMBRE             PIC X(48).
      *--------------------------------------------------------------*
       01  W-CL-CCAHISTOR.
           05  W-AGCCTA-CCAHISTOR       PIC 9(05) VALUE ZEROS.
           05  W-CTANRO-CCAHISTOR       PIC 9(15) VALUE ZEROS.
      *
       01  W-CL-CCAMAEAHO.
           05  W-AGCCTA-CCAMAEAHO       PIC 9(05) VALUE ZEROS.
           05  W-CTANRO-CCAMAEAHO       PIC 9(15) VALUE ZEROS.
      *--------------------------------------------------------------*
           COPY FECHAS  OF CCACPY.
           COPY PLT219  OF CCACPY.
       LINKAGE SECTION.
       77  PAR-FECLIQ                  PIC 9(08).
       77  PAR-CODRET                  PIC 9(01).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING PAR-FECLIQ PAR-CODRET.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN OUTPUT REPORTE
                       CCAHISTO1
                       CCAEXTRAS.
           OPEN INPUT  CCATABLAS
                       CCACODTRN
                       CLIMAEL01
      *                CLIDIR
                       PLTAGCORI
                       PLTCIUDAD.
           OPEN I-O    CCAHISTOR
                       CCAMAEAHO.
           CALL "CCA500" USING LK-FECHAS                                A
           PERFORM LEER-CCAHISTOR
           MOVE 1 TO CTL-OK
           PERFORM LEER-CCAMAEAHO UNTIL ERROR-CCAMAEAHO OR
                                       NOT ERROR-OK
           MOVE PAR-FECLIQ TO W-FECLIQ
           MOVE PAR-CODRET TO W-CODRET.
      *--------------------------------------------------------------*
       PROCESAR.
           IF ERROR-CCAHISTOR THEN
              IF ERROR-CCAMAEAHO THEN
                 MOVE 1 TO CTL-PROGRAMA
              ELSE
                 INITIALIZE W-PAGINA
                 PERFORM GRABAR-CCAMAEAHO
                 MOVE 1 TO CTL-OK
                 PERFORM LEER-CCAMAEAHO UNTIL ERROR-CCAMAEAHO OR
                                             NOT ERROR-OK
           ELSE
              IF W-CL-CCAHISTOR < W-CL-CCAMAEAHO
                 PERFORM ERROR-FATAL UNTIL FIN-PROGRAMA
              ELSE
                IF W-CL-CCAHISTOR = W-CL-CCAMAEAHO
                   PERFORM PRI-REG
                   PERFORM ACTUALIZAR-MAESTRO
                   PERFORM LEER-CCAHISTOR
                ELSE
                   INITIALIZE W-PAGINA
                   PERFORM GRABAR-CCAMAEAHO
                   MOVE 1 TO CTL-OK
                   PERFORM LEER-CCAMAEAHO UNTIL ERROR-CCAMAEAHO OR
                                           NOT ERROR-OK.
      *--------------------------------------------------------------*
       PRI-REG.
           IF NOT ERROR-PRIMERA THEN
              MOVE 1 TO CONX
              MOVE 1 TO CTL-PRIMERA.
      *--------------------------------------------------------------*
       GRABAR-CCAMAEAHO.
           IF ERROR-CCAHISTOR THEN
              MOVE 0 TO CTL-IMPRESION
              PERFORM REVISAR-INF-FALTANTE
              IF W-CODRET = 1 THEN
                 IF NOT ERROR-IMPRESION THEN
                    PERFORM IMP-EXT-SIN-MOV-HIS
                    MOVE FULTRE OF REGMAEAHO TO FPULRE OF REGMAEAHO
                    MOVE W-FECLIQ            TO FULTRE OF REGMAEAHO
                    MOVE SALULR OF REGMAEAHO TO SALPUR OF REGMAEAHO
                                                W-SALDO
                    MOVE W-SALDO             TO SALULR OF REGMAEAHO
                    REWRITE ZONA-CCAMAEAHO
                 ELSE
                   NEXT SENTENCE
              ELSE
              IF INDRAP OF REGMAEAHO = 1 THEN
                 PERFORM IMP-EXT-SIN-MOV-HIS
              ELSE
                 NEXT SENTENCE
           ELSE
           IF CONX = 0 THEN
              IF W-CODRET = 1 THEN
                 PERFORM IMP-EXT-SIN-MOV-HIS
                 MOVE FULTRE OF REGMAEAHO TO FPULRE OF REGMAEAHO
                 MOVE W-FECLIQ            TO FULTRE OF REGMAEAHO
                 MOVE SALULR OF REGMAEAHO TO SALPUR OF REGMAEAHO
                                             W-SALDO
                 MOVE W-SALDO             TO SALULR OF REGMAEAHO
                 REWRITE ZONA-CCAMAEAHO
              ELSE
              IF INDRAP OF REGMAEAHO = 1 THEN
                 PERFORM IMP-EXT-SIN-MOV-HIS
              ELSE
                NEXT SENTENCE
           ELSE
              IF W-CODRET = 1 THEN
                 IF CONT NOT = ZEROS THEN
                    PERFORM IMPRIMIR-LIN-FALTANTES
                    PERFORM IMPRIMIR-TOTALES
                    PERFORM IMPRIMIR-LEYENDA
                    PERFORM LEER-CCATABLAS-AUD
                    PERFORM IMPRIMIR-FOOTER
                    MOVE FULTRE OF REGMAEAHO TO FPULRE OF REGMAEAHO
                    MOVE W-FECLIQ            TO FULTRE OF REGMAEAHO
                    MOVE W-SALULR            TO SALPUR OF REGMAEAHO
                    MOVE W-SALDO             TO SALULR OF REGMAEAHO
                    REWRITE ZONA-CCAMAEAHO
                 ELSE
                    PERFORM IMP-EXT-SIN-MOV-HIS
              ELSE
              IF INDRAP OF REGMAEAHO = 1 THEN
                 PERFORM IMPRIMIR-LIN-FALTANTES
                 PERFORM IMPRIMIR-TOTALES
                 PERFORM IMPRIMIR-LEYENDA
                 PERFORM LEER-CCATABLAS-AUD
                 PERFORM IMPRIMIR-FOOTER.
           INITIALIZE W-SALDO CONX CONT TOT-VALDEB TOT-VALCRE.
           MOVE 0 TO CTL-PRIMERA.
      *--------------------------------------------------------------*
       ACTUALIZAR-MAESTRO.
           IF CONX = 1 THEN
              IF W-CODRET = 1 THEN
                 IF FORIGE OF ZONA-CCAHISTOR NOT > W-FECLIQ THEN
                    MOVE SALULR OF REGMAEAHO TO W-SALDO
                                                W-SALULR
                    PERFORM IMPRIMIR-PAGINA
                 ELSE
                    NEXT SENTENCE
              ELSE
              IF INDRAP OF REGMAEAHO = 1 THEN
                  MOVE SALULR OF REGMAEAHO TO W-SALDO
                  PERFORM IMPRIMIR-PAGINA.
           IF CONX = 31 THEN
              IF INDRAP OF REGMAEAHO = 1 OR W-CODRET = 1 THEN
                 PERFORM IMPRIMIR-TOTALES
                 PERFORM IMPRIMIR-LEYENDA
                 PERFORM LEER-CCATABLAS-AUD
                 PERFORM IMPRIMIR-FOOTER
                 MOVE 1 TO CONX
                 MOVE W-SALDOX TO W-SALDO
                                  SALULR OF REGMAEAHO
                 PERFORM IMPRIMIR-PAGINA.
           IF W-CODRET = 1 THEN
              IF FORIGE OF ZONA-CCAHISTOR NOT > W-FECLIQ THEN
                 ADD 1 TO CONT
                 PERFORM GRABAR-CCAEXTRAS
                 PERFORM CANTIDAD-MVTO
                 PERFORM IMPRIMIR-DETALLE
              ELSE
                 PERFORM COPIAR-HISTO1
           ELSE
           PERFORM COPIAR-HISTO1
           IF INDRAP OF REGMAEAHO = 1 THEN
              PERFORM CANTIDAD-MVTO
              PERFORM IMPRIMIR-DETALLE.
      *--------------------------------------------------------------*
       REVISAR-INF-FALTANTE.
           IF W-CODRET = 1 OR INDRAP OF REGMAEAHO = 1 THEN
              IF CONX NOT = ZEROS THEN
                 MOVE 1 TO CTL-IMPRESION
                 PERFORM IMPRIMIR-LIN-FALTANTES
                 PERFORM IMPRIMIR-TOTALES
                 PERFORM IMPRIMIR-LEYENDA
                 PERFORM IMPRIMIR-FOOTER
                 MOVE FULTRE OF REGMAEAHO TO FPULRE OF REGMAEAHO
                 MOVE W-FECLIQ            TO FULTRE OF REGMAEAHO
                 MOVE SALULR OF REGMAEAHO TO SALPUR OF REGMAEAHO
                 MOVE W-SALDO             TO SALULR OF REGMAEAHO
                 REWRITE ZONA-CCAMAEAHO.
      *--------------------------------------------------------------*
       CANTIDAD-MVTO.
           IF DEBCRE OF ZONA-CCAHISTOR = 1 THEN
              ADD IMPORT OF ZONA-CCAHISTOR TO TOT-VALDEB
              COMPUTE W-SALDO = W-SALDO - IMPORT OF ZONA-CCAHISTOR
           ELSE
              ADD IMPORT OF ZONA-CCAHISTOR TO TOT-VALCRE
              COMPUTE W-SALDO = W-SALDO + IMPORT OF ZONA-CCAHISTOR.
      *--------------------------------------------------------------*
       COPIAR-HISTO1.
           INITIALIZE ZONA-CCAHISTO1
           MOVE ZONA-CCAHISTOR TO ZONA-CCAHISTO1
           WRITE ZONA-CCAHISTO1.
      *--------------------------------------------------------------*
       GRABAR-CCAEXTRAS.
           INITIALIZE ZONA-CCAEXTRAS
           MOVE AGCCTA OF ZONA-CCAHISTOR TO AGCCTA OF ZONA-CCAEXTRAS
           MOVE CTANRO OF ZONA-CCAHISTOR TO CTANRO OF ZONA-CCAEXTRAS
           MOVE CONT                    TO SECUEN OF ZONA-CCAEXTRAS
           MOVE FORIGE OF ZONA-CCAHISTOR TO FORIGE OF ZONA-CCAEXTRAS
           MOVE DEBCRE OF ZONA-CCAHISTOR TO DEBCRE OF ZONA-CCAEXTRAS
           MOVE CODTRA OF ZONA-CCAHISTOR TO CODTRA OF ZONA-CCAEXTRAS
           MOVE IMPORT OF ZONA-CCAHISTOR TO IMPORT OF ZONA-CCAEXTRAS
           MOVE FVALOR OF ZONA-CCAHISTOR TO FVALOR OF ZONA-CCAEXTRAS
           MOVE NROREF OF ZONA-CCAHISTOR TO NROREF OF ZONA-CCAEXTRAS
           MOVE FECVAL OF ZONA-CCAHISTOR TO FECVAL OF ZONA-CCAEXTRAS
           MOVE TIPVAL OF ZONA-CCAHISTOR TO TIPVAL OF ZONA-CCAEXTRAS
           MOVE ESTTRN OF ZONA-CCAHISTOR TO ESTTRN OF ZONA-CCAEXTRAS
           MOVE AGCORI OF ZONA-CCAHISTOR TO AGCORI OF ZONA-CCAEXTRAS
           MOVE CODCAJ OF ZONA-CCAHISTOR TO CODCAJ OF ZONA-CCAEXTRAS
           WRITE ZONA-CCAEXTRAS.
      *--------------------------------------------------------------*
       LEER-CCAHISTOR.
           MOVE 0 TO CTL-CCAHISTOR
           READ CCAHISTOR NEXT RECORD AT END
                       MOVE 1               TO CTL-CCAHISTOR
                       MOVE 99999           TO AGCCTA OF ZONA-CCAHISTOR
                       MOVE 999999999999999 TO CTANRO OF ZONA-CCAHISTOR.
           MOVE AGCCTA OF ZONA-CCAHISTOR TO W-AGCCTA-CCAHISTOR
           MOVE CTANRO OF ZONA-CCAHISTOR TO W-CTANRO-CCAHISTOR.
      *--------------------------------------------------------------*
       LEER-CCAMAEAHO.
           MOVE 0 TO CTL-CCAMAEAHO
           READ CCAMAEAHO NEXT RECORD AT END
                        MOVE 1                TO CTL-CCAMAEAHO
                        MOVE 99999            TO AGCCTA OF REGMAEAHO
                        MOVE 999999999999999  TO CTANRO OF REGMAEAHO.
           MOVE AGCCTA OF REGMAEAHO TO W-AGCCTA-CCAMAEAHO
           MOVE CTANRO OF REGMAEAHO TO W-CTANRO-CCAMAEAHO.
           IF NOT ERROR-CCAMAEAHO THEN
              MOVE FCIERR OF REGMAEAHO TO W-FECCIE
              IF MESLIQ = MESCIE THEN
                 MOVE 0 TO CTL-OK
              ELSE
              IF INDBAJ OF REGMAEAHO = 0 THEN
                 MOVE 0 TO CTL-OK.
      *--------------------------------------------------------------*
       LEER-CCATABLAS-LEYENDAS.
           MOVE 0                   TO CTL-CCATABLAS
           MOVE 3                   TO CODTAB OF REGTABLAS
           MOVE SEGMEN OF REGMAEAHO TO NROTAB OF REGTABLAS
           READ CCATABLAS INVALID KEY MOVE 1 TO CTL-CCATABLAS.
           IF NOT ERROR-CCATABLAS THEN
              INITIALIZE RESTO LEYENDA-O
              MOVE CAMPO2 OF REGTABLAS TO RESTO
              MOVE W-LEYEND1           TO LEYEXT1 OF REPORTE-REG
              MOVE W-LEYEND2           TO LEYEXT2 OF REPORTE-REG
              MOVE W-LEYEND3           TO LEYEXT3 OF REPORTE-REG
           ELSE
              INITIALIZE                  LEYEXT1 OF REPORTE-REG
                                          LEYEXT2 OF REPORTE-REG
                                          LEYEXT3 OF REPORTE-REG.
      *--------------------------------------------------------------*
       LEER-CCATABLAS-AUD.
           MOVE 0 TO CTL-CCATABLAS
           MOVE 5 TO CODTAB OF REGTABLAS
           MOVE 0 TO NROTAB OF REGTABLAS
           READ CCATABLAS INVALID KEY MOVE 1 TO CTL-CCATABLAS.
           INITIALIZE W-AUDT
           IF NOT ERROR-CCATABLAS THEN
              INITIALIZE RESTO AUDIT-O W-AUDT
              MOVE CAMPO2 OF REGTABLAS TO RESTO
              MOVE W-DESAUD  TO W-AUDT
           ELSE
              MOVE "Nombre Compañia Auditora No fue Encontrado"
              TO W-AUDT.
      *--------------------------------------------------------------*
       LEER-CLIMAEL01.
           MOVE 0 TO CTL-CLIMAEL01
           READ CLIMAEL01 INVALID KEY MOVE 1 TO CTL-CLIMAEL01.
      *--------------------------------------------------------------*
      *LEER-CLIDIR.
      *    MOVE 0 TO CTL-CLIDIR
      *    READ CLIDIR INVALID KEY MOVE 1 TO CTL-CLIDIR.
      *--------------------------------------------------------------*
       LEER-PLTAGCORI.
           MOVE 0 TO CTL-PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
      *--------------------------------------------------------------*
       LEER-PLTCIUDAD.
           MOVE 0 TO CTL-PLTCIUDAD
           READ PLTCIUDAD INVALID KEY MOVE 1 TO CTL-PLTCIUDAD.
      *--------------------------------------------------------------*
       ERROR-FATAL.
           DISPLAY "CL-CCAHISTOR < CL-CCAMAEAHO..."
                    W-CL-CCAHISTOR " " W-CL-CCAMAEAHO.
           DISPLAY "ERROR FATAL, CANCELAR EL PROCESO...".
      *--------------------------------------------------------------*
       IMP-EXT-SIN-MOV-HIS.
           PERFORM IMPRIMIR-PAGINA
           INITIALIZE DETALLE-O
           INITIALIZE FECEXT OF REPORTE-REG
                      CONEXT OF REPORTE-REG
                      CREEXT OF REPORTE-REG
                      DEBEXT OF REPORTE-REG
                      SALEXT OF REPORTE-REG
           MOVE "Cuenta Sin Movimientos" TO CONEXT OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "DETALLE"
           MOVE 1 TO I
           PERFORM IMP-DETALLE-SIN-MOV-HIS UNTIL I = 30
           PERFORM IMP-TOTALES-SIN-MOV-HIS
           PERFORM IMPRIMIR-LEYENDA
           PERFORM LEER-CCATABLAS-AUD
           PERFORM IMPRIMIR-FOOTER
           INITIALIZE W-PAGINA.
      *--------------------------------------------------------------*
       IMPRIMIR-PAGINA.
           INITIALIZE                  HEADER-O
           ADD 1                    TO W-PAGINA
           MOVE W-PAGINA            TO HOJEXT OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER".
      *--------------------------------------------------------------*
       IMP-DETALLE-SIN-MOV-HIS.
           INITIALIZE DETALLE-O
           INITIALIZE FECEXT OF REPORTE-REG
                      CONEXT OF REPORTE-REG
                      CREEXT OF REPORTE-REG
                      DEBEXT OF REPORTE-REG
                      SALEXT OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "DETALLE"
           ADD 1 TO I.
      *--------------------------------------------------------------*
       IMPRIMIR-DETALLE.
           INITIALIZE DETALLE-O
           MOVE FORIGE OF ZONA-CCAHISTOR TO W-FEC
           MOVE W-FEC                   TO FECEXT OF REPORTE-REG
           PERFORM DESCRIPCION-MVTO
           IF DEBCRE OF ZONA-CCAHISTOR = 1 THEN
              MOVE IMPORT OF ZONA-CCAHISTOR TO DEBEXT OF REPORTE-REG
           ELSE
              MOVE IMPORT OF ZONA-CCAHISTOR TO CREEXT OF REPORTE-REG.
           MOVE W-SALDO                    TO SALEXT OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "DETALLE"
           ADD 1 TO CONX.
      *--------------------------------------------------------------*
       IMP-TOTALES-SIN-MOV-HIS.
           INITIALIZE                  TOTALES-O
           MOVE SALULR OF REGMAEAHO TO ULTEXT  OF REPORTE-REG
           INITIALIZE                  TCREEXT OF REPORTE-REG
                                       TDEBEXT OF REPORTE-REG
           MOVE SALULR OF REGMAEAHO TO TSALEXT OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "TOTALES".
      *--------------------------------------------------------------*
       IMPRIMIR-TOTALES.
           INITIALIZE                  TOTALES-O
           MOVE SALULR OF REGMAEAHO TO ULTEXT  OF REPORTE-REG
           MOVE TOT-VALCRE          TO TCREEXT OF REPORTE-REG
           MOVE TOT-VALDEB          TO TDEBEXT OF REPORTE-REG
           INITIALIZE W-SALDOX
           COMPUTE W-SALDOX = (SALULR OF REGMAEAHO + TOT-VALCRE)
                               - TOT-VALDEB
           MOVE W-SALDOX            TO TSALEXT  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "TOTALES"
           INITIALIZE TOT-VALCRE TOT-VALDEB.
      *--------------------------------------------------------------*
       IMPRIMIR-LEYENDA.
           PERFORM LEER-CCATABLAS-LEYENDAS
           WRITE REPORTE-REG FORMAT IS "LEYENDA".
      *--------------------------------------------------------------*
       IMPRIMIR-LIN-FALTANTES.
           INITIALIZE I
           MOVE CONX TO I
           COMPUTE I = I - 1
           IF I NOT > ZEROS THEN
              MOVE 1 TO I.
           PERFORM IMP-DETALLE-SIN-MOV-HIS UNTIL I = 30.
      *--------------------------------------------------------------*
       IMPRIMIR-FOOTER.
           INITIALIZE                  FOOTER-O

           INITIALIZE W-NOMENV W-NOMREC W-CODIGO
           MOVE DESCRI OF REGMAEAHO TO W-NOMENV
           MOVE 1                   TO W-CODIGO
           CALL "SCC001" USING W-NOMENV W-NOMREC W-CODIGO
           MOVE W-NOMREC            TO NOMEXT OF REPORTE-REG
           IF W-CODRET = 1 THEN
              PERFORM CALCULAR-FIN-MES
              MOVE ANO-CTL-1        TO ANOCOR  OF REPORTE-REG
              MOVE MES-CTL-1        TO MESCOR  OF REPORTE-REG
              MOVE DIA-CTL-1        TO DIACOR  OF REPORTE-REG
           ELSE
           IF INDRAP OF REGMAEAHO = 1 THEN
              PERFORM CALCULAR-FEC-DOS-DIAS
              MOVE ANO              TO ANOCOR  OF REPORTE-REG
              MOVE MES              TO MESCOR  OF REPORTE-REG
              MOVE DIA              TO DIACOR  OF REPORTE-REG.

      *    MOVE NITCTA OF REGMAEAHO TO C45NID OF CLIDIRR
      *    MOVE CODNDI OF REGMAEAHO TO C45NDI OF CLIDIRR
      *    PERFORM LEER-CLIDIR
      *    IF NOT ERROR-CLIDIR THEN
      *       IF C45DI1 OF CLIDIRR NOT = SPACES THEN
      *          INITIALIZE W-DIRECC
      *          MOVE C45DI1 OF CLIDIRR TO W-DIRECC
      *          PERFORM DIRECCION
      *       ELSE
      *       IF C45DI2 OF CLIDIRR NOT = SPACES THEN
      *          INITIALIZE W-DIRECC
      *          MOVE C45DI2 OF CLIDIRR TO W-DIRECC
      *          PERFORM DIRECCION
      *       ELSE
      *       IF C45DI3 OF CLIDIRR NOT = SPACES THEN
      *          INITIALIZE W-DIRECC
      *          MOVE C45DI3 OF CLIDIRR TO W-DIRECC
      *          PERFORM DIRECCION
      *       ELSE
      *       IF C45DI4 OF CLIDIRR NOT = SPACES THEN
      *          INITIALIZE W-DIRECC
      *          MOVE C45DI4 OF CLIDIRR TO W-DIRECC
      *          PERFORM DIRECCION
      *       ELSE
      *          MOVE "No Existe Dirección" TO DIREXT OF REPORTE-REG.

           MOVE AGCCTA OF REGMAEAHO     TO AGCORI OF REGAGCORI
           PERFORM LEER-PLTAGCORI
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF REGAGCORI     TO OFIEXT OF REPORTE-REG
              MOVE CODCIU OF REGAGCORI     TO CODCIU OF REGCIUDAD
              PERFORM LEER-PLTCIUDAD
              IF NOT ERROR-PLTCIUDAD THEN
                 MOVE NOMCIU OF REGCIUDAD TO CIUEXT OF REPORTE-REG
              ELSE
                 MOVE "Ciudad Inxistente" TO CIUEXT OF REPORTE-REG
           ELSE
              MOVE "Ciudad Inxistente"  TO CIUEXT OF REPORTE-REG
              MOVE "Oficina Inxistente" TO OFIEXT OF REPORTE-REG.

           MOVE AGCCTA OF REGMAEAHO TO AGEEXT OF REPORTE-REG
           MOVE CTANRO OF REGMAEAHO TO CTAEXT OF REPORTE-REG

           MOVE NITCTA OF REGMAEAHO TO NITCLI OF CLIMAEL01
           PERFORM LEER-CLIMAEL01
           IF NOT ERROR-CLIMAEL01 THEN
              IF TIPDOC OF CLIMAEL01  = 3 THEN
                 MOVE NITCTA OF REGMAEAHO TO NITEXT OF REPORTE-REG
              ELSE
                 INITIALIZE W-NIT
                 MOVE NITCTA OF REGMAEAHO TO W-NIT
                 MOVE W-NITESP TO NITEXT OF REPORTE-REG
           ELSE
             MOVE NITCTA OF REGMAEAHO TO NITEXT OF REPORTE-REG.

           WRITE REPORTE-REG FORMAT IS "FOOTER"
           INITIALIZE AUDIT-O
           MOVE W-AUDT              TO AUDEXT OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "AUDIT".
      *--------------------------------------------------------------*
       CALCULAR-FIN-MES.
           MOVE W-FECLIQ             TO W-FECHACTL-0
           MOVE W-FECHACTL-0         TO W-FECHACTL-1
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
           MOVE 2            TO LK219-TIPOPR
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3   TO W-FECHACTL-0.
      *----------------------------------------------------------------
       DIRECCION.
           IF W-BASURA = "%%" THEN
              MOVE W-NOMBRE TO DIREXT OF REPORTE-REG
           ELSE
              MOVE W-DIRECC TO DIREXT OF REPORTE-REG.
      *--------------------------------------------------------------*
       DESCRIPCION-MVTO.
           MOVE 0 TO CTL-CCACODTRN
           MOVE CODTRA OF ZONA-CCAHISTOR TO CODTRA OF REGCODTRN
           READ CCACODTRN INVALID KEY MOVE 1 TO CTL-CCACODTRN.
           IF NOT ERROR-CCACODTRN THEN
              MOVE NOLTRA OF REGCODTRN TO CONEXT OF REPORTE-REG
           ELSE
              MOVE "Descripción Inexistente" TO CONEXT OF REPORTE-REG.
      *--------------------------------------------------------------*
       CALCULAR-FEC-DOS-DIAS.
           MOVE LK-FECHA-HOY   TO LK219-FECHA1
           MOVE ZEROS    TO LK219-FECHA2
           MOVE ZEROS    TO LK219-FECHA3
           MOVE 1        TO LK219-TIPFMT
           MOVE 2        TO LK219-BASCLC
           MOVE 2        TO LK219-NRODIA
           MOVE 2        TO LK219-INDDSP
           MOVE 9        TO LK219-DIASEM
           MOVE SPACES   TO LK219-NOMDIA
           MOVE SPACES   TO LK219-NOMMES
           MOVE ZEROS    TO LK219-CODRET
           MOVE SPACES   TO LK219-MSGERR
           MOVE 3        TO LK219-TIPOPR
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO W-FECHA.
      *--------------------------------------------------------------*
       CALL-PLT219.
           CALL "PLT219" USING LK219-FECHA1
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
       TERMINAR.
           CLOSE REPORTE
                 CCAHISTOR
                 CCAHISTO1
                 CCAMAEAHO
                 CCAEXTRAS
                 CCATABLAS
                 CCACODTRN
                 CLIMAEL01
      *          CLIDIR
                 PLTAGCORI
                 PLTCIUDAD.
           STOP RUN.
