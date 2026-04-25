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
       PROGRAM-ID.    CCA590.
      ******************************************************************
      * FUNCION: PROGRAMA DE GENERACION DE ARCHIVO DE BASE (CCAMOVACE)  *
      *          PARA POSTERIOR GENERACION DE ARCHIVO DE CONTROL       *
      *          DE RETROFECHAS ORIGINADAS EN EL DIA (CARETROF).       *
      *          EL ARCHIVO DE BASE SE DIFERENCIA DEL ARCHIVO DE
      *          ENTRADA EN QUE LOS MOVIMIENTOS DE INTERESES Y         *
      *          RETENCION SE GRABAN CON UN DIA CALENDARIO ADELANTE,   *
      *          PARA EFECTOS DE AJUSTAR LA CAUSACION CON BASE EN
      *          SALDOS REALES OBTENIDOS A PARTIR DE UN DIA CALENDARIO *
      *          DESPUES DE HECHO EL ABONO Y RETENCION.
      *          ADEMAS SOLO SE SELECCIONAN REGISTROS CON RETROFECHA.
      *          EL ARCHIVO DE ENTRADA ESTA ORDENADO POR FECHA ORIGEN.
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/09/30.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM02
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT CCAMOVACE
               ASSIGN          TO DATABASE-CCAMOVACE
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVIM02.
      *
       FD  CCAMOVACE
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVACE.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-FECHACTL                  PIC 9(08)          VALUE ZEROS.
       77  W-FECHASIG                  PIC 9(08)          VALUE ZEROS.
       77  W-CODTRA                    PIC 9(03)          VALUE ZEROS.
      *    88  ES-INTERES              VALUE 018.
      *    88  ES-RETENCION            VALUE 108.
      *
       01  CONTROLES.
           05  CTL-CCAMOVIM             PIC X(02) VALUE "NO".
               88  FIN-CCAMOVIM                   VALUE "SI".
               88  NO-FIN-CCAMOVIM                VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
       01  PA-CODEMP                   PIC 9(05)          VALUE ZEROS.
      *
      * ------------------------
      * VARIABLES-ENCADENAR.
           COPY PARGEN OF CCACPY.
           COPY FECHAS OF CCACPY.
           COPY PLT219 OF CCACPY.
      ***************************************************************
      *
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMOVIM.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN INPUT  CCAMOVIM .
           OPEN OUTPUT CCAMOVACE.
      *
           CALL "PLTCODEMPP"          USING PA-CODEMP
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
      *
           MOVE "NO" TO CTL-CCAMOVIM.
           MOVE ZEROS TO FORIGE OF CCAMOVIM
           START CCAMOVIM  KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE "SI" TO CTL-CCAMOVIM.
      *
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVIM  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVIM.
      *----------------------------------------------------------------
       PROCESAR.
           IF FORIGE OF REG-MOVIM NOT = W-FECHACTL
              MOVE FORIGE OF REG-MOVIM TO W-FECHACTL
              PERFORM SUME-UN-DIA-CALENDARIO.
      *
           IF W-FECHASIG < LK-FECHA-HOY
              MOVE REG-MOVIM  TO REG-MOVACE
              MOVE W-FECHASIG TO FORIGE OF REG-MOVACE
              MOVE W-FECHASIG TO FVALOR OF REG-MOVACE
              WRITE REG-MOVACE.
      *
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVIM  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVIM.
      *----------------------------------------------------------------
       LEER-CCAMOVIM.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMOVIM AT END
                MOVE "SI" TO CTL-CCAMOVIM.
           IF NO-FIN-CCAMOVIM
              MOVE CODTRA OF REG-MOVIM TO W-CODTRA
              IF (W-CODTRA NOT = LK-TRAINT) AND
                 (W-CODTRA NOT = LK-TRARET)
      *       IF NOT ES-INTERES AND NOT ES-RETENCION
                 MOVE "NO"      TO CTL-REGISTRO
                 IF FORIGE OF REG-MOVIM < LK-FECHA-HOY
                    MOVE REG-MOVIM TO REG-MOVACE
                    WRITE REG-MOVACE.
      *----------------------------------------------------------------
       SUME-UN-DIA-CALENDARIO.
           MOVE W-FECHACTL TO LK219-FECHA1
           MOVE ZEROS      TO LK219-FECHA2
           MOVE ZEROS      TO LK219-FECHA3
           MOVE 1          TO LK219-TIPFMT
           MOVE 2          TO LK219-BASCLC
           MOVE 1          TO LK219-NRODIA
           MOVE 1          TO LK219-INDDSP
           MOVE 9          TO LK219-DIASEM
           MOVE SPACES     TO LK219-NOMDIA
           MOVE SPACES     TO LK219-NOMMES
           MOVE ZEROS      TO LK219-CODRET
           MOVE SPACES     TO LK219-MSGERR
           MOVE 2          TO LK219-TIPOPR.
           PERFORM CALL-PLT219.
           MOVE LK219-FECHA3   TO W-FECHASIG.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.

      *----------------------------------------------------------------
       CALL-PLT219.
           CALL "PLT219" USING PA-CODEMP, LK219-FECHA1
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
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMOVIM  .
           CLOSE CCAMOVACE .
           STOP  RUN      .
      *----------------------------------------------------------------
