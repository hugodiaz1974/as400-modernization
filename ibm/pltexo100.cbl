     /*-----------------------------------------------------------------------*/
     /* Material Bajo Licencia de Taylor & Johnson                            */
     /* Copyright : TAYLOR & JOHNSON ® 1996, 1997, 1998, 1999, 2000, 2001,    */
     /*                                2002, 2003, 2004, 2005                 */
     /*             Todos los Derechos Reservados                             */
     /*-----------------------------------------------------------------------*/
     /* Derechos Restringidos para los usuarios, el uso, la duplicacion o     */
     /* publicacion quedan sujetos al contrato con  TAYLOR & JOHNSON ®        */
     /*-----------------------------------------------------------------------*/
       IDENTIFICATION DIVISION.
       PROGRAM-ID.   PLTEXO100.
       AUTHOR.       HUGO HERNANDO DIAZ.
       DATE-WRITTEN. 2014/06/13.
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
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
      *-----------------------------------------------------------------
      * Declaracion de Archivos                                        |
      *--------------------------------------------------------------- -
      *
           SELECT PANTALLA
                  ASSIGN               TO WORKSTATION-PLTEXO100S-SI
                  ORGANIZATION         IS TRANSACTION
                  ACCESS               IS DYNAMIC
                  RELATIVE             IS W-SBF-CLAVE
                  CONTROL-AREA         IS W-CONTROL-PANTALLA
                  FILE STATUS          IS W-PANTALLA-STATUS.
      *
           SELECT PLTEXOCOM
                  ASSIGN               TO DATABASE-PLTEXOCOM
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLIMAEL01
                  ASSIGN               TO DATABASE-CLIMAEL01
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTFECHAS
                  ASSIGN               TO DATABASE-PLTFECHAS
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLITAB
                  ASSIGN               TO DATABASE-CLITAB
                  ORGANIZATION            IS INDEXED
                  ACCESS MODE             IS DYNAMIC
                  RECORD KEY              IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTPARGEN
                  ASSIGN               TO DATABASE-PLTPARGEN
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT LOGEXOCOM
                  ASSIGN               TO DATABASE-LOGEXOCOM
                  ORGANIZATION         IS SEQUENTIAL
                  ACCESS MODE          IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
      *
      *--------------------------------------------------------------- -
      *  Declaración de Definiciones de Archivo                        |
      *--------------------------------------------------------------- -
      *
       FD  PANTALLA
           LABEL RECORDS               ARE OMITTED.
       01  PANTALLA-REC.
           COPY DD-ALL-FORMATS         OF  PLTEXO100S.
      *
       FD  PLTEXOCOM
           LABEL RECORDS               ARE STANDARD.
       01  PLTEXOCOM-REC.
           COPY DD-ALL-FORMATS         OF PLTEXOCOM.
      *
       FD  CLIMAEL01
           LABEL RECORDS               ARE STANDARD.
       01  CLIMAEL01-REC.
           COPY DD-ALL-FORMATS         OF CLIMAEL01.
      *
       FD  PLTFECHAS
           LABEL RECORDS               ARE STANDARD.
       01  PLTFECHAS-REC.
           COPY DD-ALL-FORMATS         OF PLTFECHAS.
      *
       FD  CLITAB
           LABEL RECORDS               ARE STANDARD.
       01  CLITAB-REC.
           COPY DD-ALL-FORMATS         OF CLITAB.
      *
       FD  PLTPARGEN
           LABEL RECORDS               ARE STANDARD.
       01  PLTPARGEN-REC.
           COPY DD-ALL-FORMATS         OF PLTPARGEN.
      *
       FD  LOGEXOCOM
           LABEL RECORDS               ARE STANDARD.
       01  LOGEXOCOM-REC.
           COPY DD-ALL-FORMATS         OF  LOGEXOCOM.
      *----------------------------------------------------------------
      * Declaracion de Variables de Trabajo                           |
      *----------------------------------------------------------------
      *
       WORKING-STORAGE SECTION.
      *
      *----------------------------------------------------------------
      *       Variables Para Manejo de los Formato de Pantalla        |
      *----------------------------------------------------------------
      *
      *Area de Control de la Estaci_n de Pantalla.
       01  W-CONTROL-PANTALLA.
           03  W-FUNCIONES-UTILIZADAS.
               05  W-FUNCION-UTILIZADA PIC 9(02).
                   88  F01                            VALUE 01.
                   88  F02                            VALUE 02.
                   88  F03                            VALUE 03.
                   88  F04                            VALUE 04.
                   88  F05                            VALUE 05.
                   88  F06                            VALUE 06.
                   88  F07                            VALUE 07.
                   88  F08                            VALUE 08.
                   88  F09                            VALUE 09.
                   88  F10                            VALUE 10.
                   88  F11                            VALUE 11.
                   88  F12                            VALUE 12.
                   88  F13                            VALUE 13.
                   88  F14                            VALUE 14.
                   88  F15                            VALUE 15.
                   88  F16                            VALUE 16.
                   88  F17                            VALUE 17.
                   88  F18                            VALUE 18.
                   88  F19                            VALUE 19.
                   88  F20                            VALUE 20.
                   88  F21                            VALUE 21.
                   88  F22                            VALUE 22.
                   88  F23                            VALUE 23.
                   88  F24                            VALUE 24.
                   88  ROLLUP                         VALUE 90.
                   88  ROLLDOWN                       VALUE 91.
                   88  ENTER-KEY                      VALUE 00.
           03  W-NOMBRE-DEVICE         PIC X(10).
           03  W-NOMBRE-FORMATO        PIC X(10).
       01  W-TEMPORAL                  PIC X(20)        VALUE SPACES.
       01  T-CODTAB                    PIC 9(04)     VALUE ZEROS.
       01  T-CODINT                    PIC 9(17)     VALUE ZEROS.
      *Variable para control acceso directo del Archivo PLTPARGEN.
       01  W-EXISTE-PLTPARGEN          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-PLTPARGEN                    VALUE 0.
           88  SI-EXISTE-PLTPARGEN                    VALUE 1.
      *Variables para llamar a la rutina SIPR002
       01  X-MENSAJE.
           03  X-MENSAJE1              PIC X(070)   VALUE SPACES.
           03  X-MENSAJE2              PIC X(070)   VALUE SPACES.
           03  X-MENSAJE3              PIC X(070)   VALUE SPACES.
       01  X-CODRES                    PIC 9(01)    VALUE ZEROS.
       01  X-TITULO                    PIC X(30)    VALUE SPACES.
       01  W-CONLET                    PIC 9(02)     VALUE ZEROS.
       01  W-CONCAR                    PIC 9(02)     VALUE ZEROS.
       01  W-TIPCLI                    PIC 9(01)     VALUE ZEROS.
       01  W-ESTADO                    PIC 9(01)     VALUE ZEROS.
       01  W-BINEXO-ANT                PIC 9(06)     VALUE ZEROS.
       01  W-TIPCAJ-ANT                PIC 9(10)     VALUE ZEROS.
       01  W-TIPCLI-ANT                PIC 9(03)     VALUE ZEROS.
       01  W-CODPRO-ANT                PIC 9(03)     VALUE ZEROS.
       01  W-CODCON-ANT                PIC X(10)     VALUE SPACES.
       01  W-CANEXO-ANT                PIC 9(03)     VALUE ZEROS.
       01  W-ACCION                    PIC X(20)     VALUE ZEROS.
      *File Status del Archivo de Pantalla.
       01  W-PANTALLA-STATUS           PIC X(02).
      *Area de Indicadores del registro RSFL.
       01  W-AREA-INDICADORES-RSFL.
           03  W-INDICADOR-RSFL        PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores del registro RSFLP01.
       01  W-AREA-INDICADORES-RSFLP01.
           03  W-INDICADOR-RSFLP01     PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores del registro RSFLCTL.
       01  W-AREA-INDICADORES-RSFLCTL.
           03  W-INDICADOR-RSFLCTL     PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores del registro PANTALLA01.
       01  W-AREA-INDICADORES-PANTALLA01.
           03  W-INDICADOR-PANTALLA01  PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores del registro PANTALLA02.
       01  W-AREA-INDICADORES-PANTALLA02.
           03  W-INDICADOR-PANTALLA02  PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores del registro PANTALLA01.
       01  W-AREA-INDICADORES-PANTALLA04.
           03  W-INDICADOR-PANTALLA04  PIC 1 OCCURS 99 INDICATOR 1.
      *Area de Indicadores de respuesta.
       01  W-AREA-INDICADORES-RTA.
           03  W-INDICADOR-RTA         PIC 1 OCCURS 99 INDICATOR 1.
      *Llave relativa para el SubArchivo PLT313.
       01  W-SBF-CLAVE                 PIC 9(05)     COMP-3 VALUE 0.
       01  W-SBF-CLAVE-TMP             PIC 9(05)     COMP-3 VALUE 0.
       01  W-SBF-CLAVE-AUX             PIC 9(05)     COMP-3 VALUE 0.
      *
      *----------------------------------------------------------------
      *             COPY'S   FORMATOS DE PANTALLA.
      *----------------------------------------------------------------
       01 REG-RSFLCTL-O.
          COPY DDS-RSFLCTL-O OF PLTEXO100S.
       01 REG-RSFLCTL-I.
          COPY DDS-RSFLCTL-I OF PLTEXO100S.
      *----------------------------------------------------------------
      *                   Variables de Control                        |
      *----------------------------------------------------------------
      *
       01 W-NUMRRN               PIC S9(05)  COMP-3 VALUE 0.
       01 W-RELRCD               PIC S9(05)  COMP-3 VALUE 0.
      *Control Interacci_n Formato de Pantalla "RSFLCTL".
       01  W-FIN-RSFLCTL               PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-RSFLCTL                         VALUE 0.
           88  SI-FIN-RSFLCTL                         VALUE 1.
      *Control Interacci¾n Formato de Pantalla "PANTALLA01"
       01  W-FIN-PANTALLA01            PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-PANTALLA01                      VALUE 0.
           88  SI-FIN-PANTALLA01                      VALUE 1.
      *Control Interacci¾n Formato de Pantalla "PANTALLA02"
       01  W-FIN-PANTALLA02            PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-PANTALLA02                      VALUE 0.
           88  SI-FIN-PANTALLA02                      VALUE 1.
      *Control Interacci¾n Formato de Pantalla "PANTALLA01"
       01  W-FIN-PANTALLA04            PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-PANTALLA04                      VALUE 0.
           88  SI-FIN-PANTALLA04                      VALUE 1.
      *Variable para control acceso secuencial del SubFile.
       01  W-FIN-RSFL                  PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-RSFL                            VALUE 0.
           88  SI-FIN-RSFL                            VALUE 1.
      *Variable para control acceso secuencial del Archivo PLTEXOCOM.
       01  W-FIN-PLTEXOCOM             PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-PLTEXOCOM                       VALUE 0.
           88  SI-FIN-PLTEXOCOM                       VALUE 1.
      *Variable para control acceso directo del Archivo PLTEXOCOM.
       01  W-EXISTE-CLITAB             PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-CLITAB                       VALUE 0.
           88  SI-EXISTE-CLITAB                       VALUE 1.
      *Variable para control acceso directo del Archivo PLTEXOCOM.
       01  W-EXISTE-PLTEXOCOM          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-PLTEXOCOM                    VALUE 0.
           88  SI-EXISTE-PLTEXOCOM                    VALUE 1.
      *Variable para control acceso directo del Archivo CLIMAEL01.
       01  W-EXISTE-CLIMAEL01             PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-CLIMAEL01                       VALUE 0.
           88  SI-EXISTE-CLIMAEL01                       VALUE 1.
      *Variable para control acceso directo del Archivo PLTFECHAS.
       01  W-EXISTE-PLTFECHAS          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-EXISTE-PLTFECHAS                    VALUE 0.
           88  SI-EXISTE-PLTFECHAS                    VALUE 1.
      *Esta variable controla la inicializacion de una pantalla del
      *subFile de W-REGXSFL registros.
       01  W-LLENO-PANSFL              PIC S9(01)     COMP-3 VALUE 0.
           88  NO-LLENO-PANSFL                        VALUE 0.
           88  SI-LLENO-PANSFL                        VALUE 1.
      *Indica si se presenta un error de validacion en algun formato
      *de pantalla.
       01  W-ERROR-GRABACION           PIC S9(01)     COMP-3 VALUE 0.
           88  NO-ERROR-GRABACION                     VALUE 0.
           88  SI-ERROR-GRABACION                     VALUE 1.
      *Indica si se presenta un error de validacion en algun formato
      *de pantalla.
      *Indica si se presenta un error de validacion en algun formato
      *de pantalla.
       01  W-ERROR-VALIDACION          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-ERROR-VALIDACION                    VALUE 0.
           88  SI-ERROR-VALIDACION                    VALUE 1.
      *Esta variable se utiliza para la creacion de un nuevo Parametro
      *y se utiliza para encontrar la posicion dentro del SubFile
      *donde se debe crear el nuevo registro.
       01  W-ENCONTRO-POSRSFL          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-ENCONTRO-POSRSFL                    VALUE 0.
           88  SI-ENCONTRO-POSRSFL                    VALUE 1.
      *Esta variable se utiliza para la creacion de un nuevo Parametro
      *y se utiliza para encontrar la posicion dentro del SubFile
      *Indica si se debe o no reorganizar el SubFile.
       01  W-REORGANIZAR-RSFL          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-REORGANIZAR-RSFL                    VALUE 0.
           88  SI-REORGANIZAR-RSFL                    VALUE 1.
      *
      *--------------------------------------------------------------- -
      * Declaracion de Variables Temporales                            |
      *--------------------------------------------------------------- -
      *
      *Contiene el numero de registros que hay en una pantalla del
      *SubFile.
       01  W-REGXSFL                   PIC S9(05)     COMP-3 VALUE 12.
       01  W-REGXSFL-TMP               PIC S9(05)     COMP-3 VALUE 12.
      *Utilizadas para la inicializacion de indicadores de pantalla.
       01  W-IND-0                     PIC 1          VALUE B"0".
       01  W-IND-1                     PIC 1          VALUE B"1".
      *Variables asociadas al registro de control del SubFile.
       01  W-CODCOR                    PIC  9(02)     VALUE ZEROS.
       01  W-CODRET                    PIC  9(01)     VALUE ZEROS.
       01  W-NITCLI                    PIC S9(17)     COMP-3 VALUE 0.
       01  W-PERIODO                   PIC S9(6)      COMP-3 VALUE 0.
       01  W-NITCLI2                   PIC S9(17)     COMP-3 VALUE 0.
       01  W-NITCLI3                   PIC  9(17)     VALUE 0.
       01  W-NUMTAR2                   PIC  X(19)     VALUE SPACES.
       01  W-NUMTAR3                   PIC  X(19)     VALUE SPACES.
       01  W-NITCLI1                   PIC S9(06)     COMP-3 VALUE 0.
       01  W-ENTBAN                    PIC  X(30)     VALUE SPACES.
       01  W-CODCON                    PIC  X(08)     VALUE SPACES.
       01  W-SITUAR-P.
           03  W-SITNIT-P              PIC 9(17)      VALUE 0.
       01  W-SITUAR-A.
           03  W-SITNIT-A              PIC 9(17)      VALUE 0.

       01  W-SITUAR-PER.
           03  W-SITPER-P              PIC 9(06)      VALUE 0.
       01  W-SITUAR-AP.
           03  W-SITPER-A              PIC 9(06)      VALUE 0.
      *Utilizada para presentar mensajes de error.
       01  W-MENSAJE                   PIC X(65)      VALUE SPACES.
       01  W-MENSAJE2                  PIC X(71)      VALUE SPACES.
       01  W-MENSAJE3                  PIC X(71)      VALUE SPACES.
      *Utilizada para presentar el titulo de la pantalla.
       01  W-TITULO                    PIC X(40)      VALUE SPACES.
       01  W-TITULO1                   PIC X(49)      VALUE SPACES.
       01  W-TITULO2                   PIC X(49)      VALUE SPACES.
       01  FILLER                      REDEFINES W-TITULO1.
           03  W-NOMTIT1               PIC X(17).
           03  W-DSCTRN1               PIC X(32).
      *Utilizada para presentar las teclas de funci_n activas
       01  W-TECFUN                    PIC X(60)      VALUE SPACES.
       01  W-TECFUN1                   PIC X(60)      VALUE SPACES.
      *Utilizadas para conocer la página del SubFile que se debe
      *mostrar.
       01  W-COCIENTE                  PIC S9(05)     COMP-3 VALUE 0.
       01  W-RESIDUO                   PIC S9(05)     COMP-3 VALUE 0.
      *Variables utilizadas en la pantalla01.
       01  W-HORA-PROCESO              PIC 9(08).
      *Variables utilizadas en la pantalla01.
       01  W-FECHA-PROCESO             PIC 9(08).
       01  FILLER                      REDEFINES W-FECHA-PROCESO.
           03  W-FECPRO-AAAA           PIC 9(04).
           03  MES-IMPUESTO            PIC 9(02).
           03  FILLER                  PIC 9(02).
       01  W-FECHA-SIGUIENTE           PIC 9(08).
      *Variables para el llamado a la ayuda de la Tabla de Paarmetros.
       01  W-AGCORI                    PIC 9(05)        VALUE ZEROS.
       01  W-CODCIU                    PIC 9(05)        VALUE ZEROS.
       01  W-CODBAN                    PIC 9(05)        VALUE ZEROS.
       01  W-FECHA3                    PIC 9(06)        VALUE ZEROS.
      *Variables utilizadas en el registro de control del Subfile.
       01  W-RSFLCTL.
           03  SFLRRN                  PIC S9(05).
           03  RELRCD                  PIC S9(05).
           03  FLD                     PIC X(10).
           03  RCD                     PIC X(10).
           03  POS                     PIC S9(04).
      *Variables utilizadas en la pantalla01.
       01  W-PANTALLA01.
           03  TITULO                  PIC X(40).
           03  TIPCLI                  PIC 9(03).
           03  TIPCAJ                  PIC 9(10).
           03  CODPRO                  PIC 9(03).
           03  NOMPRO                  PIC X(50).
           03  CANEXO                  PIC 9(03).
           03  BINEXO                  PIC 9(06).
           03  NROTRN                  PIC 9(03).
           03  CODCON                  PIC X(10).
           03  TIPEXO                  PIC 9(03).
           03  DESCAJ                  PIC X(20).
           03  DESTRA                  PIC X(20).
           03  DESTIP                  PIC X(20).
           03  DESBIN                  PIC X(20).
           03  DESCLI                  PIC X(20).
           03  TECFUN                  PIC X(60).
           03  MENSAJE                 PIC X(65).
           03  RCD                     PIC X(10).
           03  FLD                     PIC X(10).
           03  POS                     PIC S9(04).
      *Utilizada para validación de fechas.
       01  W-FECHA                     PIC 9(08)             VALUE 0.
       01  FILLER                      REDEFINES W-FECHA.
           03  W-FECAA                 PIC 9(04).
           03  W-FECMM                 PIC 9(02).
           03  W-FECDD                 PIC 9(02).
      *Variable que indica si se trata de Adici¾n o Modificaci¾n
      *de Hojas de Ruta.
       01  W-TIPOPR                    PIC 9(01)      COMP-3 VALUE 0.
      *
      *--------------------------------------------------------------- -
      * Declaracion de Variables Contadores                            |
      *--------------------------------------------------------------- -
      *
      *Indices para manejo de tablas.
       01  I                           PIC 9(05)      COMP-3 VALUE 0.
       01  J                           PIC 9(05)      COMP-3 VALUE 0.
       01  K                           PIC 9(05)      COMP-3 VALUE 0.
       01  L                           PIC 9(05)      COMP-3 VALUE 0.
      *
      *Variables para controlar el llamado de la ayuda del Clientes
       01 X-NITCLI                     PIC 9(15).
       01 X-TIPDOC                     PIC 9(01).
       01 X-NOMCLI                     PIC X(35).
       01 W-NRONIT                     PIC 9(15).
      *Variables para controlar el llamado de la ayuda del Cuentas
       01 W-NROTRN                     PIC 9(09).
       01 W-CODMON                     PIC 9(03).
       01 W-CODPRO                     PIC 9(03).
       01 W-NUMAGE                     PIC 9(05).
       01 W-NUMCTA                     PIC 9(17).
       01 X-CODSIS                     PIC 9(03).
       01 X-CODPRO                     PIC 9(02).
       01 X-NUMAGE                     PIC 9(04).
       01 X-NUMCTA                     PIC 9(06).
       01 W-TECSAL                     PIC 9(03).
       01 W-MONTO-MES                  PIC 9(13)V99.
      *
      *Variables para controlar el llamado de la ayuda del Concepto
       01 X-CODCON                     PIC X(08).
       01 X-NOMCON                     PIC X(40).
      *Variables Utilizadas para llamar rutina CLIB101
       01 X-NITCLI-ANT                 PIC 9(17) VALUE 0.
       01 X-NITCLI-CLIB                PIC 9(17) VALUE 0.
       01 X-ACCION                     PIC 9(01) VALUE 0.
       01 X-ESTADO                     PIC 9(01) VALUE 0.
       01 X-EJECUTO                    PIC 9(01) VALUE 0.
       01 X-CODRET                     PIC 9(01) VALUE 0.
      *Variables Utilizadas para llamar rutina PLTCNV090.
       01 CNV-NUMCON                   PIC X(10) VALUE SPACES.
       01 CNV-NOMCON                   PIC X(25) VALUE SPACES.
       01 CNV-DESCON                   PIC X(60) VALUE SPACES.
       01 CNV-NITEMP                   PIC 9(17) VALUE 0.
       01 CNV-NOMEMP                   PIC X(30) VALUE SPACES.
      *----------------------------------------------------------------
             COPY EXTRACT OF PLTCPY.
      *----------------------------------------------------------------
       LINKAGE SECTION.
TYJ    77  XWCE         PIC 9(05).
      *----------------------------------------------------------------
       77  W-CODCAJ       PIC X(10).
       77  XAGEORI        PIC 9(05).
      *----------------------------------------------------------------
      * Procedure Division                                            |
      *----------------------------------------------------------------
      *
TYJ    PROCEDURE DIVISION USING XWCE ,
                                W-CODCAJ, XAGEORI.
       INICIAR-PROGRAMA.
           PERFORM INICIALIZAR.
           PERFORM PROCESAR UNTIL SI-FIN-RSFLCTL
           PERFORM FINALIZAR.
      *
       FINALIZAR-PROGRAMA.
           GOBACK
           STOP RUN.
      *
      *----------------------------------------------------------------
      * Procedimiento : Inicializar.                                  |
      * Descripci_n   : En este procedimiento se inicializan las      |
      *                 variables de control y se abren los archivos  |
      *                 utilizados.                                   |
      *----------------------------------------------------------------
      *
       INICIALIZAR.
           OPEN INPUT  CLITAB PLTPARGEN
           OPEN INPUT PLTFECHAS
           MOVE 5                      TO CODSIS OF REGFECHAS
           PERFORM LEER-PLTFECHAS
           IF ( NO-EXISTE-PLTFECHAS )
              DISPLAY "No Existe Fecha de Proceso. Llamar a Sistemas"
              CLOSE PLTFECHAS
              STOP RUN
           END-IF.
           PERFORM LEER-PLTPARGEN
           OPEN I-O   PANTALLA
           OPEN I-O   PLTEXOCOM
           OPEN INPUT CLIMAEL01
           OPEN EXTEND LOGEXOCOM
           MOVE FECPRO OF REGFECHAS    TO W-FECHA
                                          W-FECHA-PROCESO
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-FIN-RSFLCTL
                                          W-ERROR-GRABACION
           MOVE "Intro=Aceptar F5=Renovar F6=Crear F3=Salir"
                                       TO W-TECFUN
           MOVE 0                      TO W-NUMRRN
           PERFORM CARGAR-SUBARCHIVO
           IF ( W-SBF-CLAVE > 0 )
              MOVE 1                   TO W-NUMRRN
           END-IF.
      *----------------------------------------------------------------
      * Procedimiento : Cargar-SubArchivo.                            |
      * Descripción   : Se inicializa el SubFile y se lee la primera  |
      *                 pAgina del mismo.                             |
      *----------------------------------------------------------------
       CARGAR-SUBARCHIVO.
           MOVE ALL B"0"               TO W-AREA-INDICADORES-RSFL
           MOVE ALL B"0"               TO W-AREA-INDICADORES-RSFLCTL
           MOVE 0                      TO W-SBF-CLAVE
           MOVE 0                      TO W-LLENO-PANSFL
           PERFORM INICIAR-SUBARCHIVO
           PERFORM LOCALIZAR-PRIMER-REGISTRO
           PERFORM LLENAR-PAGINA-RSFL VARYING I FROM 1 BY 1
                 UNTIL ( SI-FIN-PLTEXOCOM ) OR I > 200
           IF ( W-SBF-CLAVE > 0 )
             IF ( W-RELRCD > 1 )
                 COMPUTE W-NUMRRN = W-RELRCD - 1
             ELSE
                 IF ( W-NUMRRN = 0 )
                    MOVE 1             TO W-NUMRRN
                 ELSE
                    MOVE W-SBF-CLAVE   TO W-NUMRRN
                 END-IF
             END-IF
           END-IF
           IF ( SI-ENCONTRO-POSRSFL )
             MOVE 1                    TO W-NUMRRN
           END-IF
           IF ( SI-FIN-PLTEXOCOM )
               MOVE W-IND-1              TO W-INDICADOR-RSFLCTL ( 05 )
               MOVE W-IND-1              TO W-INDICADOR-RSFLCTL ( 01 )
           END-IF.
           IF ( I > ZEROS )
               MOVE W-IND-0              TO W-INDICADOR-RSFLCTL ( 01 )
           END-IF.
      *
      *-----------------------------------------------------------------
      * Procedimiento : Iniciar-SubArchivo.                            |
      * Descripción   : Se inicializan los indicadores y variables     |
      *                 ascociadas al registro de control del          |
      *                 SubArchivo.                                    |
      *-----------------------------------------------------------------
      *
       INICIAR-SUBARCHIVO.
           MOVE W-IND-1                TO W-INDICADOR-RSFLCTL ( 04 )
           PERFORM INICIAR-VARIABLES-RSFLCTL
           WRITE PANTALLA-REC          FORMAT IS "RSFLCTL" INDICATOR
                                       W-AREA-INDICADORES-RSFLCTL
           END-WRITE.
           MOVE W-IND-1                TO W-INDICADOR-RSFLCTL ( 02 )
           MOVE W-IND-0                TO W-INDICADOR-RSFLCTL ( 04 ).
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Variables-Rslfctl.                    |
      * Descripción   : Se inicializan las variables del registro     |
      *                 de pantalla RSFLCTL.                          |
      *----------------------------------------------------------------
      *
       INICIAR-VARIABLES-RSFLCTL.
           INITIALIZE                  W-RSFLCTL
           MOVE W-RELRCD               TO RELRCD OF REG-RSFLCTL-O
           MOVE W-NUMRRN               TO SFLRRN OF REG-RSFLCTL-O.
      *-----------------------------------------------------------------
      * Procedimiento : Localizar-Primer-Registro.                     |
      * Descripción   : Se verifica que exista por lo menos un         |
      *                 parametro en el archivo PLTEXOCOM.             |
      *-----------------------------------------------------------------
      *
       LOCALIZAR-PRIMER-REGISTRO.
           MOVE 0                      TO W-FIN-PLTEXOCOM
           MOVE ZEROS                  TO BINEXO OF PLTEXOCOM
           MOVE ZEROS                  TO TIPCAJ OF PLTEXOCOM
           MOVE ZEROS                  TO TIPCLI OF PLTEXOCOM
           MOVE SPACES                 TO CODCON OF PLTEXOCOM
           MOVE ZEROS                  TO CODPRO OF PLTEXOCOM
           START PLTEXOCOM             KEY NOT <
              EXTERNALLY-DESCRIBED-KEY INVALID KEY
              MOVE W-IND-1          TO W-INDICADOR-RSFLCTL ( 05 )
              MOVE W-IND-1          TO W-INDICADOR-RSFLCTL ( 01 )
              MOVE 1                TO W-FIN-PLTEXOCOM
           END-START.
      *-----------------------------------------------------------------
      * Procedimiento : Llenar-Pagina-Rsfl.                            |
      * Descripción   : Se llena escribe una nueva pAgina de           |
      *                 W-REGXSFL registros en el SubFile.             |
      *-----------------------------------------------------------------
      *
       LLENAR-PAGINA-RSFL.
           READ PLTEXOCOM  NEXT RECORD  WITH NO LOCK AT END
                          MOVE 1 TO W-FIN-PLTEXOCOM
           END-READ.
           IF ( NO-FIN-PLTEXOCOM )
              ADD 1                     TO W-SBF-CLAVE
              PERFORM INICIAR-INDICADORES-RSFL
              INITIALIZE RSFL-O
              MOVE BINEXO OF PLTEXOCOM TO BINEXO OF RSFL-O
              IF ( BINEXO OF RSFL-O = 99 )
                MOVE "Todos los Bines" TO DESBIN OF RSFL-O
              ELSE
                MOVE 335                    TO CODTAB OF  CLITAB
                MOVE BINEXO OF PLTEXOCOM    TO CODINT OF  CLITAB
                PERFORM LEER-CLITAB
                IF ( SI-EXISTE-CLITAB )
                  MOVE CODNOM OF CLITAB TO DESBIN OF RSFL-O
                END-IF
              END-IF
      *
              MOVE TIPCAJ OF PLTEXOCOM TO TIPCAJ OF RSFL-O
              IF ( TIPCAJ OF RSFL-O = 99 )
                MOVE "Todos los Cajeros" TO DESTIP OF RSFL-O
              ELSE
                MOVE 333                    TO CODTAB OF  CLITAB
                MOVE TIPCAJ OF PLTEXOCOM    TO CODINT OF  CLITAB
                PERFORM LEER-CLITAB
                IF ( SI-EXISTE-CLITAB )
                  MOVE CODNOM OF CLITAB TO DESTIP OF RSFL-O
                END-IF
              END-IF
      *
              MOVE TIPCLI OF PLTEXOCOM TO TIPCLI OF RSFL-O
              IF ( TIPCLI OF RSFL-O = 99 )
                MOVE "Todos los Tipos Clientes" TO DESCLI OF RSFL-O
              ELSE
                MOVE 334                    TO CODTAB OF  CLITAB
                MOVE TIPCLI OF PLTEXOCOM    TO CODINT OF  CLITAB
                PERFORM LEER-CLITAB
                IF ( SI-EXISTE-CLITAB )
                  MOVE CODNOM OF CLITAB TO DESCLI OF RSFL-O
                END-IF
              END-IF
      *
              MOVE CODPRO OF PLTEXOCOM TO CODPRO OF RSFL-O
              IF ( CODPRO OF RSFL-O = 99 )
                MOVE "Todos los Tipos Productos" TO NOMPRO OF RSFL-O
              ELSE
                MOVE 336                    TO CODTAB OF  CLITAB
                MOVE CODPRO OF PLTEXOCOM    TO CODINT OF  CLITAB
                PERFORM LEER-CLITAB
                IF ( SI-EXISTE-CLITAB )
                  MOVE CODNOM OF CLITAB     TO NOMPRO OF RSFL-O
                END-IF
              END-IF
      *
              MOVE CODCON OF PLTEXOCOM TO CODCON OF RSFL-O
              MOVE CANEXO OF PLTEXOCOM TO CANEXO OF RSFL-O

              MOVE 0                   TO OPCION OF RSFL-O
              WRITE SUBFILE PANTALLA-REC FORMAT IS "RSFL" INDICATOR
                                        W-AREA-INDICADORES-RSFL
              MOVE W-IND-1              TO W-INDICADOR-RSFLCTL ( 03 )
           END-IF.
      *
      *-----------------------------------------------------------------
      * Procedimiento : Iniciar-Indicadores-Rsfl.                      |
      * Descripci_n   : Se inicializan los indicadores del registro    |
      *                 de pantalla RSFL.                              |
      *-----------------------------------------------------------------
      *
       INICIAR-INDICADORES-RSFL.
           MOVE W-IND-0                TO W-INDICADOR-RSFL ( 01 )
           MOVE W-IND-0                TO W-INDICADOR-RSFL ( 02 ).
      *
      *
      *-----------------------------------------------------------------
      * Procedimiento : PROCESAR                                       |
      * Descripci_n   : Se presenta el registro de control permitien-  |
      *                 do al usuario adicionar, cambiar o eliminar    |
      *                 un parametro.                                  |
      *-----------------------------------------------------------------
      *
       PROCESAR.
           PERFORM LEER-PANTALLA-MANTENIMIENTO.
      *-----------------------------------------------------------------
      * Procedimiento : LEER-PANTALLA-MANTENIMIENTO.                   |
      * Descripci_n   : Se presenta el registro de control permitien-  |
      *                 do al usuario adicionar, cambiar o eliminar    |
      *                 un parametro.                                  |
      *-----------------------------------------------------------------
      *
       LEER-PANTALLA-MANTENIMIENTO.
           MOVE 99                     TO W-FUNCION-UTILIZADA
           PERFORM DISPLAY-AND-READ-RSFLCTL UNTIL F03 OR F05 OR F06 OR
                                               ENTER-KEY OR F04
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-ERROR-VALIDACION
           EVALUATE ( W-FUNCION-UTILIZADA )
           WHEN ( 0 )
                PERFORM VALIDAR-OPCIONES-RSFL
                IF ( NO-ERROR-VALIDACION )
                  PERFORM APLICAR-OPCIONES-RSFL
                END-IF
           WHEN ( 3 )
                MOVE 1                  TO W-FIN-RSFLCTL
           WHEN ( 5 )
                MOVE 0                  TO W-NUMRRN
                PERFORM CARGAR-SUBARCHIVO
                IF ( W-SBF-CLAVE > 0 )
                  IF ( W-RELRCD > 0 )
                    MOVE W-RELRCD       TO W-NUMRRN
                  ELSE
                    MOVE 1              TO W-NUMRRN
                  END-IF
                END-IF
           WHEN ( 6 )
                PERFORM CREAR-EXONERACION
                MOVE 0                  TO W-NUMRRN
                PERFORM CARGAR-SUBARCHIVO
                IF ( W-SBF-CLAVE > 0 )
                  IF ( W-RELRCD > 0 )
                    MOVE W-RELRCD       TO W-NUMRRN
                  ELSE
                    MOVE 1              TO W-NUMRRN
                  END-IF
                END-IF
           END-EVALUATE.
      *-----------------------------------------------------------------
      * Procedimiento : Validar-Datos-Adicion                          |
      * Descripci_n   : Se verifica que los datos CLIMAEL01            |
      *-----------------------------------------------------------------
      *
       VALIDAR-DATOS-ADICION.

           IF ( NO-ERROR-VALIDACION )
             IF ( BINEXO OF W-PANTALLA01 = ZEROS OR 99 )
                 MOVE "BIN debe ser ingresado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 04 )
             ELSE
               MOVE 335                    TO CODTAB OF  CLITAB
               MOVE BINEXO OF W-PANTALLA01 TO CODINT OF  CLITAB
               PERFORM LEER-CLITAB
               IF ( NO-EXISTE-CLITAB )
                 MOVE "BIN no Parametrizado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 04 )
               ELSE
                 MOVE CODNOM OF CLITAB TO DESBIN OF W-PANTALLA01
               END-IF
             END-IF
           END-IF
      *
           IF ( NO-ERROR-VALIDACION )
             IF ( TIPCAJ OF W-PANTALLA01 = ZEROS OR 99 )
                 MOVE "Tipo de Cajero debe ser ingresado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 05 )
             ELSE
               MOVE 333                    TO CODTAB OF  CLITAB
               MOVE TIPCAJ OF W-PANTALLA01 TO CODINT OF  CLITAB
               PERFORM LEER-CLITAB
               IF ( NO-EXISTE-CLITAB )
                 MOVE "Tipo de Cajero no Parametrizado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 05 )
               ELSE
                 MOVE CODNOM OF CLITAB TO DESCAJ OF W-PANTALLA01
               END-IF
             END-IF
           END-IF
      *
           IF ( NO-ERROR-VALIDACION )
              IF ( TIPCLI OF W-PANTALLA01 = ZEROS OR 99)
                  MOVE "Tipo de Cliente debe ser ingresado"
                                    TO W-MENSAJE
                  MOVE 1             TO W-ERROR-VALIDACION
                  MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
              ELSE
                MOVE 334                    TO CODTAB OF  CLITAB
                MOVE TIPCLI OF W-PANTALLA01 TO CODINT OF  CLITAB
                PERFORM LEER-CLITAB
                IF ( NO-EXISTE-CLITAB )
                  MOVE "Tipo de Cliente no Parametrizado"
                                    TO W-MENSAJE
                  MOVE 1             TO W-ERROR-VALIDACION
                  MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
                ELSE
                  MOVE CODNOM OF CLITAB TO DESCLI OF W-PANTALLA01
                END-IF
              END-IF
           END-IF
      *
           IF ( NO-ERROR-VALIDACION )
              IF ( TIPCLI OF W-PANTALLA01 = 4 )
                 IF ( CODCON OF W-PANTALLA01 = SPACES )
                    MOVE "Código de convenio debe ser ingresado"
                                       TO W-MENSAJE
                    MOVE 1             TO W-ERROR-VALIDACION
                    MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
                 END-IF
              ELSE
                 IF ( CODCON OF W-PANTALLA01 NOT = SPACES )
                    MOVE "Código de convenio NO debe ser ingresado"
                                       TO W-MENSAJE
                    MOVE 1             TO W-ERROR-VALIDACION
                    MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
                 END-IF
              END-IF
           END-IF
      *
           IF ( NO-ERROR-VALIDACION )
             IF ( CODPRO OF W-PANTALLA01 = ZEROS )
                 MOVE "Tipo de Producto debe ser ingresado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 08 )
             ELSE
               MOVE 336                    TO CODTAB OF  CLITAB
               MOVE CODPRO OF W-PANTALLA01 TO CODINT OF  CLITAB
               PERFORM LEER-CLITAB
               IF ( NO-EXISTE-CLITAB )
                 MOVE "Tipo de Producto no Parametrizado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 08 )
               ELSE
                 MOVE CODNOM OF CLITAB TO NOMPRO OF W-PANTALLA01
               END-IF
             END-IF
           END-IF
      *
           IF ( NO-ERROR-VALIDACION )
             IF( TIPEXO OF W-PANTALLA01 = ZEROS OR 99)
               MOVE 99  TO TIPEXO OF W-PANTALLA01
               MOVE "Todo Tipo Transaccion" TO DESTIP OF W-PANTALLA01
             ELSE
               MOVE 236                    TO CODTAB OF  CLITAB
               MOVE TIPEXO OF W-PANTALLA01 TO CODINT OF  CLITAB
               PERFORM LEER-CLITAB
               IF ( NO-EXISTE-CLITAB )
                 MOVE "Tipo de Transacciones no Parametrizado"
                                     TO W-MENSAJE
                 MOVE 1              TO W-ERROR-VALIDACION
                 MOVE W-IND-1          TO W-INDICADOR-PANTALLA01 ( 04 )
               ELSE
                  MOVE CODNOM OF CLITAB TO DESTIP OF W-PANTALLA01
               END-IF
             END-IF
           END-IF.
      *
           IF ( NO-ERROR-VALIDACION )
             IF( CANEXO OF W-PANTALLA01 = ZEROS )
              MOVE "Debe Ingresar Cantidad de Transacciones a Exonerar"
                                      TO W-MENSAJE
              MOVE 1                  TO W-ERROR-VALIDACION
              MOVE W-IND-1            TO W-INDICADOR-PANTALLA01 ( 07 )
             END-IF
           END-IF.
      *-----------------------------------------------------------------
      * Procedimiento : Display-And-Read-Rsflctl.                      |
      * Descripci_n   : Se escriben y leen los formatos HEADER,        |
      *                 y RSFLCTL.                                     |
      *-----------------------------------------------------------------
      *
       DISPLAY-AND-READ-RSFLCTL.

           IF ( W-SBF-CLAVE = 0 )
             WRITE PANTALLA-REC      FORMAT IS "PANTALLA03"
           END-IF
           MOVE FECPRO OF REGFECHAS
                                  TO FECPRO OF HEADER-O OF PANTALLA-REC
           MOVE NOMBAN OF REGPARGEN
                                  TO NOMEMP OF HEADER-O OF PANTALLA-REC
           CALL "EXTRACT" USING   W-DA EX-DATE.
           MOVE W-FECHA  TO FECSIS OF HEADER-O OF PANTALLA-REC
           WRITE PANTALLA-REC          FORMAT IS "HEADER"
           END-WRITE.
           MOVE W-MENSAJE              TO FMENSAJE   OF FOOTER-O
           MOVE W-TECFUN               TO FTECFUN    OF FOOTER-O
           WRITE PANTALLA-REC          FORMAT IS "FOOTER"
           END-WRITE.
           PERFORM INICIAR-VARIABLES-RSFLCTL
           MOVE CORR W-RSFLCTL         TO REG-RSFLCTL-O
           WRITE PANTALLA-REC          FROM REG-RSFLCTL-O
                                       FORMAT IS "RSFLCTL" INDICATOR
                                       W-AREA-INDICADORES-RSFLCTL
           END-WRITE.
           READ  PANTALLA              INTO REG-RSFLCTL-I
                                       FORMAT IS "RSFLCTL" INDICATOR
                                       W-AREA-INDICADORES-RTA
           END-READ.
           MOVE RCD OF REG-RSFLCTL-I       TO RCD OF W-RSFLCTL
           MOVE FLD OF REG-RSFLCTL-I       TO FLD OF W-RSFLCTL.
      *-----------------------------------------------------------------
      * Procedimiento : Validar-Opciones-RSfl.                         |
      * Descripcion   : Se verifica que las opciones ingresadas en     |
      *                 el SubFile sean Cambiar o Suprimir.            |
      *-----------------------------------------------------------------
      *
       VALIDAR-OPCIONES-RSFL.
           MOVE W-SBF-CLAVE            TO W-SBF-CLAVE-TMP
           MOVE 0                      TO W-SBF-CLAVE
           MOVE 1                      TO I
           MOVE 0                      TO J
           PERFORM UNTIL ( I > W-SBF-CLAVE-TMP ) OR
                       ( SI-ERROR-VALIDACION )
               MOVE I                    TO W-SBF-CLAVE
               READ SUBFILE PANTALLA     FORMAT "RSFL"
                   INDICATOR W-AREA-INDICADORES-RSFL
           END-READ
           IF ( OPCION OF RSFL-I NOT = 0 AND NOT = 2 AND NOT = 4
                AND NOT = 5 )
           MOVE "La opcion ingresada es Invalida."
                                    TO W-MENSAJE
           MOVE 1                  TO W-ERROR-VALIDACION
           MOVE W-IND-1            TO W-INDICADOR-RSFL ( 51 )
           REWRITE SUBFILE PANTALLA-REC FORMAT "RSFL"
                    INDICATOR W-AREA-INDICADORES-RSFL
           END-REWRITE
             IF ( J = 0 )
                MOVE I                TO W-NUMRRN
                MOVE 1                TO J
             END-IF
           ELSE
             IF ( OPCION OF RSFL-I = 0 )
                MOVE 0                TO OPCION OF RSFL-O
                PERFORM INICIAR-INDICADORES-RSFL
                REWRITE SUBFILE PANTALLA-REC FORMAT "RSFL"
                        INDICATOR W-AREA-INDICADORES-RSFL
                END-REWRITE
             END-IF
           END-IF
           ADD 1                     TO I
           END-PERFORM.
           MOVE W-SBF-CLAVE-TMP        TO W-SBF-CLAVE.
      *
      *-----------------------------------------------------------------
      * Procedimiento : Aplicar-Opciones-Rsfl.                         |
      * Descripcion   : Dependiendo de la opcion ( 2 _ 4 ) se          |
      *                 Modifica o Elimina el registro                 |
      *                 respectivamente.                               |
      *-----------------------------------------------------------------
      *
       APLICAR-OPCIONES-RSFL.
           MOVE W-SBF-CLAVE            TO W-SBF-CLAVE-TMP
           MOVE 0                      TO W-SBF-CLAVE
           MOVE 1                      TO I
           MOVE 0                      TO J
           MOVE 0                      TO W-REORGANIZAR-RSFL
           PERFORM UNTIL ( I > W-SBF-CLAVE-TMP ) OR
                         ( SI-ERROR-VALIDACION ) OR ( SI-FIN-RSFLCTL )
           MOVE I                    TO W-SBF-CLAVE
           READ SUBFILE PANTALLA     FORMAT "RSFL"
                         INDICATOR            W-AREA-INDICADORES-RSFL
           END-READ
           EVALUATE ( OPCION OF RSFL-I )
             WHEN ( 2 )
              MOVE BINEXO OF RSFL-I TO BINEXO OF PLTEXOCOM
              MOVE TIPCAJ OF RSFL-I TO TIPCAJ OF PLTEXOCOM
              MOVE TIPCLI OF RSFL-I TO TIPCLI OF PLTEXOCOM
              MOVE CANEXO OF RSFL-I TO CANEXO OF PLTEXOCOM
              MOVE CODCON OF RSFL-I TO CODCON OF PLTEXOCOM
              MOVE CODPRO OF RSFL-I TO CODPRO OF PLTEXOCOM
              PERFORM LEER-PLTEXOCOM-NOLOCK
              IF ( SI-EXISTE-PLTEXOCOM )
                  PERFORM MODIFICAR-EXONERACION
              END-IF
             WHEN ( 4 )
              MOVE BINEXO OF RSFL-I TO BINEXO OF PLTEXOCOM
              MOVE TIPCAJ OF RSFL-I TO TIPCAJ OF PLTEXOCOM
              MOVE TIPCLI OF RSFL-I TO TIPCLI OF PLTEXOCOM
              MOVE CANEXO OF RSFL-I TO CANEXO OF PLTEXOCOM
              MOVE CODCON OF RSFL-I TO CODCON OF PLTEXOCOM
              MOVE CODPRO OF RSFL-I TO CODPRO OF PLTEXOCOM
              PERFORM LEER-PLTEXOCOM-NOLOCK
              IF ( SI-EXISTE-PLTEXOCOM )
                 PERFORM BORRAR-EXONERACION
              END-IF
             WHEN ( 5 )
                 INITIALIZE W-NITCLI3 W-NUMTAR3
                 MOVE BINEXO OF RSFL-I TO BINEXO OF PLTEXOCOM
                 MOVE TIPCAJ OF RSFL-I TO TIPCAJ OF PLTEXOCOM
                 MOVE TIPCLI OF RSFL-I TO TIPCLI OF PLTEXOCOM
                 MOVE CANEXO OF RSFL-I TO CANEXO OF PLTEXOCOM
                 MOVE CODCON OF RSFL-I TO CODCON OF PLTEXOCOM
                 MOVE CODPRO OF RSFL-I TO CODPRO OF PLTEXOCOM
                 PERFORM LEER-PLTEXOCOM-NOLOCK
                 IF ( SI-EXISTE-PLTEXOCOM )
                    PERFORM CONSULTAR-EXONERACION
                 END-IF
           END-EVALUATE

           READ SUBFILE PANTALLA     FORMAT "RSFL"
           INDICATOR            W-AREA-INDICADORES-RSFL
           END-READ
           MOVE 0                    TO OPCION OF RSFL-O
           REWRITE SUBFILE PANTALLA-REC FORMAT "RSFL"
                   INDICATOR W-AREA-INDICADORES-RSFL
           END-REWRITE
             ADD 1                     TO I
           END-PERFORM.
           MOVE W-SBF-CLAVE-TMP        TO W-SBF-CLAVE
           IF ( SI-REORGANIZAR-RSFL )
             PERFORM CARGAR-SUBARCHIVO
             IF ( W-NUMRRN > W-SBF-CLAVE )
               IF ( W-SBF-CLAVE = 0 )
                 MOVE 0                TO W-NUMRRN
               ELSE
                 MOVE W-SBF-CLAVE      TO W-NUMRRN
               END-IF
             END-IF
           END-IF.
      *
      *----------------------------------------------------------------
      * Procedimiento : ACTUALIZAR-SUBFILE.                           |
      * Descripci_n   : Se inicializan los campos e indicadores del   |
      *                 formato de pantalla (PANTALLA01) y se invoca  |
      *                 el procedimiento que captura los datos nuevos.|
      *----------------------------------------------------------------
       ACTUALIZAR-SUBFILE.

           MOVE 0                  TO W-NUMRRN
           PERFORM CARGAR-SUBARCHIVO
           IF ( W-SBF-CLAVE > 0 )
             IF ( W-RELRCD > 0 )
               MOVE W-RELRCD       TO W-NUMRRN
             ELSE
               MOVE 1              TO W-NUMRRN
             END-IF
           END-IF.
      *----------------------------------------------------------------
      * Procedimiento : Crear-EXONERACION                             |
      * Descripci_n   : Se inicializan los campos e indicadores del   |
      *                 formato de pantalla (PANTALLA01) y se invoca  |
      *                 el procedimiento que captura los datos nuevos.|
      *----------------------------------------------------------------
       CREAR-EXONERACION.
           PERFORM INICIAR-CAMPOS-ADICION
           PERFORM INICIAR-INDICADORES-ADICION
           MOVE 0                      TO W-FIN-PANTALLA01
           PERFORM LEER-DATOS-ADICION  UNTIL ( SI-FIN-PANTALLA01 ) OR
                                             ( SI-FIN-RSFLCTL )
           IF ( NO-FIN-RSFLCTL )
             MOVE "Intro=Aceptar F5=Renovar F6=Crear F3=Salir"
                                       TO W-TECFUN
           END-IF.
      *
      *
       INICIAR-CAMPOS-ADICION.
           MOVE "Intro=Aceptar   F3=Salir   F12=Anterior"
                                              TO W-TECFUN
           MOVE "Parametrizar Exoneracion Transacciones"
                                              TO W-TITULO
           INITIALIZE PANTALLA01-O
           INITIALIZE W-PANTALLA01.
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Indicadores-Adici¾n.                  |
      * Descripci¾n   : Se inician los indicadores asociados al       |
      *                 formato de pantalla (PANTALLA01).             |
      *----------------------------------------------------------------
      *
       INICIAR-INDICADORES-ADICION.
           MOVE ALL B"0"             TO W-AREA-INDICADORES-PANTALLA01.
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 20 ).
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Datos-Adici¾n.                           |
      * Descripci¾n   : Se lee el formato de pantalla "PANTALLA01"    |
      *                 para capturar los datos del nuevo parametro.  |
      *----------------------------------------------------------------
      *
       LEER-DATOS-ADICION.
           MOVE 99                     TO W-FUNCION-UTILIZADA
           PERFORM DISPLAY-AND-READ-PANTALLA01
                   UNTIL ENTER-KEY OR F03 OR F12 OR F04
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-ERROR-VALIDACION
           PERFORM INICIAR-INDICADORES-ADICION
           EVALUATE ( W-FUNCION-UTILIZADA )
             WHEN ( 3 )
               MOVE 1                  TO W-FIN-PANTALLA01
               MOVE 1                  TO W-FIN-RSFLCTL
             WHEN ( 4 )
               PERFORM ATENDER-AYUDA-PANTALLA
             WHEN ( 12 )
               MOVE 1                  TO W-FIN-PANTALLA01
             WHEN ( 0 )
               PERFORM VALIDAR-DATOS-ADICION
               IF ( NO-ERROR-VALIDACION )
                 PERFORM GRABAR-EXONERACION
                 IF ( NO-ERROR-VALIDACION )
                   PERFORM ALERTA-EXONERACION-GENERADO
                   MOVE 1                  TO W-FIN-PANTALLA01
                 END-IF
               END-IF
           END-EVALUATE.
      *----------------------------------------------------------------
      * Procedimiento : Display-And-Read-Pantalla01.                  |
      * Descripción   : Se escriben y leen los formatos HEADER,       |
      *                 FOOTER y PANTALL01.                           |
      *----------------------------------------------------------------
      *
       DISPLAY-AND-READ-PANTALLA01.
           MOVE W-TITULO               TO TITULO  OF W-PANTALLA01
           MOVE W-TECFUN               TO TECFUN OF W-PANTALLA01
           MOVE W-MENSAJE              TO MENSAJE OF W-PANTALLA01
           MOVE CORR W-PANTALLA01      TO PANTALLA01-O
           WRITE PANTALLA-REC          FORMAT IS "PANTALLA01" INDICATOR
                                       W-AREA-INDICADORES-PANTALLA01.
           READ  PANTALLA              FORMAT IS "PANTALLA01" INDICATOR
                                       W-AREA-INDICADORES-RTA
           END-READ.
           MOVE CORR PANTALLA01-I      TO W-PANTALLA01.
      *----------------------------------------------------------------
      * Procedimiento : GRABAR-EXONERACION.                           |
      * Descripci¾n   : Se ingresa un nuevo registro.                 |
      *----------------------------------------------------------------
       GRABAR-EXONERACION.
           INITIALIZE REGEXOCOM OF PLTEXOCOM W-ACCION
           MOVE CORR W-PANTALLA01      TO REGEXOCOM  OF PLTEXOCOM
           MOVE W-CODCAJ               TO USRING     OF PLTEXOCOM
           ACCEPT HORING OF REGEXOCOM OF PLTEXOCOM FROM TIME
           ACCEPT FECING OF REGEXOCOM OF PLTEXOCOM FROM DATE
           WRITE PLTEXOCOM-REC         INVALID KEY
                 MOVE "Error en Parametrización - Llave Duplicada"
                                       TO W-MENSAJE
                 MOVE 1                TO W-ERROR-VALIDACION
                 MOVE 1 TO W-ERROR-GRABACION
                                       NOT INVALID KEY
                 MOVE "Adicion" TO W-ACCION
                 MOVE CORR REGEXOCOM OF PLTEXOCOM
                                     TO REGEXOCOM OF LOGEXOCOM
                 PERFORM GRABAR-LOG
           END-WRITE.
      *----------------------------------------------------------------
      * Procedimiento : ALERTA-EXONERACION-GENERADO.                  |
      * Descripci¾n   : Se ingresa un nuevo registro.                 |
      *----------------------------------------------------------------
       ALERTA-EXONERACION-GENERADO.

           MOVE "Exoneracion Activada"    TO X-MENSAJE
           MOVE 2                            TO X-CODRES
           MOVE "Información"                TO X-TITULO
           CALL "SIPR002" USING X-MENSAJE , X-CODRES , X-TITULO.
      *----------------------------------------------------------------
      * Procedimiento : Consultar-Exoneracion.                        |
      * Descripción   : Se consulta el detalle de uso de transacciones|
      *                 mes a mes.                                    |
      *----------------------------------------------------------------
      *
       CONSULTAR-EXONERACION.

           INITIALIZE W-PANTALLA01
           PERFORM INICIAR-CAMPOS-CONSULTA
           PERFORM INICIAR-INDICADORES-CONSULTA
           MOVE 0                      TO W-FIN-PANTALLA01
           PERFORM LEER-DATOS-CONSULTA UNTIL ( SI-FIN-PANTALLA01 ) OR
                                             ( SI-FIN-RSFLCTL )
           IF ( NO-FIN-RSFLCTL )
              MOVE "Intro=Aceptar F5=Renovar F6=Crear F3=Salir"
                                        TO W-TECFUN
           END-IF.
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Campos-Consulta.                      |
      * Descripci¾n   : Se inicializan las variables asociadas al     |
      *                 formato de pantalla "PANTALLA01" para         |
      *                 borrar el parametro.                          |
      *----------------------------------------------------------------
      *
       INICIAR-CAMPOS-CONSULTA.
           MOVE "Intro=Aceptar   F3=Salir   F12=Anterior"
                                               TO W-TECFUN
           MOVE "   Consulta de Exoneracione"  TO W-TITULO
           INITIALIZE                          W-PANTALLA01.
           MOVE CORR REGEXOCOM OF PLTEXOCOM TO W-PANTALLA01

           MOVE 335                 TO CODTAB OF CLITAB
           MOVE BINEXO OF PLTEXOCOM TO CODINT OF CLITAB
           IF ( BINEXO OF PLTEXOCOM = 99 )
             MOVE "Todos los Bines" TO DESBIN OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF (SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESBIN OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 333                 TO CODTAB OF CLITAB
           MOVE TIPCAJ OF PLTEXOCOM TO CODINT OF CLITAB
           IF ( TIPCAJ OF PLTEXOCOM = 99 )
             MOVE "Todos los Cajeros" TO DESCAJ OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF (SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESCAJ OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 334                  TO CODTAB OF CLITAB
           MOVE TIPCLI OF PLTEXOCOM  TO CODINT OF CLITAB
           IF ( TIPCLI OF PLTEXOCOM = 99 )
              MOVE "Todos los Tipos de Cliente"
                                     TO DESCLI OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF ( SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESCLI OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 336                  TO CODTAB OF CLITAB
           MOVE CODPRO OF PLTEXOCOM  TO CODINT OF CLITAB
           IF ( CODPRO OF PLTEXOCOM = 99 )
              MOVE "Todos los Tipos de Productos"
                                     TO NOMPRO OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF ( SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO NOMPRO OF W-PANTALLA01
             END-IF
           END-IF
           .
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Indicadores-Consulta.                 |
      * Descripci¾n   : Se inician los indicadores asociados al       |
      *                 formato de pantalla (PANTALLA01) para         |
      *                 borrar el parametro.                          |
      *----------------------------------------------------------------
      *
       INICIAR-INDICADORES-CONSULTA.
           MOVE ALL B"0"             TO W-AREA-INDICADORES-PANTALLA01
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 01 )
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 02 ).
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Datos-Consulta.                          |
      * Descripci¾n   : Se lee el formato de pantalla "PANTALLA01"    |
      *                 para consultar el registro.                   |
      *----------------------------------------------------------------
      *
       LEER-DATOS-CONSULTA.
           MOVE 99                     TO W-FUNCION-UTILIZADA
           PERFORM DISPLAY-AND-READ-PANTALLA01 UNTIL ENTER-KEY OR F03
                                                  OR F12
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-ERROR-VALIDACION
           EVALUATE ( W-FUNCION-UTILIZADA )
             WHEN ( 3 )
               MOVE 1                  TO W-FIN-PANTALLA01
               MOVE 1                  TO W-FIN-RSFLCTL
             WHEN ( 12 )
               MOVE 1                  TO W-FIN-PANTALLA01
             WHEN ( 0 )
               MOVE 1                  TO W-FIN-PANTALLA01
           END-EVALUATE.
      *
      *----------------------------------------------------------------
      * Procedimiento : MODIFICAR-EXONERACION.                        |
      * Descripci¾n   : Se cambia el Estado al registro en PLTEXOCOM  |
      *----------------------------------------------------------------
       MODIFICAR-EXONERACION.
           PERFORM INICIAR-CAMPOS-CAMBIO
           PERFORM INICIAR-INDICADORES-CAMBIO
           MOVE 0                      TO W-FIN-PANTALLA01
           PERFORM LEER-DATOS-CAMBIO  UNTIL ( SI-FIN-PANTALLA01 ) OR
                                            ( SI-FIN-RSFLCTL )
           IF ( NO-FIN-RSFLCTL )
             MOVE "Intro=Aceptar F5=Renovar F6=Crear F3=Salir"
                                       TO W-TECFUN
           END-IF.
      *----------------------------------------------------------------
      * Procedimiento : Borrar-EXONERACION.                           |
      * Descripci¾n   : Se cambia el Estado al registro en PLTEXOCOM  |
      *----------------------------------------------------------------
       BORRAR-EXONERACION.
           PERFORM INICIAR-CAMPOS-BORRADO
           PERFORM INICIAR-INDICADORES-BORRADO
           MOVE 0                      TO W-FIN-PANTALLA01
           PERFORM LEER-DATOS-BORRADO  UNTIL ( SI-FIN-PANTALLA01 ) OR
                                             ( SI-FIN-RSFLCTL )
           IF ( NO-FIN-RSFLCTL )
             MOVE "Intro=Aceptar F5=Renovar F6=Crear F3=Salir"
                                       TO W-TECFUN
           END-IF.
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Campos-cambio.                        |
      * Descripci¾n   : Se inicializan las variables asociadas al     |
      *                 formato de pantalla "PANTALLA01" para         |
      *                 borrar el parametro.                          |
      *----------------------------------------------------------------
      *
       INICIAR-CAMPOS-CAMBIO.
           MOVE  SPACES TO TECFUN OF W-PANTALLA01
                           MENSAJE OF W-PANTALLA01.
           MOVE "Intro=Aceptar   F3=Salir   F12=Anterior"
                                          TO W-TECFUN
           CALL "PLT201"             USING XWCE
                                           XAGEORI , W-CODCAJ ,
                                           W-CODMON, W-NROTRN.
           MOVE "Modificar Exoneracion Transacciones"
                                          TO W-TITULO
           INITIALIZE W-PANTALLA01
           MOVE CORR REGEXOCOM OF PLTEXOCOM TO W-PANTALLA01

           MOVE 335                 TO CODTAB OF CLITAB
           MOVE BINEXO OF PLTEXOCOM TO CODINT OF CLITAB
           IF ( BINEXO OF PLTEXOCOM = 99 )
             MOVE "Todos los Bines" TO DESBIN OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF (SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESBIN OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 333                 TO CODTAB OF CLITAB
           MOVE TIPCAJ OF PLTEXOCOM TO CODINT OF CLITAB
           IF ( TIPCAJ OF PLTEXOCOM = 99 )
             MOVE "Todos los Cajeros" TO DESCAJ OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF (SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESCAJ OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 334                  TO CODTAB OF CLITAB
           MOVE TIPCLI OF PLTEXOCOM  TO CODINT OF CLITAB
           IF ( TIPCLI OF PLTEXOCOM = 99 )
              MOVE "Todos los Tipos de Cliente"
                                     TO DESCLI OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF ( SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESCLI OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 336                  TO CODTAB OF CLITAB
           MOVE CODPRO OF PLTEXOCOM  TO CODINT OF CLITAB
           IF ( CODPRO OF PLTEXOCOM = 99 )
              MOVE "Todos los Tipos de Productos"
                                     TO NOMPRO OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF ( SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO NOMPRO OF W-PANTALLA01
             END-IF
           END-IF

           MOVE BINEXO  OF W-PANTALLA01 TO W-BINEXO-ANT
           MOVE TIPCAJ  OF W-PANTALLA01 TO W-TIPCAJ-ANT
           MOVE TIPCLI  OF W-PANTALLA01 TO W-TIPCLI-ANT
           MOVE CODCON  OF W-PANTALLA01 TO W-CODCON-ANT
           MOVE CODPRO  OF W-PANTALLA01 TO W-CODPRO-ANT
           MOVE CANEXO  OF W-PANTALLA01 TO W-CANEXO-ANT.
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Indicadores-cambio.                   |
      * Descripci¾n   : Se inician los indicadores asociados al       |
      *                 formato de pantalla (PANTALLA01) para         |
      *                 borrar el parametro.                          |
      *----------------------------------------------------------------
      *
       INICIAR-INDICADORES-CAMBIO.
           MOVE ALL B"0"             TO W-AREA-INDICADORES-PANTALLA01
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 01 ).
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 12 ).
           MOVE W-IND-0              TO W-INDICADOR-PANTALLA01 ( 02 ).
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Datos-cambio.                            |
      * Descripci¾n   : Se lee el formato de pantalla "PANTALLA01"    |
      *                 para confirmar el borrado del parametro.      |
      *----------------------------------------------------------------
      *
       LEER-DATOS-CAMBIO.
           MOVE 99                     TO W-FUNCION-UTILIZADA
           PERFORM DISPLAY-AND-READ-PANTALLA01
                   UNTIL ENTER-KEY OR F03 OR F12 OR F04
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-ERROR-VALIDACION
           EVALUATE ( W-FUNCION-UTILIZADA )
             WHEN ( 3 )
               MOVE 1                  TO W-FIN-PANTALLA01
               MOVE 1                  TO W-FIN-RSFLCTL
             WHEN ( 4 )
               PERFORM ATENDER-AYUDA-PANTALLA
             WHEN ( 12 )
               MOVE 1                  TO W-FIN-PANTALLA01
             WHEN ( 0 )
               PERFORM VALIDAR-DATOS-CAMBIO
               IF ( NO-ERROR-VALIDACION )
                 PERFORM REGRABAR-EXONERACION
                 IF ( NO-ERROR-VALIDACION )
                   MOVE 1                TO W-REORGANIZAR-RSFL
                   MOVE 1                TO W-FIN-PANTALLA01
                 END-IF
               END-IF
           END-EVALUATE.
      *
      *-----------------------------------------------------------------
      * Procedimiento : Validar-Datos-Cambio                           |
      * Descripci_n   : Se verifica que los datos CLIMAEL01            |
      *-----------------------------------------------------------------
      *
       VALIDAR-DATOS-CAMBIO.

           IF ( NO-ERROR-VALIDACION )
             IF ( BINEXO OF W-PANTALLA01 = ZEROS )
                 MOVE "Debe Ingresar tipo de BIN"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 04 )
             ELSE
               MOVE 335                    TO CODTAB OF  CLITAB
               MOVE BINEXO OF W-PANTALLA01 TO CODINT OF  CLITAB
               PERFORM LEER-CLITAB
               IF ( NO-EXISTE-CLITAB )
                 MOVE "BIN no Parametrizado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 04 )
               ELSE
                 MOVE CODNOM OF CLITAB TO DESBIN OF W-PANTALLA01
               END-IF
             END-IF
           END-IF

           IF ( NO-ERROR-VALIDACION )
             IF ( TIPCAJ OF W-PANTALLA01 = ZEROS )
                 MOVE "Debe Ingresar tipo de cajero"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 05 )
             ELSE
               MOVE 333                    TO CODTAB OF  CLITAB
               MOVE TIPCAJ OF W-PANTALLA01 TO CODINT OF  CLITAB
               PERFORM LEER-CLITAB
               IF ( NO-EXISTE-CLITAB )
                 MOVE "Tipo de Cajero no Parametrizado"
                                    TO W-MENSAJE
                 MOVE 1             TO W-ERROR-VALIDACION
                 MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 05 )
               ELSE
                 MOVE CODNOM OF CLITAB TO DESCAJ OF W-PANTALLA01
               END-IF
             END-IF
           END-IF


           IF ( NO-ERROR-VALIDACION )
              IF ( TIPCLI OF W-PANTALLA01 = ZEROS )
                  MOVE "Debe ingresar Tipo de Cliente"
                                    TO W-MENSAJE
                  MOVE 1             TO W-ERROR-VALIDACION
                  MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
              ELSE
                MOVE 334                    TO CODTAB OF  CLITAB
                MOVE TIPCLI OF W-PANTALLA01 TO CODINT OF  CLITAB
                PERFORM LEER-CLITAB
                IF ( NO-EXISTE-CLITAB )
                  MOVE "Tipo de Cliente no Parametrizado"
                                    TO W-MENSAJE
                  MOVE 1             TO W-ERROR-VALIDACION
                  MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
                ELSE
                  MOVE CODNOM OF CLITAB TO DESCLI OF W-PANTALLA01
                END-IF
              END-IF
           END-IF

           IF ( NO-ERROR-VALIDACION )
              IF ( TIPCLI OF W-PANTALLA01 = 4 )
                 IF ( CODCON OF W-PANTALLA01 = SPACES )
                    MOVE "Código de convenio debe ser ingresado"
                                       TO W-MENSAJE
                    MOVE 1             TO W-ERROR-VALIDACION
                    MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
                 END-IF
              ELSE
                 IF ( CODCON OF W-PANTALLA01 NOT = SPACES )
                    MOVE "Código de convenio NO debe ser ingresado"
                                       TO W-MENSAJE
                    MOVE 1             TO W-ERROR-VALIDACION
                    MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 06 )
                 END-IF
              END-IF
           END-IF

           IF ( NO-ERROR-VALIDACION )
              IF ( CODPRO OF W-PANTALLA01 = ZEROS )
                  MOVE "Debe ingresar Tipo de Producto"
                                     TO W-MENSAJE
                  MOVE 1             TO W-ERROR-VALIDACION
                  MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 08 )
              ELSE
                MOVE 336                    TO CODTAB OF  CLITAB
                MOVE CODPRO OF W-PANTALLA01 TO CODINT OF  CLITAB
                PERFORM LEER-CLITAB
                IF ( NO-EXISTE-CLITAB )
                  MOVE "Tipo de Producto no Parametrizado"
                                     TO W-MENSAJE
                  MOVE 1             TO W-ERROR-VALIDACION
                  MOVE W-IND-1       TO W-INDICADOR-PANTALLA01 ( 08 )
                ELSE
                  MOVE CODNOM OF CLITAB TO NOMPRO OF W-PANTALLA01
                END-IF
              END-IF
           END-IF

           IF ( NO-ERROR-VALIDACION )
             IF( CANEXO OF W-PANTALLA01 = ZEROS )
              MOVE "Debe Ingresar Cantidad de Transacciones a Exonerar"
                                      TO W-MENSAJE
              MOVE 1                  TO W-ERROR-VALIDACION
              MOVE W-IND-1            TO W-INDICADOR-PANTALLA01 ( 07 )
             END-IF
           END-IF.
      *----------------------------------------------------------------
      * Procedimiento : REGRABAR-EXONERACION.                         |
      * Descripci¾n   : Se actualiza el archivo PLTEXOCOM y el        |
      *                 registro actual del SubFile con los nuevos    |
      *                 datos capturados.                             |
      *----------------------------------------------------------------
      *
       REGRABAR-EXONERACION.
           INITIALIZE W-ACCION
           MOVE W-BINEXO-ANT TO BINEXO  OF PLTEXOCOM
           MOVE W-TIPCAJ-ANT TO TIPCAJ  OF PLTEXOCOM
           MOVE W-TIPCLI-ANT TO TIPCLI  OF PLTEXOCOM
           MOVE W-CANEXO-ANT TO CANEXO  OF PLTEXOCOM
           MOVE W-CODCON-ANT TO CODCON  OF PLTEXOCOM
           MOVE W-CODPRO-ANT TO CODPRO  OF PLTEXOCOM
           PERFORM LEER-PLTEXOCOM-NOLOCK
           IF ( SI-EXISTE-PLTEXOCOM )

             DELETE PLTEXOCOM
             END-DELETE

             MOVE BINEXO  OF W-PANTALLA01 TO BINEXO OF PLTEXOCOM
             MOVE TIPCAJ  OF W-PANTALLA01 TO TIPCAJ OF PLTEXOCOM
             MOVE TIPCLI  OF W-PANTALLA01 TO TIPCLI OF PLTEXOCOM
             MOVE CANEXO  OF W-PANTALLA01 TO CANEXO OF PLTEXOCOM
             MOVE CODCON  OF W-PANTALLA01 TO CODCON OF PLTEXOCOM
             MOVE CODPRO  OF W-PANTALLA01 TO CODPRO OF PLTEXOCOM
             MOVE W-CODCAJ                TO USRMOD OF PLTEXOCOM
             ACCEPT HORMOD OF REGEXOCOM OF PLTEXOCOM FROM TIME
             ACCEPT FECMOD OF REGEXOCOM OF PLTEXOCOM FROM DATE
             WRITE  PLTEXOCOM-REC      INVALID KEY
               MOVE "Error al Regrabar Exoneracion" TO W-MENSAJE
               MOVE 1                  TO W-ERROR-VALIDACION
                                       NOT INVALID KEY
               MOVE "Cambio" TO W-ACCION
               MOVE CORR REGEXOCOM OF PLTEXOCOM
                                   TO REGEXOCOM OF LOGEXOCOM
               PERFORM GRABAR-LOG
             END-WRITE
           END-IF

           IF ( NO-ERROR-VALIDACION )
             MOVE CORR REGEXOCOM OF PLTEXOCOM   TO RSFL-O
             MOVE 0                    TO OPCION OF RSFL-O
             PERFORM INICIAR-INDICADORES-RSFL
             REWRITE SUBFILE PANTALLA-REC FROM RSFL-O
                                          FORMAT "RSFL"
                     INDICATORS W-AREA-INDICADORES-RSFL
             END-REWRITE
           END-IF.
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Campos-Borrado.                       |
      * Descripci¾n   : Se inicializan las variables asociadas al     |
      *                 formato de pantalla "PANTALLA01" para         |
      *                 borrar el parametro.                          |
      *----------------------------------------------------------------
      *
       INICIAR-CAMPOS-BORRADO.
           MOVE  SPACES TO TECFUN OF W-PANTALLA01
                           MENSAJE OF W-PANTALLA01.
           MOVE "Intro=Aceptar   F3=Salir   F12=Anterior"
                                          TO W-TECFUN
           CALL "PLT201"             USING XWCE
                                           XAGEORI , W-CODCAJ ,
                                           W-CODMON, W-NROTRN.
           MOVE "Eliminar Exoneracion Transacciones"
                                          TO W-TITULO
           INITIALIZE W-PANTALLA01
           MOVE CORR REGEXOCOM OF PLTEXOCOM TO W-PANTALLA01

           MOVE 335                 TO CODTAB OF CLITAB
           MOVE BINEXO OF PLTEXOCOM TO CODINT OF CLITAB
           IF ( BINEXO OF PLTEXOCOM = 99 )
             MOVE "Todos los Bines" TO DESBIN OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF (SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESBIN OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 333                 TO CODTAB OF CLITAB
           MOVE TIPCAJ OF PLTEXOCOM TO CODINT OF CLITAB
           IF ( TIPCAJ OF PLTEXOCOM = 99 )
             MOVE "Todos los Cajeros" TO DESCAJ OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF (SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESCAJ OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 334                  TO CODTAB OF CLITAB
           MOVE TIPCLI OF PLTEXOCOM  TO CODINT OF CLITAB
           IF ( TIPCLI OF PLTEXOCOM = 99 )
              MOVE "Todos los Tipos de Cliente"
                                     TO DESCLI OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF ( SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO DESCLI OF W-PANTALLA01
             END-IF
           END-IF

           MOVE 336                  TO CODTAB OF CLITAB
           MOVE CODPRO OF PLTEXOCOM  TO CODINT OF CLITAB
           IF ( CODPRO OF PLTEXOCOM = 99 )
              MOVE "Todos los Tipos de Productos"
                                     TO NOMPRO OF W-PANTALLA01
           ELSE
             PERFORM LEER-CLITAB
             IF ( SI-EXISTE-CLITAB )
               MOVE CODNOM OF CLITAB TO NOMPRO OF W-PANTALLA01
             END-IF
           END-IF
           .
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Indicadores-Borrado.                  |
      * Descripci¾n   : Se inician los indicadores asociados al       |
      *                 formato de pantalla (PANTALLA01) para         |
      *                 borrar el parametro.                          |
      *----------------------------------------------------------------
      *
       INICIAR-INDICADORES-BORRADO.
           MOVE ALL B"0"             TO W-AREA-INDICADORES-PANTALLA01
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 01 ).
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 12 ).
           MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 02 ).
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Datos-Borrado.                           |
      * Descripci¾n   : Se lee el formato de pantalla "PANTALLA01"    |
      *                 para confirmar el borrado del parametro.      |
      *----------------------------------------------------------------
      *
       LEER-DATOS-BORRADO.
           MOVE 99                     TO W-FUNCION-UTILIZADA
           PERFORM DISPLAY-AND-READ-PANTALLA01
                   UNTIL ENTER-KEY OR F03 OR F12
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-ERROR-VALIDACION
           EVALUATE ( W-FUNCION-UTILIZADA )
             WHEN ( 3 )
               MOVE 1                  TO W-FIN-PANTALLA01
               MOVE 1                  TO W-FIN-RSFLCTL
             WHEN ( 12 )
               MOVE 1                  TO W-FIN-PANTALLA01
             WHEN ( 0 )
               PERFORM ELIMINAR-EXONERACION
               IF ( NO-ERROR-VALIDACION )
                 MOVE 1                TO W-REORGANIZAR-RSFL
                 MOVE 1                TO W-FIN-PANTALLA01
               END-IF
           END-EVALUATE.
      *
      *----------------------------------------------------------------
      * Procedimiento : ELIMINAR-EXONERACION                          |
      * Descripci¾n   : Se actualiza el archivo PLTEXOCOM y el        |
      *                 registro actual del SubFile con los nuevos    |
      *                 datos capturados.                             |
      *----------------------------------------------------------------
      *
       ELIMINAR-EXONERACION.
           INITIALIZE W-ACCION
           MOVE CORR W-PANTALLA01   TO REGEXOCOM OF LOGEXOCOM
           PERFORM GRABAR-LOG
           MOVE CORR W-PANTALLA01      TO REGEXOCOM OF PLTEXOCOM
           DELETE  PLTEXOCOM       INVALID KEY
           MOVE "Error al BORRAR la Exoneracion" TO W-MENSAJE
           MOVE 1                  TO W-ERROR-VALIDACION
                                   NOT INVALID KEY
             MOVE "Borrado" TO W-ACCION
             MOVE CORR W-PANTALLA01   TO REGEXOCOM OF LOGEXOCOM
             PERFORM GRABAR-LOG
           END-DELETE.
           IF ( NO-ERROR-VALIDACION )
             MOVE CORR REGEXOCOM OF PLTEXOCOM TO RSFL-O
             MOVE 0                    TO OPCION OF RSFL-O
             PERFORM INICIAR-INDICADORES-RSFL
             REWRITE SUBFILE PANTALLA-REC FROM RSFL-O
                                          FORMAT "RSFL"
                     INDICATORS W-AREA-INDICADORES-RSFL
             END-REWRITE
           END-IF.

      *-----------------------------------------------------------------
      * Procedimiento : ATENDER-AYUDA                                  |
      * Descripcion   : Se escriben y leen los formatos HEADER,        |
      *                 y PANTALLA.                                    |
      *-----------------------------------------------------------------
      *
       ATENDER-AYUDA-PANTALLA.

           IF (RCD OF W-PANTALLA01 = "PANTALLA01" AND
               FLD OF W-PANTALLA01 = "BINEXO" )
                 MOVE 335                         TO T-CODTAB
                 MOVE ZEROS                       TO T-CODINT
                 CALL "CLI921" USING XWCE T-CODTAB T-CODINT
                 IF ( T-CODINT > 0 )
                   MOVE T-CODINT     TO BINEXO OF W-PANTALLA01
                                     CODINT OF CLITAB
                   MOVE 335          TO CODTAB OF CLITAB
                   PERFORM LEER-CLITAB
                   IF ( SI-EXISTE-CLITAB )
                     MOVE CODNOM OF CLITAB TO DESBIN OF W-PANTALLA01
                   END-IF
                 END-IF
           END-IF.

           IF (RCD OF W-PANTALLA01 = "PANTALLA01" AND
               FLD OF W-PANTALLA01 = "TIPCAJ" )
                 MOVE 333                         TO T-CODTAB
                 MOVE ZEROS                       TO T-CODINT
                 CALL "CLI921" USING XWCE T-CODTAB T-CODINT
                 IF ( T-CODINT > 0 )
                   MOVE T-CODINT     TO TIPCAJ OF W-PANTALLA01
                                     CODINT OF CLITAB
                   MOVE 333          TO CODTAB OF CLITAB
                   PERFORM LEER-CLITAB
                   IF ( SI-EXISTE-CLITAB )
                     MOVE CODNOM OF CLITAB TO DESCAJ OF W-PANTALLA01
                   END-IF
                 END-IF
           END-IF.

           IF (RCD OF W-PANTALLA01 = "PANTALLA01" AND
               FLD OF W-PANTALLA01 = "TIPCLI" )
                 MOVE 334                         TO T-CODTAB
                 MOVE ZEROS                       TO T-CODINT
                 CALL "CLI921" USING XWCE T-CODTAB T-CODINT
                 IF ( T-CODINT > 0 )
                   MOVE T-CODINT     TO TIPCLI OF W-PANTALLA01
                                     CODINT OF CLITAB
                   MOVE 334          TO CODTAB OF CLITAB
                   PERFORM LEER-CLITAB
                   IF ( SI-EXISTE-CLITAB )
                     MOVE CODNOM OF CLITAB TO DESCLI OF W-PANTALLA01
                   END-IF
                 END-IF
           END-IF.

           IF (RCD OF W-PANTALLA01 = "PANTALLA01" AND
               FLD OF W-PANTALLA01 = "CODCON" )
                 MOVE SPACES                      TO CNV-NUMCON
                                                     CNV-NOMCON
                                                     CNV-DESCON
                                                     CNV-NOMEMP
                 MOVE ZEROS                       TO CNV-NITEMP
                 CALL "PLTCNV090" USING XWCE
                                        CNV-NUMCON
                                        CNV-NOMCON
                                        CNV-DESCON
                                        CNV-NITEMP
                                        CNV-NOMEMP
                 IF ( CNV-NUMCON NOT = SPACES )
                   MOVE CNV-NUMCON   TO CODCON OF W-PANTALLA01
                 END-IF
           END-IF.

           IF (RCD OF W-PANTALLA01 = "PANTALLA01" AND
               FLD OF W-PANTALLA01 = "CODPRO" )
                 MOVE 336                         TO T-CODTAB
                 MOVE ZEROS                       TO T-CODINT
                 CALL "CLI921" USING XWCE T-CODTAB T-CODINT
                 IF ( T-CODINT > 0 )
                   MOVE T-CODINT     TO CODPRO OF W-PANTALLA01
                                     CODINT OF CLITAB
                   MOVE 336          TO CODTAB OF CLITAB
                   PERFORM LEER-CLITAB
                   IF ( SI-EXISTE-CLITAB )
                     MOVE CODNOM OF CLITAB TO NOMPRO OF W-PANTALLA01
                   END-IF
                 END-IF
           END-IF.

      *----------------------------------------------------------------
      * Procedimiento : Leer-Pltctabco-lock                           |
      * Descripci¾n   : Se lee un registro para actualizar.           |
      *----------------------------------------------------------------
      *
       LEER-PLTEXOCOM-LOCK.
           MOVE 1                      TO W-EXISTE-PLTEXOCOM
           READ PLTEXOCOM              INVALID KEY
                MOVE 0 TO W-EXISTE-PLTEXOCOM
           END-READ.
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Pltctacon-Nolock                         |
      * Descripcion   : Se lee un Servicio para validacion.           |
      *----------------------------------------------------------------
      *
       LEER-PLTEXOCOM-NOLOCK.
           MOVE 1                      TO W-EXISTE-PLTEXOCOM
           READ PLTEXOCOM WITH NO LOCK INVALID KEY
                MOVE 0 TO W-EXISTE-PLTEXOCOM
           END-READ.
      *
      *----------------------------------------------------------------
      * Procedimiento : leer-clitab.                                  |
      * Descripcion   : Se lee el archivo de parámetros generales.    |
      *----------------------------------------------------------------
      *
       LEER-CLITAB.
           MOVE 1                       TO W-EXISTE-CLITAB
           READ CLITAB                  INVALID KEY
                MOVE 0 TO W-EXISTE-CLITAB
           END-READ.
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Pltpargen.                               |
      * Descripcion   : Se lee el archivo de parámetros generales.    |
      *----------------------------------------------------------------
      *
       LEER-PLTPARGEN.
           MOVE XWCE                   TO CODEMP OF REGPARGEN
           READ PLTPARGEN              INVALID KEY
                DISPLAY "Error al leer Parámetros Generales"
                STOP RUN
           END-READ.
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Pltfechas.                               |
      * Descripcion   : Se lee la fecha de proceso.                   |
      *----------------------------------------------------------------
      *
       LEER-PLTFECHAS.
           MOVE 1                      TO W-EXISTE-PLTFECHAS
TYJ        MOVE XWCE                   TO CODEMP OF PLTFECHAS
           READ PLTFECHAS              INVALID KEY
                MOVE 0 TO W-EXISTE-PLTFECHAS
           END-READ.
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Pltpargen.                               |
      * Descripcion   : Se lee el archivo de parámetros generales.    |
      *----------------------------------------------------------------
      *
       LEER-PLTPARGEN.
           MOVE XWCE                   TO CODEMP OF REGPARGEN
           READ PLTPARGEN              INVALID KEY
                DISPLAY "Error al leer Parámetros Generales"
                STOP RUN
           END-READ.
      *
      *----------------------------------------------------------------
      * Procedimiento : GRABAR-LOG.                                   |
      * Descripción   : Se cierran los archivos utilizados.           |
      *----------------------------------------------------------------
      *
       GRABAR-LOG.
           MOVE W-CODCAJ TO USRMOD  OF LOGEXOCOM
           ACCEPT FECMOD OF LOGEXOCOM FROM DATE
           ACCEPT HORMOD OF LOGEXOCOM FROM TIME
           WRITE LOGEXOCOM-REC
           END-WRITE.
      *----------------------------------------------------------------
      * Procedimiento : Finalizar.                                    |
      * Descripción   : Se cierran los archivos utilizados.           |
      *----------------------------------------------------------------
      *
       FINALIZAR.
           CLOSE PLTEXOCOM PLTFECHAS CLIMAEL01 CLITAB
           CLOSE PANTALLA  PLTPARGEN LOGEXOCOM.
