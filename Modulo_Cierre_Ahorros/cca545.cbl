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
       PROGRAM-ID.    CCA545.
      *--------------------------------------------------------------*
      * FUNCION: PROGRAMA QUE DEPURA EL CCACAUSAC A PARTIR DEL FILE   *
      *          CCANOVCIE.                                           *
      *--------------------------------------------------------------*
       AUTHOR.        M.M.D.
       DATE-WRITTEN.  97/10/14.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCANOVCIE
               ASSIGN          TO DATABASE-CCANOVCIE
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCACAUSAC
               ASSIGN          TO DATABASE-CCACAUSAC
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCANOVCIE
           LABEL RECORDS ARE STANDARD.
       01  CCANOVCIE-REG.
           COPY DDS-ALL-FORMATS OF CCANOVCIE.
      *
       FD  CCACAUSAC
           LABEL RECORDS ARE STANDARD.
       01  REG-CAUSAC.
           COPY DDS-ALL-FORMATS OF CCACAUSAC.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCANOVCIE            PIC 9(01)  VALUE 0.
               88  ERROR-CCANOVCIE                 VALUE 1.
           05  CTL-CCACAUSAC            PIC 9(01)  VALUE 0.
               88  ERROR-CCACAUSAC                 VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01)  VALUE 0.
               88  FIN-PROGRAMA                   VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  AGEANT                  PIC 9(05)    VALUE ZEROS.
      *--------------------------------------------------------------*
       PROCEDURE DIVISION.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN INPUT CCANOVCIE
                I-O   CCACAUSAC.
      *
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
           MOVE 0      TO CTL-CCACAUSAC.
           MOVE CODMON OF CCANOVCIE-REG TO CODMON OF REG-CAUSAC
           MOVE CODSIS OF CCANOVCIE-REG TO CODSIS OF REG-CAUSAC
           MOVE CODPRO OF CCANOVCIE-REG TO CODPRO OF REG-CAUSAC
           MOVE AGCCTA OF CCANOVCIE-REG TO AGCCTA OF REG-CAUSAC
           MOVE CTANRO OF CCANOVCIE-REG TO CTANRO OF REG-CAUSAC
           MOVE FECPRO OF CCANOVCIE-REG TO FORIGE OF REG-CAUSAC.
           START CCACAUSAC KEY IS NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE 1 TO CTL-CCACAUSAC.
           IF NOT ERROR-CCACAUSAC THEN
              PERFORM LEER-CCACAUSAC UNTIL
                 CODMON OF CCANOVCIE-REG NOT = CODMON OF REG-CAUSAC OR
                 CODSIS OF CCANOVCIE-REG NOT = CODSIS OF REG-CAUSAC OR
                 CODPRO OF CCANOVCIE-REG NOT = CODPRO OF REG-CAUSAC OR
                 AGCCTA OF CCANOVCIE-REG NOT = AGCCTA OF REG-CAUSAC OR
                 CTANRO OF CCANOVCIE-REG NOT = CTANRO OF REG-CAUSAC OR
                 ERROR-CCACAUSAC.
      *--------------------------------------------------------------*
       LEER-CCACAUSAC.
           MOVE 0      TO CTL-CCACAUSAC.
           READ CCACAUSAC NEXT RECORD AT END MOVE 1 TO CTL-CCACAUSAC.
           IF NOT ERROR-CCACAUSAC THEN
              IF CODMON OF REG-CAUSAC = CODMON OF CCANOVCIE-REG AND
                 CODSIS OF REG-CAUSAC = CODSIS OF CCANOVCIE-REG AND
                 CODPRO OF REG-CAUSAC = CODPRO OF CCANOVCIE-REG AND
                 AGCCTA OF REG-CAUSAC = AGCCTA OF CCANOVCIE-REG AND
                 CTANRO OF REG-CAUSAC = CTANRO OF CCANOVCIE-REG THEN
                 DELETE CCACAUSAC
              ELSE
                 MOVE 1 TO CTL-CCACAUSAC
              END-IF.
      *--------------------------------------------------------------*
       LEER-CCANOVCIE.
           MOVE 0 TO CTL-CCANOVCIE
           READ CCANOVCIE NEXT RECORD AT END MOVE 1 TO CTL-CCANOVCIE.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE CCACAUSAC
                 CCANOVCIE.
           STOP RUN.
      *----------------------------------------------------------------
