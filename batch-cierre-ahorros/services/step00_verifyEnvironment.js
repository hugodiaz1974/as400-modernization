/**
 * step00_verifyEnvironment.js
 * ════════════════════════════
 * Equivalente a: PLT1001.CBL (Línea 146 del CLP aprox)
 * 
 * Función: Valida que el sistema esté listo para el cierre batch.
 *   - Verifica si ya se corrió el cierre para hoy.
 *   - Bloquea la tabla maestra para uso exclusivo del batch.
 */

const checkpoint = require('../utils/checkpointManager');

async function verifyEnvironment(client) {
  console.log('═══ PASO 0: PLT1001 - Verificación de Entorno y Bloqueo ═══');

  // 1. Obtener fecha de proceso
  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  if (fechaRes.rows.length === 0) throw new Error('No se pudo encontrar la fecha de proceso.');
  const fecpro = fechaRes.rows[0].fecpro;

  // 2. Verificar si el cierre ya terminó hoy
  const completed = await checkpoint.isStepCompleted(client, 11, fecpro, 'step30_dateProjection');
  
  if (completed) {
    throw new Error(`El cierre para la fecha ${fecpro} ya ha sido completado exitosamente.`);
  }

  // 3. Bloqueo exclusivo de la tabla maestra (Replica ALCOBJ *EXCL)
  console.log('  Solicitando bloqueo exclusivo de CCAMAEAHO...');
  await client.query('LOCK TABLE CCAMAEAHO IN EXCLUSIVE MODE');
  console.log('  ✅ Tabla CCAMAEAHO bloqueada correctamente.');

  console.log('  ✅ Verificación de entorno exitosa.\n');
  return fecpro;
}

module.exports = { verifyEnvironment };
