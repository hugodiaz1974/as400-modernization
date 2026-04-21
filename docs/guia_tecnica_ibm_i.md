# Manual Técnico: Equivalencias AS/400 → Modern Stack

Hugo, entiendo perfectamente. Como experto en IBM i, tu prioridad es la **integridad de los datos** y la **trazabilidad**. Aquí tienes el mapa de por qué creamos cada archivo y cómo se traduce al ecosistema que tú ya dominas.

## 1. La Capa de Datos (Base de Datos)

| Archivo en Proyecto | Equivalencia en AS/400 | Función Técnica |
| :--- | :--- | :--- |
| `backend/init.sql` | **DDS / DDL / INZPFM** | Es el libro de órdenes. Define el layout de las tablas (`Physical Files`) e inyecta los datos maestros iniciales de `CLITAB`. |
| `PostgreSQL` | **DB2 for i** | El motor de base de datos. Aquí es donde usamos `psql` (similar a tu `STRSQL`) para consultar los datos. |

## 2. El Corazón Lógico (Backend)

En el AS/400, tendrías un programa RPG o COBOL (`*PGM`) que recibe parámetros de una pantalla.

| Archivo en Proyecto | Equivalencia en AS/400 | Función Técnica |
| :--- | :--- | :--- |
| `backend/server.js` | **ILE COBOL / RPGLE Program** | Es el programa principal. Aquí reside el "Calculated Logic". Recibe los datos de la web, valida contra `CLITAB` y escribe en la base de datos. |
| `bcrypt` / `jwt` | **WRKUSRPRF / QSYGETPH** | Es el sistema de seguridad. En lugar de perfiles de OS/400, usamos "Tokens" (llaves digitales) que viajan con cada petición. |
| `BEGIN / COMMIT / ROLLBACK` | **STRCMTCTL / COMMIT / ROLLBACK** | **Control de Compromiso.** Garantiza que si grabas una exoneración pero el programa falla antes de grabar el Log, el sistema borre automáticamente la exoneración para no dejar basura. |

## 3. La Interfaz de Usuario (Frontend)

Aquí es donde el cambio es más radical visualmente, pero la lógica de manejo de pantalla es similar.

| Archivo en Proyecto | Equivalencia en AS/400 | Función Técnica |
| :--- | :--- | :--- |
| `frontend/src/App.jsx` | **Display File Controller** | Es el "Main Loop" de la pantalla. Decide si mostrar el Login o el Dashboard. |
| `src/context/AuthContext.jsx` | **LDA (Local Data Area)** | Guarda los datos del usuario que inició sesión (su nombre, su rol, su llave JWT). Todos los programas ven esta "LDA" para saber quién está operando. |
| `src/components/` | **Subrutinas / Módulos Copy** | En lugar de un archivo de 5000 líneas, dividimos el código en "piezas" (Login, Tabla, Modal). Es como tener `COPY` o `INCLUDE` para que el código sea limpio. |

## 4. El Entorno de Ejecución

| Concepto Moderno | Equivalencia en AS/400 | Función Técnica |
| :--- | :--- | :--- |
| `Docker` | **LPAR / Subsystem** | Es un contenedor estanco. Garantiza que el programa corra igual en tu PC, en la mía o en el Servidor Amazon, sin importar la versión del sistema operativo. |
| `npm / package.json` | **BNDDIR (Binding Directory)** | Es la lista de librerías externas que el programa necesita para compilar y funcionar. |

---

### ¿Por qué esta arquitectura es "defendible" ante auditoría?

1.  **Paridad Funcional:** Si revisas `backend/server.js`, verás que usamos una función llamada `getFecpro()`. Esto es COBOL puro: el programa no confía en la "hora del servidor", sino que busca en la tabla `PLTFECHAS` la fecha contable del banco.
2.  **Seguridad:** Ninguna operación ocurre sin un "Token" válido. Es el equivalente a que un usuario intente correr un `CALL PGM` sin permiso sobre el objeto.
3.  **Auditoría Física:** Cada `INSERT` o `UPDATE` dispara una escritura automática hacia `LOGEXOCOM`, replicando el historial que el banco ha tenido por décadas.

**Para dar soporte:**
- Si falla la base de datos: Miras el contenedor `migracion-db`.
- Si el cálculo es erróneo: Revisas `backend/server.js` (Tu programa RPG/COBOL moderno).
- Si la pantalla no muestra algo: Revisas los componentes en `frontend/src/components/`.
