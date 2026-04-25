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
       PROGRAM-ID.    CCA520.
       AUTHOR.        M.H.D.
       DATE-WRITTEN.  97/09/25.
      ******************************************************************
      * FUNCION: REP. INTERFASES PROCESADAS.                           *
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
           SELECT CCATABINT
               ASSIGN          TO DATABASE-CCATABINT
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *
           SELECT PLTPARGEN
               ASSIGN          TO DATABASE-PLTPARGEN
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
      *                                                                -
           SELECT CCA520IA
               ASSIGN          TO FORMATFILE-CCA520R
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL
               FILE STATUS     IS FILSTAT.
      *                                                                -
      ******************************************************************
      *                                                                *
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCATABINT
           LABEL RECORDS ARE STANDARD.
       01  REG-TABFI.
           COPY DDS-ALL-FORMATS        OF CCATABINT.
      *
       FD  PLTPARGEN
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTPARGEN.
           COPY DDS-ALL-FORMATS        OF PLTPARGEN.
      *
       FD  PLTFECHAS
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTFECHAS.
           COPY DDS-ALL-FORMATS        OF PLTFECHAS.
      *                                                                 IBM-CT
       FD  CCA520IA
           LABEL RECORDS ARE OMITTED.
       01  PRTREC.
           COPY DDS-ALL-FORMATS        OF CCA520R.
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
               05 WRK-TOTREG           PIC  9(008)        VALUE ZEROS.
               05 WRK-TOTDB            PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTCR            PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTTO            PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTNR-ER         PIC  9(008)        VALUE ZEROS.
               05 WRK-TOTDB-ER         PIC S9(013)V99     VALUE ZEROS.
               05 WRK-TOTCR-ER         PIC S9(013)V99     VALUE ZEROS.
      *
       01  VAR-TRABAJO.
           03  FLG-MONETARIO           PIC  9(001)        VALUE ZEROS.
                88 ES-NOMONETARIO                         VALUE 1.
                88 ES-MONETARIO                           VALUE 2.
           03  FLG-LINEA               PIC  9(001)        VALUE ZEROS.
                88 EN-LINEA                               VALUE 0.
                88 EN-BATCH                               VALUE 1.
           03  FLG-USERID              PIC  X(010)        VALUE SPACES.
      *
       01  CONTROLES.
           03  CTL-CCATABINT             PIC  X(002)        VALUE "NO".
               88  FIN-CCATABINT                            VALUE "SI".
               88  NO-FIN-CCATABINT                         VALUE "NO".
           03  CTL-REGISTRO            PIC  X(002)        VALUE "NO".
               88  BUEN-REGISTRO                          VALUE "SI".
               88  MAL-REGISTRO                           VALUE "NO".
       01  PA-CODEMP                     PIC 9(05)        VALUE 0.
      *
      ***************************************************************
      *
       LINKAGE SECTION.
       77  IND-MONET                   PIC  X(001).
       77  IND-LINEA                   PIC  X(001).
       77  IND-USER                    PIC  X(010).
       77  EQUIPO                      PIC  X(010).
      *
      ***************************************************************
      *
       PROCEDURE DIVISION USING IND-MONET IND-LINEA IND-USER
                                EQUIPO.
       0000-MAIN.
           PERFORM  0010-INICIAR
           PERFORM  0100-PROCESAR      UNTIL FIN-CCATABINT
           PERFORM  0200-ESC-FOOTER
           PERFORM  9999-TERMINAR.
      *----------------------------------------------------------------
       0010-INICIAR.
           MOVE IND-MONET                 TO FLG-MONETARIO
           MOVE IND-LINEA                 TO FLG-LINEA
           MOVE IND-USER                  TO FLG-USERID
           MOVE EQUIPO                    TO WRK-NOM-SUC
           OPEN INPUT   CCATABINT    PLTPARGEN    PLTFECHAS
           OPEN OUTPUT  CCA520IA
           CALL "PLTCODEMPP"              USING PA-CODEMP
      *    MOVE 001                       TO CODPAR   OF REG-PLTPARGEN
           MOVE PA-CODEMP                 TO CODEMP OF  PLTPARGEN
           READ PLTPARGEN   INVALID KEY
              DISPLAY "ERROR. ARCHIVO PLTPARGEN"
              PERFORM  9999-TERMINAR.
           MOVE NOMBAN   OF REG-PLTPARGEN    TO WRK-EMPRESA
           MOVE PA-CODEMP                 TO CODEMP OF  PLTFECHAS
           MOVE 011                       TO CODSIS   OF REG-PLTFECHAS
           READ PLTFECHAS   INVALID KEY
              DISPLAY "ERROR. ARCHIVO PLTFECHAS"
              PERFORM  9999-TERMINAR.
           MOVE FECPRO   OF REG-PLTFECHAS TO WRK-FECHA-PARA
           MOVE ZEROS                     TO WRK-FECHA-SYS
           CALL "SEC993" USING WRK-FECHA-SYS
           ACCEPT  WRK-HORA             FROM TIME
           PERFORM  0020-ENCABEZADO
           MOVE "NO"                      TO CTL-CCATABINT
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0030-LEER-CCATABINT  UNTIL FIN-CCATABINT
                                       OR    BUEN-REGISTRO.
      *-----------------------------------------------------------------
       0020-ENCABEZADO.
           IF WRK-LINEA > 55
              ADD  1                TO WRK-PAGINA
              IF ES-MONETARIO
                 MOVE "CCA520IAMO"  TO NOMLISTADO
                 MOVE "REP. DE INTERFASES MONETARIAS PROCESADAS"
                                    TO DESCLIST
              ELSE
                 MOVE "CCA520IANM"  TO NOMLISTADO
                 MOVE "REP. DE INTERFASES NO-MONETARIAS PROCESADAS"
                                    TO DESCLIST
              END-IF
              MOVE WRK-EMPRESA      TO EMPRESA
              MOVE WRK-PAGINA       TO PAGNRO
              MOVE FLG-USERID       TO USER
              MOVE WRK-FECHA-PARA   TO FECPARA
              MOVE WRK-FECHA-SYS    TO FECIMPR
              MOVE WRK-NOM-SUC      TO NOMBRESUC
              MOVE HHMMSS           TO HORA
              WRITE PRTREC  FORMAT IS "PHEAD"
              MOVE 7                TO WRK-LINEA.
      *----------------------------------------------------------------
       0030-LEER-CCATABINT.
           MOVE "SI"                      TO CTL-REGISTRO
           READ  CCATABINT    NEXT RECORD AT END
              MOVE "SI"                   TO CTL-CCATABINT.
           IF NO-FIN-CCATABINT
              IF ES-MONETARIO
                 IF INDNOV OF REG-TABFI = 1
                     MOVE "NO"            TO CTL-REGISTRO
                 END-IF
              ELSE
                 IF INDNOV OF REG-TABFI = 2
                     MOVE "NO"            TO CTL-REGISTRO.
      *----------------------------------------------------------------
       0100-PROCESAR.
           IF EN-LINEA
              IF ( NROREGLOK  OF REG-TABFI > 0 )
                 PERFORM  0110-IMP-DETALLELOK
              END-IF
              IF ( NROREGLER  OF REG-TABFI > 0 )
                 PERFORM  0120-ACUMULAR-LER
              END-IF
           ELSE
              IF ( NROREGBOK  OF REG-TABFI > 0 )
                  PERFORM  0130-IMP-DETALLEBOK
              END-IF
              IF ( NROREGBER  OF REG-TABFI > 0 )
                 PERFORM  0140-ACUMULAR-BER.
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0030-LEER-CCATABINT  UNTIL FIN-CCATABINT
                                       OR    BUEN-REGISTRO.
      *----------------------------------------------------------------
       0110-IMP-DETALLELOK.
           PERFORM  0020-ENCABEZADO
           MOVE NOMARC     OF REG-TABFI   TO NOMINTER
           MOVE DESCRI     OF REG-TABFI   TO DESINTER
           MOVE NROREGLOK  OF REG-TABFI   TO NUMREGIS
           MOVE ACUCRELOK  OF REG-TABFI   TO SLDINTCR
           MOVE ACUDEBLOK  OF REG-TABFI   TO SLDINTDB
           MOVE NROREGBER  OF REG-TABFI   TO NUMREGER
           MOVE ACUDEBBER  OF REG-TABFI   TO SLDDEBER
           MOVE ACUCREBER  OF REG-TABFI   TO SLDCREER
           ADD  NROREGLOK  OF REG-TABFI   TO WRK-TOTREG
           ADD  ACUCRELOK  OF REG-TABFI   TO WRK-TOTCR
           ADD  ACUDEBLOK  OF REG-TABFI   TO WRK-TOTDB
           WRITE PRTREC  FORMAT IS "PDETAIL"
           ADD  1                         TO WRK-LINEA.
      *----------------------------------------------------------------
       0120-ACUMULAR-LER.
           ADD  NROREGLER  OF REG-TABFI   TO WRK-TOTNR-ER
           ADD  ACUDEBLER  OF REG-TABFI   TO WRK-TOTDB-ER
           ADD  ACUCRELER  OF REG-TABFI   TO WRK-TOTCR-ER.
      *----------------------------------------------------------------
       0130-IMP-DETALLEBOK.
           PERFORM  0020-ENCABEZADO
           MOVE NOMARC     OF REG-TABFI   TO NOMINTER
           MOVE DESCRI     OF REG-TABFI   TO DESINTER
           MOVE NROREGBOK  OF REG-TABFI   TO NUMREGIS
           MOVE ACUCREBOK  OF REG-TABFI   TO SLDINTCR
           MOVE ACUDEBBOK  OF REG-TABFI   TO SLDINTDB
           MOVE NROREGBER  OF REG-TABFI   TO NUMREGER
           MOVE ACUDEBBER  OF REG-TABFI   TO SLDDEBER
           MOVE ACUCREBER  OF REG-TABFI   TO SLDCREER
           ADD  NROREGBOK  OF REG-TABFI   TO WRK-TOTREG
           ADD  ACUCREBOK  OF REG-TABFI   TO WRK-TOTCR
           ADD  ACUDEBBOK  OF REG-TABFI   TO WRK-TOTDB
           WRITE PRTREC  FORMAT IS "PDETAIL"
           ADD  1                         TO WRK-LINEA.
      *----------------------------------------------------------------
       0140-ACUMULAR-BER.
           ADD  NROREGLER  OF REG-TABFI   TO WRK-TOTNR-ER
           ADD  ACUDEBBER  OF REG-TABFI   TO WRK-TOTDB-ER
           ADD  ACUCREBER  OF REG-TABFI   TO WRK-TOTCR-ER.
      *----------------------------------------------------------------
       0200-ESC-FOOTER.
           IF ES-MONETARIO
              IF EN-LINEA
                 IF WRK-TOTNR-ER > 0
                    PERFORM  0210-ESC-EER
                 END-IF
              ELSE
                 IF WRK-TOTNR-ER > 0
                    PERFORM  0210-ESC-EER.
           MOVE WRK-TOTREG                TO TOTREGIS
           MOVE WRK-TOTCR                 TO SLDTOTCR
           MOVE WRK-TOTDB                 TO SLDTOTDB
           MOVE WRK-TOTNR-ER              TO TOTREGER
           MOVE WRK-TOTDB-ER              TO SLDTDBER
           MOVE WRK-TOTCR-ER              TO SLDTCRER
           WRITE PRTREC  FORMAT IS "PFOOT".
      *----------------------------------------------------------------
       0210-ESC-EER.
           MOVE "RECHAZOS"                TO NOMINTER
           MOVE "ERRORES EN INTERFASES"   TO DESINTER
           MOVE WRK-TOTNR-ER              TO NUMREGIS
           MOVE WRK-TOTCR-ER              TO SLDINTCR
           MOVE WRK-TOTDB-ER              TO SLDINTDB
           WRITE PRTREC  FORMAT IS "PDETAIL"
           ADD  1                         TO WRK-LINEA.
      *----------------------------------------------------------------
       9999-TERMINAR.
           CLOSE CCATABINT  PLTPARGEN    PLTFECHAS    CCA520IA
           STOP RUN.
      *----------------------------------------------------------------
