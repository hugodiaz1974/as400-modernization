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
    
    if (!binExo || !tipCaj || !tipCli || !codPro || canExo === undefined) {
        return res.status(400).json({ error: "Faltan campos obligatorios" });
    }
    if (tipCli === '4' && (!codCon || codCon.trim() === '')) {
        return res.status(400).json({ error: "Código de convenio debe ser ingresado" });
    }

    try {
        const sql = `INSERT INTO transaction_exemptions (bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_ing) 
                     VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`;
        
        const codConFinal = tipCli === '4' ? codCon : '-';
        const result = await pool.query(sql, [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor]);
        
        // Grabar Log de Auditoría
        await pool.query(
            `INSERT INTO logexocom (accion, bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_mod) 
             VALUES ('Adicion', $1, $2, $3, $4, $5, $6, $7)`,
            [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor]
        );

        res.status(201).json({ id: result.rows[0].id, message: "Exoneración grabada exitosamente" });
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
    
    if (!binExo || !tipCaj || !tipCli || !codPro || canExo === undefined) {
        return res.status(400).json({ error: "Faltan campos obligatorios" });
    }
    if (tipCli === '4' && (!codCon || codCon.trim() === '')) {
        return res.status(400).json({ error: "Código de convenio debe ser ingresado" });
    }

    try {
        const codConFinal = tipCli === '4' ? codCon : '-';
        const sql = `UPDATE transaction_exemptions 
                     SET bin_exo = $1, tip_caj = $2, tip_cli = $3, cod_con = $4, cod_pro = $5, can_exo = $6, 
                         usr_mod = $7, fec_mod = CURRENT_TIMESTAMP
                     WHERE id = $8`;
        
        await pool.query(sql, [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor, id]);

        // Grabar Log
        await pool.query(
            `INSERT INTO logexocom (accion, bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_mod) 
             VALUES ('Cambio', $1, $2, $3, $4, $5, $6, $7)`,
            [binExo, tipCaj, tipCli, codConFinal, codPro, parseInt(canExo), actor]
        );

        res.json({ message: "Exoneración modificada exitosamente" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.delete('/api/exonerations/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const actor = req.user.usuario; // Extraído dinámicamente del JWT!
    try {
        const existing = await pool.query("SELECT * FROM transaction_exemptions WHERE id = $1", [id]);
        
        await pool.query("DELETE FROM transaction_exemptions WHERE id = $1", [id]);

        if (existing.rows.length > 0) {
            const row = existing.rows[0];
            await pool.query(
                `INSERT INTO logexocom (accion, bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_mod) 
                 VALUES ('Borrado', $1, $2, $3, $4, $5, $6, $7)`,
                [row.bin_exo, row.tip_caj, row.tip_cli, row.cod_con, row.cod_pro, row.can_exo, actor]
            );
        }

        res.json({ message: "Exoneración suprimida exitosamente" });
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
