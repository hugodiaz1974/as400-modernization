/**
 * step05_interfaceReport.js
 * ═════════════════════════
 * Equivalente a: CCA520.CBL (Líneas 283-298 del CCACIERRE.CLP)
 * 
 * Función: Genera reporte de totales de interfaces consolidadas.
 *          En el AS/400 se llama 2 veces:
 *            - &NOVEDA='1' → Reporte de novedades (batch)
 *            - &NOVEDA='2' → Reporte de movimientos (batch)
 *          Lee CCATABINT y genera un resumen en log/JSON.
 */

async function interfaceReport(client) {
  console.log('═══ PASO 5: CCA520 - Reporte Totales Interfaces ═══');

  const result = await client.query(
    'SELECT nomarc, descri, indnov, nroregbok, acucrebok, acudebbok, nroregber, acucreber, acudebber FROM CCATABINT'
  );

  console.log('  ┌─────────────┬──────────────────┬──────┬────────┬──────────────┬──────────────┬────────┐');
  console.log('  │ Interfaz    │ Descripción      │ Tipo │ Reg OK │ Créd OK      │ Déb OK       │ Reg ER │');
  console.log('  ├─────────────┼──────────────────┼──────┼────────┼──────────────┼──────────────┼────────┤');

  for (const row of result.rows) {
    const tipo = row.indnov == 1 ? 'NOM' : 'MON';
    const name = (row.nomarc || '').trim().padEnd(11);
    const desc = (row.descri || '').trim().substring(0, 16).padEnd(16);
    console.log(`  │ ${name} │ ${desc} │ ${tipo}  │ ${String(row.nroregbok).padStart(6)} │ ${String(row.acucrebok).padStart(12)} │ ${String(row.acudebbok).padStart(12)} │ ${String(row.nroregber).padStart(6)} │`);
  }
  console.log('  └─────────────┴──────────────────┴──────┴────────┴──────────────┴──────────────┴────────┘');
  console.log('  ✅ CCA520 completado.\n');
}

module.exports = { interfaceReport };
