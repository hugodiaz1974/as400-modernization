const fs = require('fs');
const readline = require('readline');
const pool = require('../config/database');
const path = require('path');

async function importMaestro() {
  const filePath = path.join(__dirname, '../../data/CCAMAEAHO');
  console.log(`Iniciando migración masiva desde: ${filePath}`);

  if (!fs.existsSync(filePath)) {
    console.error('El archivo CSV CCAMAEAHO no existe en la ruta esperada.');
    process.exit(1);
  }

  const fileStream = fs.createReadStream(filePath, { encoding: 'latin1' }); // AS/400 suele usar codificaciones extendidas
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  const client = await pool.connect();
  
  try {
    // Limpiar la tabla antes de la carga inicial
    await client.query('TRUNCATE TABLE CCAMAEAHO');
    console.log('Tabla CCAMAEAHO vaciada correctamente. Preparando carga...');

    let count = 0;
    await client.query('BEGIN');
    
    for await (const line of rl) {
      if (!line.trim()) continue;
      
      // Limpiar caracteres nulos y otros caracteres de control que rompen el protocolo Postgres
      const cleanLine = line.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, "");

      // Separar por comas, considerando posibles comillas
      const parts = cleanLine.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(s => s.trim().replace(/^"|"$/g, ''));
      
      if (parts.length >= 82) {
        try {
          const values = parts.slice(0, 82).map(p => {
            if (p === '' || p === undefined || p === '.00') return '0';
            // Si es un número, enviarlo tal cual, si no, como string escapado
            if (/^-?\d+\.?\d*$/.test(p)) return p;
            return `'${p.replace(/'/g, "''").replace(/\\/g, "\\\\")}'`;
          });

          const query = `
            INSERT INTO CCAMAEAHO VALUES (${values.join(',')})
            ON CONFLICT (CODMON, CODSIS, CODPRO, AGCCTA, CTANRO) DO NOTHING;
          `;
          
          await client.query(query);
          count++;
          
          if (count % 1000 === 0) {
            console.log(`Progreso: ${count} cuentas migradas...`);
          }
        } catch (rowErr) {
          console.error(`Error en línea ${count + 1}:`, cleanLine);
          console.error('Error detail:', rowErr.message);
          // Opcional: continuar o fallar
          throw rowErr; 
        }
      }
    }

    await client.query('COMMIT');
    console.log(`\n¡Migración Completada Exitosamente! Se insertaron ${count} cuentas de ahorro.`);
  } catch (err) {
    if (client) await client.query('ROLLBACK');
    console.error('Error durante la importación masiva:', err);
  } finally {
    if (client) client.release();
    process.exit(0);
  }
}

importMaestro();
