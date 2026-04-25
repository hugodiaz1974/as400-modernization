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
       PROGRAM-ID.    CCA665.
      ******************************************************************
      * FUNCION: PROGRAMA REALIZA EN MOVIMIENTO CONTABLE DE TRASLADO   *
      *          DE LAS CUENTAS INACTIVAS.                             *
      ******************************************************************
       AUTHOR.        HUGO HERNANDO DIAZ.
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
               ASSIGN          TO DATABASE-CCAMAEAH12
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *
           SELECT PLTCCAINA
                  ASSIGN               TO DATABASE-PLTCCAINA
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTTRNMON
                  ASSIGN               TO DATABASE-PLTTRNMON
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
           COPY DDS-ALL-FORMATS OF CCAMAEAH12.
      *
       FD  PLTCCAINA
           LABEL RECORDS ARE STANDARD.
       01  PLTCCAINA-REC.
           COPY DDS-ALL-FORMATS OF PLTCCAINA.
      *
       FD  PLTTRNMON
           LABEL RECORDS ARE STANDARD.
       01  PLTTRNMON-REC.
           COPY DDS-ALL-FORMATS OF PLTTRNMON.
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
           OPEN I-O    PLTCCAINA PLTTRNMON CCAMAEAHO
           PERFORM CALL-CCA500
           PERFORM CALL-CCA501
           MOVE LK-FECHA-HOY    TO W-FECINI
                                   W-FECINI-K
           MOVE 01              TO W-DIAINI-K
           MOVE LK-FECHA-MANANA TO W-FECFIN
           IF ( W-MESINI = W-MESFIN )
              PERFORM TERMINAR
           ELSE
              PERFORM START-CCAMAEAHO
           END-IF.
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
                 MOVE 11999661 TO W-NROTRN
                 MOVE 1        TO W-CNSTRN
      *          PERFORM TOMAR-TRANSACCION
              END-IF
           END-IF.
      *----------------------------------------------------------------
       PROCESAR.
           IF COD001 OF REG-MAESTR = ZEROS
              AND CODPRO OF REG-MAESTR NOT = 32
              IF LIBRE OF REG-MAESTR(84:8) = '00000000' OR '        '
                 PERFORM GRABAR-MOVIMIENTO
                 MOVE LK-FECHA-HOY TO LIBRE OF REG-MAESTR(84:8)
                 REWRITE REG-MAESTR INVALID KEY
                         CONTINUE
                 END-REWRITE
              END-IF
           END-IF
           PERFORM LEER-NEXT-CCAMAEAHO.
      *----------------------------------------------------------------
       LEER-NEXT-CCAMAEAHO.
           READ CCAMAEAHO NEXT RECORD AT END
                MOVE 1 TO W-FIN-CCAMAEAHO
           END-READ.
      *--------------------------------------------------------------*
       GRABAR-MOVIMIENTO.
           INITIALIZE REGTRNMON OF PLTCCAINA-REC
           MOVE W-CODEMP                TO CODEMP OF PLTCCAINA-REC
           MOVE AGCCTA OF CCAMAEAHO     TO AGCORI OF PLTCCAINA-REC
           MOVE CODMON OF CCAMAEAHO     TO CODMON OF PLTCCAINA-REC
           MOVE W-CODCAJ                TO CODCAJ OF PLTCCAINA-REC
           MOVE W-NROTRN                TO NROTRN OF PLTCCAINA-REC
           MOVE W-CNSTRN                TO CNSTRN OF PLTCCAINA-REC
           ADD 1                        TO W-CNSTRN
           MOVE 99                      TO CODSIS OF PLTCCAINA-REC
           MOVE CODPRO OF CCAMAEAHO     TO CODPRO OF PLTCCAINA-REC
           MOVE 500                     TO CODTRN OF PLTCCAINA-REC
           MOVE 5                       TO MEDPAG OF PLTCCAINA-REC
           MOVE 1                       TO TIPMOV OF PLTCCAINA-REC
           MOVE NITCTA OF CCAMAEAHO     TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           IF ( SI-EXISTE-CLIMAE )
             MOVE NITCLI OF CLIMAE   TO NRONIT OF PLTCCAINA-REC
             MOVE NOMCLI OF CLIMAE   TO INFDEP OF PLTCCAINA-REC
           END-IF
           MOVE AGCCTA OF CCAMAEAHO     TO AGCDST OF PLTCCAINA-REC
           MOVE CTANRO OF CCAMAEAHO     TO CTANRO OF PLTCCAINA-REC
           MOVE 500                     TO CODOPE OF PLTCCAINA-REC
           MOVE SALACT OF CCAMAEAHO     TO VLRTRN OF PLTCCAINA-REC
           IF SALACT OF CCAMAEAHO < ZEROS
              MOVE 505                  TO CODTRN OF PLTCCAINA-REC
                                           CODOPE OF PLTCCAINA-REC
              MOVE 2                    TO TIPMOV OF PLTCCAINA-REC
              COMPUTE VLRTRN OF PLTCCAINA = SALACT OF CCAMAEAHO
                                          * (-1)
           END-IF
           ACCEPT HORTRN OF PLTCCAINA-REC  FROM TIME
           MOVE CTANRO OF CCAMAEAHO     TO NROREF OF PLTCCAINA-REC
           MOVE LK-FECHA-HOY            TO FECEFE OF PLTCCAINA-REC
                                           FECPRO OF PLTCCAINA-REC
           MOVE 0                       TO ESTTRN OF PLTCCAINA-REC
           MOVE W-CODCAJ                TO USRING OF PLTCCAINA-REC
           MOVE AGCCTA OF CCAMAEAHO     TO AGCOPR OF PLTCCAINA-REC
           COMPUTE W-VLRINA = W-VLRINA + VLRTRN OF PLTCCAINA-REC
           WRITE PLTCCAINA-REC
           END-WRITE.
           MOVE W-CNSTRN                TO CNSTRN OF PLTCCAINA-REC
           ADD 1                        TO W-CNSTRN
           MOVE 501                     TO CODTRN OF PLTCCAINA-REC
           MOVE 5                       TO MEDPAG OF PLTCCAINA-REC
           MOVE 2                       TO TIPMOV OF PLTCCAINA-REC
           IF SALACT OF CCAMAEAHO < ZEROS
              MOVE 1                    TO TIPMOV OF PLTCCAINA-REC
              MOVE 506                  TO CODTRN OF PLTCCAINA-REC
           END-IF
           WRITE PLTCCAINA-REC
           END-WRITE.
           PERFORM GRABAR-PASO-ACTIVA.
      *--------------------------------------------------------------*
       GRABAR-PASO-ACTIVA.
           INITIALIZE REGTRNMON OF PLTTRNMON-REC
           MOVE CORR REGTRNMON OF PLTCCAINA-REC TO
                     REGTRNMON OF PLTTRNMON-REC
           MOVE W-CNSTRN                TO CNSTRN OF PLTTRNMON-REC
           ADD 1                        TO W-CNSTRN
           MOVE LK-FECHA-MANANA         TO FECPRO OF PLTTRNMON-REC
                                           FECEFE OF PLTTRNMON-REC
           MOVE 503                     TO CODTRN OF PLTTRNMON-REC
           MOVE 5                       TO MEDPAG OF PLTTRNMON-REC
           MOVE 1                       TO TIPMOV OF PLTTRNMON-REC
           IF SALACT OF CCAMAEAHO < ZEROS
              MOVE 2                    TO TIPMOV OF PLTTRNMON-REC
              MOVE 507                  TO CODTRN OF PLTTRNMON-REC
           END-IF
           COMPUTE W-VLRACT = W-VLRACT + VLRTRN OF PLTTRNMON-REC
           WRITE PLTTRNMON-REC
           END-WRITE.
           MOVE W-CNSTRN                TO CNSTRN OF PLTTRNMON-REC
           ADD 1                        TO W-CNSTRN
           MOVE 504                     TO CODTRN OF PLTTRNMON-REC
           MOVE 5                       TO MEDPAG OF PLTTRNMON-REC
           MOVE 2                       TO TIPMOV OF PLTTRNMON-REC
           IF SALACT OF CCAMAEAHO < ZEROS
              MOVE 1                    TO TIPMOV OF PLTTRNMON-REC
              MOVE 508                  TO CODTRN OF PLTTRNMON-REC
           END-IF
           WRITE PLTTRNMON-REC
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
           CLOSE PLTCCAINA
           CLOSE CCAMAEAHO
           CLOSE PLTTRNMON
           STOP  RUN.
      *----------------------------------------------------------------
