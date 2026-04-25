const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || 'banco_migracion_secreto_2026';

// ──────────────────────────────────────────────────────────────
// Conexión a PostgreSQL (Reemplazo de DB2 en el AS/400)
// ──────────────────────────────────────────────────────────────
const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgres://admin:secreto123@localhost:5432/tarjeta_credito',
});

// Verificar conexión a la DB
async function initializeDatabase() {
    const client = await pool.connect();
    try {
        const result = await client.query("SELECT COUNT(*) AS total FROM clitab");
        console.log(`[DB] Tablas verificadas. CLITAB tiene ${result.rows[0].total} parámetros cargados.`);
    } finally {
        client.release();
    }
}

// ══════════════════════════════════════════════════════════════
// HELPER FUNCIONES AL ESTILO AS/400 (Paridad COBOL)
// ══════════════════════════════════════════════════════════════
async function getFecpro() {
    try {
        const res = await pool.query("SELECT fecpro FROM pltfechas WHERE codemp=1 AND codsis=5");
        return res.rows.length > 0 ? res.rows[0].fecpro : '20231025';
    } catch { return '20231025'; }
}

async function validateClitabStrict(tab, code) {
    if (code === '99' || code === '0') return false; // Bloqueo de modificador universal ("Todos")
    try {
        const result = await pool.query("SELECT 1 FROM clitab WHERE codtab=$1 AND codint=$2", [tab, parseInt(code)]);
        return result.rowCount > 0;
    } catch { return false; }
}

// ══════════════════════════════════════════════════════════════
// MIDDLEWARE DE SEGURIDAD JWT (Alternativa a perfiles de IBM i)
// ══════════════════════════════════════════════════════════════
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Formato: "Bearer [TOKEN]"

    if (!token) return res.status(401).json({ error: "Acceso denegado. Token no proporcionado." });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: "Sesión expirada o token inválido." });
        
        req.user = user; // Guardamos { id, usuario, nombre_real, rol } en el request
        next();
    });
}

// ══════════════════════════════════════════════════════════════
// API: AUTENTICACIÓN (LOGIN)
// ══════════════════════════════════════════════════════════════
app.post('/api/login', async (req, res) => {
    const { usuario, password } = req.body;

    if (!usuario || !password) {
        return res.status(400).json({ error: "Usuario y contraseña requeridos" });
    }

    try {
        // Buscar el usuario en la BD
        const result = await pool.query('SELECT * FROM usuarios_sistema WHERE usuario = $1 AND estado = 1', [usuario]);
        
        if (result.rows.length === 0) {
            return res.status(401).json({ error: "Usuario no existe o está inactivo." });
        }

        const user = result.rows[0];

        // Comparar contraseña con el hash guardado usando bcrypt
        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            return res.status(401).json({ error: "Contraseña incorrecta." });
        }

        // Generar Token JWT (equivale a iniciar la sesión en el terminal 5250)
        const tokenPayload = {
            id: user.id,
            usuario: user.usuario,
            nombre_real: user.nombre_real,
            rol: user.rol
        };

        const token = jwt.sign(tokenPayload, JWT_SECRET, { expiresIn: '8h' }); // Expira en 8 horas

        // Retornar token y datos básicos del usuario
        res.json({
            message: "Login exitoso",
            token,
            user: {
                usuario: user.usuario,
                nombre_real: user.nombre_real,
                rol: user.rol
            }
        });

    } catch (err) {
        console.error("Error en Login:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    }
});


// ══════════════════════════════════════════════════════════════
// API: CLITAB - Parámetros del Sistema (Reemplazo de LEER-CLITAB en COBOL)
// ══════════════════════════════════════════════════════════════

app.get('/api/parameters/:codtab', authenticateToken, async (req, res) => {
    const { codtab } = req.params;
    try {
        const result = await pool.query(
            "SELECT codtab, codint, codnom FROM clitab WHERE codtab = $1 AND estado = 1 ORDER BY codint",
            [codtab]
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/parameters', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query(
            "SELECT codtab, codint, codnom FROM clitab WHERE estado = 1 ORDER BY codtab, codint"
        );
        const grouped = {};
        result.rows.forEach(row => {
            if (!grouped[row.codtab]) grouped[row.codtab] = [];
            grouped[row.codtab].push({ codint: row.codint, codnom: row.codnom });
        });
        res.json(grouped);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ══════════════════════════════════════════════════════════════
// API: TRANSACTION_EXEMPTIONS - PLTEXOCOM (CRUD de Exoneraciones)
// ══════════════════════════════════════════════════════════════

app.get('/api/exonerations', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query("SELECT * FROM transaction_exemptions ORDER BY id DESC");
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/exonerations', authenticateToken, async (req, res) => {
    const { binExo, tipCaj, tipCli, codCon, codPro, canExo } = req.body;
    const actor = req.user.usuario; // Extraído dinámicamente del JWT!
    
    if (!binExo || !tipCaj || !tipCli || !codPro || canExo === undefined || isNaN(parseInt(canExo))) {
        return res.status(400).json({ error: "Faltan campos obligatorios o formato numérico inválido" });
    }
    
    // Paridad COBOL: Bloqueo de Convenio, y Modificador Universal
    if (tipCli === '4' && (!codCon || codCon.trim() === '')) {
        return res.status(400).json({ error: "Código de convenio debe ser ingresado" });
    }
    if (tipCli !== '4' && codCon && codCon.trim() !== '' && codCon.trim() !== '-') {
        return res.status(400).json({ error: "Código de convenio NO debe ser ingresado si no es tipo Convenio" });
    }
    if (binExo === '99' || tipCaj === '99' || tipCli === '99' || codPro === '99' || binExo === '0' || tipCaj === '0') {
        return res.status(400).json({ error: "No se permite parametrizar de forma universal (Código 0 o 99)." });
    }

    try {
        if (!(await validateClitabStrict(335, binExo))) return res.status(404).json({error: "BIN no parametrizado o universal"});
        if (!(await validateClitabStrict(333, tipCaj))) return res.status(404).json({error: "Cajero no parametrizado o universal"});
        if (!(await validateClitabStrict(334, tipCli))) return res.status(404).json({error: "Cliente no parametrizado o universal"});
        if (!(await validateClitabStrict(336, codPro))) return res.status(404).json({error: "Producto no parametrizado o universal"});

        const fecpro = await getFecpro();
        const codConFinal = tipCli === '4' ? codCon : null;

        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            
            const sql = `INSERT INTO transaction_exemptions (bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_ing, fec_ing) 
                         VALUES ($1, $2, $3, $4, $5, $6, $7, TO_TIMESTAMP($8::text, 'YYYYMMDD')) RETURNING id`;
            const result = await client.query(sql, [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor, fecpro]);
            
            // Grabar Log de Auditoría
            await client.query(
                `INSERT INTO logexocom (accion, bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_mod, fec_mod) 
                 VALUES ('Adicion', $1, $2, $3, $4, $5, $6, $7, TO_TIMESTAMP($8::text, 'YYYYMMDD'))`,
                [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor, fecpro]
            );

            await client.query('COMMIT');
            res.status(201).json({ id: result.rows[0].id, message: "Exoneración grabada exitosamente" });
        } catch (err) {
            await client.query('ROLLBACK');
            throw err;
        } finally {
            client.release();
        }
    } catch (err) {
        if (err.code === '23505') {
            return res.status(409).json({ error: "Concurrencia: Ya existe un parámetro para esta combinación." });
        }
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/exonerations/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { binExo, tipCaj, tipCli, codCon, codPro, canExo } = req.body;
    const actor = req.user.usuario; // Extraído dinámicamente del JWT!
    
    if (!binExo || !tipCaj || !tipCli || !codPro || canExo === undefined || isNaN(parseInt(canExo))) {
        return res.status(400).json({ error: "Faltan campos obligatorios o formato numérico inválido" });
    }
    if (tipCli === '4' && (!codCon || codCon.trim() === '')) {
        return res.status(400).json({ error: "Código de convenio debe ser ingresado" });
    }
    if (tipCli !== '4' && codCon && codCon.trim() !== '' && codCon.trim() !== '-') {
        return res.status(400).json({ error: "Código de convenio NO debe ser ingresado si no es tipo Convenio" });
    }
    if (binExo === '99' || tipCaj === '99' || tipCli === '99' || codPro === '99' || binExo === '0' || tipCaj === '0') {
        return res.status(400).json({ error: "No se permite parametrizar de forma universal (Código 0 o 99)." });
    }

    try {
        if (!(await validateClitabStrict(335, binExo))) return res.status(404).json({error: "BIN no parametrizado o universal"});
        if (!(await validateClitabStrict(333, tipCaj))) return res.status(404).json({error: "Cajero no parametrizado o universal"});
        if (!(await validateClitabStrict(334, tipCli))) return res.status(404).json({error: "Cliente no parametrizado o universal"});
        if (!(await validateClitabStrict(336, codPro))) return res.status(404).json({error: "Producto no parametrizado o universal"});

        const fecpro = await getFecpro();
        const codConFinal = tipCli === '4' ? codCon : null;

        const client = await pool.connect();
        try {
            await client.query('BEGIN');

            const lockCheck = await client.query("SELECT id FROM transaction_exemptions WHERE id = $1 FOR UPDATE", [id]);
            if (lockCheck.rowCount === 0) {
                await client.query('ROLLBACK');
                return res.status(404).json({ error: "Exoneración no encontrada para actualizar" });
            }

            const sql = `UPDATE transaction_exemptions 
                         SET bin_exo = $1, tip_caj = $2, tip_cli = $3, cod_con = $4, cod_pro = $5, can_exo = $6, 
                             usr_mod = $7, fec_mod = TO_TIMESTAMP($8::text, 'YYYYMMDD')
                         WHERE id = $9`;
            
            await client.query(sql, [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor, fecpro, id]);

            // Grabar Log
            await client.query(
                `INSERT INTO logexocom (accion, bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_mod, fec_mod) 
                 VALUES ('Cambio', $1, $2, $3, $4, $5, $6, $7, TO_TIMESTAMP($8::text, 'YYYYMMDD'))`,
                [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor, fecpro]
            );

            await client.query('COMMIT');
            res.json({ message: "Exoneración modificada exitosamente" });
        } catch (err) {
            await client.query('ROLLBACK');
            throw err;
        } finally {
            client.release();
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/exonerations/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const actor = req.user.usuario; // Extraído dinámicamente del JWT!
    try {
        const fecpro = await getFecpro();

        const client = await pool.connect();
        try {
            await client.query('BEGIN');

            const existing = await client.query("SELECT * FROM transaction_exemptions WHERE id = $1 FOR UPDATE", [id]);
            
            if (existing.rows.length === 0) {
                await client.query('ROLLBACK');
                return res.status(404).json({ error: "Exoneración no encontrada para eliminar" });
            }

            await client.query("DELETE FROM transaction_exemptions WHERE id = $1", [id]);

            const row = existing.rows[0];
            await client.query(
                `INSERT INTO logexocom (accion, bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_mod, fec_mod) 
                 VALUES ('Borrado', $1, $2, $3, $4, $5, $6, $7, TO_TIMESTAMP($8::text, 'YYYYMMDD'))`,
                [row.bin_exo, row.tip_caj, row.tip_cli, row.cod_con, row.cod_pro, row.can_exo, actor, fecpro]
            );

            await client.query('COMMIT');
            res.json({ message: "Exoneración suprimida exitosamente" });
        } catch (err) {
            await client.query('ROLLBACK');
            throw err;
        } finally {
            client.release();
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get('/api/audit-log', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query("SELECT * FROM logexocom ORDER BY id DESC LIMIT 100");
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ══════════════════════════════════════════════════════════════
// API: BATCH MONITORING - PLTCHECKPOINT
// ══════════════════════════════════════════════════════════════
app.get('/api/batch/status', authenticateToken, async (req, res) => {
    try {
        const currentFecproRes = await pool.query("SELECT fecpro FROM pltfechas WHERE codsis = 11");
        const currentFecpro = currentFecproRes.rows[0].fecpro;

        const result = await pool.query(`
            SELECT * FROM PLTCHECKPOINT 
            WHERE fecpro = (SELECT MAX(fecpro) FROM PLTCHECKPOINT)
            ORDER BY fecact ASC
        `);
        
        res.json({
            currentDate: currentFecpro,
            checkpoints: result.rows
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const { spawn } = require('child_process');

// ══════════════════════════════════════════════════════════════
// API: BATCH CONTROL - START PROCESS
// ══════════════════════════════════════════════════════════════
app.post('/api/batch/start', authenticateToken, async (req, res) => {
    try {
        // Verificar si ya hay un proceso corriendo (opcional, basado en checkpoints)
        const check = await pool.query("SELECT estado FROM PLTCHECKPOINT WHERE estado = 'INICIADO' LIMIT 1");
        if (check.rows.length > 0) {
            return res.status(409).json({ error: "Ya existe un proceso batch en ejecución." });
        }

        console.log(`[BATCH] Iniciando orquestador desde: ${process.cwd()}/batch-cierre-ahorros`);
        
        // Ejecutar el orquestador como un proceso independiente
        const batchProcess = spawn('node', ['orchestrator.js'], {
            cwd: './batch-cierre-ahorros', 
            detached: true,
            stdio: 'inherit' // Ver logs en la consola del backend
        });

        batchProcess.unref(); // Permitir que el proceso viva independientemente del servidor
        
        res.json({ message: "Proceso batch iniciado correctamente." });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ──────────────────────────────────────────────────────────────
// Arranque del servidor
// ──────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3001;

if (process.env.NODE_ENV !== 'test') {
    initializeDatabase()
        .then(() => {
            app.listen(PORT, '0.0.0.0', () => {
                 console.log(`\n========================================================`);
                console.log(`  Backend en ejecución en http://localhost:${PORT}`);
                console.log(`  Motor: PostgreSQL | SEGURIDAD JWT ACTIVA`);
                console.log(`========================================================\n`);
            });
        })
        .catch(err => {
            console.error('[ERROR FATAL] No se pudo conectar a PostgreSQL:', err.message);
            process.exit(1);
        });
}

module.exports = { app, pool };
