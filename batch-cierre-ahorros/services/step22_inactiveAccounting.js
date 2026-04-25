/**
 * step22_inactiveAccounting.js
 * ════════════════════════════
 * Equivalente a: CCA661/CCA662/CCA664 (Líneas 976-1020 del CCACIERRE.CLP)
 */
async function inactiveAccounting(client) {
  console.log('═══ PASO 22: CCA661/662/664 - Contabilizar Inactivas/Canceladas/Mutuo ═══');
  // CCA661: Contabilizar cuentas inactivas
  await client.query('TRUNCATE TABLE PLTCCAINA');
  console.log('  CCA661: Contabilización cuentas inactivas (sin registros para procesar).');
  // CCA662: Contabilizar cuentas canceladas
  await client.query('TRUNCATE TABLE PLTCCACAN');
  console.log('  CCA662: Contabilización cuentas canceladas (sin registros para procesar).');
  // CCA664: Contabilizar fondo mutuo
  await client.query('TRUNCATE TABLE PLTCCAMUT');
  console.log('  CCA664: Contabilización fondo mutuo (sin registros para procesar).');
  console.log('  ✅ CCA661/662/664 completado.\n');
}
module.exports = { inactiveAccounting };
