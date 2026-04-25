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
       PROGRAM-ID.    CCA765.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: DEPURA CUENTAS CERRADAS EN EL CCADEPMAE A PARTIR    *
      *          DEL ARCHIVO CCANOVCIE.                              *
      *--------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCADEPMAE
               ASSIGN          TO DATABASE-CCADEPMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCANOVCIE
               ASSIGN          TO DATABASE-CCANOVCIE
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCANOVCIE
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCANOVCIE.
           COPY DDS-ALL-FORMATS OF CCANOVCIE.
      *
       FD  CCADEPMAE
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCADEPMAE.
           COPY DDS-ALL-FORMATS OF CCADEPMAE.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCANOVCIE            PIC 9(01) VALUE 0.
               88  ERROR-CCANOVCIE                VALUE 1.
           05  CTL-CCADEPMAE           PIC 9(01) VALUE 0.
               88  ERROR-CCADEPMAE               VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01) VALUE 0.
               88  FIN-PROGRAMA                  VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  W-FECHA                 PIC 9(08) VALUE ZEROS.
       01  PA-CODEMP                   PIC 9(05) VALUE ZEROS.
      *--------------------------------------------------------------*
       PROCEDURE DIVISION.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN INPUT CCANOVCIE
                I-O   CCADEPMAE.
           CALL "PLTCODEMPP"    USING PA-CODEMP
           PERFORM LEER-CCANOVCIE
           IF ERROR-CCANOVCIE THEN
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       PROCESAR.
           PERFORM PROCESAR-REGISTRO
           PERFORM LEER-CCANOVCIE
           IF ERROR-CCANOVCIE THEN
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       PROCESAR-REGISTRO.
           MOVE CODMON OF ZONA-CCANOVCIE TO CODMON OF REGDEPMAE
           MOVE CODSIS OF ZONA-CCANOVCIE TO CODSIS OF REGDEPMAE
           MOVE CODPRO OF ZONA-CCANOVCIE TO CODPRO OF REGDEPMAE
           MOVE AGCCTA OF ZONA-CCANOVCIE TO NUMAGE OF REGDEPMAE
           MOVE CTANRO OF ZONA-CCANOVCIE TO NUMCTA OF REGDEPMAE
           PERFORM LEER-CCADEPMAE
           IF NOT ERROR-CCADEPMAE THEN
              DELETE CCADEPMAE.
      *---------------------------------------------------------------*
       LEER-CCANOVCIE.
           MOVE 0 TO CTL-CCANOVCIE
           READ CCANOVCIE NEXT RECORD AT END MOVE 1 TO CTL-CCANOVCIE.
      *---------------------------------------------------------------*
       LEER-CCADEPMAE.
           MOVE 0 TO CTL-CCADEPMAE
           MOVE PA-CODEMP    TO CODEMP OF CCADEPMAE
           READ CCADEPMAE INVALID KEY MOVE 1 TO CTL-CCADEPMAE.
      *---------------------------------------------------------------*
       TERMINAR.
           CLOSE CCANOVCIE
                 CCADEPMAE.
           STOP RUN.
