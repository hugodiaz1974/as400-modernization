# Agent Instructions: Core Bancario AWS (Modernización AS/400)

Este archivo define las reglas de oro y el contexto técnico para cualquier agente de IA que trabaje en este proyecto. **DEBE LEERSE AL INICIAR CADA SESIÓN.**

## 1. Misión del Proyecto
Migrar la lógica de negocio de tarjetas de crédito desde un IBM i (AS/400) hacia una arquitectura moderna (Node.js/React/Postgres) manteniendo **100% de paridad funcional**. El usuario es un experto en IBM i, por lo que las explicaciones deben usar analogías de este sistema (RPG, COBOL, DB2, CL, etc.).

## 2. Stack Tecnológico (The Tech Stack)
- **Frontend:** React.js con Vite. Arquitectura modular (Componentes + Context API).
- **Backend:** Node.js + Express.
- **Base de Datos:** PostgreSQL (Dockerizado).
- **Seguridad:** JWT (JSON Web Tokens) guardados en LocalStorage.
- **Entorno:** 100% Docker (`docker-compose.yml`).

## 3. Reglas de Oro (Business Rules)
- **Paridad de Fechas:** NUNCA usar `CURRENT_TIMESTAMP` para procesos de negocio. Usar siempre la función `getFecpro()` que consulta la tabla `PLTFECHAS` (Fecha contable bancaria).
- **Integridad Transaccional:** Todas las operaciones de escritura (POST/PUT/DELETE) DEBEN estar envueltas en transacciones SQL (`BEGIN/COMMIT/ROLLBACK`).
- **Auditoría Obligatoria:** Cada acción de escritura debe registrarse atómicamente en la tabla `LOGEXOCOM`.
- **Validación Estricta:** Antes de insertar en `transaction_exemptions`, se DEBE validar que los códigos existan en la tabla de parámetros `CLITAB`.
- **Prohibido Comodines:** No permitir la creación de exoneraciones con el código `99` (Todos) o `0` a menos que sea una consulta de lectura.

## 4. Estructura de Código
- **Frontend:** No crear componentes monolíticos. Usar la estructura en `src/components/` y mantener `AuthContext` como fuente de verdad para la sesión.
- **Backend:** Mantener la lógica en `server.js` pero asegurar el uso de `client = await pool.connect()` para garantizar que el rollback funcione correctamente.

## 5. Credenciales de Desarrollo
- **URL Local:** `http://localhost:80`
- **Usuario:** `hdiaz` o `admin`
- **Password:** `123456` (Hash Bcrypt corregido).

## 6. Documentación de Referencia
Consultar siempre la carpeta `/docs` para ver manuales de equivalencias y planos de arquitectura.

---
**Firmado:** Antigravity AI Agent.
