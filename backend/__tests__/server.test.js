const request = require('supertest');
const { app, pool } = require('../server');
const jwt = require('jsonwebtoken');

// Asegúrate de que el secreto sea el mismo que usa el server.js
const JWT_SECRET = process.env.JWT_SECRET || 'banco_migracion_secreto_2026';

describe('QA Automatización Backend AS/400 Migración', () => {
    let authToken = '';
    let createdExonerationId = null;

    beforeAll(() => {
        // Generamos un token válido administrativo para los tests
        // Simulando que iniciamos sesión correctamente
        authToken = jwt.sign({
            id: 1, usuario: 'qa_admin', nombre_real: 'Usuario QA', rol: 'ADMIN'
        }, JWT_SECRET, { expiresIn: '1h' });
    });

    afterAll(async () => {
        // Limpieza de datos (Teardown)
        if (createdExonerationId) {
            await pool.query('DELETE FROM transaction_exemptions WHERE id = $1', [createdExonerationId]);
        }
        await pool.end(); // Necesario para que Jest no se quede esperando (Open Handles)
    });

    // ────────────────────────────────────────────────────────
    // MÓDULO 1: SEGURIDAD (JWT)
    // ────────────────────────────────────────────────────────
    describe('Requisitos de Seguridad', () => {
        it('TC-001: Debe rechazar peticiones sin Header Authorization', async () => {
            const response = await request(app).get('/api/exonerations');
            expect(response.status).toBe(401);
            expect(response.body.error).toMatch(/Acceso denegado/i);
        });

        it('TC-002: Debe rechazar peticiones con un JWT falso', async () => {
            const response = await request(app)
                .get('/api/exonerations')
                .set('Authorization', 'Bearer eyJhbFakeTokenInvalido.dfasdfag');
            expect(response.status).toBe(403);
            expect(response.body.error).toMatch(/inválido/i);
        });
    });

    // ────────────────────────────────────────────────────────
    // MÓDULO 2: CRUD EXONERACIONES (PLTEXOCOM)
    // ────────────────────────────────────────────────────────
    describe('Flujo CRUD de Exoneraciones', () => {

        it('TC-003: Rechazar POST si falta el Código de Convenio en un tipo validado (tipCli=4)', async () => {
            const payload = { binExo: "12345", tipCaj: "R", tipCli: "4", codCon: "", codPro: "01", canExo: 5 };
            const response = await request(app)
                .post('/api/exonerations')
                .set('Authorization', `Bearer ${authToken}`)
                .send(payload);

            expect(response.status).toBe(400);
            expect(response.body.error).toMatch(/Código de convenio/i);
        });

        it('TC-004: POST - Debe Crear exitosamente una exoneración con datos válidos', async () => {
            const payload = {
                binExo: "462896", tipCaj: "1", tipCli: "2", codCon: "", codPro: "101", canExo: 10
            };
            const response = await request(app)
                .post('/api/exonerations')
                .set('Authorization', `Bearer ${authToken}`)
                .send(payload);

            if (response.status !== 201) console.error("TC-004 Error:", response.body);
            expect(response.status).toBe(201);
            expect(response.body).toHaveProperty('id');
            createdExonerationId = response.body.id; // Guardamos el ID para usarlo luego
        });

        it('TC-005: PUT - Debe Modificar la exoneración previamente creada', async () => {
            expect(createdExonerationId).toBeDefined();
            
            const upPayload = {
                binExo: "482407", tipCaj: "2", tipCli: "4", codCon: "CONV-500", codPro: "102", canExo: 20
            };
            const response = await request(app)
                .put(`/api/exonerations/${createdExonerationId}`)
                .set('Authorization', `Bearer ${authToken}`)
                .send(upPayload);

            expect(response.status).toBe(200);
            expect(response.body.message).toMatch(/modificada exitosamente/i);
        });

        it('TC-006: PUT - Debe responder 404 si se intenta modificar un ID que no existe', async () => {
            const upPayload = {
                binExo: "462896", tipCaj: "1", tipCli: "1", codCon: "", codPro: "101", canExo: 1
            };
            const response = await request(app)
                .put(`/api/exonerations/9999999`) // ID improbable
                .set('Authorization', `Bearer ${authToken}`)
                .send(upPayload);

            expect(response.status).toBe(404);
            expect(response.body.error).toMatch(/no encontrada/i);
        });

        it('TC-007: DELETE - Debe retornar error 404 si el registro a borrar no existe', async () => {
             const response = await request(app)
                .delete(`/api/exonerations/9999999`)
                .set('Authorization', `Bearer ${authToken}`);

            expect(response.status).toBe(404);
            expect(response.body.error).toMatch(/no encontrada/i);
        });

        it('TC-008: DELETE - Debe suprimir la exoneración creada y dejar el ambiente limpio', async () => {
            const response = await request(app)
                .delete(`/api/exonerations/${createdExonerationId}`)
                .set('Authorization', `Bearer ${authToken}`);

            expect(response.status).toBe(200);
            expect(response.body.message).toMatch(/suprimida exitosamente/i);

            createdExonerationId = null; // Lo ponemos en nulo porque ya se borró
        });
    });
});
