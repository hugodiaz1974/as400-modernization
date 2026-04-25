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
       PROGRAM-ID.    CCA680.
       AUTHOR.        M.H.D.
       DATE-WRITTEN.  97/10/10.
      ******************************************************************
      * FUNCION: REP. FICHAS DE CUENTAS.                               *
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
      *    SELECT SIIC45
      *        ASSIGN          TO DATABASE-SIIC45
      *        ORGANIZATION    IS INDEXED
      *        ACCESS MODE     IS DYNAMIC
      *        RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
      *        FILE STATUS     IS FILSTAT.
      *
      *
           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
               FILE STATUS     IS FILSTAT.
      *                                                                -
           SELECT CCA680IA
               ASSIGN          TO FORMATFILE-CCA680R
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
       01  REG-MAEAHO.
           COPY DDS-ALL-FORMATS        OF CCAMAEAHO.
      *
       FD  CCATABLAS
           LABEL RECORDS ARE STANDARD.
       01  REG-TABLAS.
           COPY DDS-ALL-FORMATS        OF CCATABLAS.
      *
      *FD  SIIC45
      *    LABEL RECORDS ARE STANDARD.
      *01  REG-SIIC45.
      *    COPY DDS-ALL-FORMATS        OF SIIC45.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTAGCORI.
           COPY DDS-ALL-FORMATS        OF PLTAGCORI.
      *                                                                 IBM-CT
       FD  CCA680IA
           LABEL RECORDS ARE OMITTED.
       01  PRTREC.
           COPY DDS-ALL-FORMATS        OF CCA680R.
      *
      ******************************************************************
      *                                                                -
       WORKING-STORAGE SECTION.
      *
           COPY   CATABLASR1           OF CCACPY.                        IBM-CT
      *
       01  FILSTAT.
           03  ERR-FLG                 PIC  X(001).
           03  PFK-BYTE                PIC  X(001).
      *
       01  ARG-COR052.
           05  LNROIDE            PIC  9(013).
           05  LDIGCHQ            PIC  9(001).
           05  LSIIC40            PIC  9(001).
           05  LSIIF45            PIC  9(001).
           05  LRETNOM            PIC  X(050).
           05  LCODRET            PIC  9(001).
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
               05 WRK-TOTACP           PIC  9(008)        VALUE ZEROS.
               05 WRK-TOTRCH           PIC  9(008)        VALUE ZEROS.
               05 WRK-TOTANU           PIC  9(008)        VALUE ZEROS.
      *
       01  VAR-TRABAJO.
           03  FLG-USERID              PIC  X(010)        VALUE SPACES.
           03  FLG-ENCABE              PIC  9(001)        VALUE ZEROS.
           03  AGENCIA                 PIC  9(003)        VALUE ZEROS.
           03  WRK-NUMIDENT            PIC  9(013)        VALUE ZEROS.
           03  WRK-OBSERVACION         PIC  X(050)        VALUE SPACES.
           03  CONT-OBSERV             PIC  9(002)        VALUE ZEROS.
           03  RED-OBS-TOTAL          REDEFINES   WRK-OBSERVACION.
               05  WRK-APERTURA        PIC  X(050).
           03  RED-OBS-INDCUS         REDEFINES   WRK-OBSERVACION.
               05  WRK-CODCUS          PIC  X(002).
               05  WRK-FILCUS          PIC  X(003).
               05  WRK-DESCUS          PIC  X(045).
      *
       01  CONTROLES.
           03  CTL-CCAMAEAHO            PIC  X(002)        VALUE "NO".
               88  FIN-CCAMAEAHO                           VALUE "SI".
               88  NO-FIN-CCAMAEAHO                        VALUE "NO".
           03  CTL-SIIC45              PIC  X(002)        VALUE "NO".
               88  EXISTE-SIIC45                          VALUE "SI".
               88  NO-EXISTE-SIIC45                       VALUE "NO".
           03  CTL-REGISTRO            PIC  X(002)        VALUE "SI".
               88  BUEN-REGISTRO                          VALUE "SI".
               88  MAL-REGISTRO                           VALUE "NO".
       01  PA-CODEMP                   PIC  9(05)         VALUE 0.
      *
      * PARAMETROS RUTINAS
           COPY PARGEN  OF CCACPY.
           COPY FECHAS  OF CCACPY.
      ***************************************************************
      *
       LINKAGE SECTION.
       77  W-USRING                    PIC  X(010).
       77  EQUIPO                      PIC  X(010).
      *
      ***************************************************************
      *
       PROCEDURE DIVISION  USING W-USRING  EQUIPO.
       0000-MAIN.
           PERFORM  0010-INICIAR
           PERFORM  0100-PROCESAR      UNTIL FIN-CCAMAEAHO
           PERFORM  9999-TERMINAR.
      *----------------------------------------------------------------
       0010-INICIAR.
           CALL "PLTCODEMPP"        USING PA-CODEMP
           CALL "CCA500"  USING  LK-FECHAS
           CALL "CCA501"  USING  LK-CCAPARGEN.
           MOVE W-USRING                  TO FLG-USERID
           MOVE EQUIPO                    TO WRK-NOM-SUC
           OPEN INPUT   CCAMAEAHO   PLTAGCORI
                                    CCATABLAS
      *                 SIIC45      CCATABLAS
           OPEN OUTPUT  CCA680IA
           MOVE LK-NOMEMP                 TO WRK-EMPRESA
           MOVE LK-FECHA-HOY              TO WRK-FECHA-PARA
           MOVE ZEROS                     TO WRK-FECHA-SYS
           CALL "SEC993" USING WRK-FECHA-SYS
           ACCEPT  WRK-HORA             FROM TIME
           MOVE ZEROS                     TO WRK-TOTACP    WRK-TOTRCH
                                             WRK-TOTANU
           PERFORM  0020-ENCABEZADO
           MOVE "NO"                      TO CTL-CCAMAEAHO
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0030-LEER-CCAMAEAHO UNTIL FIN-CCAMAEAHO
                                       OR    BUEN-REGISTRO.
      *-----------------------------------------------------------------
       0020-ENCABEZADO.
           IF WRK-LINEA > 55
              MOVE 1                      TO FLG-ENCABE
              ADD  1                      TO WRK-PAGINA
              MOVE "CCA680IA"             TO NOMLISTADO
              MOVE FLG-USERID             TO USER
              MOVE WRK-EMPRESA            TO EMPRESA
              MOVE WRK-PAGINA             TO PAGNRO
              MOVE "REPORTE DE    F I C H A S   D E   C U E N T A "
                                          TO DESCLIST
              MOVE WRK-FECHA-PARA         TO FECPARA
              MOVE WRK-NOM-SUC            TO NOMBRESUC
              MOVE HHMMSS                 TO HORA
              MOVE WRK-FECHA-SYS          TO FECIMPR
              WRITE PRTREC  FORMAT IS "PHEAD"
              MOVE 4                      TO WRK-LINEA.
      *----------------------------------------------------------------
       0030-LEER-CCAMAEAHO.
           MOVE "SI"                      TO CTL-REGISTRO
           READ  CCAMAEAHO    NEXT RECORD AT END
              MOVE "SI"                   TO CTL-CCAMAEAHO.
           IF NO-FIN-CCAMAEAHO
              MOVE AGCCTA  OF REG-MAEAHO  TO AGENCIA
              IF INDFIC NOT = 1
                 MOVE "NO"                TO CTL-REGISTRO.
      *----------------------------------------------------------------
       0100-PROCESAR.
           PERFORM  0020-ENCABEZADO
           MOVE 0                         TO FLG-ENCABE
           MOVE AGENCIA                   TO CODOFI
           PERFORM  0110-DESCRI-AGENCIA
           MOVE NOMAGC   OF  REG-PLTAGCORI   TO DESOFI
           MOVE CTANRO   OF  REG-MAEAHO   TO NUMCTA
           MOVE TIPCTA   OF  REG-MAEAHO   TO CODCTA
           MOVE "ERROR TIPO CUENTA   "    TO TIPOCTA
           IF TIPCTA OF REG-MAEAHO = 1
              MOVE "UNIPERSONAL"          TO TIPOCTA
           ELSE
              IF TIPCTA OF REG-MAEAHO = 2
                 MOVE "CONJUNTA   "       TO TIPOCTA.
           MOVE NITCTA   OF  REG-MAEAHO   TO NROID1
           MOVE DESCRI   OF  REG-MAEAHO   TO DESCTA1
      *    MOVE CODNDI   OF  REG-MAEAHO   TO CODDIR
           PERFORM  0120-TRAER-DOMICILIO
      *    MOVE C45DI1   OF  REG-SIIC45   TO DIRCTA
           IF NITCT2  OF REG-MAEAHO > 0
              MOVE NITCT2 OF  REG-MAEAHO  TO NROID2    WRK-NUMIDENT
              PERFORM 0130-TRAER-NOMBRE
              MOVE LRETNOM                TO DESCTA2.
           IF NITCT3  OF REG-MAEAHO > 0
              MOVE NITCT3 OF  REG-MAEAHO  TO NROID3    WRK-NUMIDENT
              PERFORM 0130-TRAER-NOMBRE
              MOVE LRETNOM                TO DESCTA3.
           MOVE FAPERT   OF  REG-MAEAHO   TO FECAPER
           MOVE FULMOV   OF  REG-MAEAHO   TO FECULMV
           MOVE "NO"                      TO FLGCBC
           IF INDCBC = 1
              MOVE "SI"                   TO FLGCBC.
           MOVE PUNADI   OF REG-MAEAHO    TO FLGPAD
           MOVE SEGMEN   OF REG-MAEAHO    TO FLGSGM
           PERFORM  0140-TRAER-SEGMENTO
           MOVE W-DESSEG                  TO DESSGM
           MOVE "NO"                      TO FLGEMB
           IF INDEMB > 0
              MOVE "SI"                   TO FLGEMB.
           MOVE "NO"                      TO FLGINA
           IF INDINA > 0
              MOVE "SI"                   TO FLGINA.
           MOVE "NO"                      TO FLGFAL
           IF INDFAL > 0
              MOVE "SI"                   TO FLGFAL.
           MOVE "NO"                      TO FLGINV
           IF INDINV > 0
              MOVE "SI"                   TO FLGINV.
           MOVE "NO"                      TO FLGBLO
           IF INDBLO > 0
              MOVE "SI"                   TO FLGBLO
              IF INDBLO = 1
                MOVE "BLOQUEO AL DEBITO"  TO DESBLO
              ELSE
              IF INDBLO = 2
                MOVE "BLOQUEO AL CREDITO" TO DESBLO
              ELSE
              IF INDBLO = 3
                MOVE "BLOQUEO TOTAL"      TO DESBLO.
           WRITE PRTREC  FORMAT IS "PDETAIL"
           PERFORM  0200-ESCRIBIR-FOOTER
           MOVE 60                        TO WRK-LINEA
           MOVE "NO"                      TO CTL-REGISTRO
           PERFORM  0030-LEER-CCAMAEAHO UNTIL FIN-CCAMAEAHO
                                       OR    BUEN-REGISTRO.
      *----------------------------------------------------------------
       0110-DESCRI-AGENCIA.
           MOVE AGENCIA                   TO AGCORI   OF REG-PLTAGCORI
           MOVE PA-CODEMP                 TO CODEMP OF REG-PLTAGCORI
           READ PLTAGCORI      INVALID KEY
                MOVE " AGENCIA NO EXISTE "
                                          TO NOMAGC   OF REG-PLTAGCORI.
      *----------------------------------------------------------------
       0120-TRAER-DOMICILIO.
      *    MOVE NITCTA     OF REG-MAEAHO  TO C45NID    OF REG-SIIC45
      *    MOVE CODNDI     OF REG-MAEAHO  TO C45NDI    OF REG-SIIC45
      *    MOVE "SI"                      TO CTL-SIIC45
      *    READ SIIC45     INVALID KEY
      *       MOVE "NO"                   TO CTL-SIIC45.
      *    IF NO-EXISTE-SIIC45
      *       MOVE "DIRECCION NO EXISTE"
      *                                   TO C45DI1   OF  REG-SIIC45.
      *----------------------------------------------------------------
       0130-TRAER-NOMBRE.
           MOVE WRK-NUMIDENT              TO LNROIDE
           MOVE ZEROS                     TO LDIGCHQ
           MOVE ZEROS                     TO LSIIC40
           MOVE ZEROS                     TO LSIIF45
           MOVE SPACES                    TO LRETNOM
           MOVE ZEROS                     TO LCODRET.
      *--------------- CLIENTES INDESEABLES ---------------------------
      *     CALL "COR052"  USING  ARG-COR052.
      *----------------------------------------------------------------
       0140-TRAER-SEGMENTO.
           MOVE 4                         TO CODTAB    OF REG-TABLAS
           MOVE SEGMEN     OF REG-MAEAHO  TO NROTAB    OF REG-TABLAS
           READ CCATABLAS   INVALID KEY
              MOVE "SEGMENTO ERRONEO"
                                          TO CAMPO2   OF  REG-TABLAS.
           MOVE CAMPO2     OF REG-TABLAS  TO RESTO.
      *----------------------------------------------------------------
       0200-ESCRIBIR-FOOTER.
           MOVE SPACES                    TO
                OBSERV01   OBSERV02    OBSERV03    OBSERV04
                OBSERV05   OBSERV06    OBSERV07    OBSERV08
                OBSERV09   OBSERV10
           MOVE 0                         TO CONT-OBSERV
           MOVE SPACES                    TO WRK-OBSERVACION
           IF FAPERT OF REG-MAEAHO = LK-FECHA-HOY
              ADD   1                     TO CONT-OBSERV
              MOVE  "CUENTA ABIERTA HOY"  TO WRK-APERTURA
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           IF FCIERR OF REG-MAEAHO = LK-FECHA-HOY
              ADD   1                     TO CONT-OBSERV
              MOVE  "CUENTA CERRADA HOY"  TO WRK-APERTURA
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           IF MOTBAJ OF REG-MAEAHO > 0
              ADD   1                     TO CONT-OBSERV
              MOVE  MOTBAJ  OF REG-MAEAHO TO WRK-CODCUS
      *OJO CON LA DESCRIPCION DEL MOTIVO DE BAJA.
              MOVE  MOTBAJ  OF REG-MAEAHO TO WRK-DESCUS
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           IF INDEMB OF REG-MAEAHO NOT = CODEMB  OF REG-MAEAHO
              ADD   1                     TO CONT-OBSERV
              MOVE  INDEMB  OF REG-MAEAHO TO WRK-CODCUS
              IF INDEMB  OF REG-MAEAHO = 0
                 MOVE "CUENTA DESEMBARGADA"  TO WRK-DESCUS
              ELSE
                 MOVE "CUENTA EMBARGADA"     TO WRK-DESCUS
              END-IF
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           IF INDBLO OF REG-MAEAHO NOT = CODBLO  OF REG-MAEAHO
              ADD   1                     TO CONT-OBSERV
              MOVE  INDBLO  OF REG-MAEAHO TO WRK-CODCUS
              IF INDBLO  OF REG-MAEAHO = 0
                 MOVE "CUENTA DESBLOQUEADA"   TO WRK-DESCUS
              ELSE
                 IF INDBLO  OF REG-MAEAHO = 1
                    MOVE "BLOQUEADA AL DEBITO"   TO WRK-DESCUS
                 ELSE
                    IF INDBLO  OF REG-MAEAHO = 2
                       MOVE "BLOQUEADA AL CREDITO"  TO WRK-DESCUS
                    ELSE
                       IF INDBLO  OF REG-MAEAHO = 3
                          MOVE "BLOQUEADA TOTALMENTE"  TO WRK-DESCUS
                       END-IF
                    END-IF
                 END-IF
              END-IF
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           IF INDINA OF REG-MAEAHO NOT = CODINA  OF REG-MAEAHO
              ADD   1                     TO CONT-OBSERV
              MOVE  INDINA  OF REG-MAEAHO TO WRK-CODCUS
              IF INDINA  OF REG-MAEAHO = 0
                 MOVE "CUENTA ACTIVADA"   TO WRK-DESCUS
              ELSE
                 MOVE "CUENTA INACTIVADA" TO WRK-DESCUS
              END-IF
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           IF INDFAL OF REG-MAEAHO NOT = CODFAL  OF REG-MAEAHO
              ADD   1                     TO CONT-OBSERV
              MOVE  INDFAL  OF REG-MAEAHO TO WRK-CODCUS
              IF INDFAL  OF REG-MAEAHO = 0
                 MOVE "CUENTA DESFALLECIDA" TO WRK-DESCUS
              ELSE
                 MOVE "CUENTA FALLECIDA"    TO WRK-DESCUS
              END-IF
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           IF INDINV OF REG-MAEAHO NOT = CODINV  OF REG-MAEAHO
              ADD   1                     TO CONT-OBSERV
              MOVE  INDINV  OF REG-MAEAHO TO WRK-CODCUS
              IF INDINV  OF REG-MAEAHO = 0
                 MOVE "CUENTA SIN INVESTIGAR" TO WRK-DESCUS
              ELSE
                 MOVE "CUENTA INVESTIGADA"    TO WRK-DESCUS
              END-IF
              PERFORM  0210-ESCRIBIR-OBSERVACION.
           WRITE PRTREC  FORMAT IS "PFOOT".
           MOVE 60                        TO WRK-LINEA.
      *----------------------------------------------------------------
       0210-ESCRIBIR-OBSERVACION.
           EVALUATE  CONT-OBSERV
              WHEN 0
                   MOVE CONT-OBSERV       TO CONT-OBSERV
              WHEN 1
                   MOVE WRK-OBSERVACION   TO OBSERV01
              WHEN 2
                   MOVE WRK-OBSERVACION   TO OBSERV02
              WHEN 3
                   MOVE WRK-OBSERVACION   TO OBSERV03
              WHEN 4
                   MOVE WRK-OBSERVACION   TO OBSERV04
              WHEN 5
                   MOVE WRK-OBSERVACION   TO OBSERV05
              WHEN 6
                   MOVE WRK-OBSERVACION   TO OBSERV06
              WHEN 7
                   MOVE WRK-OBSERVACION   TO OBSERV07
              WHEN 8
                   MOVE WRK-OBSERVACION   TO OBSERV08
              WHEN 9
                   MOVE WRK-OBSERVACION   TO OBSERV09
              WHEN 10
                   MOVE WRK-OBSERVACION   TO OBSERV10
              WHEN OTHER
                   MOVE CONT-OBSERV       TO CONT-OBSERV
           END-EVALUATE
           MOVE SPACES                    TO WRK-OBSERVACION.
      *----------------------------------------------------------------
       9999-TERMINAR.
           CLOSE CCAMAEAHO   PLTAGCORI
                 CCATABLAS   CCA680IA
           STOP RUN.
      *----------------------------------------------------------------
