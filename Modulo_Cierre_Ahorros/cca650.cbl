       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CCA650.
       AUTHOR.        VGQ.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: GENERACION DEL REPORTE MENSUAL DE CAUSACION         *
      *          DETALLADO POR CLIENTE.                              *
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
           SELECT CCACAUSAC
               ASSIGN          TO DATABASE-CCACAUSAC
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCACODPRO
               ASSIGN          TO DATABASE-CCACODPRO
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
           SELECT CLIMAE
               ASSIGN          TO DATABASE-CLIMAE
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT REPORTE
               ASSIGN          TO FORMATFILE-CCA650R1
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT REPORT1
               ASSIGN          TO FORMATFILE-CCA650R2
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *
       FD  CCACODPRO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACODPRO.
           COPY DDS-ALL-FORMATS OF CCACODPRO.
      *                                                                 IBM-CT
       FD  CCACAUSAC
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACAUSAC.
           COPY DDS-ALL-FORMATS OF CCACAUSAC.
      *                                                                 IBM-CT
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *                                                                 IBM-CT
       FD  CLIMAE
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CLIMAE.
           COPY DDS-ALL-FORMATS OF CLIMAE.
      *                                                                 IBM-CT
       FD  REPORTE
           LABEL RECORDS ARE STANDARD.
       01  REPORTE-REG.
           COPY DDS-ALL-FORMATS OF CCA650R.
      *                                                                 IBM-CT
       FD  REPORT1
           LABEL RECORDS ARE STANDARD.
       01  REPORT1-REG.
           COPY DDS-ALL-FORMATS OF CCA650R.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCAMAEAHO            PIC 9(01)  VALUE 0.
               88  ERROR-CCAMAEAHO                 VALUE 1.
           05  CTL-CCACAUSAC            PIC 9(01)  VALUE 0.
               88  ERROR-CCACAUSAC                 VALUE 1.
           05  CTL-CLIMAE              PIC 9(01)  VALUE 0.
               88  ERROR-CLIMAE                   VALUE 1.
           05  CTL-PLTAGCORI              PIC 9(01)  VALUE 0.
               88  ERROR-PLTAGCORI                   VALUE 1.
           05  CTL-CCACODPRO              PIC 9(01)  VALUE 0.
               88  ERROR-CCACODPRO                   VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01)  VALUE 0.
               88  FIN-PROGRAMA                   VALUE 1.
      *--------------------------------------------------------------*
       01  CTA-ANT.
           05  W-PROANT                PIC 9(05)  VALUE ZEROS.
           05  W-AGEANT                PIC 9(05)  VALUE ZEROS.
           05  W-CTAANT                PIC 9(15)  VALUE ZEROS.
       01   CTA-CCACAUSAC.
           05  W-PROCAU                PIC 9(05)  VALUE ZEROS.
           05  W-AGECAU                PIC 9(05)  VALUE ZEROS.
           05  W-CTACAU                PIC 9(15)  VALUE ZEROS.
      * -----------------------------------------
       01  W-CUENTA PIC 9(12) VALUE ZEROS.
       01  FILLER REDEFINES W-CUENTA.
           03 W-OFICTA PIC 9(04).
           03 W-NROCTA PIC 9(06).
           03 W-CODPRO PIC 99.
      *--------------------------------------------------------------*
       01  VARIABLES.
      *--------------------------------------------------------------*
           05  W-RET                   PIC 9(03)    VALUE ZEROS.
           05  W-NOMOFI                PIC X(40)    VALUE SPACES.
           05  W-NOMPRO                PIC X(40)    VALUE SPACES.
           05  NOMBRE                  PIC X(40)    VALUE SPACES.
           05  OFIANT                  PIC 9(05)    VALUE ZEROS.
           05  PROANT                  PIC 9(05)    VALUE ZEROS.
           05  W-HORA                  PIC 9(08)    VALUE ZEROS.
           05  RED-W-HORA              REDEFINES    W-HORA.
               10 HORA                 PIC 9(06).
               10 FILLER               PIC 9(02).
           05  W-USRID                 PIC X(10)    VALUE SPACES.
           05  W-FECHA                 PIC  9(08)   VALUE ZEROS.
           05  RED-W-FECHA             REDEFINES    W-FECHA.
               10 SIGLO                PIC 9(02).
               10 ANO                  PIC 9(02).
               10 MES                  PIC 9(02).
               10 DIA                  PIC 9(02).
           05  W-PAGINA                PIC 9(06)     VALUE ZEROS.
           05  W-PAGINC                PIC 9(06)     VALUE ZEROS.
           05  W-NIT                   PIC 9(13)     VALUE ZEROS.
           05  W-FECLIQ                PIC 9(08)     VALUE ZEROS.
           05  W-CODRET                PIC 9(01)     VALUE ZEROS.
      *--------------------------------------------------------------*
      * TOTALES POR CLIENTE Y CONSOLIDADOS POR AGENCIA.
      *--------------------------------------------------------------*
           05  TOT-INTCAU              PIC 9(15)V99  VALUE ZEROS.
           05  W-SALACT                PIC S9(15)V99  VALUE ZEROS.
           05  W-EQUEFE                PIC S9(05)V9(6) VALUE ZEROS.
           05  TOT-INTPAG              PIC 9(15)V99  VALUE ZEROS.
           05  TOT-RETFTE              PIC 9(15)V99  VALUE ZEROS.
           05  TOT-INPPAG              PIC 9(15)V99  VALUE ZEROS.
           05  TOT-REPPAG              PIC 9(15)V99  VALUE ZEROS.

           05  TOD-INTCAU              PIC 9(15)V99  VALUE ZEROS.
           05  TOD-INTPAG              PIC 9(15)V99  VALUE ZEROS.
           05  TOD-RETFTE              PIC 9(15)V99  VALUE ZEROS.
           05  TOD-INPPAG              PIC 9(15)V99  VALUE ZEROS.
           05  TOD-REPPAG              PIC 9(15)V99  VALUE ZEROS.

           05  TOC-INTCAU              PIC 9(15)V99  VALUE ZEROS.
           05  TOC-INTPAG              PIC 9(15)V99  VALUE ZEROS.
           05  TOC-RETFTE              PIC 9(15)V99  VALUE ZEROS.
           05  TOC-INPPAG              PIC 9(15)V99  VALUE ZEROS.
           05  TOC-REPPAG              PIC 9(15)V99  VALUE ZEROS.
      *--------------------------------------------------------------*
      * ALMACENA EL ULTIMO DIA CALENDARIO DEL MES QUE CORTA.
      *--------------------------------------------------------------*
           05  W-FECHACTL-1             PIC 9(08)    VALUE ZEROS.
           05  R-FECHACTL-1             REDEFINES    W-FECHACTL-1.
               10  ANO-CTL-1            PIC 9(04).
               10  MES-CTL-1            PIC 9(02).
               10  DIA-CTL-1            PIC 9(02).
      *--------------------------------------------------------------*
           COPY EXTRACT OF CCACPY.
           COPY PARGEN  OF CCACPY.
           COPY FECHAS  OF CCACPY.
           COPY PLT219  OF CCACPY.
      *--------------------------------------------------------------*
      * FECHA DE CONTROL.
      *--------------------------------------------------------------*
       01  FECHAS-CONTROL.
           05  W-FECHACTL-0             PIC 9(08)    VALUE ZEROS.
           05  R-FECHACTL-0             REDEFINES    W-FECHACTL-0.
               10  ANO-CTL-0            PIC 9(04).
               10  MES-CTL-0            PIC 9(02).
               10  DIA-CTL-0            PIC 9(02).
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       77  L-USER                      PIC  X(10).
       77  L-FECLIQ                    PIC  9(08).
       77  L-CODRET                    PIC  9(01).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING L-USER L-FECLIQ L-CODRET.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           CALL "CCA500" USING LK-FECHAS                                A
           CALL "CCA501" USING LK-CCAPARGEN.
           OPEN OUTPUT REPORTE
                       REPORT1
                INPUT  CCAMAEAHO  CCACODPRO
                       CCACAUSAC
                       CLIMAE
                       PLTAGCORI.
           CALL "EXTRACT" USING W-DA EX-DATE.
           MOVE EX-DATE-8              TO W-FECHA
           ACCEPT W-HORA  FROM TIME

           MOVE L-USER   TO W-USRID
           MOVE L-FECLIQ TO W-FECLIQ
           MOVE L-CODRET TO W-CODRET

           PERFORM CALCULAR-FIN-MES

           PERFORM LEER-CCACAUSAC
           IF ERROR-CCACAUSAC THEN
              PERFORM COLOCAR-TITULOS
              PERFORM COLOCAR-TITULOS-C
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              WRITE REPORT1-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA
           ELSE
              PERFORM COLOCAR-TITULOS
              PERFORM COLOCAR-TITULOS-C
              PERFORM COLOCAR-AGENCIA
              MOVE AGCCTA OF REGCAUSAC TO W-AGECAU W-AGEANT OFIANT
              MOVE CODPRO OF REGCAUSAC TO W-AGECAU W-AGEANT PROANT
                                          W-PROANT W-PROCAU
              MOVE CTANRO OF REGCAUSAC TO W-CTACAU W-CTAANT
              PERFORM REVISAR-MAESTRO-AHORROS
              PERFORM REVISAR-RETENCION.
      *--------------------------------------------------------------*
       PROCESAR.
           IF AGCCTA OF REGCAUSAC NOT = OFIANT OR
              CODPRO OF REGCAUSAC NOT = PROANT
              ADD TOT-INTCAU TO TOC-INTCAU
              ADD TOT-INTPAG TO TOC-INTPAG
              ADD TOT-RETFTE TO TOC-RETFTE
              ADD TOT-INPPAG TO TOC-INPPAG
              ADD TOT-REPPAG TO TOC-REPPAG
              PERFORM IMPRIMIR-DETALLE
              INITIALIZE TOT-INTCAU
                         TOT-INTPAG
                         TOT-RETFTE
                         TOT-INPPAG
                         TOT-REPPAG
              PERFORM COLOCAR-TOTALES
              PERFORM COLOCAR-TITULOS
              PERFORM COLOCAR-AGENCIA
              MOVE AGCCTA OF REGCAUSAC TO W-AGEANT
              MOVE CODPRO OF REGCAUSAC TO W-PROANT PROANT
              MOVE CTANRO OF REGCAUSAC TO W-CTAANT
              MOVE AGCCTA OF REGCAUSAC TO OFIANT
              PERFORM REVISAR-MAESTRO-AHORROS
              PERFORM REVISAR-RETENCION.
           IF CTA-CCACAUSAC NOT = CTA-ANT THEN
              ADD TOT-INTCAU TO TOC-INTCAU
              ADD TOT-INTPAG TO TOC-INTPAG
              ADD TOT-RETFTE TO TOC-RETFTE
              ADD TOT-INPPAG TO TOC-INPPAG
              ADD TOT-REPPAG TO TOC-REPPAG
              PERFORM IMPRIMIR-DETALLE
              MOVE AGCCTA OF REGCAUSAC TO W-AGEANT
              MOVE CTANRO OF REGCAUSAC TO W-CTAANT
              PERFORM REVISAR-MAESTRO-AHORROS
              PERFORM REVISAR-RETENCION
              INITIALIZE TOT-INTCAU
                         TOT-INTPAG
                         TOT-RETFTE
                         TOT-INPPAG
                         TOT-REPPAG.
           PERFORM PROCESAR-REGISTRO
           PERFORM LEER-CCACAUSAC
           IF ERROR-CCACAUSAC THEN
              PERFORM IMPRIMIR-DETALLE
              ADD TOT-INTCAU TO TOC-INTCAU
              ADD TOT-INTPAG TO TOC-INTPAG
              ADD TOT-RETFTE TO TOC-RETFTE
              ADD TOT-INPPAG TO TOC-INPPAG
              ADD TOT-REPPAG TO TOC-REPPAG
              PERFORM COLOCAR-TOTALES
              WRITE REPORTE-REG FORMAT IS "FOOTER"
              WRITE REPORT1-REG FORMAT IS "FOOTER"
              MOVE 1 TO CTL-PROGRAMA
           ELSE
              MOVE CODPRO OF REGCAUSAC TO W-PROCAU
              MOVE AGCCTA OF REGCAUSAC TO W-AGECAU
              MOVE CTANRO OF REGCAUSAC TO W-CTACAU.
      *--------------------------------------------------------------*
       PROCESAR-REGISTRO.
            MOVE SALACT OF REGCAUSAC TO W-SALACT
            MOVE EQUEFE OF REGCAUSAC TO W-EQUEFE
            ADD VALCAU OF REGCAUSAC TO TOT-INTCAU
                                       TOT-INTPAG
            ADD VLRRET OF REGCAUSAC TO TOT-RETFTE.
      *     IF FORIGE OF REGCAUSAC NOT > W-FECHACTL-1 THEN
      *        ADD VALCAU OF REGCAUSAC TO TOT-INTCAU
      *                                   TOT-INTPAG
      *        IF W-RET = 1 THEN
      *            ADD VLRRET OF REGCAUSAC TO  TOT-RETFTE
      *        ELSE
      *            NEXT SENTENCE
      *     ELSE
      *        ADD VALCAU OF REGCAUSAC TO TOT-INTCAU
      *                                   TOT-INPPAG
      *        IF W-RET = 1 THEN
      *            ADD VLRRET OF REGCAUSAC TO  TOT-REPPAG.
      *
      *
      *--------------------------------------------------------------*
       REVISAR-MAESTRO-AHORROS.
           INITIALIZE W-NIT
           MOVE CODMON OF REGCAUSAC TO CODMON OF REGMAEAHO
           MOVE CODSIS OF REGCAUSAC TO CODSIS OF REGMAEAHO
           MOVE CODPRO OF REGCAUSAC TO CODPRO OF REGMAEAHO
           MOVE AGCCTA OF REGCAUSAC TO AGCCTA OF REGMAEAHO
           MOVE CTANRO OF REGCAUSAC TO CTANRO OF REGMAEAHO
           PERFORM LEER-CCAMAEAHO
           IF NOT ERROR-CCAMAEAHO THEN
              MOVE DESCRI OF REGMAEAHO TO NOMBRE
              IF NITCTA OF REGMAEAHO NOT = ZEROS THEN
                 MOVE NITCTA OF REGMAEAHO TO W-NIT
              ELSE
              IF NITCT2 OF REGMAEAHO NOT = ZEROS THEN
                 MOVE NITCT2 OF REGMAEAHO TO W-NIT
              ELSE
              IF NITCT3 OF REGMAEAHO NOT = ZEROS THEN
                 MOVE NITCT3 OF REGMAEAHO TO W-NIT
              ELSE
                 MOVE ZEROS               TO W-NIT
           ELSE
              INITIALIZE  W-NIT NOMBRE.
      *--------------------------------------------------------------*
       REVISAR-RETENCION.
           MOVE W-NIT TO NUMINT OF CLIMAE
           PERFORM LEER-CLIMAE
           IF ERROR-CLIMAE THEN
              MOVE ZEROS             TO W-RET
           ELSE
              MOVE NITCLI OF CLIMAE  TO W-NIT
              MOVE RETFTE OF CLIMAE  TO W-RET.
      *--------------------------------------------------------------*
       LEER-CCAMAEAHO.
           MOVE 0 TO CTL-CCAMAEAHO
           READ CCAMAEAHO INVALID KEY MOVE 1 TO CTL-CCAMAEAHO.
      *--------------------------------------------------------------*
       LEER-CCACAUSAC.
           MOVE 0 TO CTL-CCACAUSAC
           READ CCACAUSAC NEXT RECORD AT END MOVE 1 TO CTL-CCACAUSAC.
      *--------------------------------------------------------------*
       LEER-CLIMAE.
           MOVE 0 TO CTL-CLIMAE
           READ CLIMAE INVALID KEY MOVE 1 TO CTL-CLIMAE.
      *--------------------------------------------------------------*
       LEER-PLTAGCORI.
           MOVE 0   TO CTL-PLTAGCORI
           READ PLTAGCORI INVALID KEY MOVE 1 TO CTL-PLTAGCORI.
      *--------------------------------------------------------------*
       LEER-CCACODPRO.
           MOVE 0   TO CTL-CCACODPRO.
           READ CCACODPRO INVALID KEY MOVE 1 TO CTL-CCACODPRO.
      *--------------------------------------------------------------*
      *    W-FECHACTL-1 ES EL ULTIMO DIA CALENDARIO DEL MES.
      *--------------------------------------------------------------*
       CALCULAR-FIN-MES.
           MOVE W-FECLIQ             TO W-FECHACTL-0
           MOVE W-FECHACTL-0         TO W-FECHACTL-1.
           PERFORM PROYECTAR-DIAS    UNTIL MES-CTL-0 NOT = MES-CTL-1.
      *--------------------------------------------------------------*
       PROYECTAR-DIAS.
           MOVE W-FECHACTL-0 TO W-FECHACTL-1.
           PERFORM SUMAR-UN-DIA-CALENDARIO.
      *--------------------------------------------------------------*
       SUMAR-UN-DIA-CALENDARIO.
           MOVE W-FECHACTL-0 TO LK219-FECHA1
           MOVE ZEROS        TO LK219-FECHA2
           MOVE ZEROS        TO LK219-FECHA3
           MOVE 1            TO LK219-TIPFMT
           MOVE 2            TO LK219-BASCLC
           MOVE 1            TO LK219-NRODIA
           MOVE 1            TO LK219-INDDSP
           MOVE 9            TO LK219-DIASEM
           MOVE SPACES       TO LK219-NOMDIA
           MOVE SPACES       TO LK219-NOMMES
           MOVE ZEROS        TO LK219-CODRET
           MOVE SPACES       TO LK219-MSGERR
           MOVE 2            TO LK219-TIPOPR
           PERFORM CALL-PLT219
           MOVE LK219-FECHA3   TO W-FECHACTL-0.
      *--------------------------------------------------------------*
       CALL-PLT219.
           CALL "PLT219" USING LK219-FECHA1
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
       COLOCAR-TITULOS.
           INITIALIZE HEADER-O OF REPORTE-REG
           ADD  1                 TO W-PAGINA
           MOVE "CCA650    "      TO NROPRO  OF REPORTE-REG
           MOVE W-USRID           TO USER    OF REPORTE-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORTE-REG
           MOVE W-PAGINA          TO PAGNRO  OF REPORTE-REG
           MOVE "******* REPORTE DE CAUSACION DE AHORROS *********"
                                  TO NOMLIS  OF REPORTE-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORTE-REG
           MOVE HORA              TO HORPRO  OF REPORTE-REG
           MOVE W-FECHA           TO FECSYS  OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "HEADER".
      *--------------------------------------------------------------*
       COLOCAR-TITULOS-C.
           INITIALIZE HEADER-O OF REPORT1-REG
           ADD  1                 TO W-PAGINC
           MOVE "CCA650    "      TO NROPRO  OF REPORT1-REG
           MOVE W-USRID           TO USER    OF REPORT1-REG
           MOVE LK-NOMEMP         TO EMPRESA OF REPORT1-REG
           MOVE W-PAGINC          TO PAGNRO  OF REPORT1-REG
           MOVE "****** REPORTE CAUSACION DE AHORROS ***********"
                                  TO NOMLIS  OF REPORT1-REG
           MOVE LK-FECHA-HOY            TO FECPAR  OF REPORT1-REG
           MOVE HORA              TO HORPRO  OF REPORT1-REG
           MOVE W-FECHA           TO FECSYS  OF REPORT1-REG
           WRITE REPORT1-REG FORMAT IS "HEADER"
           WRITE REPORT1-REG FORMAT IS "TITCON".
      *--------------------------------------------------------------*
       COLOCAR-AGENCIA.
           INITIALIZE AGENCIA-O     OF REPORTE-REG
           MOVE CODPRO OF REGCAUSAC TO CODPRO OF CCACODPRO
                                       CODPRO OF REPORTE-REG
           PERFORM LEER-CCACODPRO
           IF NOT ERROR-CCACODPRO
              MOVE DESCRI OF CCACODPRO TO NOMPRO OF REPORTE-REG
                                         W-NOMPRO
           ELSE
              MOVE ALL "*"             TO NOMPRO OF REPORTE-REG
                                         W-NOMPRO
           END-IF
           MOVE AGCCTA OF REGCAUSAC TO AGCORI OF PLTAGCORI
                                       AGEN   OF REPORTE-REG
           PERFORM LEER-PLTAGCORI
           IF NOT ERROR-PLTAGCORI THEN
              MOVE NOMAGC OF PLTAGCORI  TO DEAGE OF REPORTE-REG
                                         W-NOMOFI
           ELSE
              MOVE "AGENCIA INVALIDA" TO DEAGE OF REPORTE-REG
                                         W-NOMOFI.
           WRITE REPORTE-REG FORMAT IS "AGENCIA"
           WRITE REPORTE-REG FORMAT IS "TITULOS".
      *--------------------------------------------------------------*
       IMPRIMIR-DETALLE.
           INITIALIZE DETALLE-O                OF REPORTE-REG
           MOVE CTANRO OF REGMAEAHO TO W-NROCTA
           MOVE AGCCTA OF REGMAEAHO TO W-OFICTA
           MOVE CODPRO OF REGMAEAHO TO W-CODPRO
           MOVE W-CUENTA            TO NROCTA  OF REPORTE-REG
           MOVE NOMBRE              TO NOMCLI  OF REPORTE-REG
           MOVE W-NIT               TO NITCLI  OF REPORTE-REG
      *    MOVE SALACT OF REGCAUSAC TO SALACT  OF REPORTE-REG
           MOVE W-SALACT            TO SALACT  OF REPORTE-REG
           MOVE W-EQUEFE            TO EQUEFE  OF REPORTE-REG
      *    MOVE EQUEFE OF REGCAUSAC TO EQUEFE  OF REPORTE-REG
           MOVE TOT-INTCAU          TO INTCAU  OF REPORTE-REG
      *    MOVE TOT-INTPAG          TO INTPAG  OF REPORTE-REG
           MOVE TOT-RETFTE          TO RTEFTE  OF REPORTE-REG
      *    MOVE TOT-INPPAG          TO INTPPAG OF REPORTE-REG
      *    MOVE TOT-REPPAG          TO RETPPAG OF REPORTE-REG
           IF TOT-INTCAU > ZEROS OR
              TOT-RETFTE > ZEROS
              WRITE REPORTE-REG FORMAT IS "DETALLE" AT EOP
                PERFORM COLOCAR-TITULOS
                PERFORM COLOCAR-AGENCIA.
      *--------------------------------------------------------------*
       COLOCAR-TOTALES.
           INITIALIZE TOTALES-O                 OF REPORTE-REG
           MOVE TOC-INTCAU          TO TINTCAU  OF REPORTE-REG
      *    MOVE TOC-INTPAG          TO TINTPAG  OF REPORTE-REG
           MOVE TOC-RETFTE          TO TRTEFTE  OF REPORTE-REG
      *    MOVE TOC-INPPAG          TO TINTPPAG OF REPORTE-REG
      *    MOVE TOC-REPPAG          TO TRETPPAG OF REPORTE-REG
           WRITE REPORTE-REG FORMAT IS "TOTALES" AT EOP
                 PERFORM COLOCAR-TITULOS
                 PERFORM COLOCAR-AGENCIA.
           PERFORM IMPRIMR-CONSOLIDADO.
      *--------------------------------------------------------------*
       IMPRIMR-CONSOLIDADO.
           INITIALIZE CONSOL-O                  OF REPORT1-REG
           MOVE OFIANT              TO AGECON   OF REPORT1-REG
           MOVE PROANT              TO PROCON   OF REPORT1-REG
           MOVE W-NOMOFI            TO DESAGE   OF REPORT1-REG
           MOVE W-NOMPRO            TO NOMCON   OF REPORT1-REG
           MOVE TOC-INTCAU          TO CINTCAU  OF REPORT1-REG
      *    MOVE TOC-INTPAG          TO CINTPAG  OF REPORT1-REG
           MOVE TOC-RETFTE          TO CRTEFTE  OF REPORT1-REG
      *    MOVE TOC-INPPAG          TO CINTPPAG OF REPORT1-REG
      *    MOVE TOC-REPPAG          TO CRETPPAG OF REPORT1-REG
           WRITE REPORT1-REG FORMAT IS "CONSOL" AT EOP
                 PERFORM COLOCAR-TITULOS-C.
           INITIALIZE TOC-INTCAU
                      TOC-INTPAG
                      TOC-RETFTE
                      TOC-INPPAG
                      TOC-REPPAG.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE REPORTE     CCACODPRO
                 REPORT1
                 CCAMAEAHO
                 CCACAUSAC
                 CLIMAE
                 PLTAGCORI.
           STOP RUN.
