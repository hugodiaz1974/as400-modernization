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
       PROGRAM-ID.    CCA700.
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
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM03
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *        ORGANIZATION    IS SEQUENTIAL
      *        ACCESS MODE     IS SEQUENTIAL
      *        FILE STATUS     IS FILSTAT.
      *
           SELECT PLTSUCURS
               ASSIGN          TO DATABASE-PLTSUCURS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO
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
      *                                                                -
           SELECT CCA700IA
               ASSIGN          TO FORMATFILE-CCA700R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *                                                                -
      ******************************************************************
      *                                                                *
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS        OF CCAMOVIM03.
      *
       FD  PLTSUCURS
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTSUCURS.
           COPY DDS-ALL-FORMATS        OF PLTSUCURS.
      *
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  REG-TABTR.
           COPY DDS-ALL-FORMATS        OF CCACODTRN.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  REG-MAESTR.
           COPY DDS-ALL-FORMATS        OF CCAMAEAHO.
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
      *                                                                 IBM-CT
       FD  CCA700IA
           LABEL RECORDS ARE OMITTED.
       01  PRTREC.
           COPY DDS-ALL-FORMATS        OF CCA700R.
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
               05 WRK-SBTDB            PIC S9(013)V99     VALUE ZEROS.
               05 WRK-SBTCR            PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTCTA           PIC  9(009)        VALUE ZEROS.
               05 WRK-TOTDB            PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTCR            PIC S9(013)V99     VALUE ZEROS.
      *
       01  VAR-TRABAJO.
           03  FLG-USERID              PIC  X(010)        VALUE SPACES.
           03  FLG-ENCABE              PIC  9(001)        VALUE ZEROS.
           03  AGENCIA-ANT             PIC  9(005)        VALUE ZEROS.
           03  CODSUC-ANT              PIC  9(005)        VALUE ZEROS.
           03  CODMON-ANT              PIC  9(003)        VALUE ZEROS.
           03  CODSIS-ANT              PIC  9(003)        VALUE ZEROS.
           03  CODPRO-ANT              PIC  9(003)        VALUE ZEROS.
           03  AGCCTA-ANT              PIC  9(005)        VALUE ZEROS.
           03  CTANRO-ANT              PIC  9(017)        VALUE ZEROS.
       01  W-EXISTE-PLTSUCURS          PIC 9 VALUE ZEROS.
           88 NO-EXISTE-PLTSUCURS      VALUE 1.
           88 SI-EXISTE-PLTSUCURS      VALUE 0.
      *
       01  CONTROLES.
           03  CTL-CCAMOVIM            PIC  X(002)        VALUE "NO".
               88  FIN-CCAMOVIM                           VALUE "SI".
               88  NO-FIN-CCAMOVIM                        VALUE "NO".
      * -----------------------------------------
       01  W-CUENTA PIC 9(12) VALUE ZEROS.
       01  FILLER REDEFINES W-CUENTA.
           03 W-OFICTA PIC 9(04).
           03 W-NROCTA PIC 9(06).
           03 W-CODPRO PIC 99.
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
           03  W-NOMSPL                PIC X(07).
           03  W-NOMCOR                PIC X(03).
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
       01  CTL-REGISTROS               PIC 9 VALUE ZEROS.
           88 NO-HAY-REGISTROS         VALUE 0.
           88 SI-HAY-REGISTROS         VALUE 1.
       01  PA-CODEMP                   PIC 9(05)   VALUE ZEROS.
      ***************************************************************
           COPY PARGEN OF CCACPY.
      ***************************************************************
      *
       LINKAGE SECTION.
       77  IND-USER                    PIC  X(010).
       77  EQUIPO                      PIC  X(010).
      *
      ***************************************************************
      *
       PROCEDURE DIVISION  USING IND-USER  EQUIPO.
       0000-MAIN.
           PERFORM  0010-INICIAR
           PERFORM  0100-PROCESAR      UNTIL FIN-CCAMOVIM
           PERFORM  9999-TERMINAR.
      *----------------------------------------------------------------
       0010-INICIAR.
           CALL "PLTCODEMPP"           USING PA-CODEMP
           MOVE IND-USER                  TO FLG-USERID
           MOVE EQUIPO                    TO WRK-NOM-SUC
           OPEN INPUT   CCAMOVIM     PLTFECHAS     PLTAGCORI
                        CCACODTRN    CCAMAEAHO     PLTSUCURS
      *    OPEN OUTPUT  CCA700IA
           CALL "CCA501" USING LK-CCAPARGEN
           MOVE LK-NOMEMP                 TO WRK-EMPRESA
           MOVE 011                       TO CODSIS   OF REG-PLTFECHAS
           MOVE PA-CODEMP                 TO CODEMP OF REG-PLTFECHAS
           READ PLTFECHAS   INVALID KEY
              DISPLAY "ERROR. ARCHIVO PLTFECHAS"
              PERFORM  9999-TERMINAR.
           MOVE FECPRO   OF REG-PLTFECHAS    TO WRK-FECHA-PARA
           MOVE ZEROS                     TO WRK-FECHA-SYS
           CALL "SEC993" USING WRK-FECHA-SYS
           ACCEPT  WRK-HORA             FROM TIME
           MOVE ZEROS                     TO WRK-SBTCTA    WRK-TOTCTA
                                             WRK-SBTDB     WRK-TOTDB
                                             WRK-SBTCR     WRK-TOTCR
           MOVE "NO"                      TO CTL-CCAMOVIM
           MOVE ZEROS                     TO NROBNV OF CCAMOVIM
           MOVE ZEROS                     TO AGCCTA OF CCAMOVIM
           MOVE ZEROS                     TO CODMON OF CCAMOVIM
           MOVE ZEROS                     TO CODSIS OF CCAMOVIM
           MOVE ZEROS                     TO CODPRO OF CCAMOVIM
           MOVE ZEROS                     TO CTANRO OF CCAMOVIM
           MOVE ZEROS                     TO FORIGE OF CCAMOVIM
           MOVE ZEROS                     TO DEBCRE OF CCAMOVIM
           MOVE ZEROS                     TO CODTRA OF CCAMOVIM
           MOVE ZEROS                     TO IMPORT OF CCAMOVIM
           START CCAMOVIM KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE "SI" TO CTL-CCAMOVIM.
           IF NO-FIN-CCAMOVIM
              PERFORM  0030-LEER-CCAMOVIM
           END-IF.
           MOVE ZEROS TO CTL-REGISTROS
           IF NO-FIN-CCAMOVIM
              MOVE 1 TO CTL-REGISTROS
              MOVE AGCCTA  OF REG-MOVIM   TO AGENCIA-ANT
              MOVE NROBNV  OF REG-MOVIM   TO CODSUC-ANT
              PERFORM ABRIR-IMPRESION
              PERFORM  0020-ENCABEZADO
              PERFORM 0040-SUBTIT-1.
      *-----------------------------------------------------------------
       0020-ENCABEZADO.
           IF WRK-LINEA > 55
              MOVE 1                      TO FLG-ENCABE
              ADD  1                      TO WRK-PAGINA
              MOVE "CCA700R1"             TO NOMLISTADO OF CCA700IA
              MOVE FLG-USERID             TO USER OF CCA700IA
              MOVE WRK-EMPRESA            TO EMPRESA OF CCA700IA
              MOVE WRK-PAGINA             TO PAGNRO OF CCA700IA
              MOVE "REPORTE DE MOVIMIENTO DIARIO POR CUENTA         "
                                          TO DESCLIST OF CCA700IA
              MOVE WRK-FECHA-PARA         TO FECPARA OF CCA700IA
              MOVE WRK-NOM-SUC            TO NOMBRESUC OF CCA700IA
              MOVE HHMMSS                 TO HORA OF CCA700IA
              MOVE WRK-FECHA-SYS          TO FECIMPR OF CCA700IA
              WRITE PRTREC  FORMAT IS "PHEAD"
              MOVE 5                      TO WRK-LINEA.
      *----------------------------------------------------------------
       0030-LEER-CCAMOVIM.
           READ  CCAMOVIM    NEXT RECORD AT END
              MOVE "SI"                   TO CTL-CCAMOVIM.
      *----------------------------------------------------------------
       0040-SUBTIT-1.
           MOVE 0                         TO FLG-ENCABE
           MOVE AGENCIA-ANT               TO CODOFI
           PERFORM  0050-DESCRI-AGENCIA
           MOVE NOMAGC   OF  REG-PLTAGCORI   TO DESOFI
           MOVE NOMSUC   OF  PLTSUCURS       TO DESSUC
           WRITE PRTREC  FORMAT IS "PSUBT1"
           ADD  4                         TO WRK-LINEA.
      *----------------------------------------------------------------
       0050-DESCRI-AGENCIA.
           MOVE AGENCIA-ANT               TO AGCORI  OF REG-PLTAGCORI
           MOVE PA-CODEMP                 TO CODEMP  OF REG-PLTAGCORI
           READ PLTAGCORI      INVALID KEY
                MOVE " AGENCIA NO EXISTE "
                                          TO NOMAGC  OF REG-PLTAGCORI.
      *----------------------------------------------------------------
       0100-PROCESAR.
           IF CODSUC-ANT NOT = NROBNV OF CCAMOVIM
              PERFORM  0200-CAMBIO-AGENCIA
              PERFORM CERRAR-IMPRESION
              MOVE AGCCTA OF CCAMOVIM  TO AGENCIA-ANT
              MOVE NROBNV OF CCAMOVIM  TO CODSUC-ANT
              PERFORM ABRIR-IMPRESION
              PERFORM  0020-ENCABEZADO
              PERFORM 0040-SUBTIT-1
           END-IF.
           IF AGENCIA-ANT NOT  =  AGCCTA   OF  REG-MOVIM
              PERFORM  0200-CAMBIO-AGENCIA
              MOVE AGCCTA OF CCAMOVIM  TO AGENCIA-ANT
           END-IF.
           PERFORM  0110-IMP-DETALLE
           PERFORM  0030-LEER-CCAMOVIM.
      *----------------------------------------------------------------
       0110-IMP-DETALLE.
           PERFORM  0020-ENCABEZADO
           IF FLG-ENCABE = 1
              PERFORM 0040-SUBTIT-1.
           MOVE CTANRO     OF REG-MOVIM   TO W-NROCTA
           MOVE AGCCTA     OF REG-MOVIM   TO W-OFICTA
           MOVE CODPRO     OF REG-MOVIM   TO W-CODPRO
           MOVE W-CUENTA                  TO NUMCTA
           IF CODMON OF CCAMOVIM NOT = CODMON-ANT OR
              CODSIS OF CCAMOVIM NOT = CODSIS-ANT OR
              CODPRO OF CCAMOVIM NOT = CODPRO-ANT OR
              AGCCTA OF CCAMOVIM NOT = AGCCTA-ANT OR
              CTANRO OF CCAMOVIM NOT = CTANRO-ANT
              PERFORM 0120-LEER-NOMBRE
              MOVE DESCRI  OF REG-MAESTR  TO DESCTA
           ELSE
              MOVE SPACES                 TO DESCTA
              MOVE ZEROS                  TO NUMCTA
           END-IF.
           MOVE FORIGE     OF REG-MOVIM   TO FECMOV
           ADD  1                         TO WRK-SBTCTA
           MOVE IMPORT     OF REG-MOVIM   TO IMPMOV
           MOVE NROREF     OF REG-MOVIM   TO REFERE
           MOVE CODTRA     OF REG-MOVIM   TO CODMVT
           PERFORM  0130-LEER-CODIGO
           MOVE NOLTRA     OF REG-TABTR   TO DESMOV
           IF DEBCRE  OF REG-TABTR = 1
              ADD  IMPORT  OF REG-MOVIM   TO WRK-SBTDB
           ELSE
              ADD  IMPORT  OF REG-MOVIM   TO WRK-SBTCR.
           WRITE PRTREC  FORMAT IS "PDETAIL"
           ADD  1                         TO WRK-LINEA.
      *----------------------------------------------------------------
       0120-LEER-NOMBRE.
           MOVE AGCCTA     OF REG-MOVIM   TO AGCCTA    OF REG-MAESTR
                                             AGCCTA-ANT
           MOVE CTANRO     OF REG-MOVIM   TO CTANRO    OF REG-MAESTR
                                             CTANRO-ANT
           MOVE CODMON     OF REG-MOVIM   TO CODMON    OF REG-MAESTR
                                             CODMON-ANT
           MOVE CODSIS     OF REG-MOVIM   TO CODSIS    OF REG-MAESTR
                                             CODSIS-ANT
           MOVE CODPRO     OF REG-MOVIM   TO CODPRO    OF REG-MAESTR
                                             CODPRO-ANT
           READ CCAMAEAHO   INVALID KEY
              MOVE "CUENTA INVALIDA"      TO DESCRI    OF REG-MAESTR.
      *----------------------------------------------------------------
       0130-LEER-CODIGO.
           MOVE CODTRA     OF REG-MOVIM   TO CODTRA    OF REG-TABTR
           READ CCACODTRN    INVALID KEY
              MOVE 1                      TO DEBCRE    OF REG-TABTR
              MOVE "CODIGO INVALIDO"      TO NOLTRA    OF REG-TABTR.
      *----------------------------------------------------------------
       0200-CAMBIO-AGENCIA.
           PERFORM  0210-ESCRIBIR-PIE
           PERFORM  0220-ACUMULAR-TOTAL
           MOVE AGCCTA  OF REG-MOVIM      TO AGENCIA-ANT.
           MOVE ZEROS TO WRK-PAGINA.
      *    PERFORM  0020-ENCABEZADO.
      *----------------------------------------------------------------
       0210-ESCRIBIR-PIE.
           MOVE WRK-SBTCTA                TO SBTREG
           MOVE WRK-SBTDB                 TO SBTDEB
           MOVE WRK-SBTCR                 TO SBTCRE
           WRITE PRTREC  FORMAT IS "PPIE".
           MOVE 60                        TO WRK-LINEA.
      *----------------------------------------------------------------
       0220-ACUMULAR-TOTAL.
           ADD  WRK-SBTCTA                TO WRK-TOTCTA
           ADD  WRK-SBTDB                 TO WRK-TOTDB
           ADD  WRK-SBTCR                 TO WRK-TOTCR
           MOVE ZEROS                     TO WRK-SBTCTA    WRK-SBTDB
                                             WRK-SBTCR.
      *----------------------------------------------------------------
       0300-ESCRIBIR-FOOTER.
           MOVE WRK-TOTCTA                TO TOTREG
           MOVE WRK-TOTDB                 TO TOTDEB
           MOVE WRK-TOTCR                 TO TOTCRE
           WRITE PRTREC  FORMAT IS "PFOOT".
           MOVE 60                        TO WRK-LINEA.
      *----------------------------------------------------------------
       ABRIR-IMPRESION.
           MOVE CODSUC-ANT          TO CODSUC OF PLTSUCURS.
           MOVE PA-CODEMP           TO CODEMP OF PLTSUCURS
           MOVE ZEROS TO W-EXISTE-PLTSUCURS
           READ PLTSUCURS INVALID KEY
                MOVE 1 TO W-EXISTE-PLTSUCURS
           END-READ.
           IF (SI-EXISTE-PLTSUCURS)
              MOVE "CCA700R"          TO W-NOMARC1
              MOVE "CCA700R"          TO W-NOMARC2
              MOVE "CCA700R"          TO W-NOMARC5
              MOVE "CCAMOVD"          TO W-NOMSPL
              MOVE 86                 TO W-LNGCMD
              MOVE NOMCOR OF REGSUCURS TO W-NOMCOR
              MOVE NOMIMP OF REGSUCURS TO W-NOMIMP
              CALL "QCMDEXC"          USING W-OVRPRTF , W-LNGCMD
              OPEN OUTPUT CCA700IA
           END-IF.
      *--------------------------------------------------------------*
       CERRAR-IMPRESION.
           MOVE 20                 TO W-LNGCMD
           CLOSE CCA700IA
           CALL "QCMDEXC"          USING W-DLTOVR-PRT , W-LNGCMD.
      *----------------------------------------------------------------
       9999-TERMINAR.
           IF SI-HAY-REGISTROS
              PERFORM  0210-ESCRIBIR-PIE
           END-IF
      *    PERFORM  0220-ACUMULAR-TOTAL
      *    PERFORM  0300-ESCRIBIR-FOOTER
           CLOSE CCAMOVIM   PLTFECHAS    PLTAGCORI     CCA700IA
                 CCACODTRN  CCAMAEAHO    PLTSUCURS
           STOP RUN.
      *----------------------------------------------------------------
