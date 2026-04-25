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
       PROGRAM-ID.    CCA530.
       AUTHOR.        M.H.D.
       DATE-WRITTEN.  97/10/01.
      ******************************************************************
      * FUNCION: VALIDA EL MOVIMIENTO NO MONETARIO. ACTUALIZA MAESTRO. *
      *          NOTA: SE INHABILITO USO DE CODIGO 207 (CAMBIO RETFTE).*
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
      ******************************************************************
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCANOMON
               ASSIGN          TO DATABASE-CCANOMON
               ORGANIZATION    IS RELATIVE
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCANOVAPL
               ASSIGN          TO DATABASE-CCANOVAPL
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCATABLAS
               ASSIGN          TO DATABASE-CCATABLAS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT PLTFECHAS
               ASSIGN          TO DATABASE-PLTFECHAS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      ******************************************************************
      *                                                                *
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCANOMON
           LABEL RECORDS ARE STANDARD.
       01  REG-NOMONE.
           COPY DDS-ALL-FORMATS        OF CCANOMON.
      *
       FD  CCANOVAPL
           LABEL RECORDS ARE STANDARD.
       01  REG-NOVAPL.
           COPY DDS-ALL-FORMATS        OF CCANOVAPL.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAEAHO.
           COPY DDS-ALL-FORMATS        OF CCAMAEAHO.
      *
       FD  CCATABLAS
           LABEL RECORDS ARE STANDARD.
       01  REG-TABLAS.
           COPY DDS-ALL-FORMATS        OF CCATABLAS.
      *
       FD  PLTFECHAS
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTFECHAS.
           COPY DDS-ALL-FORMATS        OF PLTFECHAS.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTAGCORI.
           COPY DDS-ALL-FORMATS        OF PLTAGCORI.
      *
      ******************************************************************
       WORKING-STORAGE SECTION.
      * -----------------------------------------------------
           COPY   CATABPRO            OF CCACPY.                        IBM-CT
      *
       01  FILSTAT.
           03  ERR-FLG            PIC  X(001).
           03  PFK-BYTE           PIC  X(001).
      *
       01  IND-I PIC 9(05) COMP-3 VALUE ZEROS.
       01  VAR-NUEVO-01.
           03  NOMBRE             PIC X(50).
           03  NIT1               PIC 9(15).
           03  NIT2               PIC 9(15).
           03  NIT3               PIC 9(15).
           03  FILLER             PIC X(05).
       01  W-CODRET               PIC 9(01) VALUE ZEROS.
       01  W-NIT                  PIC 9(15) VALUE ZEROS.
       01  W-NIT17                PIC 9(17) VALUE ZEROS.
      *
       01  CONTROLES.
           03  CTL-CCANOMON       PIC  X(002)             VALUE "NO".
               88  FIN-CCANOMON                           VALUE "SI".
               88  NO-FIN-CCANOMON                        VALUE "NO".
           03  CTL-CCAMAEAHO       PIC  X(002)             VALUE "NO".
               88  EXISTE-CCAMAEAHO                        VALUE "SI".
               88  NO-EXISTE-CCAMAEAHO                     VALUE "NO".
           03  CTL-CCATABLAS       PIC  X(002)             VALUE "NO".
               88  EXISTE-CCATABLAS                        VALUE "SI".
               88  NO-EXISTE-CCATABLAS                     VALUE "NO".
           03  CTL-WRT-CCAMAEAHO   PIC  X(002)             VALUE "SI".
               88  WRT-CCAMAEAHO                           VALUE "SI".
               88  NO-WRT-CCAMAEAHO                        VALUE "NO".
           03  CTL-RWT-CCAMAEAHO   PIC  X(002)             VALUE "SI".
               88  RWT-CCAMAEAHO                           VALUE "SI".
               88  NO-RWT-CCAMAEAHO                        VALUE "NO".
           03  CTL-WRT-CCANOVAPL   PIC  X(002)             VALUE "SI".
               88  WRT-CCANOVAPL                           VALUE "SI".
               88  NO-WRT-CCANOVAPL                        VALUE "NO".
           03  CTL-CUENTA         PIC  X(002)             VALUE "SI".
               88  CUENTA-VALIDA                          VALUE "SI".
               88  CUENTA-NO-VALIDA                       VALUE "NO".
           03  CTL-NIT            PIC X(002)              VALUE "SI".
               88  BUEN-NIT                               VALUE "SI".
               88  MAL-NIT                                VALUE "NO".
           03  CTL-AGENCIA        PIC X(002)              VALUE "SI".
               88  EXISTE-AGENCIA                         VALUE "SI".
               88  NO-EXISTE-AGENCIA                      VALUE "NO".
           03  CTL-ERROR          PIC  X(002)             VALUE "NO".
               88  HAY-ERROR                              VALUE "SI".
               88  NO-HAY-ERROR                           VALUE "NO".
      ***************************************************************
           COPY FECHAS  OF CCACPY.
           COPY CANOMONER1  OF CCACPY.                                  IBM-CT
           COPY CANOVAPLR1 OF CCACPY.                                    IBM-CT
      *
      ***************************************************************
       01  PA-CODEMP                  PIC 9(05).
      ***************************************************************
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM  0010-INICIAR
           PERFORM  0100-PROCESAR      UNTIL FIN-CCANOMON
           PERFORM  9999-TERMINAR.
      *----------------------------------------------------------------
       0010-INICIAR.
           OPEN INPUT   CCANOMON   CCATABLAS   PLTFECHAS    PLTAGCORI
           OPEN EXTEND  CCANOVAPL
           OPEN I-O     CCAMAEAHO
           CALL "CCA500"  USING  LK-FECHAS                              ANANA
           MOVE "NO"                      TO CTL-CCANOMON
           PERFORM  0020-LEER-CCANOMON.
      *----------------------------------------------------------------
       0020-LEER-CCANOMON.
           READ  CCANOMON   NEXT RECORD AT END
              MOVE "SI"                   TO CTL-CCANOMON.
      *----------------------------------------------------------------
       0100-PROCESAR.
      *    MOVE CAMPO1  OF REG-NOMONE     TO DAT-NUEVO
           INITIALIZE REGNOVAPL.
           MOVE 0                         TO INDRES     OF REG-NOVAPL
           IF ESTTRN  OF REG-NOMONE > 0
              PERFORM  0110-HAGA-ANULACION
           ELSE
              IF CODNOV  OF REG-NOMONE = 1
                 PERFORM  0200-VALIDAR-ALTA
              ELSE
              IF CODNOV  OF REG-NOMONE = 2
                 PERFORM  0400-VALIDAR-CANCELACION
              ELSE
              IF CODNOV  OF REG-NOMONE = 3 OR 4
                 PERFORM  0500-VALIDAR-CUSTODIA
              ELSE
                 PERFORM  0220-MARQUE-ERROR
                 MOVE "CODIGO DE LA NOVEDAD INVALIDO"
                 TO RECHAZ    OF REG-NOVAPL
              END-IF
           END-IF.
           PERFORM  0020-LEER-CCANOMON.
      *----------------------------------------------------------------
       0110-HAGA-ANULACION.
           INITIALIZE  REGNOVAPL
           MOVE "SI"                      TO CTL-ERROR
           MOVE 0                         TO INDRES    OF REG-NOVAPL
           MOVE SPACES                    TO ESTMAE    OF REG-NOVAPL
           MOVE CAMPO1  OF REG-NOMONE     TO VENNOV    OF REG-NOVAPL
           MOVE "NOVEDAD ANULADA"         TO RECHAZ    OF REG-NOVAPL
           PERFORM  0990-WRT-CCANOVAPL.
      *----------------------------------------------------------------
       0200-VALIDAR-ALTA.
           PERFORM  0210-VALIDAR-PERMANENTES
           MOVE DATNUE OF REG-NOMONE TO VAR-NUEVO-01.
           IF NO-HAY-ERROR
              PERFORM  0240-VALIDAR-DATOS-ALTA
              IF NO-HAY-ERROR
                 MOVE  1                 TO INDRES     OF REG-NOVAPL
                 PERFORM 0990-WRT-CCANOVAPL
                 PERFORM 0295-HAGA-ALTA.
           IF HAY-ERROR
              PERFORM  0990-WRT-CCANOVAPL.
      *----------------------------------------------------------------
       0210-VALIDAR-PERMANENTES.
           MOVE "NO"                      TO CTL-ERROR
           MOVE "SI"                      TO CTL-CCAMAEAHO
           MOVE CODMON    OF REG-NOMONE   TO CODMON    OF REG-MAEAHO
           MOVE CODSIS    OF REG-NOMONE   TO CODSIS    OF REG-MAEAHO
           MOVE CODPRO    OF REG-NOMONE   TO CODPRO    OF REG-MAEAHO
           MOVE AGCCTA    OF REG-NOMONE   TO AGCCTA    OF REG-MAEAHO
           MOVE CTANRO    OF REG-NOMONE   TO CTANRO    OF REG-MAEAHO
           READ CCAMAEAHO  INVALID KEY                                   IBM-CT
                MOVE "NO"                 TO CTL-CCAMAEAHO
                PERFORM 0215-INICIAR-CCAMAEAHO.
           IF EXISTE-CCAMAEAHO
              IF CODNOV   OF REG-NOMONE  = 1
                 PERFORM  0220-MARQUE-ERROR
                 MOVE "CUENTA YA EXISTE"  TO RECHAZ    OF REG-NOVAPL
              ELSE
                 IF INDBAJ  OF REG-MAEAHO  > 0
                    PERFORM  0220-MARQUE-ERROR
                    MOVE "CUENTA CERRADA" TO RECHAZ    OF REG-NOVAPL
                 ELSE
                    NEXT SENTENCE
                 END-IF
              END-IF
           ELSE
              IF CODNOV   OF REG-NOMONE  = 1
                 NEXT SENTENCE
              ELSE
                 PERFORM  0220-MARQUE-ERROR
                 MOVE "CUENTA NO EXISTE"  TO RECHAZ    OF REG-NOVAPL
              END-IF
           END-IF.
      *----------------------------------------------------------------
       0215-INICIAR-CCAMAEAHO.
           INITIALIZE   REGMAEAHO
           MOVE CODMON  OF REG-NOMONE     TO CODMON    OF REG-MAEAHO
           MOVE CODSIS  OF REG-NOMONE     TO CODSIS    OF REG-MAEAHO
           MOVE CODPRO  OF REG-NOMONE     TO CODPRO    OF REG-MAEAHO
           MOVE AGCCTA  OF REG-NOMONE     TO AGCCTA    OF REG-MAEAHO
           MOVE CTANRO  OF REG-NOMONE     TO CTANRO    OF REG-MAEAHO
           PERFORM 0217-INICIAR-PROM    VARYING IND-I FROM 1 BY 1
                                        UNTIL   IND-I > 13.
      *----------------------------------------------------------------
       0217-INICIAR-PROM.
           MOVE ZEROS                     TO CANT-DEUDOR  (IND-I)
                                             SALDO-DEUDOR (IND-I)
                                             CANT-ACREED  (IND-I)
                                             SALDO-ACREED (IND-I).
      *----------------------------------------------------------------
       0220-MARQUE-ERROR.
           MOVE "SI"                      TO CTL-ERROR.
      *----------------------------------------------------------------
       0240-VALIDAR-DATOS-ALTA.
           PERFORM  0250-VALIDAR-AGENCIA
           IF NO-EXISTE-AGENCIA
              PERFORM  0220-MARQUE-ERROR
              MOVE "AGENCIA INVALIDA"      TO RECHAZ    OF REG-NOVAPL
           ELSE
              PERFORM  0270-VERIFICAR-NITS
              IF NO-HAY-ERROR
                 PERFORM VALIDAR-NOMBRE
              END-IF
           END-IF.
      *----------------------------------------------------------------
       VALIDAR-NOMBRE.
            IF NOMBRE = SPACES
               PERFORM  0220-MARQUE-ERROR
               MOVE "FALTA NOMBRE CUENTA   "
               TO RECHAZ    OF REG-NOVAPL
            END-IF.
      *----------------------------------------------------------------
       0250-VALIDAR-AGENCIA.
           MOVE "SI"                     TO CTL-AGENCIA
           MOVE AGCCTA   OF REG-NOMONE   TO AGCORI OF REG-PLTAGCORI
           MOVE PA-CODEMP                TO CODEMP OF REG-PLTAGCORI
           READ PLTAGCORI      INVALID KEY
                MOVE "NO"                TO CTL-AGENCIA.
      *----------------------------------------------------------------
       0270-VERIFICAR-NITS.
           IF NIT1 IS NOT NUMERIC
              PERFORM  0220-MARQUE-ERROR
              MOVE "NIT1 NO NUMERICO      "
              TO RECHAZ    OF REG-NOVAPL
           ELSE
              IF NIT1 = ZEROS
                 PERFORM  0220-MARQUE-ERROR
                 MOVE "NIT1 EN CEROS         "
                 TO RECHAZ    OF REG-NOVAPL
              ELSE
                 MOVE NIT1 TO W-NIT
      *          PERFORM  0280-VALIDAR-NIT
                 IF W-CODRET NOT = ZEROS
                    PERFORM  0220-MARQUE-ERROR
                    MOVE "NIT1 NO EXISTE        "
                    TO RECHAZ    OF REG-NOVAPL
                 END-IF
              END-IF
           END-IF.
           IF BUEN-NIT
              IF NIT2 IS NOT NUMERIC
                 PERFORM  0220-MARQUE-ERROR
                 MOVE "NIT2 NO NUMERICO      "
                 TO RECHAZ    OF REG-NOVAPL
              ELSE
                 IF NIT2 > ZEROS
                    MOVE NIT2 TO W-NIT
      *             PERFORM  0280-VALIDAR-NIT
                    IF W-CODRET NOT = ZEROS
                       PERFORM  0220-MARQUE-ERROR
                       MOVE "NIT2 NO EXISTE        "
                       TO RECHAZ    OF REG-NOVAPL
                    END-IF
                 END-IF
              END-IF
           END-IF.
           IF BUEN-NIT
              IF NIT3 IS NOT NUMERIC
                 PERFORM  0220-MARQUE-ERROR
                 MOVE "NIT3 NO NUMERICO      "
                 TO RECHAZ    OF REG-NOVAPL
              ELSE
                 IF NIT3 > ZEROS
                    MOVE NIT3 TO W-NIT
      *             PERFORM  0280-VALIDAR-NIT
                    IF W-CODRET NOT = ZEROS
                       PERFORM  0220-MARQUE-ERROR
                       MOVE "NIT3 NO EXISTE        "
                       TO RECHAZ    OF REG-NOVAPL
                    END-IF
                 END-IF
              END-IF
           END-IF.
      *----------------------------------------------------------------
       0280-VALIDAR-NIT.
           MOVE "SI"                      TO CTL-NIT
           PERFORM  0310-LLAMAR-CLIENTES.
           IF W-CODRET NOT = 0
              MOVE "NO"                   TO CTL-NIT
           END-IF.
      *----------------------------------------------------------------
       0295-HAGA-ALTA.
           MOVE CODMON     OF REG-NOMONE  TO CODMON    OF REG-MAEAHO
           MOVE CODSIS     OF REG-NOMONE  TO CODSIS    OF REG-MAEAHO
           MOVE CODPRO     OF REG-NOMONE  TO CODPRO    OF REG-MAEAHO
           MOVE AGCCTA     OF REG-NOMONE  TO AGCCTA    OF REG-MAEAHO
           MOVE CTANRO     OF REG-NOMONE  TO CTANRO    OF REG-MAEAHO
           MOVE NOMBRE                    TO DESCRI    OF REG-MAEAHO
           MOVE NIT1                    TO NITCTA    OF REG-MAEAHO
           IF NIT2   > 0
              MOVE NIT2                 TO NITCT2    OF REG-MAEAHO.
           IF NIT3   > 0
              MOVE NIT3                 TO NITCT3    OF REG-MAEAHO.
           MOVE LK-FECHA-HOY            TO FAPERT    OF REG-MAEAHO
           MOVE 1                       TO INDFIC    OF REG-MAEAHO
           PERFORM 0217-INICIAR-PROM  VARYING IND-I FROM 1 BY 1
                                        UNTIL IND-I > 13.
           MOVE TABLA-PROMEDIOS           TO TABSAL  OF REG-MAEAHO
           MOVE "SI"                      TO CTL-WRT-CCAMAEAHO
           WRITE REG-MAEAHO    INVALID KEY
                 MOVE "NO"                TO CTL-WRT-CCAMAEAHO.
      *----------------------------------------------------------------
       0310-LLAMAR-CLIENTES.
           MOVE W-NIT                     TO W-NIT17
           MOVE ZEROS                     TO W-CODRET
           CALL "CLI900"  USING  W-NIT17 W-NIT17 W-CODRET.
      *----------------------------------------------------------------
       0400-VALIDAR-CANCELACION.
           PERFORM  0210-VALIDAR-PERMANENTES
           IF NO-HAY-ERROR
              PERFORM  0405-VALIDAR-CAMBIOS-BASICOS
              IF NO-HAY-ERROR
                 MOVE  1                 TO INDRES     OF REG-NOVAPL
                 PERFORM 0990-WRT-CCANOVAPL
                 PERFORM 0420-HAGA-CAMBIO-BASICO.
           IF HAY-ERROR
              PERFORM  0990-WRT-CCANOVAPL.
      *----------------------------------------------------------------
       0405-VALIDAR-CAMBIOS-BASICOS.
           IF INDBAJ  OF REG-MAEAHO  > 0
              PERFORM  0220-MARQUE-ERROR
              MOVE "CUENTA CANCELADA"
              TO RECHAZ    OF REG-NOVAPL.
      *----------------------------------------------------------------
       0420-HAGA-CAMBIO-BASICO.
           IF CODNOV   OF REG-NOMONE  = 2
              MOVE  1 TO INDBAJ OF REG-MAEAHO
              MOVE  1 TO MOTBAJ OF REG-MAEAHO
              MOVE LK-FECHA-HOY TO FCIERR OF REG-MAEAHO
           ELSE
           IF CODNOV OF REG-NOMONE  = 3
              MOVE  1 TO INDBLO OF REG-MAEAHO
              MOVE  1 TO CODBLO OF REG-MAEAHO
           ELSE
           IF CODNOV OF REG-NOMONE  = 4
              MOVE  ZEROS TO INDBLO OF REG-MAEAHO
              MOVE  ZEROS TO CODBLO OF REG-MAEAHO
           END-IF.
           MOVE 1                         TO INDFIC    OF REG-MAEAHO
           MOVE "SI"                      TO CTL-RWT-CCAMAEAHO
           REWRITE REG-MAEAHO    INVALID KEY
                 MOVE "NO"                TO CTL-RWT-CCAMAEAHO.
      *----------------------------------------------------------------
       0500-VALIDAR-CUSTODIA.
           PERFORM  0210-VALIDAR-PERMANENTES
           IF NO-HAY-ERROR
              PERFORM 0405-VALIDAR-CAMBIOS-BASICOS
              IF NO-HAY-ERROR
                 MOVE  1                 TO INDRES     OF REG-NOVAPL
                 PERFORM 0990-WRT-CCANOVAPL
                 PERFORM 0420-HAGA-CAMBIO-BASICO.
           IF HAY-ERROR
              PERFORM  0990-WRT-CCANOVAPL.
      *----------------------------------------------------------------
       0990-WRT-CCANOVAPL.
           MOVE CODMON  OF REG-NOMONE     TO CODMON    OF REG-NOVAPL
           MOVE CODSIS  OF REG-NOMONE     TO CODSIS    OF REG-NOVAPL
           MOVE CODPRO  OF REG-NOMONE     TO CODPRO    OF REG-NOVAPL
           MOVE AGCCTA  OF REG-NOMONE     TO AGCCTA    OF REG-NOVAPL
           MOVE CTANRO  OF REG-NOMONE     TO CTANRO    OF REG-NOVAPL
           MOVE HORPRO  OF REG-NOMONE     TO HORPRO    OF REG-NOVAPL
           MOVE CODNOV  OF REG-NOMONE     TO CODNOV    OF REG-NOVAPL
           IF NO-HAY-ERROR
              PERFORM  0995-REG-BUENOS
           ELSE
              PERFORM  0996-REG-MALOS.
           WRITE  REG-NOVAPL.
      *----------------------------------------------------------------
       0995-REG-BUENOS.
           MOVE SPACES                    TO NOV-DATOS
           IF CODNOV OF REG-NOMONE  = 1
              MOVE NITCTA   OF REG-MAEAHO TO OLD-NIT1
              MOVE NITCT2   OF REG-MAEAHO TO OLD-NIT2
              MOVE NITCT3   OF REG-MAEAHO TO OLD-NIT3
              MOVE NIT1                 TO NEW-NIT1
              MOVE NIT2                 TO NEW-NIT2
              MOVE NIT3                 TO NEW-NIT3
           ELSE
           IF CODNOV   OF REG-NOMONE  = 2
              MOVE INDBAJ OF REG-MAEAHO TO NEW-IND-CUSTODIA
           ELSE
           IF CODNOV   OF REG-NOMONE  = 3 OR 4
              MOVE INDBLO OF REG-MAEAHO TO NEW-IND-CUSTODIA
           END-IF.
           MOVE DATOS-OLD                 TO ESTMAE  OF REG-NOVAPL
           MOVE DATOS-NEW                 TO VENNOV  OF REG-NOVAPL.
      *----------------------------------------------------------------
       0996-REG-MALOS.
           MOVE SPACES                    TO NOV-DATOS
           IF CODNOV OF REG-NOMONE  = 1
              MOVE NIT1                 TO NEW-NIT1
              MOVE NIT2                 TO NEW-NIT2
              MOVE NIT3                 TO NEW-NIT3
           ELSE
           IF CODNOV   OF REG-NOMONE  = 2
              MOVE INDBAJ OF REG-MAEAHO TO NEW-IND-CUSTODIA
           ELSE
           IF CODNOV   OF REG-NOMONE  = 3 OR 4
              MOVE INDBLO OF REG-MAEAHO TO NEW-IND-CUSTODIA
           END-IF.
           MOVE DATOS-OLD                 TO ESTMAE  OF REG-NOVAPL
           MOVE DATOS-NEW                 TO VENNOV  OF REG-NOVAPL.
      *----------------------------------------------------------------
       9999-TERMINAR.
           CLOSE CCANOMON  CCANOVAPL   CCAMAEAHO    CCATABLAS
                 PLTFECHAS PLTAGCORI
           STOP RUN.
      *----------------------------------------------------------------
