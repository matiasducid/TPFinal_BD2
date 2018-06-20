/* TABLAS A AGREGAR
-Clientes (cod_Cliente, Nombre, cod_tipo, dirección)
-Tipo_Cliente (cod_tipo, descripción)
-Producto (cod_Producto, Nombre, cod_categoria, cod_subcategoria, precio_actual)
-Categoria (cod_categoria,  cod_subcategoría, descripción)
-Venta (Fecha_Vta, Id_Factura, cod_Cliente, Nombre, cod_medio_pago)
-Detalle_Venta(Id_factura, cod_producto, descripción, unidad, precio)
-Medio_Pago( cod_Medio_Pago, descripción, valor, unidad, tipo_operación)
-Tiempo ( Id_fecha, día, mes, trimestre, año) */


CREATE TABLE "Categoria"(
    cod_categoria integer,
    cod_subcategoria integer NOT NULL,
    descripcion varchar(100),
    CONSTRAINT "pk_cod_categoria" PRIMARY KEY ("cod_categoria"),
    CONSTRAINT "fk_cod_subcategoria" FOREIGN KEY ("cod_subcategoria") REFERENCES "Categoria"
);

CREATE TABLE "Tipo_Cliente" (
    cod_tipo t_cod_tipo NOT NULL,
    descripcion varchar(100),
    CONSTRAINT "pk_Tipo_Cliente" PRIMARY KEY (cod_tipo)
);

CREATE DOMAIN t_cod_tipo AS integer
    DEFAULT 1 
    CHECK (VALUE IN (1,2,3,4));--son cuatro tipos en facturacion1

CREATE TABLE "Clientes"(
    "cod_Cliente" varchar(8) NOT NULL,
    "Nombre" varchar(50) NOT NULL,
    cod_tipo t_cod_tipo,
    direccion varchar(50),
    CONSTRAINT "pk_Cliente" PRIMARY KEY ("cod_Cliente"),
    CONSTRAINT "fk_Tipo_Cliente" FOREIGN KEY (cod_tipo) REFERENCES "Tipo_Cliente"
);


CREATE TABLE "Producto"(
    "cod_Producto" integer NOT NULL,
    "Nombre" varchar(50),
    cod_categoria integer NOT NULL, --Quizas DOMAIN
    cod_subcategoria integer NOT NULL,
    precio_actual float,
    CONSTRAINT "pk_Producto" PRIMARY KEY ("cod_Producto"),
    CONSTRAINT "fk_cod_categoria" FOREIGN KEY (cod_categoria) REFERENCES "Categoria"--(cod_categoria)
    --CONSTRAINT "fk_cod_subcategoria" FOREIGN KEY (cod_subcategoria)
);


CREATE TABLE "Venta"(
    "Fecha_Vta" date NOT NULL, 
    "Id_Factura" integer NOT NULL,
    "cod_Cliente" varchar(8) NOT NULL,
    "Nombre" varchar(50),
    cod_medio_pago integer,
    CONSTRAINT "pk_Id_Factura" PRIMARY KEY ("Id_Factura"),
    CONSTRAINT "fk_cod_Cliente" FOREIGN KEY ("cod_Cliente") REFERENCES "Clientes"
);

CREATE DOMAIN t_forma_pago varchar(15)
    DEFAULT 'EFECTIVO'
    CHECK (VALUE IN('EFECTIVO','DEBITO','CREDITO','CHEQUE'));


CREATE TABLE "Detalle_Venta"(
    "Id_Factura" integer NOT NULL,
    cod_producto integer NOT NULL,
    descripcion varchar(100),
    unidad integer NOT NULL,
    precio float NOT NULL,
    CONSTRAINT "fk_Id_Factura" FOREIGN KEY ("Id_Factura") REFERENCES "Venta",
    CONSTRAINT "fk_cod_producto" FOREIGN KEY ("cod_producto") REFERENCES "Producto"
);


CREATE TABLE "Medio_Pago"(
    "cod_Medio_Pago" t_forma_pago,
    descripcion varchar(50),
    valor float,
    cantidad integer, --unidad en PDF
    tipo_operacion integer, --varchar(50) o definir un tipo?
    CONSTRAINT "pk_Medio_Pago" PRIMARY KEY ("cod_Medio_Pago")
);


CREATE TABLE "Tiempo"(
    "Id_fecha" integer,--timestamp, date ?
    dia integer CHECK (dia between 1 AND 31),
    mes integer CHECK (mes between 1 AND 12),
    trimestre integer CHECK (trimestre between 1 AND 4),
    año integer CHECK (año between 2000 and date_part('year',now())),
    CONSTRAINT "pk_Id_Fecha" PRIMARY KEY ("Id_fecha")
);