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
       PROGRAM-ID.    CCA755.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: RESUMEN MENSUAL/REPORTE GENERAL DE CUENTAS          *
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
               ASSIGN          TO FORMATFILE-CCA755R
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
           COPY DDS-ALL-FORMATS OF CCA755R.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC 9(01)  VALUE 0.
               88  ERROR-CCAMAEAHO                 VALUE 1.
           05  CTL-PLTAGCORI              PIC 9(01)  VALUE 0.
               88  ERROR-PLTAGCORI                   VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01)  VALUE 0.
               88  FIN-PROGRAMA                   VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
      *--------------------------------------------------------------*
           05  AGEANT                  PIC 9(05)    VALUE ZEROS.
           05  W-HORA                  PIC 9(08)    VALUE ZEROS.
           05  RED-W-HORA              REDEFINES    W-HORA.
               10 HORA                 PIC 9(06).
               10 FILLER               PIC 9(02).
           05  W-USRID                 PIC X(10)    VALUE SPACES.
           05  W-FECHA                 PIC 9(08)    VALUE ZEROS.
           05  RED-W-FECHA             REDEFINES    W-FECHA.
               10 SIGLO                PIC 9(02).
               10 ANO                  PIC 9(02).
               10 MES                  PIC 9(02).
               10 DIA                  PIC 9(02).
           05  W-PAGINA                PIC 9(06)     VALUE ZEROS.
           05  W-FECLIQ                PIC 9(08)     VALUE ZEROS.
           05  RED-W-FECLIQ            REDEFINES     W-FECLIQ.
               10 ANOLIQ               PIC 9(04).
               10 MESLIQ               PIC 9(02).
               10 DIALIQ               PIC 9(02).
           05  W-FECAPE                PIC 9(08)     VALUE ZEROS.
           05  RED-W-FECAPE            REDEFINES     W-FECAPE.
               10 ANOAPE               PIC 9(04).
               10 MESAPE               PIC 9(02).
               10 DIAAPE               PIC 9(02).
           05  W-FECCIE                PIC 9(08)     VALUE ZEROS.
           05  RED-W-FECCIE            REDEFINES     W-FECCIE.
               10 ANOCIE               PIC 9(04).
               10 MESCIE               PIC 9(02).
               10 DIACIE               PIC 9(02).
      *--------------------------------------------------------------*
           05  W-SALULR                PIC 9(15)V99  VALUE ZEROS.
           05  W-SALPUR                PIC 9(15)V99  VALUE ZEROS.
           05  W-CANCEL                PIC 9(06)     VALUE ZEROS.
           05  W-NUEVAS                PIC 9(06)     VALUE ZEROS.
           05  W-MESANT                PIC 9(06)     VALUE ZEROS.
           05  W-NVOSAL                PIC 9(06)     VALUE ZEROS.
           05  W-INACT                 PIC 9(06)     VALUE ZEROS.
           05  W-EMBAR                 PIC 9(06)     VALUE ZEROS.
           05  W-FALLE                 PIC 9(06)     VALUE ZEROS.
           05  W-BLOQU                 PIC 9(06)     VALUE ZEROS.
           05  W-ACTIV                 PIC 9(06)     VALUE ZEROS.
      *--------------------------------------------------------------*
           05  T-SALULR                PIC 9(15)V99  VALUE ZEROS.
           05  T-SALPUR                PIC 9(15)V99  VALUE ZEROS.
           05  T-CANCEL                PIC 9(06)     VALUE ZEROS.
           05  T-NUEVAS                PIC 9(06)     VALUE ZEROS.
           05  T-MESANT                PIC 9(06)     VALUE ZEROS.
           05  T-NVOSAL                PIC 9(06)     VALUE ZEROS.
           05  T-INACT                 PIC 9(06)     VALUE ZEROS.
           05  T-EMBAR                 PIC 9(06)     VALUE ZEROS.
           05  T-FALLE                 PIC 9(06)     VALUE ZEROS.
           05  T-BLOQU                 PIC 9(06)     VALUE ZEROS.
           05  T-ACTIV                 PIC 9(06)     VALUE ZEROS.
       01  PA-CODEMP                   PIC 9(05)     VALUE ZEROS.
      *--------------------------------------------------------------*
           COPY EXTRACT OF CCACPY.
           COPY PARGEN  OF CCACPY.
           COPY FECHAS  OF CCACPY.
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       77  L-USER                      PIC  X(10).
       77  L-FECLIQ                    PIC  9(08).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING L-USER L-FECLIQ.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN OUTPUT REPORTE
                INPUT  CCAMAEAHO
                       PLTAGCORI.
           CALL "PLTCODEMPP"           USING PA-CODEMP
           CALL "EXTRACT" USING W-DA EX-DATE.
           MOVE EX-DATE-8              TO W-FECHA
           PERFORM CALL-CCA501
           ACCEPT W-HORA  FROM TIME
           PERFORM CALL-CCA500
           MOVE L-USER   TO W-USRID
           MOVE L-FECLIQ TO W-FECLIQ
           PERFORM LEER-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              PERFORM COLOCAR-TITULOS
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA
           ELSE
              MOVE AGCCTA OF REGMAEAHO TO AGEANT
              PERFORM COLOCAR-TITULOS.
      *---------------------------------------------------------------*
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
      *---------------------------------------------------------------*
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.

      *---------------------------------------------------------------*
       PROCESAR.
           IF AGCCTA OF REGMAEAHO NOT = AGEANT THEN
              PERFORM IMPRIMIR-DETALLE
              MOVE AGCCTA OF REGMAEAHO TO AGEANT.
           PERFORM PROCESAR-REGISTRO
           PERFORM LEER-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              PERFORM IMPRIMIR-DETALLE
              PERFORM COLOCAR-TOTALES
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       PROCESAR-REGISTRO.
           IF AGCCTA OF REGMAEAHO = AGEANT THEN
              IF INDBAJ OF REGMAEAHO = ZEROS THEN
                 INITIALIZE W-FECAPE
                 MOVE FAPERT OF REGMAEAHO TO W-FECAPE
                 ADD SALULR  OF REGMAEAHO TO W-SALULR
                 ADD SALPUR  OF REGMAEAHO TO W-SALPUR
                 PERFORM REVISAR-CUSTODIAS
              ELSE
              INITIALIZE W-FECCIE
              MOVE FCIERR OF REGMAEAHO TO W-FECCIE
              IF MESCIE = MESLIQ THEN
                 ADD SALULR OF REGMAEAHO TO W-SALULR
                 ADD SALPUR OF REGMAEAHO TO W-SALPUR
                 ADD 1                   TO W-CANCEL.
      *--------------------------------------------------------------*
       REVISAR-CUSTODIAS.
           IF MESAPE = MESLIQ THEN
              ADD 1 TO W-NUEVAS
           ELSE
              ADD 1 TO W-MESANT.
           IF INDINA OF REGMAEAHO = 1 THEN
              ADD 1 TO W-INACT
           ELSE
           IF INDEMB OF REGMAEAHO = 1 THEN
              ADD 1 TO W-EMBAR
           ELSE
           IF INDFAL OF REGMAEAHO = 1 THEN
              ADD 1 TO W-FALLE
           ELSE
           IF INDBLO OF REGMAEAHO NOT = ZEROS THEN
              ADD 1 TO W-BLOQU
           ELSE
              ADD 1 TO W-ACTIV.
      *--------------------------------------------------------------*
       LEER-CCAMAEAHO.
           MOVE 0 TO CTL-CCAMAEAHO
           READ CCAMAEAHO NEXT RECORD AT END MOVE 1 TO CTL-CCAMAEAHO.
      *--------------------------------------------------------------*
       LEER-PLTAGCORI.
           MOVE 0   TO CTL-PLTAGCORI
           MOVE PA-CODEMP         TO CODEMP OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
      *--------------------------------------------------------------*
       COLOCAR-TITULOS.
           INITIALIZE             HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA755    "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "***         RESUMEN GENERAL DE CUENTAS         ***"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
           MOVE HORA              TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER"
           WRITE REPORTE-REG FORMAT IS "TITULOS".
      *--------------------------------------------------------------*
       IMPRIMIR-DETALLE.
           INITIALIZE DETALLE-O
           MOVE AGEANT              TO CODAGE  OF REPORTE-REG
           PERFORM NOMBRE-AGENCIA
           MOVE W-SALPUR            TO SALANT  OF REPORTE-REG
           MOVE W-SALULR            TO VALNSA  OF REPORTE-REG
           MOVE W-MESANT            TO MESANT  OF REPORTE-REG
           MOVE W-NUEVAS            TO NUEVA   OF REPORTE-REG
           MOVE W-CANCEL            TO CANCE   OF REPORTE-REG
           INITIALIZE W-NVOSAL
           COMPUTE W-NVOSAL = (W-MESANT + W-NUEVAS) - W-CANCEL
           MOVE W-NVOSAL            TO NVOSAL  OF REPORTE-REG

           MOVE W-ACTIV             TO ACTIVAS OF REPORTE-REG
           MOVE W-INACT             TO INACT   OF REPORTE-REG
           MOVE W-EMBAR             TO EMBAR   OF REPORTE-REG
           MOVE W-FALLE             TO FALLE   OF REPORTE-REG
           MOVE W-BLOQU             TO BLOQ    OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "DETALLE" AT EOP
                 PERFORM COLOCAR-TITULOS.
           ADD W-SALPUR TO T-SALPUR
           ADD W-SALULR TO T-SALULR
           ADD W-MESANT TO T-MESANT
           ADD W-NUEVAS TO T-NUEVAS
           ADD W-CANCEL TO T-CANCEL
           ADD W-NVOSAL TO T-NVOSAL
           ADD W-ACTIV  TO T-ACTIV
           ADD W-INACT  TO T-INACT
           ADD W-EMBAR  TO T-EMBAR
           ADD W-FALLE  TO T-FALLE
           ADD W-BLOQU  TO T-BLOQU
           INITIALIZE W-SALPUR
                      W-SALULR
                      W-MESANT
                      W-NUEVAS
                      W-CANCEL
                      W-NVOSAL
                      W-ACTIV
                      W-INACT
                      W-EMBAR
                      W-FALLE
                      W-BLOQU.
      *--------------------------------------------------------------*
       COLOCAR-TOTALES.
           INITIALIZE               TOTALES-O
           MOVE T-SALPUR            TO TSALANT  OF REPORTE-REG
           MOVE T-SALULR            TO TVALNSA  OF REPORTE-REG
           MOVE T-MESANT            TO TMESANT  OF REPORTE-REG
           MOVE T-NUEVAS            TO TNUEVA   OF REPORTE-REG
           MOVE T-CANCEL            TO TCANCEL  OF REPORTE-REG
           MOVE T-NVOSAL            TO TNVOSAL  OF REPORTE-REG

           MOVE T-ACTIV             TO TACTIVAS OF REPORTE-REG
           MOVE T-INACT             TO TINACT   OF REPORTE-REG
           MOVE T-EMBAR             TO TEMBAR   OF REPORTE-REG
           MOVE T-FALLE             TO TFALLE   OF REPORTE-REG
           MOVE T-BLOQU             TO TBLOQ    OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "TOTALES" AT EOP
                 PERFORM COLOCAR-TITULOS.
      *--------------------------------------------------------------*
       NOMBRE-AGENCIA.
           MOVE AGEANT                 TO AGCORI OF REGAGCORI
           PERFORM LEER-PLTAGCORI.
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF REGAGCORI TO DESAGE OF REPORTE-REG
           ELSE
              MOVE "AGENCIA INCORRECTA " TO DESAGE OF REPORTE-REG.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE REPORTE
                 CCAMAEAHO
                 PLTAGCORI.
           STOP RUN.
