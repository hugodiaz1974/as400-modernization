# Implementación: Arquitectura Modular React (Frontend)

El análisis externo ha identificado que, aunque nuestra interfaz es visualmente superior a la pantalla 5250, hereda un rasgo típico del AS/400: **es un monolito**. Todo el ciclo de vida del programa existe en `App.jsx`, lo que a la larga dificultará el mantenimiento por parte del equipo del banco.

Este plan fragmentará el monolito aplicando el Principio de Responsabilidad Única (SRP), mejorará el rendimiento general y asegurará la escalabilidad de la UI.

## Proposed Changes

### 1. Manejo de Autenticación (`AuthContext.jsx`)
#### [NEW] [frontend/src/context/AuthContext.jsx](file:///c:/Users/hugot/OneDrive/BACKUP%20ASUS%2020221112/VARIOS/PROYECTOS%20AI/MIGRACION/frontend/src/context/AuthContext.jsx)
- Extracción de la lógica de sesión (Token JWT, `login`, `logout` y estado del `authUser`).
- Provisión de contexto global para evitar forzar la recarga de toda la aplicación cuando el token expira o cambia.

### 2. Fragmentación de Componentes
#### [NEW] [frontend/src/components/LoginForm.jsx](file:///c:/Users/hugot/OneDrive/BACKUP%20ASUS%2020221112/VARIOS/PROYECTOS%20AI/MIGRACION/frontend/src/components/LoginForm.jsx)
- Control del formulario inicial de credenciales de seguridad.
#### [NEW] [frontend/src/components/Sidebar.jsx](file:///c:/Users/hugot/OneDrive/BACKUP%20ASUS%2020221112/VARIOS/PROYECTOS%20AI/MIGRACION/frontend/src/components/Sidebar.jsx)
- Menú lateral y botón global de Logout.
#### [NEW] [frontend/src/components/ExonerationTable.jsx](file:///c:/Users/hugot/OneDrive/BACKUP%20ASUS%2020221112/VARIOS/PROYECTOS%20AI/MIGRACION/frontend/src/components/ExonerationTable.jsx)
- Tabla de datos interactiva. Aquí inyectaremos `useMemo` para memorizar la traducción de `codint` a `codnom` de la tabla de parámetros CLITAB, optimizando radicalmente el renderizado.
#### [NEW] [frontend/src/components/ExonerationModal.jsx](file:///c:/Users/hugot/OneDrive/BACKUP%20ASUS%2020221112/VARIOS/PROYECTOS%20AI/MIGRACION/frontend/src/components/ExonerationModal.jsx)
- Formulario transaccional de Pop-Up con encapsulación del objeto `formData`.

### 3. Refactor del Core
#### [MODIFY] [frontend/src/App.jsx](file:///c:/Users/hugot/OneDrive/BACKUP%20ASUS%2020221112/VARIOS/PROYECTOS%20AI/MIGRACION/frontend/src/App.jsx)
- `App.jsx` dejará de tener +500 líneas y se convertirá simplemente en el enrutador coordinador que llama organizadamente a `LoginForm` o al entorno del Pop-up con el Dashboard, consumiendo `AuthContext`.

## User Review Required

> [!WARNING]
> La IA también sugiere modificar el Backend para emitir *Cookies HttpOnly* en vez de usar *localStorage* para la seguridad JWT. Hacer esto **cambia por completo** cómo funcionan las validaciones de REST que acabas de auditar exitosamente con el Tester QA de automatización. **¿Aprobamos solo el enfoque de arquitectura de componentes React (Altamente recomendado), o deseas también aventurarte a alterar el backend REST para soportar Cookies (Lo que podría romper las pruebas automatizadas actuales)?**

## Verification Plan

### Manual Verification
- Tras la fragmentación, iniciaremos el contenedor de `frontend` (Hot Reload).
- Comprobaremos mediante React DevTools que las actualizaciones en la tabla ya no causan que el Navbar y el Sidebar hagan re-renders completos.
- Probaremos que iniciar y cerrar sesión libere la memoria correctamente.
