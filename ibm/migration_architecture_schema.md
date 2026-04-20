# Esquema de Migración: Tarjeta de Crédito de AS/400 a AWS

Este diagrama ilustra la evolución tecnológica del producto de Tarjeta de Crédito, pasando de una arquitectura monolítica en el mainframe a una arquitectura orientada a microservicios en la nube.

> [!TIP]
> **Ventajas comerciales para el banco:** Al moverse a la derecha (AWS), el banco elimina el costo fijo del hardware IBM i, paga solo por el consumo real de base de datos/servidores, y puede integrarse fácilmente mediante APIs con el resto de su ecosistema (como COBIS).

## Grafico Comparativo de Arquitectura

```mermaid
flowchart TB
    subgraph Legacy ["🌐 Arquitectura DB2 / AS400 (Actual)"]
        direction TB
        User_Legacy(("👤 Usuarios / Cajeros"))
        
        subgraph CapaPresentacion ["Capa de Presentación"]
            DSPF["🖥️ Pantallas Verdes 5250\n(Archivos .DSPF)"]
        end
        
        subgraph CapaNegocio ["Capa de Negocio (Monolito)"]
            COBOL["⚙️ Programas COBOL\n(PLTEXO200, etc)"]
            RPG["⚙️ Programas RPGLE\n(Validaciones, Logs)"]
        end
        
        subgraph CapaDatos ["Capa de Datos"]
            DB2[("🗄️ Base de Datos DB2")]
            PF["📄 Archivos Físicos (.PF)"]
            LF["📊 Archivos Lógicos (.LF)"]
            
            DB2 --- PF
            DB2 --- LF
        end
        
        User_Legacy -->|Navegación Teclas| CapaPresentacion
        CapaPresentacion -->|Llamado PGM / Call| CapaNegocio
        CapaNegocio -->|Lectura/Escritura Nativa| CapaDatos
    end

    subgraph AWS ["☁️ Arquitectura AWS Cloud-Native (Objetivo)"]
        direction TB
        User_Modern(("👤 Usuarios / Web / Móvil"))
        
        subgraph Frontend_AWS ["Frontend (App Web)"]
            React["⚛️ React.js (SPA)\nInterfaz Moderna"]
        end
        
        subgraph Orquestacion ["Orquestación y Seguridad"]
            ALB["⚖️ Application Load Balancer\n/ API Gateway"]
        end
        
        subgraph Backend_AWS ["Backend (Microservicios Docker)"]
            Node["🟢 Microservicio Node.js / Java"]
            API["🔌 API REST (JSON)"]
            
            Node --- API
        end
        
        subgraph Datos_AWS ["Base de Datos Core"]
            RDS[("🐘 Amazon RDS\n(PostgreSQL Múltiples Zonas)")]
            Tablas["📑 Tablas Relacionales"]
            Vistas["👁️ Vistas / Índices B-Tree"]
            
            RDS --- Tablas
            RDS --- Vistas
        end
        
        User_Modern -->|HTTPS / Navegador| Frontend_AWS
        Frontend_AWS -->|Llamadas API REST| Orquestacion
        Orquestacion -->|Enrutamiento Seguro| Backend_AWS
        Backend_AWS -->|Consultas SQL (ORM)| Datos_AWS
    end

    %% Relaciones de Migración
    COBOL -.->|✨ Refactorizado a APIs| Node
    DSPF -.->|✨ Rediseñado a Web| React
    PF -.->|✨ Migrado a Tablas| Tablas
    LF -.->|✨ Migrado a Índices| Vistas

    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:white;
    classDef as400 fill:#006699,stroke:#000,stroke-width:2px,color:white;
    classDef general fill:#f9f9f9,stroke:#333,stroke-width:1px;

    class AWS,Frontend_AWS,Orquestacion,Backend_AWS,Datos_AWS aws;
    class Legacy,CapaPresentacion,CapaNegocio,CapaDatos as400;
```

## Comparativa Técnica para la Gerencia

| Etapa | IBM i (AS/400) | AWS Cloud | Beneficio Principal |
| :--- | :--- | :--- | :--- |
| **Base de Datos** | DB2 (Archivos Físicos y Lógicos) | **Amazon RDS PostgreSQL** | Costo de licenciamiento $0, auto-escalable y con respaldos automatizados. |
| **Lógica** | Programas monolíticos en COBOL/RPG | **Microservicios (Node.js/Java)** | Mantenimiento fácil. Múltiples programadores jóvenes domninan estas tecnologías. |
| **Interfaz (UI/UX)** | Pantallas de terminal 5250 (Teclas F) | **Interfaces en React.js** | Operación ágil, menor curva de aprendizaje para empleados, se puede ver desde el celular. |
| **Integración** | Archivos planos o colas de datos IBM (MQ) | **APIs RESTful** | Se integra naturalmente con COBIS y con pasarelas de pago modernas nativamente. |

> [!IMPORTANT]  
> Este es el planteamiento mediante el cual le demostraríamos al Banco que tu sistema es "Future-Proof" (a prueba del futuro) y capaz de desconectarse del costoso servidor físico actual.
