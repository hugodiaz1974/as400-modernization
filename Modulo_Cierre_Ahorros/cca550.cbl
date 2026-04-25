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
       PROGRAM-ID.    CCA550.
       AUTHOR.        VGQ.
       DATE-WRITTEN.  NOVIEMBRE/2000.
      *--------------------------------------------------------------*
      * FUNCION: VALIDACION DE NOVEDADES MONETARIAS Y ACTUALIZACION  *
      *          DE CODIGOS DE ERROR.                                *
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
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM01
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
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
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVIM01.
      *
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACODTRN.
           COPY DDS-ALL-FORMATS OF CCACODTRN.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCAMAEAHO           PIC 9(01) VALUE 0.
               88  ERROR-CCAMAEAHO               VALUE 1.
           05  CTL-CCAMOVIM            PIC 9(01) VALUE 0.
               88  ERROR-CCAMOVIM                VALUE 1.
           05  CTL-CCACODTRN           PIC 9(01) VALUE 0.
               88  ERROR-CCACODTRN               VALUE 1.
           05  CTL-PLTAGCORI           PIC 9(01) VALUE 0.
               88  ERROR-PLTAGCORI               VALUE 1.
           05  CTL-MAXIMO              PIC 9(01) VALUE 0.
               88  ERROR-MAXIMO                  VALUE 1.
           05  CTL-OK                  PIC 9(01) VALUE 0.
               88  ERROR-OK                      VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01) VALUE 0.
               88  FIN-PROGRAMA                  VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  CONT-ERR                PIC 9(02) VALUE ZEROS.
           05  MONANT                  PIC 9(03) VALUE ZEROS.
           05  PROANT                  PIC 9(03) VALUE ZEROS.
           05  SISANT                  PIC 9(03) VALUE ZEROS.
           05  AGEANT                  PIC 9(05) VALUE ZEROS.
           05  CTAANT                  PIC 9(17) VALUE ZEROS.
           05  CODERR                  PIC 9(02) VALUE ZEROS.
           05  I                       PIC 9(06) VALUE ZEROS.
           05  FECDEV                  PIC 9(08) VALUE ZEROS.
           05  DIADEV                  PIC 9(02) VALUE ZEROS.
      *--------------------------------------------------------------*
      * PARAMETROS RUTINA CALCULO FECHA
      *--------------------------------------------------------------*
           05  W-F24                   PIC 9(08) VALUE ZEROS.
           05  W-F48                   PIC 9(08) VALUE ZEROS.
           05  W-F72                   PIC 9(08) VALUE ZEROS.
           05  W-F96                   PIC 9(08) VALUE ZEROS.
           05  W-F120                  PIC 9(08) VALUE ZEROS.
           05  W-CODRET                PIC 9(01) VALUE ZEROS.
      *--------------------------------------------------------------*
      * TABLAS.
      *--------------------------------------------------------------*
       01  TABLA-CODIGOS               PIC X(9999) VALUE ZEROS.
       01  RED-TABLA-CODIGOS           REDEFINES   TABLA-CODIGOS.
           05 TABLA-COD                OCCURS      9999 TIMES.
              10 DECRE                 PIC 9(01).
              10 TIVAL                 PIC 9(01).
              10 FECVA                 PIC 9(01).
       01  TABLA-CODIGOS2              PIC X(9999)  VALUE ZEROS.
       01  RED-TABLA-CODIGOS2          REDEFINES   TABLA-CODIGOS2.
           05 TABLA-COD2               OCCURS      9999 TIMES.
              10 EXISTE                PIC 9(01).
       01  PA-CODEMP                   PIC 9(05)  VALUE ZEROS.
      *
      * VARIABLES-ENCADENAR.
           COPY FECHAS  OF CCACPY.
           COPY PLT219  OF CCACPY.
      *
       01  KKK-USRING.
           05 KKK-USRING1              PIC X(08)   VALUE SPACES.
           05 KKK-USRING2              PIC X(02)   VALUE SPACES.
       01  KKK-USRINGW    REDEFINES KKK-USRING PIC X(10).
      *
      *--------------------------------------------------------------*
       PROCEDURE DIVISION.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN I-O    CCAMOVIM
                INPUT  CCAMAEAHO
                       CCACODTRN
                       PLTAGCORI.
           CALL "PLTCODEMPP"             USING PA-CODEMP
           PERFORM LEER-CCAMOVIM
           IF ERROR-CCAMOVIM THEN
              MOVE 1 TO CTL-PROGRAMA
           ELSE
            MOVE 1 TO I
            PERFORM CARGAR-FECHAS
            PERFORM INIC-TABLA UNTIL I > 9999
            MOVE 1 TO I
            PERFORM INIC-TABLA-2 UNTIL I > 9999
            PERFORM CARGAR-TABLA UNTIL ERROR-CCACODTRN
            PERFORM CARGAR-TABLA-2 UNTIL ERROR-PLTAGCORI.
      *--------------------------------------------------------------*
       PROCESAR.
           IF AGCCTA OF REGMOVIM NOT = AGEANT OR
              CODSIS OF REGMOVIM NOT = SISANT OR
              CODMON OF REGMOVIM NOT = MONANT OR
              CODPRO OF REGMOVIM NOT = PROANT OR
              CTANRO OF REGMOVIM NOT = CTAANT THEN
              PERFORM VALIDAR-MAESTRO
              IF NOT ERROR-CCAMAEAHO THEN
                 MOVE 0 TO CTL-OK
                 MOVE AGCCTA OF REGMOVIM TO AGEANT
                 MOVE CTANRO OF REGMOVIM TO CTAANT
                 MOVE CODMON OF REGMOVIM TO MONANT
                 MOVE CODSIS OF REGMOVIM TO SISANT
                 MOVE CODPRO OF REGMOVIM TO PROANT
              ELSE
                 MOVE 1 TO CTL-OK
                 MOVE AGCCTA OF REGMOVIM TO AGEANT
                 MOVE CTANRO OF REGMOVIM TO CTAANT
                 MOVE CODMON OF REGMOVIM TO MONANT
                 MOVE CODSIS OF REGMOVIM TO SISANT
                 MOVE CODPRO OF REGMOVIM TO PROANT
                 MOVE 1 TO CODERR
                 PERFORM REGRABAR
           ELSE
           IF NOT ERROR-OK THEN
              NEXT SENTENCE
           ELSE
              MOVE 1 TO CODERR
              MOVE AGCCTA OF REGMOVIM TO AGEANT
              MOVE CTANRO OF REGMOVIM TO CTAANT
              MOVE CODMON OF REGMOVIM TO MONANT
              MOVE CODSIS OF REGMOVIM TO SISANT
              MOVE CODPRO OF REGMOVIM TO PROANT
              PERFORM REGRABAR.

           PERFORM VALIDAR-REG
           IF CONT-ERR < 3 THEN
              REWRITE ZONA-CCAMOVIM.
           MOVE 0 TO CONT-ERR CTL-MAXIMO CODERR

           PERFORM LEER-CCAMOVIM
           IF ERROR-CCAMOVIM THEN
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       VALIDAR-REG.
           IF NOT ERROR-MAXIMO THEN
              PERFORM VALIDAR-PARAMETROS
              IF NOT ERROR-MAXIMO THEN
                 PERFORM VALIDAR-FECORI
                 IF NOT ERROR-MAXIMO THEN
                    PERFORM VALIDAR-FECORI-I
                    IF NOT ERROR-MAXIMO THEN
                       PERFORM VALIDAR-FECORI-II
                       IF NOT ERROR-MAXIMO THEN
                         PERFORM VALIDAR-INACTIVA
                         IF NOT ERROR-MAXIMO THEN
                            PERFORM VALIDAR-IND-CUSTODIA
                            IF NOT ERROR-MAXIMO THEN
                               PERFORM VALIDAR-IMPORTE
                               IF NOT ERROR-MAXIMO THEN
                                  PERFORM VALIDAR-AGEORI.
      *--------------------------------------------------------------*
       VALIDAR-PARAMETROS.
           IF CODTRA OF REGMOVIM = 0 THEN
              MOVE 2 TO CODERR
              PERFORM REGRABAR
           ELSE
           IF DEBCRE OF REGMOVIM NOT = DECRE(CODTRA OF REGMOVIM)
              MOVE 2 TO CODERR
              PERFORM REGRABAR
           ELSE
           IF TIPVAL OF REGMOVIM NOT = TIVAL(CODTRA OF REGMOVIM)
              MOVE 2 TO CODERR
              PERFORM REGRABAR.
VG    *    ELSE
VG    *    IF FECVAL OF REGMOVIM NOT = FECVA(CODTRA OF REGMOVIM)
VG    *       MOVE 2 TO CODERR
VG    *       PERFORM REGRABAR.
      *--------------------------------------------------------------*
       VALIDAR-FECORI.
           IF FORIGE OF REGMOVIM NOT = ZEROS THEN
              IF LK-FECHA-HOY NOT = FORIGE OF REGMOVIM  THEN
                 CALL "CCA051P" USING FORIGE OF REGMOVIM W-CODRET
                 IF W-CODRET NOT = 0 THEN
                    MOVE 3 TO CODERR
                    PERFORM REGRABAR
                 ELSE
                    NEXT SENTENCE
              ELSE
                NEXT SENTENCE
           ELSE
             MOVE 3 TO CODERR
             PERFORM REGRABAR.
      *--------------------------------------------------------------*
       VALIDAR-FECORI-I.
           IF FORIGE OF REGMOVIM NOT = ZEROS THEN
              IF FORIGE OF REGMOVIM > LK-FECHA-HOY THEN
                 MOVE 4 TO CODERR
                 PERFORM REGRABAR
              ELSE
                 NEXT SENTENCE
           ELSE
             MOVE 4 TO CODERR
             PERFORM REGRABAR.
      *--------------------------------------------------------------*
       VALIDAR-FECORI-II.
           IF FORIGE OF REGMOVIM = ZEROS THEN
              MOVE 5 TO CODERR
              PERFORM REGRABAR
           ELSE
              IF FORIGE OF REGMOVIM = LK-FECHA-HOY
                 EVALUATE FECVAL OF REGMOVIM
                   WHEN 1 PERFORM FECHAS-HOY
                   WHEN 2 PERFORM FECHAS-24
                   WHEN 3 PERFORM FECHAS-48
                   WHEN 4 PERFORM FECHAS-72
                   WHEN 5 PERFORM FECHAS-96
                   WHEN 6 PERFORM FECHAS-120
                 END-EVALUATE
              ELSE
                 IF FORIGE OF REGMOVIM < LK-FECHA-HOY THEN
                    EVALUATE FECVAL OF REGMOVIM
                      WHEN 1 PERFORM MENOR-FECHA-HOY
                      WHEN OTHER PERFORM CALCULAR-FECHA-DEVOLUCION
                    END-EVALUATE
                 ELSE
                    MOVE 5 TO CODERR
                    PERFORM REGRABAR.
      *--------------------------------------------------------------*
       FECHAS-HOY.
           IF FVALOR OF REGMOVIM = LK-FECHA-HOY THEN
              NEXT SENTENCE
           ELSE
              IF FVALOR OF REGMOVIM < LK-FECHA-HOY THEN
                 NEXT SENTENCE
              ELSE
                 MOVE 5 TO CODERR
                 PERFORM REGRABAR
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       FECHAS-24.
           IF FVALOR OF REGMOVIM = LK-FECHA-MANANA THEN
              NEXT SENTENCE
           ELSE
              IF FVALOR OF REGMOVIM < LK-FECHA-HOY THEN
                 NEXT SENTENCE
              ELSE
                 MOVE 5 TO CODERR
                 PERFORM REGRABAR
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       FECHAS-48.
           IF FVALOR OF REGMOVIM = W-F48 THEN
              NEXT SENTENCE
           ELSE
              IF FVALOR OF REGMOVIM < LK-FECHA-HOY THEN
                 NEXT SENTENCE
              ELSE
                 MOVE 5 TO CODERR
                 PERFORM REGRABAR
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       FECHAS-72.
           IF FVALOR OF REGMOVIM = W-F72 THEN
              NEXT SENTENCE
           ELSE
              IF FVALOR OF REGMOVIM < LK-FECHA-HOY THEN
                 NEXT SENTENCE
              ELSE
                 IF INDCNJ OF REGMOVIM NOT = 2
                    MOVE 5 TO CODERR
                    PERFORM REGRABAR
                 END-IF
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       FECHAS-96.
           IF FVALOR OF REGMOVIM = W-F96 THEN
              NEXT SENTENCE
           ELSE
              IF FVALOR OF REGMOVIM < LK-FECHA-HOY THEN
                 NEXT SENTENCE
              ELSE
                 IF INDCNJ OF REGMOVIM NOT = 2
                    MOVE 5 TO CODERR
                    PERFORM REGRABAR
                 END-IF
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       FECHAS-120.
           IF FVALOR OF REGMOVIM = W-F120 THEN
              NEXT SENTENCE
           ELSE
              IF FVALOR OF REGMOVIM < LK-FECHA-HOY THEN
                 NEXT SENTENCE
              ELSE
                 IF INDCNJ OF REGMOVIM NOT = 2
                    MOVE 5 TO CODERR
                    PERFORM REGRABAR
                 END-IF
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       MENOR-FECHA-HOY.
      *    IF FVALOR OF REGMOVIM = FORIGE OF REGMOVIM
      *       NEXT SENTENCE
      *    ELSE
      *       MOVE 5 TO CODERR
      *       PERFORM REGRABAR
      *    END-IF.
           IF FVALOR OF REGMOVIM = FORIGE OF REGMOVIM
              NEXT SENTENCE
           ELSE
              PERFORM CALCULAR-FECHA
              IF LK219-FECHA3 NOT = FVALOR OF REGMOVIM
                 MOVE 5 TO CODERR
                 PERFORM REGRABAR
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       CALCULAR-FECHA-DEVOLUCION.
           PERFORM CALCULAR-FECHA
VG         EVALUATE FECVAL OF REGMOVIM
VG           WHEN 2 MOVE LK-FECHA-MANANA TO LK219-FECHA3
VG           WHEN 3 MOVE LK-FECHA-PASMAN TO LK219-FECHA3
VG           WHEN 4 MOVE W-F72           TO LK219-FECHA3
VG           WHEN 5 MOVE W-F96           TO LK219-FECHA3
VG           WHEN 6 MOVE W-F120          TO LK219-FECHA3
VG         END-EVALUATE
           IF LK219-FECHA3 NOT = FVALOR OF REGMOVIM THEN
              MOVE 5 TO CODERR
              PERFORM REGRABAR
           ELSE
              NEXT SENTENCE
           END-IF.
      *--------------------------------------------------------------*
       DEVOLVER-FECHA.
           INITIALIZE DIADEV FECDEV

           IF FECVAL OF REGMOVIM = 2 THEN
              MOVE 1 TO DIADEV
           ELSE
              IF FECVAL OF REGMOVIM = 3 THEN
                 MOVE 2 TO DIADEV
              ELSE
                 IF FECVAL OF REGMOVIM = 4 THEN
                    MOVE 3 TO DIADEV
                 ELSE
                    IF FECVAL OF REGMOVIM = 5 THEN
                       MOVE 4 TO DIADEV
                    ELSE
                       MOVE 5 TO DIADEV
                    END-IF
                 END-IF
              END-IF
           END-IF.

           MOVE LK-FECHA-HOY   TO LK219-FECHA1
           MOVE ZEROS    TO LK219-FECHA2
           MOVE ZEROS    TO LK219-FECHA3
           MOVE 1        TO LK219-TIPFMT
           MOVE 2        TO LK219-BASCLC
           MOVE DIADEV   TO LK219-NRODIA
           MOVE 2        TO LK219-INDDSP
           MOVE 9        TO LK219-DIASEM
           MOVE SPACES   TO LK219-NOMDIA
           MOVE SPACES   TO LK219-NOMMES
           MOVE ZEROS    TO LK219-CODRET
           MOVE SPACES   TO LK219-MSGERR
           MOVE 3        TO LK219-TIPOPR
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO FECDEV.
      *--------------------------------------------------------------*
       VALIDAR-FECULR.
           IF NOT ERROR-CCAMAEAHO THEN
              IF FULTRE OF REGMAEAHO NOT = ZEROS THEN
                 IF FORIGE OF REGMOVIM NOT > FULTRE OF REGMAEAHO THEN
                    MOVE 6 TO CODERR
                     PERFORM REGRABAR.
      *--------------------------------------------------------------*
       VALIDAR-IND-CUSTODIA.
           IF NOT ERROR-CCAMAEAHO THEN
              IF INDBLO OF REGMAEAHO = 1
VGQ230           AND USRING OF REGMOVIM NOT = 'RECHAZO'
                 IF DEBCRE OF REGMOVIM = 1 THEN
                    MOVE 8 TO CODERR
                    PERFORM REGRABAR
                 ELSE
                    NEXT SENTENCE
              ELSE
              IF INDBLO OF REGMAEAHO = 2
VGQ230           AND USRING OF REGMOVIM NOT = 'RECHAZO'
                 IF DEBCRE OF REGMOVIM = 2 THEN
                    MOVE 9 TO CODERR
                    PERFORM REGRABAR
                 ELSE
                    NEXT SENTENCE
              ELSE
              IF INDBLO OF REGMAEAHO = 3 THEN
                 MOVE 10 TO CODERR
                 PERFORM REGRABAR.
      *--------------------------------------------------------------*
       VALIDAR-INACTIVA.
           IF NOT ERROR-CCAMAEAHO THEN
              IF INDINA OF REGMAEAHO NOT = ZEROS
                 MOVE USRING OF CCAMOVIM TO KKK-USRINGW
                 IF COD001 OF REGMAEAHO = ZEROS
                   IF KKK-USRING1 NOT = "PLTEMB12"
                    IF ( USRING OF CCAMOVIM NOT = "CONACIONAL" )
                     IF ( DEBCRE OF CCAMOVIM = 1 )
                        MOVE 11 TO CODERR
                        PERFORM REGRABAR
                     END-IF
                    END-IF
                   END-IF
                 ELSE
                   IF KKK-USRING1 NOT = "PLTEMB12"
                    IF ( USRING OF CCAMOVIM NOT = "CONACIONAL" )
                     IF ( DEBCRE OF CCAMOVIM = 1 )
                        MOVE 30 TO CODERR
                        PERFORM REGRABAR
                     END-IF
                    END-IF
                   END-IF
                 END-IF
              ELSE
                 IF INDBAJ OF REGMAEAHO NOT = ZEROS
                    IF FCIERR OF REGMAEAHO NOT = LK-FECHA-HOY
                       IF COD001 OF REGMAEAHO NOT = ZEROS
                          MOVE 31 TO CODERR
                          PERFORM REGRABAR
                       ELSE
                          MOVE 32 TO CODERR
                          PERFORM REGRABAR
                       END-IF
                    ELSE
                      IF ( USRING OF CCAMOVIM = "ORDPAGMU" )
                          MOVE 32 TO CODERR
                          PERFORM REGRABAR
                      END-IF
                    END-IF
                 ELSE
                    IF INDFAL OF REGMAEAHO NOT = ZEROS
                       IF COD001 OF REGMAEAHO NOT = ZEROS
                          MOVE 33 TO CODERR
                          PERFORM REGRABAR
                       ELSE
                          MOVE 12 TO CODERR
                          PERFORM REGRABAR
                       END-IF
                    END-IF
                 END-IF
              END-IF
           END-IF.
      *--------------------------------------------------------------*
       VALIDAR-IMPORTE.
           IF IMPORT OF REGMOVIM = ZEROS THEN
             MOVE 14 TO CODERR
             PERFORM REGRABAR.
      *--------------------------------------------------------------*
       VALIDAR-AGEORI.
           IF AGCORI OF REGMOVIM NOT = ZEROS THEN
             IF AGCORI OF REGMOVIM NOT > 99999 THEN
                IF EXISTE(AGCORI OF REGMOVIM) = 1 THEN
                   NEXT SENTENCE
                ELSE
                  MOVE 15 TO CODERR
                  PERFORM REGRABAR
              ELSE
                MOVE 15 TO CODERR
                PERFORM REGRABAR
           ELSE
              MOVE 15 TO CODERR
              PERFORM REGRABAR.
      *--------------------------------------------------------------*
       VALIDAR-MAESTRO.
           MOVE 0 TO CTL-CCAMAEAHO
           MOVE AGCCTA OF REGMOVIM TO AGCCTA OF REGMAEAHO
           MOVE CTANRO OF REGMOVIM TO CTANRO OF REGMAEAHO
           MOVE CODMON OF REGMOVIM TO CODMON OF REGMAEAHO
           MOVE CODSIS OF REGMOVIM TO CODSIS OF REGMAEAHO
           MOVE CODPRO OF REGMOVIM TO CODPRO OF REGMAEAHO
           READ CCAMAEAHO INVALID KEY MOVE 1 TO CTL-CCAMAEAHO.
           IF NOT ERROR-CCAMAEAHO THEN
VG            IF INDBAJ OF REGMAEAHO NOT = ZEROS THEN
VG               IF FCIERR OF REGMAEAHO NOT = LK-FECHA-HOY
VG                  MOVE 1 TO CTL-CCAMAEAHO.
      *--------------------------------------------------------------*
       LEER-CCAMOVIM.
           MOVE 0 TO CTL-CCAMOVIM
           READ CCAMOVIM NEXT RECORD AT END MOVE 1 TO CTL-CCAMOVIM.
      *--------------------------------------------------------------*
       INIC-TABLA.
           INITIALIZE DECRE(I)
                      TIVAL(I)
                      FECVA(I)
           ADD 1 TO I.
      *--------------------------------------------------------------*
       INIC-TABLA-2.
           INITIALIZE EXISTE(I)
           ADD 1 TO I.
      *--------------------------------------------------------------*
       CARGAR-TABLA.
           MOVE 0 TO CTL-CCACODTRN
           READ CCACODTRN NEXT RECORD AT END MOVE 1 TO CTL-CCACODTRN.
           IF NOT ERROR-CCACODTRN THEN
              MOVE DEBCRE OF REGCODTRN TO DECRE(CODTRA OF REGCODTRN)
              MOVE TIPVAL OF REGCODTRN TO TIVAL(CODTRA OF REGCODTRN)
              MOVE FECVAL OF REGCODTRN TO FECVA(CODTRA OF REGCODTRN).
      *--------------------------------------------------------------*
       CARGAR-TABLA-2.
           MOVE 0 TO CTL-PLTAGCORI
             MOVE PA-CODEMP                TO CODEMP OF PLTAGCORI
             READ PLTAGCORI NEXT RECORD AT END MOVE 1 TO CTL-PLTAGCORI.
             IF NOT ERROR-PLTAGCORI THEN
                IF( PA-CODEMP = CODEMP OF PLTAGCORI)
                    IF AGCORI OF PLTAGCORI > 9999
                       NEXT SENTENCE
                    ELSE
                       MOVE 1 TO EXISTE(AGCORI OF PLTAGCORI)
                    END-IF
                END-IF
           END-IF.
      *--------------------------------------------------------------*
       CARGAR-FECHAS.
           CALL "CCA500" USING LK-FECHAS  .
      *
      *SE AVERIGUA FECHA A 72 HORAS
      *
           MOVE LK-FECHA-HOY    TO LK219-FECHA1
           MOVE LK-FECHA-MANANA TO W-F24
           MOVE LK-FECHA-PASMAN TO W-F48
           MOVE ZEROS    TO LK219-FECHA2
           MOVE ZEROS    TO LK219-FECHA3
           MOVE 1        TO LK219-TIPFMT
           MOVE 2        TO LK219-BASCLC
           MOVE 3        TO LK219-NRODIA
           MOVE 1        TO LK219-INDDSP
           MOVE 9        TO LK219-DIASEM
           MOVE SPACES   TO LK219-NOMDIA
           MOVE SPACES   TO LK219-NOMMES
           MOVE ZEROS    TO LK219-CODRET
           MOVE SPACES   TO LK219-MSGERR
           MOVE 3        TO LK219-TIPOPR
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO W-F72.
           MOVE 4        TO LK219-NRODIA
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO W-F96.
           MOVE 5        TO LK219-NRODIA
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3 TO W-F120.
      *--------------------------------------------------------------*
       REGRABAR.
           IF CODER1 OF REGMOVIM  = ZEROS THEN
              MOVE CODERR TO CODER1 OF REGMOVIM
           ELSE
           IF CODER2 OF REGMOVIM  = ZEROS THEN
              MOVE CODERR TO CODER2 OF REGMOVIM
           ELSE
           IF CODER3 OF REGMOVIM  = ZEROS THEN
              MOVE CODERR TO CODER3 OF REGMOVIM
           ELSE
              NEXT SENTENCE.
           ADD 1 TO CONT-ERR
           IF CONT-ERR = 3 THEN
              REWRITE ZONA-CCAMOVIM
              MOVE 1 TO CTL-MAXIMO.
      *--------------------------------------------------------------*
       CALCULAR-FECHA.
           MOVE FORIGE OF REGMOVIM TO LK219-FECHA1
           MOVE ZEROS              TO LK219-FECHA2
           MOVE ZEROS              TO LK219-FECHA3
           MOVE 1                  TO LK219-TIPFMT
           MOVE 2                  TO LK219-BASCLC
           MOVE FECVAL OF REGMOVIM TO LK219-NRODIA
           SUBTRACT 1 FROM LK219-NRODIA
           MOVE 1                  TO LK219-INDDSP
           MOVE 9                  TO LK219-DIASEM
           MOVE SPACES             TO LK219-NOMDIA
           MOVE SPACES             TO LK219-NOMMES
           MOVE ZEROS              TO LK219-CODRET
           MOVE SPACES             TO LK219-MSGERR
           MOVE 3                  TO LK219-TIPOPR
           PERFORM CALL-PLT219.
      *--------------------------------------------------------------*
       CALL-PLT219.
           CALL "PLT219" USING PA-CODEMP
                               LK219-FECHA1
                               LK219-FECHA2
                               LK219-FECHA3
                               LK219-TIPFMT
                               LK219-BASCLC
                               LK219-NRODIA
                               LK219-INDDSP
                               LK219-DIASEM
                               LK219-NOMDIA
                               LK219-NOMMES
                               LK219-CODRET
                               LK219-MSGERR
                               LK219-TIPOPR.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE CCAMOVIM
                 CCAMAEAHO
                 CCACODTRN
                 PLTAGCORI.
           STOP RUN.
