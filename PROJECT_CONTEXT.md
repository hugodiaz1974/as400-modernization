# Contexto del Proyecto: Modernización AS/400 a Nube (Core Bancario)

Este documento guarda la "memoria" y decisiones técnicas tomadas entre el Arquitecto (el Usuario) y la IA de desarrollo para garantizar que el contexto no se pierda entre diferentes sesiones o PCs.

## 1. Visión General
El objetivo maestro es desvincular al banco del legacy IBM i (AS/400) y migrar la lógica de negocio COBOL/RPG hacia una arquitectura cloud-native (AWS) con el fin de ahorrar costos de infraestructura y modernizar la experiencia del usuario, todo sin perder la paridad funcional del negocio.

## 2. Arquitectura Establecida (Three-Tier)
Hemos refactorizado el código COBOL (específicamente `PLTEXO100`) hacia un stack tecnológico moderno:

- **Frontend:** React.js modularizado con **Context API** para autenticación. Estructura de componentes desacoplados (`src/components/`).
- **Backend:** Node.js con Express, reforzado con **Control Transaccional Atómico (Atomic Commit/Rollback)**.
- **Base de Datos:** PostgreSQL con tablas espejo del AS/400 (`CLITAB`, `TRANSACTION_EXEMPTIONS`, `LOGEXOCOM`, `PLTFECHAS`).
- **Infraestructura:** Stack dockerizado (`docker-compose.yml`) con Nginx para el frontend.

## 3. Lógica de Paridad Bancaria Estricta
Se han replicado lógicas críticas del programa `pltexo100.cbl` para asegurar que el backend se comporte igual al Mainframe:
- **Validación Dinámica de Parámetros (`CLITAB`):** No se insertan datos si el BIN, Cajero o Producto no existen activos en los catálogos.
- **Control de Fechas Bancarias (`PLTFECHAS`):** El sistema ignora el reloj del servidor y usa la fecha contable oficial del banco (`fecpro`).
- **Bloqueo del "Comodín" Universal (99/0):** Se prohíbe parametrizar exoneraciones globales para evitar riesgos de seguridad financiera.

## 4. Integridad Transaccional (Commitment Control)
A diferencia de un CRUD simple, las operaciones de escritura están blindadas:
- **Atomicidad:** Inserción de Exoneración + Log de Auditoría ocurren en el mismo bloque `BEGIN/COMMIT`. Si uno falla, se activa un `ROLLBACK` total.
- **Bloqueo de Concurrencia:** Uso de `SELECT FOR UPDATE` en modificaciones/borrados para evitar colisiones de datos bajo alta carga transaccional.

## 5. Seguridad y Autenticación (JWT)
- **Tecnología:** JSON Web Token (JWT) + Bcrypt.
- **Identidad:** El backend extrae al `actor` del token para la auditoría física.
- **Credenciales Activas:** `hdiaz` / `admin` con contraseña por defecto: **`123456`**.

## 6. Próximos pasos pendientes en la hoja de ruta
1.  **Despliegue a AWS:** Instalar infraestructura real (RDS / ECS) usando Terraform o CloudFormation.
2.  **Integración de Reportes:** Crear reportes de auditoría usando los datos de `LOGEXOCOM`.
3.  **Migración de Clientes:** Implementar el CRUD para la tabla `CLIMAE` (Maestro de Clientes).

## Nota para el Asistente IA (Antigravity):
Si estás en una nueva sesión, mantén la arquitectura modular del frontend. No rompas el `AuthContext`. Al editar el backend, respeta siempre el uso del cliente `client = await pool.connect()` para transacciones. No uses `CURRENT_TIMESTAMP` en auditorías; usa la función `getFecpro()`.
