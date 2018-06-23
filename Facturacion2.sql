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
    unidad integer NOT NULL,--Deberia ser cantidad
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
cod_producto integer;
nombre_producto varchar(50);
cod_cat_producto integer;
cod_subcat_producto integer;
precio_actual_producto float;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		cod_producto = (SELECT MAX("cod_Producto") FROM "Producto")+1;
		nombre_producto = ('NOMBRE DE PRODUCTO ' || cod_producto);
		cod_cat_producto = (SELECT CEIL(random()*(SELECT MAX(cod_categoria)FROM "Categoria")));
		cod_subcat_producto = (SELECT CEIL(random()*(SELECT MAX(cod_categoria)FROM "Categoria")));
		precio_actual_producto = (SELECT random()*1000 +100);
		INSERT INTO "Producto" VALUES(cod_producto, nombre_producto, cod_cat_producto, cod_subcat_producto, precio_actual_producto);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto una primer tupla en producto
INSERT INTO "Producto" VALUES (1,'DULCE DE MEMBRILLO',1,1,120.723479472101);
--Utilizo la funcion de cracion de tuplas en la tabla Producto.
SELECT("crear_Producto"(10));
---------------
CREATE OR REPLACE FUNCTION "crear_Venta"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
j integer;
fecha_venta date;
id_factura_venta integer;
cod_cliente_venta varchar(8);
nombre_venta varchar(50);
cod_medio_pago_venta integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
	--cast( now() - '60 year'::interval * random()  as date )
		fecha_venta = (SELECT cast( now() - '5 year'::interval * random()  as date ));
		id_factura_venta = (SELECT MAX("Id_Factura")FROM "Venta")+1;
		cod_cliente_venta = (SELECT "cod_Cliente" FROM "Clientes" ORDER BY RANDOM() LIMIT 1);
		nombre_venta = ('NOMBRE DE VENTA ' || id_factura_venta);
		cod_medio_pago_venta = (SELECT CEIL (random()*4)); --No seria menjor tener como cod_medio_pago_venta 'EFECTIVO' 'DEBITO' ... ??
		INSERT INTO "Venta" VALUES(fecha_venta, id_factura_venta, cod_cliente_venta, nombre_venta, cod_medio_pago_venta);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto una primer tupla en Venta.
INSERT INTO "Venta" VALUES((SELECT current_date),1,1,'Primer Venta',1);
--Utilizo la funcion para agregar tuplas a Venta.
SELECT("crear_Venta"(10));
---------------

CREATE OR REPLACE FUNCTION "crear_Detalle_Venta"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
id_factura_detalle_venta integer;
cod_producto_detalle_venta integer;
descripcion_detalle_venta varchar(100);
unidad_detalle_venta integer;
precio_detalle_venta float;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		id_factura_detalle_venta = (SELECT "Id_Factura" FROM "Venta" ORDER BY RANDOM() LIMIT 1);
		cod_producto_detalle_venta = (SELECT "cod_Producto" FROM "Producto" ORDER BY RANDOM() LIMIT 1);
		descripcion_detalle_venta = ('En la venta ' || id_factura_detalle_venta || ' Se vendió el producto ' || cod_producto_detalle_venta) ;
		unidad_detalle_venta = (SELECT CEIL(random()*10)) ;
		precio_detalle_venta = (SELECT precio_actual FROM "Producto" WHERE "cod_Producto" = cod_producto_detalle_venta) * unidad_detalle_venta ;
		INSERT INTO "Detalle_Venta" VALUES(id_factura_detalle_venta, cod_producto_detalle_venta, descripcion_detalle_venta, unidad_detalle_venta, precio_detalle_venta);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--No hace falta insertar una primer tupla en este caso.
--Utilizo la funcion para crear multiples detalles.
SELECT("crear_Detalle_Venta"(10));

------------------
CREATE OR REPLACE FUNCTION "crear_Medio_Pago"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
j integer;
codigo_medio_pago varchar(15);--t_forma_pago puse anteriormente y no funcionaba
descripcion_medio_pago varchar (100);
valor_medio_pago float;
cantidad_medio_pago integer;
tipo_operacion_medio_pago integer; 	
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		j = (SELECT CEIL(random()* 4));
		CASE j
			WHEN 1 THEN
				codigo_medio_pago = 'EFECTIVO' ;
			WHEN 2 THEN
				codigo_medio_pago = 'DEBITO' ;
			WHEN 3 THEN
				codigo_medio_pago = 'CREDITO' ;
			ELSE
				codigo_medio_pago = 'CHEQUE' ;
		END CASE;
		descripcion_medio_pago = ('Descripcion del medio ' || codigo_medio_pago);
		valor_medio_pago = (SELECT random()*500);
		cantidad_medio_pago = (SELECT CEIL (random()*12));
		tipo_operacion_medio_pago = (SELECT CEIL(random()*3));
		INSERT INTO "Medio_Pago" VALUES (codigo_medio_pago, descripcion_medio_pago, valor_medio_pago, cantidad_medio_pago, tipo_operacion_medio_pago);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inicializo la tabla "Medio_Pago"
INSERT INTO "Medio_Pago" VALUES ('EFECTIVO','El primer pago',424.240255262703,5,1);
--Utilizo la funcion para crear tuplas en la tabla "Medio_Pago" 
SELECT("crear_Medio_Pago"(1));
--TIENE MEDIO DE PAGO COMO PRIMARY KEY, POR LO TANTO SOLO PODEMOS PONER 4 TUPLAS, DEBERIAMOS HACER UNA CLAVE COMPUESTA.
--------------------






--CREATE TABLE "Tiempo"(
--    "Id_fecha" integer,--timestamp, date ?
--    dia integer CHECK (dia between 1 AND 31),
--    mes integer CHECK (mes between 1 AND 12),
--    trimestre integer CHECK (trimestre between 1 AND 4), --Creo
--    año integer CHECK (año between 2000 and date_part('year',now())),
--    CONSTRAINT "pk_Id_Fecha" PRIMARY KEY ("Id_fecha")
--);
CREATE OR REPLACE FUNCTION "crear_Tiempo"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
id_fecha_tiempo integer;
fecha_aux date;
dia_tiempo integer;
mes_tiempo integer;
trimestre_tiempo integer;
año_tiempo integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		id_fecha_tiempo = (SELECT MAX("Id_fecha")FROM "Tiempo") + 1 ;
		fecha_aux = (SELECT now() - '5 year'::interval * random() as date);
		dia_tiempo = (SELECT EXTRACT(DAY FROM fecha_aux));
		mes_tiempo = (SELECT EXTRACT (MONTH FROM fecha_aux));
		CASE mes_tiempo
			WHEN 1,2,3 THEN
				trimestre_tiempo = 1 ;
			WHEN 4,5,6 THEN 
				trimestre_tiempo = 2 ;
			WHEN 7,8,9 THEN 
				trimestre_tiempo = 3 ;
			ELSE
				trimestre_tiempo = 4 ;
		END CASE;
		año_tiempo = (SELECT EXTRACT(YEAR FROM fecha_aux));
		INSERT INTO "Tiempo" VALUES (id_fecha_tiempo,dia_tiempo,mes_tiempo,trimestre_tiempo,año_tiempo);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inicializo la primer tupla.
INSERT INTO "Tiempo" VALUES(1,(SELECT EXTRACT(DAY FROM current_date)),(SELECT EXTRACT(MONTH FROM current_date)),(SELECT((SELECT EXTRACT(MONTH FROM current_date)))/4),(SELECT EXTRACT(YEAR FROM current_date)));
--Utilizo la funcion creada para crear una tupla en la tabla Tiempo.
SELECT("crear_Tiempo"(10));