       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CCA760.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: CREACION MAESTRO EN LINEA (CCADEPMAE) A PARTIR DEL  *
      *          CCAMAEAHO JUNTO CON LAS CTAS DE RECHAZO FICTICIAS.  *
      *          INICIALIZACION DE INDICADORES VARIOS EN CCAMAEAHO   *
      *          IND.FICHA CLIENTE. IND.RESUMEN. COPIA BLOQUEOS.     *
      *--------------------------------------------------------------*
      *OJO NUMERO DE CUENTA COMO RECHAZO
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
           SELECT CCADEPMAE
               ASSIGN          TO DATABASE-CCADEPMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACAUSAC
               ASSIGN          TO DATABASE-CCACAUSAC
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACODPRO
               ASSIGN          TO DATABASE-CCACODPRO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS SEQUENTIAL
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
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
      *

       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *
       FD  CCADEPMAE
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCADEPMAE.
           COPY DDS-ALL-FORMATS OF CCADEPMAE.
      *
       FD  CCACAUSAC
           LABEL RECORDS ARE STANDARD.
       01  REG-CAUSAC.
           COPY DDS-ALL-FORMATS OF CCACAUSAC.
      *
       FD  CCACODPRO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACODPRO.
           COPY DDS-ALL-FORMATS OF CCACODPRO.
      *
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  REG-CLIMAE.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
      *
      *
      * ALMACENA FECHA A PARTIR DE LA CUAL NO SE HAN ABONADO LOS
      * INTERESES. CUANDO HAY CORTE, ES EL PRIMER DIA CALENDARIO DEL
      * SIGUIENTE MES. DE RESTO VALE CEROS.
      *
       01  W-FECHACTL               PIC 9(08)            VALUE ZEROS.
       01  R-FECHACTL               REDEFINES W-FECHACTL.
           05  ANO-CTL              PIC 9(04).
           05  MES-CTL              PIC 9(02).
           05  DIA-CTL              PIC 9(02).
      *
       01  CONTROLES.
           05  CTL-CCAMAEAHO           PIC 9(01) VALUE 0.
               88  ERROR-CCAMAEAHO               VALUE 1.
           05  CTL-CCACODPRO           PIC 9(01) VALUE 0.
               88  ERROR-CCACODPRO               VALUE 1.
           05  CTL-CCADEPMAE           PIC 9(01) VALUE 0.
               88  ERROR-CCADEPMAE               VALUE 1.
           05  CTL-CCACAUSAC           PIC 9(01) VALUE 0.
               88  ERROR-CCACAUSAC               VALUE 1.
           05  CTL-PLTAGCORI           PIC 9(01) VALUE 0.
               88  ERROR-PLTAGCORI               VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01) VALUE 0.
               88  FIN-PROGRAMA                  VALUE 1.
           05  CTL-OK                  PIC 9(01) VALUE 0.
               88  ERROR-OK                      VALUE 1.
           05  CTL-RECHAZO             PIC 9(01) VALUE 0.
               88  ERROR-RECHAZO                 VALUE 1.
      *
       01  W-CTANROX                   PIC 9(17)          VALUE ZEROS.
       01  R-W-CTANROX                 REDEFINES W-CTANROX.
           05  FILLER                  PIC X(08).
           05  W-CUENTA                PIC 9(08).
               88  ES-ESPECIAL         VALUE 88888888.
           05  W-DIGITO                PIC 9(01).
      *
       01  VARIABLES.
           05  I                       PIC 9(04) VALUE ZEROS.
           05  W-RECHAZO               PIC 9(17) VALUE ZEROS.
           05  RED-W-RECHAZO           REDEFINES W-RECHAZO.
               10 W-NROAGE             PIC 9(05).
               10 W-NROCTA             PIC 9(12).
           05  W-RECHAZOS              PIC 9(17) VALUE ZEROS.
           05  RED-W-RECHAZOS          REDEFINES W-RECHAZOS.
               10 W-AGCCTAS            PIC 9(05).
               10 W-NROCTAS            PIC 9(12).
      *--------------------------------------------------------------*
       01  TABLA                       PIC X(8991)   VALUE SPACES.
       01  R-TABLA                     REDEFINES     TABLA.
           05  TABLA                   OCCURS        999 TIMES.
               10  T-SALMIN            PIC S9(15)V99 COMP-3.
      *--------------------------------------------------------------*
      * PARAMETROS RUTINA PLT990
       01  PAR-CODCPT                  PIC 9(05).
       01  PAR-AGCORI                  PIC 9(05).
       01  PAR-NROCTA                  PIC 9(17).
       01  PAR-AGCCTA                  PIC 9(05).
       01  PAR-CODRET                  PIC 9(01).
      *
           COPY PARGEN  OF CCACPY.
           COPY FECHAS  OF CCACPY.
      *--------------------------------------------------------------*
      /
       PROCEDURE DIVISION.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN INPUT  CCACAUSAC
                       CLIMAE
                       CCACODPRO
                       PLTAGCORI
                       CCAMAEAHO
                OUTPUT CCADEPMAE.
      *
           MOVE 1 TO I
           PERFORM INIC-TABLA UNTIL I > 999
           MOVE 0 TO CTL-CCACODPRO
           PERFORM CARG-TABLA UNTIL ERROR-CCACODPRO
           PERFORM CALL-CCA500.
      *
           MOVE ZEROS TO W-FECHACTL.
           PERFORM CALL-CCA501
           IF LK-FECHA-HOY > LK-FECLIQ
              IF LK-INDCIE  = 1
                 PERFORM CALC-FECHACTL.
      *
           MOVE 1 TO CTL-OK
           MOVE 0 TO CTL-RECHAZO
           PERFORM LEER-CCAMAEAHO UNTIL NOT ERROR-OK OR ERROR-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       CALC-FECHACTL.
           MOVE LK-FECLIQ              TO W-FECHACTL.
           MOVE 01     TO DIA-CTL.
           ADD   1     TO MES-CTL.
           IF MES-CTL = 13
              MOVE 01  TO MES-CTL
              ADD   1  TO ANO-CTL.
      *--------------------------------------------------------------*
       PROCESAR.
           PERFORM ACTUALIZAR-REGISTRO
           MOVE 1  TO CTL-OK
           MOVE 0  TO CTL-RECHAZO
           PERFORM LEER-CCAMAEAHO UNTIL NOT ERROR-OK OR ERROR-CCAMAEAHO
           IF ERROR-CCAMAEAHO THEN
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       ACTUALIZAR-REGISTRO.
           IF CTANRO OF CCAMAEAHO NOT = 999999
              PERFORM ACTUALIZAR-CCADEPMAE
              WRITE   ZONA-CCADEPMAE INVALID KEY
                   DISPLAY "GRABANDO     : ", NUMAGE OF REGDEPMAE ,
                           "CTA : " , NUMCTA OF REGDEPMAE.
      *--------------------------------------------------------------*
       ACTUALIZAR-CCADEPMAE.
           INITIALIZE REGDEPMAE
           MOVE CODMON OF REGMAEAHO TO CODMON OF REGDEPMAE
           MOVE CODSIS OF REGMAEAHO TO CODSIS OF REGDEPMAE
           MOVE CODPRO OF REGMAEAHO TO CODPRO OF REGDEPMAE
           MOVE AGCCTA OF REGMAEAHO TO NUMAGE OF REGDEPMAE
           MOVE INTREM OF REGMAEAHO TO INTREM OF REGDEPMAE
           MOVE RETREM OF REGMAEAHO TO RETREM OF REGDEPMAE.
           IF NOT ERROR-RECHAZO THEN
              MOVE CTANRO OF REGMAEAHO TO NUMCTA OF REGDEPMAE
      *       PERFORM CALC-INT-RET
           ELSE
              MOVE W-RECHAZOS          TO NUMCTA OF REGDEPMAE.
           MOVE CODPRO OF REGMAEAHO TO CODPRO OF REGDEPMAE
           MOVE NITCTA OF REGMAEAHO TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           MOVE NITCLI OF CLIMAE    TO NITCTA OF REGDEPMAE
           MOVE ZEROS               TO CLACTA OF REGDEPMAE
           MOVE DESCRI OF REGMAEAHO TO NOMCTA OF REGDEPMAE
           MOVE FULMOV OF REGMAEAHO TO FULMOV OF REGDEPMAE
           MOVE FAPERT OF REGMAEAHO TO FAPERT OF REGDEPMAE
           MOVE INDEMB OF REGMAEAHO TO INDEMB OF REGDEPMAE
           MOVE INDBLO OF REGMAEAHO TO INDBLO OF REGDEPMAE
           MOVE INDBLO OF REGMAEAHO TO CODBLO OF REGDEPMAE
           MOVE INDINA OF REGMAEAHO TO INDINA OF REGDEPMAE
           MOVE INDFAL OF REGMAEAHO TO INDFAL OF REGDEPMAE
           MOVE ZEROS               TO INDCAN OF REGDEPMAE
           MOVE ZEROS               TO INDSLD OF REGDEPMAE
           MOVE INDSVB OF REGMAEAHO TO INDSVB OF REGDEPMAE
           MOVE INDCBC OF REGMAEAHO TO INDCBC OF REGDEPMAE
           MOVE ZEROS               TO INDINT OF REGDEPMAE
      *    MOVE ZEROS               TO INDRAP OF REGDEPMAE
      *    MOVE ZEROS               TO INDFIC OF REGDEPMAE
      *    MOVE INDCNN OF REGMAEAHO TO INDCNN OF REGDEPMAE
           MOVE NITCT2 OF REGMAEAHO TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           MOVE NITCLI OF CLIMAE    TO CLAVE2 OF REGDEPMAE
           MOVE NITCT3 OF REGMAEAHO TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           MOVE NITCLI OF CLIMAE    TO CLAVE3 OF REGDEPMAE
           MOVE TIPCTA OF REGMAEAHO TO TIPCTA OF REGDEPMAE
      *    MOVE CODNDI OF REGMAEAHO TO CODNDI OF REGDEPMAE
      *    MOVE PUNADI OF REGMAEAHO TO PUNADI OF REGDEPMAE
           MOVE ZEROS               TO INTSOB OF REGDEPMAE
           MOVE ZEROS               TO CANDEV OF REGDEPMAE
           MOVE ZEROS               TO VALDEV OF REGDEPMAE
           MOVE ZEROS               TO FULDEV OF REGDEPMAE
      * ----------------------------------------
           IF INDBAJ OF REGMAEAHO NOT = ZEROS
              IF MOTBAJ OF REGMAEAHO = ZEROS
                 MOVE 1 TO INDSLD OF REGDEPMAE
              ELSE
                 MOVE 1 TO INDCAN OF REGDEPMAE
              END-IF
           END-IF
      * ----------------------------------------
      *    MOVE INDBAJ OF REGMAEAHO TO INDCAN OF REGDEPMAE
           MOVE FCIERR OF REGMAEAHO TO FCANCE OF REGDEPMAE
           MOVE T-SALMIN(CODPRO OF REGMAEAHO)
                                    TO SALMIN OF REGDEPMAE
           MOVE ZEROS               TO SOBCUP OF REGDEPMAE
           MOVE ZEROS               TO FULSOB OF REGDEPMAE
           MOVE SALACT OF REGMAEAHO TO SALINI OF REGDEPMAE
           COMPUTE DEP24 OF REGDEPMAE =
                   DEP24 OF REGMAEAHO +
                   DEP48 OF REGMAEAHO +
                   DEP72 OF REGMAEAHO
           MOVE ZEROS               TO DEP48  OF REGDEPMAE
           MOVE ZEROS               TO DEP72  OF REGDEPMAE
           MOVE CTAMEG OF REGMAEAHO TO CTAMEG OF REGDEPMAE
           MOVE VLRPIG OF REGMAEAHO TO VLRPIG OF REGDEPMAE
           MOVE NRODSO OF REGMAEAHO TO NRODSO OF REGDEPMAE
           MOVE DDSBGO OF REGMAEAHO TO DDSBGO OF REGDEPMAE
           MOVE FINSOB OF REGMAEAHO TO SOBRE  OF REGDEPMAE
           MOVE ZEROS               TO DEPEFE OF REGDEPMAE
                                       NOTCRE OF REGDEPMAE
                                       CORCRE OF REGDEPMAE
                                       RETEFE OF REGDEPMAE
                                       RETCHE OF REGDEPMAE
                                       NOTDEB OF REGDEPMAE
                                       CORDEB OF REGDEPMAE
                                       INCCAM OF REGDEPMAE
                                       CTAESP OF REGDEPMAE.
      *--------------------------------------------------------------*
       LEER-CCAMAEAHO.
           MOVE 0 TO CTL-CCAMAEAHO
           READ CCAMAEAHO NEXT RECORD AT END MOVE 1 TO CTL-CCAMAEAHO.
           IF NOT ERROR-CCAMAEAHO THEN
VG    *       IF INDBAJ OF REGMAEAHO = ZEROS THEN
                 MOVE CTANRO OF REGMAEAHO TO W-CTANROX
                 IF ES-ESPECIAL
                    PERFORM CALC-RECH-LIN
                    MOVE 0 TO CTL-OK
                 ELSE
                    MOVE 0 TO CTL-OK.
      *---------------------------------------------------------------*
       CALC-RECH-LIN.
           PERFORM LEER-PLTAGCORI
           IF (ERROR-PLTAGCORI)
              MOVE AGCCTA OF REGMAEAHO TO PAR-AGCORI
           ELSE
              MOVE AGCPPL OF REGAGCORI TO PAR-AGCORI
           END-IF
           MOVE 2                   TO PAR-CODCPT
           MOVE AGCCTA OF REGMAEAHO TO PAR-AGCORI
           MOVE 0                   TO PAR-NROCTA
                                       PAR-AGCCTA
                                       PAR-CODRET
           CALL "CCA990" USING PAR-CODCPT PAR-AGCORI PAR-NROCTA
                               PAR-AGCCTA PAR-CODRET
           MOVE PAR-AGCCTA          TO W-AGCCTAS
           MOVE PAR-NROCTA          TO W-NROCTAS
           MOVE 1                   TO CTL-RECHAZO.
      *---------------------------------------------------------------*
       LEER-PLTAGCORI.
           READ PLTAGCORI
                INVALID     MOVE 1     TO CTL-PLTAGCORI
                NOT INVALID MOVE 0     TO CTL-PLTAGCORI
           END-READ.
      *---------------------------------------------------------------*
       CALC-INT-RET.
           MOVE NITCTA OF REGMAEAHO TO NUMINT OF REG-CLIMAE.
           PERFORM LEER-CLIMAE.
           MOVE 0  TO CTL-CCACAUSAC.
           MOVE CODMON OF REGMAEAHO TO CODMON OF REGCAUSAC
           MOVE CODSIS OF REGMAEAHO TO CODSIS OF REGCAUSAC
           MOVE CODPRO OF REGMAEAHO TO CODPRO OF REGCAUSAC
           MOVE AGCCTA OF REGMAEAHO TO AGCCTA OF REGCAUSAC
           MOVE CTANRO OF REGMAEAHO TO CTANRO OF REGCAUSAC
           MOVE W-FECHACTL          TO FORIGE OF REGCAUSAC.
           START CCACAUSAC KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE 1 TO CTL-CCACAUSAC.
           IF NOT ERROR-CCACAUSAC
              PERFORM LEER-CCACAUSAC UNTIL ERROR-CCACAUSAC.
      *       IF INTREM OF REGDEPMAE > 0
      *          IF RETFTE OF REG-CLIMAE = 0
      *             MOVE ZEROS TO RETREM OF REGDEPMAE.
      *----------------------------------------------------------------
       LEER-CCACAUSAC.
           READ CCACAUSAC NEXT AT END
                MOVE 1 TO CTL-CCACAUSAC.
           IF NOT ERROR-CCACAUSAC
              IF CODMON OF REGCAUSAC NOT = CODMON OF REGMAEAHO OR
                 CODSIS OF REGCAUSAC NOT = CODSIS OF REGMAEAHO OR
                 CODPRO OF REGCAUSAC NOT = CODPRO OF REGMAEAHO OR
                 AGCCTA OF REGCAUSAC NOT = AGCCTA OF REGMAEAHO OR
                 CTANRO OF REGCAUSAC NOT = CTANRO OF REGMAEAHO
                 MOVE 1 TO CTL-CCACAUSAC
              ELSE
                 ADD VALCAU OF REGCAUSAC TO INTREM OF REGDEPMAE
                 ADD VLRRET OF REGCAUSAC TO RETREM OF REGDEPMAE.
      *----------------------------------------------------------------
       LEER-CLIMAE.
      *    MOVE NITCTA OF REGMAEAHO TO NUMINT OF REG-CLIMAE.
           READ CLIMAE INVALID KEY
                MOVE ZEROS TO NITCLI OF CLIMAE
                MOVE 0 TO RETFTE OF REG-CLIMAE.
      *----------------------------------------------------------------
       BORRAR-CCADEPMAE.
           READ CCADEPMAE NEXT AT END
                MOVE 1 TO CTL-CCADEPMAE.
      *    IF NOT ERROR-CCADEPMAE
      *       IF CODPRO OF REGDEPMAE NOT = 2
      *          MOVE 1 TO CTL-CCADEPMAE
      *       ELSE
      *          DELETE CCADEPMAE.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS.
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.

      *---------------------------------------------------------------*
       INIC-TABLA.
           INITIALIZE T-SALMIN(I)
           ADD 1 TO I.
      *---------------------------------------------------------------*
       CARG-TABLA.
           MOVE 0 TO CTL-CCACODPRO
           READ CCACODPRO NEXT RECORD AT END MOVE 1 TO CTL-CCACODPRO.
           IF NOT ERROR-CCACODPRO THEN
             MOVE VMCUEN OF REGCODPRO TO T-SALMIN(CODPRO OF REGCODPRO).
      *---------------------------------------------------------------*
       TERMINAR.
           CLOSE CCACAUSAC
                 CCAMAEAHO
                 CCACODPRO
                 PLTAGCORI
                 CCADEPMAE
                 CLIMAE.
           STOP RUN.
