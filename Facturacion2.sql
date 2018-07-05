CREATE DOMAIN t_forma_pago varchar(15)
    DEFAULT 'EFECTIVO'
    CHECK (VALUE IN('EFECTIVO','DEBITO','CREDITO','CHEQUE'));

CREATE DOMAIN t_cod_tipo integer
    DEFAULT 1
    CHECK (VALUE BETWEEN 1 AND 4);

CREATE TABLE "Categoria"(
    cod_categoria integer,
    cod_subcategoria integer NOT NULL,
    descripcion varchar(100),
    CONSTRAINT "pk_cod_categoria" PRIMARY KEY ("cod_categoria"),
    CONSTRAINT "fk_cod_subcategoria" FOREIGN KEY ("cod_subcategoria") REFERENCES "Categoria"
);
CREATE TABLE "Tipo_Cliente" (
    cod_tipo integer NOT NULL,
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
    CONSTRAINT "fk_cod_categoria" FOREIGN KEY (cod_categoria) REFERENCES "Categoria" (cod_categoria)
    
);

CREATE TABLE "Medio_Pago"(
    "cod_Medio_Pago" serial,
    descripcion varchar(50),
    valor float,
    cantidad integer, --unidad en PDF
    tipo_operacion t_forma_pago, --varchar(50) o definir un tipo?
    CONSTRAINT "pk_Medio_Pago" PRIMARY KEY ("cod_Medio_Pago")
);


CREATE TABLE "Tiempo"(
    "Id_fecha" integer,
    fecha date,
    dia integer CHECK (dia between 1 AND 31),
    mes integer CHECK (mes between 1 AND 12),
    trimestre integer CHECK (trimestre between 1 AND 4),
    año integer CHECK (año between 2000 and date_part('year',now())),
    CONSTRAINT "pk_Id_Fecha" PRIMARY KEY ("Id_fecha",fecha)
);


CREATE TABLE "Venta"(
    "Fecha_Vta" date,
    "Id_Tiempo" integer,
    "Id_Factura" integer NOT NULL,
    "cod_Cliente" varchar(8) NOT NULL,
    "Nombre" varchar(50),
    cod_medio_pago integer,
    CONSTRAINT "pk_Id_Factura" PRIMARY KEY ("Id_Factura"),
    CONSTRAINT "fk_cod_Cliente" FOREIGN KEY ("cod_Cliente") REFERENCES "Clientes" ("cod_Cliente"),
    CONSTRAINT "fk_Medio_Pago" FOREIGN KEY (cod_medio_pago) REFERENCES "Medio_Pago" ("cod_Medio_Pago"),
    CONSTRAINT "fk_Tiempo1" FOREIGN KEY ("Id_Tiempo","Fecha_Vta") REFERENCES "Tiempo" ("Id_fecha",fecha)
);
CREATE TABLE "Detalle_Venta"(
    "Id_Factura" integer NOT NULL,
    cod_producto integer NOT NULL,
    descripcion varchar(100),
    unidad integer NOT NULL,--Deberia ser cantidad
    precio float NOT NULL,
    CONSTRAINT "fk_Id_Factura" FOREIGN KEY ("Id_Factura") REFERENCES "Venta",
    CONSTRAINT "fk_cod_producto" FOREIGN KEY ("cod_producto") REFERENCES "Producto"
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


CREATE OR REPLACE FUNCTION "crear_Tipo_Cliente"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
cod_t_tipo_cliente integer;
descripcion_tipo_cliente varchar(100);
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		cod_t_tipo_cliente = (SELECT MAX(cod_tipo)FROM "Tipo_Cliente")+1;
		descripcion_tipo_cliente = ('TIPO DE CLIENTE ' || cod_t_tipo_cliente); 
		INSERT INTO "Tipo_Cliente" VALUES (cod_t_tipo_cliente,descripcion_tipo_cliente);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;


INSERT INTO "Tipo_Cliente" VALUES (1,'TIPO DE CLIENTE 1');

SELECT("crear_Tipo_Cliente"(5));


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

INSERT INTO "Clientes" VALUES('12652862','Juan Perez',3,'Ramon y Cajal 2550');



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


--Inicializo la tabla "Medio_Pago"
INSERT INTO "Medio_Pago" VALUES (1,'El primer pago',424.240255262703,3,'EFECTIVO');
INSERT INTO "Medio_Pago" VALUES (((SELECT MAX("cod_Medio_Pago")FROM "Medio_Pago")+1),'Segundo medio de pago',701.843223259771,5,'DEBITO');
INSERT INTO "Medio_Pago" VALUES (((SELECT MAX("cod_Medio_Pago")FROM "Medio_Pago")+1),'Tercer medio de pago',328.223224359797,8,'CREDITO');
INSERT INTO "Medio_Pago" VALUES (((SELECT MAX("cod_Medio_Pago")FROM "Medio_Pago")+1),'Cuarto medio de pago',205.824222329759,12,'CHEQUE');




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
		INSERT INTO "Tiempo" VALUES (id_fecha_tiempo,fecha_aux,dia_tiempo,mes_tiempo,trimestre_tiempo,año_tiempo);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inicializo la primer tupla.
INSERT INTO "Tiempo" VALUES(1,(SELECT current_date),(SELECT EXTRACT(DAY FROM current_date)),(SELECT EXTRACT(MONTH FROM current_date)),(SELECT((SELECT EXTRACT(MONTH FROM current_date)))/4),(SELECT EXTRACT(YEAR FROM current_date)));
--Utilizo la funcion creada para crear una tupla en la tabla Tiempo.
SELECT("crear_Tiempo"(9));


---------------
CREATE OR REPLACE FUNCTION "crear_Venta"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
j integer;
fecha_venta date;
id_tiempo_venta integer;
id_factura_venta integer;
cod_cliente_venta varchar(8);
nombre_venta varchar(50);
cod_medio_pago_venta integer;

dia_tiempo integer;
mes_tiempo integer;
trimestre_tiempo integer;
año_tiempo integer;
BEGIN
	i =1;
	FOR i IN i..cantidad LOOP
		fecha_venta = (SELECT cast(now() - '5 year'::interval * random() as date));
		IF (SELECT fecha FROM "Tiempo" WHERE fecha=fecha_venta) IS NOT NULL THEN
			id_tiempo_venta = (SELECT "Id_fecha" FROM "Tiempo" WHERE fecha=fecha_venta);
			id_factura_venta = (SELECT MAX("Id_Factura")FROM "Venta")+1;
			cod_cliente_venta = (SELECT "cod_Cliente" FROM "Clientes" ORDER BY RANDOM() LIMIT 1);
			nombre_venta = ('NOMBRE DE VENTA ' || id_factura_venta);
			cod_medio_pago_venta = (SELECT CEIL (random()*(SELECT MAX("cod_Medio_Pago")FROM "Medio_Pago"))); --No seria menjor tener como cod_medio_pago_venta 'EFECTIVO' 'DEBITO' ... ??
			INSERT INTO "Venta" VALUES(fecha_venta,id_tiempo_venta, id_factura_venta, cod_cliente_venta, nombre_venta, cod_medio_pago_venta);
		ELSE
			dia_tiempo = (SELECT EXTRACT (DAY FROM fecha_venta));
			mes_tiempo = (SELECT EXTRACT (MONTH FROM fecha_venta));
			año_tiempo = (SELECT EXTRACT (YEAR FROM fecha_venta));
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
			INSERT INTO "Tiempo" VALUES ((SELECT MAX("Id_fecha")FROM "Tiempo") + 1,
								 fecha_venta,dia_tiempo,mes_tiempo,
								 trimestre_tiempo,año_tiempo);
			id_tiempo_venta = (SELECT "Id_fecha" FROM "Tiempo" WHERE fecha=fecha_venta);
			id_factura_venta = (SELECT MAX("Id_Factura")FROM "Venta")+1;
			cod_cliente_venta = (SELECT "cod_Cliente" FROM "Clientes" ORDER BY RANDOM() LIMIT 1);
			nombre_venta = ('NOMBRE DE VENTA ' || id_factura_venta);
			cod_medio_pago_venta = (SELECT CEIL (random()*(SELECT MAX("cod_Medio_Pago")FROM "Medio_Pago"))); --No seria menjor tener como cod_medio_pago_venta 'EFECTIVO' 'DEBITO' ... ??
			INSERT INTO "Venta" VALUES(fecha_venta,id_tiempo_venta, id_factura_venta, cod_cliente_venta, nombre_venta, cod_medio_pago_venta);
		END IF;
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;

INSERT INTO "Venta" VALUES((SELECT current_date),1,1,'12652862','Primer Venta',1);
--Utilizo la funcion para agregar tuplas a Venta.
SELECT("crear_Venta"(9));
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



