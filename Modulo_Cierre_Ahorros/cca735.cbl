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
       PROGRAM-ID.    CCA735.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: GENERACION DEL REPORTE DE SALDOS DE AHORROS.        *
      *--------------------------------------------------------------*
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
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT REPORTE
               ASSIGN          TO FORMATFILE-CCA735R1
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT REPORT1
               ASSIGN          TO FORMATFILE-CCA735R2
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *                                                                 IBM-CT
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *                                                                 IBM-CT
       FD  REPORTE
           LABEL RECORDS ARE STANDARD.
       01  REPORTE-REG.
           COPY DDS-ALL-FORMATS OF CCA735R.
      *                                                                 IBM-CT
       FD  REPORT1
           LABEL RECORDS ARE STANDARD.
       01  REPORT1-REG.
           COPY DDS-ALL-FORMATS OF CCA735R.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCAMAEAHO           PIC 9(01)  VALUE 0.
               88  ERROR-CCAMAEAHO                VALUE 1.
           05  CTL-PLTAGCORI           PIC 9(01)  VALUE 0.
               88  ERROR-PLTAGCORI                VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01)  VALUE 0.
               88  FIN-PROGRAMA                   VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  AGEANT                  PIC 9(05)    VALUE ZEROS.
           05  W-HORA                  PIC 9(08)    VALUE ZEROS.
           05  RED-W-HORA              REDEFINES W-HORA.
               10 HORA                 PIC 9(06).
               10 FILLER               PIC 9(02).
           05  W-USRID                 PIC X(10)    VALUE SPACES.
           05  W-FECHA                 PIC  9(08)   VALUE ZEROS.
           05  RED-W-FECHA             REDEFINES W-FECHA.
               10 SIGLO                PIC 9(02).
               10 ANO                  PIC 9(02).
               10 MES                  PIC 9(02).
               10 DIA                  PIC 9(02).
           05  W-PAGINA                PIC 9(06)    VALUE ZEROS.
           05  W-PAGINC                PIC 9(06)    VALUE ZEROS.
           05  TOT-AGENOR              PIC 9(15)V99 VALUE ZEROS.
           05  TOT-AGECUS              PIC 9(15)V99 VALUE ZEROS.
      *--------------------------------------------------------------*
           COPY EXTRACT OF CCACPY.
           COPY PARGEN  OF CCACPY.
           COPY FECHAS  OF CCACPY.
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       77  W-USRING                      PIC  X(10).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING W-USRING.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN OUTPUT REPORTE
                       REPORT1
           OPEN INPUT  CCAMAEAHO
                       PLTAGCORI.
           MOVE W-USRING TO W-USRID
           PERFORM CALL-CCA501
           CALL "EXTRACT" USING W-DA EX-DATE.
           MOVE EX-DATE-8              TO W-FECHA
           ACCEPT W-HORA  FROM TIME
           PERFORM CALL-CCA500.
           PERFORM LEER-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              WRITE REPORT1-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA
           ELSE
              PERFORM COLOCAR-TITULOS-N
              PERFORM COLOCAR-TITULOS-C
              PERFORM COLOCAR-AGENCIA-N
              PERFORM COLOCAR-AGENCIA-C
              MOVE AGCCTA OF REGMAEAHO TO AGEANT.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.

      *--------------------------------------------------------------*
       PROCESAR.
           IF AGCCTA OF REGMAEAHO NOT = AGEANT THEN
              PERFORM COLOCAR-TOTALES-N
              PERFORM COLOCAR-TOTALES-C
              PERFORM COLOCAR-TITULOS-N
              PERFORM COLOCAR-TITULOS-C
              PERFORM COLOCAR-AGENCIA-N
              PERFORM COLOCAR-AGENCIA-C
              INITIALIZE TOT-AGENOR TOT-AGECUS
              MOVE AGCCTA OF REGMAEAHO TO AGEANT.
           PERFORM PROCESAR-REGISTRO
           PERFORM LEER-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              PERFORM COLOCAR-TOTALES-N
              PERFORM COLOCAR-TOTALES-C
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              WRITE REPORT1-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       PROCESAR-REGISTRO.
           IF NOT ERROR-CCAMAEAHO THEN
              IF INDBAJ OF REGMAEAHO = ZEROS THEN
                 IF INDEMB OF REGMAEAHO = ZEROS AND
                    INDBLO OF REGMAEAHO = ZEROS AND
                    INDINA OF REGMAEAHO = ZEROS AND
                    INDFAL OF REGMAEAHO = ZEROS THEN
                    PERFORM IMPRIMIR-NORMAL
                    ADD SALULR OF REGMAEAHO TO TOT-AGENOR
                 ELSE
                    PERFORM IMPRIMIR-CUSTODIAS
                    ADD SALULR OF REGMAEAHO TO TOT-AGECUS.
      *--------------------------------------------------------------*
       IMPRIMIR-NORMAL.
           INITIALIZE DETALLE-O OF REPORTE-REG
           MOVE CTANRO OF REGMAEAHO TO NROCTA OF REPORTE-REG
           MOVE DESCRI OF REGMAEAHO TO NOMCLI OF REPORTE-REG
           IF NITCTA OF REGMAEAHO NOT = ZEROS THEN
              MOVE NITCTA OF REGMAEAHO TO NITCLI OF REPORTE-REG
           ELSE
           IF NITCT2 OF REGMAEAHO NOT = ZEROS THEN
              MOVE NITCT2 OF REGMAEAHO TO NITCLI OF REPORTE-REG
           ELSE
           IF NITCT3 OF REGMAEAHO NOT = ZEROS THEN
              MOVE NITCT3 OF REGMAEAHO TO NITCLI OF REPORTE-REG.
           MOVE SALULR OF REGMAEAHO TO SALCIER OF REPORTE-REG
           INITIALIZE EMB  OF REPORTE-REG
                      BLOQ OF REPORTE-REG
                      INAC OF REPORTE-REG
                      FALL OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "DETALLE" AT EOP
                 PERFORM COLOCAR-TITULOS-N
                 PERFORM COLOCAR-AGENCIA-N.
      *--------------------------------------------------------------*
       IMPRIMIR-CUSTODIAS.
           INITIALIZE DETALLE-O OF REPORT1-REG
           MOVE CTANRO OF REGMAEAHO TO NROCTA OF REPORT1-REG
           MOVE DESCRI OF REGMAEAHO TO NOMCLI OF REPORT1-REG
           IF NITCTA OF REGMAEAHO NOT = ZEROS THEN
              MOVE NITCTA OF REGMAEAHO TO NITCLI OF REPORT1-REG
           ELSE
           IF NITCT2 OF REGMAEAHO NOT = ZEROS THEN
              MOVE NITCT2 OF REGMAEAHO TO NITCLI OF REPORT1-REG
           ELSE
           IF NITCT3 OF REGMAEAHO NOT = ZEROS THEN
              MOVE NITCT3 OF REGMAEAHO TO NITCLI OF REPORT1-REG.
           MOVE SALULR OF REGMAEAHO TO SALCIER OF REPORT1-REG
           IF INDEMB OF REGMAEAHO NOT = ZEROS THEN
              MOVE INDEMB OF REGMAEAHO TO EMB  OF REPORT1-REG.
           IF INDBLO OF REGMAEAHO NOT = ZEROS THEN
              MOVE INDBLO OF REGMAEAHO TO BLOQ OF REPORT1-REG.
           IF INDINA OF REGMAEAHO NOT = ZEROS THEN
              MOVE INDINA OF REGMAEAHO TO INAC OF REPORT1-REG.
           IF INDFAL OF REGMAEAHO NOT = ZEROS THEN
              MOVE INDFAL OF REGMAEAHO TO FALL OF REPORT1-REG.
           WRITE REPORT1-REG FORMAT IS "DETALLE" AT EOP
                 PERFORM COLOCAR-TITULOS-C
                 PERFORM COLOCAR-AGENCIA-C.
      *--------------------------------------------------------------*
       COLOCAR-TITULOS-N.
           INITIALIZE HEADER-O OF REPORTE-REG
           ADD  1                 TO W-PAGINA
           MOVE "CCA735IA  "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "*** REPORTE DE SALDOS DE AHORRO CUENTAS ACTIVAS **"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
           MOVE HORA              TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER".
      *--------------------------------------------------------------*
       COLOCAR-TITULOS-C.
           INITIALIZE HEADER-O OF REPORT1-REG
           ADD  1                 TO W-PAGINC
           MOVE "CCA735IB  "      TO NROPRO  OF REPORT1-REG
           MOVE W-USRID           TO USER    OF REPORT1-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORT1-REG
           MOVE W-PAGINC          TO PAGNRO  OF REPORT1-REG
           MOVE "***  REP. SALDOS DE AHORRO CUENTAS EN CUSTODIA  **"
                                  TO NOMLIS  OF REPORT1-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORT1-REG
           MOVE HORA              TO HORPRO  OF REPORT1-REG
           MOVE W-FECHA           TO FECSYS  OF REPORT1-REG
           WRITE REPORT1-REG FORMAT IS "HEADER".
      *--------------------------------------------------------------*
       COLOCAR-AGENCIA-N.
           INITIALIZE AGENCIA-O OF REPORTE-REG
           MOVE AGCCTA OF REGMAEAHO  TO AGEN OF REPORTE-REG
                                        AGCORI OF REGAGCORI
           PERFORM LEER-PLTAGCORI
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF REGAGCORI  TO DEAGE OF REPORTE-REG
           ELSE
              MOVE "AGENCIA INCORRECTA" TO DEAGE OF REPORTE-REG.
           WRITE REPORTE-REG FORMAT IS "AGENCIA"
           WRITE REPORTE-REG FORMAT IS "TITULOS".
      *--------------------------------------------------------------*
       COLOCAR-AGENCIA-C.
           INITIALIZE AGENCIA-O OF REPORT1-REG
           MOVE AGCCTA OF REGMAEAHO  TO AGEN OF REPORT1-REG
                                        AGCORI OF REGAGCORI
           PERFORM LEER-PLTAGCORI
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF PLTAGCORI  TO DEAGE OF REPORT1-REG
           ELSE
              MOVE "AGENCIA INCORRECTA" TO DEAGE OF REPORT1-REG.
           WRITE REPORT1-REG FORMAT IS "AGENCIA"
           WRITE REPORT1-REG FORMAT IS "TITULOS".
      *--------------------------------------------------------------*
       COLOCAR-TOTALES-N.
           INITIALIZE TOTALES-O OF REPORTE-REG
           MOVE TOT-AGENOR TO TOTOFI OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "TOTALES" AT EOP
                 PERFORM COLOCAR-TITULOS-N
                 PERFORM COLOCAR-AGENCIA-N.
      *--------------------------------------------------------------*
       COLOCAR-TOTALES-C.
           INITIALIZE TOTALES-O OF REPORT1-REG
           MOVE TOT-AGECUS TO TOTOFI OF REPORT1-REG
           WRITE REPORT1-REG FORMAT IS "TOTALES" AT EOP
                 PERFORM COLOCAR-TITULOS-C
                 PERFORM COLOCAR-AGENCIA-C.
      *--------------------------------------------------------------*
       LEER-PLTAGCORI.
           MOVE 0   TO CTL-PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
      *--------------------------------------------------------------*
       LEER-CCAMAEAHO.
           MOVE 0 TO CTL-CCAMAEAHO
           READ CCAMAEAHO NEXT RECORD AT END MOVE 1 TO CTL-CCAMAEAHO.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE REPORTE
                 REPORT1
                 CCAMAEAHO
                 PLTAGCORI.
           STOP RUN.
