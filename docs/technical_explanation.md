# Guía Técnica: ¿Por qué Docker, PostgreSQL y Microservicios?
## Material de soporte para presentación al Banco

---

## 1. El Problema Actual (Lo que el Banco ya sabe)

Hoy en día, tu sistema de Tarjeta de Crédito vive en un **IBM i (AS/400)**. Todo está dentro de una sola máquina física:

```
┌────────────────────────────────────────────────┐
│            SERVIDOR IBM i (AS/400)              │
│                                                │
│  📺 Pantallas 5250 (.DSPF)                     │
│  ⚙️  Programas COBOL / RPG (.PGM)              │
│  🗄️  Base de Datos DB2 (.PF / .LF)             │
│  🔒 Seguridad, usuarios, perfiles              │
│                                                │
│  TODO vive aquí. Si esto se apaga, TODO se cae.│
└────────────────────────────────────────────────┘
```

Esto se llama una **arquitectura monolítica**. Es como una casa donde la cocina, el baño, el dormitorio y la sala son un solo cuarto. Funciona, pero:

- **Es costoso**: El banco paga licencias IBM + mantenimiento de hardware solo para tu producto.
- **Es frágil**: Si el servidor tiene un problema, todo se detiene.
- **Es difícil de escalar**: Si hay un pico de transacciones (Black Friday), no puedes "agregar más potencia" fácilmente.
- **Es aislado**: COBIS (que ya está en AWS) no puede comunicarse directamente con tu sistema sin archivos planos o procesos batch.

---

## 2. ¿Qué es un Contenedor (Docker)?

### La analogía con el AS/400

En el AS/400, cuando tú compilas un programa COBOL con `CRTCBLPGM`, se genera un objeto `*PGM` que **solo corre en el IBM i**. Si quisieras llevar ese programa a un servidor Linux o Windows, **no funciona**. Está "amarrado" al sistema operativo del AS/400.

### El problema que Docker resuelve

Imagina que pudieras empaquetar tu programa junto con **todo lo que necesita para funcionar** (sistema operativo, librerías, configuración) en una "caja" portátil. Esa caja correría igual en:
- Tu laptop con Windows
- Un servidor Linux en AWS
- La computadora de un colega con MacOS

**Eso es exactamente un contenedor Docker.**

### Definición técnica

Un **contenedor** es un paquete ligero que incluye:
1. Tu código (el `.js`, `.java`, o lo que sea)
2. Las dependencias (librerías como Express, pg, etc.)
3. Un sistema operativo mínimo (generalmente Linux Alpine, que pesa solo ~5MB)
4. La configuración para arrancar

```
┌─────────────────────────────────┐
│        CONTENEDOR DOCKER        │
│                                 │
│  🐧 Linux Alpine (5 MB)        │
│  🟢 Node.js v18                │
│  📦 Dependencias (express, pg) │
│  📄 Tu código (server.js)      │
│  ⚙️  Instrucciones de arranque  │
│                                 │
│  Peso total: ~50 MB             │
│  (vs IBM i: Terabytes)          │
└─────────────────────────────────┘
```

### ¿Qué es el Dockerfile?

El `Dockerfile` es como un **"script de compilación"**. En el AS/400, tú usas un comando como:

```
CRTCBLPGM PGM(MILIB/MIPROGRAMA) SRCFILE(MISRC/QCBLSRC)
```

En Docker, el equivalente es el `Dockerfile`. Le dice a Docker **cómo construir la caja**:

```dockerfile
# 1. Toma un sistema operativo con Node.js instalado
FROM node:18-alpine

# 2. Crea un directorio de trabajo (como una librería en el AS/400)
WORKDIR /app

# 3. Copia las dependencias e instálalas
COPY package.json ./
RUN npm install

# 4. Copia tu código fuente
COPY . .

# 5. Expón el puerto (como habilitar un servicio TCP/IP en el AS/400)
EXPOSE 3001

# 6. Comando para arrancar (como SBMJOB CMD(CALL PGM(...)))
CMD ["node", "server.js"]
```

Cuando ejecutas `docker build`, Docker lee este archivo y **genera una imagen** (un snapshot inmutable de tu aplicación). Es como hacer un `SAVOBJ` de tu programa, pero portátil a cualquier servidor del mundo.

---

## 3. ¿Por qué Docker Compose?

### El problema de los múltiples contenedores

Nuestro sistema de Tarjeta de Crédito no es un solo programa. Tiene **tres componentes** que necesitan comunicarse entre sí:

| Componente | En el AS/400 | En la nube |
|:---|:---|:---|
| Base de Datos | DB2 (integrada en el OS) | PostgreSQL (contenedor separado) |
| Lógica de Negocio | Programas COBOL/RPG | APIs en Node.js (contenedor separado) |
| Interfaz | Pantallas 5250 | React.js (contenedor separado) |

Sin Docker Compose, tendrías que arrancar cada contenedor manualmente con comandos largos y complejos, configurando redes y puertos uno por uno. **Docker Compose resuelve esto.**

### ¿Qué es Docker Compose?

Docker Compose es un archivo llamado `docker-compose.yml` que **define y conecta todos los contenedores** con un solo archivo de configuración.

En el mundo AS/400, la analogía más cercana sería un **Job Scheduler (WRKJOBSCDE)** que arranca múltiples subsistemas coordinados. Docker Compose es eso, pero para contenedores.

### Cómo se ve nuestro docker-compose.yml

```yaml
# docker-compose.yml - Orquestador de tu sistema migrado

services:
  # ── SERVICIO 1: Base de Datos ──────────────────────────
  # Equivalente a: Tu partición de DB2 en el AS/400
  database:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: tarjeta_credito    # Nombre de la base
      POSTGRES_USER: admin            # Usuario (como un perfil IBM i)
      POSTGRES_PASSWORD: secreto123   # Contraseña
    ports:
      - "5432:5432"                   # Puerto TCP/IP expuesto
    volumes:
      - db_data:/var/lib/postgresql   # Persistencia de datos

  # ── SERVICIO 2: Backend (APIs) ─────────────────────────
  # Equivalente a: Tus programas COBOL/RPG compilados
  backend:
    build: ./backend                  # Construye desde el Dockerfile
    ports:
      - "3001:3001"                   # Puerto del API
    depends_on:
      - database                      # Espera a que DB esté lista
    environment:
      DATABASE_URL: postgres://admin:secreto123@database:5432/tarjeta_credito

  # ── SERVICIO 3: Frontend (Interfaz Web) ────────────────
  # Equivalente a: Tus pantallas DSPF
  frontend:
    build: ./frontend
    ports:
      - "80:80"                       # Puerto HTTP estándar
    depends_on:
      - backend                       # Espera a que APIs estén listas

volumes:
  db_data:                            # Almacenamiento persistente
```

### El comando mágico

Con un **solo comando**, los tres servicios arrancan coordinadamente:

```bash
docker compose up -d
```

Esto equivale a encender tu AS/400 y que automáticamente arranquen:
1. ✅ El subsistema de base de datos (DB2 → PostgreSQL)
2. ✅ Los trabajos batch de tus programas (COBOL → Node.js APIs)
3. ✅ El servicio de pantallas (5250 → React en el navegador)

Y con otro comando, todo se apaga limpiamente:

```bash
docker compose down
```

---

## 4. ¿Por qué PostgreSQL y no SQLite?

### SQLite (Lo que tenemos ahora como prueba)

SQLite es un archivo local (`.db`) que vive en tu disco duro. Es perfecto para pruebas, pero:
- ❌ **No soporta múltiples usuarios simultáneos** (un banco tiene cientos de cajeros)
- ❌ **No tiene servidor** (no puedes conectarte remotamente)
- ❌ **No tiene seguridad de acceso** (sin usuarios, sin roles, sin auditoría)
- ❌ **No es compatible con AWS RDS** (no se puede escalar en la nube)

### PostgreSQL (Lo que necesitamos para producción)

PostgreSQL es un **motor de base de datos empresarial** que:
- ✅ **Soporta miles de conexiones simultáneas** con transacciones ACID
- ✅ **Es compatible directamente con Amazon RDS** (se despliega en AWS con un clic)
- ✅ **Tiene el mismo concepto de tablas y SQL que DB2** (tu conocimiento se transfiere)
- ✅ **Es gratuito** (sin costo de licencia, a diferencia de Oracle o DB2)
- ✅ **Es el estándar de la industria FinTech** para sistemas nuevos

### Equivalencia AS/400 → PostgreSQL

| Concepto IBM i (DB2) | Equivalente PostgreSQL |
|:---|:---|
| Archivo Físico (.PF) | `CREATE TABLE` |
| Archivo Lógico (.LF) | `CREATE INDEX` / `CREATE VIEW` |
| Librería (CRTLIB) | `CREATE SCHEMA` |
| Perfil de Usuario (CRTUSRPRF) | `CREATE ROLE` |
| Journaling (STRJRNPF) | WAL (Write-Ahead Log) - activado por defecto |
| SAVLIB / RSTLIB | `pg_dump` / `pg_restore` |

---

## 5. ¿Cómo se conecta esto con AWS?

Una vez que todo funciona localmente con Docker Compose, el paso a AWS es **directo** porque ya tenemos los contenedores listos:

```mermaid
flowchart LR
    subgraph Local ["💻 Tu Laptop (Hoy)"]
        DC["Docker Compose"]
        DB_L[("PostgreSQL\n(Contenedor)")]
        BE_L["Node.js API\n(Contenedor)"]
        FE_L["React\n(Contenedor)"]
        DC --> DB_L
        DC --> BE_L
        DC --> FE_L
    end

    subgraph AWS_Cloud ["☁️ AWS (Mañana)"]
        RDS[("Amazon RDS\nPostgreSQL")]
        ECS["Amazon ECS\n(Contenedores)"]
        S3["Amazon S3\n+ CloudFront"]
    end

    DB_L -.->|Misma config| RDS
    BE_L -.->|Mismo Dockerfile| ECS
    FE_L -.->|Mismo build| S3
```

| Local (Docker Compose) | AWS (Producción) | Cambio requerido |
|:---|:---|:---|
| Contenedor PostgreSQL | **Amazon RDS** | Solo cambiar la URL de conexión |
| Contenedor Node.js | **Amazon ECS / Fargate** | Subir la misma imagen Docker |
| Contenedor React/Nginx | **Amazon S3 + CloudFront** | Subir los archivos estáticos |

> [!IMPORTANT]
> **Mensaje clave para el banco:** Lo que desarrollamos localmente con Docker Compose es una réplica exacta de cómo operará en AWS. No hay "sorpresas" al migrar. El código es el mismo, solo cambia la infraestructura que lo hospeda.

---

## 6. Resumen Ejecutivo (Para la Presentación)

```
ANTES (IBM i)                    DESPUÉS (AWS)
─────────────                    ─────────────
1 servidor físico costoso   →    Servicios elásticos por demanda
Todo acoplado en 1 máquina  →    3 componentes independientes
Solo pantalla verde 5250    →    Web responsive + API abierta
Integración por archivos    →    Integración por APIs (como COBIS)
Escalar = comprar hardware  →    Escalar = un clic en la consola
```

**¿Por qué Docker?** Porque empaqueta cada componente en una "caja portátil" que corre igual en tu laptop que en AWS.

**¿Por qué Docker Compose?** Porque orquesta las 3 cajas (Base de Datos, Backend, Frontend) con un solo comando.

**¿Por qué PostgreSQL?** Porque es el estándar bancario en la nube, es compatible con Amazon RDS, y su estructura es casi idéntica a la de DB2 que el banco ya conoce.
