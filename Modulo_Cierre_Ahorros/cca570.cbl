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
       PROGRAM-ID.    CCA570.
       AUTHOR.        AMCW.
       DATE-WRITTEN.  NOVIEMBRE/2001.
      *--------------------------------------------------------------*
      * FUNCION: IMPRESION DE LOS REGISTROS DE MOVIMIENTO RECIBIDOS  *
      *          EN LAS INTERFACES.                                  *
      *--------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMOVRECI
               ASSIGN          TO DATABASE-CCAMOVRECI
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
           SELECT CCATABINT
               ASSIGN          TO DATABASE-CCATABINT
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT REPORTE
               ASSIGN          TO FORMATFILE-CCA570R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVRECI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMOVRECI.
           COPY DDS-ALL-FORMATS OF CCAMOVRECI.
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
       FD  CCATABINT
           LABEL RECORDS ARE STANDARD.
       01  REG-TABINT.                                                   IBM-CT
           COPY DDS-ALL-FORMATS OF CCATABINT.                             IBM-CT
      *
       FD  REPORTE
           LABEL RECORDS ARE STANDARD.
       01  REPORTE-REG.
           COPY DDS-ALL-FORMATS OF CCA570R.
      *                                                                 IBM-CT
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
           COPY CATABLASR1 OF CCACPY.
      *                                                                 IBM-CT
       01  CONTROLES.
           05  CTL-CCAMOVRECI           PIC 9(01) VALUE 0.
               88  ERROR-CCAMOVRECI               VALUE 1.
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
      *Variable para control acceso directo del Archivo CCATABINT.
       01  W-EXISTE-CCATABINT          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-CCATABINT                    VALUE 0.
           88  SI-EXISTE-CCATABINT                    VALUE 1.
      *--------------------------------------------------------------*
       01 W-EXISTE-PLTSUCURS           PIC 9 VALUE ZEROS.
          88 SI-EXISTE-PLTSUCURS       VALUE 0.
          88 NO-EXISTE-PLTSUCURS       VALUE 1.
      * -----------------------------------------
       01  W-CUENTA PIC 9(12) VALUE ZEROS.
       01  FILLER REDEFINES W-CUENTA.
           03 W-OFICTA PIC 9(04).
           03 W-NROCTA PIC 9(06).
      *    03 W-CODPRO PIC 99.
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
           05  W-AGEANT                PIC 9(05) VALUE ZEROS.
           05  W-FORIGEN               PIC 9(08) VALUE ZEROS.
           05  W-FECANT                PIC 9(08) VALUE ZEROS.
           05  W-CODPRO                PIC 9(03) VALUE ZEROS.
           05  W-PROANT                PIC 9(03) VALUE ZEROS.
           05  W-CODTRA                PIC 9(03) VALUE ZEROS.
           05  W-CODANT                PIC 9(03) VALUE ZEROS.
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
      *Variables totalizadoras.
       01  W-TDEBTRA                   PIC 9(13)V99.
       01  W-TCRETRA                   PIC 9(13)V99.
       01  W-TDEBPRO                   PIC 9(13)V99.
       01  W-TCREPRO                   PIC 9(13)V99.
       01  W-TDEBFEC                   PIC 9(13)V99.
       01  W-TCREFEC                   PIC 9(13)V99.
       01  W-TDEBAGE                   PIC 9(13)V99.
       01  W-TCREAGE                   PIC 9(13)V99.
       01  W-TDEBGRL                   PIC 9(13)V99.
       01  W-TCREGRL                   PIC 9(13)V99.
       01  W-NROREG                    PIC 9(6).
       01  W-REGPRO                    PIC 9(6).
       01  W-REGFEC                    PIC 9(6).
       01  W-REGAGE                    PIC 9(6).
       01  W-REGGRL                    PIC 9(6).
       01  W-DESINT                    PIC X(30)    VALUE SPACES.
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
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       77  W-USR                       PIC X(10).
       77  W-NOMARC                    PIC X(10).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING W-USR , W-NOMARC.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN INPUT  CCAMOVRECI
                       CCACODTRN
                       CCATABLAS
                       CCATABINT.
           OPEN INPUT  PLTAGCORI PLTSUCURS.
           OPEN OUTPUT REPORTE
           MOVE W-USR TO W-USRID
           CALL "CCA501" USING LK-CCAPARGEN.
           ACCEPT W-FECHA FROM DATE
           ACCEPT LK-FECHA-HOY FROM DATE
           IF ANO < 50 THEN
              MOVE 20 TO SIGLO
           ELSE
              MOVE 19 TO SIGLO.
           ACCEPT W-HORA  FROM TIME
           MOVE W-NOMARC      TO NOMARC OF REGTABINT
           PERFORM LEER-CCATABINT
           IF ( SI-EXISTE-CCATABINT )
              MOVE DESCRI OF REGTABINT  TO W-DESINT
           ELSE
              MOVE "Interfaz no definida" TO W-DESINT
           END-IF
           MOVE 1 TO CTL-OK
           MOVE ZEROS TO CTL-PROGRAMA
           MOVE ZEROS TO CTL-CCAMOVRECI
                         W-AGEANT
                         W-FECANT
                         W-PROANT
                         W-CODANT
           MOVE ZEROS TO W-NROREG
                         W-REGPRO
                         W-REGFEC
                         W-REGAGE
                         W-REGGRL
           MOVE ZEROS TO AGCCTA OF CCAMOVRECI
                         FORIGE OF CCAMOVRECI
                         CODPRO OF CCAMOVRECI
                         CODTRA OF CCAMOVRECI
                         CTANRO OF CCAMOVRECI
                         DEBCRE OF CCAMOVRECI
                         IMPORT OF CCAMOVRECI
           START CCAMOVRECI KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE 1     TO CTL-CCAMOVRECI.
           IF ERROR-CCAMOVRECI THEN
              PERFORM TERMINAR
           END-IF.
           PERFORM LEER-CCAMOVRECI UNTIL ERROR-CCAMOVRECI OR
                                          NOT ERROR-OK
           IF ERROR-CCAMOVRECI THEN
              MOVE 1 TO CTL-PROGRAMA
              MOVE LK-TRA004 TO NROBNV OF CCAMOVRECI
              WRITE REPORTE-REG FORMAT IS "FOOTER"
           ELSE
      *       PERFORM ABRIR-IMPRESION
              MOVE AGCCTA OF CCAMOVRECI TO W-AGEANT
              MOVE FORIGE OF CCAMOVRECI TO W-FECANT
              MOVE CODTRA OF CCAMOVRECI TO W-CODANT
              MOVE CODPRO OF CCAMOVRECI TO W-PROANT
              PERFORM IMPRIMIR-TITULOS.
      *----------------------------------------------------------------
       ABRIR-IMPRESION.
           MOVE NROBNV OF CCAMOVRECI TO CODSUC OF PLTSUCURS.
           MOVE NROBNV OF CCAMOVRECI TO W-CODSUC SUCANTE.
           MOVE ZEROS TO W-EXISTE-PLTSUCURS
           READ PLTSUCURS INVALID KEY
                MOVE 1 TO W-EXISTE-PLTSUCURS
           END-READ.
           IF (SI-EXISTE-PLTSUCURS)
              MOVE "CCA570R"          TO W-NOMARC1
              MOVE "CCA570R"          TO W-NOMARC2
              MOVE "CCA570R"          TO W-NOMARC5
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
           IF ( CODTRA OF CCAMOVRECI NOT = W-CODANT )
              PERFORM IMPRIMIR-TOT-TRANSAC
              MOVE CODTRA OF CCAMOVRECI TO W-CODANT
           END-IF
           IF ( CODPRO OF CCAMOVRECI NOT = W-PROANT )
              PERFORM IMPRIMIR-TOT-TRANSAC
              PERFORM IMPRIMIR-TOT-PRODUC
              MOVE CODTRA OF CCAMOVRECI TO W-CODANT
              MOVE CODPRO OF CCAMOVRECI TO W-PROANT
           END-IF
           IF ( FORIGE OF CCAMOVRECI NOT = W-FECANT )
              PERFORM IMPRIMIR-TOT-TRANSAC
              PERFORM IMPRIMIR-TOT-PRODUC
              PERFORM IMPRIMIR-TOT-FECHA
              MOVE CODTRA OF CCAMOVRECI TO W-CODANT
              MOVE CODPRO OF CCAMOVRECI TO W-PROANT
              MOVE FORIGE OF CCAMOVRECI TO W-FECANT
           END-IF
           IF ( AGCCTA OF CCAMOVRECI NOT = W-AGEANT )
              PERFORM IMPRIMIR-TOT-TRANSAC
              PERFORM IMPRIMIR-TOT-PRODUC
              PERFORM IMPRIMIR-TOT-FECHA
              PERFORM IMPRIMIR-AGENCIA
              PERFORM IMPRIMIR-TOT-AGENCIA
              MOVE AGCCTA OF CCAMOVRECI TO W-AGEANT
              MOVE FORIGE OF CCAMOVRECI TO W-FECANT
              MOVE CODPRO OF CCAMOVRECI TO W-PROANT
              MOVE CODTRA OF CCAMOVRECI TO W-CODANT
           END-IF
           IF W-CONTL > 60
                PERFORM IMPRIMIR-TITULOS
           END-IF
           IF ( DEBCRE OF CCAMOVRECI = 1 )
              ADD  IMPORT OF CCAMOVRECI TO W-TDEBTRA
              ADD  IMPORT OF CCAMOVRECI TO W-TDEBPRO
              ADD  IMPORT OF CCAMOVRECI TO W-TDEBFEC
              ADD  IMPORT OF CCAMOVRECI TO W-TDEBAGE
              ADD  IMPORT OF CCAMOVRECI TO W-TDEBGRL
           ELSE
              ADD  IMPORT OF CCAMOVRECI TO W-TCRETRA
              ADD  IMPORT OF CCAMOVRECI TO W-TCREPRO
              ADD  IMPORT OF CCAMOVRECI TO W-TCREFEC
              ADD  IMPORT OF CCAMOVRECI TO W-TCREAGE
              ADD  IMPORT OF CCAMOVRECI TO W-TCREGRL
           END-IF
           ADD  1          TO W-NROREG
           ADD  1          TO W-REGPRO
           ADD  1          TO W-REGFEC
           ADD  1          TO W-REGAGE
           ADD  1          TO W-REGGRL
           MOVE 1 TO CTL-OK
           PERFORM LEER-CCAMOVRECI UNTIL ERROR-CCAMOVRECI OR
                                            NOT ERROR-OK
           IF ( ERROR-CCAMOVRECI )
              PERFORM IMPRIMIR-AGENCIA
              PERFORM IMPRIMIR-TOT-AGENCIA
              PERFORM COLOCAR-TOTALES-GLOBALES
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       LEER-CCAMOVRECI.
           MOVE 0 TO CTL-CCAMOVRECI
           READ CCAMOVRECI NEXT RECORD AT END
                            MOVE 1 TO CTL-CCAMOVRECI.
           IF NOT ERROR-CCAMOVRECI THEN
      *       IF CODER1 OF CCAMOVRECI NOT = ZEROS OR
      *          CODER2 OF CCAMOVRECI NOT = ZEROS OR
      *          CODER3 OF CCAMOVRECI NOT = ZEROS THEN
                 MOVE 0 TO CTL-OK.
      *--------------------------------------------------------------*
       IMPRIMIR-TITULOS.
           INITIALIZE HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA570    "      TO NROPRO  OF HEADER-O
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF HEADER-O
           MOVE W-PAGINA          TO PAGNRO  OF HEADER-O
           MOVE W-DESINT          TO NOMLIS  OF HEADER-O
           MOVE HORA              TO HORPRO  OF HEADER-O
           MOVE W-FECHA           TO FECSYS  OF HEADER-O
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
           MOVE W-AGEANT  TO AGCORI OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE W-AGEANT              TO AGEN  OF AGENCIA-O
              MOVE NOMAGC OF PLTAGCORI   TO DEAGE OF AGENCIA-O
           ELSE
              MOVE W-AGEANT              TO AGEN  OF AGENCIA-O
              MOVE "Agencia Inexistente" TO DEAGE OF AGENCIA-O.
      *--------------------------------------------------------------*
       IMPRIMIR-TOT-TRANSAC.
           INITIALIZE DETALLE-O
           MOVE W-FECANT             TO FORIGEN OF DETALLE-O
           MOVE W-PROANT             TO CODPRO  OF DETALLE-O
           MOVE W-CODANT             TO CODTRN  OF DETALLE-O
                                        CODTRA  OF REGCODTRN
           PERFORM LEER-CCACODTRN
           IF ( NO-EXISTE-CCACODTRN )
              MOVE "Transacción no definida "
                                   TO NOMTRN  OF DETALLE-O
           ELSE
              MOVE NOLTRA OF REGCODTRN
                                   TO NOMTRN  OF DETALLE-O
           END-IF
           MOVE W-NROREG       TO NROTRN OF DETALLE-O
           MOVE W-TDEBTRA      TO IMPDEB OF DETALLE-O
           MOVE W-TCRETRA      TO IMPCRE OF DETALLE-O
           WRITE REPORTE-REG FORMAT IS "DETALLE"
           ADD  1       TO W-CONTL.
           MOVE 0            TO W-TDEBTRA
                                W-TCRETRA
                                W-NROREG.
      *--------------------------------------------------------------*
       IMPRIMIR-TOT-FECHA.
           INITIALIZE AGENCIA-O
           MOVE "TOTAL FECHA"  TO DESTOT OF TOTDEB-O
           MOVE W-REGFEC       TO NROREG OF TOTDEB-O
           MOVE W-TDEBFEC      TO TOTDB  OF TOTDEB-O
           MOVE W-TCREFEC      TO TOTCR  OF TOTDEB-O
           WRITE REPORTE-REG FORMAT IS "TOTDEB"
           ADD  3       TO W-CONTL.
           MOVE 0            TO W-TDEBFEC
                                W-TCREFEC
                                W-REGFEC.
      *--------------------------------------------------------------*
       IMPRIMIR-TOT-PRODUC.
           INITIALIZE AGENCIA-O
           MOVE "TOTAL PRODUCTO"  TO DESTOT OF TOTDEB-O
           MOVE W-REGPRO     TO NROREG OF TOTDEB-O
           MOVE W-TDEBPRO    TO TOTDB  OF TOTDEB-O
           MOVE W-TCREPRO    TO TOTCR  OF TOTDEB-O
           WRITE REPORTE-REG FORMAT IS "TOTDEB"
           ADD  3       TO W-CONTL.
           MOVE 0            TO W-TDEBPRO
                                W-TCREPRO
                                W-REGPRO.
      *--------------------------------------------------------------*
       IMPRIMIR-TOT-AGENCIA.
           INITIALIZE AGENCIA-O
           MOVE "TOTAL AGENCIA"  TO DESTOT OF TOTDEB-O
           MOVE W-REGAGE         TO NROREG OF TOTDEB-O
           MOVE W-TDEBAGE        TO TOTDB  OF TOTDEB-O
           MOVE W-TCREAGE        TO TOTCR  OF TOTDEB-O
           WRITE REPORTE-REG FORMAT IS "TOTDEB"
           WRITE REPORTE-REG FORMAT IS "FIRMA"
           ADD  3       TO W-CONTL.
           MOVE 0            TO W-TDEBAGE
                                W-TCREAGE
                                W-REGAGE.
      *--------------------------------------------------------------*
       COLOCAR-TOTALES-GLOBALES.
           MOVE W-TDEBGRL TO TOTOTDB OF TOTTOT-O
           MOVE W-TCREGRL TO TOTOTCR OF TOTTOT-O
           WRITE REPORTE-REG FORMAT IS "TOTTOT"
           WRITE REPORTE-REG FORMAT IS "FOOTER".
      *--------------------------------------------------------------*
       VALIDAR-AGENCIA.
           IF AGCCTA OF CCAMOVRECI NOT > 9999 THEN
              IF EXISTE(AGCCTA OF CCAMOVRECI) NOT = 1 THEN
                 MOVE 9000               TO W-AGENCIA
                 MOVE 9000               TO W-CODSUC
              ELSE
                 MOVE AGCCTA OF CCAMOVRECI TO W-AGENCIA
                 MOVE NROBNV OF CCAMOVRECI TO W-CODSUC
           ELSE
              MOVE 9000                  TO W-CODSUC
              MOVE 9000                  TO W-AGENCIA.
      *--------------------------------------------------------------*
       NOMBRE-AGENCIA.
           MOVE 0 TO CTL-PLTAGCORI
           MOVE I TO AGCORI OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF PLTAGCORI     TO TDESAGE OF REPORTE-REG
           ELSE
              MOVE "AGENCIA INEXISTENTE" TO TDESAGE OF REPORTE-REG.
      *----------------------------------------------------------------
      * Procedimiento : Leer-CCAcodtrn.                                  |
      * Descripcion   : Se lee un Código de transacción.              |
      *----------------------------------------------------------------
      *
       LEER-CCACODTRN.
           MOVE 1                      TO W-EXISTE-CCACODTRN
           READ CCACODTRN              INVALID KEY
                                       MOVE 0 TO W-EXISTE-CCACODTRN
           END-READ.
      *--------------------------------------------------------------*
       LEER-CCATABINT.
           MOVE 1                      TO W-EXISTE-CCATABINT.
           READ CCATABINT              INVALID KEY
              MOVE 0                   TO W-EXISTE-CCATABINT.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE CCAMOVRECI    PLTSUCURS
                 CCACODTRN     CCATABINT
                 CCATABLAS     REPORTE
                 PLTAGCORI.
           GOBACK.
