CREATE DOMAIN t_tipo AS varchar(10)
	DEFAULT 'TIPO 1'
	CHECK (VALUE IN ('TIPO 1','TIPO 2','TIPO 3','TIPO 4') );
CREATE TABLE "Clientes" (
	"nro_Cliente" integer NOT NULL,
	"Nombre" varchar(50) NOT NULL,
	tipo t_tipo,
	direccion varchar(50),
	CONSTRAINT "pk_Cliente" PRIMARY KEY ("nro_Cliente")
);
CREATE TABLE "Categoria" (
	nro_categ integer NOT NULL,
	descripcion varchar(100),
	CONSTRAINT "pk_Categoria" PRIMARY KEY (nro_categ)
);

CREATE DOMAIN t_forma_pago varchar(15)
	DEFAULT 'EFECTIVO'
	CHECK (VALUE IN('EFECTIVO','DEBITO','CREDITO','CHEQUE'));
CREATE TABLE "Venta" (
	"nro_Factura" integer NOT NULL,
	"Fecha_Vta" date NOT NULL,
	"nro_Cliente" integer NOT NULL,
	"Nombre" varchar(50),
	forma_pago  t_forma_pago,
	CONSTRAINT "pk_Venta" PRIMARY KEY ("nro_Factura"),
	CONSTRAINT "fk_nro_Cliente" FOREIGN KEY ("nro_Cliente") REFERENCES public."Clientes" ("nro_Cliente") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
--	CONSTRAINT "fk_Nombre" FOREIGN KEY ("Nombre") REFERENCES public."Clientes" ("Nombre") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
--el campo cantidad, es en el pdf, unidad.
CREATE TABLE "Detalle_Vta" (
	nro_factura integer NOT NULL,
	nro_producto integer NOT NULL,
	descripcion varchar(100),
	cantidad integer,
	precio float,
	CONSTRAINT "pk_Detalle_Vta" PRIMARY KEY (nro_factura),
	CONSTRAINT fk_nro_producto FOREIGN KEY (nro_producto) REFERENCES public."Producto" ("nro_Producto") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);

--Creo la Tabla Productos.
CREATE TABLE "Producto" (
	"nro_Producto" integer NOT NULL,
	"Nombre" varchar(50) NOT NULL,
	nro_categ integer NOT NULL,
	precio_actual integer NOT NULL,
	CONSTRAINT "pk_Producto" PRIMARY KEY ("nro_Producto"),
	CONSTRAINT fk_nro_categ FOREIGN KEY (nro_categ) REFERENCES public."Categoria" (nro_categ)
);
--___________________________________________________________________________________________________________________________________


	
--Funcion que agrega Clientes.
CREATE OR REPLACE FUNCTION "agregar_Clientes"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
j integer;
k integer;
nro_cliente integer;
nombre_cliente varchar(50);
tipo_cliente t_tipo;
direccion_cliente varchar(50);
BEGIN
	i=1;
	FOR i IN i..cantidad LOOP
		nro_cliente = (SELECT MAX("nro_Cliente") FROM "Clientes")+1;
		nombre_cliente = ('Cliente ' || nro_cliente);
		j = (SELECT CEIL(random()*4));
		CASE j 
			WHEN 1 THEN 
				tipo_cliente := 'TIPO 1';
			WHEN 2 THEN
				tipo_cliente := 'TIPO 2';
			WHEN 3 THEN 
				tipo_cliente := 'TIPO 3';
			ELSE 
				tipo_cliente := 'TIPO 4';
		END CASE;
		k = (SELECT CEIL(random()*5));
		CASE k
			WHEN 1 THEN
				direccion_cliente := 'San Martin ' || nro_cliente || ' y 28 de Julio';
			WHEN 2 THEN
				direccion_cliente := 'Almirante Brown ' || nro_cliente || ' y Perito Moreno';
			WHEN 3 THEN
				direccion_cliente := 'Manuel Belgrano ' || nro_cliente;
			WHEN 3 THEN
				direccion_cliente := 'Ricardo Berwin ' || nro_cliente;
			ELSE
				direccion_cliente := 'Avenida Fontana ' || nro_cliente || ' e Italia';
		END CASE;
		INSERT INTO "Clientes" VALUES (nro_cliente,nombre_cliente,tipo_cliente,direccion_cliente);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql; 

--Se crea el primer elemento (Precondición de la función).
INSERT INTO "Clientes" VALUES (1,'Juan Perez','TIPO 1','Av Siempreviva 123');

--Llamada a la funcion para agregar clientes.
SELECT ("agregar_Clientes"(8))

--Definición de la funcion "crearCategorias" crea categorias distintas para cada tipo nuevo según el número pasado por parámetro.
CREATE OR REPLACE FUNCTION "crear_Categorias"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
nro_categoria integer;
descripcion_categoria varchar(100);
BEGIN
	i = 1;
	FOR i IN i..cantidad LOOP
		nro_categoria = (SELECT MAX(nro_categ) FROM "Categoria") +1;
		descripcion_categoria = ('Esta es la descripcion, CATEGORIA ' || nro_categoria);
		INSERT INTO "Categoria" VALUES (nro_categoria, descripcion_categoria);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Se crea el primer elemento (Precondición de la función).
INSERT INTO "Categoria" VALUES (1,'Primer Categoria');
--Llamo a la función que crea categorias.
SELECT ( "crear_Categorias"(5));

--Definicion de la funcion "agregar_Productos" genera y agrega la cantidad de productos segun el número que pasen por parámetro.
CREATE OR REPLACE FUNCTION "agregar_Productos"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
nro_producto integer;
nombre_producto varchar(50);
numero_categ_producto integer;
precio_actual_producto integer;
BEGIN
	i = 1;
	FOR i IN i..cantidad LOOP
		nro_producto = (SELECT MAX("nro_Producto") FROM "Producto") + 1;
		nombre_producto = ('PRODUCTO ' || nro_producto);
		numero_categ_producto = (SELECT CEIL(random()*(SELECT MAX(nro_categ) FROM "Categoria")));
		precio_actual_producto = (SELECT CEIL(random()* 1000)+100);		
		INSERT INTO "Producto" VALUES (nro_producto,nombre_producto,numero_categ_producto,precio_actual_producto);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Creo una primer tupla de Producto.
INSERT INTO "Producto" VALUES(1,'Primer Producto',1,250);
--Utilizo la Funcion para crear mas tupas de productos.
SELECT("agregar_Productos"(9));

--Funcion que agrega tuplas a la tabla Detalle_Vta
CREATE OR REPLACE FUNCTION "crear_Detalle_Vta"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
nro_factura_detalle_vta integer;
nro_producto_detalle_vta integer;
descripcion_detalle_vta varchar(100);
cantidad_detalle_vta integer;
precio_detalle_vta float;

BEGIN
	i=1;
	FOR i IN i..cantidad LOOP
		nro_factura_detalle_vta = (SELECT MAX(nro_factura)FROM "Detalle_Vta") +1;
		nro_producto_detalle_vta = (SELECT CEIL(random()*(SELECT MAX("nro_Producto") FROM "Producto")));
		descripcion_detalle_vta = ('DESCRIPCIÓN ' || nro_factura_detalle_vta);
		cantidad_detalle_vta = (SELECT CEIL(random()*1000));
		precio_detalle_vta = (SELECT (random()*1000));
		INSERT INTO "Detalle_Vta" VALUES (nro_factura_detalle_vta,nro_producto_detalle_vta,descripcion_detalle_vta,cantidad_detalle_vta,precio_detalle_vta);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Agrego una primer tupla a Detalle_Vta
INSERT INTO "Detalle_Vta" VALUES (1,1,'DESCRIPCION 1',3,508.593718986958);
--Utilizo la funcion que agrega tuplas a la tabla Detalle_Vta
SELECT("crear_Detalle_Vta"(9)) ;

--Funcion que agrega tuplas a la tabla "Venta".
CREATE OR REPLACE FUNCTION "crear_Venta"(cantidad integer)RETURNS TEXT AS
$$
DECLARE
i integer;
j integer;
nro_factura_venta integer;
fecha_venta date;
nro_cliente_venta integer;
nombre_venta varchar(50);
forma_pago_venta t_forma_pago;
BEGIN
	i = 1;
	FOR i IN i..cantidad LOOP
		nro_factura_venta = (SELECT MAX("nro_Factura") FROM "Venta") +1;
		fecha_venta = (SELECT(SELECT now() - '5 years'::interval * random() as date ) );
		nro_cliente_venta = ( SELECT CEIL(random()*(SELECT MAX("nro_Cliente") FROM "Clientes")) );
		nombre_venta = ('Venta ' || nro_factura_venta);
		j = (SELECT CEIL(random()*4));
		CASE j
			WHEN 1 THEN 
				forma_pago_venta := 'EFECTIVO';
			WHEN 2 THEN
				forma_pago_venta := 'DEBITO';
			WHEN 3 THEN 
				forma_pago_venta := 'CREDITO';
			ELSE 
				forma_pago_venta := 'CHEQUE';
		END CASE;		
		INSERT INTO "Venta" VALUES(nro_factura_venta,fecha_venta,nro_cliente_venta,nombre_venta,forma_pago_venta);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto la primer tupla de "Venta"
INSERT INTO "Venta" VALUES (1,(SELECT now()),1,'Primer Venta','DEBITO');
--Utilizo funcion para agregar tuplas a Venta.
SELECT("crear_Venta"(9)) ;
