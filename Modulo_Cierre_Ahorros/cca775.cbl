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
       PROGRAM-ID.    CCA775.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: GENERACION DEL REPORTE DE SALDOS PROMEDIO.          *
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
               ASSIGN          TO FORMATFILE-CCA775R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
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
           COPY DDS-ALL-FORMATS OF CCA775R.
      *                                                                 IBM-CT
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
           05  NOMBRE                  PIC X(40)  VALUE SPACES.
           05  W-HORA                  PIC 9(08)  VALUE ZEROS.
           05  RED-W-HORA              REDEFINES  W-HORA.
               10 HORA                 PIC 9(06).
               10 FILLER               PIC 9(02).
           05  W-USRID                 PIC X(10)  VALUE SPACES.
           05  W-FECHA                 PIC  9(08) VALUE ZEROS.
           05  RED-W-FECHA             REDEFINES  W-FECHA.
               10 SIGLO                PIC 9(02).
               10 ANO                  PIC 9(02).
               10 MES1                 PIC 9(02).
               10 DIA                  PIC 9(02).
           05  W-PAGINA                PIC 9(06)  VALUE ZEROS.
           05  W-FECLIQ                PIC 9(08)  VALUE ZEROS.
           05  RED-W-FECLIQ            REDEFINES  W-FECLIQ.
               10 ANO-LIQ              PIC 9(04).
               10 MES-LIQ              PIC 9(02).
               10 DIA-LIQ              PIC 9(02).
           05  I                       PIC 9(05)  VALUE ZEROS.
           05  MES                     PIC 9(02)  VALUE ZEROS.
           05  W-MES                   PIC X(10)  VALUE SPACES.
           05  AGEANT                  PIC 9(05)  VALUE ZEROS.
      *--------------------------------------------------------------*
      * VARIABLES DE ALMACENAMIENTO POR AGENCIA                      *
      *--------------------------------------------------------------*
           05   TOT-DEU1               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-DEU2               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-DEU3               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-DEU4               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-DEU5               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-DEU6               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-ACR1               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-ACR2               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-ACR3               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-ACR4               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-ACR5               PIC S9(15)V99  VALUE ZEROS.
           05   TOT-ACR6               PIC S9(15)V99  VALUE ZEROS.

           05   TOT-PRTDE              PIC S9(15)V99  VALUE ZEROS.
           05   TOT-PRTAC              PIC S9(15)V99  VALUE ZEROS.
           05   TOT-PRSDE              PIC S9(15)V99  VALUE ZEROS.
           05   TOT-PRSAC              PIC S9(15)V99  VALUE ZEROS.

      *--------------------------------------------------------------*
      * PARAMETROS RUTINA DE PROMEDIOS                               *
      *--------------------------------------------------------------*
       01  ARG-CCA485.
           05  A485-BASCAL             PIC 9(01).
           05  A485-ELEMDE             PIC 9(01).
           05  A485-TABPRM             PIC X(312).
           05  A485-PROCAL             PIC X(405).
           05  A485-RETCOD             PIC 9(01).
      *--------------------------------------------------------------*
       01  TABLA-PROCAL                PIC X(405)    VALUE SPACES.
       01  R-TABLA-PROCAL REDEFINES TABLA-PROCAL.
           05  TAB-PROCAL OCCURS    15 TIMES.
               10  PROCAL-DEU          PIC S9(15)V99    COMP-3.
               10  PROCAL-ACR          PIC S9(15)V99    COMP-3.
               10  PROCAL-PON          PIC S9(15)V99    COMP-3.
       01  PA-CODEMP                   PIC 9(05).
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
           CALL "CCA501" USING LK-CCAPARGEN
           ACCEPT W-HORA  FROM TIME
           CALL "CCA500" USING LK-FECHAS.                               A
           MOVE L-USER   TO W-USRID
           MOVE L-FECLIQ TO W-FECLIQ
           PERFORM LEER-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              PERFORM COLOCAR-TITULOS
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA
           ELSE
              PERFORM COLOCAR-TITULOS
              PERFORM COLOCAR-AGENCIA
              MOVE AGCCTA OF REGMAEAHO TO AGEANT.
      *--------------------------------------------------------------*
       PROCESAR.
           IF AGCCTA OF REGMAEAHO NOT = AGEANT THEN
              PERFORM COLOCAR-TOTALES
              PERFORM INIC-VARIABLES
              PERFORM COLOCAR-TITULOS
              PERFORM COLOCAR-AGENCIA
              MOVE AGCCTA OF REGMAEAHO TO AGEANT.
           PERFORM PROCESAR-REGISTRO
           PERFORM LEER-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              PERFORM COLOCAR-TOTALES
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       PROCESAR-REGISTRO.
           MOVE 1 TO I
           PERFORM INIC-TABLA-PROM UNTIL I > 15
           PERFORM CALL-PROMEDIOS
           PERFORM IMPRIMIR-DETALLE.
      *--------------------------------------------------------------*
       CALL-PROMEDIOS.
           MOVE 1                    TO A485-BASCAL
           MOVE 2                    TO A485-ELEMDE
           MOVE TABSAL  OF REGMAEAHO TO A485-TABPRM
           MOVE SPACES               TO A485-PROCAL
           MOVE ZEROS                TO A485-RETCOD

           CALL "CCA485" USING          ARG-CCA485.
           IF A485-RETCOD = ZEROS THEN
              MOVE A485-PROCAL TO TABLA-PROCAL.
      *--------------------------------------------------------------*
       INIC-TABLA-PROM.
           INITIALIZE PROCAL-DEU(I)
                      PROCAL-ACR(I)
                      PROCAL-PON(I)
           ADD 1 TO I.
      *--------------------------------------------------------------*
       MESES.
           INITIALIZE MES
           MOVE MES-LIQ TO MES
           PERFORM TABLA-MESES
           MOVE W-MES TO MES1 OF REPORTE-REG
           PERFORM MES-ANTERIOR
           PERFORM TABLA-MESES
           MOVE W-MES TO MES2 OF REPORTE-REG
           PERFORM MES-ANTERIOR
           PERFORM TABLA-MESES
           MOVE W-MES TO MES3 OF REPORTE-REG
           PERFORM MES-ANTERIOR
           PERFORM TABLA-MESES
           MOVE W-MES TO MES4 OF REPORTE-REG
           PERFORM MES-ANTERIOR
           PERFORM TABLA-MESES
           MOVE W-MES TO MES5 OF REPORTE-REG
           PERFORM MES-ANTERIOR
           PERFORM TABLA-MESES
           MOVE W-MES TO MES6 OF REPORTE-REG.
      *--------------------------------------------------------------*
       MES-ANTERIOR.
           COMPUTE MES = MES - 1
           IF MES = 0 THEN
              MOVE 12 TO MES.
      *--------------------------------------------------------------*
       TABLA-MESES.
           INITIALIZE W-MES
           IF MES = 1 THEN
              MOVE "ENERO    " TO W-MES
           ELSE
           IF MES = 2 THEN
              MOVE "FEBRERO  " TO W-MES
           ELSE
           IF MES = 3 THEN
              MOVE "MARZO    " TO W-MES
           ELSE
           IF MES = 4 THEN
              MOVE "ABRIL    " TO W-MES
           ELSE
           IF MES = 5 THEN
              MOVE "MAYO     " TO W-MES
           ELSE
           IF MES = 6 THEN
              MOVE "JUNIO    " TO W-MES
           ELSE
           IF MES = 7 THEN
              MOVE "JULIO    " TO W-MES
           ELSE
           IF MES = 8 THEN
              MOVE "AGOSTO   " TO W-MES
           ELSE
           IF MES = 9 THEN
              MOVE "SEPT/BRE " TO W-MES
           ELSE
           IF MES = 10 THEN
              MOVE "OCTUBRE  " TO W-MES
           ELSE
           IF MES = 11 THEN
              MOVE "NOVIEMBRE" TO W-MES
           ELSE
           IF MES = 12 THEN
              MOVE "DICIEMBRE" TO W-MES.
      *--------------------------------------------------------------*
       LEER-CCAMAEAHO.
           MOVE 0 TO CTL-CCAMAEAHO
           READ CCAMAEAHO NEXT RECORD AT END MOVE 1 TO CTL-CCAMAEAHO.
      *--------------------------------------------------------------*
       LEER-PLTAGCORI.
           MOVE 0                      TO CTL-PLTAGCORI
           MOVE PA-CODEMP              TO CODEMP OF PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
      *--------------------------------------------------------------*
       COLOCAR-TITULOS.
           INITIALIZE             HEADER-O
           ADD  1                 TO W-PAGINA
           MOVE "CCA775    "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "***         REPORTE DE SALDOS PROMEDIO         ***"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
           MOVE HORA              TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER".
      *--------------------------------------------------------------*
       COLOCAR-AGENCIA.
           INITIALIZE AGENCIA-O
           MOVE AGCCTA OF REGMAEAHO TO AGCORI OF REGAGCORI
                                       AGEN   OF REPORTE-REG
           PERFORM LEER-PLTAGCORI
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF REGAGCORI  TO DEAGE OF REPORTE-REG
           ELSE
              MOVE "AGENCIA INVALIDA" TO DEAGE OF REPORTE-REG.
           WRITE REPORTE-REG FORMAT IS "AGENCIA"
           INITIALIZE TITULOS-O
           PERFORM MESES
           WRITE REPORTE-REG FORMAT IS "TITULOS".
      *--------------------------------------------------------------*
       IMPRIMIR-DETALLE.
           INITIALIZE DETALLE-O

           MOVE CTANRO OF REGMAEAHO TO CTAAGE   OF REPORTE-REG
           MOVE DESCRI OF REGMAEAHO TO NOMCTA   OF REPORTE-REG

           MOVE PROCAL-DEU(1)       TO ACUDEU1  OF REPORTE-REG
           MOVE PROCAL-ACR(1)       TO ACUACR1  OF REPORTE-REG
           ADD  PROCAL-DEU(1)       TO TOT-DEU1
           ADD  PROCAL-ACR(1)       TO TOT-ACR1

           MOVE PROCAL-DEU(2)       TO ACUDEU2  OF REPORTE-REG
           MOVE PROCAL-ACR(2)       TO ACUACR2  OF REPORTE-REG
           ADD  PROCAL-DEU(2)       TO TOT-DEU2
           ADD  PROCAL-ACR(2)       TO TOT-ACR2

           MOVE PROCAL-DEU(3)       TO ACUDEU3  OF REPORTE-REG
           MOVE PROCAL-ACR(3)       TO ACUACR3  OF REPORTE-REG
           ADD  PROCAL-DEU(3)       TO TOT-DEU3
           ADD  PROCAL-ACR(3)       TO TOT-ACR3

           MOVE PROCAL-DEU(4)       TO ACUDEU4  OF REPORTE-REG
           MOVE PROCAL-ACR(4)       TO ACUACR4  OF REPORTE-REG
           ADD  PROCAL-DEU(4)       TO TOT-DEU4
           ADD  PROCAL-ACR(4)       TO TOT-ACR4

           MOVE PROCAL-DEU(5)       TO ACUDEU5  OF REPORTE-REG
           MOVE PROCAL-ACR(5)       TO ACUACR5  OF REPORTE-REG
           ADD  PROCAL-DEU(5)       TO TOT-DEU5
           ADD  PROCAL-ACR(5)       TO TOT-ACR5

           MOVE PROCAL-DEU(6)       TO ACUDEU6  OF REPORTE-REG
           MOVE PROCAL-ACR(6)       TO ACUACR6  OF REPORTE-REG
           ADD  PROCAL-DEU(6)       TO TOT-DEU6
           ADD  PROCAL-ACR(6)       TO TOT-ACR6

           MOVE PROCAL-DEU(13)      TO PROTRIDE OF REPORTE-REG
           MOVE PROCAL-ACR(13)      TO PROTRIAC OF REPORTE-REG
           ADD  PROCAL-DEU(13)      TO TOT-PRTDE
           ADD  PROCAL-ACR(13)      TO TOT-PRTAC

           MOVE PROCAL-DEU(14)      TO PROSEMDE OF REPORTE-REG
           MOVE PROCAL-ACR(14)      TO PROSEMAC OF REPORTE-REG
           ADD  PROCAL-DEU(14)      TO TOT-PRSDE
           ADD  PROCAL-ACR(14)      TO TOT-PRSAC

           WRITE REPORTE-REG FORMAT IS "DETALLE" AT EOP
                 PERFORM COLOCAR-TITULOS
                 PERFORM COLOCAR-AGENCIA.
      *--------------------------------------------------------------*
       COLOCAR-TOTALES.
           INITIALIZE TOTALES-O.

           MOVE TOT-DEU1            TO TACUDEU1  OF REPORTE-REG
           MOVE TOT-ACR1            TO TACUACR1  OF REPORTE-REG
           MOVE TOT-DEU2            TO TACUDEU2  OF REPORTE-REG
           MOVE TOT-ACR2            TO TACUACR2  OF REPORTE-REG
           MOVE TOT-DEU3            TO TACUDEU3  OF REPORTE-REG
           MOVE TOT-ACR3            TO TACUACR3  OF REPORTE-REG
           MOVE TOT-DEU4            TO TACUDEU4  OF REPORTE-REG
           MOVE TOT-ACR4            TO TACUACR4  OF REPORTE-REG
           MOVE TOT-DEU5            TO TACUDEU5  OF REPORTE-REG
           MOVE TOT-ACR5            TO TACUACR5  OF REPORTE-REG
           MOVE TOT-DEU6            TO TACUDEU6  OF REPORTE-REG
           MOVE TOT-ACR6            TO TACUACR6  OF REPORTE-REG

           MOVE TOT-PRTDE           TO TPROTRIDE OF REPORTE-REG
           MOVE TOT-PRTAC           TO TPROTRIAC OF REPORTE-REG
           MOVE TOT-PRSDE           TO TPROSEMDE OF REPORTE-REG
           MOVE TOT-PRSAC           TO TPROSEMAC OF REPORTE-REG.

           WRITE REPORTE-REG FORMAT IS "TOTALES" AT EOP
                 PERFORM COLOCAR-TITULOS
                 PERFORM COLOCAR-AGENCIA.
      *--------------------------------------------------------------*
       INIC-VARIABLES.
           INITIALIZE TOT-DEU1
                      TOT-ACR1
                      TOT-DEU2
                      TOT-ACR2
                      TOT-DEU3
                      TOT-ACR3
                      TOT-DEU4
                      TOT-ACR4
                      TOT-DEU5
                      TOT-ACR5
                      TOT-DEU6
                      TOT-ACR6
                      TOT-PRTDE
                      TOT-PRTAC
                      TOT-PRSDE
                      TOT-PRSAC.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE REPORTE
                 CCAMAEAHO
                 PLTAGCORI.
           STOP RUN.
