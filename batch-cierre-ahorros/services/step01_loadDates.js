/**
 * step01_loadDates.js
 * ═══════════════════
 * Equivalente a: CCA500.CBL (Línea 176 del CCACIERRE.CLP)
 * 
 * Función: Lee la tabla PLTFECHAS para el sistema de ahorros (CODSIS=11)
 *          y retorna las 4 fechas de proceso:
 *            - FECPRA: Fecha de proceso anterior (ayer)
 *            - FECPRO: Fecha de proceso actual   (hoy)
 *            - FECPRS: Fecha de proceso siguiente (mañana)
 *            - FECPSS: Fecha proceso subsiguiente (pasado mañana)
 * 
 * En el AS/400, CCA500 recibe un parámetro &FECHAS (32 chars) donde
 * retorna las 4 fechas concatenadas (8 chars cada una). En Node.js
 * retornamos un objeto con las 4 fechas como propiedades.
 */

const CODSIS_AHORROS = 11;

async function loadDates(client) {
  console.log('═══ PASO 1: CCA500 - Carga de Fechas de Proceso ═══');

  // Leer PLTFECHAS para CODSIS=11 (Ahorros)
  // En COBOL: MOVE 11 TO CODSIS OF REGFECHAS → READ PLTFECHAS
  const result = await client.query(
    'SELECT fecpra, fecpro, fecprs, fecpss FROM pltfechas WHERE codsis = $1',
    [CODSIS_AHORROS]
  );

  if (result.rows.length === 0) {
    throw new Error(
      `CCA500: No se encontró registro en PLTFECHAS para CODSIS=${CODSIS_AHORROS}. ` +
      'El proceso no puede continuar sin fechas de proceso.'
    );
  }

  const row = result.rows[0];

  const fechas = {
    fechaAyer:       row.fecpra,  // &XFECPRA = %SST(&FECHAS 1 8)
    fechaHoy:        row.fecpro,  // &XFECHOY = %SST(&FECHAS 9 8)
    fechaManana:     row.fecprs,  // &XFECMAN = %SST(&FECHAS 17 8)
    fechaPasadoMan:  row.fecpss   // &XFECPAM = %SST(&FECHAS 25 8)
  };

  console.log(`  Fecha Ayer:           ${fechas.fechaAyer}`);
  console.log(`  Fecha Hoy (proceso):  ${fechas.fechaHoy}`);
  console.log(`  Fecha Mañana:         ${fechas.fechaManana}`);
  console.log(`  Fecha Pasado Mañana:  ${fechas.fechaPasadoMan}`);
  console.log('  ✅ CCA500 completado.\n');

  return fechas;
}

module.exports = { loadDates };
