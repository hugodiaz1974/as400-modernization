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
       PROGRAM-ID.    CCA640.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: GENERACION DEL REPORTE DIARIO DE CAUSACION.         *
      *--------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCACAUHOY
               ASSIGN          TO DATABASE-CCACAUHOY
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT REPORTE
               ASSIGN          TO FORMATFILE-CCA640R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCACAUHOY
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACAUHOY.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *                                                                 IBM-CT
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *                                                                 IBM-CT
       FD  REPORTE
           LABEL RECORDS ARE STANDARD.
       01  REPORTE-REG.
           COPY DDS-ALL-FORMATS OF CCA640R.
      *                                                                 IBM-CT
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCACAUHOY            PIC 9(01)  VALUE 0.
               88  ERROR-CCACAUHOY                 VALUE 1.
           05  CTL-SIIF01              PIC 9(01)  VALUE 0.
               88  ERROR-SIIF01                   VALUE 1.
           05  CTL-PLTAGCORI              PIC 9(01)  VALUE 0.
               88  ERROR-PLTAGCORI                   VALUE 1.
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
           05  W-PAGINA                PIC 9(06)     VALUE ZEROS.
           05  TOT-AGENCIA             PIC S9(15)V99 VALUE ZEROS.
           05  TOT-CONSOL              PIC S9(15)V99 VALUE ZEROS.
      *--------------------------------------------------------------*
           COPY EXTRACT OF CCACPY.
           COPY PARGEN  OF CCACPY.
           COPY FECHAS  OF CCACPY.
       01  PA-CODEMP                   PIC 9(05)    VALUE ZEROS.
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       77  W-USRING                    PIC  X(10).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING W-USRING.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           CALL "PLTCODEMPP"                USING PA-CODEMP
           CALL "CCA500" USING LK-FECHAS                                A
           CALL "CCA501" USING LK-CCAPARGEN.
           OPEN OUTPUT REPORTE
           OPEN INPUT  CCACAUHOY
                       PLTAGCORI.
           MOVE W-USRING  TO W-USRID
           CALL "EXTRACT" USING W-DA EX-DATE.
           MOVE EX-DATE-8              TO W-FECHA
           ACCEPT W-HORA  FROM TIME
           PERFORM LEER-CCACAUHOY
           IF ERROR-CCACAUHOY THEN
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA
           ELSE
              PERFORM COLOCAR-TITULOS
              MOVE AGCCTA OF ZONA-CCACAUHOY TO AGEANT.
      *--------------------------------------------------------------*
       PROCESAR.
           IF AGCCTA OF ZONA-CCACAUHOY NOT = AGEANT THEN
              ADD TOT-AGENCIA TO TOT-CONSOL
              PERFORM IMPRIMIR-DETALLE
              INITIALIZE TOT-AGENCIA
              MOVE AGCCTA OF ZONA-CCACAUHOY TO AGEANT.
           PERFORM PROCESAR-REGISTRO
           PERFORM LEER-CCACAUHOY
           IF ERROR-CCACAUHOY THEN
              ADD TOT-AGENCIA TO TOT-CONSOL
              PERFORM IMPRIMIR-DETALLE
              PERFORM COLOCAR-TOTALES
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       PROCESAR-REGISTRO.
           IF CODTRA OF ZONA-CCACAUHOY = LK-TRAREV OR
              CODTRA OF ZONA-CCACAUHOY = LK-TRACAU OR
              CODTRA OF ZONA-CCACAUHOY = LK-TRAAJU THEN
              IF DEBCRE OF ZONA-CCACAUHOY = 1 THEN
                 COMPUTE TOT-AGENCIA =
                         TOT-AGENCIA - IMPORT OF ZONA-CCACAUHOY
              ELSE
                 COMPUTE TOT-AGENCIA =
                         TOT-AGENCIA + IMPORT OF ZONA-CCACAUHOY.
      *--------------------------------------------------------------*
       COLOCAR-TITULOS.
           INITIALIZE HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA640    "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "*** REPORTE DE LA CAUSACION DIARIA POR AGENCIA  **"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
                                     FECDIA  OF REPORTE-REG
           MOVE HORA              TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER"
           WRITE REPORTE-REG FORMAT IS "TITULOS".
      *--------------------------------------------------------------*
       IMPRIMIR-DETALLE.
           MOVE AGEANT TO AGCORI OF PLTAGCORI
                          CODIGO OF REPORTE-REG
           MOVE PA-CODEMP        TO CODEMP OF PLTAGCORI
           PERFORM LEER-PLTAGCORI
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF PLTAGCORI     TO DESAGE OF REPORTE-REG
           ELSE
              MOVE "AGENCIA INCORRECTA" TO DESAGE OF REPORTE-REG.
           MOVE TOT-AGENCIA TO VALOR OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "DETALLE" AT EOP
                 PERFORM COLOCAR-TITULOS.
      *--------------------------------------------------------------*
       COLOCAR-TOTALES.
           INITIALIZE TOTALES-O
           MOVE TOT-CONSOL TO TOTCRE OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "TOTALES" AT EOP
                 PERFORM COLOCAR-TITULOS.
      *--------------------------------------------------------------*
       LEER-PLTAGCORI.
           MOVE 0   TO CTL-PLTAGCORI
           MOVE PA-CODEMP        TO CODEMP OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
      *--------------------------------------------------------------*
       LEER-CCACAUHOY.
           MOVE 0 TO CTL-CCACAUHOY
           READ CCACAUHOY NEXT RECORD AT END MOVE 1 TO CTL-CCACAUHOY.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE REPORTE
                 CCACAUHOY
                 PLTAGCORI.
           STOP RUN.
