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
       PROGRAM-ID.    CCA505.
       AUTHOR.        HUGO HERNANDO DIAZ.
       DATE-WRITTEN.  ENERO/2012.
      *--------------------------------------------------------------*
      * FUNCION: RETORNA FECHAS ARCHIVO PLTCTLEXT1.
      *--------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-AS400.
       OBJECT-COMPUTER. IBM-AS400.
      *                                                                *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *
           SELECT CCACODPRO
               ASSIGN          TO DATABASE-CCACODPRO
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY.
      *
           SELECT PLTCTLEXT1
               ASSIGN          TO DATABASE-PLTCTLEXT1
               ORGANIZATION    IS INDEXED
               ACCESS MODE     IS DYNAMIC
               RECORD KEY      IS EXTERNALLY-DESCRIBED-KEY
                                  WITH DUPLICATES.
      *--------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
      *
       FD  PLTCTLEXT1
           LABEL RECORDS ARE STANDARD.
       01  ZONA-PLTCTLEXT1.
           COPY DDS-ALL-FORMATS OF PLTCTLEXT1.
      *
       FD  CCACODPRO
           LABEL RECORDS ARE STANDARD.
       01  ZONA-CCACODPRO.
           COPY DDS-ALL-FORMATS OF CCACODPRO.
      *--------------------------------------------------------------*
       WORKING-STORAGE SECTION.
      *--------------------------------------------------------------*
      *Variable para control acceso directo del Archivo PLTCTLEXT1.
       01  W-FIN-PLTCTLEXT1          PIC S9(01)  COMP-3 VALUE 0.
           88  NO-FIN-PLTCTLEXT1                  VALUE 0.
           88  SI-FIN-PLTCTLEXT1                  VALUE 1.
      *Variable para control acceso directo del Archivo CCACODPRO.
       01  W-EXISTE-CCACODPRO          PIC S9(01)  COMP-3 VALUE 0.
           88  NO-EXISTE-CCACODPRO                  VALUE 0.
           88  SI-EXISTE-CCACODPRO                  VALUE 1.
      *Variable para control acceso directo del Archivo CCACODPRO.
       01  W-GENERO-PROMEDIO           PIC S9(01)  COMP-3 VALUE 0.
           88  NO-GENERO-PROMEDIO                   VALUE 0.
           88  SI-GENERO-PROMEDIO                   VALUE 1.
      *--------------------------------------------------------------*
       01  W-FECHAHOY                  PIC 9(08)          VALUE ZEROS.
       01  R-FECHOY                    REDEFINES W-FECHAHOY.
           05  AA-FECHOY               PIC 9(04).
           05  MM-FECHOY               PIC 9(02).
           05  DD-FECHOY               PIC 9(02).
       01  W-FECHA-PROCESO             PIC 9(08)          VALUE ZEROS.
       01  X-FECLIQ                    PIC 9(08)          VALUE ZEROS.
       01  R-FECLIQ                    REDEFINES X-FECLIQ.
           05  AM-FECLIQ               PIC 9(06).
           05  DD-FECLIQ               PIC 9(02).
       01  X-FECHOY                    PIC 9(08)          VALUE ZEROS.
       01  R-FECHAHOY                  REDEFINES X-FECHOY.
           05  AM-FECHAHOY             PIC 9(06).
           05  DD-FECHAHOY             PIC 9(02).
      *--------------------------------------------------------------*
       LINKAGE SECTION.
      *--------------------------------------------------------------*
       01  W-CODEMP        PIC 9(05).
       01  W-CODPRO        PIC 9(03).
       01  W-FECHOY        PIC 9(08).
       01  W-FECLIQ        PIC 9(08).
       01  W-FECFIN        PIC 9(08).
       01  W-GENERADO      PIC 9(01).
      *--------------------------------------------------------------*
       PROCEDURE DIVISION USING W-CODEMP ,                              NA .
                                W-CODPRO ,
                                W-FECHOY ,
                                W-FECLIQ ,
                                W-FECFIN ,
                                W-GENERADO.
      *--------------------------------------------------------------*
       INICIAR-PROGRAMA.
           PERFORM INICIALIZAR.
           PERFORM PROCESAR
           PERFORM FINALIZAR.
       FINALIZAR-PROGRAMA.
           GOBACK.
      *-----------------------------------------------------------
       INICIALIZAR.
           OPEN INPUT PLTCTLEXT1
           OPEN I-O   CCACODPRO
           MOVE 0               TO W-GENERADO
           MOVE W-FECLIQ        TO X-FECLIQ
           MOVE W-FECHOY        TO W-FECHAHOY
                                   X-FECHOY
                                   W-FECHA-PROCESO
           MOVE 1               TO DD-FECHOY
           IF ( MM-FECHOY = 1 )
             MOVE 12            TO MM-FECHOY
             COMPUTE AA-FECHOY = AA-FECHOY - 1
           ELSE
             COMPUTE MM-FECHOY = MM-FECHOY - 1
           END-IF.
      *-----------------------------------------------------------
       PROCESAR.
           IF ( AM-FECLIQ < AM-FECHAHOY )
            PERFORM VALIDAR-GENERACION-EXTRACTO
            IF ( SI-GENERO-PROMEDIO )
               PERFORM ACTUALIZAR-FECHA-INTERESES
            END-IF
           END-IF.
      *-----------------------------------------------------------
       VALIDAR-GENERACION-EXTRACTO.
           MOVE ZEROS                  TO W-FIN-PLTCTLEXT1
                                          W-GENERO-PROMEDIO
                                          W-FECFIN
           MOVE W-CODEMP               TO CODEMP OF PLTCTLEXT1
           MOVE W-FECHAHOY             TO FECINI OF PLTCTLEXT1
           MOVE ZEROS                  TO FECFIN OF PLTCTLEXT1
           START PLTCTLEXT1             KEY NOT <
                 EXTERNALLY-DESCRIBED-KEY INVALID KEY
                 MOVE 1                TO W-FIN-PLTCTLEXT1
           END-START.
           PERFORM LEER-PLTCTLEXT1 UNTIL SI-FIN-PLTCTLEXT1.
      *----------------------------------------------------------------
       LEER-PLTCTLEXT1.
           READ PLTCTLEXT1 NEXT  AT END
                   MOVE 1 TO W-FIN-PLTCTLEXT1
           END-READ.
           IF ( CODEMP OF PLTCTLEXT1 NOT = W-CODEMP ) OR
              ( FECINI OF PLTCTLEXT1 NOT = W-FECHAHOY )
                   MOVE 1 TO W-FIN-PLTCTLEXT1
           END-IF
           IF ( NO-FIN-PLTCTLEXT1 )
              IF ( FECPRO OF PLTCTLEXT1 NOT = ZEROS )
                 MOVE FECFIN OF PLTCTLEXT1 TO W-FECFIN
                 MOVE 1        TO W-GENERO-PROMEDIO
                 MOVE 1        TO W-FIN-PLTCTLEXT1
              END-IF
           END-IF.
      *----------------------------------------------------------------
       ACTUALIZAR-FECHA-INTERESES.
           MOVE W-CODPRO            TO CODPRO OF CCACODPRO
           PERFORM LEER-CCACODPRO
           IF ( SI-EXISTE-CCACODPRO )
             MOVE W-FECHA-PROCESO   TO FECLIQ OF CCACODPRO
             REWRITE ZONA-CCACODPRO
                NOT INVALID KEY
                   MOVE 1           TO W-GENERADO
             END-REWRITE
           END-IF.
      *----------------------------------------------------------------
       LEER-CCACODPRO.
           MOVE 1                      TO W-EXISTE-CCACODPRO
           READ CCACODPRO              INVALID KEY
                                       MOVE 0 TO W-EXISTE-CCACODPRO
           END-READ.
      *----------------------------------------------------------------
       FINALIZAR.
           CLOSE CCACODPRO
           CLOSE PLTCTLEXT1.
