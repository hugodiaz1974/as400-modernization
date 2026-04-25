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
       PROGRAM-ID.      CCA540.
       AUTHOR. VICENTE GUZMAN Q.
       DATE-WRITTEN.  99/10/06.
      *
      *----------------------------------------------------------------
      *                                                               |
      * Programa  : CCA540.                                           |
      * Aplicacion: Linea.                                            |
      * Funcion   : Este programa genera el listado Bitacora de las   |
      *             Operaciones No Monetarias.                        |
      * Archivos Entrada/Salida:                                      |
      * Elaborado : Vicente Guzmán Quintero                           |
      * Fecha     : 99/10/06.                                         |
      *                                                               |
      *----------------------------------------------------------------
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.
           IBM-AS400.
       OBJECT-COMPUTER.
           IBM-AS400.
      *
       SPECIAL-NAMES.
           REQUESTOR IS CCW-REQUESTOR
           CONSOLE IS CCW-CONSOLE.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
      *----------------------------------------------------------------
      * Declaracion de Archivos                                       |
      *----------------------------------------------------------------
      *
           SELECT CCATRNNOMO
                  ASSIGN               TO DATABASE-CCATRNNOMO
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY
                                          WITH DUPLICATES.
      *
           SELECT PLTFECHAS
                  ASSIGN               TO DATABASE-PLTFECHAS
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTPARGEN
                  ASSIGN               TO DATABASE-PLTPARGEN
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.

      *
           SELECT CCACODNOV
                  ASSIGN               TO DATABASE-CCACODNOV
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCA540R1
                  ASSIGN          TO PRINTER-CCA540R1
                  ORGANIZATION    IS SEQUENTIAL
                  ACCESS MODE     IS SEQUENTIAL
                  FILE STATUS     IS FILSTAT.

      *
       DATA DIVISION.
       FILE SECTION.
      *
      *----------------------------------------------------------------
      *  Declaracion de Definiciones de Archivo                       |
      *----------------------------------------------------------------
      *
       FD  CCATRNNOMO
           LABEL RECORDS               ARE STANDARD.
       01  CCATRNNOMO-REC.
           COPY DD-ALL-FORMATS         OF CCATRNNOMO.
      *
       FD  PLTFECHAS
           LABEL RECORDS               ARE STANDARD.
       01  PLTFECHAS-REC.
           COPY DD-ALL-FORMATS         OF PLTFECHAS.
      *
       FD  PLTPARGEN
           LABEL RECORDS               ARE STANDARD.
       01  PLTPARGEN-REC.
           COPY DD-ALL-FORMATS         OF PLTPARGEN.
      *
       FD  CCACODNOV
           LABEL RECORDS               ARE STANDARD.
       01  CCACODNOV-REC.
           COPY DD-ALL-FORMATS         OF CCACODNOV.
      *
       FD  CCA540R1
           LABEL RECORDS ARE OMITTED.
       01  PRTREC1        PIC X(132).
      *
      *----------------------------------------------------------------
      * Declaracion de Variables de Trabajo                           |
      *----------------------------------------------------------------
      *
       WORKING-STORAGE SECTION.
      *File Status del Archivo de Pantalla.
       01  W-PANTALLA-STATUS           PIC X(02).
      *Area de Indicadores del registro RSFL.
       01  W-AREA-INDICADORES-RSFL.
           03  W-INDICADOR-RSFL        PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores del registro RSFLCTL.
       01  W-AREA-INDICADORES-RSFLCTL.
           03  W-INDICADOR-RSFLCTL     PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores del registro PANTALLA01.
       01  W-AREA-INDICADORES-PANTALLA01.
           03  W-INDICADOR-PANTALLA01  PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores de respuesta.
       01  W-AREA-INDICADORES-RTA.
           03  W-INDICADOR-RTA         PIC 1 OCCURS 99 INDICATOR 1.
      *Llave relativa para el SubArchivo PLT357S.
       01  W-SBF-CLAVE                 PIC 9(05)     COMP-3 VALUE 0.
       01  W-SBF-CLAVE-TMP             PIC 9(05)     COMP-3 VALUE 0.
      *
      *----------------------------------------------------------------
      *                   Variables de Control                        |
      *----------------------------------------------------------------
      *
      *Variable para control del archivo de transacciones.
       01  W-EXISTE-CCATRNNOMO         PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-CCATRNNOMO                  VALUE 0.
           88  SI-EXISTE-CCATRNNOMO                   VALUE 1.
      *Variable para control acceso directo del Archivo PLTFECHAS.
       01  W-EXISTE-PLTFECHAS          PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-PLTFECHAS                    VALUE 0.
           88  SI-EXISTE-PLTFECHAS                    VALUE 1.
      *Variable para control acceso directo del Archivo CCACODNOV.
       01  W-EXISTE-CCACODNOV          PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-CCACODNOV                    VALUE 0.
           88  SI-EXISTE-CCACODNOV                    VALUE 1.
      *Variable para control acceso directo del Archivo PLTTRNMON.
      *Indica si se presento un error de validacion en algun formato
      *de pantalla.
       01  W-ERROR-VALIDACION          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-ERROR-VALIDACION                    VALUE 0.
           88  SI-ERROR-VALIDACION                    VALUE 1.
      *
      *----------------------------------------------------------------
      * Declaracion de Variables Contadores                           |
      *----------------------------------------------------------------
      *
      *Indices para manejo de tablas.
       01  I                           PIC 9(05)      COMP-3 VALUE 0.
       01  J                           PIC 9(05)      COMP-3 VALUE 0.
      *
       01  FILSTAT.
           05  ERR-FLAG    PIC X(01).
           05  PFK-BYTE    PIC X(01).

       01  L-TIPMOV                    PIC 9(01)      VALUE ZERO.
       01  L-CODMON                    PIC 9(03)      VALUE ZEROS.
       01  L-NROBNV                    PIC 9(16)      VALUE ZEROS.
       01  L-TASA                      PIC 9(08)V9(2) VALUE ZEROS.
       01  L-VLRMEX                    PIC 9(13)V9(2) VALUE ZEROS.
       01  L-VLRMEX-C                  PIC 9(13)V9(2) VALUE ZEROS.
       01  L-VLRMEX-T                  PIC 9(13)V9(2) VALUE ZEROS.
       01  L-VLRMEX-M                  PIC 9(13)V9(2) VALUE ZEROS.
       01  L-VLRMLC                    PIC 9(13)V9(2) VALUE ZEROS.
       01  L-VLRMLC-C                  PIC 9(13)V9(2) VALUE ZEROS.
       01  L-VLRMLC-T                  PIC 9(13)V9(2) VALUE ZEROS.
       01  L-VLRMLC-M                  PIC 9(13)V9(2) VALUE ZEROS.
       01  X-TIPMOV                    PIC 9(01)      VALUE ZERO.
       01  X-CODMON                    PIC 9(03)      VALUE ZEROS.
       01  X-NROBNV                    PIC 9(16)      VALUE ZEROS.
       01  D-NROBNV                    PIC 9(16)      VALUE ZEROS.
       01  FILLER                      REDEFINES D-NROBNV.
           03  FILLER                  PIC 9(12).
           03  D-CODCON                PIC 9(04).
       01  X-DESCRI                    PIC X(100)     VALUE SPACES.
       01  FILLER                      REDEFINES X-DESCRI.
           03  X-CAMP1                 PIC X(01).
           03  X-CAMP2                 PIC X(01).
           03  FILLER                  PIC X(02).
           03  X-TIT                   PIC X(02).
           03  FILLER                  PIC X(94).

       01  X-TASA                      PIC 9(08)V9(2) VALUE ZEROS.
       01  X-VLRMEX                    PIC 9(13)V9(2) VALUE ZEROS.
       01  X-VLRMEX-C                  PIC 9(13)V9(2) VALUE ZEROS.
       01  X-VLRMEX-T                  PIC 9(13)V9(2) VALUE ZEROS.
       01  X-VLRMEX-M                  PIC 9(13)V9(2) VALUE ZEROS.
       01  X-VLRMLC                    PIC 9(13)V9(2) VALUE ZEROS.
       01  X-VLRMLC-C                  PIC 9(13)V9(2) VALUE ZEROS.
       01  X-VLRMLC-T                  PIC 9(13)V9(2) VALUE ZEROS.
       01  X-VLRMLC-M                  PIC 9(13)V9(2) VALUE ZEROS.
      *
       01  LINENC001.
           03  FILLER             PIC X(001)          VALUE SPACES.
           03  FILLER           PIC IS X(024)       VALUE
               "Plataforma Bancaria ".
           03  FILLER           PIC IS X(028)       VALUE SPACES.
           03  FILLER           PIC IS X(047)       VALUE SPACES.
           03  FILLER           PIC IS X(030)       VALUE
               "Taylor & Johnson Ltda".

       01  LIN-ENC-NOMBAN-I.
           03  FILLER             PIC X(001)          VALUE SPACES.
           03  NOMBAN-I           PIC X(030)          VALUE SPACES.
           03  FILLER             PIC X(069)          VALUE SPACES.
           03  FILLER             PIC X(026)          VALUE
           "Nit    : 860050983-7     ".
      *
       01  LIN-ENC-NOMAGE-I.
           03  FILLER            PIC X(001)     VALUE SPACES.
           03  FILLER            PIC X(030)     VALUE
           "Programa: CCA540".
           03  FILLER            PIC X(069)     VALUE SPACES.
           03  FILLER            PIC X(008)     VALUE "Fecha  :".
           03  FILLER            PIC X(001)     VALUE SPACES.
           03  FECHA-I           PIC 9999/99/99 VALUE ZEROS.
      *
       01  LIN-TITUL1.
           03  FILLER             PIC X(040)          VALUE SPACES.
           03  FILLER             PIC X(060)          VALUE
           "Bitacora de Operaciones No Monetarias".
      *
       01  LIN-TITUL2.
           03  FILLER             PIC X(040)          VALUE SPACES.
           03  FILLER             PIC X(060)          VALUE
           "======== == =========== == ==========".

       01  LIN-TIT-DET.
           03  FILLER             PIC X(001)          VALUE SPACES.
           03  FILLER             PIC X(007)          VALUE
           "Agencia".
           03  FILLER             PIC X(001)          VALUE SPACES.
           03  FILLER             PIC X(006)          VALUE
           "Moneda".
           03  FILLER             PIC X(001)          VALUE SPACES.
           03  FILLER             PIC X(006)          VALUE
           "Cajero".
           03  FILLER             PIC X(001)          VALUE SPACES.
           03  FILLER             PIC X(009)          VALUE
           "Secuencia".
           03  FILLER             PIC X(003)          VALUE SPACES.
           03  FILLER             PIC X(005)          VALUE
           "Fecha".
           03  FILLER             PIC X(008)          VALUE SPACES.
           03  FILLER             PIC X(004)          VALUE
           "Hora".
           03  FILLER             PIC X(004)          VALUE SPACES.
           03  FILLER             PIC X(007)          VALUE
           "Sistema".
           03  FILLER             PIC X(002)          VALUE SPACES.
           03  FILLER             PIC X(008)          VALUE
           "Producto".
           03  FILLER             PIC X(002)          VALUE SPACES.
           03  FILLER             PIC X(003)          VALUE
           "Age".
           03  FILLER             PIC X(005)          VALUE SPACES.
           03  FILLER             PIC X(006)          VALUE
           "Cuenta".
           03  FILLER             PIC X(002)          VALUE SPACES.
           03  FILLER             PIC X(001)          VALUE
           "E".
           03  FILLER             PIC X(003)          VALUE SPACES.
           03  FILLER             PIC X(007)          VALUE
           "Novedad".
           03  FILLER             PIC X(003)          VALUE SPACES.
           03  FILLER             PIC X(019)          VALUE
           "Descripcion Novedad".

       01  LIN-DETALLE.
           03  AGCORI             PIC Z9999               VALUE ZEROS.
           03  FILLER             PIC X(004)              VALUE SPACES.
           03  CODMON             PIC ZZ9                 VALUE ZEROS.
           03  FILLER             PIC X(001)              VALUE SPACES.
           03  CODCAJ             PIC X(10)               VALUE SPACES.
           03  NROTRN             PIC ZZZZZZZZ9           VALUE ZEROS.
           03  FILLER             PIC X(001)              VALUE SPACES.
           03  FECPRO             PIC 9999/99/99          VALUE ZEROS.
           03  FILLER             PIC X(002)              VALUE SPACES.
           03  HORPRO             PIC 99/99/99/99         VALUE ZEROS.
           03  FILLER             PIC X(003)              VALUE SPACES.
           03  CODSIS             PIC ZZZ                 VALUE ZEROS.
           03  FILLER             PIC X(007)              VALUE SPACES.
           03  CODPRO             PIC ZZZ99               VALUE ZEROS.
           03  NUMAGE             PIC Z9999               VALUE ZEROS.
           03  FILLER             PIC X(001)              VALUE SPACES.
           03  NUMCTA             PIC ZZZZ999999          VALUE ZEROS.
           03  FILLER             PIC X(002)              VALUE SPACES.
           03  ESTTRN             PIC 9                   VALUE ZEROS.
           03  FILLER             PIC X(004)              VALUE SPACES.
           03  CODNOV             PIC ZZZZ9               VALUE ZEROS.
           03  FILLER             PIC X(004)              VALUE SPACES.
           03  DESNOV             PIC X(25)               VALUE SPACES.

       01  LIN-DETALLE1.
           03  FILLER             PIC X(004)          VALUE SPACES.
           03  FILLER             PIC X(021)          VALUE
           "Informacion Anterior:".
           03  FILLER              PIC X(001)         VALUE SPACES.
           03  DATVIE              PIC X(100)         VALUE SPACES.

       01  LIN-DETALLE2.
           03  FILLER             PIC X(004)          VALUE SPACES.
           03  FILLER             PIC X(021)          VALUE
           "Informacion Nueva   :".
           03  FILLER              PIC X(001)         VALUE SPACES.
           03  DATNUE              PIC X(100)         VALUE SPACES.

       01  LIN-FIN.
           03  FILLER             PIC X(050)          VALUE SPACES.
           03  FILLER             PIC X(035)          VALUE
           " <<<<<  FIN DEL REPORTE   >>>>>".
      *
      *Contiene la fecha de ho,manana y pasado manana para el Plttrnmon.
       01  W-FECHA-PROCESO             PIC 9(08)        VALUE 0.
       01  W-FECHA-VALOR               PIC 9(08)        VALUE 0.
       01  W-FECHA-MANANA              PIC 9(08)        VALUE 0.
       01  W-FECHA-MANSIG              PIC 9(08)        VALUE 0.
       01  CONT-LINEA                  PIC 9(02)  VALUE ZEROS.
       01  LK-CODEMP                   PIC 9(05)  VALUE ZEROS.
      *----------------------------------------------------------------
      *            Definicion de Areas de Encadenamiento              |
      *----------------------------------------------------------------
      *
      *----------------------------------------------------------------
      *LINKAGE SECTION.
      *----------------------------------------------------------------
      *77  W-AGCORI             PIC 9(05).
      *
      *----------------------------------------------------------------
      *                     PROCEDURE DIVISION                        |
      *----------------------------------------------------------------
      *
       PROCEDURE DIVISION.

       INI-PROGRAMA.
           PERFORM INICIALIZAR
           PERFORM LEER-DATOS
           PERFORM FINALIZAR.
       FINALIZAR-PROGRAMA.
           GOBACK.
      *
      *----------------------------------------------------------------
      * Procedimiento : Inicializar.                                  |
      * Descripcion   : En este procedimiento se inicializan las      |
      *                 variables de control y se abren los archivos  |
      *                 utilizados.                                   |
      *----------------------------------------------------------------
      *
       INICIALIZAR.
           OPEN INPUT   PLTPARGEN
           OPEN INPUT   CCACODNOV
           OPEN OUTPUT  CCA540R1
           CALL "PLTCODEMPP"           USING LK-CODEMP
           PERFORM LEER-PLTPARGEN
           OPEN INPUT PLTFECHAS
           MOVE 5                      TO CODSIS OF REGFECHAS
           PERFORM LEER-PLTFECHAS
           IF ( NO-EXISTE-PLTFECHAS )
             DISPLAY "No Existe Fecha de Proceso. Llamar a Sistemas"
             CLOSE PLTFECHAS
             STOP RUN
           END-IF.
           OPEN INPUT CCATRNNOMO
           MOVE FECPRO OF REGFECHAS    TO W-FECHA-PROCESO
           MOVE FECPRO OF REGFECHAS    TO FECHA-I
           MOVE FECPRS OF REGFECHAS    TO W-FECHA-MANANA
           MOVE FECPSS OF REGFECHAS    TO W-FECHA-MANSIG.
       LEER-DATOS.
           MOVE 1                   TO W-EXISTE-CCATRNNOMO
           MOVE ZEROS               TO AGCORI OF CCATRNNOMO
           MOVE SPACES              TO CODCAJ OF CCATRNNOMO
           MOVE ZEROS               TO CODMON OF CCATRNNOMO
           MOVE ZEROS               TO NROTRN OF CCATRNNOMO
           MOVE ZEROS               TO CNSTRN OF CCATRNNOMO

           PERFORM IMPRIMIR-CABECERA
           START CCATRNNOMO KEY NOT <  EXTERNALLY-DESCRIBED-KEY
                             INVALID KEY
                                       MOVE 0 TO W-EXISTE-CCATRNNOMO
           END-START

           IF W-EXISTE-CCATRNNOMO = 1
             READ CCATRNNOMO
                              NEXT  AT END
                                       MOVE 0 TO W-EXISTE-CCATRNNOMO
             END-READ
           END-IF

           IF W-EXISTE-CCATRNNOMO = 1
      *         IF AGCORI OF CCATRNNOMO = W-AGCORI
                IF CODSIS OF CCATRNNOMO = 11
                    MOVE CORR REGTRNNOMO TO LIN-DETALLE
                    MOVE CORR REGTRNNOMO TO LIN-DETALLE1
                    MOVE CORR REGTRNNOMO TO LIN-DETALLE2
                    PERFORM IMPRIMIR-DETALLE
                END-IF
                PERFORM LEER-CCATRNNOMO
      *                       UNTIL AGCORI OF CCATRNNOMO NOT = W-AGCORI
                         UNTIL W-EXISTE-CCATRNNOMO      =  0
           END-IF.

      *
       LEER-PLTFECHAS.
           MOVE 1                      TO W-EXISTE-PLTFECHAS
           MOVE LK-CODEMP              TO CODEMP OF PLTFECHAS
           READ PLTFECHAS              INVALID KEY
                                       MOVE 0 TO W-EXISTE-PLTFECHAS
           END-READ.
      *
       LEER-CCACODNOV.
           MOVE CODMON OF CCATRNNOMO TO CODMON OF CCACODNOV
           MOVE CODSIS OF CCATRNNOMO TO CODSIS OF CCACODNOV
           MOVE CODPRO OF CCATRNNOMO TO CODPRO OF CCACODNOV
           MOVE CODNOV OF CCATRNNOMO TO CODNOV OF CCACODNOV
           MOVE 1                      TO W-EXISTE-CCACODNOV
           READ CCACODNOV              INVALID KEY
                                       MOVE 0 TO W-EXISTE-CCACODNOV
           END-READ
           IF W-EXISTE-CCACODNOV  = 1
                 MOVE TITCAM OF CCACODNOV  TO DESNOV
              ELSE
                 MOVE SPACES               TO DESNOV
           END-IF.

       IMPRIMIR-CABECERA.
           MOVE SPACES                    TO  PRTREC1
           WRITE PRTREC1 FROM LINENC001 AFTER PAGE
           WRITE PRTREC1 FROM LIN-ENC-NOMBAN-I AFTER 1 LINES
           WRITE PRTREC1 FROM LIN-ENC-NOMAGE-I AFTER 1 LINES
           WRITE PRTREC1 FROM LIN-TITUL1 AFTER 1 LINES
           WRITE PRTREC1 FROM LIN-TITUL2 AFTER 1 LINES
           MOVE ALL "-"              TO PRTREC1
           WRITE PRTREC1 AFTER 1 LINES
           WRITE PRTREC1 FROM LIN-TIT-DET AFTER 1 LINES
           MOVE ALL "-"              TO PRTREC1
           WRITE PRTREC1 AFTER 1 LINES
           MOVE ALL " "              TO PRTREC1
           WRITE PRTREC1 AFTER 1 LINES
           ADD 9      TO CONT-LINEA.


      *----------------------------------------------------------------
      * Procedimiento : Leer-Pltpargen.                               |
      * Descripcion   : Se lee el archivo de parámetros generales.    |
      *----------------------------------------------------------------
      *
       LEER-PLTPARGEN.
OER   *    MOVE 1                      TO CODPAR OF REGPARGEN
           MOVE LK-CODEMP              TO CODEMP OF PLTPARGEN
           READ PLTPARGEN              INVALID KEY
                DISPLAY "Error al leer Parámetros Generales"
                STOP RUN
           END-READ
           MOVE NOMBAN OF REGPARGEN    TO NOMBAN-I.

       LEER-CCATRNNOMO.

           READ CCATRNNOMO  NEXT AT END
                                MOVE 0 TO W-EXISTE-CCATRNNOMO
           END-READ.

           IF W-EXISTE-CCATRNNOMO = 1
             IF CODSIS OF CCATRNNOMO = 11
                  MOVE CORR REGTRNNOMO TO LIN-DETALLE
                  MOVE CORR REGTRNNOMO TO LIN-DETALLE1
                  MOVE CORR REGTRNNOMO TO LIN-DETALLE2
                  PERFORM IMPRIMIR-DETALLE
             END-IF
           END-IF.

        IMPRIMIR-DETALLE.
           IF CONT-LINEA > 55
               PERFORM IMPRIMIR-CABECERA
               MOVE ZEROS TO CONT-LINEA
           END-IF
           PERFORM LEER-CCACODNOV
           WRITE PRTREC1 FROM LIN-DETALLE  AFTER 1 LINES
           MOVE ALL " "              TO PRTREC1
           WRITE PRTREC1 AFTER 1 LINES
           MOVE  DATVIE  OF CCATRNNOMO TO X-DESCRI
           IF X-CAMP2 = SPACES
              IF X-CAMP1 = "1"
                 MOVE "SI"   TO  X-TIT
                ELSE
                 MOVE "NO"   TO  X-TIT
              END-IF
              MOVE X-DESCRI  TO DATVIE OF LIN-DETALLE1
           END-IF
           WRITE PRTREC1 FROM LIN-DETALLE1 AFTER 1 LINES
           MOVE  DATNUE  OF CCATRNNOMO TO X-DESCRI
           IF X-CAMP2 = SPACES
              IF X-CAMP1 = "1"
                 MOVE "SI"   TO  X-TIT
                ELSE
                 MOVE "NO"   TO  X-TIT
              END-IF
              MOVE X-DESCRI  TO DATNUE OF LIN-DETALLE2
           END-IF
           WRITE PRTREC1 FROM LIN-DETALLE2 AFTER 1 LINES
           MOVE ALL " "              TO PRTREC1
           WRITE PRTREC1 AFTER 1 LINES
           ADD 5     TO CONT-LINEA.
      *----------------------------------------------------------------
       FINALIZAR.
           MOVE ALL " "              TO PRTREC1
           WRITE PRTREC1 AFTER 1 LINES
           WRITE PRTREC1 FROM LIN-FIN AFTER 1 LINES
           CLOSE CCATRNNOMO
                 CCA540R1
                 PLTFECHAS
                 CCACODNOV
                 PLTPARGEN.
