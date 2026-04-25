/**
 * step04_consolidateInterfaces.js
 * ════════════════════════════════
 * Equivalente a: CCA510.CBL (Línea 251 del CCACIERRE.CLP)
 * 
 * Función: Lee cada interfaz habilitada en CCATABINT y consolida sus
 *          registros en las tablas destino:
 *            - INDNOV=2 (monetarias)    → CCAMOVIM
 *            - INDNOV=1 (no monetarias) → CCANOMON
 * 
 * En el AS/400, CCA510 llamaba a CCA511P y CCA512P que leían archivos
 * físicos externos (CCABATCH, PLTTRNMON, etc.) y los copiaban.
 * En Node.js, este paso verifica que los archivos de entrada estén
 * disponibles en la BD y actualiza los acumuladores de CCATABINT.
 * 
 * Nota: En la arquitectura modernizada, los movimientos del día ya
 * llegan directamente a CCAMOVIM via API o carga previa. Este paso
 * se encarga de contabilizar los totales y actualizar CCATABINT.
 */

async function consolidateInterfaces(client) {
  console.log('═══ PASO 4: CCA510 - Consolidación de Interfaces ═══');

  // Leer interfaces habilitadas (INDHAB = 0 significa habilitada en AS/400)
  const interfaces = await client.query(
    'SELECT nomarc, descri, indnov, nomlib, nomdis FROM CCATABINT WHERE indhab = 0'
  );

  if (interfaces.rows.length === 0) {
    console.log('  No hay interfaces habilitadas para procesar.');
    console.log('  ✅ CCA510 completado (sin interfaces).\n');
    return { monetarias: 0, noMonetarias: 0 };
  }

  let totalMonetarias = 0;
  let totalNoMonetarias = 0;

  for (const intf of interfaces.rows) {
    if (intf.indnov === '2' || intf.indnov === 2) {
      // =========================================================
      // LÓGICA DE NEGOCIO CCA512: Enriquecimiento de Movimientos
      // =========================================================
      console.log(`  [MON] Ejecutando lógica CCA512 sobre CCAMOVIM...`);
      
      // 1. Cálculo de Indicador de Fecha Valor (FECVAL)
      // Si la fecha de efectividad (FVALOR) es mayor a la fecha de proceso (FORIGE), es diferido (2).
      await client.query(`
        UPDATE CCAMOVIM 
        SET fecval = CASE 
          WHEN fvalor > forige THEN 2 
          ELSE 1 
        END
        WHERE fecval IS NULL OR fecval = 0
      `);

      // 2. Inicialización de Estados
      // ESTTRN = 0 (Ingresado, pendiente de evaluar saldos en CCA580)
      await client.query(`
        UPDATE CCAMOVIM 
        SET esttrn = 0 
        WHERE esttrn IS NULL
      `);

      // =========================================================

      // Interfaz monetaria → contar registros en CCAMOVIM
      const countRes = await client.query('SELECT COUNT(*) as cnt FROM CCAMOVIM');
      const cnt = parseInt(countRes.rows[0].cnt);
      totalMonetarias += cnt;

      // Actualizar acumuladores batch en CCATABINT
      await client.query(`
        UPDATE CCATABINT SET nroregbok = $1 WHERE nomarc = $2
      `, [cnt, intf.nomarc]);

      console.log(`  [MON] ${intf.nomarc.trim()}: ${cnt} registros monetarios.`);
    } else if (intf.indnov === '1' || intf.indnov === 1) {
      // Interfaz no monetaria → contar registros en CCANOMON (si existe)
      try {
        const countRes = await client.query('SELECT COUNT(*) as cnt FROM CCANOMON');
        const cnt = parseInt(countRes.rows[0].cnt);
        totalNoMonetarias += cnt;
        await client.query(`
          UPDATE CCATABINT SET nroregbok = $1 WHERE nomarc = $2
        `, [cnt, intf.nomarc]);
        console.log(`  [NOM] ${intf.nomarc.trim()}: ${cnt} registros no monetarios.`);
      } catch (e) {
        console.log(`  [NOM] ${intf.nomarc.trim()}: tabla CCANOMON no disponible, saltando.`);
      }
    }
  }

  console.log(`  Total monetarias: ${totalMonetarias}, No monetarias: ${totalNoMonetarias}`);
  console.log('  ✅ CCA510 completado.\n');

  return { monetarias: totalMonetarias, noMonetarias: totalNoMonetarias };
}

module.exports = { consolidateInterfaces };
