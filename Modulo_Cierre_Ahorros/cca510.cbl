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
       PROGRAM-ID.    CCA510.
       AUTHOR.        V.G.Q.
       DATE-WRITTEN.  NOVIEMBRE/2000.
      ******************************************************************
      * FUNCION: PROCESAR ARCHIVO DE INTERFASES.                       *
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.   IBM-AS400.
       OBJECT-COMPUTER.   IBM-AS400.
      *****************************************************************
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
      *****************************************************************
       DATA DIVISION.
       FILE SECTION.
      *****************************************************************
      *
       FD  CCATABINT
           LABEL RECORDS ARE STANDARD.
       01  REG-TABINT.                                                   IBM-CT
           COPY DDS-ALL-FORMATS OF CCATABINT.                             IBM-CT
      *
      ******************************************************************
      *
       WORKING-STORAGE SECTION.
      *                                                                *
       01  CONTROLES.
           03  CTL-CCATABINT             PIC X(002).
               88  FIN-CCATABINT                             VALUE "SI".
               88  NO-FIN-CCATABINT                          VALUE "NO".
           03  CTL-RWT-CCATABINT         PIC X(002).
               88  RWT-CCATABINT                             VALUE "SI".
               88  NO-RWT-CCATABINT                          VALUE "NO".
      *                                                                *
       01  VAR-TRABAJO.
           03  WRK-TIPOPROC            PIC X(001).
               88  EN-LINEA            VALUE "0".
               88  EN-BATCH            VALUE "1".
           03  WRK-NOM-INTERFASE       PIC X(010).
      *
       01  FILSTAT.
           03  ERR-FLAG                PIC X(001).
           03  PFK-BYTE                PIC X(001).
      *
       01  VAR-DLT                     PIC X(001)         VALUE ZEROS.
      *
       01  VAR-MONETARIO               PIC X(073)         VALUE ZEROS.
       01  RED-VAR-MONETARIO     REDEFINES    VAR-MONETARIO.
           03  MO-IND-TABLA            PIC X(001).
           03  MO-IND-PROCESO          PIC X(001).
           03  MO-NOM-LIBRERIA         PIC X(010).
           03  MO-NOM-ARCHIVO          PIC X(010).
           03  MO-VALCRE-OK            PIC 9(013)V99  COMP-3.
           03  MO-VALDEB-OK            PIC 9(013)V99  COMP-3.
           03  MO-NROREG-OK            PIC 9(007)     COMP-3.
           03  MO-VALCRE-ER            PIC 9(013)V99  COMP-3.
           03  MO-VALDEB-ER            PIC 9(013)V99  COMP-3.
           03  MO-NROREG-ER            PIC 9(007)     COMP-3.
           03  MO-IND-RETORNO          PIC X(001).
           03  MO-NOM-DISENO           PIC X(010).
      *
       01  VAR-NOMONETARIO             PIC X(072)         VALUE ZEROS.
       01  RED-VAR-NOMONETARIO   REDEFINES    VAR-NOMONETARIO.
           03  NM-IND-PROCESO          PIC X(001).
           03  NM-NOM-LIBRERIA         PIC X(010).
           03  NM-NOM-ARCHIVO          PIC X(010).
           03  NM-VALCRE-OK            PIC 9(013)V99  COMP-3.
           03  NM-VALDEB-OK            PIC 9(013)V99  COMP-3.
           03  NM-NROREG-OK            PIC 9(007)     COMP-3.
           03  NM-VALCRE-ER            PIC 9(013)V99  COMP-3.
           03  NM-VALDEB-ER            PIC 9(013)V99  COMP-3.
           03  NM-NROREG-ER            PIC 9(007)     COMP-3.
           03  NM-IND-RETORNO          PIC X(001).
           03  NM-NOM-DISENO           PIC X(010).
      *
       LINKAGE SECTION.
       01  TIPOPROC                    PIC X(001).
      *
      ******************************************************************
      *
       PROCEDURE DIVISION USING TIPOPROC.
       MAIN-PROGRAM.
           PERFORM 0010-INICIAR
           MOVE "0"                     TO MO-IND-TABLA
           PERFORM 0100-PROCESO      UNTIL FIN-CCATABINT
           PERFORM 9999-FINALIZAR.
      *****************************************************************
      * PROCEDIMIENTO EN QUE ABRIMOS ARCHIVOS.
      *****************************************************************
       0010-INICIAR.
           MOVE TIPOPROC                TO WRK-TIPOPROC
           OPEN I-O    CCATABINT
           MOVE "NO"                    TO CTL-CCATABINT
           PERFORM  0020-LEER-CCATABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE LEEMOS EL ARCHIVO DE INTERFASES.
      *****************************************************************
       0020-LEER-CCATABINT.
           READ CCATABINT   NEXT RECORD AT END
              MOVE "SI"                 TO CTL-CCATABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE PROCESAMOS EL ARCHIVO DE INTERFASES.
      *****************************************************************
       0100-PROCESO.
           IF INDHAB OF REG-TABINT = ZEROS
              MOVE NOMARC  OF REG-TABINT    TO WRK-NOM-INTERFASE
              IF INDNOV   OF REG-TABINT = "1"
                 PERFORM  0110-LLAMAR-NOMONETARIO
              ELSE
                 IF INDNOV   OF REG-TABINT = "2"
                    PERFORM  0120-LLAMAR-MONETARIO
                 END-IF
              END-IF
           END-IF.
           PERFORM  0020-LEER-CCATABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE LLAMAMOS EL PROGRAMA QUE PROCESA LAS IN-
      * TERFASES NO MONETARIAS.
      *****************************************************************
       0110-LLAMAR-NOMONETARIO.
           MOVE INDDLT   OF REG-TABINT   TO VAR-DLT
           MOVE WRK-TIPOPROC            TO NM-IND-PROCESO
           MOVE NOMARC   OF REG-TABINT  TO NM-NOM-ARCHIVO
           MOVE NOMLIB   OF REG-TABINT  TO NM-NOM-LIBRERIA
           MOVE NOMDIS   OF REG-TABINT  TO NM-NOM-DISENO
           MOVE ZEROS                   TO NM-VALCRE-OK
           MOVE ZEROS                   TO NM-VALDEB-OK
           MOVE ZEROS                   TO NM-NROREG-OK
           MOVE ZEROS                   TO NM-VALCRE-ER
           MOVE ZEROS                   TO NM-VALDEB-ER
           MOVE ZEROS                   TO NM-NROREG-ER
           MOVE "0"                     TO NM-IND-RETORNO
           CALL "CCA511P" USING VAR-DLT VAR-NOMONETARIO
           IF NM-IND-RETORNO = "0"
              PERFORM  0130-ACT-CCATABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE LLAMAMOS EL PROGRAMA QUE PROCESA LAS IN-
      * TERFASES MONETARIAS.
      *****************************************************************
       0120-LLAMAR-MONETARIO.
           MOVE INDDLT   OF REG-TABINT  TO VAR-DLT
           MOVE WRK-TIPOPROC            TO MO-IND-PROCESO
           MOVE NOMARC   OF REG-TABINT  TO MO-NOM-ARCHIVO
           MOVE NOMLIB   OF REG-TABINT  TO MO-NOM-LIBRERIA
           MOVE NOMDIS   OF REG-TABINT  TO MO-NOM-DISENO
           MOVE ZEROS                   TO MO-VALCRE-OK
           MOVE ZEROS                   TO MO-VALDEB-OK
           MOVE ZEROS                   TO MO-NROREG-OK
           MOVE ZEROS                   TO MO-VALCRE-ER
           MOVE ZEROS                   TO MO-VALDEB-ER
           MOVE ZEROS                   TO MO-NROREG-ER
           MOVE "0"                     TO MO-IND-RETORNO
           CALL "CCA512P" USING VAR-DLT VAR-MONETARIO
           IF MO-IND-RETORNO = "0"
              MOVE "1"                  TO MO-IND-TABLA.
              PERFORM  0130-ACT-CCATABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE ACTUALIZAMOS LOS ACUMULADORES DE LA IN-
      * TERFASE PROCESADA.
      ******************************************************************
       0130-ACT-CCATABINT.
           IF EN-LINEA
              IF INDNOV   OF REG-TABINT = "1"
                 PERFORM  0140-ACT-NML
              ELSE
                 PERFORM  0140-ACT-MOL
              END-IF
           ELSE
              IF INDNOV   OF REG-TABINT = "1"
                 PERFORM  0140-ACT-NMB
              ELSE
                 PERFORM  0140-ACT-MOB.
           PERFORM  0150-REESCRIBIR-CCATABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE ASIGNAMOS LOS DATOS DE UNA INTERFASE NO
      * MONETARIA PROCESADA EN LINEA.
      ******************************************************************
       0140-ACT-NML.
           MOVE NM-VALCRE-OK            TO ACUCRELOK   OF REG-TABINT
           MOVE NM-VALDEB-OK            TO ACUDEBLOK   OF REG-TABINT
           MOVE NM-NROREG-OK            TO NROREGLOK   OF REG-TABINT
           IF NM-NROREG-ER > 0
              MOVE NM-VALCRE-ER         TO ACUCRELER   OF REG-TABINT
              MOVE NM-VALDEB-ER         TO ACUDEBLER   OF REG-TABINT
              MOVE NM-NROREG-ER         TO NROREGLER   OF REG-TABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE ASIGNAMOS LOS DATOS DE UNA INTERFASE NO
      * MONETARIA PROCESADA EN BATCH.
      ******************************************************************
       0140-ACT-NMB.
           MOVE NM-VALCRE-OK            TO ACUCREBOK   OF REG-TABINT
           MOVE NM-VALDEB-OK            TO ACUDEBBOK   OF REG-TABINT
           MOVE NM-NROREG-OK            TO NROREGBOK   OF REG-TABINT
           IF NM-NROREG-ER > 0
              MOVE NM-VALCRE-ER         TO ACUCREBER   OF REG-TABINT
              MOVE NM-VALDEB-ER         TO ACUDEBBER   OF REG-TABINT
              MOVE NM-NROREG-ER         TO NROREGBER   OF REG-TABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE ASIGNAMOS LOS DATOS DE UNA INTERFASE
      * MONETARIA PROCESADA EN LINEA.
      ******************************************************************
       0140-ACT-MOL.
           MOVE MO-VALCRE-OK            TO ACUCRELOK   OF REG-TABINT
           MOVE MO-VALDEB-OK            TO ACUDEBLOK   OF REG-TABINT
           MOVE MO-NROREG-OK            TO NROREGLOK   OF REG-TABINT
           IF MO-NROREG-ER > 0
              MOVE MO-VALCRE-ER         TO ACUCRELER   OF REG-TABINT
              MOVE MO-VALDEB-ER         TO ACUDEBLER   OF REG-TABINT
              MOVE MO-NROREG-ER         TO NROREGLER   OF REG-TABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE ASIGNAMOS LOS DATOS DE UNA INTERFASE
      * MONETARIA PROCESADA EN BATCH.
      ******************************************************************
       0140-ACT-MOB.
           MOVE MO-VALCRE-OK            TO ACUCREBOK   OF REG-TABINT
           MOVE MO-VALDEB-OK            TO ACUDEBBOK   OF REG-TABINT
           MOVE MO-NROREG-OK            TO NROREGBOK   OF REG-TABINT
           IF MO-NROREG-ER > 0
              MOVE MO-VALCRE-ER         TO ACUCREBER   OF REG-TABINT
              MOVE MO-VALDEB-ER         TO ACUDEBBER   OF REG-TABINT
              MOVE MO-NROREG-ER         TO NROREGBER   OF REG-TABINT.
      *****************************************************************
      * PROCEDIMIENTO EN QUE REESCRIBIMOS EL REGISTRO DE LA INTERFASE
      * PROCESADA.
      ******************************************************************
       0150-REESCRIBIR-CCATABINT.
           MOVE "SI"                    TO CTL-RWT-CCATABINT
           REWRITE REG-TABINT    INVALID KEY
              MOVE "NO"                 TO CTL-RWT-CCATABINT.
      ******************************************************************
      * PROCEDIMIENTO EN QUE TERMINAMOS EL PROGRAMA.
      *****************************************************************
       9999-FINALIZAR.
           CLOSE CCATABINT
           STOP RUN.
