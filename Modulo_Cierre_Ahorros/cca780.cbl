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
       PROGRAM-ID.    CCA780.
      ******************************************************************
      * FUNCION: GENERA SECUENCIA DE MOVIMIENTO POR CUENTA EN ARCHIVO  *
      *          SECUENCIAL CCAEXTRAS, PARA SER INDEXADO POSTERIORMENTE.*
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/10/14.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAHISTOR
               ASSIGN          TO DATABASE-CCAHISTOR
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCAEXTRAS
               ASSIGN          TO DATABASE-CCAEXTRAS
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAHISTOR
           LABEL RECORDS ARE STANDARD.
       01  REG-HISTOR.
           COPY DDS-ALL-FORMATS OF CCAHISTOR.
      *
       FD  CCAEXTRAS
           LABEL RECORDS ARE STANDARD.
       01  REG-EXTRAS.
           COPY DDS-ALL-FORMATS OF CCAEXTRAS.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-SECUEN                    PIC 9(07) COMP VALUE ZEROS.
      *
       01  W-CL-CCAHISTOR.
           05  W-CODMON-CCAHISTOR       PIC 9(03) VALUE ZEROS.
           05  W-CODSIS-CCAHISTOR       PIC 9(03) VALUE ZEROS.
           05  W-CODPRO-CCAHISTOR       PIC 9(03) VALUE ZEROS.
           05  W-AGCCTA-CCAHISTOR       PIC 9(05) VALUE ZEROS.
           05  W-CTANRO-CCAHISTOR       PIC 9(17) VALUE ZEROS.
      *
       01  CONTROLES.
           05  CTL-CCAHISTOR            PIC X(02) VALUE "NO".
               88  FIN-CCAHISTOR                  VALUE "SI".
               88  NO-FIN-CCAHISTOR               VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
      *
      ***************************************************************
      *
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAHISTOR.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN INPUT  CCAHISTOR.
           OPEN OUTPUT CCAEXTRAS.
      *
           MOVE "NO" TO CTL-CCAHISTOR.
      *
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAHISTOR UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAHISTOR.
           IF NO-FIN-CCAHISTOR
              MOVE ZEROS  TO W-SECUEN
              MOVE CODMON OF REG-HISTOR TO W-CODMON-CCAHISTOR
              MOVE CODSIS OF REG-HISTOR TO W-CODSIS-CCAHISTOR
              MOVE CODPRO OF REG-HISTOR TO W-CODPRO-CCAHISTOR
              MOVE AGCCTA OF REG-HISTOR TO W-AGCCTA-CCAHISTOR
              MOVE CTANRO OF REG-HISTOR TO W-CTANRO-CCAHISTOR.
      *----------------------------------------------------------------
       PROCESAR.
           IF (CODMON OF REG-HISTOR NOT = W-CODMON-CCAHISTOR) OR
              (CODSIS OF REG-HISTOR NOT = W-CODSIS-CCAHISTOR) OR
              (CODPRO OF REG-HISTOR NOT = W-CODPRO-CCAHISTOR) OR
              (AGCCTA OF REG-HISTOR NOT = W-AGCCTA-CCAHISTOR) OR
              (CTANRO OF REG-HISTOR NOT = W-CTANRO-CCAHISTOR)
              MOVE ZEROS  TO W-SECUEN
              MOVE CODMON OF REG-HISTOR TO W-CODMON-CCAHISTOR
              MOVE CODSIS OF REG-HISTOR TO W-CODSIS-CCAHISTOR
              MOVE CODPRO OF REG-HISTOR TO W-CODPRO-CCAHISTOR
              MOVE AGCCTA OF REG-HISTOR TO W-AGCCTA-CCAHISTOR
              MOVE CTANRO OF REG-HISTOR TO W-CTANRO-CCAHISTOR.
      *
           ADD 1 TO W-SECUEN.
           MOVE CODMON OF REG-HISTOR TO CODMON OF REG-EXTRAS
           MOVE CODSIS OF REG-HISTOR TO CODSIS OF REG-EXTRAS
           MOVE CODPRO OF REG-HISTOR TO CODPRO OF REG-EXTRAS
           MOVE AGCCTA OF REG-HISTOR TO AGCCTA OF REG-EXTRAS
           MOVE CTANRO OF REG-HISTOR TO CTANRO OF REG-EXTRAS
           MOVE W-SECUEN             TO SECUEN OF REG-EXTRAS
           MOVE FORIGE OF REG-HISTOR TO FORIGE OF REG-EXTRAS
           MOVE DEBCRE OF REG-HISTOR TO DEBCRE OF REG-EXTRAS
           MOVE CODTRA OF REG-HISTOR TO CODTRA OF REG-EXTRAS
           MOVE IMPORT OF REG-HISTOR TO IMPORT OF REG-EXTRAS
           MOVE FVALOR OF REG-HISTOR TO FVALOR OF REG-EXTRAS
           MOVE NROREF OF REG-HISTOR TO NROREF OF REG-EXTRAS
           MOVE FECVAL OF REG-HISTOR TO FECVAL OF REG-EXTRAS
           MOVE TIPVAL OF REG-HISTOR TO TIPVAL OF REG-EXTRAS
           MOVE ESTTRN OF REG-HISTOR TO ESTTRN OF REG-EXTRAS
           MOVE AGCORI OF REG-HISTOR TO AGCORI OF REG-EXTRAS
           MOVE CODCAJ OF REG-HISTOR TO CODCAJ OF REG-EXTRAS.
      *
           WRITE REG-EXTRAS.
      *
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAHISTOR UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAHISTOR.
           IF FIN-CCAHISTOR
              PERFORM GRABAR-LAST.
      *----------------------------------------------------------------
       LEER-CCAHISTOR.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAHISTOR AT END
                MOVE "SI" TO CTL-CCAHISTOR.
      *----------------------------------------------------------------
       GRABAR-LAST.
           INITIALIZE REGEXTRAC.
           MOVE 999                  TO CODMON OF REG-EXTRAS
           MOVE 999                  TO CODSIS OF REG-EXTRAS
           MOVE 999                  TO CODPRO OF REG-EXTRAS
           MOVE 999                  TO AGCCTA OF REG-EXTRAS
           MOVE 99999999999999999    TO CTANRO OF REG-EXTRAS
           MOVE 9999999              TO SECUEN OF REG-EXTRAS.
           WRITE REG-EXTRAS.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAHISTOR .
           CLOSE CCAEXTRAS .
           STOP  RUN      .
      *----------------------------------------------------------------
