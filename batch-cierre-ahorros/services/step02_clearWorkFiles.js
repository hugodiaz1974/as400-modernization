/**
 * step02_clearWorkFiles.js
 * ════════════════════════
 * Equivalente a: CLRPFM (Líneas 187-191 y 218-221 del CCACIERRE.CLP)
 * 
 * Función: Limpia todas las tablas temporales y de trabajo antes de iniciar.
 */

async function clearWorkFiles(client) {
  console.log('═══ PASO 2: CLRPFM - Limpieza de Archivos de Trabajo ═══');

  const tables = [
    'CCAEXTRAC', 
    'CCACAUHOY', 
    'CCAMOVIM', 
    'CCAMOERR', 
    'CCANOMON', 
    'CCAMOVBAT', 
    'CCACAUSAS',
    'PLTTRNCCA'
  ];

  for (const table of tables) {
    try {
      await client.query(`TRUNCATE TABLE ${table}`);
      console.log(`  Tabla ${table} vaciada.`);
    } catch (err) {
      console.log(`  ⚠️ Advertencia: No se pudo vaciar ${table} (puede que no exista).`);
    }
  }

  console.log('  ✅ Limpieza de archivos completada.\n');
}

module.exports = { clearWorkFiles };
