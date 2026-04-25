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
       PROGRAM-ID.    CCA710.
      ******************************************************************
      * FUNCION: ADICION DE MOVIMIENTO ACEPTADO A HISTORICO.           *
      ******************************************************************
       AUTHOR.        J.L.K.
       DATE-WRITTEN.  97/10/10.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCAMOVIM
               ASSIGN          TO DATABASE-CCAMOVIM
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *
           SELECT CCACODTRN
               ASSIGN          TO DATABASE-CCACODTRN
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT CCAHISTOR
               ASSIGN          TO DATABASE-CCAHISTOR
               ORGANIZATION    IS SEQUENTIAL
               ACCESS MODE     IS SEQUENTIAL.
      *-----------------------------------------------------------------
       DATA DIVISION.
       FILE SECTION.
      *
       FD  CCAMOVIM
           LABEL RECORDS ARE STANDARD.
       01  REG-MOVIM.
           COPY DDS-ALL-FORMATS OF CCAMOVIM.
      *
       FD  CCACODTRN
           LABEL RECORDS ARE STANDARD.
       01  REG-CODTRN.
           COPY DDS-ALL-FORMATS OF CCACODTRN.
      *
       FD  CCAHISTOR
           LABEL RECORDS ARE STANDARD.
       01  REG-HISTOR.
           COPY DDS-ALL-FORMATS OF CCAHISTOR.
      *
       WORKING-STORAGE SECTION.
      *
       01  CONTROLES.
           05  CTL-CCAMOVIM             PIC X(02) VALUE "NO".
               88  FIN-CCAMOVIM                   VALUE "SI".
               88  NO-FIN-CCAMOVIM                VALUE "NO".
           05  CTL-CCACODTRN            PIC X(02) VALUE "NO".
               88  FIN-CCACODTRN                  VALUE "SI".
               88  NO-FIN-CCACODTRN               VALUE "NO".
           05  CTL-REGISTRO            PIC X(02) VALUE "NO".
               88  REGISTRO-VALIDO               VALUE "SI".
               88  REGISTRO-NO-VALIDO            VALUE "NO".
      *
           COPY FECHAS  OF CCACPY.
           COPY PARGEN OF CCACPY.
      ***************************************************************
       01  W-TABLA.
           03 ITEM-TABLA OCCURS 9999.
              05 T-CODMON       PIC 999.
              05 T-CODSIS       PIC 999.
              05 T-CODPRO       PIC 999.
      ***************************************************************
      *
       PROCEDURE DIVISION.
       COMIENZO.
           PERFORM INICIAR .
           PERFORM PROCESAR UNTIL FIN-CCAMOVIM.
           PERFORM TERMINAR.
      *----------------------------------------------------------------
       INICIAR.
      *
           OPEN INPUT  CCAMOVIM CCACODTRN.
           OPEN EXTEND CCAHISTOR.
      *
           PERFORM CALL-CCA500.
           PERFORM CALL-CCA501.
      *
           MOVE "NO" TO CTL-CCAMOVIM.
           PERFORM CARGAR-TABLA.
      *
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVIM  UNTIL REGISTRO-VALIDO
                                 OR    FIN-CCAMOVIM.
      *----------------------------------------------------------------
       PROCESAR.
           MOVE CORR REGMOVIM TO REGHISTOR.
           MOVE CNSTRN OF REGMOVIM TO SECUEN OF REGHISTOR.
           IF T-CODSIS(CODTRA OF REGMOVIM) = LK-TRA005
              MOVE T-CODMON(CODTRA OF REGMOVIM) TO CODMON OF REGHISTOR
              MOVE T-CODSIS(CODTRA OF REGMOVIM) TO CODSIS OF REGHISTOR
              MOVE T-CODPRO(CODTRA OF REGMOVIM) TO CODPRO OF REGHISTOR
              MOVE CODPRO OF REGMOVIM           TO CODPRO OF REGHISTOR
              WRITE REG-HISTOR
           END-IF
           MOVE "NO" TO CTL-REGISTRO.
           PERFORM LEER-CCAMOVIM  UNTIL REGISTRO-VALIDO
                   OR FIN-CCAMOVIM.
      *----------------------------------------------------------------
       LEER-CCAMOVIM.
           MOVE "SI" TO CTL-REGISTRO.
           READ CCAMOVIM AT END
                MOVE "SI" TO CTL-CCAMOVIM.
           IF NO-FIN-CCAMOVIM
              IF FVALOR OF REG-MOVIM > LK-FECHA-MANANA
                 MOVE "NO" TO CTL-REGISTRO.
      *----------------------------------------------------------------
       CALL-CCA500.
           CALL "CCA500" USING LK-FECHAS .
      *----------------------------------------------------------------
       CALL-CCA501.
           CALL "CCA501" USING LK-CCAPARGEN.
      *----------------------------------------------------------------
       CARGAR-TABLA.
           MOVE "NO" TO CTL-CCACODTRN.
           INITIALIZE W-TABLA.
           MOVE ZEROS TO CODTRA OF CCACODTRN.
           START CCACODTRN KEY NOT < EXTERNALLY-DESCRIBED-KEY
                 INVALID KEY MOVE "SI" TO CTL-CCACODTRN
           END-START.
           PERFORM UNTIL (FIN-CCACODTRN)
             READ CCACODTRN NEXT RECORD AT END
                MOVE "SI" TO CTL-CCACODTRN
             END-READ
             IF (NO-FIN-CCACODTRN)
             MOVE CODMON OF CCACODTRN TO T-CODMON (CODTRA OF CCACODTRN)
             MOVE CODSIS OF CCACODTRN TO T-CODSIS (CODTRA OF CCACODTRN)
             MOVE CODPRO OF CCACODTRN TO T-CODPRO (CODTRA OF CCACODTRN)
             END-IF
           END-PERFORM.
      *----------------------------------------------------------------
       TERMINAR.
           CLOSE CCAMOVIM  CCACODTRN.
           CLOSE CCAHISTOR .
           STOP  RUN      .
      *----------------------------------------------------------------
