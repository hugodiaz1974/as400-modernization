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
       PROGRAM-ID.    CCA662.
      ******************************************************************
      * FUNCION: PROGRAMA REALIZA EN MOVIMIENTO CONTABLE DE TRASLADO   *
      *          DE LAS CUENTAS INACTIVAS.                             *
      ******************************************************************
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  05/11/30.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAH14
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT PLTCCACAN
                  ASSIGN               TO DATABASE-PLTCCACAN
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLIMAE
                  ASSIGN               TO DATABASE-CLIMAE
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS OF CCAMAEAH14.
      *
       FD  PLTCCACAN
           LABEL RECORDS ARE STANDARD.
       01  PLTCCACAN-REC.
           COPY DDS-ALL-FORMATS OF PLTCCACAN.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  CLIMAE-REC.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-DIAS                      PIC 9(05)          VALUE ZEROS.
       77  W-DIASINA                   PIC 9(05)          VALUE 90.
       77  W-AGCCTA                    PIC 9(05)          VALUE 90.
       01  W-VLRINA                    PIC 9(13)V99       VALUE ZEROS.
       01  W-VLRACT                    PIC 9(13)V99       VALUE ZEROS.
      *
       01  W-FECINI                    PIC 9(08)          VALUE ZEROS.
       01  R-W-FECINI                  REDEFINES W-FECINI.
           05  W-ANOINI                PIC 9(04).
           05  W-MESINI                PIC 9(02).
           05  W-DIAINI                PIC 9(02).
       01  FILLER                      REDEFINES W-FECINI.
           05  W-ANOMES                PIC 9(06).
           05  W-FILLER                PIC 9(02).
       01  W-FECINI-K                  PIC 9(08)          VALUE ZEROS.
       01  FILLER                      REDEFINES W-FECINI-K.
           05  W-ANOINI-K              PIC 9(06).
           05  W-DIAINI-K              PIC 9(02).
      *
       01  W-FECFIN                    PIC 9(08)          VALUE ZEROS.
       01  R-W-FECFIN                  REDEFINES W-FECFIN.
           05  W-ANOFIN                PIC 9(04).
           05  W-MESFIN                PIC 9(02).
           05  W-DIAFIN                PIC 9(02).
       01  FILLER                      REDEFINES W-FECFIN.
           05  W-FECPRO                PIC 9(06).
           05  W-FILLER                PIC 9(02).
      *--------------------------------------------------------------*
       01 PAR-CODCPT       PIC 9(05) VALUE ZEROS.
       01 PAR-AGENCIA      PIC 9(05) VALUE ZEROS.
       01 PAR-CUENTA       PIC 9(17) VALUE ZEROS.
       01 PAR-AGENVA       PIC 9(05) VALUE ZEROS.
       01 PAR-CODRET       PIC 9(01) VALUE ZEROS.
      *
       01  W-CTANROX                   PIC 9(15)          VALUE ZEROS.
      *
      *Utilizadas para llamar a la rutina PLT201.
       01  W-NROTRN                    PIC 9(09) VALUE ZEROS.
       01  W-CNSTRN                    PIC 9(09) VALUE ZEROS.
       01  W-CODMON                    PIC 9(03) VALUE ZEROS.
      *
       01 W-FIN-CCAMAEAHO               PIC 9(01) VALUE 0.
          88 NO-FIN-CCAMAEAHO                     VALUE 0.
          88 SI-FIN-CCAMAEAHO                     VALUE 1.
      *
       01 W-EXISTE-CLIMAE            PIC 9(01) VALUE 0.
          88 NO-EXISTE-CLIMAE                  VALUE 0.
          88 SI-EXISTE-CLIMAE                  VALUE 1.
      *
      * PARAMETROS RUTINAS
           COPY FECHAS  OF CCACPY.
           COPY PLT219  OF CCACPY.
           COPY PARGEN  OF CCACPY.
           COPY EXTRACT OF PLTCPY.
      *--------------------------------------------------------------
       LINKAGE SECTION.
      *--------------------------------------------------------------
       01  W-CODEMP                    PIC 9(05).
       01  W-AGCORI                    PIC 9(05).
       01  W-CODCAJ                    PIC X(10).
      *--------------------------------------------------------------
       PROCEDURE DIVISION   USING W-CODEMP , W-AGCORI ,
                                             W-CODCAJ .
      *
       COMIENZO.
           PERFORM INICIAR
           PERFORM PROCESAR UNTIL (SI-FIN-CCAMAEAHO)
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
           OPEN INPUT  CLIMAE
           OPEN I-O    PLTCCACAN CCAMAEAHO
           PERFORM CALL-CCA500
           PERFORM CALL-CCA501
           MOVE LK-FECHA-HOY    TO W-FECINI
                                   W-FECINI-K
           MOVE 01              TO W-DIAINI-K
           MOVE LK-FECHA-MANANA TO W-FECFIN
           PERFORM START-CCAMAEAHO.
      *----------------------------------------------------------------
       START-CCAMAEAHO.
           MOVE ZEROS           TO W-FIN-CCAMAEAHO.
           MOVE ZEROS           TO FCIERR OF CCAMAEAHO
           MOVE ZEROS           TO CODMON OF CCAMAEAHO
           MOVE ZEROS           TO CODSIS OF CCAMAEAHO
           MOVE ZEROS           TO CODPRO OF CCAMAEAHO
           MOVE ZEROS           TO AGCCTA OF CCAMAEAHO
           MOVE ZEROS           TO CTANRO OF CCAMAEAHO.
           START CCAMAEAHO KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE 1 TO W-FIN-CCAMAEAHO
           END-START.
           IF (NO-FIN-CCAMAEAHO)
              PERFORM LEER-NEXT-CCAMAEAHO
              IF (NO-FIN-CCAMAEAHO)
                 MOVE 11999662 TO W-NROTRN
                 MOVE 1        TO W-CNSTRN
      *          PERFORM TOMAR-TRANSACCION
              END-IF
           END-IF.
      *----------------------------------------------------------------
       PROCESAR.
           IF (FPULRE OF REG-MAESTR = ZEROS OR
               FCIERR OF REG-MAESTR = LK-FECHA-HOY)
              AND SALACT OF REG-MAESTR NOT = ZEROS
              AND INDBAJ OF REG-MAESTR > ZEROS
              PERFORM GRABAR-MOVIMIENTO
              MOVE LK-FECHA-HOY TO FPULRE OF REG-MAESTR
              REWRITE REG-MAESTR
           END-IF
           PERFORM LEER-NEXT-CCAMAEAHO.
      *----------------------------------------------------------------
       LEER-NEXT-CCAMAEAHO.
           READ CCAMAEAHO NEXT RECORD AT END
                MOVE 1 TO W-FIN-CCAMAEAHO
           END-READ.
      *--------------------------------------------------------------*
       GRABAR-MOVIMIENTO.
           INITIALIZE REGTRNMON OF PLTCCACAN-REC
           MOVE W-CODEMP                TO CODEMP OF PLTCCACAN-REC
           MOVE AGCCTA OF CCAMAEAHO     TO AGCORI OF PLTCCACAN-REC
           MOVE CODMON OF CCAMAEAHO     TO CODMON OF PLTCCACAN-REC
           MOVE W-CODCAJ                TO CODCAJ OF PLTCCACAN-REC
           MOVE W-NROTRN                TO NROTRN OF PLTCCACAN-REC
           MOVE W-CNSTRN                TO CNSTRN OF PLTCCACAN-REC
           ADD 1                        TO W-CNSTRN
           MOVE 99                      TO CODSIS OF PLTCCACAN-REC
           MOVE CODPRO OF CCAMAEAHO     TO CODPRO OF PLTCCACAN-REC
           MOVE 527                     TO CODTRN OF PLTCCACAN-REC
           MOVE 5                       TO MEDPAG OF PLTCCACAN-REC
           MOVE 1                       TO TIPMOV OF PLTCCACAN-REC
           MOVE NITCTA OF CCAMAEAHO     TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           IF ( SI-EXISTE-CLIMAE )
             MOVE NITCLI OF CLIMAE   TO NRONIT OF PLTCCACAN-REC
             MOVE NOMCLI OF CLIMAE   TO INFDEP OF PLTCCACAN-REC
           END-IF
           MOVE AGCCTA OF CCAMAEAHO     TO AGCDST OF PLTCCACAN-REC
           MOVE CTANRO OF CCAMAEAHO     TO CTANRO OF PLTCCACAN-REC
           MOVE 527                     TO CODOPE OF PLTCCACAN-REC
           MOVE SALACT OF CCAMAEAHO     TO VLRTRN OF PLTCCACAN-REC
           IF SALACT OF CCAMAEAHO < ZEROS
              MOVE 530                  TO CODTRN OF PLTCCACAN-REC
                                           CODOPE OF PLTCCACAN-REC
              MOVE 2                    TO TIPMOV OF PLTCCACAN-REC
              COMPUTE VLRTRN OF PLTCCACAN = SALACT OF CCAMAEAHO
                                          * (-1)
           END-IF
           ACCEPT HORTRN OF PLTCCACAN-REC  FROM TIME
           MOVE CTANRO OF CCAMAEAHO     TO NROREF OF PLTCCACAN-REC
           MOVE LK-FECHA-HOY            TO FECEFE OF PLTCCACAN-REC
                                           FECPRO OF PLTCCACAN-REC
           MOVE 0                       TO ESTTRN OF PLTCCACAN-REC
           MOVE W-CODCAJ                TO USRING OF PLTCCACAN-REC
           MOVE AGCCTA OF CCAMAEAHO     TO AGCOPR OF PLTCCACAN-REC
           COMPUTE W-VLRINA = W-VLRINA + VLRTRN OF PLTCCACAN-REC
           WRITE PLTCCACAN-REC
           END-WRITE.
           MOVE W-CNSTRN                TO CNSTRN OF PLTCCACAN-REC
           ADD 1                        TO W-CNSTRN
           MOVE 528                     TO CODTRN OF PLTCCACAN-REC
           MOVE 5                       TO MEDPAG OF PLTCCACAN-REC
           MOVE 2                       TO TIPMOV OF PLTCCACAN-REC
           IF SALACT OF CCAMAEAHO < ZEROS
              MOVE 1                    TO TIPMOV OF PLTCCACAN-REC
              MOVE 529                  TO CODTRN OF PLTCCACAN-REC
           END-IF
           WRITE PLTCCACAN-REC
           END-WRITE.
      *--------------------------------------------------------------*
       TOMAR-TRANSACCION.
           CALL "PLT201"    USING W-CODEMP , W-AGCORI , W-CODCAJ ,
                                             W-CODMON , W-NROTRN.
           MOVE 1                      TO W-CNSTRN.
      *--------------------------------------------------------------*
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS   .
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.
      *----------------------------------------------------------------
       LEER-CLIMAE.
           MOVE 1                      TO W-EXISTE-CLIMAE
           READ CLIMAE               INVALID KEY
                                       MOVE 0 TO W-EXISTE-CLIMAE
           END-READ.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CLIMAE
           CLOSE PLTCCACAN
           CLOSE CCAMAEAHO
           STOP  RUN.
      *----------------------------------------------------------------
