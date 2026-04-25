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
       PROGRAM-ID.    CCA800.
      ******************************************************************
      * FUNCION: PROYECCION DE UN DIA HABIL PARA LA FECHA DE PROCESO   *
      *          Y EN CASO DE HABERSE HECHO EL CORTE, SE PROYECTA LA   *
      *          FECHA DE CORTE AL ULTIMO DIA HABIL DEL MES SIGUIENTE. *
      *          TAMBIEN SE CALCULA EL PENULTIMO DIA HABIL DEL         *
      *          MES SIGUIENTE (EN CASO DE NECESITARSE).               *
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/10/10.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT PLTFECHAS
               ASSIGN          TO DATABASE-PLTFECHAS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAPARGEN
               ASSIGN          TO DATABASE-CCAPARGEN
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  PLTFECHAS
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTFECHAS.
           COPY DDS-ALL-FORMATS OF PLTFECHAS.
      *
       FD  CCAPARGEN
           LABEL RECORDS ARE STANDARD.
       01  REG-PARGEN.
           COPY DDS-ALL-FORMATS OF CCAPARGEN.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-FECHAANT                  PIC 9(08)          VALUE ZEROS.
       77  W-FECHAHOY                  PIC 9(08)          VALUE ZEROS.
       77  W-FECHA24                   PIC 9(08)          VALUE ZEROS.
       77  W-FECHA48                   PIC 9(08)          VALUE ZEROS.
       01  W-FECHA                     PIC 9(08)          VALUE ZEROS.
       01  R-FECHA                     REDEFINES W-FECHA.
           05  ANO-FECHA               PIC 9(04).
           05  MES-FECHA               PIC 9(02).
           05  DIA-FECHA               PIC 9(02).
      *----------------------------------------------------------------
      *                   Variables de Control                        |
      *----------------------------------------------------------------
      *Variable para control acceso directo del Archivo PLTFECHAS.
       01  W-EXISTE-PLTFECHAS          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-PLTFECHAS                    VALUE 0.
           88  SI-EXISTE-PLTFECHAS                    VALUE 1.
      *Variable para control acceso directo del Archivo CCAPARGEN.
       01  W-EXISTE-CCAPARGEN          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-CCAPARGEN                    VALUE 0.
           88  SI-EXISTE-CCAPARGEN                    VALUE 1.
      *
      * ALMACENA EL PENULTIMO DIA HABIL DEL MES SIGUIENTE.
       01  W-FECHACTL-2                PIC 9(08)          VALUE ZEROS.
       01  R-FECHACTL-2                REDEFINES W-FECHACTL-2.
           05  ANO-CTL-2               PIC 9(04).
           05  MES-CTL-2               PIC 9(02).
           05  DIA-CTL-2               PIC 9(02).
      *
      * ALMACENA EL ULTIMO DIA HABIL DEL MES SIGUIENTE.
       01  W-FECHACTL-1                PIC 9(08)          VALUE ZEROS.
       01  R-FECHACTL-1                REDEFINES W-FECHACTL-1.
           05  ANO-CTL-1               PIC 9(04).
           05  MES-CTL-1               PIC 9(02).
           05  DIA-CTL-1               PIC 9(02).
      *
      * FECHA DE CONTROL.
       01  W-FECHACTL-0                PIC 9(08)          VALUE ZEROS.
       01  R-FECHACTL-0                REDEFINES W-FECHACTL-0.
           05  ANO-CTL-0               PIC 9(04).
           05  MES-CTL-0               PIC 9(02).
           05  DIA-CTL-0               PIC 9(02).
      *
      * PARAMETROS RUTINA CALCULO FECHAS (PLT219).
      *
       77  F-FECHA1                    PIC 9(08) VALUE ZEROS.
       77  F-FECHA2                    PIC 9(08) VALUE ZEROS.
       77  F-FECHA3                    PIC 9(08) VALUE ZEROS.
       77  F-TIPFMT                    PIC 9(01) VALUE ZEROS.
       77  F-BASCLC                    PIC 9(01) VALUE ZEROS.
       77  F-NRODIA                    PIC 9(05) VALUE ZEROS.
       77  F-INDDSP                    PIC 9(01) VALUE ZEROS.
       77  F-DIASEM                    PIC 9(01) VALUE ZEROS.
       77  F-NOMDIA                    PIC X(10) VALUE SPACES.
       77  F-NOMMES                    PIC X(10) VALUE SPACES.
       77  F-CODRET                    PIC 9(01) VALUE ZEROS.
       77  F-MSGERR                    PIC X(40) VALUE SPACES.
       77  F-TIPOPR                    PIC 9(01) VALUE ZEROS.
      *
      * ----------------------
       01  W-FIN-MES                   PIC X VALUE "N".
       01  W-FIN-TRI                   PIC X VALUE "N".
       01  W-SDO-DIA                   PIC X VALUE "N".
       01  PA-CODEMP                   PIC 9(05) VALUE ZEROS.
      ***************************************************************
      *
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           PERFORM CALL-CCA502.
           PERFORM CALL-CCA503.
           OPEN I-O    PLTFECHAS  .
           OPEN I-O    CCAPARGEN.
           CALL "PLTCODEMPP"           USING PA-CODEMP.
      *----------------------------------------------------------------
       PROCESAR.
           MOVE 11                     TO CODSIS OF REG-PLTFECHAS.
           MOVE PA-CODEMP              TO CODEMP OF REG-PLTFECHAS
           READ PLTFECHAS.
           MOVE FECPRA OF REG-PLTFECHAS TO W-FECHAANT
           MOVE FECPRO OF REG-PLTFECHAS TO W-FECHAHOY
           MOVE FECPRS OF REG-PLTFECHAS TO W-FECHA24.
           MOVE FECPSS OF REG-PLTFECHAS TO W-FECHA48.
      *
           MOVE W-FECHA48    TO W-FECHACTL-0
           PERFORM SUMAR-UN-DIA-HABIL
           MOVE W-FECHAHOY   TO FECPRA OF REG-PLTFECHAS.
           MOVE W-FECHA24    TO FECPRO OF REG-PLTFECHAS.
           MOVE W-FECHA48    TO FECPRS OF REG-PLTFECHAS.
           MOVE W-FECHACTL-0 TO FECPSS OF REG-PLTFECHAS.
           REWRITE REG-PLTFECHAS.
      *
           MOVE 1     TO CODCIA OF REG-PARGEN.
           READ CCAPARGEN.
           PERFORM PROYECTAR-CORTE.
      *    IF W-FECHAHOY > FECLIQ OF REG-PARGEN
      *       IF INDCIE OF REG-PARGEN = 1
      *          PERFORM PROYECTAR-CORTE.
      *----------------------------------------------------------------
       PROYECTAR-CORTE.
           MOVE W-FECHAANT TO F-FECHA1
           MOVE W-FECHAHOY TO F-FECHA2
           IF W-FIN-MES = "S"
              MOVE F-FECHA2 TO W-FECHA
              MOVE 1        TO DIA-FECHA
              MOVE W-FECHA  TO F-FECHA2
           ELSE
              IF W-SDO-DIA = "S"
                 MOVE F-FECHA1 TO W-FECHA
                 MOVE 1        TO DIA-FECHA
                 MOVE W-FECHA  TO F-FECHA1
              END-IF
           END-IF
           MOVE F-FECHA2   TO F-FECHA1
           MOVE ZEROS      TO F-FECHA2
           MOVE ZEROS      TO F-FECHA3
           MOVE 1          TO F-TIPFMT
           MOVE 2          TO F-BASCLC
           MOVE 1          TO F-NRODIA
           MOVE 2          TO F-INDDSP
           MOVE ZEROS      TO F-DIASEM
           MOVE SPACES     TO F-NOMDIA
           MOVE SPACES     TO F-NOMMES
           MOVE ZEROS      TO F-CODRET
           MOVE SPACES     TO F-MSGERR
           MOVE 2          TO F-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE F-FECHA3   TO FECLIQ OF REG-PARGEN.
      *    MOVE  0                   TO INDCIE OF REG-PARGEN.
      *    MOVE FECLIQ OF REG-PARGEN TO W-FECHACTL-0
      *    MOVE 01                   TO DIA-CTL-0
      *    ADD   1                   TO MES-CTL-0
      *    IF MES-CTL-0 = 13
      *       MOVE 01                TO MES-CTL-0
      *       ADD   1                TO ANO-CTL-0.
      *    MOVE W-FECHACTL-0         TO W-FECHACTL-1.
      *    PERFORM PROYECTAR-HABILES UNTIL MES-CTL-0 NOT = MES-CTL-1.
      *    MOVE W-FECHACTL-1         TO FECLIQ OF REG-PARGEN.
           REWRITE REG-PARGEN.
      *----------------------------------------------------------------
       PROYECTAR-HABILES.
           MOVE W-FECHACTL-1 TO W-FECHACTL-2
           MOVE W-FECHACTL-0 TO W-FECHACTL-1.
           PERFORM SUMAR-UN-DIA-HABIL.
      *----------------------------------------------------------------
       SUMAR-UN-DIA-HABIL.
           MOVE W-FECHACTL-0 TO F-FECHA1
           MOVE ZEROS        TO F-FECHA2
           MOVE ZEROS        TO F-FECHA3
           MOVE 1            TO F-TIPFMT
           MOVE 2            TO F-BASCLC
           MOVE 1            TO F-NRODIA
           MOVE 1            TO F-INDDSP
           MOVE 9            TO F-DIASEM
           MOVE SPACES       TO F-NOMDIA
           MOVE SPACES       TO F-NOMMES
           MOVE ZEROS        TO F-CODRET
           MOVE SPACES       TO F-MSGERR
           MOVE 3            TO F-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE F-FECHA3   TO W-FECHACTL-0.
      *----------------------------------------------------------------
       CALL-PLT219.
           CALL "PLT219" USING
                         PA-CODEMP
                         F-FECHA1
                         F-FECHA2
                         F-FECHA3
                         F-TIPFMT
                         F-BASCLC
                         F-NRODIA
                         F-INDDSP
                         F-DIASEM
                         F-NOMDIA
                         F-NOMMES
                         F-CODRET
                         F-MSGERR
                         F-TIPOPR.
      *----------------------------------------------------------------
       CALL-CCA502.
           CALL "CCA502" USING W-FIN-MES W-FIN-TRI.
      *----------------------------------------------------------------
       CALL-CCA503.
           CALL "CCA503" USING W-SDO-DIA.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE PLTFECHAS  .
           CLOSE CCAPARGEN.
           STOP  RUN     .
      *----------------------------------------------------------------
