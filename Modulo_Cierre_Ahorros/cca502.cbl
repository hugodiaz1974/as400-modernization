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
       PROGRAM-ID.    CCA502.
       AUTHOR.        VICENTE GUZMAN Q.
       DATE-WRITTEN.  ENERO72001.
      *--------------------------------------------------------------*
      * FUNCION: RETORNA SI HOY ES 1 DIA HABIL DEL MES Y TRIMESTRE
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
           05  W-FECHA-ANT             PIC 9(08) VALUE ZEROS.
           05  FILLER REDEFINES W-FECHA-ANT.
               07 W-AA-ANT PIC 9999.
               07 W-MM-ANT PIC 99.
               07 W-DD-ANT PIC 99.
           05  W-FECHA-HOY             PIC 9(08) VALUE ZEROS.
           05  FILLER REDEFINES W-FECHA-HOY.
               07 W-AA-HOY PIC 9999.
               07 W-MM-HOY PIC 99.
               07 W-DD-HOY PIC 99.
           05  W-FECHA-MAN             PIC 9(08) VALUE ZEROS.
           05  FILLER REDEFINES W-FECHA-MAN.
               07 W-AA-MAN PIC 9999.
               07 W-MM-MAN PIC 99.
               07 W-DD-MAN PIC 99.
       01 LK-CODEMP                    PIC 9(05) VALUE 0.
      *--------------------------------------------------------------*
       LINKAGE SECTION.
      *--------------------------------------------------------------*
       01 FIN-MES                      PIC X.
       01 FIN-TRI                      PIC X.
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING FIN-MES FIN-TRI.                         NA .
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           MOVE 0                     TO CTL-PROGRAMA
           CALL "PLTCODEMPP"    USING LK-CODEMP
           OPEN INPUT PLTFECHAS.
           MOVE "N" TO FIN-MES FIN-TRI.
      *--------------------------------------------------------------*
       PROCESAR.
           MOVE 11                     TO CODSIS OF REGFECHAS
           PERFORM LEER-PLTFECHAS
           IF NOT FIN-PROGRAMA
              IF W-MM-HOY NOT = W-MM-MAN
                 MOVE "S" TO FIN-MES
                 IF W-MM-HOY = 3 OR 6 OR 9 OR 12
                    MOVE "S" TO FIN-TRI
                 END-IF
              END-IF
              MOVE 1   TO CTL-PROGRAMA
           END-IF.
      *--------------------------------------------------------------*
       LEER-PLTFECHAS.
           MOVE 0 TO CTL-PLTFECHAS
           MOVE LK-CODEMP               TO CODEMP OF PLTFECHAS
           READ PLTFECHAS
                INVALID KEY MOVE 1     TO CTL-PLTFECHAS.
           IF NOT ERROR-PLTFECHAS THEN
              MOVE FECPRA OF REGFECHAS TO W-FECHA-ANT
              MOVE FECPRO OF REGFECHAS TO W-FECHA-HOY
              MOVE FECPRS OF REGFECHAS TO W-FECHA-MAN
           ELSE
              MOVE 1                    TO CTL-PROGRAMA
              INITIALIZE                W-FECHA-ANT
                                        W-FECHA-HOY
                                        W-FECHA-MAN.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE PLTFECHAS
           GOBACK.
