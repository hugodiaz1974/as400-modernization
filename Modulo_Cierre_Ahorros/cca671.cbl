       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CCA671.
      ******************************************************************
      * FUNCION: PROGRAMA DE ACTUALIZACION DE ARCHIVO DE CUADRE        *
      *          CUADRE GENERAL X OFICINA PLTCUADRE                    *
      ******************************************************************
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  97/09/30.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT PLTCUADRE
               ASSIGN          TO DATABASE-PLTCUADRE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO3
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT CLIMAE
               ASSIGN          TO DATABASE-CLIMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  PLTCUADRE
           LABEL RECORDS ARE STANDARD.
       01  REG-CUADRE.
           COPY DDS-ALL-FORMATS OF PLTCUADRE.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO3.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIMAE.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  REG-AGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-AGCCTA                    PIC 9(05)          VALUE ZEROS.
       77  W-CODPRO                    PIC 9(05)          VALUE ZEROS.
       77  W-NITCLI                    PIC 9(17)          VALUE ZEROS.
       77  W-CAN                       PIC 9(05)          VALUE ZEROS.
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC X(02) VALUE "NO".
               88  FIN-CCAMAEAHO                  VALUE "SI".
               88  NO-FIN-CCAMAEAHO               VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
           05  CTL-CLIMAE              PIC 9     VALUE 0.
               88  SI-EXISTE-CLIMAE              VALUE 1.
               88  NO-EXISTE-CLIMAE              VALUE 0.
           05  CTL-PLTCUADRE           PIC 9     VALUE 0.
               88  SI-EXISTE-PLTCUADRE           VALUE 1.
               88  NO-EXISTE-PLTCUADRE           VALUE 0.
           05  CTL-PLTAGCORI           PIC 9     VALUE 0.
               88  SI-EXISTE-PLTAGCORI           VALUE 1.
               88  NO-EXISTE-PLTAGCORI           VALUE 0.
           05  CTL-GRABAR              PIC 9     VALUE 0.
               88  FALTA-GRABAR                  VALUE 1.
               88  GRABO-REGISTRO                VALUE 0.
      *
      * PARAMETROS RUTINAS
           COPY FECHAS  OF CCACPY.
      ***************************************************************
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMAEAHO
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           OPEN INPUT  CCAMAEAHO CLIMAE PLTAGCORI
           OPEN I-O    PLTCUADRE.
           PERFORM CALL-CCA500.
      *
           MOVE "NO"  TO CTL-CCAMAEAHO.
           MOVE ZEROS TO CTL-GRABAR
           MOVE ZEROS TO AGCCTA OF REG-MAEAHO W-AGCCTA
           MOVE ZEROS TO CODPRO OF REG-MAEAHO W-CODPRO
           MOVE ZEROS TO NITCTA OF REG-MAEAHO W-NITCLI
           START CCAMAEAHO KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY
                 MOVE "SI" TO CTL-CCAMAEAHO
           END-START.
           MOVE "NO" TO CTL-REGISTRO.
           IF (NO-FIN-CCAMAEAHO)
              PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                      OR FIN-CCAMAEAHO
           END-IF.
           PERFORM INICIALIZAR-REGISTRO.
      *----------------------------------------------------------------
       PROCESAR.
           IF AGCCTA OF CCAMAEAHO NOT = W-AGCCTA OR
              CODPRO OF CCAMAEAHO NOT = W-CODPRO
              PERFORM GRABAR-REGISTRO
              MOVE 0 TO CTL-GRABAR
              PERFORM INICIALIZAR-REGISTRO
           END-IF.
           IF ( NITCTA NOT = W-NITCLI )
              MOVE NITCTA OF CCAMAEAHO TO NUMINT OF CLIMAE W-NITCLI
              PERFORM LEER-CLIMAE
              IF (SI-EXISTE-CLIMAE)
                 IF ASOCIA OF CLIMAE = 1
                    ADD 1              TO NROASO OF PLTCUADRE
                 END-IF
              END-IF
           END-IF.
           PERFORM ACUMULAR-DATOS
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMAEAHO UNTIL REGISTRO-VALIDO
                   OR FIN-CCAMAEAHO.
      *----------------------------------------------------------------
       ACUMULAR-DATOS.
           ADD SALANT OF CCAMAEAHO     TO SALANT OF PLTCUADRE
           ADD SALACT OF CCAMAEAHO     TO SALDIS OF PLTCUADRE
           ADD VALCOB OF CCAMAEAHO     TO SALREM OF PLTCUADRE
           ADD DEP24  OF CCAMAEAHO     TO DEPA24 OF PLTCUADRE
           ADD DEP48  OF CCAMAEAHO     TO DEPA48 OF PLTCUADRE
           ADD DEP72  OF CCAMAEAHO     TO DEPA72 OF PLTCUADRE
           IF INDINA OF CCAMAEAHO = ZEROS
              ADD  SALACT OF CCAMAEAHO TO SALACT OF PLTCUADRE
           ELSE
              ADD  SALACT OF CCAMAEAHO TO SALINA OF PLTCUADRE
           END-IF.
           ADD 1                       TO NROCTA OF PLTCUADRE.
           IF SALACT OF CCAMAEAHO < ZEROS
              ADD SALACT OF CCAMAEAHO  TO SALNEG OF PLTCUADRE
           ELSE
              ADD SALACT OF CCAMAEAHO  TO SALPOS OF PLTCUADRE
           END-IF.
           ADD DEBDIA OF CCAMAEAHO     TO DEBDIA OF PLTCUADRE.
           ADD CREDIA OF CCAMAEAHO     TO CREDIA OF PLTCUADRE.
           MOVE 1 TO CTL-GRABAR.
      *----------------------------------------------------------------
       LEER-CCAMAEAHO.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMAEAHO NEXT RECORD AT END
                MOVE "SI" TO CTL-CCAMAEAHO
           END-READ.
           IF NO-FIN-CCAMAEAHO
              IF INDBAJ OF CCAMAEAHO NOT = ZEROS
                 AND SALACT OF CCAMAEAHO = ZEROS
                 MOVE "NO" TO CTL-REGISTRO
              END-IF
           END-IF.
      *----------------------------------------------------------------
       INICIALIZAR-REGISTRO.
           INITIALIZE REGCUADRE.
           MOVE LK-FECHA-HOY        TO FECSAL OF PLTCUADRE
           MOVE AGCCTA OF CCAMAEAHO TO AGCCTA OF PLTCUADRE W-AGCCTA
           MOVE CODSIS OF CCAMAEAHO TO CODSIS OF PLTCUADRE
           MOVE CODPRO OF CCAMAEAHO TO CODPRO OF PLTCUADRE W-CODPRO
           MOVE CODMON OF CCAMAEAHO TO CODMON OF PLTCUADRE.
           MOVE NITCTA OF CCAMAEAHO TO NUMINT OF CLIMAE W-NITCLI
           PERFORM LEER-CLIMAE
           IF (SI-EXISTE-CLIMAE)
              IF ASOCIA OF CLIMAE = 1
                 ADD 1              TO NROASO OF PLTCUADRE
              END-IF
           END-IF.
           MOVE AGCCTA OF CCAMAEAHO TO AGCORI OF PLTAGCORI
           PERFORM LEER-PLTAGCORI
           IF (SI-EXISTE-PLTAGCORI)
              MOVE CODREG OF PLTAGCORI TO CODREG OF PLTCUADRE
              MOVE CODSUC OF PLTAGCORI TO CODSUC OF PLTCUADRE
           END-IF.
      *----------------------------------------------------------------
       LEER-PLTCUADRE.
           MOVE 1 TO CTL-PLTCUADRE.
           READ PLTCUADRE INVALID KEY
                MOVE ZEROS TO CTL-PLTCUADRE.
      *----------------------------------------------------------------
       LEER-PLTAGCORI.
           MOVE 1 TO CTL-PLTAGCORI.
           READ PLTAGCORI INVALID KEY
                MOVE ZEROS TO CTL-PLTAGCORI.
      *----------------------------------------------------------------
       LEER-CLIMAE.
           MOVE 1 TO CTL-CLIMAE
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO CTL-CLIMAE.
      *----------------------------------------------------------------
       GRABAR-REGISTRO.
           WRITE REG-CUADRE
                 INVALID KEY
                   PERFORM REGRABAR-REGISTRO
           END-WRITE.
      *----------------------------------------------------------------
       REGRABAR-REGISTRO.
           REWRITE REG-CUADRE.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.

      *----------------------------------------------------------------
       TERMINAR.
           IF FALTA-GRABAR
              PERFORM GRABAR-REGISTRO
           END-IF
           CLOSE PLTCUADRE CLIMAE
                 CCAMAEAHO PLTAGCORI.
           STOP  RUN      .
      *----------------------------------------------------------------
