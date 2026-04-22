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

## 4. Estructura de Código y Estándares QA
- **Prohibición de Monolitos:** CUALQUIER funcionalidad nueva debe fragmentarse en componentes atómicos dentro de `src/components/`. Está terminantemente prohibido hacer crecer `App.jsx` con lógica de negocio.
- **Gestión de Estado:** Usar `Context API` (`AuthContext`) para evitar el "Prop Drilling". Los componentes deben ser lo más puros y reutilizables posible.
- **Rendimiento:** Implementar `useMemo` y `useCallback` en listados y tablas de alta transaccionalidad para optimizar el renderizado.
- **Backend Modular:** Aunque la lógica actual reside en `server.js`, se debe priorizar la creación de controladores y rutas separadas si el proyecto escala, evitando un solo archivo masivo.

## 5. Principios de Ingeniería
- **Clean Code:** Código autodocumentado con nombres de variables descriptivos (evitar nombres crípticos del AS/400 en el código Javascript, usar nombres claros como `exonerationData` en lugar de `EXODAT`).
- **Seguridad:** NUNCA exponer secretos o contraseñas en el código. Usar variables de entorno.

## 6. Comandos de Despliegue (Quick Start)
- **Iniciar Entorno:** `docker compose up -d --build`
- **Apagar Entorno:** `docker compose down`
- **Ver Logs de Errores:** `docker compose logs -f`
- **Resetear Base de Datos:** `docker compose down -v` (Cuidado: borra datos no commiteados en SQL).

## 7. Credenciales de Desarrollo
- **URL Local:** `http://localhost:80`
- **Usuario:** `hdiaz` o `admin`
- **Password:** `123456` (Hash Bcrypt corregido).

## 8. Documentación de Referencia
Consultar siempre la carpeta `/docs` para ver manuales de equivalencias y planos de arquitectura.

---
**Firmado:** Antigravity AI Agent.
