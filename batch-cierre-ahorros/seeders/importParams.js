const fs = require('fs');
const pool = require('../config/database');
const path = require('path');

async function migrate(tableName, fileName, cols) {
  console.log(`Migrando ${tableName}...`);
  const data = fs.readFileSync(path.join(__dirname, '../../data', fileName), 'latin1');
  const lines = data.split('\n').filter(l => l.trim());
  
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(`TRUNCATE TABLE ${tableName}`);
    
    for (const line of lines) {
      const cleanLine = line.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, "");
      const parts = cleanLine.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(s => s.trim().replace(/^"|"$/g, ''));
      
      if (parts.length >= cols) {
        const values = parts.slice(0, cols).map(p => {
          if (p === '' || p === undefined || p === '.00' || p === ' ') return '0';
          if (/^-?\d+\.?\d*$/.test(p)) return p;
          return `'${p.replace(/'/g, "''")}'`;
        });
        await client.query(`INSERT INTO ${tableName} VALUES (${values.join(',')}) ON CONFLICT DO NOTHING`);
      }
    }
    await client.query('COMMIT');
    console.log(`${tableName} ok.`);
  } catch (e) {
    await client.query('ROLLBACK');
    console.error(`Error en ${tableName}: ${e.message}`);
  } finally {
    client.release();
  }
}

async function run() {
  await migrate('CCACODPRO', 'CCACODPRO', 19);
  await migrate('CCACODTAS', 'CCACODTAS', 18);
  await migrate('CCANOMTAS', 'CCANOMTAS', 9);
  await migrate('CCAPARGEN', 'CCAPARGEN', 46);
  await migrate('CCATABINT', 'CCATABINT', 22);
  await migrate('CCATRAPRO', 'CCATRAPRO', 9);
  process.exit(0);
}

run();
