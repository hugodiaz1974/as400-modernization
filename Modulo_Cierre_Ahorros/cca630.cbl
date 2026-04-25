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
       PROGRAM-ID.    CCA630.
      ******************************************************************
      * FUNCION: PROGRAMA DE GENERACION DE CONTABILIDAD DEL DIA.       *
      *          EL ARCHIVO DE BASE ENTRA ORDENADO POR CODIGO DE       *
      *          TRANSACCION Y DENTRO DE CODIGO DE TRANSACCION         *
      *          POR AGENCIA DESTINO Y FECHA DE ORIGEN.                *
      ******************************************************************
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  97/12/03.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMOVTMP4
               ASSIGN          TO DATABASE-CCAMOVTMP4
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
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
           SELECT PLTTRNMON
               ASSIGN          TO DATABASE-PLTTRNMON
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVTMP4
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVTMP4.
      *
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  REG-CODTRN.
           COPY DDS-ALL-FORMATS OF CCACODTRN.
      *
       FD  PLTAGCORI
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTAGCORI.
           COPY DDS-ALL-FORMATS OF PLTAGCORI.
      *
       FD  PLTTRNMON
           LABEL RECORDS ARE STANDARD.
       01  REG-PLTTRNMON.
           COPY DDS-ALL-FORMATS OF PLTTRNMON.
      *
       WORKING-STORAGE SECTION.
      *
       77  W-USERID                    PIC X(10) VALUE SPACES.
       77  W-AGEORI                    PIC 9(05) VALUE ZEROS .
      *
       77  W-CODEMP                    PIC 9(03) VALUE ZEROS.
       77  W-NOMEMP                    PIC X(40) VALUE SPACES.
      *
       77  W-SECUEN                    PIC 9(07)     COMP VALUE ZEROS.
       77  W-ACUMUL                    PIC S9(13)V99 COMP VALUE ZEROS.
       77  W-VALOR                     PIC S9(13)V99 COMP VALUE ZEROS.
       77  W-PORCOB                    PIC 9(02)V9(03) VALUE ZEROS.
      *
       77  W-NROTRN                    PIC 9(09) VALUE 700000.
       77  W-CNSTRN                    PIC 9(09) VALUE ZEROS.
       77  W-CODTRA                    PIC 9(05)          VALUE ZEROS.
       77  W-AGCCTA                    PIC 9(05)          VALUE ZEROS.
       77  W-FORIGE                    PIC 9(08)          VALUE ZEROS.
      *-----------------------------------------------------------------
      *Variables para el llamado del pltbase
       01  L-CODMON                    PIC 9(03).
       01  L-CODSIS                    PIC 9(03).
       01  L-CODPRO                    PIC 9(03).
       01  L-NUMAGE                    PIC 9(05).
       01  L-NUMCTA                    PIC 9(17).
       01  L-VLRTRN                    PIC 9(13)V99.
       01  L-VLRBASE                   PIC 9(13)V99.
H      01  W-INFPRD                    PIC X(60).
H      01  FILLER                      REDEFINES W-INFPRD.
H          03  W-INFMOV                PIC X(44).
H          03  W-VLRIND                PIC 9.
H          03  W-VLRBASE               PIC 9(13)V99.
       01  PA-CODEMP                   PIC 9(05) VALUE 0.
      *-----------------------------------------------------------------
       01  CONTROLES.
           05  CTL-CCAMOVTMP4             PIC X(02) VALUE "NO".
               88  FIN-CCAMOVTMP4                   VALUE "SI".
               88  NO-FIN-CCAMOVTMP4                VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
      * ----------------------
           COPY PARGEN OF CCACPY.
           COPY FECHAS OF CCACPY.
      * ----------------------
      *
       LINKAGE SECTION.
       01  ARG-CCA630.
           05  A630-AGEORI   PIC 9(05).
           05  A630-USERID   PIC X(10).
      *
      ***************************************************************
      *
       PROCEDURE DIVISION USING ARG-CCA630.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMOVTMP4.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN INPUT  CCAMOVTMP4.
           OPEN INPUT  CCACODTRN .
           OPEN INPUT  PLTAGCORI.
           OPEN EXTEND PLTTRNMON.
           CALL "PLTCODEMPP"           USING PA-CODEMP
      *
           MOVE A630-AGEORI TO W-AGEORI
           MOVE A630-USERID TO W-USERID
      *
           PERFORM CALL-CCA501.
      *
           INITIALIZE REG-PLTTRNMON.
           MOVE ZEROS TO W-SECUEN
           MOVE ZEROS TO W-ACUMUL.
      *
           MOVE "NO" TO CTL-CCAMOVTMP4 .
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVTMP4  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVTMP4.
      *----------------------------------------------------------------
       PROCESAR.
           MOVE "SI" TO CTL-REGISTRO.
           MOVE CODTRA OF REG-MOVIM TO W-CODTRA
           MOVE W-CODTRA            TO CODTRA OF REG-CODTRN
           READ CCACODTRN INVALID KEY
                DISPLAY "TRANSACCION NO EXISTE: " W-CODTRA
                MOVE "NO" TO CTL-REGISTRO
           END-READ.
           IF REGISTRO-VALIDO
              PERFORM GRABAR-PLTTRNMON
           END-IF
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVTMP4  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVTMP4.
      *----------------------------------------------------------------
       GRABAR-PLTTRNMON.
           INITIALIZE REG-PLTTRNMON.
           ADD 1 TO W-CNSTRN.
           MOVE PA-CODEMP           TO CODEMP OF PLTTRNMON
           MOVE CORR REGMOVIM OF CCAMOVTMP4 TO REGTRNMON OF PLTTRNMON.
           MOVE CODMON OF REGCODTRN TO CODMON OF PLTTRNMON
           MOVE CODSIS OF REGCODTRN TO CODSIS OF PLTTRNMON
           MOVE CODPRO OF REGCODTRN TO CODPRO OF PLTTRNMON
           MOVE CODTRN OF REGCODTRN TO CODTRN OF PLTTRNMON
      *                                HORTRN OF PLTTRNMON
           MOVE AGCCTA OF REGMOVIM  TO AGCDST OF PLTTRNMON
           MOVE 5                   TO MEDPAG OF PLTTRNMON
           IF ( CODSIS OF REGCODTRN =  55 ) AND
              ( CODTRN OF REGCODTRN = 190 )
            MOVE NROPRD OF REGMOVIM TO NROPRD OF PLTTRNMON
           ELSE
            MOVE CTANRO OF REGMOVIM TO NROPRD OF PLTTRNMON
           END-IF
           MOVE INFDEP OF REGMOVIM  TO INFDEP OF PLTTRNMON
           MOVE INFPRD OF REGMOVIM  TO INFPRD OF PLTTRNMON
           MOVE NROREF OF REGMOVIM  TO NROREF OF PLTTRNMON
      *                                CTANRO OF PLTTRNMON
           MOVE IMPORT OF REGMOVIM  TO VLRTRN OF PLTTRNMON
           MOVE FVALOR OF REGMOVIM  TO FECEFE OF PLTTRNMON
           MOVE FORIGE OF REGMOVIM  TO FECPRO OF PLTTRNMON
           MOVE DEBCRE OF REGMOVIM  TO TIPMOV OF PLTTRNMON
      *                                ESTTRN OF PLTTRNMON
           MOVE A630-USERID         TO USRING OF PLTTRNMON
           MOVE ZEROS               TO AGCOPR OF PLTTRNMON
      *                                NROOPR OF PLTTRNMON
      *                                INDCNJ OF PLTTRNMON
      *                                INFPRD OF PLTTRNMON
      *                                NROBNV OF PLTTRNMON
      *                                NRONIT OF PLTTRNMON
      *                                IND101 OF PLTTRNMON
      *                                INDPAT OF PLTTRNMON
      *                                CODOPE OF PLTTRNMON.
                                       CODEMS OF PLTTRNMON
                                       CODBAN OF PLTTRNMON
                                       CONSEC OF PLTTRNMON
                                       DIS001 OF PLTTRNMON
                                       DIS002 OF PLTTRNMON
                                       CAUANU OF PLTTRNMON
           MOVE W-NROTRN            TO NROTRN OF PLTTRNMON.
           MOVE W-CNSTRN            TO CNSTRN OF PLTTRNMON.
           PERFORM VALIDAR-BASE-3XM
           WRITE REG-PLTTRNMON.
      *----------------------------------------------------------------
       VALIDAR-BASE-3XM.
H          IF ( DEBCRE OF REGMOVIM = 1 )
H           MOVE CODMON OF REGMOVIM       TO L-CODMON
H           MOVE CODSIS OF REGMOVIM       TO L-CODSIS
H           MOVE CODPRO OF REGMOVIM       TO L-CODPRO
H           MOVE AGCCTA OF REGMOVIM       TO L-NUMAGE
H           MOVE CTANRO OF REGMOVIM       TO L-NUMCTA
H           MOVE IMPORT OF REGMOVIM       TO L-VLRTRN
H           MOVE ZEROS                    TO L-VLRBASE
H           CALL "PLTBASE" USING PA-CODEMP , L-CODMON , L-CODSIS ,
H                                L-CODPRO  , L-NUMAGE , L-NUMCTA ,
H                                L-VLRTRN  , L-VLRBASE
H           MOVE L-VLRBASE                TO W-VLRBASE
H           MOVE W-INFPRD                 TO INFPRD OF PLTTRNMON
H          END-IF
H          IF ( L-VLRBASE > 0 )
H              MOVE 8 TO INDCNJ OF PLTTRNMON
H          ELSE
H              MOVE 7 TO INDCNJ OF PLTTRNMON
H          END-IF.
      *----------------------------------------------------------------
       LEER-CCAMOVTMP4.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMOVTMP4 NEXT RECORD AT END
                MOVE "SI"            TO CTL-CCAMOVTMP4
                MOVE 999             TO CODTRA OF REG-MOVIM
                MOVE 99999           TO AGCCTA OF REG-MOVIM
                MOVE 99999999        TO FORIGE OF REG-MOVIM.
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMOVTMP4  .
           CLOSE CCACODTRN  .
           CLOSE PLTAGCORI   .
           CLOSE PLTTRNMON   .
           STOP  RUN      .
      *----------------------------------------------------------------
