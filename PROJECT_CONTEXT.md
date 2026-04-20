# Contexto del Proyecto: Modernización AS/400 a Nube (Core Bancario)

Este documento guarda la "memoria" y decisiones técnicas tomadas entre el Arquitecto (el Usuario) y la IA de desarrollo para garantizar que el contexto no se pierda entre diferentes sesiones o PCs.

## 1. Visión General
El objetivo maestro es desvincular al banco del legacy IBM i (AS/400) y migrar la lógica de negocio COBOL/RPG hacia una arquitectura cloud-native (AWS) con el fin de ahorrar costos de infraestructura y modernizar la experiencia del usuario, todo sin perder la paridad funcional del negocio.

## 2. Arquitectura Establecida (Three-Tier)
Hemos refactorizado el código COBOL (específicamente `PLTEXO100`) hacia un stack tecnológico moderno:

- **Frontend:** React.js con Tailwind CSS y Lucide Icons. Diseñado como un Dashboard Premium Fintech ("Core Bancario AWS").
- **Backend:** Node.js con Express, actuando como un microservicio RESTful.
- **Base de Datos:** PostgreSQL, actuando como reemplazo transaccional de DB2. 
- **Infraestructura:** Todo el stack está 100% dockerizado (`docker-compose.yml`) asegurando portabilidad.

## 3. Lógica de Parámetros Dinámicos
La lógica del AS/400 se basaba en la tabla física `CLITAB`. La hemos migrado a PostgreSQL, de tal modo que el Frontend descarga dinámicamente:
- `335`: BINes de Exoneración
- `334`: Tipos de Cliente (Ej. VIP, Corporativo)
- `333`: Tipos de Cajero (Redes locales, internacionales)
- `336`: Tipos de Producto (Tarjetas Black, Platinum, etc.)

## 4. Seguridad de Grado Bancario implementada (JWT)
Para simular el control de los Perfiles de Usuario (`CRTUSRPRF`), hemos implementado lo siguiente:
- Autenticación manejada mediante librerías **JSON Web Token (JWT)**.
- Base de datos con la tabla `usuarios_sistema`.
- **Encriptación de passwords irreversibles** usando el algoritmo `Bcrypt`.
- El Dashboard frontal está completamente bloqueado a menos que exista un token válido.
- Credenciales útiles de desarrollo inyectadas: `hdiaz` / `admin123` y `admin` / `admin123`.
- **Auditoría:** La antigua lógica temporal de escribir literal "SISTEMA" o "USUARIO" en `LOGEXOCOM` fue reemplazada. El backend Node.js ahora intersecta el JWT y extrae el usuario genuino para registrarlo en el LOG de auditoría de BD.

## 5. Próximos pasos pendientes en la hoja de ruta
Al retomar el proyecto, se debe elegir entre:
1.  **Despliegue a AWS:** Instalar infraestructura real (EC2 / ECS / RDS) en Amazon para tener URLs públicas. Integrar (opcionalmente) Amazon Cognito para absorber el JWT.
2.  **Migrar más módulos AS/400:** Traducir e integrar a la plataforma los códigos fuente `PLTPARGEN` o `PLTFECHAS`.
3.  **Exportación e Inyección de Datas reales:** Sacar un CSV de la producción del Banco AS/400 real e importarlo a nuestro PostgreSQL.

## Nota para el Asistente IA (Antigravity):
Si estás leyendo esto en una nueva sesión, debes asumir automáticamente el rol de asistente experto de Migración de AS/400 hacia Node.js/React. Respeta el stack arquitectónico definido, revisa los archivos `server.js` y `App.jsx` para entender el marco de programación establecido y no rompas la securización JWT.
