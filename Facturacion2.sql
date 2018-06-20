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
CREATE DOMAIN t_cod_tipo AS integer
    DEFAULT 1 
    CHECK (VALUE IN (1,2,3,4));--son cuatro tipos en facturacion1
CREATE TABLE "Tipo_Cliente" (
    cod_tipo t_cod_tipo NOT NULL,
    descripcion varchar(100),
    CONSTRAINT "pk_Tipo_Cliente" PRIMARY KEY (cod_tipo)
);
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


------------------------------------------------------------------------------------------------------------
--Sector de funciones que agregan tuplasa cada tabla.


--Funcion que agrega tuplas a la tabla Categoria.
CREATE OR REPLACE FUNCTION "crear_Categoria"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
cod_categ integer;
cod_subcategoria integer;
descripcion varchar(100);
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		cod_categ = (SELECT MAX(cod_categoria) FROM "Categoria") +1;
		cod_subcategoria = (SELECT CEIL (random()*(SELECT MAX(cod_categoria) FROM "Categoria")));
		descripcion = ('DESCRIPCION ' || cod_categ);
		INSERT INTO "Categoria" VALUES(cod_categ,cod_subcategoria,descripcion);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto una primer tupla.
INSERT INTO "Categoria" VALUES(1,1,'Primer Descripcion');
--Utilizo la funcion que crea tuplas en la tabla Categoria.
SELECT("crear_Categoria"(5));
----------------


--COMENTADA PORQUE HACE MAL LA PARTE DE "cod_t_tipo_cliente = (SELECT CEIL(random()*4));"


--Funcion que agrega tuplas a la tabla "Tipo_Cliente"
--CREATE OR REPLACE FUNCTION "crear_Tipo_Cliente"(cantidad integer) RETURNS TEXT AS
--$$
--DECLARE
--i integer;
--cod_t_tipo_cliente integer;
--descripcion_tipo_cliente varchar(100);
--BEGIN
--	i =1;
--	FOR i IN i..cantidad LOOP
--		cod_t_tipo_cliente = (SELECT CEIL(random()*4));
--		descripcion_tipo_cliente = ('DESCRIPCIÓN DEL TIPO' || cod_t_tipo_cliente); 
--		INSERT INTO "Tipo_Cliente" VALUES (cod_t_tipo_cliente,descripcion_tipo_cliente);
--	END LOOP;
--	RETURN 'OK';
--END
--$$
--LANGUAGE plpgsql;

--SELECT("crear_Tipo_Cliente"(1));
------------------

CREATE OR REPLACE FUNCTION "crear_Clientes"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
j integer;
cod_cliente varchar(8);
nombre_cliente varchar(50);
cod_tipo_cliente t_cod_tipo;
direccion_cliente varchar(50);
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		cod_cliente = (SELECT CEIL(random()*99999999));--varchar? capas conviene integer.
		nombre_cliente = ('NOMBRE ' || cod_cliente);
		j = (SELECT CEIL(random()*4));
		cod_tipo_cliente = (SELECT CEIL(random()*4));
		CASE j
			WHEN 1 THEN
			direccion_cliente = 'ALMIRANTE BROWM 2500 ' || cod_cliente ;
			WHEN 2 THEN
			direccion_cliente = 'PERITO MORENO 350' || cod_cliente ;
			WHEN 3 THEN
			direccion_cliente = '25 DE MAYO Y AP BELL' || cod_cliente ;
			ELSE
			direccion_cliente = 'MOSCU 245' || cod_cliente ;
		END CASE;
		INSERT INTO "Clientes" VALUES (cod_cliente, nombre_cliente, cod_tipo_cliente, direccion_cliente);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;

INSERT INTO "Clientes" VALUES(1,'Carlos Sanchez',3,'Ramon y Cajal 2550');

SELECT("crear_Clientes"(4));
------------------

CREATE OR REPLACE FUNCTION "crear_Producto"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
---------------

CREATE OR REPLACE FUNCTION "crear_Venta"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
---------------

CREATE OR REPLACE FUNCTION "crear_Detalle_Venta"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
------------------

CREATE OR REPLACE FUNCTION "crear_Medio_Pago"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--------------------

CREATE OR REPLACE FUNCTION "crear_Tiempo"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
