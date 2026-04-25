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
       PROGRAM-ID.    CCA672.
      ******************************************************************
      * FUNCION: PROGRAMA DE GENERACION DE ARCHIVO TEMPORAL DE         *
      *          MOVIMIENTO CON RETROFECHA ORIGINADO EN EL DIA.        *
      ******************************************************************
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  97/09/29.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMOVACE
               ASSIGN          TO DATABASE-CCAMOVACE
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT PLTCUADRE
               ASSIGN          TO DATABASE-PLTCUADRE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVACE
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVACE.
      *
       FD  PLTCUADRE
           LABEL RECORDS ARE STANDARD.
       01  REG-CUADRE.
           COPY DDS-ALL-FORMATS OF PLTCUADRE.
      *
       WORKING-STORAGE SECTION.
      *
       01  CONTROLES.
           05  CTL-CCAMOVACE             PIC X(02) VALUE "NO".
               88  FIN-CCAMOVACE                   VALUE "SI".
               88  NO-FIN-CCAMOVACE                VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
       01  PA-CODEMP                   PIC 9(05) VALUE 0.
      ***************************************************************
           COPY FECHAS OF CCACPY.
      ***************************************************************
      ***************************************************************
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMOVACE.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN INPUT  CCAMOVACE .
           OPEN I-O    PLTCUADRE.
           CALL "PLTCODEMPP"       USING PA-CODEMP
      *
           MOVE "NO" TO CTL-CCAMOVACE .
      *
           CALL "CCA500" USING LK-FECHAS.
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVACE  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVACE.
      *----------------------------------------------------------------
       PROCESAR.
           MOVE  PA-CODEMP           TO CODEMP OF PLTCUADRE
           MOVE  FORIGE OF REG-MOVIM TO FECSAL OF PLTCUADRE
           MOVE  AGCCTA OF REG-MOVIM TO AGCCTA OF PLTCUADRE
           MOVE  CODSIS OF REG-MOVIM TO CODSIS OF PLTCUADRE
           MOVE  CODPRO OF REG-MOVIM TO CODPRO OF PLTCUADRE
           MOVE  CODMON OF REG-MOVIM TO CODMON OF PLTCUADRE
           IF CODPRO OF REG-MOVIM = 31 AND
              CTANRO OF REG-MOVIM > 999999
              MOVE 90 TO CODPRO OF PLTCUADRE
           END-IF
           IF FORIGE OF REG-MOVIM < 20020101
              MOVE 20020101 TO FECSAL OF PLTCUADRE
           END-IF.
           READ PLTCUADRE INVALID KEY
                CONTINUE
                NOT INVALID KEY
                PERFORM ACTUALIZAR-REGISTRO
           END-READ.
           MOVE  PA-CODEMP           TO CODEMP OF PLTCUADRE
           MOVE  LK-FECHA-HOY        TO FECSAL OF PLTCUADRE
           MOVE  AGCCTA OF REG-MOVIM TO AGCCTA OF PLTCUADRE
           MOVE  CODSIS OF REG-MOVIM TO CODSIS OF PLTCUADRE
           MOVE  CODPRO OF REG-MOVIM TO CODPRO OF PLTCUADRE
           MOVE  CODMON OF REG-MOVIM TO CODMON OF PLTCUADRE
           IF CODPRO OF REG-MOVIM = 31 AND
              CTANRO OF REG-MOVIM > 999999
              MOVE 90 TO CODPRO OF PLTCUADRE
           END-IF
           READ PLTCUADRE INVALID KEY
                CONTINUE
                NOT INVALID KEY
                PERFORM ACTUALIZAR-REGISTRO-HOY
           END-READ.
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVACE  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVACE.
      *----------------------------------------------------------------
       ACTUALIZAR-REGISTRO.
           IF DEBCRE OF REG-MOVIM = 1
              ADD IMPORT OF REG-MOVIM TO DEBRET OF PLTCUADRE
           ELSE
              ADD IMPORT OF REG-MOVIM TO CRERET OF PLTCUADRE
           END-IF.
           REWRITE REG-CUADRE INVALID KEY
              CONTINUE
           END-REWRITE.
      *----------------------------------------------------------------
       ACTUALIZAR-REGISTRO-HOY.
           IF DEBCRE OF REG-MOVIM = 1
              ADD IMPORT OF REG-MOVIM TO DEBRHO OF PLTCUADRE
           ELSE
              ADD IMPORT OF REG-MOVIM TO CRERHO OF PLTCUADRE
           END-IF.
           REWRITE REG-CUADRE INVALID KEY
              CONTINUE
           END-REWRITE.
      *----------------------------------------------------------------
       LEER-CCAMOVACE.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMOVACE NEXT RECORD AT END
                MOVE "SI"              TO CTL-CCAMOVACE
           END-READ.
           IF NO-FIN-CCAMOVACE
              IF FORIGE OF REG-MOVIM NOT < LK-FECHA-HOY
                 MOVE "NO" TO CTL-REGISTRO
              ELSE
                 IF FORIGE OF REG-MOVIM NOT = FVALOR OF REG-MOVIM
                    MOVE "NO" TO CTL-REGISTRO
                 END-IF
              END-IF
           END-IF.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMOVACE
                 PLTCUADRE.
           STOP RUN.
      *----------------------------------------------------------------
