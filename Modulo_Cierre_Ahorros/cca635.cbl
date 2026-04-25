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
       PROGRAM-ID.    CCA635.
       AUTHOR. S.C.T.
       DATE-WRITTEN.  2002/04/18.
      *
      *----------------------------------------------------------------
      *
      * Programa  : CCA635.
      * Aplicacion: Linea.
      * Funcion   : Este programa permite Generar las Cuentas de Ahorro
      *             Activas. Seleccionando por Agencia.
      * Elaborado : S.C.T.
      * Fecha     : 2002/04/18
      *
      *----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
       INPUT-OUTPUT SECTION.
      *----------------------------------------------------------------
       FILE-CONTROL.
           SELECT PLTFECHAS
               ASSIGN          TO DATABASE-PLTFECHAS
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.

           SELECT PLTPARGEN
               ASSIGN          TO DATABASE-PLTPARGEN
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.

           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CAHORROACT
                  ASSIGN               TO DATABASE-CAHORROACT
                  ORGANIZATION         IS SEQUENTIAL
                  ACCESS MODE          IS SEQUENTIAL.
      *

           SELECT CLIMAEL01
               ASSIGN          TO DATABASE-CLIMAEL01
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.

           SELECT PANTALLA
               ASSIGN          TO WORKSTATION-CCA635S-SI
               ORGANIZATION    IS TRANSACTION
               ACCESS          IS SEQUENTIAL
               CONTROL-AREA    IS W-CONTROL-PANTALLA
               FILE STATUS     IS W-PANTALLA-STATUS.

           SELECT PLTAGCORI
               ASSIGN          TO DATABASE-PLTAGCORI
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CLITAB
                  ASSIGN               TO DATABASE-CLITAB
                  ORGANIZATION         IS INDEXED
                  ACCESS MODE          IS DYNAMIC
                  RECORD KEY           IS EXTERNALLY-DESCRIBED-KEY.
      *
      *----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF  PLTAGCORI.

       FD  PLTPARGEN
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTPARGEN.
           COPY DDS-ALL-FORMATS OF  PLTPARGEN.

       FD  PLTFECHAS
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTFECHAS.
           COPY DDS-ALL-FORMATS OF  PLTFECHAS.
      *
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  CCAMAEAHO-REC.
           COPY DD-ALL-FORMATS         OF CCAMAEAHO.
      *
       FD  CAHORROACT
           LABEL RECORDS ARE OMITTED.

       01  REGISTRO            PICTURE IS X(150).
      *
       FD  CLIMAEL01
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CLIMAEL01.
           COPY DDS-ALL-FORMATS OF  CLIMAEL01.

       FD  PANTALLA
           LABEL RECORDS               ARE OMITTED.
       01  PANTALLA-REC.
           COPY DD-ALL-FORMATS         OF CCA635S.
      *
       FD  CLITAB
           LABEL RECORDS               ARE STANDARD.
       01  CLITAB-REC.
           COPY DD-ALL-FORMATS         OF CLITAB.
      *
      *----------------------------------------------------------------
       WORKING-STORAGE SECTION.
      *----------------------------------------------------------------
      *Area de Control de la Estacion de Pantalla.
       01  W-CONTROL-PANTALLA.
           03  W-FUNCIONES-UTILIZADAS.
               05  W-FUNCION-UTILIZADA PIC 9(02).
                   88  F01                            VALUE 01.         LVW   LS
                   88  F02                            VALUE 02.         LVW   LS
                   88  F03                            VALUE 03.         LVW   LS
                   88  F04                            VALUE 04.         LVW   LS
                   88  F05                            VALUE 05.         LVW   LS
                   88  F06                            VALUE 06.         LVW   LS
                   88  F07                            VALUE 07.         LVW   LS
                   88  F08                            VALUE 08.         LVW   LS
                   88  F09                            VALUE 09.         LVW   LS
                   88  F10                            VALUE 10.         LVW   LS
                   88  F11                            VALUE 11.         LVW   LS
                   88  F12                            VALUE 12.         LVW   LS
                   88  F13                            VALUE 13.         LVW   LS
                   88  F14                            VALUE 14.         LVW   LS
                   88  F15                            VALUE 15.         LVW   LS
                   88  F16                            VALUE 16.         LVW   LS
                   88  F17                            VALUE 17.         LVW   LS
                   88  F18                            VALUE 18.         LVW   LS
                   88  F19                            VALUE 19.         LVW   LS
                   88  F20                            VALUE 20.         LVW   LS
                   88  F21                            VALUE 21.         LVW   LS
                   88  F22                            VALUE 22.         LVW   LS
                   88  F23                            VALUE 23.         LVW   LS
                   88  F24                            VALUE 24.         LVW   LS
                   88  ROLLDOWN                       VALUE 90.
                   88  ROLLUP                         VALUE 91.
                   88  ENTER-KEY                      VALUE 00.         LVW   LS
           03  W-NOMBRE-DEVICE         PIC X(10).
           03  W-NOMBRE-FORMATO        PIC X(10).
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

      *Llave relativa para el SubArchivo PLT114S.
       01  W-SBF-CLAVE                 PIC 9(05)     COMP-3 VALUE 0.
       01  W-SBF-CLAVE-TMP             PIC 9(05)     COMP-3 VALUE 0.
      *
      *----------------------------------------------------------------
      * Declaracion de Variables Temporales                           |
      *----------------------------------------------------------------
      *
      *Utilizadas para la inicializacion de indicadores de pantalla.
       01  W-IND-0                     PIC 1          VALUE B"0".
       01  W-IND-1                     PIC 1          VALUE B"1".
      *Utilizada para presentar mensajes de error.
       01  W-MENSAJE                   PIC X(60)      VALUE SPACES.
      *Indica si se presento un error de validacion en algun formato
      *de pantalla.
       01  W-ERROR-VALIDACION          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-ERROR-VALIDACION                    VALUE 0.
           88  SI-ERROR-VALIDACION                    VALUE 1.
      *Variable para control acceso directo del Archivo CLITAB
       01  W-EXISTE-CLITAB             PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-CLITAB                       VALUE 0.
           88  SI-EXISTE-CLITAB                       VALUE 1.
      *Utilizada para presentar las teclas de funcion activas
       01  W-TECFUN                    PIC X(78)      VALUE SPACES.
      *Contiene las variables ingresadas en Pantalla01.
      *Utilizada para validación de fechas.
       01  W-FECHA                     PIC 9(08)             VALUE 0.
       01  FILLER                      REDEFINES W-FECHA.
           03  W-FECAA                 PIC 9(04).
           03  W-FECMM                 PIC 9(02).
           03  W-FECDD                 PIC 9(02).
       01  W-PANTALLA01.
           03  NOMEMP                  PIC X(22).
           03  FECSIS                  PIC S9(8).
           03  FECPRO                  PIC S9(8).
           03  FECHAD                  PIC S9(8).
           03  FECHAH                  PIC S9(8).
           03  AGCCTA                  PIC S9(5).
           03  NOMAGC                  PIC X(27).
           03  TECFUN                  PIC X(53).
           03  MENSAJE                 PIC X(53).
           03  RCD                     PIC X(10).
           03  FLD                     PIC X(10).
           03  POS                     PIC S9(04).
       01  CONTROLES.
           05  CTR-PLTCHESL05    PIC X(02) VALUE "NO".
               88  FIN-PLTCHESL05          VALUE "SI".
               88  NO-FIN-PLTCHESL05       VALUE "NO".
      *Control Interaccion Formato de Pantalla "PANTALLA01"
       01  W-FIN-PANTALLA01-1          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-PANTALLA01-1                    VALUE 0.
           88  SI-FIN-PANTALLA01-1                    VALUE 1.
      *Control Interaccion Formato de Pantalla "PANTALLA01"
       01  W-FIN-PANTALLA01-2          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-PANTALLA01-2                    VALUE 0.
           88  SI-FIN-PANTALLA01-2                    VALUE 1.
      *Control Interaccion Formato de Pantalla "PANTALLA01"
       01  W-FIN-PANTALLA01-3          PIC S9(01)     COMP-3 VALUE 0.
           88  NO-FIN-PANTALLA01-3                    VALUE 0.
           88  SI-FIN-PANTALLA01-3                    VALUE 1.
       01  W-TECSAL                    PIC 9(03).
       01  XY-CODMON                   PIC 9(03).
       01  W-AGCCTA                    PIC 9(05).
       01  W-NUMAGC                    PIC 9(05).
       01  W-TIPCHQ                    PIC 9(05).
       01  C-CTA-CA                    PIC 9(04)  VALUE ZEROS.
       01  C-CTA-SA                    PIC 9(04)  VALUE ZEROS.
       01  CONT-LINEA                  PIC 9(02)  VALUE ZEROS.
       01  W-CUENTA                    PIC 9(12).
       01  W-CUENTA-R    REDEFINES     W-CUENTA.
           03 W-AGE                    PIC 9(04).
           03 W-CTA                    PIC 9(06).
           03 W-PRO                    PIC 9(02).
       01  W-FECHA-INI                 PIC X(02)  VALUE "NO".
           88  NO-FECHA-INI                       VALUE "NO".
           88  SI-FECHA-INI                       VALUE "SI".
       01  W-FECHA-FIN                 PIC X(02)  VALUE "NO".
           88  NO-FECHA-FIN                       VALUE "NO".
           88  SI-FECHA-FIN                       VALUE "SI".
       01  W-AGCCTA-E                  PIC XX     VALUE "NO".
           88  TODAS-AGCCTA                       VALUE "SI".
           88  NO-TODAS-AGCCTA                    VALUE "NO".
       01  CONTROLES.
           05  CTL-R-PLTFECHAS          PIC X(02) VALUE "NO".
               88  R-PLTFECHAS          VALUE "SI".
               88  NO-R-PLTFECHAS       VALUE "NO".
           05  CTL-PLTAGCORI            PIC XX    VALUE "NO".
               88  FIN-PLTAGCORI        VALUE "SI".
               88  NO-FIN-PLTAGCORI     VALUE "NO".
           05  CTL-PLTAGCORI-X          PIC XX    VALUE "NO".
               88  FIN-PLTAGCORIX       VALUE "SI".
               88  NO-FIN-PLTAGCORIX    VALUE "NO".
      *Variable para control del archivo de CCAMAEAHO.
       01  W-EXISTE-CCAMAEAHO          PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-CCAMAEAHO                   VALUE 0.
           88  SI-EXISTE-CCAMAEAHO                   VALUE 1.
      *----------------------------------------------------------------
      *Variable para control del archivo de CLIMAEL01.
       01  W-EXISTE-CLIMAEL01          PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-CLIMAEL01                   VALUE 0.
           88  SI-EXISTE-CLIMAEL01                   VALUE 1.
      *----------------------------------------------------------------
      *Fecha en formato AAAAMMDD sobre la cual se realizan las
      *operaciones definidas por el parámetro Z-FECHA1.
       01  Z-FECHA1                    PIC 9(08).
       01  FILLER                      REDEFINES Z-FECHA1.
           03  Z-FEC1AA                PIC 9(04).
           03  Z-FEC1MM                PIC 9(02).
           03  Z-FEC1DD                PIC 9(02).
      *Fecha en formato AAAAMMDD utilizada cuando el tipo de operación
      *es el de hallar la diferencia en días entre Z-FECHA1 y Z-FECHA2
       01  Z-FECHA2                    PIC 9(08).
       01  FILLER                      REDEFINES Z-FECHA2.
           03  Z-FEC2AA                PIC 9(04).
           03  Z-FEC2MM                PIC 9(02).
           03  Z-FEC2DD                PIC 9(02).
      *Fecha Resultado en formato AAAAMMDD.
       01  Z-FECHA3                    PIC 9(08).
       01  FILLER                      REDEFINES Z-FECHA3.
           03  Z-FEC31AA               PIC 9(04).
           03  Z-FEC31MM               PIC 9(02).
           03  Z-FEC31DD               PIC 9(02).
       01  FILLER                      REDEFINES Z-FECHA3.
           03  Z-FEC32DD               PIC 9(02).
           03  Z-FEC32MM               PIC 9(02).
           03  Z-FEC32AA               PIC 9(04).
       01  FILLER                      REDEFINES Z-FECHA3.
           03  Z-FEC33MM               PIC 9(02).
           03  Z-FEC33DD               PIC 9(02).
           03  Z-FEC33AA               PIC 9(04).
      *Tipo de Formato de la Fecha de Salida.
      *  1 = AAAAMMDD
      *  2 = DDMMAAAA
      *  3 = MMDDAAAA
       01  Z-TIPFMT                    PIC 9(01).
      *Base 360 o 365 para cálculo sobre fechas.
      *  1 = 360
      *  2 = 365
       01  Z-BASCLC                    PIC 9(01).
      *Número de Días para desplazamiento o retroceso.
       01  Z-NRODIA                    PIC 9(05).
      *Indicativo de Desplazamiento o Retroceso.
      *  1 = Desplazamiento
      *  2 = Retroceso
       01  Z-INDDSP                    PIC 9(01).
      *Día de la semana relacionado con la Fecha 3.
       01  Z-DIASEM                    PIC 9(01).
      *Nombre del Día de la Semana anterior.
       01  Z-NOMDIA                    PIC X(10).
      *Nombre del Mes Asociado.
       01  Z-NOMMES                    PIC X(10).
      *Código de Retorno para la Validación.
       01  Z-CODRET                    PIC 9(01).
      *Mensaje de Validación.
       01  Z-MSGERR                    PIC X(40).
      *Tipo de Operación que se debe realizar.
      *  1 = Validación de la Fecha L-FECHA1 en formato AAAAMMDD
      *  2 = Calcula Fecha Hacia Adelante/Atras día no hábil
      *  3 = Calcula Fecha Hacia Adelante/Atras día hábil
      *  6 = Retornar Fecha del Sistema en Formato AAAAMMDD
       01  Z-TIPOPR                    PIC 9(01).
      *----------------------------------------------------------------
       01 W-SALDO               PIC S9(13)V99.
       01 WS-TABLA.
          03 WS-ITEMS OCCURS 20 TIMES.
             05 TAB-MDA         PIC 99.
             05 TAB-NOM-MDA     PIC X(10).
             05 TAB-VLR1        PIC S9(13)V99.
             05 TAB-VLR2        PIC S9(13)V99.
             05 TAB-VLR3        PIC S9(13)V99.
             05 TAB-VLR4        PIC S9(13)V99.
             05 TAB-VLR5        PIC S9(13)V99.
             05 TAB-VLR6        PIC S9(13)V99.
             05 TAB-VLR7        PIC S9(13)V99.
             05 TAB-VLR8        PIC S9(13)V99.
       01  PA-CODEMP            PIC 9(05)    VALUE ZEROS.
      *----------------------------------------------------------------
           COPY EXTRACT OF PLTCBL.
      *----------------------------------------------------------------
       LINKAGE SECTION.
      *----------------------------------------------------------------
       77  XAGEORI              PIC 9(05).
       77  W-CODCAJ             PIC X(10).
      *----------------------------------------------------------------
       PROCEDURE DIVISION USING XAGEORI  , W-CODCAJ  .
      *----------------------------------------------------------------
       INICIAR-PROGRAMA.
           PERFORM INICIALIZAR                  .
           PERFORM LEER-DATOS-SELECCION
                                       UNTIL ( SI-FIN-PANTALLA01-1 ).
           PERFORM FINALIZAR                    .
      *----------------------------------------------------------------
       INICIALIZAR.
           OPEN INPUT CLITAB
           MOVE 901                  TO CODTAB OF REGTABMAE
           MOVE 1                    TO CODINT OF REGTABMAE
           PERFORM LEER-CLITAB
           IF ( NO-EXISTE-CLITAB )
              DISPLAY "NO existe NIT de la empresa"
              CLOSE CLITAB
              STOP RUN
           END-IF
           OPEN I-O    PANTALLA
           OPEN INPUT  CCAMAEAHO
           OPEN INPUT  CLIMAEL01
           OPEN INPUT  PLTAGCORI
           OPEN INPUT  PLTPARGEN
           OPEN EXTEND CAHORROACT
           OPEN INPUT  PLTFECHAS
           CALL "PLTCODEMPP"      USING PA-CODEMP
           PERFORM LEA-FECHA
           PERFORM LEA-BANCO
           MOVE SPACES                 TO W-MENSAJE
           PERFORM INICIAR-CAMPOS-CAPTURA
           PERFORM INICIAR-INDICADORES-CAPTURA
           MOVE 0                      TO W-FIN-PANTALLA01-1.

       LEER-DATOS-SELECCION.
           MOVE 99                     TO W-FUNCION-UTILIZADA
           PERFORM DISPLAY-AND-READ-PANTALLA01 UNTIL ENTER-KEY OR F03
                                                     OR F04
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-ERROR-VALIDACION
           PERFORM INICIAR-INDICADORES-CAPTURA
           EVALUATE ( W-FUNCION-UTILIZADA )
             WHEN ( 3 )
               MOVE 1                  TO W-FIN-PANTALLA01-1
             WHEN ( 4 )
               PERFORM ATENDER-AYUDA
                IF ( W-TECSAL = 3 )
                  MOVE 1               TO W-FIN-PANTALLA01-1
                END-IF
             WHEN ( 0 )
               PERFORM VALIDAR-DATOS
               IF ( NO-ERROR-VALIDACION )
                 PERFORM CONFIRMAR-REPORTE
               END-IF
           END-EVALUATE.
      *
       CONFIRMAR-REPORTE.
           MOVE SPACES                 TO W-MENSAJE
           MOVE "Teclee Intro para confirmar Generación de Archivo"
                                       TO W-MENSAJE
           MOVE 0                      TO W-FIN-PANTALLA01-3
           PERFORM INICIAR-CAMPOS-CONFIRMACION
           PERFORM INICIAR-INDIC-CONFIRMACION
           PERFORM LEER-DATOS-CONFIRMACION UNTIL
                                       ( SI-FIN-PANTALLA01-1 ) OR
                                       ( SI-FIN-PANTALLA01-3 )
           IF ( NO-FIN-PANTALLA01-1 )
             MOVE "Intro=Aceptar   F3=Salir   F12=Cancelar"
                                       TO W-TECFUN
             PERFORM INICIAR-CAMPOS-CAPTURA
             PERFORM INICIAR-INDICADORES-CAPTURA
           END-IF.
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Campos-Captura.                       |
      * Descripcion   : Se inicializan las variables asociadas al     |
      *                 formato de pantalla "PANTALLA01".             |
      *----------------------------------------------------------------
      *
       INICIAR-CAMPOS-CAPTURA.
           INITIALIZE W-PANTALLA01
           MOVE XAGEORI                TO AGCCTA  OF W-PANTALLA01
           MOVE "Intro=Aceptar   F3=Salir   F4=Ayuda"
                                       TO W-TECFUN.
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Indicadores-Captura.                  |
      * Descripcion   : Se inician los indicadores asociados al       |
      *                 formato de pantalla (FMT001).                 |
      *----------------------------------------------------------------
      *
       INICIAR-INDICADORES-CAPTURA.
           MOVE ALL B"0"              TO W-AREA-INDICADORES-PANTALLA01
           MOVE W-IND-1               TO W-INDICADOR-PANTALLA01 ( 06 ).
      *
      *
      *
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Campos-Confirmacion.                  |
      * Descripcion   : Se inicializan las variables asociadas al     |
      *                 formato de pantalla "PANTALLA01".             |
      *----------------------------------------------------------------
      *
       INICIAR-CAMPOS-CONFIRMACION.
           MOVE "Intro=Aceptar   F3=Salir   F12=Cancelar"
                                       TO W-TECFUN.
      *----------------------------------------------------------------
      * Procedimiento : Iniciar-Indicadores-Confirmacion.             |
      * Descripcion   : Se inician los indicadores asociados al       |
      *                 formato de pantalla (PANTALLA01).             |
      *----------------------------------------------------------------
      *
       INICIAR-INDIC-CONFIRMACION.
           MOVE ALL B"0"              TO W-AREA-INDICADORES-PANTALLA01
           MOVE W-IND-1               TO W-INDICADOR-PANTALLA01 ( 01 )
           MOVE W-IND-1               TO W-INDICADOR-PANTALLA01 ( 05 )
           MOVE W-IND-1               TO W-INDICADOR-PANTALLA01 ( 06 ).
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-Datos-Confirmacion.                      |
      * Descripcion   : Se lee el formato de pantalla "PANTALLA01"    |
      *                 para confirmar la reposicion.                 |
      *----------------------------------------------------------------
      *
       LEER-DATOS-CONFIRMACION.
           MOVE 99                     TO W-FUNCION-UTILIZADA
           PERFORM DISPLAY-AND-READ-PANTALLA01 UNTIL ENTER-KEY OR F03
                                                  OR F12
           MOVE SPACES                 TO W-MENSAJE
           MOVE 0                      TO W-ERROR-VALIDACION
           PERFORM INICIAR-INDIC-CONFIRMACION
           EVALUATE ( W-FUNCION-UTILIZADA )
             WHEN ( 3 )
               MOVE 1                  TO W-FIN-PANTALLA01-1
               MOVE 1                  TO W-FIN-PANTALLA01-3
             WHEN ( 12 )
               MOVE 1                  TO W-FIN-PANTALLA01-3
             WHEN ( 0 )
               IF ( NO-ERROR-VALIDACION )
                 PERFORM PROCESA-CCAMAEAHO
                 IF ( NO-ERROR-VALIDACION )
                   MOVE "Transacción Satisfactoria."
                                       TO W-MENSAJE
                   MOVE 1              TO W-FIN-PANTALLA01-1
                   MOVE 1              TO W-FIN-PANTALLA01-3
                   PERFORM INICIAR-CAMPOS-CAPTURA
                   PERFORM INICIAR-INDICADORES-CAPTURA
                 END-IF
               END-IF
           END-EVALUATE.

       FINALIZAR.
           CLOSE PANTALLA CCAMAEAHO PLTAGCORI PLTFECHAS
           CLOSE PLTPARGEN CLITAB CLIMAEL01 CAHORROACT
           GOBACK.

       ATENDER-AYUDA.
           IF ( RCD OF W-PANTALLA01 = "PANTALLA01" AND
                FLD OF W-PANTALLA01 = "AGCCTA" )
             MOVE AGCCTA OF W-PANTALLA01 TO W-NUMAGC
             CALL "PLT920"             USING PA-CODEMP W-NUMAGC
             IF ( W-NUMAGC > 0 )
               MOVE W-NUMAGC           TO AGCCTA OF W-PANTALLA01
             END-IF
             MOVE W-IND-1              TO W-INDICADOR-PANTALLA01 ( 02 )
           END-IF.
      *----------------------------------------------------------------
       LEA-FECHA.
           MOVE 5     TO CODSIS OF REGFECHAS
           MOVE PA-CODEMP    TO CODEMP OF REGFECHAS
           MOVE "SI"  TO CTL-R-PLTFECHAS
           READ PLTFECHAS
                INVALID KEY MOVE "NO" TO CTL-R-PLTFECHAS
           END-READ
           IF ( NO-R-PLTFECHAS )
             DISPLAY "No Existe Fecha de Proceso. Llamar a Sistemas"
             PERFORM FINALIZAR
           END-IF.
      *    MOVE FECPRO OF REGFECHAS    TO FECHA-I   .
      *----------------------------------------------------------------
       LEA-BANCO.
      *    MOVE  1                     TO CODPAR OF REGPARGEN
           MOVE PA-CODEMP             TO CODEMP OF PLTPARGEN
           READ PLTPARGEN              INVALID KEY
             DISPLAY "No Existe Parametro General. Llamar a Sistemas"
             PERFORM FINALIZAR
           END-READ.
      *    MOVE NOMBAN OF REGPARGEN    TO NOMBAN-I      .
      * ----------------------------------------------------------------
       VALIDAR-DATOS.
           MOVE W-IND-0             TO W-INDICADOR-PANTALLA01 ( 02 )
           MOVE W-IND-0             TO W-INDICADOR-PANTALLA01 ( 03 )
           MOVE 0                         TO W-ERROR-VALIDACION
      *    IF ( FECHAD OF W-PANTALLA01 = ZEROS )
      *       MOVE "Debe Ingresar Fecha Desde" TO W-MENSAJE
      *       MOVE 1                           TO W-ERROR-VALIDACION
      *       MOVE W-IND-1             TO W-INDICADOR-PANTALLA01 ( 02 )
      *    ELSE
      *       MOVE FECHAD OF W-PANTALLA01 TO Z-FECHA1
      *       MOVE FECHAD OF W-PANTALLA01 TO Z-FECHA2
      *       PERFORM VALIDA-FECHA
      *       IF ( FECHAD OF W-PANTALLA01 > FECPRO OF W-PANTALLA01) AND
      *          ( W-MENSAJE = SPACES )
      *        MOVE "Fecha Desde mayor a fecha de proceso" TO W-MENSAJE
      *        MOVE 1                  TO W-ERROR-VALIDACION
      *       END-IF
      *       IF ( FECHAD OF W-PANTALLA01 > FECHAH OF W-PANTALLA01) AND
      *          ( W-MENSAJE = SPACES )
      *        MOVE "Fecha Desde Debe Ser Menor que Hasta" TO W-MENSAJE
      *        MOVE 1                  TO W-ERROR-VALIDACION
      *       END-IF
      *       IF  W-MENSAJE  NOT = SPACES
      *            MOVE W-IND-1     TO W-INDICADOR-PANTALLA01 ( 02 )
      *       END-IF
      *    END-IF
      *    IF ( FECHAH OF W-PANTALLA01 = ZEROS )  AND
      *          ( W-MENSAJE = SPACES )
      *       MOVE "Debe Ingresar Fecha Hasta" TO W-MENSAJE
      *       MOVE 1                           TO W-ERROR-VALIDACION
      *       MOVE W-IND-1             TO W-INDICADOR-PANTALLA01 ( 03 )
      *    ELSE
      *       MOVE FECHAH OF W-PANTALLA01 TO Z-FECHA1
      *       MOVE FECHAH OF W-PANTALLA01 TO Z-FECHA2
      *       PERFORM VALIDA-FECHA
      *       IF ( FECHAH OF W-PANTALLA01 > FECPRO OF W-PANTALLA01) AND
      *          ( W-MENSAJE = SPACES )
      *        MOVE "Fecha Hasta Mayor a fecha de proceso" TO W-MENSAJE
      *        MOVE 1                  TO W-ERROR-VALIDACION
      *       END-IF
      *       IF ( FECHAH OF W-PANTALLA01 < FECHAD OF W-PANTALLA01) AND
      *          ( W-MENSAJE = SPACES )
      *        MOVE "Fecha Hasta Debe Ser Mayor que Desde" TO W-MENSAJE
      *        MOVE 1                  TO W-ERROR-VALIDACION
      *       END-IF
      *       IF  W-MENSAJE  NOT = SPACES
      *            MOVE W-IND-1     TO W-INDICADOR-PANTALLA01 ( 03 )
      *       END-IF
      *    END-IF
           IF ( AGCCTA OF W-PANTALLA01 = ZEROS )
              MOVE "Todas las <Agencias>"  TO NOMAGC OF W-PANTALLA01
              MOVE "SI" TO W-AGCCTA-E
           ELSE
              MOVE AGCCTA OF W-PANTALLA01 TO W-AGCCTA
              PERFORM LEER-AGENCIA
              MOVE ZERO   TO W-AGCCTA
           END-IF.

       DISPLAY-AND-READ-PANTALLA01.
           MOVE FECPRO OF REGFECHAS    TO FECPRO   OF W-PANTALLA01
           CALL "EXTRACT" USING W-DA EX-DATE.
           MOVE EX-DATE-8              TO W-FECHA
           MOVE NOMBAN OF REGPARGEN    TO NOMEMP   OF W-PANTALLA01
           MOVE W-FECHA                TO FECSIS   OF W-PANTALLA01
           MOVE W-TECFUN               TO TECFUN   OF W-PANTALLA01
           MOVE W-MENSAJE              TO MENSAJE  OF W-PANTALLA01
           MOVE CORR W-PANTALLA01      TO PANTALLA01-O
           WRITE PANTALLA-REC          FORMAT IS "PANTALLA01" INDICATOR
                                       W-AREA-INDICADORES-PANTALLA01.
           READ  PANTALLA              FORMAT IS "PANTALLA01" INDICATOR
                                       W-AREA-INDICADORES-RTA
           END-READ.
           MOVE CORR PANTALLA01-I      TO W-PANTALLA01.
      *
      *----------------------------------------------------------------
      * Procedimiento : Atender-Ayuda.                                |
      * Descripcion   : Se llama las rutinas de ayuda para impuestos  |
      *                 o terceros.                                   |
      *----------------------------------------------------------------
      *
       PROCESA-CCAMAEAHO.
           MOVE  ZEROS   TO  C-CTA-CA C-CTA-SA
           INITIALIZE CCAMAEAHO-REC
           MOVE 1                      TO W-EXISTE-CCAMAEAHO
           MOVE AGCCTA OF W-PANTALLA01 TO AGCCTA OF CCAMAEAHO
           START CCAMAEAHO  KEY NOT <  EXTERNALLY-DESCRIBED-KEY
                             INVALID KEY
                                       MOVE 0 TO W-EXISTE-CCAMAEAHO
           END-START
           READ CCAMAEAHO   NEXT AT END
                                MOVE 0 TO W-EXISTE-CCAMAEAHO
           END-READ
           IF SI-EXISTE-CCAMAEAHO
                  MOVE  AGCCTA OF CCAMAEAHO    TO W-AGCCTA
                  PERFORM PROCESA-DATOS UNTIL  W-EXISTE-CCAMAEAHO = 0
           END-IF.
      *--------------------------------------------------------------
       PROCESA-DATOS.
           IF SI-EXISTE-CCAMAEAHO
              PERFORM IMPRIMIR-DATOS
              PERFORM LEER-CCAMAEAHO.
      *----------------------------------------------------------------
      *PROCESA-DATOS1.
      *    IF SI-EXISTE-CCAMAEAHO
      *       IF FECHAD OF W-PANTALLA01   > 0
      *          IF FAPERT OF CCAMAEAHO-REC   <  FECHAD OF W-PANTALLA01
      *             MOVE "NO" TO W-FECHA-INI
      *             PERFORM LEER-CCAMAEAHO
      *          ELSE
      *             MOVE "SI" TO W-FECHA-INI
      *          END-IF
      *       END-IF
      *       IF SI-FECHA-INI
      *          IF FECHAH OF W-PANTALLA01   > 0
      *             IF FAPERT OF CCAMAEAHO-REC   >
      *                                       FECHAH OF W-PANTALLA01
      *                MOVE "NO" TO W-FECHA-FIN
      *                PERFORM LEER-CCAMAEAHO
      *             ELSE
      *                MOVE "SI" TO W-FECHA-FIN
      *             END-IF
      *          END-IF
      *       END-IF
      *       IF SI-FECHA-INI AND SI-FECHA-FIN
      *          MOVE  "NO" TO  W-FECHA-INI W-FECHA-FIN
      *          PERFORM IMPRIMIR-DATOS
      *          PERFORM LEER-CCAMAEAHO
      *       END-IF
      *    END-IF.

       IMPRIMIR-DATOS.
      *    IF ( FAPERT OF CCAMAEAHO >  ZEROS ) AND
      *       ( INDBAJ OF CCAMAEAHO NOT =  1 )
           IF ( INDBAJ OF CCAMAEAHO NOT =  1 )
               IF  NO-TODAS-AGCCTA
                   IF AGCCTA OF W-PANTALLA01 NOT = AGCCTA OF CCAMAEAHO
                      PERFORM LEER-CCAMAEAHO
                      GO TO PROCESA-DATOS
                   END-IF
               END-IF
               IF AGCCTA OF CCAMAEAHO   NOT = W-AGCCTA
                   MOVE  AGCCTA OF CCAMAEAHO    TO W-AGCCTA
               END-IF
               MOVE AGCCTA OF REGMAEAHO TO W-AGE
               MOVE CTANRO OF REGMAEAHO TO W-CTA
               MOVE CODPRO OF REGMAEAHO TO W-PRO
               MOVE W-CUENTA            TO REGISTRO
               WRITE REGISTRO
           END-IF.
      *----------------------------------------------------------------
       VALIDA-FECHA.
           IF ( NO-ERROR-VALIDACION )
             MOVE ZEROS                  TO Z-FECHA3
             MOVE 1                      TO Z-TIPFMT
             MOVE 1                      TO Z-BASCLC
             MOVE ZEROS                  TO Z-NRODIA
             MOVE 1                      TO Z-INDDSP
             MOVE ZEROS                  TO Z-DIASEM
             MOVE SPACES                 TO Z-NOMDIA
             MOVE SPACES                 TO Z-NOMMES
             MOVE ZEROS                  TO Z-CODRET
             MOVE SPACES                 TO Z-MSGERR
             MOVE 1                      TO Z-TIPOPR
             CALL "PLT219" USING PA-CODEMP ,
                                Z-FECHA1 ,
                                Z-FECHA2 ,
                                Z-FECHA3 ,
                                Z-TIPFMT ,
                                Z-BASCLC ,
                                Z-NRODIA ,
                                Z-INDDSP ,
                                Z-DIASEM ,
                                Z-NOMDIA ,
                                Z-NOMMES ,
                                Z-CODRET ,
                                Z-MSGERR ,
                                Z-TIPOPR
             IF ( Z-CODRET EQUAL TO ZERO )
               NEXT SENTENCE
             ELSE
               MOVE Z-MSGERR
                                   TO W-MENSAJE
               MOVE 1              TO W-ERROR-VALIDACION
               MOVE W-IND-1        TO W-INDICADOR-PANTALLA01 ( 03 )
             END-IF
           END-IF.
      * ----------------------------------------------------------------

       LEA-AGENCIA.
           MOVE W-AGCCTA              TO AGCORI OF REGAGCORI
           MOVE PA-CODEMP             TO CODEMP OF REGAGCORI
           PERFORM LEER-PLTAGCORI.
      *    IF  CTL-PLTAGCORI-X    = "NO"
      *        MOVE "Agencia Invalida "    TO NOM-AGE-I
      *    ELSE
      *        MOVE AGCORI OF REGAGCORI    TO COD-AGE-I
      *        MOVE NOMAGC OF REGAGCORI    TO NOM-AGE-I
      *    END-IF.
      *----------------------------------------------------------------

       LEER-AGENCIA.
           MOVE W-AGCCTA               TO AGCORI OF REGAGCORI
           MOVE PA-CODEMP             TO CODEMP OF REGAGCORI
           PERFORM LEER-PLTAGCORI
           IF  CTL-PLTAGCORI-X    = "NO"
             MOVE "Agencia Invalida " TO NOMAGC OF W-PANTALLA01
            ELSE
             MOVE NOMAGC OF REGAGCORI    TO NOMAGC OF W-PANTALLA01
      *      MOVE AGCORI OF REGAGCORI    TO COD-AGE-I
      *      MOVE NOMAGC OF REGAGCORI    TO NOM-AGE-I
           END-IF.
      *
      *----------------------------------------------------------------
      * Procedimiento : Leer-CLITAB                                   |
      * Descripcion   : Se lee el archivo de parámetros generales.    |
      *----------------------------------------------------------------
      *
       LEER-CLITAB.
           MOVE 1                      TO W-EXISTE-CLITAB
           READ CLITAB                 INVALID KEY
                MOVE 0                 TO W-EXISTE-CLITAB
           END-READ.
      *----------------------------------------------------------------
      * Procedimiento : Leer-CLIMAEL01                                |
      * Descripcion   : Se lee el archivo de Clientes                 |
      *----------------------------------------------------------------
      *
       LEER-CLIMAEL01.
           MOVE 1                      TO W-EXISTE-CLIMAEL01
           READ CLIMAEL01              INVALID KEY
                MOVE 0                 TO W-EXISTE-CLIMAEL01
           END-READ.
      *---------------------------------------------------------------
       LEER-PLTAGCORI.
           MOVE "SI"           TO CTL-PLTAGCORI-X
           MOVE PA-CODEMP              TO CODEMP OF PLTAGCORI
           READ PLTAGCORI   INVALID KEY MOVE "NO" TO CTL-PLTAGCORI-X.

      *---------------------------------------------------------------
       LEER-CCAMAEAHO.
           READ CCAMAEAHO   NEXT AT END
                                MOVE 0 TO W-EXISTE-CCAMAEAHO
           END-READ.
      *---------------------------------------------------------------
