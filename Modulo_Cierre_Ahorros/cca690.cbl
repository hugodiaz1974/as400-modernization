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
       PROGRAM-ID.    CCA690.
       AUTHOR.        M.H.D.
       DATE-WRITTEN.  97/10/15.
      ******************************************************************
      * FUNCION: REP. SALDOS DE CUENTAS.                               *
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
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO1
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES
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
      *
           SELECT CCACODPRO
               ASSIGN          TO DATABASE-CCACODPRO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT PLTSUCURS
               ASSIGN          TO DATABASE-PLTSUCURS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *                                                                -
           SELECT CCA690IA
               ASSIGN          TO FORMATFILE-CCA690R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *                                                                -
      ******************************************************************
      *                                                                *
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS        OF CCAMAEAHO1.
      *
       FD  PLTFECHAS
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTFECHAS.
           COPY DDS-ALL-FORMATS        OF PLTFECHAS.
      *
       FD  CCACODPRO
           LABEL RECORDS ARE STANDARD.
       01  REG-CCACODPRO.
           COPY DDS-ALL-FORMATS        OF CCACODPRO.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTAGCORI.
           COPY DDS-ALL-FORMATS        OF PLTAGCORI.
      *
       FD  PLTSUCURS
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTSUCURS.
           COPY DDS-ALL-FORMATS        OF PLTSUCURS.
      *                                                                 IBM-CT
       FD  CCA690IA
           LABEL RECORDS ARE OMITTED.
       01  PRTREC.
           COPY DDS-ALL-FORMATS        OF CCA690R.
      *
      ******************************************************************
      *                                                                -
       WORKING-STORAGE SECTION.
      *
       01  FILSTAT.
           03  ERR-FLG                 PIC  X(001).
           03  PFK-BYTE                PIC  X(001).
      *
       01  VAR-PRTF.
           03  VAR-PRTF01.
               05 WRK-NOMLISTADO       PIC  X(010)        VALUE SPACES.
               05 WRK-EMPRESA          PIC  X(040)        VALUE SPACES.
               05 WRK-LINEA            PIC  9(005)        VALUE 60.
               05 WRK-PAGINA           PIC  9(005)        VALUE ZEROS.
               05 WRK-FECHA-PARA       PIC  9(008)        VALUE ZEROS.
               05 WRK-FECHA-SYS        PIC  9(008)        VALUE ZEROS.
               05 WRK-HORA             PIC  9(008)        VALUE ZEROS.
               05 RED-HORA     REDEFINES      WRK-HORA.
                  07  HHMMSS           PIC  9(006).
                  07  CCSS             PIC  9(002).
               05 WRK-NOM-SUC          PIC  X(020)        VALUE SPACES.
               05 WRK-DESLIST          PIC  X(048)        VALUE SPACES.
               05 WRK-SBTCTA           PIC  9(009)        VALUE ZEROS.
               05 WRK-SBTDIS           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-SBT24H           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-SBT48H           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-SBT72H           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-SBTPOT           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTCTA           PIC  9(009)        VALUE ZEROS.
               05 WRK-TOTDIS           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOT24H           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOT48H           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOT72H           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTPOT           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-EMB-CAN          PIC  9(009)        VALUE ZEROS.
               05 WRK-EMB-ACT          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-EMB-24           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-EMB-48           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-EMB-72           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-EMB-CON          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-BLO-CAN          PIC  9(009)        VALUE ZEROS.
               05 WRK-BLO-ACT          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-BLO-24           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-BLO-48           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-BLO-72           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-BLO-CON          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INA-CAN          PIC  9(009)        VALUE ZEROS.
               05 WRK-INA-ACT          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INA-24           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INA-48           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INA-72           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INA-CON          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-FAL-CAN          PIC  9(009)        VALUE ZEROS.
               05 WRK-FAL-ACT          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-FAL-24           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-FAL-48           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-FAL-72           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-FAL-CON          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INV-CAN          PIC  9(009)        VALUE ZEROS.
               05 WRK-INV-ACT          PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INV-24           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INV-48           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INV-72           PIC S9(013)V99     VALUE ZEROS.
               05 WRK-INV-CON          PIC S9(013)V99     VALUE ZEROS.
      *
       01  W-EXISTE-PLTSUCURS          PIC 9 VALUE ZEROS.
           88 NO-EXISTE-PLTSUCURS      VALUE 1.
           88 SI-EXISTE-PLTSUCURS      VALUE 0.
       01  W-FIN-PLTAGCORI          PIC 9 VALUE ZEROS.
           88 NO-FIN-PLTAGCORI      VALUE 0.
           88 SI-FIN-PLTAGCORI      VALUE 1.
       01  W-FIN-CCACODPRO          PIC 9 VALUE ZEROS.
           88 NO-FIN-CCACODPRO      VALUE 0.
           88 SI-FIN-CCACODPRO      VALUE 1.
       01  VAR-TRABAJO.
           03  FLG-USERID              PIC  X(010)        VALUE SPACES.
           03  FLG-ENCABE              PIC  9(001)        VALUE ZEROS.
           03  FLG-CTA                 PIC  9(001)        VALUE ZEROS.
               88  ES-ACTIVA                              VALUE 0.
               88  ES-CUSTODIA                            VALUE 1.
           03  FLG-PV                  PIC  9(001)        VALUE 0.
               88  ES-PRIMERA-VEZ                         VALUE 0.
               88  ES-OTRA-VEZ                            VALUE 1.
           03  CODPRO-ANT              PIC  9(005)        VALUE ZEROS.
           03  AGENCIA-ANT             PIC  9(005)        VALUE ZEROS.
           03  CODSUC-ANT              PIC  9(005)        VALUE ZEROS.
      *
       01  CONTROLES.
           03  CTL-CCAMAEAHO            PIC  X(002)        VALUE "NO".
               88  FIN-CCAMAEAHO                           VALUE "SI".
               88  NO-FIN-CCAMAEAHO                        VALUE "NO".
           03  CTL-REGISTRO            PIC  X(002)        VALUE "NO".
               88  BUEN-REGISTRO                          VALUE "SI".
               88  MAL-REGISTRO                           VALUE "NO".
      * -----------------------------------------
       01  W-CUENTA PIC 9(12) VALUE ZEROS.
       01  FILLER REDEFINES W-CUENTA.
           03 W-OFICTA PIC 9(04).
           03 W-NROCTA PIC 9(06).
           03 W-CODPRO PIC 99.
       01  PA-CODEMP                   PIC 9(05)          VALUE 0.
      * -----------------------------------------
           COPY PARGEN OF CCACPY.
      * -----------------------------------------
       01  W-OVRPRTF.
           03  FILLER                  PIC X(13)      VALUE
               "OVRPRTF FILE(".
           03  W-NOMARC1               PIC X(07).
           03  FILLER                  PIC X(09)      VALUE
               ") TOFILE(".
           03  W-NOMARC2               PIC X(07).
           03  FILLER                  PIC X(11)      VALUE
               ") SPLFNAME(".
           03  W-NOMSPL                PIC X(06).
           03  W-NOMCOR                PIC 9(04).
           03  FILLER                  PIC X(01)      VALUE
               ")".
           03  FILLER                  PIC X(06)      VALUE
               " OUTQ(".
           03  W-NOMIMP                PIC X(10).
           03  FILLER REDEFINES W-NOMIMP.
               05 FIL-1                PIC X(03).
               05 IMP-SUC              PIC 9(03).
               05 FIL-2                PIC 9(02).
               05 FIL-3                PIC XX.
           03  FILLER                  PIC X(01)      VALUE
               ")".
           03  FILLER                  PIC X(11)      VALUE
               " HOLD(*YES)".
       01  W-DLTOVR-PRT.
           03  FILLER                  PIC X(12)      VALUE
               "DLTOVR FILE(".
           03  W-NOMARC5               PIC X(07).
           03  FILLER                  PIC X(01)      VALUE
               ")".
       01  W-LNGCMD                    PIC S9(10)V9(05) COMP-3.
      ***************************************************************
       LINKAGE SECTION.
       77  IND-USER                    PIC  X(010).
       77  EQUIPO                      PIC  X(010).
       77  IND-CTA                     PIC  X(001).
      ***************************************************************
       PROCEDURE DIVISION  USING IND-USER  EQUIPO  IND-CTA.
       0000-MAIN.
           PERFORM  0010-INICIAR
           PERFORM  0100-PROCESAR UNTIL (FIN-CCAMAEAHO)
           PERFORM  9999-TERMINAR.
      *----------------------------------------------------------------
       0010-INICIAR.
           MOVE IND-USER                  TO FLG-USERID
           MOVE EQUIPO                    TO WRK-NOM-SUC
           MOVE IND-CTA                   TO FLG-CTA
           OPEN INPUT CCAMAEAHO PLTFECHAS PLTAGCORI PLTSUCURS CCACODPRO
           CALL "PLTCODEMPP"              USING PA-CODEMP
           CALL "CCA501" USING LK-CCAPARGEN.
           MOVE LK-NOMEMP                 TO WRK-EMPRESA
           MOVE 011                       TO CODSIS   OF REG-PLTFECHAS
           MOVE PA-CODEMP                 TO CODEMP   OF REG-PLTFECHAS
           READ PLTFECHAS   INVALID KEY
              DISPLAY "ERROR. ARCHIVO PLTFECHAS"
              PERFORM  9999-TERMINAR.
           MOVE FECPRO   OF REG-PLTFECHAS    TO WRK-FECHA-PARA
           MOVE ZEROS                     TO WRK-FECHA-SYS
           CALL "SEC993" USING WRK-FECHA-SYS
           ACCEPT  WRK-HORA             FROM TIME
           PERFORM INICIALIZAR-OFICINA.
           MOVE ZERO                      TO FLG-PV.
           MOVE "NO"                      TO CTL-CCAMAEAHO
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0030-LEER-CCAMAEAHO UNTIL FIN-CCAMAEAHO
                                       OR    BUEN-REGISTRO
           IF NO-FIN-CCAMAEAHO
              MOVE CODPRO  OF REG-MAESTR  TO CODPRO-ANT
              MOVE AGCCTA  OF REG-MAESTR  TO AGENCIA-ANT
              MOVE REGION  OF REG-MAESTR  TO CODSUC-ANT
              PERFORM ABRIR-IMPRESION
              PERFORM 0020-ENCABEZADO
              PERFORM 0040-SUBTIT-1.
      *-----------------------------------------------------------------
       INICIALIZAR-OFICINA.
           MOVE ZEROS                     TO WRK-SBTCTA    WRK-TOTCTA
                                             WRK-SBT24H    WRK-TOT24H
                                             WRK-SBT48H    WRK-TOT48H
                                             WRK-SBT72H    WRK-TOT72H
                                             WRK-SBTPOT    WRK-TOTPOT
                                             WRK-SBTDIS    WRK-TOTDIS.
           MOVE ZEROS                     TO WRK-EMB-CAN   WRK-EMB-ACT
                                             WRK-EMB-24    WRK-EMB-48
                                             WRK-EMB-72    WRK-EMB-CON.
           MOVE ZEROS                     TO WRK-BLO-CAN   WRK-BLO-ACT
                                             WRK-BLO-24    WRK-BLO-48
                                             WRK-BLO-72    WRK-BLO-CON.
           MOVE ZEROS                     TO WRK-INA-CAN   WRK-INA-ACT
                                             WRK-INA-24    WRK-INA-48
                                             WRK-INA-72    WRK-INA-CON.
           MOVE ZEROS                     TO WRK-FAL-CAN   WRK-FAL-ACT
                                             WRK-FAL-24    WRK-FAL-48
                                             WRK-FAL-72    WRK-FAL-CON.
           MOVE ZEROS                     TO WRK-INV-CAN   WRK-INV-ACT
                                             WRK-INV-24    WRK-INV-48
                                             WRK-INV-72    WRK-INV-CON.
      *-----------------------------------------------------------------
       0100-PROCESAR.
      *    IF CODSUC-ANT NOT = REGION OF CCAMAEAHO
      *       PERFORM  0200-CAMBIO-AGENCIA
      *       PERFORM CERRAR-IMPRESION
      *       MOVE AGCCTA OF CCAMAEAHO TO AGENCIA-ANT
      *       MOVE REGION OF CCAMAEAHO TO CODSUC-ANT
      *       PERFORM ABRIR-IMPRESION
      *       PERFORM  0020-ENCABEZADO
      *       PERFORM 0040-SUBTIT-1
      *    END-IF.
           IF AGENCIA-ANT NOT  =  AGCCTA OF CCAMAEAHO
              PERFORM  0200-CAMBIO-AGENCIA
              PERFORM CERRAR-IMPRESION
              MOVE AGCCTA OF CCAMAEAHO TO AGENCIA-ANT
              MOVE CODPRO OF CCAMAEAHO TO CODPRO-ANT
              PERFORM ABRIR-IMPRESION
              PERFORM  0020-ENCABEZADO
              PERFORM 0040-SUBTIT-1
           END-IF.
           IF CODPRO-ANT NOT  =  CODPRO OF CCAMAEAHO
              PERFORM  0200-CAMBIO-PRODUCTO
              MOVE CODPRO OF CCAMAEAHO TO CODPRO-ANT
           END-IF.
           PERFORM  0110-IMP-DETALLE
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0030-LEER-CCAMAEAHO UNTIL FIN-CCAMAEAHO
                                       OR    BUEN-REGISTRO.
      *-----------------------------------------------------------------
       0020-ENCABEZADO.
           IF WRK-LINEA > 55
              IF ES-PRIMERA-VEZ
                 MOVE 1                   TO FLG-PV
      *       ELSE
      *          PERFORM  0210-ESCRIBIR-PIE
      *          PERFORM  0220-ACUMULAR-TOTAL
              END-IF
              MOVE 1                      TO FLG-ENCABE
              ADD  1                      TO WRK-PAGINA
              MOVE FLG-USERID             TO USER
              MOVE WRK-EMPRESA            TO EMPRESA
              MOVE WRK-PAGINA             TO PAGNRO
              IF ES-ACTIVA
                 MOVE "REP. DIARIO DE SALDOS DE CUENTAS ACTIVAS"
                                          TO DESCLIST
              MOVE "CCA690R1"             TO NOMLISTADO
              ELSE
                 MOVE "REP. DIARIO DE SALDOS DE CUENTAS EN CUSTODIA"
                                          TO DESCLIST
              MOVE "CCA690R2"             TO NOMLISTADO
              END-IF
              MOVE WRK-FECHA-PARA         TO FECPARA
              MOVE WRK-NOM-SUC            TO NOMBRESUC
              MOVE HHMMSS                 TO HORA
              MOVE WRK-FECHA-SYS          TO FECIMPR
              WRITE PRTREC  FORMAT IS "PHEAD"
              MOVE 5                      TO WRK-LINEA.
      *----------------------------------------------------------------
       0030-LEER-CCAMAEAHO.
           MOVE "SI"                      TO CTL-REGISTRO
           READ  CCAMAEAHO    NEXT RECORD AT END
              MOVE "SI"                   TO CTL-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              IF INDBAJ  OF REG-MAESTR > 0
                 MOVE "NO"                TO CTL-REGISTRO
              ELSE
                 IF ES-ACTIVA
                    IF INDEMB  OF REG-MAESTR > 0  OR
                       INDINA  OF REG-MAESTR > 0  OR
                       INDFAL  OF REG-MAESTR > 0  OR
                       INDINV  OF REG-MAESTR > 0  OR
                       INDBLO  OF REG-MAESTR > 2
                       MOVE "NO"          TO CTL-REGISTRO
                    END-IF
                  ELSE
                    IF INDEMB  OF REG-MAESTR = 0  AND
                       INDINA  OF REG-MAESTR = 0  AND
                       INDFAL  OF REG-MAESTR = 0  AND
                       INDINV  OF REG-MAESTR = 0  AND
                       INDBLO  OF REG-MAESTR < 3
                       MOVE "NO"          TO CTL-REGISTRO.
      *----------------------------------------------------------------
       0040-SUBTIT-1.
           MOVE 0                         TO FLG-ENCABE
           PERFORM  0050-DESCRI-AGENCIA
           MOVE AGENCIA-ANT                  TO CODOFI
           MOVE CODPRO-ANT                   TO CODPRO OF PSUBT1-O
           PERFORM  0050-DESCRI-CODPRO
           MOVE NOMAGC   OF  REG-PLTAGCORI   TO DESOFI
           MOVE DESCRI   OF  REG-CCACODPRO   TO NOMPRO OF PSUBT1-O
           MOVE NOMSUC   OF  PLTSUCURS       TO DESSUC
           WRITE PRTREC  FORMAT IS "PSUBT1"
           ADD  6                         TO WRK-LINEA.
      *----------------------------------------------------------------
       0050-DESCRI-AGENCIA.
           MOVE AGENCIA-ANT               TO AGCORI OF PLTAGCORI
           MOVE PA-CODEMP                 TO CODEMP OF PLTAGCORI
           READ PLTAGCORI      INVALID KEY
                MOVE " AGENCIA NO EXISTE "
                                          TO NOMAGC OF REG-PLTAGCORI.
      *----------------------------------------------------------------
       0050-DESCRI-CODPRO.
           MOVE CODPRO-ANT                TO CODPRO OF CCACODPRO
           READ CCACODPRO      INVALID KEY
                MOVE " PRODUCTO NO EXISTE "
                                          TO DESCRI OF REG-CCACODPRO.
      *----------------------------------------------------------------
       0110-IMP-DETALLE.
           PERFORM  0020-ENCABEZADO
           IF FLG-ENCABE = 1
              PERFORM 0040-SUBTIT-1.
           MOVE DESCRI     OF REG-MAESTR   TO DESCTA
           MOVE CTANRO     OF REG-MAESTR   TO W-NROCTA
           MOVE CODPRO     OF REG-MAESTR   TO W-CODPRO
           MOVE AGCCTA     OF REG-MAESTR   TO W-OFICTA
           MOVE W-CUENTA                   TO NUMCTA
           MOVE FULMOV     OF REG-MAESTR   TO FEULMO
           ADD  1                          TO WRK-SBTCTA
           MOVE SALACT     OF REG-MAESTR   TO SLDDIS
           ADD  SALACT     OF REG-MAESTR   TO WRK-SBTDIS
           MOVE DEP24      OF REG-MAESTR   TO CRE24H
           ADD  DEP24      OF REG-MAESTR   TO WRK-SBT24H
           MOVE DEP48      OF REG-MAESTR   TO CRE48H
           ADD  DEP48      OF REG-MAESTR   TO WRK-SBT48H
           MOVE DEP72      OF REG-MAESTR   TO CRE72H
           ADD  DEP72      OF REG-MAESTR   TO WRK-SBT72H
           MOVE SALCON     OF REG-MAESTR   TO SLDPOT
           ADD  SALCON     OF REG-MAESTR   TO WRK-SBTPOT
      *OJO CON LAS OBSERVACIONES.
           MOVE SPACES                     TO OBSERV
                FLGEMB   FLGBLO   FLGINA   FLGFAL   FLGINV
           IF INDEMB   OF REG-MAESTR > 0
              ADD 1                        TO WRK-EMB-CAN
              ADD  SALACT  OF REG-MAESTR   TO WRK-EMB-ACT
              ADD  DEP24   OF REG-MAESTR   TO WRK-EMB-24
              ADD  DEP48   OF REG-MAESTR   TO WRK-EMB-48
              ADD  DEP72   OF REG-MAESTR   TO WRK-EMB-72
              ADD  SALCON  OF REG-MAESTR   TO WRK-EMB-CON
              MOVE "X"                     TO FLGEMB.
           IF INDBLO   OF REG-MAESTR > 0
              ADD 1                        TO WRK-BLO-CAN
              ADD  SALACT  OF REG-MAESTR   TO WRK-BLO-ACT
              ADD  DEP24   OF REG-MAESTR   TO WRK-BLO-24
              ADD  DEP48   OF REG-MAESTR   TO WRK-BLO-48
              ADD  DEP72   OF REG-MAESTR   TO WRK-BLO-72
              ADD  SALCON  OF REG-MAESTR   TO WRK-BLO-CON
              MOVE "X"                     TO FLGBLO.
           IF INDINA   OF REG-MAESTR > 0
              ADD 1                        TO WRK-INA-CAN
              ADD  SALACT  OF REG-MAESTR   TO WRK-INA-ACT
              ADD  DEP24   OF REG-MAESTR   TO WRK-INA-24
              ADD  DEP48   OF REG-MAESTR   TO WRK-INA-48
              ADD  DEP72   OF REG-MAESTR   TO WRK-INA-72
              ADD  SALCON  OF REG-MAESTR   TO WRK-INA-CON
              MOVE "X"                     TO FLGINA.
           IF INDFAL   OF REG-MAESTR > 0
              ADD 1                        TO WRK-FAL-CAN
              ADD  SALACT  OF REG-MAESTR   TO WRK-FAL-ACT
              ADD  DEP24   OF REG-MAESTR   TO WRK-FAL-24
              ADD  DEP48   OF REG-MAESTR   TO WRK-FAL-48
              ADD  DEP72   OF REG-MAESTR   TO WRK-FAL-72
              ADD  SALCON  OF REG-MAESTR   TO WRK-FAL-CON
              MOVE "X"                     TO FLGFAL.
           IF INDINV   OF REG-MAESTR > 0
              ADD 1                        TO WRK-INV-CAN
              ADD  SALACT  OF REG-MAESTR   TO WRK-INV-ACT
              ADD  DEP24   OF REG-MAESTR   TO WRK-INV-24
              ADD  DEP48   OF REG-MAESTR   TO WRK-INV-48
              ADD  DEP72   OF REG-MAESTR   TO WRK-INV-72
              ADD  SALCON  OF REG-MAESTR   TO WRK-INV-CON
              MOVE "X"                     TO FLGINV.
           WRITE PRTREC  FORMAT IS "PDETAIL"
           ADD  1                         TO WRK-LINEA.
      *----------------------------------------------------------------
       0200-CAMBIO-AGENCIA.
           PERFORM  0210-ESCRIBIR-PIE
           MOVE ZEROS TO WRK-PAGINA.
      *    PERFORM  0220-ACUMULAR-TOTAL
           MOVE 0                         TO FLG-PV.
      *    PERFORM  0020-ENCABEZADO.
      *----------------------------------------------------------------
       0200-CAMBIO-PRODUCTO.
           PERFORM  0210-ESCRIBIR-PIE
           MOVE ZEROS TO WRK-PAGINA.
      *    PERFORM  0220-ACUMULAR-TOTAL
           MOVE 0                         TO FLG-PV.
      *    PERFORM  0020-ENCABEZADO.
      *----------------------------------------------------------------
       0210-ESCRIBIR-PIE.
           MOVE "Total Oficina     "      TO NOMTOT
           MOVE WRK-SBTCTA                TO SUBCTA
           MOVE WRK-SBTDIS                TO SUBDIS
           MOVE WRK-SBT24H                TO SUB24H
           MOVE WRK-SBT48H                TO SUB48H
           MOVE WRK-SBT72H                TO SUB72H
           MOVE WRK-SBTPOT                TO SUBPOT
           WRITE PRTREC  FORMAT IS "PPIE".
           MOVE 60                        TO WRK-LINEA.
           IF NOT ES-ACTIVA
              PERFORM IMPRIMIR-RESUMEN-INACTIVAS
              MOVE 60                     TO WRK-LINEA
           END-IF.
           PERFORM INICIALIZAR-OFICINA.
      *----------------------------------------------------------------
       IMPRIMIR-RESUMEN-INACTIVAS.
           PERFORM  0020-ENCABEZADO
           PERFORM 0040-SUBTIT-1.
           IF WRK-EMB-CAN > ZEROS
              MOVE "Total Embargadas  "      TO NOMTOT
              MOVE WRK-EMB-CAN               TO SUBCTA
              MOVE WRK-EMB-ACT               TO SUBDIS
              MOVE WRK-EMB-24                TO SUB24H
              MOVE WRK-EMB-48                TO SUB48H
              MOVE WRK-EMB-72                TO SUB72H
              MOVE WRK-EMB-CON               TO SUBPOT
              WRITE PRTREC  FORMAT IS "PPIE".
           IF WRK-BLO-CAN > ZEROS
              MOVE "Total Bloqueadas  "      TO NOMTOT
              MOVE WRK-BLO-CAN               TO SUBCTA
              MOVE WRK-BLO-ACT               TO SUBDIS
              MOVE WRK-BLO-24                TO SUB24H
              MOVE WRK-BLO-48                TO SUB48H
              MOVE WRK-BLO-72                TO SUB72H
              MOVE WRK-BLO-CON               TO SUBPOT
              WRITE PRTREC  FORMAT IS "PPIE".
           IF WRK-INA-CAN > ZEROS
              MOVE "Total Inactivas   "      TO NOMTOT
              MOVE WRK-INA-CAN               TO SUBCTA
              MOVE WRK-INA-ACT               TO SUBDIS
              MOVE WRK-INA-24                TO SUB24H
              MOVE WRK-INA-48                TO SUB48H
              MOVE WRK-INA-72                TO SUB72H
              MOVE WRK-INA-CON               TO SUBPOT
              WRITE PRTREC  FORMAT IS "PPIE".
           IF WRK-FAL-CAN > ZEROS
              MOVE "Total Fallecidas  "      TO NOMTOT
              MOVE WRK-FAL-CAN               TO SUBCTA
              MOVE WRK-FAL-ACT               TO SUBDIS
              MOVE WRK-FAL-24                TO SUB24H
              MOVE WRK-FAL-48                TO SUB48H
              MOVE WRK-FAL-72                TO SUB72H
              MOVE WRK-FAL-CON               TO SUBPOT
              WRITE PRTREC  FORMAT IS "PPIE".
           IF WRK-INV-CAN > ZEROS
              MOVE "Total Investigadas"      TO NOMTOT
              MOVE WRK-INV-CAN               TO SUBCTA
              MOVE WRK-INV-ACT               TO SUBDIS
              MOVE WRK-INV-24                TO SUB24H
              MOVE WRK-INV-48                TO SUB48H
              MOVE WRK-INV-72                TO SUB72H
              MOVE WRK-INV-CON               TO SUBPOT
              WRITE PRTREC  FORMAT IS "PPIE".
      *----------------------------------------------------------------
       0220-ACUMULAR-TOTAL.
           ADD  WRK-SBTCTA                TO WRK-TOTCTA
           ADD  WRK-SBTDIS                TO WRK-TOTDIS
           ADD  WRK-SBT24H                TO WRK-TOT24H
           ADD  WRK-SBT48H                TO WRK-TOT48H
           ADD  WRK-SBT72H                TO WRK-TOT72H
           ADD  WRK-SBTPOT                TO WRK-TOTPOT
           MOVE ZEROS                     TO WRK-SBTCTA    WRK-SBTDIS
                                             WRK-SBT24H    WRK-SBT48H
                                             WRK-SBT72H
                                             WRK-SBTPOT.
      *----------------------------------------------------------------
       0300-ESCRIBIR-FOOTER.
           MOVE WRK-TOTCTA                TO TOTCTA
           MOVE WRK-TOTDIS                TO TOTDIS
           MOVE WRK-TOT24H                TO TOT24H
           MOVE WRK-TOT48H                TO TOT48H
           MOVE WRK-TOT72H                TO TOT72H
           MOVE WRK-TOTPOT                TO TOTPOT
           WRITE PRTREC  FORMAT IS "PFOOT".
           MOVE 60                        TO WRK-LINEA.
      *----------------------------------------------------------------
       ABRIR-IMPRESION.
           MOVE AGENCIA-ANT               TO AGCORI OF PLTAGCORI
           MOVE PA-CODEMP                 TO CODEMP OF PLTAGCORI
           READ PLTAGCORI INVALID KEY
                MOVE ZEROS                TO CODSUC OF PLTSUCURS.
           MOVE ZEROS TO W-EXISTE-PLTSUCURS
           MOVE PA-CODEMP                 TO CODEMP OF PLTSUCURS
           READ PLTSUCURS INVALID KEY
                MOVE ALL "*" TO NOMSUC OF PLTSUCURS
           END-READ.
           MOVE "CCA690R"          TO W-NOMARC1
           MOVE "CCA690R"          TO W-NOMARC2
           MOVE "CCA690R"          TO W-NOMARC5
           IF ES-ACTIVA
              MOVE "CASALA"          TO W-NOMSPL
           ELSE
              MOVE "CASALI"          TO W-NOMSPL
           END-IF
           MOVE 86                 TO W-LNGCMD
           MOVE AGENCIA-ANT        TO W-NOMCOR
           MOVE IND-USER           TO W-NOMIMP
           CALL "QCMDEXC"          USING W-OVRPRTF , W-LNGCMD
           OPEN OUTPUT CCA690IA.
      *--------------------------------------------------------------*
       CERRAR-IMPRESION.
           MOVE 20                 TO W-LNGCMD
           CLOSE CCA690IA
           CALL "QCMDEXC"          USING W-DLTOVR-PRT , W-LNGCMD.
      *----------------------------------------------------------------
       9999-TERMINAR.
           PERFORM  0210-ESCRIBIR-PIE
           ADD  WRK-SBTCTA                TO WRK-TOTCTA
           ADD  WRK-SBTDIS                TO WRK-TOTDIS
           ADD  WRK-SBT24H                TO WRK-TOT24H
           ADD  WRK-SBT48H                TO WRK-TOT48H
           ADD  WRK-SBT72H                TO WRK-TOT72H
           ADD  WRK-SBTPOT                TO WRK-TOTPOT
           MOVE ZEROS                     TO WRK-SBTCTA    WRK-SBTDIS
                                             WRK-SBT24H    WRK-SBT48H
                                             WRK-SBTPOT    WRK-SBT72H
      *    PERFORM  0300-ESCRIBIR-FOOTER
           PERFORM  CERRAR-IMPRESION
           CLOSE CCAMAEAHO   PLTFECHAS    PLTAGCORI
                 PLTSUCURS   CCACODPRO
           STOP RUN.
      *----------------------------------------------------------------
