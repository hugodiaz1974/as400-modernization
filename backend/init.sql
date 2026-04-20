-- ══════════════════════════════════════════════════════════════
-- Script de Inicialización de Base de Datos
-- Migración del Core de Tarjeta de Crédito (IBM i → PostgreSQL)
-- ══════════════════════════════════════════════════════════════

-- ┌─────────────────────────────────────────────────────────────
-- │ TABLA 1: USUARIOS_SISTEMA  (Reemplazo perfiles IBM i)
-- │ Almacena los perfiles que tendrán acceso al sistema.
-- └─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuarios_sistema (
    id          SERIAL PRIMARY KEY,
    usuario     VARCHAR(50) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL, -- Guardado con bcrypt
    nombre_real VARCHAR(100) NOT NULL,
    rol         VARCHAR(50)  DEFAULT 'Operador',
    estado      SMALLINT     DEFAULT 1
);

-- ┌─────────────────────────────────────────────────────────────
-- │ TABLA 2: CLITAB  (Tabla de Parámetros Generales)
-- │ Equivalente al archivo CLITAB.PF del AS/400
-- │ Contiene los catálogos del sistema (BINes, Cajeros, etc.)
-- └─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clitab (
    codtab   INTEGER      NOT NULL,   -- Código de la tabla (333, 334, 335, 336, etc.)
    codint   BIGINT       NOT NULL,   -- Código interno del parámetro
    codnom   VARCHAR(60)  NOT NULL,   -- Nombre/Descripción del parámetro
    estado   SMALLINT     DEFAULT 1,  -- 1=Activo, 0=Inactivo
    PRIMARY KEY (codtab, codint)
);

-- ┌─────────────────────────────────────────────────────────────
-- │ TABLA 2: TRANSACTION_EXEMPTIONS  (PLTEXOCOM.PF)
-- │ Tabla principal de exoneraciones de transacciones
-- └─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transaction_exemptions (
    id      SERIAL PRIMARY KEY,
    bin_exo VARCHAR(10)  NOT NULL,
    tip_caj VARCHAR(2)   NOT NULL,
    tip_cli VARCHAR(2)   NOT NULL,
    cod_con VARCHAR(20),
    cod_pro VARCHAR(10)  NOT NULL,
    can_exo INTEGER      NOT NULL,
    usr_ing VARCHAR(30),
    fec_ing TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    usr_mod VARCHAR(30),
    fec_mod TIMESTAMP,
    UNIQUE(bin_exo, tip_caj, tip_cli, cod_con, cod_pro)
);

-- ┌─────────────────────────────────────────────────────────────
-- │ TABLA 3: LOGEXOCOM  (Log de Auditoría)
-- │ Equivalente al archivo LOGEXOCOM del AS/400
-- │ Registra cada acción (Adicion, Cambio, Borrado)
-- └─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS logexocom (
    id       SERIAL PRIMARY KEY,
    accion   VARCHAR(20)  NOT NULL,   -- 'Adicion', 'Cambio', 'Borrado'
    bin_exo  VARCHAR(10),
    tip_caj  VARCHAR(2),
    tip_cli  VARCHAR(2),
    cod_con  VARCHAR(20),
    cod_pro  VARCHAR(10),
    can_exo  INTEGER,
    usr_mod  VARCHAR(30),
    fec_mod  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    hor_mod  TIME         DEFAULT CURRENT_TIME
);

-- ┌─────────────────────────────────────────────────────────────
-- │ TABLA 4: CLIMAE  (Maestro de Clientes)
-- │ Traducción directa del archivo CLIMAE.PF del AS/400
-- │ Contiene toda la información del cliente/asociado
-- └─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS climae (
    numint   NUMERIC(17,0) PRIMARY KEY,          -- Codigo Interno del Cliente
    nitcli   NUMERIC(17,0),                       -- Numero de Identificacion
    tipcli   SMALLINT,                            -- Tipo de Cliente (01)
    tipdoc   NUMERIC(2,0),                        -- Tipo/Identificacion (10,20)
    nomcli   VARCHAR(60),                         -- Nombre del Cliente
    feccon   NUMERIC(8,0),                        -- Fecha Constitucion/Nacimiento
    lugcon   NUMERIC(9,0),                        -- Lugar Constitucion/Nacimiento
    fecesc   NUMERIC(8,0),                        -- Fecha de Escritura/Expedicion
    asocis   NUMERIC(9,0),                        -- Lugar de Escritura/Expedicion
    -- Solicitud de Ingreso
    asocod   NUMERIC(17,0),                       -- Codigo del Asociado
    feccre   NUMERIC(8,0),                        -- Fecha de Creacion
    fecing   NUMERIC(8,0),                        -- Fecha de Ingreso
    numact   NUMERIC(10,0),                       -- Numero del Acta
    agcvin   SMALLINT,                            -- Agencia Origen/Vinculacion
    procod   NUMERIC(17,0),                       -- Codigo del Promotor
    -- Informacion Personal
    codsex   SMALLINT,                            -- Sexo (42)
    edaaso   NUMERIC(3,0),                        -- Edad
    estciv   SMALLINT,                            -- Estado Civil (43)
    motvin   NUMERIC(2,0),                        -- Motivo Vinculacion (44)
    percar   NUMERIC(2,0),                        -- Personas a Cargo Adultas
    perm18   NUMERIC(2,0),                        -- Personas a Cargo < 18
    cortee   NUMERIC(2,0),                        -- Corte
    monfun   NUMERIC(15,2),                       -- Valor Funerario
    valapo   NUMERIC(15,2),                       -- Valor Aporte
    estaso   NUMERIC(2,0),                        -- Estado del Asociado (110)
    fecest   NUMERIC(8,0),                        -- Fecha de Estado Asociado
    -- Forma de Pago de Facturacion
    pagfac   NUMERIC(1,0),                        -- Forma de Pago Facturacion (128)
    numcta   NUMERIC(17,0),                       -- Numero de Cuenta
    binban   NUMERIC(3,0),                        -- Bin del Banco (90)
    -- Nivel Academico
    indest   NUMERIC(2,0),                        -- Indicador de Estudios (69)
    -- Informacion Conyuge/Companero
    tiprep   NUMERIC(2,0),                        -- Tipo Docto Representante/Conyuge
    repleg   NUMERIC(17,0),                       -- Representante Legal/Conyuge
    nomrep   VARCHAR(60),                         -- Nombre Representante/Conyuge
    fecnco   NUMERIC(8,0),                        -- Fecha nacimiento Conyuge
    codsec   NUMERIC(1,0),                        -- Sexo del Conyuge
    depecn   NUMERIC(1,0),                        -- Depende Economicamente
    valing   NUMERIC(15,2),                       -- Valor Ingresos
    tipemc   NUMERIC(1,0),                        -- Tipo Actividad Conyuge
    nitemc   NUMERIC(17,0),                       -- Nit Empresa Conyuge
    carasc   NUMERIC(4,0),                        -- Cargo del Asociado/Emp
    fecinc   NUMERIC(8,0),                        -- Fecha de Ingreso Conyuge
    indesc   NUMERIC(2,0),                        -- Indicador Estudios Conyuge
    ocupcc   NUMERIC(4,0),                        -- Ocupacion Conyuge
    -- Actividad Economica Principal
    codcar   NUMERIC(5,0),                        -- Actividad Laboral (122)
    nitemp   NUMERIC(17,0),                       -- Nit Empresa donde labora
    caraso   NUMERIC(4,0),                        -- Cargo del Asociado/emp
    fecine   NUMERIC(8,0),                        -- Fecha Ing. Act. Economica
    estine   NUMERIC(1,0),                        -- Estado Act. Eco. Principal
    ocupac   NUMERIC(4,0),                        -- Ocupacion (134)
    -- Pagos Iniciales
    tippia   NUMERIC(3,0),                        -- Pago Inicial Asociado (135)
    forpia   NUMERIC(3,0),                        -- Forma de Pago (136)
    datadd   VARCHAR(20),                         -- Dato Adicional
    -- Servicio de Solidaridad
    vlrpro   NUMERIC(15,2),                       -- Valor de Proteccion
    faccuo   NUMERIC(3,0),                        -- Factor que Determina Cuota
    -- Medio de Informacion
    asoref   NUMERIC(17,0),                       -- Asociado que Refirio
    -- Otros Campos
    codger   NUMERIC(17,0),                       -- Gerente de Cuenta
    asocor   NUMERIC(2,0),                        -- Codigo Unico x/Corte
    tipemp   SMALLINT,                            -- Tipo de Empresa (50)
    nomemp   VARCHAR(40),                         -- Sigla
    numsuc   NUMERIC(3,0),                        -- Numero de Sucursales
    numage   NUMERIC(3,0),                        -- Numero de Agencias
    moncre   NUMERIC(13,2),                       -- Monto de Creacion
    matric   VARCHAR(20),                         -- Matricula
    resolu   VARCHAR(20),                         -- Resolucion
    decret   VARCHAR(20),                         -- Decreto
    asotip   NUMERIC(1,0),                        -- Tipo (120)
    asotrc   NUMERIC(2,0),                        -- Tipo rep codigo (121)
    fecret   NUMERIC(8,0),                        -- Fecha de Retiro
    conver   NUMERIC(1,0),                        -- Condicion Activo o Inactivo
    tipviv   NUMERIC(1,0),                        -- Tipo de Vivienda (124)
    estrat   NUMERIC(1,0),                        -- Estrato (125)
    numemp   NUMERIC(4,0),                        -- Numero de Empleados
    ofiser   NUMERIC(3,0),                        -- Oficina Servicio (126)
    asocia   NUMERIC(1,0),                        -- Asociado (127)
    indcvi   NUMERIC(1,0),                        -- Indicador Cuota Vitalicia
    indper   NUMERIC(1,0),                        -- Indicador Perseverancia
    inakdl   NUMERIC(1,0),                        -- Indicador Act. Kindle
    indpmu   NUMERIC(1,0),                        -- Indicador Pago Muerte
    bloque   NUMERIC(2,0),                        -- Bloqueado (115)
    activo   NUMERIC(2,0),                        -- Activo (114)
    retfte   SMALLINT,                            -- Retencion la Fuente
    actkdl   NUMERIC(2,0),                        -- Actualizable Kindle
    indind   NUMERIC(2,0),                        -- Indicativo Induccion
    fecind   NUMERIC(8,0),                        -- Fecha de Induccion
    codcii   NUMERIC(8,0),                        -- Codigo CIIU
    codpro   SMALLINT,                            -- Codigo de Profesion
    codban   SMALLINT,                            -- Codigo de Banca
    indprv   SMALLINT,                            -- Indicativo de Privacidad
    indemp   SMALLINT,                            -- Indicativo de Emp/Dep
    exciva   SMALLINT,                            -- Exento de IVA
    excret   SMALLINT,                            -- Exento de Impuesto Retiro
    indsip   SMALLINT,                            -- Indicativo del Sipla
    idibas   NUMERIC(3,0),                        -- Idioma Base
    clavin   NUMERIC(2,0),                        -- Clase Vinculacion
    indrel   NUMERIC(2,0),                        -- Relacion Banco/Cliente
    hoobyy   NUMERIC(5,0),                        -- Hobby
    nrohij   NUMERIC(2,0),                        -- Nro de Hijos
    fecsip   NUMERIC(9,0),                        -- Fecha Formato Sipla
    usrori   VARCHAR(10),                         -- Usuario que Vinculo
    notesc   SMALLINT,                            -- Notaria Escritura
    nroesc   SMALLINT,                            -- Numero de Escritura
    notpju   SMALLINT,                            -- Notaria Personeria Juridica
    nropju   SMALLINT,                            -- Numero Personeria Juridica
    fecpju   INTEGER,                             -- Fecha Personeria Juridica
    regcci   VARCHAR(10),                         -- Reg. Camara de Comercio
    reglib   VARCHAR(6),                          -- Reg. de Libros
    fecreg   INTEGER,                             -- Fecha Registro Mercantil
    sitcia   SMALLINT,                            -- Situacion Compania
    fsicia   INTEGER,                             -- Fecha Situacion Compania
    indgra   SMALLINT,                            -- Indicativo Gran Contribuyente
    tipsoc   SMALLINT,                            -- Tipo de Sociedad
    clasup   VARCHAR(1),                          -- Calificacion Superbancaria
    lugexp   NUMERIC(9,0),                        -- Lugar Expedicion Documento
    codins   NUMERIC(17,0),                       -- Codigo de Institucion
    deport   NUMERIC(5,0),                        -- Deporte
    indvia   NUMERIC(5,0),                        -- Indicador de Viajes
    indclu   NUMERIC(17,0),                       -- Nro del Club
    indpre   NUMERIC(3,0),                        -- Indicador Preferencia Trn
    indase   NUMERIC(3,0),                        -- Indicador Asesor Financiero
    indpec   NUMERIC(3,0),                        -- Indicador Percepcion Banco
    indmoe   NUMERIC(3,0),                        -- Indicador Moneda Extranjera
    ctamoe   NUMERIC(17,0),                       -- Num Cuenta Extranjera
    bcoext   NUMERIC(7,0),                        -- Codigo Banco Extranjero
    paiext   NUMERIC(7,0),                        -- Codigo Pais Extranjero
    nomcl1   VARCHAR(60),                         -- Nombre Cliente separador
    fecuac   NUMERIC(9,0),                        -- Fecha de Actualizacion
    horuac   NUMERIC(9,0),                        -- Hora de Actualizacion
    usruac   VARCHAR(10)                          -- Usuario que Actualiza
);

-- ══════════════════════════════════════════════════════════════
-- CARGA DE DATOS INICIALES (Equivalente a INZPFM en AS/400)
-- ══════════════════════════════════════════════════════════════

-- ── Tabla 333: Tipos de Cajero ────────────────────────────────
INSERT INTO clitab (codtab, codint, codnom) VALUES
    (333, 1, 'Corporativos Propios'),
    (333, 2, 'Red Servibanca'),
    (333, 3, 'Otras Redes'),
    (333, 99, 'Todos los Cajeros')
ON CONFLICT DO NOTHING;

-- ── Tabla 334: Tipos de Cliente ───────────────────────────────
INSERT INTO clitab (codtab, codint, codnom) VALUES
    (334, 1, 'Empleado'),
    (334, 2, 'Asociado'),
    (334, 3, 'Cliente General'),
    (334, 4, 'Convenio'),
    (334, 99, 'Todos los Tipos Clientes')
ON CONFLICT DO NOTHING;

-- ── Tabla 335: BINes de Tarjeta ───────────────────────────────
INSERT INTO clitab (codtab, codint, codnom) VALUES
    (335, 462896, 'Visa Débito'),
    (335, 482407, 'Electron'),
    (335, 99, 'Todos los Bines')
ON CONFLICT DO NOTHING;

-- ── Tabla 336: Tipos de Producto ──────────────────────────────
INSERT INTO clitab (codtab, codint, codnom) VALUES
    (336, 101, 'Cuenta de Ahorros'),
    (336, 102, 'Cuenta Corriente'),
    (336, 99, 'Todos los Tipos Productos')
ON CONFLICT DO NOTHING;

-- ── Tabla 236: Tipos de Transacción ──────────────────────────
INSERT INTO clitab (codtab, codint, codnom) VALUES
    (236, 1, 'Retiro'),
    (236, 2, 'Consulta de Saldo'),
    (236, 3, 'Transferencia'),
    (236, 99, 'Todo Tipo Transaccion')
ON CONFLICT DO NOTHING;

-- ── Datos iniciales de Exoneraciones ─────────────────────────
INSERT INTO transaction_exemptions (bin_exo, tip_caj, tip_cli, cod_con, cod_pro, can_exo, usr_ing)
VALUES
    ('462896', '1', '1', '-', '101', 5, 'SISTEMA'),
    ('482407', '2', '4', 'AC-1004', '102', 3, 'SISTEMA')
ON CONFLICT DO NOTHING;

-- ── Datos Iniciales de Usuarios (Como un RSTUSRPRF) ──────────
-- Contraseña por defecto: 123456 (encriptada con bcrypt, hash: $2a$10$X1j18H1P0.oB/A3P7G46JupJvD5B5n5mPzRYF/s08qG5x6v9G9NRO)
INSERT INTO usuarios_sistema (usuario, password, nombre_real, rol) 
VALUES 
    ('admin', '$2a$10$X1j18H1P0.oB/A3P7G46JupJvD5B5n5mPzRYF/s08qG5x6v9G9NRO', 'Administrador Global', 'Admin'),
    ('hdiaz', '$2a$10$X1j18H1P0.oB/A3P7G46JupJvD5B5n5mPzRYF/s08qG5x6v9G9NRO', 'Hugo Diaz', 'Admin')
ON CONFLICT (usuario) DO NOTHING;
