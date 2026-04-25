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
       PROGRAM-ID.    CCA720.
       AUTHOR.        MMD.
       DATE-WRITTEN.  97/09/25.
      *--------------------------------------------------------------*
      * FUNCION: ACTUALIZACION ACUMULADOS MENSUALES Y ANUALES A      *
      *          PARTIR DEL CCAHISTOR. SI ES CIERRE ANUAL SE GENERA   *
      *          CCAACUMULA Y SE INICIALIZA ACUMULADO ANUAL EN        *
      *          CCAACUMUL.                                           *
      *--------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAHISTOR
               ASSIGN          TO DATABASE-CCAHISTOR
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAACUMUL
               ASSIGN          TO DATABASE-CCAACUMUL
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAACUMULA
               ASSIGN          TO DATABASE-CCAACUMULA
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCAMAEAHO
               ASSIGN          TO DATABASE-CCAMAEAHO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAHISTOR
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAHISTOR.
           COPY DDS-ALL-FORMATS OF CCAHISTOR.
      *
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACODTRN.
           COPY DDS-ALL-FORMATS OF CCACODTRN.
      *
       FD  CCAACUMUL
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAACUMUL.
           COPY DDS-ALL-FORMATS OF CCAACUMUL.
      *                                                                 IBM-CT
       FD  CCAACUMULA
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAACUMULA.
           COPY DDS-ALL-FORMATS OF CCAACUMULA.
      *                                                                 IBM-CT
       FD  CCAMAEAHO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCAMAEAHO.
           COPY DDS-ALL-FORMATS OF CCAMAEAHO.
      *                                                                 IBM-CT
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
       01  CONTROLES.
           05  CTL-CCAHISTOR            PIC 9(01) VALUE 0.
               88  ERROR-CCAHISTOR                VALUE 1.
           05  CTL-CCACODTRN             PIC 9(01) VALUE 0.
               88  ERROR-CCACODTRN                 VALUE 1.
           05  CTL-CCAACUMUL            PIC 9(01) VALUE 0.
               88  ERROR-CCAACUMUL                VALUE 1.
           05  CTL-CCAACUMULA           PIC 9(01) VALUE 0.
               88  ERROR-CCAACUMULA               VALUE 1.
           05  CTL-CCAMAEAHO            PIC 9(01) VALUE 0.
               88  ERROR-CCAMAEAHO                VALUE 1.
           05  CTL-PROGRAMA            PIC 9(01) VALUE 0.
               88  FIN-PROGRAMA                  VALUE 1.
      *--------------------------------------------------------------*
       01  VARIABLES.
           05  W-FECLIQ                PIC 9(08)    VALUE ZEROS.
           05  RED-W-FECLIQ            REDEFINES    W-FECLIQ.
               10 ANOLIQ               PIC 9(04).
               10 MESLIQ               PIC 9(02).
               10 DIALIQ               PIC 9(02).
           05  I                       PIC 9(05)    VALUE ZEROS.
           05  W-TOTACUM               PIC 9(15)V99 VALUE ZEROS.
           05  W-TOTMADB               PIC 9(15)V99 VALUE ZEROS.
           05  W-TOTMACR               PIC 9(15)V99 VALUE ZEROS.
           05  MONANT                  PIC 9(03)    VALUE ZEROS.
           05  SISANT                  PIC 9(03)    VALUE ZEROS.
           05  PROANT                  PIC 9(03)    VALUE ZEROS.
           05  AGEANT                  PIC 9(05)    VALUE ZEROS.
           05  CTAANT                  PIC 9(15)    VALUE ZEROS.
           05  CODANT                  PIC 9(03)    VALUE ZEROS.
      *--------------------------------------------------------------*
      * TABLAS.
      *--------------------------------------------------------------*
       01  TABLA-CODIGOS               PIC X(4995) VALUE ZEROS.
       01  RED-TABLA-CODIGOS           REDEFINES   TABLA-CODIGOS.
           05 TABLA-COD                OCCURS     999 TIMES.
              10 INDLO                 PIC 9(01).
              10 DECRE                 PIC 9(01).
              10 CODAL                 PIC 9(03).
      *--------------------------------------------------------------*
       LINKAGE SECTION.
       77  PAR-FECLIQ                  PIC 9(08).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING PAR-FECLIQ.
      *--------------------------------------------------------------*
       COMIENZO.
           PERFORM INICIAR.
           PERFORM PROCESAR UNTIL FIN-PROGRAMA.
           PERFORM TERMINAR.
      *--------------------------------------------------------------*
       INICIAR.
           OPEN I-O CCAHISTOR
                    CCACODTRN
                    CCAACUMUL
                    CCAACUMULA
                    CCAMAEAHO.
           PERFORM LEER-CCAHISTOR
           IF ERROR-CCAHISTOR THEN
              MOVE 1 TO CTL-PROGRAMA
           ELSE
              MOVE 1 TO I
              PERFORM INIC-TABLA   UNTIL I > 999
              PERFORM CARGAR-TABLA UNTIL ERROR-CCACODTRN
              MOVE CODMON OF REGHISTOR TO MONANT
              MOVE CODSIS OF REGHISTOR TO SISANT
              MOVE CODPRO OF REGHISTOR TO PROANT
              MOVE AGCCTA OF REGHISTOR TO AGEANT
              MOVE CTANRO OF REGHISTOR TO CTAANT
              MOVE CODTRA OF REGHISTOR TO CODANT
              MOVE PAR-FECLIQ          TO W-FECLIQ.
      *--------------------------------------------------------------*
       PROCESAR.
           IF CODMON OF REGHISTOR = MONANT AND
              CODSIS OF REGHISTOR = SISANT AND
              CODPRO OF REGHISTOR = PROANT AND
              AGCCTA OF REGHISTOR = AGEANT AND
              CTANRO OF REGHISTOR = CTAANT THEN
              IF CODTRA OF REGHISTOR = CODANT THEN
                 NEXT SENTENCE
              ELSE
                 PERFORM CODIGOS-TRANSACCION
                 MOVE CODTRA OF REGHISTOR TO CODANT
                 MOVE CODMON OF REGHISTOR TO MONANT
                 MOVE CODSIS OF REGHISTOR TO SISANT
                 MOVE CODPRO OF REGHISTOR TO PROANT
                 MOVE CTANRO OF REGHISTOR TO CTAANT
                 MOVE AGCCTA OF REGHISTOR TO AGEANT
                 INITIALIZE W-TOTACUM
              END-IF
           ELSE
             PERFORM CHANGE-CUENTA
             MOVE CODTRA OF REGHISTOR TO CODANT
             MOVE CODMON OF REGHISTOR TO MONANT
             MOVE CODSIS OF REGHISTOR TO SISANT
             MOVE CODPRO OF REGHISTOR TO PROANT
             MOVE CTANRO OF REGHISTOR TO CTAANT
             MOVE AGCCTA OF REGHISTOR TO AGEANT
             INITIALIZE     W-TOTMADB
                            W-TOTMACR
                            W-TOTACUM.

           IF FORIGE OF REGHISTOR NOT > W-FECLIQ THEN
              PERFORM REVISAR-ACUMULADORES.

           PERFORM LEER-CCAHISTOR
           IF ERROR-CCAHISTOR THEN
              PERFORM CHANGE-CUENTA
              MOVE 1 TO CTL-PROGRAMA.
      *--------------------------------------------------------------*
       CODIGOS-TRANSACCION.
           IF W-TOTACUM NOT = ZEROS THEN
              MOVE 0      TO CTL-CCAACUMUL
              MOVE MONANT TO CODMON OF CCAACUMUL
              MOVE SISANT TO CODSIS OF CCAACUMUL
              MOVE PROANT TO CODPRO OF CCAACUMUL
              MOVE AGEANT TO AGCCTA OF CCAACUMUL
              MOVE CTAANT TO CTANRO OF CCAACUMUL
              MOVE CODANT TO CODTRA OF CCAACUMUL
              PERFORM LEER-CCAACUMUL
              IF NOT ERROR-CCAACUMUL THEN
                 PERFORM REGRABAR-CCAACUMUL
              ELSE
                 PERFORM INICIALIZAR-CCAACUMUL
                 PERFORM GRABAR-CCAACUMUL.
      *--------------------------------------------------------------*
       CHANGE-CUENTA.
           MOVE MONANT TO CODMON OF REGMAEAHO
           MOVE SISANT TO CODSIS OF REGMAEAHO
           MOVE PROANT TO CODPRO OF REGMAEAHO
           MOVE AGEANT TO AGCCTA OF REGMAEAHO
           MOVE CTAANT TO CTANRO OF REGMAEAHO
           PERFORM LEER-CCAMAEAHO
           PERFORM CODIGOS-TRANSACCION
           IF NOT ERROR-CCAMAEAHO THEN
              ADD W-TOTMADB TO ACUDEB OF REGMAEAHO
              ADD W-TOTMACR TO ACUCRE OF REGMAEAHO
              PERFORM REWRITE-CCAMAEAHO.
      *--------------------------------------------------------------*
       REVISAR-ACUMULADORES.
           IF INDLO(CODTRA OF REGHISTOR) = 1 THEN
              PERFORM ACUMULADOS-CCACUMUL.
           PERFORM ACUMULADOS-CCCAMAEAHO.
      *--------------------------------------------------------------*
       ACUMULADOS-CCACUMUL.
           COMPUTE W-TOTACUM = W-TOTACUM + IMPORT OF REGHISTOR.
      *--------------------------------------------------------------*
       ACUMULADOS-CCCAMAEAHO.
      *    IF CODAL(CODTRA OF REGHISTOR) = ZEROS THEN
              IF DECRE(CODTRA OF REGHISTOR) = 1 THEN
                 COMPUTE W-TOTMADB = W-TOTMADB + IMPORT OF REGHISTOR
              ELSE
                 COMPUTE W-TOTMACR = W-TOTMACR + IMPORT OF REGHISTOR
              END-IF.
      *    ELSE
      *       IF DECRE(CODTRA OF REGHISTOR) = 1 THEN
      *          COMPUTE W-TOTMACR = W-TOTMACR - IMPORT OF REGHISTOR
      *       ELSE
      *          COMPUTE W-TOTMADB = W-TOTMADB - IMPORT OF REGHISTOR.
      *--------------------------------------------------------------*
       LEER-CCAHISTOR.
           MOVE 0 TO CTL-CCAHISTOR
           READ CCAHISTOR NEXT RECORD AT END MOVE 1 TO CTL-CCAHISTOR.
      *--------------------------------------------------------------*
       LEER-CCAMAEAHO.
           MOVE 0 TO CTL-CCAMAEAHO
           READ CCAMAEAHO INVALID KEY MOVE 1 TO CTL-CCAMAEAHO.
      *--------------------------------------------------------------*
       LEER-CCAACUMUL.
           MOVE 0 TO CTL-CCAACUMUL
           READ CCAACUMUL INVALID KEY MOVE 1 TO CTL-CCAACUMUL.
      *--------------------------------------------------------------*
       INIC-TABLA.
           INITIALIZE INDLO(I)
                      DECRE(I)
                      CODAL(I)
           ADD 1 TO I.
      *--------------------------------------------------------------*
       CARGAR-TABLA.
           MOVE 0 TO CTL-CCACODTRN
           READ CCACODTRN NEXT RECORD AT END MOVE 1 TO CTL-CCACODTRN.
           IF NOT ERROR-CCACODTRN THEN
              MOVE INDLOG OF REGCODTRN TO INDLO(CODTRA OF REGCODTRN)
              MOVE DEBCRE OF REGCODTRN TO DECRE(CODTRA OF REGCODTRN)
              IF CODALT OF REGCODTRN NOT = ZEROS THEN
                 MOVE CODALT OF REGCODTRN TO CODAL(CODALT OF REGCODTRN).
      *--------------------------------------------------------------*
       INICIALIZAR-CCAACUMUL.
           INITIALIZE REGACUMUL OF CCAACUMUL.
           MOVE MONANT TO CODMON OF CCAACUMUL
           MOVE SISANT TO CODSIS OF CCAACUMUL
           MOVE PROANT TO CODPRO OF CCAACUMUL
           MOVE AGEANT TO AGCCTA OF CCAACUMUL
           MOVE CTAANT TO CTANRO OF CCAACUMUL
           MOVE CODANT TO CODTRA OF CCAACUMUL.
      *--------------------------------------------------------------*
       INICIALIZAR-CCAACUMULA.
           INITIALIZE REGACUMULA OF CCAACUMULA.
           MOVE MONANT TO CODMON OF CCAACUMULA
           MOVE SISANT TO CODSIS OF CCAACUMULA
           MOVE PROANT TO CODPRO OF CCAACUMULA
           MOVE AGEANT TO AGCCTA OF CCAACUMULA
           MOVE CTAANT TO CTANRO OF CCAACUMULA
           MOVE CODANT TO CODTRA OF CCAACUMULA.
      *--------------------------------------------------------------*
       GRABAR-CCAACUMUL.
           MOVE W-TOTACUM TO ACUMES OF CCAACUMUL
           ADD  W-TOTACUM TO ACUANO OF CCAACUMUL
           IF MESLIQ = 12 THEN
              PERFORM INICIALIZAR-CCAACUMULA
              MOVE W-TOTACUM TO ACUANO OF CCAACUMULA
              MOVE ZEROS     TO ACUANO OF CCAACUMUL
              PERFORM NIT-CLIENTE
              WRITE ZONA-CCAACUMULA.
           WRITE ZONA-CCAACUMUL.
      *--------------------------------------------------------------*
       REGRABAR-CCAACUMUL.
           MOVE W-TOTACUM           TO ACUMES OF CCAACUMUL
           ADD  ACUMES OF CCAACUMUL TO ACUANO OF CCAACUMUL
           IF MESLIQ = 12 THEN
              PERFORM INICIALIZAR-CCAACUMULA
              MOVE ACUANO OF CCAACUMUL TO ACUANO OF CCAACUMULA
              MOVE ZEROS     TO ACUANO OF CCAACUMUL
              PERFORM NIT-CLIENTE
              WRITE ZONA-CCAACUMULA.
           REWRITE ZONA-CCAACUMUL.
      *--------------------------------------------------------------*
       REWRITE-CCAMAEAHO.
           REWRITE ZONA-CCAMAEAHO.
      *--------------------------------------------------------------*
       NIT-CLIENTE.
           IF NOT ERROR-CCAMAEAHO THEN
              MOVE NITCTA OF REGMAEAHO TO CLINIT OF CCAACUMULA
           ELSE
              INITIALIZE                  CLINIT OF CCAACUMULA.
      *--------------------------------------------------------------*
       TERMINAR.
           CLOSE CCAHISTOR
                 CCACODTRN
                 CCAACUMUL
                 CCAACUMULA
                 CCAMAEAHO.
           STOP RUN.
