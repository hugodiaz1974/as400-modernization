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
       PROGRAM-ID.    CCA600.
      ******************************************************************
      * FUNCION: PROGRAMA DE GENERACION DE ARCHIVO TEMPORAL DE         *
      *          MOVIMIENTO CON RETROFECHA ORIGINADO EN EL DIA.        *
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/09/29.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVRF11
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT CCARETROF
               ASSIGN          TO DATABASE-CCARETROF
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVRF11.
      *
       FD  CCARETROF
           LABEL RECORDS ARE STANDARD.
       01  REG-RETROF.
           COPY DDS-ALL-FORMATS OF CCARETROF.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-ACUM                      PIC S9(13)V99 COMP VALUE ZEROS.
      *
       77  W-CODMON                    PIC 9(03)          VALUE ZEROS.
       77  W-CODSIS                    PIC 9(03)          VALUE ZEROS.
       77  W-CODPRO                    PIC 9(03)          VALUE ZEROS.
       77  W-AGCCTA                    PIC 9(05)          VALUE ZEROS.
       77  W-CTANRO                    PIC 9(17)          VALUE ZEROS.
       77  W-FORIGE                    PIC 9(08)          VALUE ZEROS.
      *
       01  W-CTANROX                   PIC 9(17)          VALUE ZEROS.
       01  R-W-CTANROX                 REDEFINES W-CTANROX.
           05  FILLER                  PIC X(10).
           05  W-CUENTA                PIC 9(06).
               88  ES-ESPECIAL         VALUE 888888.
           05  W-DIGITO                PIC 9(01).
      *
       01  CONTROLES.
           05  CTL-CCAMOVIM             PIC X(02) VALUE "NO".
               88  FIN-CCAMOVIM                   VALUE "SI".
               88  NO-FIN-CCAMOVIM                VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
      *
      * VARIABLES-ENCADENAR.
           COPY FECHAS  OF CCACPY.
      ***************************************************************
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMOVIM.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN INPUT  CCAMOVIM .
           OPEN I-O    CCARETROF.
      *
           PERFORM CALL-CCA500.
      *
           MOVE "NO" TO CTL-CCAMOVIM .
      *
           MOVE "NO" TO CTL-REGISTRO.
           MOVE ZEROS TO CODMON OF CCAMOVIM
                         CODSIS OF CCAMOVIM
                         CODPRO OF CCAMOVIM
                         AGCCTA OF CCAMOVIM
                         CTANRO OF CCAMOVIM
                         FORIGE OF CCAMOVIM
                         DEBCRE OF CCAMOVIM
                         CODTRA OF CCAMOVIM
                         IMPORT OF CCAMOVIM.
           START CCAMOVIM KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE "SI" TO CTL-CCAMOVIM.
           PERFORM LEER-CCAMOVIM  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVIM.
           IF NO-FIN-CCAMOVIM
              MOVE CODMON OF REG-MOVIM TO W-CODMON
              MOVE CODSIS OF REG-MOVIM TO W-CODSIS
              MOVE CODPRO OF REG-MOVIM TO W-CODPRO
              MOVE AGCCTA OF REG-MOVIM TO W-AGCCTA
              MOVE CTANRO OF REG-MOVIM TO W-CTANRO
              MOVE FORIGE OF REG-MOVIM TO W-FORIGE.
      *----------------------------------------------------------------
       PROCESAR.
           IF AGCCTA OF REG-MOVIM NOT = W-AGCCTA OR
              CODMON OF REG-MOVIM NOT = W-CODMON OR
              CODSIS OF REG-MOVIM NOT = W-CODSIS OR
              CODPRO OF REG-MOVIM NOT = W-CODPRO OR
              CTANRO OF REG-MOVIM NOT = W-CTANRO
              PERFORM CAMBIO-CUENTA
           ELSE
              IF FORIGE OF REG-MOVIM NOT = W-FORIGE
                 PERFORM CAMBIO-FECHA.
           IF DEBCRE OF REG-MOVIM = 1
              SUBTRACT IMPORT OF REG-MOVIM FROM W-ACUM
           ELSE
              ADD      IMPORT OF REG-MOVIM TO   W-ACUM.
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVIM  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVIM.
           IF FIN-CCAMOVIM
              PERFORM CAMBIO-CUENTA.
      *----------------------------------------------------------------
       CAMBIO-CUENTA.
           PERFORM CAMBIO-FECHA.
           MOVE CODMON OF REG-MOVIM TO W-CODMON.
           MOVE CODSIS OF REG-MOVIM TO W-CODSIS.
           MOVE CODPRO OF REG-MOVIM TO W-CODPRO.
           MOVE AGCCTA OF REG-MOVIM TO W-AGCCTA.
           MOVE CTANRO OF REG-MOVIM TO W-CTANRO.
      *----------------------------------------------------------------
       CAMBIO-FECHA.
           INITIALIZE REG-RETROF
           MOVE W-CODMON TO CODMON OF REG-RETROF
           MOVE W-CODSIS TO CODSIS OF REG-RETROF
           MOVE W-CODPRO TO CODPRO OF REG-RETROF
           MOVE W-AGCCTA TO AGCCTA OF REG-RETROF
           MOVE W-CTANRO TO CTANRO OF REG-RETROF
           MOVE W-FORIGE TO FORIGE OF REG-RETROF
           IF W-ACUM < ZEROS
              MOVE 1                TO     DEBCRE OF REG-RETROF
              MULTIPLY W-ACUM BY -1 GIVING IMPORT OF REG-RETROF
              WRITE REG-RETROF
           ELSE
              IF W-ACUM > ZEROS
                 MOVE 2             TO     DEBCRE OF REG-RETROF
                 MOVE W-ACUM        TO     IMPORT OF REG-RETROF
                 WRITE REG-RETROF.
           MOVE ZEROS TO W-ACUM.
           MOVE FORIGE OF REG-MOVIM TO W-FORIGE.
      *----------------------------------------------------------------
       LEER-CCAMOVIM.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMOVIM NEXT RECORD AT END
                MOVE "SI"              TO CTL-CCAMOVIM
                MOVE 999               TO CODMON OF REG-MOVIM
                MOVE 999               TO CODSIS OF REG-MOVIM
                MOVE 999               TO CODPRO OF REG-MOVIM
                MOVE 99999             TO AGCCTA OF REG-MOVIM
                MOVE 99999999999999999 TO CTANRO OF REG-MOVIM
                MOVE 99999999          TO FORIGE OF REG-MOVIM.
           IF NO-FIN-CCAMOVIM
              IF FORIGE OF REG-MOVIM NOT < LK-FECHA-HOY
                 MOVE "NO" TO CTL-REGISTRO
              ELSE
                 MOVE CTANRO OF REG-MOVIM TO W-CTANROX
                 IF ES-ESPECIAL
                    MOVE "NO" TO CTL-REGISTRO.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMOVIM  .
           CLOSE CCARETROF .
           STOP  RUN      .
      *----------------------------------------------------------------
