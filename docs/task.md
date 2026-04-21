# Tareas: Modularización y Arquitectura React

- `[x]` 1. Creación de Estructura de Carpetas
  - `[x]` Crear `src/components` y `src/context`.
- `[x]` 2. Lógica de Autenticación
  - `[x]` Mover el Token, validación y control de sesiones a `AuthContext.jsx`.
- `[x]` 3. Componentes Visuales
  - `[x]` Mover el JSX y lógica de Login a `LoginForm.jsx`.
  - `[x]` Mover el menú de navegación a `Sidebar.jsx`.
  - `[x]` Mover la Tabla de Datos y su listado a `ExonerationTable.jsx`.
  - `[x]` Implementar `useMemo` para traducciones CLITAB en la tabla.
  - `[x]` Mover el fomulario Pop-Up a `ExonerationModal.jsx`.
- `[x]` 4. Refactor Central (`App.jsx`)
  - `[x]` Eliminar monolito y reconstruir como manejador de vistas que interactúa con el Context.
- `[x]` 5. QA Frontend
  - `[x]` Validar y observar en Hot Reload que todo corre perfectamente sin caídas por *prop-drilling*.
