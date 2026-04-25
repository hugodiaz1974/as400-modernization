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
       PROGRAM-ID.    CCA500.
       AUTHOR.        VICENTE GUZMAN Q.
       DATE-WRITTEN.  NOVIEMBRE/2000.
      *--------------------------------------------------------------*
      * FUNCION: RETORNA FECHAS ARCHIVO PLTFECHAS.
      *--------------------------------------------------------------*
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
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  PLTFECHAS
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTFECHAS.
           COPY DDS-ALL-FORMATS OF PLTFECHAS.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-PLTFECHAS              PIC 9(01) VALUE 0.
               88  ERROR-PLTFECHAS                  VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01) VALUE 0.
               88  FIN-PROGRAMA                  VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  W-FECHA                 PIC 9(08) VALUE ZEROS.
       01  LK-CODEMP                   PIC 9(05) VALUE ZEROS.
      *--------------------------------------------------------------*
       LINKAGE SECTION.
      *--------------------------------------------------------------*
           COPY FECHAS OF CCACPY.
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING LK-FECHAS.                               NA .
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           MOVE 0                     TO CTL-PROGRAMA
           CALL "PLTCODEMPP"          USING LK-CODEMP.
           OPEN INPUT PLTFECHAS.
      *--------------------------------------------------------------*
       PROCESAR.
           MOVE 11                     TO CODSIS OF REGFECHAS
           PERFORM LEER-PLTFECHAS
           MOVE 1                      TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       LEER-PLTFECHAS.
           MOVE 0 TO CTL-PLTFECHAS
           MOVE LK-CODEMP               TO CODEMP OF PLTFECHAS
           READ PLTFECHAS
                INVALID KEY MOVE 1     TO CTL-PLTFECHAS.
           IF NOT ERROR-PLTFECHAS THEN
              MOVE FECPRA OF REGFECHAS TO LK-FECHA-AYER
              MOVE FECPRO OF REGFECHAS TO LK-FECHA-HOY
              MOVE FECPRS OF REGFECHAS TO LK-FECHA-MANANA
              MOVE FECPSS OF REGFECHAS TO LK-FECHA-PASMAN
           ELSE
              INITIALIZE                LK-FECHA-AYER
                                        LK-FECHA-HOY
                                        LK-FECHA-MANANA
                                        LK-FECHA-PASMAN .
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE PLTFECHAS
           GOBACK.
