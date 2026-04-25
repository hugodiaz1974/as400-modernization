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
       PROGRAM-ID.    CCA511.
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  NOVIEMBRE/2000.
      ******************************************************************
      * FUNCION: PROCESA ARCHIVO DE INTERFASE NO MONETARIA.            *
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
           SELECT CCAINTERF
               ASSIGN          TO DATABASE-CCAINTERF
               ORGANIZATION    IS RELATIVE
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCANOMON
               ASSIGN          TO DATABASE-CCANOMON
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *                                                                -
      ******************************************************************
      *                                                                *
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAINTERF
           LABEL RECORDS ARE STANDARD.
       01  REG-CCAINTERF.
           COPY DDS-ALL-FORMATS        OF CCATRNNOMO.
      *
       FD  CCANOMON
           LABEL RECORDS ARE STANDARD.
       01  REG-NOMONE.
           COPY DDS-ALL-FORMATS        OF CCANOMON.
      *
      ******************************************************************
      *                                                                -
       WORKING-STORAGE SECTION.
      *
       01  FILSTAT.
           03  ERR-FLG            PIC  X(001).
           03  PFK-BYTE           PIC  X(001).
      *
       01  VAR-TRABAJO.
           03  VAR-PARAMETRO      PIC  X(072)             VALUE ZEROS.
           03  RED-VAR-PARAMETRO    REDEFINES    VAR-PARAMETRO.
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
           03  CTL-WRT-CCANOMON   PIC  X(002)             VALUE "SI".
               88  WRT-CCANOMON                           VALUE "SI".
               88  NO-WRT-CCANOMON                        VALUE "NO".
           03  CTL-REGISTRO       PIC  X(002)             VALUE "NO".
               88  BUEN-REGISTRO                          VALUE "SI".
               88  MAL-REGISTRO                           VALUE "NO".
       01  PA-CODEMP                         PIC 9(05) VALUE ZEROS.
      *
      ***************************************************************
      *
       LINKAGE SECTION.
       01  PARAMETRO1                  PIC  X(072).
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
           CALL "PLTCODEMPP"              USING PA-CODEMP
           MOVE ZEROS                     TO NUM-REG-OK
                ACUM-DB-OK                   ACUM-CR-OK
           MOVE ZEROS                     TO NUM-REG-ER
                ACUM-DB-ER                   ACUM-CR-ER
           MOVE PARAMETRO1                TO VAR-PARAMETRO
           OPEN I-O     CCAINTERF
           OPEN EXTEND  CCANOMON
           MOVE "NO"                      TO CTL-CCAINTERF
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0020-LEER-CCAINTERF UNTIL FIN-CCAINTERF
                                       OR    BUEN-REGISTRO.
      *----------------------------------------------------------------
       0020-LEER-CCAINTERF.
           MOVE "SI"                      TO CTL-REGISTRO
           READ  CCAINTERF   NEXT RECORD AT END
              MOVE "SI"                   TO CTL-CCAINTERF.
           IF NO-FIN-CCAINTERF
              IF ESTTRN  OF REG-CCAINTERF > 0
                 MOVE "NO"                TO CTL-REGISTRO.
      *----------------------------------------------------------------
       0100-PROCESAR.
           IF CODSIS OF CCAINTERF = 11
              PERFORM  0110-PROCESAR-OK
           END-IF.
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0020-LEER-CCAINTERF UNTIL FIN-CCAINTERF
                                       OR    BUEN-REGISTRO.
      *----------------------------------------------------------------
       0110-PROCESAR-OK.
           INITIALIZE REGNOMON
           MOVE CORR REGTRNNOMO TO REGNOMON
           MOVE NUMAGE OF REGTRNNOMO TO AGCCTA OF REGNOMON
           MOVE NUMCTA OF REGTRNNOMO TO CTANRO OF REGNOMON
           MOVE DATVIE OF REGTRNNOMO TO CAMPO1 OF REGNOMON
           WRITE  REG-NOMONE
           MOVE ZEROS                       TO ACUM-CR-OK
           MOVE ZEROS                       TO ACUM-DB-OK
           ADD  1                           TO NUM-REG-OK
           MOVE ZEROS                       TO ACUM-CR-ER
           MOVE ZEROS                       TO ACUM-DB-ER
           MOVE ZEROS                       TO NUM-REG-ER.
      *----------------------------------------------------------------
       9999-TERMINAR.
           MOVE VAR-PARAMETRO               TO PARAMETRO1
           CLOSE CCAINTERF  CCANOMON
           GOBACK.
      *----------------------------------------------------------------
