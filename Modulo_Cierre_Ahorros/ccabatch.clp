     /*---------------------------------------------------------------*/
     /* Material Bajo Licencia de Taylor & Johnson Ltda.              */
     /* Copyright : TAYLOR & JOHNSON 1996, 1999, 2000, 2001, 2002     */
     /*             Todos los Derechos Reservados                     */
     /*---------------------------------------------------------------*/
     /* Derechos Restringidos para los usuarios, el uso, la duplica-  */
     /* cion o publicacion quedan sujetos al contrato con Taylor &    */
     /* Johnson                                                       */
     /*---------------------------------------------------------------*/
/*-------------------------------------------------------------------*/
/* PROGRAMA   : CCABATCH                                             */
/* AUTOR      : VGQ.                                                 */
/* RESPONSABLE: OER.                                                 */
/* FECHA      : NOVIEMBRE/2000           HORA : 19:34:10             */
/* FUNCION    : Realizar La Ejecución del Proceso Batch de Ahorros   */
/*-------------------------------------------------------------------*/

             PGM

             DCLF       FILE(CCABATCHS)

     /* ----------------------------------------------------------------------*/
     /* Definicion variables ambiente                                         */
     /*-----------------------------------------------------------------------*/

     /* Librerias de Ejecutables                                   */

             DCL VAR(&BSECOBJ) TYPE(*CHAR) LEN(10)  /* SEG */
             DCL VAR(&BEXECLP) TYPE(*CHAR) LEN(10)  /* CLP */
             DCL VAR(&BEXEOBJ) TYPE(*CHAR) LEN(10)  /* OBJ */
             DCL VAR(&BEXERLU) TYPE(*CHAR) LEN(10)  /* RLU */
             DCL VAR(&BEXESDA) TYPE(*CHAR) LEN(10)  /* SDA */

      /* Librerias de Base de Datos                                */

             DCL VAR(&BCLIDAT) TYPE(*CHAR) LEN(10)  /* CLI */
             DCL VAR(&BPLTDAT) TYPE(*CHAR) LEN(10)  /* PLT */
             DCL VAR(&BCCADAT) TYPE(*CHAR) LEN(10)  /* CCA */
             DCL VAR(&BCCCDAT) TYPE(*CHAR) LEN(10)  /* CCC */
             DCL VAR(&BCDTDAT) TYPE(*CHAR) LEN(10)  /* CDT */
             DCL VAR(&BPAPDAT) TYPE(*CHAR) LEN(10)  /* PAP */
             DCL VAR(&BFACDAT) TYPE(*CHAR) LEN(10)  /* FAC */
             DCL VAR(&BAPCDAT) TYPE(*CHAR) LEN(10)  /* APC */
             DCL VAR(&BSOLDAT) TYPE(*CHAR) LEN(10)  /* SOL */
             DCL VAR(&BCBCDAT) TYPE(*CHAR) LEN(10)  /* CBC */
             DCL VAR(&BCOBDAT) TYPE(*CHAR) LEN(10)  /* COB */
             DCL VAR(&BTRADAT) TYPE(*CHAR) LEN(10)  /* TRA */
             DCL VAR(&BCARDAT) TYPE(*CHAR) LEN(10)  /* CAR */
             DCL VAR(&BENDDAT) TYPE(*CHAR) LEN(10)  /* END */
             DCL VAR(&BTESDAT) TYPE(*CHAR) LEN(10)  /* TES */
             DCL VAR(&BCHEDAT) TYPE(*CHAR) LEN(10)  /* CHE */

     /* Librerias de Entrada y Salida para Externos                */

             DCL VAR(&BFACENT) TYPE(*CHAR) LEN(10)  /* FAE */
             DCL VAR(&BFACSAL) TYPE(*CHAR) LEN(10)  /* FAS */
             DCL VAR(&BPLTENT) TYPE(*CHAR) LEN(10)  /* PTE */
             DCL VAR(&BPLTSAL) TYPE(*CHAR) LEN(10)  /* PTS */
             DCL VAR(&BTESENT) TYPE(*CHAR) LEN(10)  /* TEE */
             DCL VAR(&BHISTOR) TYPE(*CHAR) LEN(10)  /* HIS */

             DCL VAR(&BCCABKP) TYPE(*CHAR) LEN(10)  /* BKP */
             DCL VAR(&BCODAMB) TYPE(*CHAR) LEN(03)  /* AMB */
             DCL VAR(&BCODEMP) TYPE(*CHAR) LEN(05)  /* EMP */

     /* Librerias COMUNES PLATAFORMA Y CLIENTES                               */

             DCL VAR(&CLIDAT) TYPE(*CHAR) LEN(10)  /* CLI */
             DCL VAR(&PLTDAT) TYPE(*CHAR) LEN(10)  /* PLT */

             DCL        VAR(&PARM1)   TYPE(*CHAR) LEN(01)
             DCL        VAR(&LINBAT)  TYPE(*CHAR) LEN(01)
             DCL        VAR(&NOVEDA)  TYPE(*CHAR) LEN(01)
             DCL        VAR(&XINDCTL) TYPE(*CHAR) LEN(01)

             DCL        VAR(&XMMDD)    TYPE(*CHAR) LEN(04)
             DCL        VAR(&XNOMSPL)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&XNOMARC)  TYPE(*CHAR) LEN(10)

             DCL        VAR(&XUSRING)  TYPE(*CHAR) LEN(10)
             DCL        VAR(&WS)       TYPE(*CHAR) LEN(10)
             DCL        VAR(&FECHAS)   TYPE(*CHAR) LEN(32)
             DCL        VAR(&XFECPRA)  TYPE(*CHAR) LEN(08)
             DCL        VAR(&XFECHOY)  TYPE(*CHAR) LEN(08)
             DCL        VAR(&XFECMAN)  TYPE(*CHAR) LEN(08)
             DCL        VAR(&XFECPAM)  TYPE(*CHAR) LEN(08)
             DCL        VAR(&XINDEXS)  TYPE(*DEC)  LEN(1  0)
             DCL        VAR(&XREG)     TYPE(*DEC)  LEN(10 0)
             DCL        VAR(&XREG1)    TYPE(*DEC)  LEN(10 0)

     /* Variables Para Ejecucion de Programa Verificación Ingreso a Plataforma*/

             DCL        VAR(&XAGCORI)  TYPE(*CHAR) LEN(05)
             DCL        VAR(&XCODCIU)  TYPE(*CHAR) LEN(05)
             DCL        VAR(&XINDHOR)  TYPE(*CHAR) LEN(01)
             DCL        VAR(&XCODRET)  TYPE(*CHAR) LEN(01)

     /* Variables Rutina para leer Archivo de Interfaces y Consolidar Movimien*/

             DCL        VAR(&ARCHORI) TYPE(*CHAR) LEN(10)
             DCL        VAR(&ARCHDES) TYPE(*CHAR) LEN(10)
             DCL        VAR(&INDTAB)  TYPE(*CHAR) LEN(01)

     /* Variables Rutina para leer Archivo de Interfaces y Consolidar Movimien*/

             DCL        VAR(&EQUIPO)  TYPE(*CHAR) LEN(010) VALUE('  ')
             DCL        VAR(&FILE)    TYPE(*CHAR) LEN(010) VALUE('  ')


     /* Variables Rutina para Actualización de Movimiento                     */

             DCL        VAR(&REGS1)   TYPE(*DEC) LEN(010) VALUE(0)
             DCL        VAR(&REGS2)   TYPE(*DEC) LEN(010) VALUE(0)
             DCL        VAR(&REGS3)   TYPE(*DEC) LEN(010) VALUE(0)
             DCL        VAR(&REGS4)   TYPE(*DEC) LEN(010) VALUE(0)
             DCL        VAR(&REGS5)   TYPE(*DEC) LEN(010) VALUE(0)

             DCL        VAR(&XFINMES) TYPE(*CHAR) LEN(001) VALUE('N')
             DCL        VAR(&XFINTRI) TYPE(*CHAR) LEN(001) VALUE('N')

     /* Variables Rutina para Generacion Contable del dia                     */

             DCL        VAR(&XPARM)   TYPE(*CHAR) LEN(022) VALUE('   ')

     /* Variables Depurar Cuentas Cerradas en Maestro                         */

             DCL        VAR(&NOMMAE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&MESDIA) TYPE(*CHAR) LEN(04)

             RTVDTAARA  DTAARA(*LDA (51 10)) RTNVAR(&BEXECLP)
             RTVDTAARA  DTAARA(*LDA (61 10)) RTNVAR(&BEXEOBJ)
             RTVDTAARA  DTAARA(*LDA (71 10)) RTNVAR(&BEXERLU)
             RTVDTAARA  DTAARA(*LDA (81 10)) RTNVAR(&BEXESDA)
             RTVDTAARA  DTAARA(*LDA (91 10)) RTNVAR(&BCLIDAT)
             RTVDTAARA  DTAARA(*LDA (101 10)) RTNVAR(&BPLTDAT)
             RTVDTAARA  DTAARA(*LDA (111 10)) RTNVAR(&BCCADAT)
             RTVDTAARA  DTAARA(*LDA (121 10)) RTNVAR(&BCCCDAT)
             RTVDTAARA  DTAARA(*LDA (131 10)) RTNVAR(&BCDTDAT)
             RTVDTAARA  DTAARA(*LDA (141 10)) RTNVAR(&BPAPDAT)
             RTVDTAARA  DTAARA(*LDA (151 10)) RTNVAR(&BFACDAT)
             RTVDTAARA  DTAARA(*LDA (161 10)) RTNVAR(&BAPCDAT)
             RTVDTAARA  DTAARA(*LDA (171 10)) RTNVAR(&BSOLDAT)
             RTVDTAARA  DTAARA(*LDA (181 10)) RTNVAR(&BCBCDAT)
             RTVDTAARA  DTAARA(*LDA (191 10)) RTNVAR(&BCOBDAT)
             RTVDTAARA  DTAARA(*LDA (201 10)) RTNVAR(&BTRADAT)
             RTVDTAARA  DTAARA(*LDA (211 10)) RTNVAR(&BCARDAT)
             RTVDTAARA  DTAARA(*LDA (221 10)) RTNVAR(&BCHEDAT)
             RTVDTAARA  DTAARA(*LDA (231 10)) RTNVAR(&BENDDAT)
             RTVDTAARA  DTAARA(*LDA (241 10)) RTNVAR(&BTESDAT)
             RTVDTAARA  DTAARA(*LDA (251 10)) RTNVAR(&BFACENT)
             RTVDTAARA  DTAARA(*LDA (261 10)) RTNVAR(&BFACSAL)
             RTVDTAARA  DTAARA(*LDA (271 10)) RTNVAR(&BPLTENT)
             RTVDTAARA  DTAARA(*LDA (281 10)) RTNVAR(&BPLTSAL)
             RTVDTAARA  DTAARA(*LDA (291 10)) RTNVAR(&BTESENT)
             RTVDTAARA  DTAARA(*LDA (301 10)) RTNVAR(&BHISTOR)
             RTVDTAARA  DTAARA(*LDA (311 10)) RTNVAR(&CLIDAT)
             RTVDTAARA  DTAARA(*LDA (321 10)) RTNVAR(&PLTDAT)
             RTVDTAARA  DTAARA(*LDA (331 10)) RTNVAR(&BSECOBJ)

             RTVDTAARA  DTAARA(*LDA (51 03))  RTNVAR(&BCODAMB)
             RTVDTAARA  DTAARA(*LDA (23 05))  RTNVAR(&BCODEMP)

             RTVJOBA    JOB(&WS)
             RTVJOBA    USER(&XUSRING)

             CHGVAR     VAR(&BCCABKP)  VALUE(&BCODAMB *CAT 'CCABKP')

/*-------------------------------------------------------------------*/
/*        Asigna las Libreria del aplicativo                         */
/*-------------------------------------------------------------------*/

    VERINGPLT:    /* Verificacion Ingreso a Plataforma */
    /*       CALL       PGM(&BEXECLP/CCALDAP)     */

             OVRDBF     FILE(PLTCAJL01) TOFILE(&BSECOBJ/PLTCAJL01)
             OVRDBF     FILE(PLTAGCORI) TOFILE(&BSECOBJ/PLTAGCORI)
             CALL       PGM(&BSECOBJ/PLT1001) PARM(&BCODEMP &XUSRING +
                          &WS &XAGCORI &XCODCIU &XINDHOR &BCODAMB +
                          &XCODRET)
             IF         COND(&XCODRET *NE '1') THEN(SIGNOFF)
             DLTOVR     FILE(*ALL)
             CHGVAR     VAR(&IN01)     VALUE('0')
             CHGVAR     VAR(&IN03)     VALUE('0')
/*-------------------------------------------------------------------*/
/* SE LLAMA AL PROGRAMA QUE RETORNA LAS FECHAS DE PROCESO.           */
/*-------------------------------------------------------------------*/

    FECPRO:    /* Carga la fecha de Proceso */
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA500) PARM(&FECHAS)
             CHGVAR     VAR(&XFECPRA)  VALUE(%SST(&FECHAS 1 8))
             CHGVAR     VAR(&XFECHOY)  VALUE(%SST(&FECHAS 9 8))
             CHGVAR     VAR(&XFECMAN)  VALUE(%SST(&FECHAS 17 8))
             CHGVAR     VAR(&XFECPAM)  VALUE(%SST(&FECHAS 25 8))

             CHGVAR     VAR(&FECHOY)   VALUE(&XFECHOY)
             CHGVAR     VAR(&FECPRA)   VALUE(&XFECPRA)
             CHGVAR     VAR(&FECMAN)   VALUE(&XFECMAN)
             CHGVAR     VAR(&FECPAM)   VALUE(&XFECPAM)

             CLRPFM     FILE(&BCCADAT/CCAEXTRAC) MBR(*FIRST)
             MONMSG     MSGID(CPF3100)

             CLRPFM     FILE(&BCCADAT/CCACAUHOY)
             MONMSG     MSGID(CPF3100)
             DLTOVR     FILE(*ALL)
/*-------------------------------------------------------------------*/
/* MUESTRA PANTALLA DEL CIERRE                                       */
/*-------------------------------------------------------------------*/
 PANTALLA01: SNDRCVF    RCDFMT(PANTALLA01)
             IF         COND(&IN03 = '1') THEN(RETURN)
             IF         COND(&IN01 = '1') THEN(GOTO CMDLBL(SEGUIR))
             GOTO       CMDLBL(PANTALLA01)

 SEGUIR:     CHGVAR     VAR(&LCKARC1)  VALUE('Disponible')
             CHGVAR     VAR(&LCKARC2)  VALUE('Disponible')
             CHGVAR     VAR(&LCKARC3)  VALUE('Disponible')

             ALCOBJ     OBJ((&BCCADAT/CCAMAEAHO *FILE *EXCL)) WAIT(10)
             MONMSG     MSGID(CPF1002) EXEC(CHGVAR VAR(&LCKARC1) +
                        VALUE('NO Disponible'))
/*           ALCOBJ     OBJ((&BHISTOR/CCAHISTOR *FILE *EXCL)) WAIT(10) */
/*           MONMSG     MSGID(CPF1002) EXEC(CHGVAR VAR(&LCKARC2) +
                        VALUE('NO Disponible'))         */
             ALCOBJ     OBJ((&BCCADAT/CCAMOVACE *FILE *EXCL)) WAIT(10)
             MONMSG     MSGID(CPF1002) EXEC(CHGVAR VAR(&LCKARC3) +
                        VALUE('NO Disponible'))

             IF         COND(&LCKARC1 *EQ 'NO Disponible' *OR +
                          &LCKARC2 *EQ 'NO Disponible' *OR &LCKARC3 +
                          *EQ 'NO Disponible') THEN(DO)
                        SNDRCVF    RCDFMT(PANTALLA04)
                        GOTO       CMDLBL(DESBLOQUEA)
                        ENDDO

/*-------------------------------------------------------------------*/
/* Lee Archivo de Interfaces y Consolida Movimiento y Novedades.     */
/*-------------------------------------------------------------------*/
    INTERFACES:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA510  - +
                        Consolidación Interfaces') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*-------------------------------------------------------------------*/
/* SE ASIGNAN VALORES A LAS VARIABLES DECLARADAS.                    */
/*-------------------------------------------------------------------*/

             CHGVAR     VAR(&LINBAT)  VALUE('1')
             CHGVAR     VAR(&INDTAB)  VALUE('0')
             CHGVAR     VAR(&ARCHORI) VALUE('CCABATCH')
             CHGVAR     VAR(&ARCHDES) VALUE('CCAMOVBAT')

/*-------------------------------------------------------------------*/
/* SE LIMPIAN LOS ARCHIVOS QUE VAN A TENER LA SALIDA DEL PROCESO.    */
/*-------------------------------------------------------------------*/

             CLRPFM     FILE(&BCCADAT/CCAMOVIM)
             CLRPFM     FILE(&BCCADAT/CCAMOERR)
             CLRPFM     FILE(&BCCADAT/CCANOMON)
             CLRPFM     FILE(&BCCADAT/&ARCHDES)

/*-------------------------------------------------------------------*/
/* SE COPIA EL MOVIMIENTO ESPECIAL - CAPTURADO FUERA DE LINEA        */
/*-------------------------------------------------------------------*/

             CHKOBJ     OBJ(&BCCADAT/&ARCHDES) OBJTYPE(*FILE)
             MONMSG     MSGID(CPF2103) EXEC(GOTO CMDLBL(SIGA))

             RTVMBRD    FILE(&BCCADAT/&ARCHORI) NBRCURRCD(&XREG)
             IF         COND(&XREG *GT 0) THEN(DO)
             CPYF       FROMFILE(&BCCADAT/&ARCHORI) +
                        TOFILE(&BCCADAT/&ARCHDES) MBROPT(*REPLACE) +
                        CRTFILE(*NO) INCREL((*IF CODSIS *EQ +
                        '11')) FMTOPT(*DROP *MAP)
             ENDDO

/*-------------------------------------------------------------------*/
/* SE LLAMA EL PROGRAMA QUE INICIALIZA LOS ACUMULADORES DEL ARCHIVO  */
/* DE INTERFACES.                                                    */
/*-------------------------------------------------------------------*/

  SIGA:
             OVRDBF     FILE(CCATABINT) TOFILE(&BCCADAT/CCATABINT)
             CALL       PGM(&BEXEOBJ/CCA513) PARM(&LINBAT)

             DLTOVR     FILE(*ALL)
/*-------------------------------------------------------------------*/
/* SE LLAMA EL PROGRAMA QUE PROCESA EL ARCHIVO DE INTERFACES.        */
/*-------------------------------------------------------------------*/

             OVRDBF     FILE(CCATABINT) TOFILE(&BCCADAT/CCATABINT)
             CALL       PGM(&BEXEOBJ/CCA510) PARM(&LINBAT)

             DLTOVR     FILE(*ALL)
/*-------------------------------------------------------------------*/
/* SE LIMPIA LA INTERFAZ ESPECIAL.                                  */
/*-------------------------------------------------------------------*/

             CLRPFM     FILE(&BCCADAT/&ARCHDES)
/*-------------------------------------------------------------------*/
/* Reporte Movimiento de Interfaces                                  */
/* LINBAT:1, NOVEDA: 1 Reporte Novedades               (Batch).      */
/* LINBAT:1, NOVEDA: 2 Reporte Movimiento              (Batch).      */
/*-------------------------------------------------------------------*/
    RPTTOTINT: /* Reporte de Totales Interfaces Consolidadas */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA520 - +
                        Rep. Totales Interfaces Consolidadas') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RTVNETA    SYSNAME(&EQUIPO)
             CHGVAR     VAR(&NOVEDA) VALUE('1')
             CHGVAR     VAR(&LINBAT) VALUE('1')

             DLTSPLF FILE(CCA520R1)
             MONMSG  MSGID(CPF3300)
             OVRPRTF FILE(CCA520R)  TOFILE(&BEXERLU/CCA520R)  +
                     SPLFNAME(CCA520R1)

             OVRDBF     FILE(CCATABINT) TOFILE(&BCCADAT/CCATABINT)
             OVRDBF     FILE(PLTPARGEN) TOFILE(&BSECOBJ/PLTPARGEN)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA520) +
                        PARM(&NOVEDA &LINBAT &XUSRING &EQUIPO)

             DLTOVR     FILE(*ALL)
             CHGVAR     VAR(&NOVEDA) VALUE('2')
             CHGVAR     VAR(&LINBAT) VALUE('1')

             DLTSPLF FILE(CCA520R2)
             MONMSG  MSGID(CPF3300)
             OVRPRTF FILE(CCA520R)  TOFILE(&BEXERLU/CCA520R)  +
                     SPLFNAME(CCA520R2)

             OVRDBF     FILE(CCATABINT) TOFILE(&BCCADAT/CCATABINT)
             OVRDBF     FILE(PLTPARGEN) TOFILE(&BSECOBJ/PLTPARGEN)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA520) +
                        PARM(&NOVEDA &LINBAT &XUSRING &EQUIPO)

             DLTOVR     FILE(*ALL)
/*-------------------------------------------------------------------*/
/* Valida las Novedades NO MONETARIAS.                               */
/*-------------------------------------------------------------------*/
    VALNOVEDAD: /* Validación de Novedades                    */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA530  - +
                        Validación Novedades') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*-------------------------------------------------------------------*/
/* SE LIMPIAN LOS ARCHIVOS QUE VAN A TENER LA SALIDA DEL PROCESO.    */
/*-------------------------------------------------------------------*/

             CLRPFM     FILE(&BCCADAT/CCANOVAPL)

             RTVMBRD    FILE(&BCCADAT/CCANOMON) MBR(*FIRST) +
                        NBRCURRCD(&XREG)

             IF         COND(&XREG *NG 0) THEN(GOTO CMDLBL(RPTNOVPRO))
/*********************************************************************/
/* SE LLAMA EL PROGRAMA QUE VALIDA EL MOVIMIENTO NO MONETARIO.       */
/*********************************************************************/

             OVRDBF     FILE(CCANOMON)  TOFILE(&BCCADAT/CCANOMON01)
             OVRDBF     FILE(CCANOVAPL) TOFILE(&BCCADAT/CCANOVAPL)
             OVRDBF     FILE(CCAMAEAHO) TOFILE(&BCCADAT/CCAMAEAHO)
             OVRDBF     FILE(CCATABLAS) TOFILE(&BCCADAT/CCATABLAS)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             OVRDBF     FILE(PLTAGCORI) TOFILE(&BSECOBJ/PLTAGCORI)
             CALL       PGM(&BEXEOBJ/CCA530)
             DLTOVR     FILE(*ALL)

      /*     CALL       PGM(&BEXECLP/CCA530P)         */

/*-------------------------------------------------------------------*/
/* Reporte de Novedades Procesadas.                                  */
/*-------------------------------------------------------------------*/
    RPTNOVPRO:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA540  - +
                        Rep. Novedades Procesadas') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*********************************************************************/
/* SE GENERA EL REPORTE DE LAS NOVEDADES NO MONETARIAS PROCESADAS.   */
/*********************************************************************/

  SIG:
             DLTSPLF    FILE(CCA540R1)
             MONMSG     MSGID(CPF3300)
             OVRPRTF    FILE(CCA540R1) TOFILE(&BEXERLU/CCA540R1)  +
                                       SPLFNAME(CCANOMON)

             OVRDBF     FILE(CCATRNNOMO) TOFILE(&BCCADAT/CCATRNNOMO)
             OVRDBF     FILE(PLTFECHAS)  TOFILE(&BSECOBJ/PLTFECHAS)
             OVRDBF     FILE(PLTPARGEN)  TOFILE(&BSECOBJ/PLTPARGEN)
             OVRDBF     FILE(CCACODNOV)  TOFILE(&BCCADAT/CCACODNOV)
             CALL       PGM(&BEXEOBJ/CCA540)

             DLTOVR     FILE(*ALL)
   /*        CALL       PGM(&BEXECLP/CCA540P)       */

/*---------------------- INFORME DE MVTO NO APLICADO ----------------*/
    INFMTONAPL:

             DLTSPLF    FILE(CCA565R)
             MONMSG     MSGID(CPF3300)
             OVRPRTF    FILE(CCA565R)   TOFILE(&BEXERLU/CCA565R) +
                                        SPLFNAME(CCAERRORES)

             OVRDBF     FILE(CCAMOERR)   TOFILE(&BCCADAT/CCAMOERR)
             OVRDBF     FILE(CCACODTRN)  TOFILE(&BCCADAT/CCACODTRN)
             OVRDBF     FILE(CCATABLAS)  TOFILE(&BCCADAT/CCATABLAS)
             OVRDBF     FILE(PLTAGCORI)  TOFILE(&BSECOBJ/PLTAGCORI)
             OVRDBF     FILE(PLTSUCURS)  TOFILE(&PLTDAT/PLTSUCURS)
             CALL       PGM(&BEXEOBJ/CCA565) PARM(&XUSRING)
             DLTOVR     FILE(*ALL)

         /*  CALL       PGM(&BEXECLP/CCA565P)    */
/*-------------------------------------------------------------------*/
/* Programa que Depura el Archivo de Causaciones a Partir del        */
/* Archivo de Cuentas Cerradas en el Dia (CANOVCIE).                 */
/*-------------------------------------------------------------------*/

    DEPARCCAUS:  /* Depurar el Archivo de Causaciones */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA545  - +
                        Depuración Archivo de Causaciones')   +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CPYF       FROMFILE(&BCCADAT/CCANOMON) +
                        TOFILE(&BCCADAT/CCANOVCIE) +
                        MBROPT(*REPLACE) INCREL((*IF CODNOV *EQ +
                        2)) FMTOPT(*MAP *DROP)
             MONMSG     MSGID(CPF2817)
             MONMSG     MSGID(CPF2869)

             RTVMBRD    FILE(&BCCADAT/CCANOVCIE) MBR(*FIRST) +
                        NBRCURRCD(&XREG)

             IF         COND(&XREG *LE 0) THEN(GOTO CMDLBL(MTOMON))

             OVRDBF     FILE(CCANOVCIE) TOFILE(&BCCADAT/CCANOVCIE)
             OVRDBF     FILE(CCACAUSAC) TOFILE(&BCCADAT/CCACAUSAC)
             CALL       PGM(&BEXEOBJ/CCA545)

             DLTOVR     FILE(*ALL)
       /*    CALL       PGM(&BEXECLP/CCA545P)           */

/*-------------------------------------------------------------------*/
/* Valida el Movimiento Monetario.                                   */
/*-------------------------------------------------------------------*/

    MTOMON:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA550  - +
                        Validación Movimiento') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*-------------------------------------------------------------------*/
/* ORDENAR ARCHIVO CCAMOVIM                                           */
/*-------------------------------------------------------------------*/

             RTVMBRD    FILE(&BCCADAT/CCAMOVIM) MBR(*FIRST) +
                          NBRCURRCD(&XREG)
             IF         COND(&XREG *LE 0) THEN(GOTO CMDLBL(INIREGMAL))
/*-------------------------------------------------------------------*/
/* SE LLAMA EL PROGRAMA QUE VALIDA EL MOVIMIENTO MONETARIO.          */
/*-------------------------------------------------------------------*/

             OVRDBF     FILE(CCAMOVIM01)   TOFILE(&BCCADAT/CCAMOVIM01)
             OVRDBF     FILE(CCAMAEAHO)    TOFILE(&BCCADAT/CCAMAEAHO)
             OVRDBF     FILE(CCACODTRN)    TOFILE(&BCCADAT/CCACODTRN)
             OVRDBF     FILE(PLTDIAFST)    TOFILE(&PLTDAT/PLTDIAFST)
             OVRDBF     FILE(PLTFECHAS)    TOFILE(&BSECOBJ/PLTFECHAS)
             OVRDBF     FILE(PLTAGCORI)    TOFILE(&BSECOBJ/PLTAGCORI)
             CALL       PGM(&BEXEOBJ/CCA550)
             DLTOVR     FILE(*ALL)

     /*      CALL       PGM(&BEXECLP/CCA550P)   */

/*-------------------------------------------------------------------*/
/* Cereo de Registros Malos en CAMOVIM y Asignación de Cuentas de    */
/* Rechazo en los Registros Erróneos. Generación de Reportes de Mov. */
/* Rechazados.                                                       */
/*-------------------------------------------------------------------*/

    INIREGMAL:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA560  - +
                        Asignación a Cuentas de Rechazo')     +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(&BCCADAT/CCAMOVIMR)
   /*        DLTSPLF    FILE(CCA560R)          */
   /*        MONMSG     MSGID(CPF3300)         */

             DLTF       FILE(QTEMP/CCAMOVTMP)
             MONMSG     MSGID(CPF2105)

             CRTDUPOBJ  OBJ(CCAMOVIM) FROMLIB(&BCCADAT) +
                          OBJTYPE(*FILE) TOLIB(QTEMP) NEWOBJ(CCAMOVTMP)
             MONMSG     MSGID(CPF2130)

             OVRDBF     FILE(CCAMOVIM03) TOFILE(&BCCADAT/CCAMOVIM03)
             OVRDBF     FILE(CCAMOVIMR)  TOFILE(&BCCADAT/CCAMOVIMR)
             OVRDBF     FILE(CCACODTRN)  TOFILE(&BCCADAT/CCACODTRN)
             OVRDBF     FILE(CCAMAEAHO)  TOFILE(&BCCADAT/CCAMAEAHO)
             OVRDBF     FILE(CCATABLAS)  TOFILE(&BCCADAT/CCATABLAS)
             OVRDBF     FILE(PLTAGCORI)  TOFILE(&BSECOBJ/PLTAGCORI)
             OVRDBF     FILE(PLTSUCURS)  TOFILE(&PLTDAT/PLTSUCURS)
             OVRDBF     FILE(CCAMOVTMP)  TOFILE(QTEMP/CCAMOVTMP)
             OVRDBF     FILE(PLTPARGEN)  TOFILE(&BSECOBJ/PLTPARGEN)
             OVRDBF     FILE(PLTFECHAS)  TOFILE(&BSECOBJ/PLTFECHAS)
 /*          OVRPRTF    FILE(CCA560R)    TOFILE(&BEXERLU/CCA560R) + */
 /*                                     SPLFNAME(CCA560R)          */
             CALL       PGM(&BEXEOBJ/CCA560) PARM(&XUSRING)
/* - COPIA ARCHIVO DE SPOOL ------------------------------------ */
             CHGVAR     VAR(&XMMDD)    VALUE(%SST(&XFECHOY 5 4))
             CHGVAR     VAR(&XNOMARC)  VALUE('CCA560' *CAT &XMMDD)
             CHGVAR     VAR(&XNOMSPL)  VALUE('CCA560R')
             CALL       PGM(&BEXECLP/PLTCPYSPLP) PARM(&XNOMSPL +
                        &BPLTSAL &XNOMARC)
/* ------------------------------------------------------------- */
             CLRPFM     FILE(&BCCADAT/CCAMOVIM)
             CPYF       FROMFILE(QTEMP/CCAMOVTMP) +
                        TOFILE(&BCCADAT/CCAMOVIM) MBROPT(*REPLACE)
             MONMSG     MSGID(CPF2817)

/*-------------------------------------------------------------------*/
/* ORDENAR NUEVAMENTE EL ARCHIVO CCAMOVIM                             */
/*-------------------------------------------------------------------*/

             RTVMBRD    FILE(&BCCADAT/CCAMOVIM) MBR(*FIRST) +
                                              NBRCURRCD(&XREG)
    /*       CALL       PGM(&BEXECLP/CCA560P)     */

             RTVMBRD    FILE(&BCCADAT/CCAMOVIMR) NBRCURRCD(&XREG)
             RTVMBRD    FILE(&BCCADAT/CCAMOERR)  NBRCURRCD(&XREG1)

             IF         COND(&XREG *EQ 0 *AND &XREG1 *EQ 0) THEN(DO)
                        GOTO CMDLBL(ACTUALIZAR)
             ENDDO
 PANTA05:
             CHGVAR     VAR(&IN01)     VALUE('0')
             CHGVAR     VAR(&IN03)     VALUE('0')
             CHGVAR     VAR(&REG)      VALUE(&XREG)
             CHGVAR     VAR(&REG1)     VALUE(&XREG1)

             SNDRCVF    RCDFMT(PANTALLA05)
             IF         COND(&IN03 = '1') THEN(GOTO CMDLBL(DESBLOQUEA))
             IF         COND(&IN01 = '1') THEN(GOTO CMDLBL(ACTUALIZAR))
             GOTO       CMDLBL(PANTA05)

/*-------------------------------------------------------------------*/
/* Actualización de Movimiento.                                      */
/*-------------------------------------------------------------------*/
ACTUALIZAR:
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA580    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA580  - +
                        Actualización Movimiento') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(&BCCADAT/CCAMOVACE)
             RTVMBRD    FILE(&BCCADAT/CCAMOVIM) MBR(*FIRST) +
                          NBRCURRCD(&REGS1)
             RTVMBRD    FILE(&BCCADAT/CCAMOVDIF) MBR(*FIRST) +
                          NBRCURRCD(&REGS2)
             IF         COND(&REGS1 *GT 0 *OR &REGS2 *GT 0) THEN(DO)
             CPYF       FROMFILE(CCAMOVIM) TOFILE(CCAMOVACE) +
                          MBROPT(*REPLACE)
             MONMSG     MSGID(CPF2869)
             MONMSG     MSGID(CPF2817)
             CPYF       FROMFILE(CCAMOVDIF) TOFILE(CCAMOVACE) +
                          MBROPT(*ADD)
             MONMSG     MSGID(CPF2869)
             ENDDO
             CLRPFM     FILE(&BCCADAT/CCAMOVDIF)
             OVRDBF     FILE(CCAMAEAHO) TOFILE(&BCCADAT/CCAMAEAHO)
             OVRDBF     FILE(CCAMOVACE) TOFILE(&BCCADAT/CCAMOVAC01)
             OVRDBF     FILE(CCAMOVDIF) TOFILE(&BCCADAT/CCAMOVDIF)
             OVRDBF     FILE(PLTDIAFST) TOFILE(&PLTDAT/PLTDIAFST)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA580)
             DLTOVR     FILE(*ALL)
    /*       CALL       PGM(&BEXECLP/CCA580P)         */
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA580    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*-------------------------------------------------------------------*/
/* Reporte de Movimiento Rechazado                                   */
/*-------------------------------------------------------------------*/
    REPMTORECH:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA599  - +
                        Reporte de Movimiento Rechazado') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             DLTSPLF    FILE(CCA599R)
             MONMSG     MSGID(CPF3300)
             OVRPRTF    FILE(CCA599R) TOFILE(&BEXERLU/CCA599R) +
                        SPLFNAME(CCARECHAZO)

             OVRDBF     FILE(CCAMOVIMR) TOFILE(&BCCADAT/CCAMOVIMR)
             OVRDBF     FILE(CCACODTRN) TOFILE(&BCCADAT/CCACODTRN)
             OVRDBF     FILE(CCATABLAS) TOFILE(&BCCADAT/CCATABLAS)
             OVRDBF     FILE(PLTAGCORI) TOFILE(&BSECOBJ/PLTAGCORI)
             OVRDBF     FILE(PLTSUCURS) TOFILE(&PLTDAT/PLTSUCURS)
             CALL       PGM(&BEXEOBJ/CCA599) PARM(&XUSRING)

      /*     CALL       PGM(&BEXECLP/CCA599P)   */

/*-------------------------------------------------------------------*/
/* Generación de Detalle de Retrofechas.                             */
/*-------------------------------------------------------------------*/

    GENDETRET:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA590  - +
                        Generación Detalle Retrofechas') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*********************************************************************/
/* SE ORDENA ARCHIVO A PROCESAR POR FECHA ORIGEN (&CCAMOVIM).         */
/* EL ARCHIVO CAMOVTMP SE USA EN ESTE PROCESO COMO TEMPORAL.         */
/*********************************************************************/

             CLRPFM     FILE(&BCCADAT/CCAMOVRF1)

             RTVMBRD    FILE(&BCCADAT/CCAMOVIM) MBR(*FIRST)  +
                        NBRCURRCD(&REGS1)

             IF (&REGS1 *NG 0) GOTO GENCONRET

/*********************************************************************/
/* SE GENERA BASE (CCAMOVRF1) PARA GENERACION POSTERIOR DE ARCHIVO DE */
/* CONTROL DE RETROFECHAS POR CUENTA Y FECHA (CCARETROF).            */
/*********************************************************************/

             OVRDBF     FILE(CCAMOVIM)  TOFILE(&BCCADAT/CCAMOVIM02)
             OVRDBF     FILE(CCAMOVACE) TOFILE(&BCCADAT/CCAMOVRF1)
             OVRDBF     FILE(PLTDIAFST) TOFILE(&PLTDAT/PLTDIAFST)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA590)

/*           CALL       PGM(&BEXECLP/CCA590P) PARM(&FILE)          */

/*-------------------------------------------------------------------*/
/* Generación de Consolidación de Retrofechas por Cuenta.            */
/*-------------------------------------------------------------------*/

    GENCONRET:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA600P - +
                        Generación Consolidación Retrofechas') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA600P)                      */

/*-------------------------------------------------------------------*/
/* Actualización de Ajustes de Retrofecha en Causación.              */
/*-------------------------------------------------------------------*/

    ACTAJURET:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA601  - +
                        Causación Diaria') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*********************************************************************/
/* EL ARCHIVO DE CAUSACION DEL DIA (CCACAUHOY) SE DEBE LIMPIAR       */
/* AL COMIENZO DEL PROCESO BATCH.                                    */
/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA601    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
             CLRPFM     FILE(&BCCADAT/CCACAUSAS)
             CLRPFM     FILE(&BCCADAT/CCACAUHOY)
             OVRDBF     FILE(CCAMAEAHO) TOFILE(&BCCADAT/CCAMAEAHO)
             OVRDBF     FILE(CCACAUSAC) TOFILE(&BCCADAT/CCACAUSAS)
             OVRDBF     FILE(CCACAUHOY) TOFILE(&BCCADAT/CCACAUHOY)
             OVRDBF     FILE(CCATRAPRO) TOFILE(&BCCADAT/CCATRAPRO)
             OVRDBF     FILE(CCACODPRO) TOFILE(&BCCADAT/CCACODPRO)
             OVRDBF     FILE(CLIMAE)    TOFILE(&CLIDAT/CLIMAE)
             OVRDBF     FILE(CCAPARGEN) TOFILE(&BCCADAT/CCAPARGEN)
             OVRDBF     FILE(PLTDIAFST) TOFILE(&PLTDAT/PLTDIAFST)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA601) PARM(&XUSRING)
             DLTOVR     FILE(*ALL)
             RTVMBRD    FILE(&BCCADAT/CCACAUSAS) MBR(*FIRST) +
                              NBRCURRCD(&REGS1)

             IF (&REGS1 *GT 0) DO
                CPYF    FROMFILE(&BCCADAT/CCACAUSAS) +
                        TOFILE(&BCCADAT/CCACAUSAC) FROMMBR(*FIRST) +
                        TOMBR(*FIRST) MBROPT(*ADD)
/*----------- COPIA REGISTROS PARA ABONO DIARIO/MENSUAL/TRIMESTRAL---*/
                CPYF    FROMFILE(&BCCADAT/CCACAUSAS) +
                        TOFILE(&BCCADAT/CCAABODIA) FROMMBR(*FIRST) +
                        TOMBR(*FIRST) MBROPT(*ADD) INCREL((*IF +
                        INDMRT *EQ 1))
                CPYF    FROMFILE(&BCCADAT/CCACAUSAS) +
                        TOFILE(&BCCADAT/CCAABOMES) FROMMBR(*FIRST) +
                        TOMBR(*FIRST) MBROPT(*ADD) INCREL((*IF +
                        INDMRT *EQ 2))
                CPYF    FROMFILE(&BCCADAT/CCACAUSAS) +
                        TOFILE(&BCCADAT/CCAABOTRI) FROMMBR(*FIRST) +
                        TOMBR(*FIRST) MBROPT(*ADD) INCREL((*IF +
                        INDMRT *EQ 3))
                ENDDO
       /*    CALL       PGM(&BEXECLP/CCA601P)    */
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA601    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*-------------------------------------------------------------------*/
/* Generación/Abono de Intereses al Corte.                           */
/*-------------------------------------------------------------------*/
    GENABOINT:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA602  - +
                        Abono de Intereses al Corte') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*********************************************************************/
/*     EVALUA LA FECHA PARA VER SI ES INICIO DE MES O TRIMESTRE      */
/*********************************************************************/
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA502) PARM(&XFINMES &XFINTRI)

/*********************************************************************/
/* EL ARCHIVO DE CAUSACION DEL DIA, EL CUAL INCLUYE LA CAUSACION     */
/* GENERADA EN PASO ANTERIOR(CCA601)                                  */
/* ------- ABONO DIARIO ------------------------                     */
/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA602    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

                CLRPFM  FILE(&BCCADAT/CCAMOVINT)

                RTVMBRD FILE(&BCCADAT/CCAABODIA) MBR(*FIRST) +
                        NBRCURRCD(&REGS1)

                IF (&REGS1 *NG 0) GOTO MENSUAL

                   OVRDBF  FILE(CCAMAEAHO) TOFILE(&BCCADAT/CCAMAEAHO)
                   OVRDBF  FILE(CCACAUSAC) TOFILE(&BCCADAT/CCAABODIA)
                   OVRDBF  FILE(CCAMOVINT) TOFILE(&BCCADAT/CCAMOVINT)
                   OVRDBF  FILE(CLIMAE)    TOFILE(&CLIDAT/CLIMAE)
                   OVRDBF  FILE(CCATRAPRO) TOFILE(&BCCADAT/CCATRAPRO)
                   OVRDBF  FILE(CCAPARGEN) TOFILE(&BCCADAT/CCAPARGEN)
                   OVRDBF  FILE(PLTDIAFST) TOFILE(&PLTDAT/PLTDIAFST)
                   OVRDBF  FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
                   CALL    PGM(&BEXEOBJ/CCA602) PARM(&XUSRING)

                   CLRPFM  FILE(&BCCADAT/CCAABODIA)

  MENSUAL:
                   IF (&XFINMES *EQ 'N') GOTO SEGENERO
                   RTVMBRD  FILE(&BCCADAT/CCAABOMES)  MBR(*FIRST) +
                            NBRCURRCD(&REGS1)

                   IF (&REGS1 *NG 0) GOTO TRIMESTRE

                   OVRDBF  FILE(CCACAUSAC) TOFILE(&BCCADAT/CCAABOMES)
                   OVRDBF  FILE(CCAMAEAHO) TOFILE(&BCCADAT/CCAMAEAHO)
                   OVRDBF  FILE(CCAMOVINT) TOFILE(&BCCADAT/CCAMOVINT)
                   OVRDBF  FILE(CLIMAE)    TOFILE(&CLIDAT/CLIMAE)
                   OVRDBF  FILE(CCATRAPRO) TOFILE(&BCCADAT/CCATRAPRO)
                   OVRDBF  FILE(CCAPARGEN) TOFILE(&BCCADAT/CCAPARGEN)
                   OVRDBF  FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
                   CALL    PGM(&BEXEOBJ/CCA602) PARM(&XUSRING)

                   DLTOVR     FILE(*ALL)

                   CLRPFM     FILE(&BCCADAT/CCAABOMES)

  TRIMESTRE:
                IF (&XFINTRI *EQ 'N') GOTO SEGENERO
                RTVMBRD  FILE(&BCCADAT/CCAABOTRI)  MBR(*FIRST)   +
                                        NBRCURRCD(&REGS1)
                IF (&REGS1 *NG 0) GOTO SEGENERO

                  OVRDBF FILE(CCACAUSAC) TOFILE(&BCCADAT/CCAABOTRI)
                  OVRDBF FILE(CCAMAEAHO) TOFILE(&BCCADAT/CCAMAEAHO)
                  OVRDBF FILE(CCAMOVINT) TOFILE(&BCCADAT/CCAMOVINT)
                  OVRDBF FILE(CLIMAE)    TOFILE(&CLIDAT/CLIMAE)
                  OVRDBF FILE(CCATRAPRO) TOFILE(&BCCADAT/CCATRAPRO)
                  OVRDBF FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
                  CALL   PGM(&BEXEOBJ/CCA602) PARM(&XUSRING)

                  DLTOVR     FILE(*ALL)

                  CLRPFM     FILE(&BCCADAT/CCAABOTRI)
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA602    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*********************************************************************/
/* SI SE GENERO MOVIMIENTO DE INTERESES Y RETENCION.                 */
/* SE PEGA ESTE MOVIMIENTO AL MOVIMIENTO ACEPTADO DEL DIA            */
/*********************************************************************/

  SEGENERO:

                  RTVMBRD FILE(&BCCADAT/CCAMOVINT) MBR(*FIRST) +
                          NBRCURRCD(&REGS1)

                  IF (&REGS1 *NE 0) DO
                    CPYF  FROMFILE(&BCCADAT/CCAMOVINT) +
                          TOFILE(&BCCADAT/CCAMOVACE) MBROPT(*ADD) +
                          FMTOPT(*MAP *DROP)
                ENDDO
       /*    CALL       PGM(&BEXECLP/CCA602P)    */

/*-------------------------------------------------------------------*/
/* Abono de Incentivos Ahorro Juvenil                                */
/*-------------------------------------------------------------------*/
    ABOINCJUV:
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA606    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA606  - +
                        Abono de Incentivo Juvenil ') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(&BCCADAT/CCAMOVINC)
             CLRPFM     FILE(&BCCADAT/CCAMOVNEG)
             CLRPFM     FILE(&BCCADAT/CCAMOVPNG)

             OVRDBF     FILE(CCAMAEAHO6)    TOFILE(&BCCADAT/CCAMAEAHO6)
             OVRDBF     FILE(CCAMOVINT)     TOFILE(&BCCADAT/CCAMOVINC)
             OVRDBF     FILE(CLIMAE)        TOFILE(&CLIDAT/CLIMAE)
             OVRDBF     FILE(CLITAB)        TOFILE(&CLIDAT/CLITAB)
             OVRDBF     FILE(PLTDIAFST)     TOFILE(&PLTDAT/PLTDIAFST)
             OVRDBF     FILE(PLTFECHAS)     TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA606) PARM(&XUSRING)

 /********************************************************************/
 /*  Generacion de Transacciones por Saldos de Negativos en          */
 /*  Cuentas de Ahorros Genera CCAMOVNEG y CCAMOVPNG                 */
 /********************************************************************/
             OVRDBF     FILE(CCAMOVNEG)     TOFILE(&BCCADAT/CCAMOVNEG)
             CALL       PGM(&BEXEOBJ/CCA201)
             OVRDBF     FILE(CCAMOVPNG)     TOFILE(&BCCADAT/CCAMOVPNG)
             CALL       PGM(&BEXEOBJ/CCA205)
 /********************************************************************/

             DLTOVR     FILE(*ALL)

             RTVMBRD  FILE(&BCCADAT/CCAMOVINC)  MBR(*FIRST) +
                             NBRCURRCD(&REGS1)

             RTVMBRD  FILE(&BCCADAT/CCAMOVNEG)  MBR(*FIRST) +
                             NBRCURRCD(&REGS4)

             RTVMBRD  FILE(&BCCADAT/CCAMOVPNG)  MBR(*FIRST) +
                             NBRCURRCD(&REGS5)

             IF (&REGS1 *NE 0)
                CPYF FROMFILE(&BCCADAT/CCAMOVINC) +
                     TOFILE(&BCCADAT/CCAMOVACE) MBROPT(*ADD) +
                     FMTOPT(*MAP *DROP)

             IF (&REGS4 *NE 0)
                CPYF FROMFILE(&BCCADAT/CCAMOVNEG) +
                     TOFILE(&BCCADAT/CCAMOVACE) MBROPT(*ADD) +
                     FMTOPT(*MAP *DROP)

             IF (&REGS5 *NE 0)
                CPYF FROMFILE(&BCCADAT/CCAMOVPNG) +
                     TOFILE(&BCCADAT/CCAMOVACE) MBROPT(*ADD) +
                     FMTOPT(*MAP *DROP)

        /*   CALL       PGM(&BEXECLP/CCA606P)           */

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA606    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*-------------------------------------------------------------------*/
/* Generación de Contabilidad del Dia. (Causación/Intereses).        */
/*-------------------------------------------------------------------*/

    GENCONDIA:
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA630    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA630  - +
                        Generación Contabilidad') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CHGVAR   VAR(&XPARM) VALUE(&XAGCORI *CAT &XUSRING)

             CLRPFM     FILE(&BCCADAT/CCAMOVTMP)
             CLRPFM     FILE(&BCCADAT/PLTTRNCCA)

             RTVMBRD  FILE(&BCCADAT/CCACAUHOY) MBR(*FIRST) +
                      NBRCURRCD(&REGS1)
             RTVMBRD    FILE(&BCCADAT/CCAMOVINT) MBR(*FIRST) +
                      NBRCURRCD(&REGS2)
             RTVMBRD    FILE(&BCCADAT/CCAMOVINC) MBR(*FIRST) +
                      NBRCURRCD(&REGS3)
             RTVMBRD    FILE(&BCCADAT/CCAMOVNEG) MBR(*FIRST) +
                      NBRCURRCD(&REGS4)
             RTVMBRD    FILE(&BCCADAT/CCAMOVPNG) MBR(*FIRST) +
                      NBRCURRCD(&REGS5)

             IF         COND(&REGS1 *NG 0 *AND &REGS2 *NG 0 *AND +
                          &REGS3 *NG 0 *AND &REGS4 *NG 0 *AND +
                          &REGS5 *NG 0) THEN(GOTO CMDLBL(REPCAUDIA))

               CPYF FROMFILE(&BCCADAT/CCACAUHOY) +
                    TOFILE(&BCCADAT/CCAMOVTMP) +
                    MBROPT(*REPLACE) FMTOPT(*MAP *DROP)
               MONMSG MSGID(CPF2817)
               CPYF FROMFILE(&BCCADAT/CCAMOVINT) +
                    TOFILE(&BCCADAT/CCAMOVTMP) MBROPT(*ADD) +
                    FMTOPT(*MAP *DROP)
               MONMSG MSGID(CPF2817)
               CPYF FROMFILE(&BCCADAT/CCAMOVINC) +
                    TOFILE(&BCCADAT/CCAMOVTMP) MBROPT(*ADD) +
                    FMTOPT(*MAP *DROP)
               MONMSG MSGID(CPF2817)
               CPYF FROMFILE(&BCCADAT/CCAMOVNEG) +
                    TOFILE(&BCCADAT/CCAMOVTMP) MBROPT(*ADD) +
                    FMTOPT(*MAP *DROP)
               MONMSG MSGID(CPF2817)
               CPYF FROMFILE(&BCCADAT/CCAMOVPNG) +
                    TOFILE(&BCCADAT/CCAMOVTMP) MBROPT(*ADD) +
                    FMTOPT(*MAP *DROP)
               MONMSG MSGID(CPF2817)

               OVRDBF FILE(CCAMOVTMP4) TOFILE(&BCCADAT/CCAMOVTMP4)
               OVRDBF FILE(CCACODTRN)  TOFILE(&BCCADAT/CCACODTRN)
               OVRDBF FILE(PLTTRNMON)  TOFILE(&BCCADAT/PLTTRNCCA)
               OVRDBF FILE(PLTFECHAS)  TOFILE(&BSECOBJ/PLTFECHAS)
               OVRDBF FILE(PLTAGCORI)  TOFILE(&BSECOBJ/PLTAGCORI)
               CALL   PGM(&BEXEOBJ/CCA630) PARM(&XPARM)

               DLTOVR     FILE(*ALL)
               CLRPFM     FILE(&BCCADAT/CCAMOVTMP)

      /*     CALL       PGM(&BEXECLP/CCA630P)         */
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA630    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*-------------------------------------------------------------------*/
/* Reporte de Causación Diaria.                                      */
/*-------------------------------------------------------------------*/
    REPCAUDIA:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA640P - +
                        Rep. Causación Diaria') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/* VG        CALL       PGM(&BEXECLP/CCA640P)                        */

/*-------------------------------------------------------------------*/
/* Reporte Mensual de Causacion.                                     */
/*-------------------------------------------------------------------*/
    REPMENCUA:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA650P - +
                        Reporte de Causación') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA650P)                        */

/*-------------------------------------------------------------------*/
/* Inactivación Automática de Cuentas.                               */
/*-------------------------------------------------------------------*/
    INAAUTCTA:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA660  - +
                        Inactivación Automática de Cuentas') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*********************************************************************/
/* SE EJECUTA PROGRAMA DE INACTIVACION.                              */
/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA660    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             OVRDBF     FILE(CCAMAEAHO5) TOFILE(&BCCADAT/CCAMAEAHO5)
             CALL       PGM(&BEXEOBJ/CCA660)

     /*      CALL       PGM(&BEXECLP/CCA660P)    */
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA660    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
/* Proceso contable de las Cuentas Inactivas                         */
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA661    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Ejecutando Programa CCA665  - +
                          Contabilizacion Cuentas Inactivas') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(&BCCADAT/PLTCCAINA)

             OVRDBF     FILE(CCAMAEAH12) TOFILE(&BCCADAT/CCAMAEAH12)
             OVRDBF     FILE(PLTCCAINA)  TOFILE(&BCCADAT/PLTCCAINA)
             OVRDBF     FILE(PLTTRNMON)  TOFILE(&PLTDAT/PLTTRNMON)
             OVRDBF     FILE(CLIMAE)     TOFILE(&CLIDAT/CLIMAE)
 /*          CALL       PGM(&BEXEOBJ/CCA661) PARM(&BCODEMP &XAGCORI +
                          &XUSRING)                   */
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA661    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
/* Proceso contable de las Cuentas Canceladas                        */
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA662    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Ejecutando Programa CCA662  - +
                          Contabilizacion Cuentas Canceladas') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(&BCCADAT/PLTCCACAN)

             OVRDBF     FILE(CCAMAEAH14) TOFILE(&BCCADAT/CCAMAEAH14)
             OVRDBF     FILE(PLTCCACAN)  TOFILE(&BCCADAT/PLTCCACAN)
             OVRDBF     FILE(CLIMAE)     TOFILE(&CLIDAT/CLIMAE)
 /*          CALL       PGM(&BEXEOBJ/CCA662) PARM(&BCODEMP &XAGCORI +
                          &XUSRING)             */
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA662    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*-------------------------------------------------------------------*/
/* Proceso contable de ENVIO A FONDO MUTUO                           */
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA664    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Ejecutando Programa CCA664  - +
                          Contabilizacion FONDO MUTUO') +
                          TOPGMQ(*EXT) MSGTYPE(*STATUS)

             CLRPFM     FILE(&BCCADAT/PLTCCAMUT)

             OVRDBF     FILE(CCAMAEAH13) TOFILE(&BCCADAT/CCAMAEAH13)
             OVRDBF     FILE(PLTCCAMUT)  TOFILE(&BCCADAT/PLTCCAMUT)
             OVRDBF     FILE(CLIMAE)     TOFILE(&CLIDAT/CLIMAE)
             CALL       PGM(&BEXEOBJ/CCA664) PARM(&XUSRING &XAGCORI)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA664    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*-------------------------------------------------------------------*/
/* Actualizacíon del Archivo de Balance (CCABALANC).                 */
/*    a partir del CCAMOVIM                                          */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA670P - +
                        Actualización Archivo de Balance') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA670P)                         */

/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCAACTREM ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             OVRDBF     FILE(PLTREMMA15) TOFILE(&PLTDAT/PLTREMMA15)
             OVRDBF     FILE(CCAMAEAHO)  TOFILE(&BCCADAT/CCAMAEAHO)
             CALL       PGM(&BEXEOBJ/CCAACTREM)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCAACTREM ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*********************************************************************/
/* SE ACTUALIZA ARCHIVO DE BALANCE.                                  */
/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA671    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
             OVRDBF     FILE(PLTCUADRE)  TOFILE(&PLTDAT/PLTCUADRE)
             OVRDBF     FILE(PLTFECHAS)  TOFILE(&BSECOBJ/PLTFECHAS)
             OVRDBF     FILE(PLTAGCORI)  TOFILE(&BSECOBJ/PLTAGCORI)
             OVRDBF     FILE(CCAMAEAHO1) TOFILE(&BCCADAT/CCAMAEAHO1)
             OVRDBF     FILE(CLIMAE)     TOFILE(&CLIDAT/CLIMAE)
             CALL       PGM(&BEXEOBJ/CCA671)
             DLTOVR     FILE(*ALL)

      /*     CALL       PGM(&BEXECLP/CCA671P)       */
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA671    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*********************************************************************/
/* SE ACTUALIZA ARCHIVO DE BALANCE.                                  */
/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA672    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             OVRDBF     FILE(PLTCUADRE) TOFILE(&PLTDAT/PLTCUADRE)
             OVRDBF     FILE(CCAMOVACE) TOFILE(&BCCADAT/CCAMOVACE)
             CALL       PGM(&BEXEOBJ/CCA672)
             DLTOVR     FILE(*ALL)

      /*     CALL       PGM(&BEXECLP/CCA672P)       */

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA672    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
/* Reporte de Fichas de Cuenta.                                      */
/*-------------------------------------------------------------------*/

/*           SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +     */
/*                      MSGDTA('Ejecutando Programa CCA680P - +     */
/*                      Rep. Fichas de Cuenta') +                   */
/*                      TOPGMQ(*EXT) MSGTYPE(*STATUS)               */
/* VG        CALL       PGM(&BEXECLP/CCA680P)                        */

/*-------------------------------------------------------------------*/
/* Reporte de Saldos Diarios.                                        */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA690P - +
                        Rep. Saldos Diarios (Activas)') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
             CHGVAR     VAR(&PARM1) VALUE('0')
/*           CALL       PGM(&BEXECLP/CCA690P) PARM(&PARM1)           */

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA690P - +
                        Rep. Saldos Diarios (Custodia)') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
             CHGVAR     VAR(&PARM1) VALUE('1')
/*           CALL       PGM(&BEXECLP/CCA690P) PARM(&PARM1)         */

/*-------------------------------------------------------------------*/
/* Reporte Movimiento Diario por Cuenta.                             */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA700P - +
                        Rep. Movimiento Diario por Cuenta') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA700P)                        */

/*-------------------------------------------------------------------*/
/* Adición del Movimiento Aceptado al Histórico.                     */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA710P - +
                        Adición Movimiento al Histórico') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*********************************************************************/
/* SE ADICIONAN AL HISTORICO LOS MOVIMIENTOS QUE POR SU FECHA VALOR  */
/* HAYAN SIDO APLICADOS EN EL DIA.                                   */
/*********************************************************************/
             CLRPFM     FILE(&BHISTOR/CCAHISTMP)
             MONMSG     MSGID(CPF2817)
             MONMSG     MSGID(CPF3133)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA710    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             OVRDBF     FILE(CCAMOVIM)  TOFILE(&BCCADAT/CCAMOVACE)
             OVRDBF     FILE(CCAHISTOR) TOFILE(&BHISTOR/CCAHISTMP)
             OVRDBF     FILE(CCACODTRN) TOFILE(&BCCADAT/CCACODTRN)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA710)

             DLTOVR     FILE(*ALL)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA710    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*********************************************************************/
/* SE ORDENA ARCHIVO HISTORICO DE MOVIMIENTO.                        */
/*********************************************************************/

             RTVMBRD    FILE(&BHISTOR/CCAHISTOR) MBR(*FIRST) +
                        NBRCURRCD(&REGS1)
         /*  CALL       PGM(&BEXECLP/CCA710P)       */

/*********************************************************************/
/* SE ADICIONAN AL HISTORICO LOS MOVIMIENTOS QUE POR SU FECHA VALOR  */
/* HAYAN SIDO APLICADOS EN EL DIA.                                   */
/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA711    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

/*           CLRPFM     FILE(&BHISTOR/CCAHISDIF)                */
             CLRPFM     FILE(&BHISTOR/CCADIFTMP)
             OVRDBF     FILE(CCAMOVIM)  TOFILE(&BCCADAT/CCAMOVDIF)
             OVRDBF     FILE(CCACODTRN) TOFILE(&BCCADAT/CCACODTRN)
             OVRDBF     FILE(CCAHISDIF) TOFILE(&BHISTOR/CCADIFTMP)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA711)

             DLTOVR     FILE(*ALL)

/*           CALL       PGM(&BEXECLP/CCA711P)    */

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA711    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
/* Actualización de Acumulados Anuales y Mensuales. Solo Cierre.     */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA720P - +
                        Generación de Acumulados Anuales y +
                        Mensuales') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA720P)                         */

/*-------------------------------------------------------------------*/
/* Generación de Extractos.                                          */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA730P - +
                        Generación de Extractos') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/* VG        CALL       PGM(&BEXECLP/CCA730P)                         */

/*-------------------------------------------------------------------*/
/* Reporte de Saldos de Ahorro - Proceso Mensual.                    */
/*-------------------------------------------------------------------*/

/*           SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +     */
/*                      MSGDTA('Ejecutando Programa CCA735P - +     */
/*                      Rep. Mensual de Saldos') +                  */
/*                      TOPGMQ(*EXT) MSGTYPE(*STATUS)               */
/*           CALL       PGM(&BEXECLP/CCA735P)                        */

/*-------------------------------------------------------------------*/
/* Reporte Cuadre Contable. Actualiza en CABALANC Saldos Fin Proceso.*/
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA740P - +
                        Rep. Cuadre Contable') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA740P)                         */

/*-------------------------------------------------------------------*/
/* Actualiza CABALTOT con Saldos Fin Proceso, Total Compañía.        */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA745P - +
                        Generación Registro Saldo Total Compañía') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA745P)                         */

/*-------------------------------------------------------------------*/
/* Reporte Control de Cuentas en Custodia. Aperturas, Cierres, Etc.  */
/*-------------------------------------------------------------------*/

/*           SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +      */
/*                      MSGDTA('Ejecutando Programa CCA750P - +      */
/*                      Rep. Especial Novedades de Custodia') +      */
/*                      TOPGMQ(*EXT) MSGTYPE(*STATUS)                */
/*           CALL       PGM(&BEXECLP/CCA750P)                         */

/*-------------------------------------------------------------------*/
/* Reporte General de Cuentas.                                       */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA755P - +
                        Rep. General Resumen de Cuentas') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*           CALL       PGM(&BEXECLP/CCA755P)                        */

/*-------------------------------------------------------------------*/
/* Creación Maestro en Línea (PLTDEPMAE), Junto con Sus Cuentas      */
/* Ficticias de Rechazos e Inicialización de Ind. Ficha Cliente,     */
/* Ind. de Resumen a Pedido y Copia de los Indicadores.              */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA760  - +
                        Creación Maestro para Plataforma de Caja') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*-------------------------------------------------------------------*/
/* BORRA ARCHIVO CCADEPMAE.                                          */
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA760    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             CLRPFM     FILE(&BCCADAT/CCADEPMAE)

             OVRDBF     FILE(CCAMAEAHO) TOFILE(&BCCADAT/CCAMAEAHO)
             OVRDBF     FILE(CCADEPMAE) TOFILE(&BCCADAT/CCADEPMAE)
             OVRDBF     FILE(CCACAUSAC) TOFILE(&BCCADAT/CCACAUSAC)
             OVRDBF     FILE(CCACODPRO) TOFILE(&BCCADAT/CCACODPRO)
             OVRDBF     FILE(CCAPARGEN) TOFILE(&BCCADAT/CCAPARGEN)
             OVRDBF     FILE(CLIMAE)    TOFILE(&CLIDAT/CLIMAE)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             OVRDBF     FILE(PLTAGCORI) TOFILE(&BSECOBJ/PLTAGCORI)
             CALL       PGM(&BEXEOBJ/CCA760)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA760    ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
/* COPIA ARCHIVO DE RECHAZOS A PLATAFORMA                            */
/*-------------------------------------------------------------------*/
             CPYF       FROMFILE(&BCCADAT/CCAMOVIMR) +
                        TOFILE(&BPLTDAT/PLTMOVIMR) MBROPT(*ADD) +
                        FMTOPT(*MAP *DROP)
             MONMSG     MSGID(CPF2869)
             MONMSG     MSGID(CPF2817)

             CALL       PGM(INIFACEMP) PARM(&PLTDAT 'PLTMOVIMR ')
/*-------------------------------------------------------------------*/

        /*   CALL       PGM(&BEXECLP/CCA760P)    */

/*-------------------------------------------------------------------*/
/* Depura el archivo PLTDEPMAE a Partir del Archivo CANOVCIE.        */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA765  - +
                        Depuración PLTDEPMAE a Partir del CANOVCIE') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

             RTVMBRD    FILE(&BCCADAT/CCANOVCIE) MBR(*FIRST) +
                        NBRCURRCD(&XREG)

             IF         COND(&XREG *LE 0) THEN(GOTO CMDLBL(DEPROTPRO))

             OVRDBF     FILE(CCANOVCIE) TOFILE(&BCCADAT/CCANOVCIE)
             OVRDBF     FILE(CCADEPMAE) TOFILE(&BCCADAT/CCADEPMAE)
             CALL       PGM(&BEXEOBJ/CCA765)

             CPYF       FROMFILE(&BCCADAT/CCANOVCIE) +
                        TOFILE(&BCCADAT/CCANOVCIT) +
                        MBROPT(*REPLACE) CRTFILE(*YES)
             CLRPFM     FILE(&BCCADAT/CCANOVCIE)

      /*     CALL       PGM(&BEXECLP/CCA765P)         */

/*-------------------------------------------------------------------*/
/* Depuración CACAUSAC, Rotación Promedios Fin de Mes.               */
/*-------------------------------------------------------------------*/
  DEPROTPRO:
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA770P - +
                        Depuración CACAUSAC, Rotación Promedios') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)

/*********************************************************************/
/* SI EXISTE INDICACION DE HACER CIERRE, SOLO SE COPIAN EN CCACAUSAS  */
/* LOS REGISTROS DE FECHA ORIGEN MAYOR A LA DE CORTE Y SE ACTUALIZAN */
/* Y ROTAN LOS PROMEDIOS EN EL MAESTRO. EN CASO CONTRARIO NO SE      */
/* ACTUALIZA EL MAESTRO Y EL CCACAUSAS SERA IGUAL AL CCACAUSAC.        */
/*********************************************************************/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA770    ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             CLRPFM     FILE(&BCCADAT/CCACAUSAS)

             OVRDBF     FILE(PLTFECHAS)     TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA502) PARM(&XFINMES &XFINTRI)

             OVRDBF     FILE(CCAMAEAHO)     TOFILE(&BCCADAT/CCAMAEAHO)
             OVRDBF     FILE(CCACAUSAC)     TOFILE(&BCCADAT/CCACAUSAC)
             OVRDBF     FILE(CCACAUSAS)     TOFILE(&BCCADAT/CCACAUSAS)
             OVRDBF     FILE(CCAPARGEN)     TOFILE(&BCCADAT/CCAPARGEN)
             CALL       PGM(&BEXEOBJ/CCA770)

             IF         (&XFINMES *EQ 'S') THEN(DO)
                        CPYF FROMFILE(&BCCADAT/CCACAUSAC) +
                             TOFILE(&BPLTDAT/PLTCAUSAC) MBROPT(*ADD) +
                             FMTOPT(*MAP *DROP)
             CALL       PGM(INIFACEMP) PARM(&BPLTDAT PLTCAUSAC)
             ENDDO
             DLTOVR     FILE(*ALL)

             CLRPFM     FILE(&BCCADAT/CCACAUSAC)

             RTVMBRD    FILE(&BCCADAT/CCACAUSAS) MBR(*FIRST) +
                        NBRCURRCD(&REGS1)

             IF (&REGS1 *NG 0) GOTO REPGENSLD

             CPYF      FROMFILE(&BCCADAT/CCACAUSAS)    +
                       TOFILE(&BCCADAT/CCACAUSAC)      +
                       FROMMBR(*FIRST) TOMBR(*FIRST)  +
                       MBROPT(*REPLACE)
             MONMSG     MSGID(CPF2817)

             CLRPFM     FILE(&BCCADAT/CCACAUSAS)

      /*     CALL       PGM(&BEXECLP/CCA770P)        */

  REPGENSLD:

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCA770    ' '2' &XINDCTL)

/*-------------------------------------------------------------------*/
/* Reporte General de Saldos Promedio.                               */
/*-------------------------------------------------------------------*/
/*           SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +      */
/*                      MSGDTA('Ejecutando Programa CCA775P - +      */
/*                      Rep. General de Saldos Promedios') +         */
/*                      TOPGMQ(*EXT) MSGTYPE(*STATUS)                */
/*           CALL       PGM(&BEXECLP/CCA775P)                         */

/*-------------------------------------------------------------------*/
/* Generación Miembro Actual del CAEXTRAC.                           */
/*-------------------------------------------------------------------*/

/*           SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +     */
/*                      MSGDTA('Ejecutando Programa CCA780P - +     */
/*                      Generación Miembro CAEXTRAC en CAEXTRAC') + */
/*                      TOPGMQ(*EXT) MSGTYPE(*STATUS)               */
/* VG        CALL       PGM(&BEXECLP/CCA780P)                        */

/*-------------------------------------------------------------------*/
/* Depura Cuentas Cerradas en Maestro y Acumulado.                   */
/*-------------------------------------------------------------------*/

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA790P - +
                        Depuración Cuentas Cerradas en Maestro') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/* VG        CALL       PGM(&BEXECLP/CCA790P)                         */
/*-------------------------------------------------------------------*/

/*-------------------------------------------------------------------*/
/* SE LLAMA AL PROGRAMA QUE RETORNA LAS FECHAS DE PROCESO.           */
/*-------------------------------------------------------------------*/

             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(CCA500) PARM(&FECHAS)

             CHGVAR     VAR(&MESDIA) VALUE(%SST(&FECHAS 13 4))
             CHGVAR     VAR(&NOMMAE) VALUE('CCAMAE' *CAT &MESDIA)
/*-------------------------------------------------------------------*/
/* Transmite archivos CCA para la Tesoreria                          */
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCATRANSF ' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             CALL       PGM(&BEXECLP/CCATRANSF) PARM(&XFECHOY)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCATRANSF ' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
/* Saca copia del archivo final para inicio del dia siguiente.       */
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS1' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             CPYF       FROMFILE(&BCCADAT/PLTTRNCCA) +
                          TOFILE(&BHISTOR/PLTTRNCCAH) +
                          MBROPT(*ADD) FMTOPT(*MAP *DROP)
             MONMSG     MSGID(CPF2817)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS1' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS2' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             CPYF       FROMFILE(&BHISTOR/CCAHISTMP) +
                          TOFILE(&BHISTOR/CCAHISTOR) +
                          MBROPT(*ADD) FMTOPT(*MAP *DROP)
             MONMSG     MSGID(CPF2817)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS2' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS3' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             CPYF       FROMFILE(&BHISTOR/CCADIFTMP) +
                        TOFILE(&BHISTOR/CCAHISDIF) +
                        MBROPT(*REPLACE) FMTOPT(*MAP *DROP)
             MONMSG     MSGID(CPF2817)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS3' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS4' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             CPYF       FROMFILE(&BCCADAT/CCAMAEAHO) +
                          TOFILE(&BCCADAT/&NOMMAE) +
                          MBROPT(*REPLACE) CRTFILE(*YES) +
                          FMTOPT(*MAP *DROP)
             MONMSG     MSGID(CPF2817)

             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCACOPIAS4' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
/*-------------------------------------------------------------------*/
        /*   CALL       PGM(&BEXECLP/CCACOPIAP)   */
/*-------------------------------------------------------------------*/
/* Proyección de Fechas. (Proceso y Corte).                          */
/*-------------------------------------------------------------------*/
             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG)          +
                        MSGDTA('Ejecutando Programa CCA800P - +
                        Proyección de Fechas (Proceso y Corte)') +
                        TOPGMQ(*EXT) MSGTYPE(*STATUS)
/*********************************************************************/
/* LA FECHA DE PROCESO SE PROYECTA UN DIA HABIL ADELANTE.            */
/* LA FECHA DE CORTE SE PROYECTA AL ULTIMO DIA HABIL DEL MES QUE     */
/* SIGUE, UNICAMENTE SI SE HIZO CORTE EN ESTE PROCESO.               */
/*********************************************************************/

             OVRDBF     FILE(CCACODPRO) TOFILE(&BCCADAT/CCACODPRO)
             OVRDBF     FILE(CCAPARGEN) TOFILE(&BCCADAT/CCAPARGEN)
             OVRDBF     FILE(PLTDIAFST) TOFILE(&PLTDAT/PLTDIAFST)
             OVRDBF     FILE(PLTFECHAS) TOFILE(&BSECOBJ/PLTFECHAS)
             CALL       PGM(&BEXEOBJ/CCA800)

        /*   CALL       PGM(&BEXECLP/CCA800P)        */

/*-------------------------------------------------------------------*/
/* Saca copia del archivo final para inicio del dia siguiente.       */
/*-------------------------------------------------------------------*/
/*           CPYF       FROMFILE( &BCCADAT/CCAMAEAHO) +              */
/*                      TOFILE( &BCCADAT/CCAMAEINI) +                */
/*                      MBROPT(*REPLACE) FMTOPT(*MAP *DROP)          */
/*-------------------------------------------------------------------*/
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCAPANTALL' '1' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)

             SNDRCVF    RCDFMT(PANTALLA06)
             DLTOVR     FILE(*ALL)
             CALL       PGM(&BEXECLP/CCAC085P) PARM('CCABATCH  ' +
                        'CCAPANTALL' '2' &XINDCTL)
             IF         COND(&XINDCTL *NE '0') THEN(GOTO FIN_PGM)
 DESBLOQUEA:
             DLCOBJ     OBJ((&BCCADAT/CCAMAEAHO *FILE *EXCL))
             MONMSG     MSGID(CPF2100)
 /*          DLCOBJ     OBJ((&BHISTOR/CCAHISTOR  *FILE *EXCL)) */
 /*          MONMSG     MSGID(CPF2100)                         */
             DLCOBJ     OBJ((&BCCADAT/CCAMOVACE  *FILE *EXCL))
             MONMSG     MSGID(CPF2100)

 FIN_PGM:    ENDPGM
