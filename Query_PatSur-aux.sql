CREATE EXTENSION dblink
--Conexion a la base de Facturacion1.
SELECT dblink_connect('conexionFacturacion1','dbname = Facturacion1 user=postgres password = postgres');
--Conexion a la base de Facturacion2.
SELECT dblink_connect('conexionFacturacion2a','dbname = Facturacion2 user=postgres password = postgres');--tuve que poner "a" al final porque no le gustaba sino.


--Creo la tabla Categoria
CREATE TABLE "Categoria" (
	"Id_Categoria" integer,
	descripcion varchar(100),
	"Id_Subcategoria" integer,
	CONSTRAINT "pk_Categoria" PRIMARY KEY ("Id_Categoria")
);

--Creo la tabla Producto.
CREATE TABLE "Productos" (
	"Id_Producto" integer,
	"Nombre" varchar(50),
	"Id_Categoria" integer,
	"Id_Subcategoria" integer,
	precio float,
CONSTRAINT "pk_Producto" PRIMARY KEY ("Id_Producto"),
CONSTRAINT "fk_Categoria" FOREIGN KEY ("Id_Categoria") REFERENCES public."Categoria" ("Id_Categoria") 
);


CREATE DOMAIN t_tipo AS varchar(10)
	DEFAULT 'TIPO 1'
	CHECK (VALUE IN ('TIPO 1','TIPO 2','TIPO 3','TIPO 4') );


--Creo la tabla Tipo_Cliente.
CREATE TABLE "Tipo_Cliente" (
"Id_Tipo" integer NOT NULL,
descripcion varchar(100),
CONSTRAINT "pk_Tipo_Cliente" PRIMARY KEY ("Id_Tipo")
);


--Creo la tabla Clientes
CREATE TABLE "Clientes" (
	"Id_Cliente" integer,
	"Nombre" varchar(50),
	"Apellido" varchar(50),
	"Id_tipo" integer,
	CONSTRAINT "pk_Cliente" PRIMARY KEY ("Id_Cliente"),
	CONSTRAINT "fk_Tipo_Cliente" FOREIGN KEY ("Id_tipo") REFERENCES "Tipo_Cliente" ("Id_Tipo")
);
--ALTER TABLE "Clientes" ALTER "Id_tipo" TYPE integer;
--ALTER TABLE "Clientes" ADD CONSTRAINT "pk_Cliente" PRIMARY KEY ("Id_Cliente");
--ALTER TABLE "Clientes" ADD CONSTRAINT "fk_Tipo_Cliente" FOREIGN KEY ("Id_tipo") REFERENCES "Tipo_Cliente" ("Id_Tipo");

--Creo la tabla Tiempo.
CREATE TABLE "Tiempo" (
	"Id_Tiempo" integer,
	fecha date,
	dia integer CHECK (dia between 1 AND 31),
	mes integer CHECK (mes between 1 AND 12),
	trimestre integer CHECK (trimestre between 1 AND 4),
	año integer CHECK (año between 2000 and date_part('year',now())),
	CONSTRAINT "pk_Tiempo" PRIMARY KEY ("Id_Tiempo",fecha)
);

CREATE DOMAIN t_forma_pago varchar(15)
    DEFAULT 'EFECTIVO'
    CHECK (VALUE IN('EFECTIVO','DEBITO','CREDITO','CHEQUE'));
--Creo la tabla Medios.
CREATE TABLE "Medios" (
	"Id_Medio_Pago" t_forma_pago,
	descripcion varchar(100),
	CONSTRAINT "pk_Medios" PRIMARY KEY("Id_Medio_Pago"))

--Creo la tabla Region
CREATE TABLE "Region" (
	"Id_Region" integer,
	descripcion varchar(100),
	CONSTRAINT "pk_Region" PRIMARY KEY ("Id_Region"));
--Creo la tabla Provincia.
CREATE TABLE "Provincia"(
	"Id_Provincia" integer,
	descripcion varchar(100),
	"Id_Region" integer,
	CONSTRAINT "pk_Provincia" PRIMARY KEY ("Id_Provincia"),
	CONSTRAINT "fk_Region" FOREIGN KEY ("Id_Region") REFERENCES "Region" ("Id_Region"));

--Creo la tabla Ciudad.
CREATE TABLE "Ciudad"(
	"Id_Ciudad" integer,
	descripcion varchar (100),
	"Id_Provincia" integer,
	CONSTRAINT "pk_Ciudad" PRIMARY KEY ("Id_Ciudad"),
	CONSTRAINT "fk_Provincia" FOREIGN KEY ("Id_Provincia") REFERENCES "Provincia"
 );
--Creo la tabla Distribucion Geografica.
CREATE TABLE "Distribucion_Geografica"(
	"Id_Sucursal" integer,
	descripcion varchar (100),
	"Id_Ciudad" integer,
	CONSTRAINT "pk_DG" PRIMARY KEY ("Id_Sucursal"),
	CONSTRAINT "fk_Ciudad" FOREIGN KEY ("Id_Ciudad") REFERENCES "Ciudad"
 );
--Creo la tabla Ventas.
CREATE TABLE "Ventas" (
	"Fecha" date,
	"Id_Tiempo" integer,
	"Id_Factura" integer,
	"Id_Cliente" integer,
	"Id_Producto" integer,
	"Id_Sucursal" integer,
	"Monto_vendido" float,
	"Cantidad_Vendida" integer,
	"Id_Medio_Pago" t_forma_pago,
	CONSTRAINT "pk_Venta" PRIMARY KEY ("Id_Factura"),
	CONSTRAINT "fk_Tiempo" FOREIGN KEY ("Id_Tiempo","Fecha") REFERENCES "Tiempo" ("Id_Tiempo",fecha),
	CONSTRAINT "fk_Cliente" FOREIGN KEY ("Id_Cliente") REFERENCES "Clientes" ("Id_Cliente"),
	CONSTRAINT "fk_Producto" FOREIGN KEY ("Id_Producto") REFERENCES "Productos" ("Id_Producto"),
	CONSTRAINT "fk_DG" FOREIGN KEY ("Id_Sucursal") REFERENCES "Distribucion_Geografica" ("Id_Sucursal"),
	CONSTRAINT "fk_Medios" FOREIGN KEY ("Id_Medio_Pago") REFERENCES "Medios" ("Id_Medio_Pago")
	);

CREATE TABLE "Eq_Clientes" (
	idc1 integer,
	idc2 varchar(8),
	nombre1 varchar(50),
	nombre2 varchar(50),
	apellido1 varchar(50),
	apellido2 varchar(50),
	tipo1 t_tipo,
	tipo2 integer,
	nueva_clave serial
);

CREATE TABLE "Eq_Productos" (
	idp1 integer,
	nombre1 varchar(50),
	nro_cat1 integer,
	precio1 integer,
	idp2 integer,
	nombre2 varchar(50),
	cod_cat2 integer,
	cod_subcat2 integer,
	precio2 float,
	clave_nueva serial
);

CREATE TABLE "Eq_Ventas"(
	"Fecha_Vta1" date,
	"nro_Factura1" integer,
	"nro_Cliente1" integer,
	"Nombre1" varchar(50),
	forma_pago1 t_forma_pago,
	"Fecha_Vta2" date,
	"Id_Tiempo2" integer,
	"id_Prod" integer,
	cantidad integer,
	monto float,
	"Id_Factura2" integer,
	"cod_Cliente2" integer,
	"Nombre2" varchar(50),
	cod_medio_pago varchar(15),
	"claveDW_Ventas" serial	
);

--"Fecha","Id_Tiempo","Id_Factura","Id_Cliente","Id_Producto"
--"Id_Sucursal" , "Monto_vendido", "Cantidad_Vendida", "Id_Medio_Pago"  
CREATE OR REPLACE FUNCTION "agregar_A_EqVentas"() RETURNS void AS
$$
DECLARE
medio text;
cursor_temp CURSOR FOR SELECT * FROM "tmp_V2";
row_temp RECORD; 
BEGIN
	
	FOR row_temp IN cursor_temp LOOP
		
		CASE row_temp.cod_medio_pago
			WHEN 1 THEN 
				medio = 'EFECTIVO';
			WHEN 2 THEN
				medio = 'DEBITO';
			WHEN 3 THEN
				medio = 'CREDITO';
			ELSE
				medio = 'CHEQUE';
		END CASE;
		INSERT INTO "Eq_Ventas" VALUES(null,null,null,null,null,row_temp.fecha,row_temp.tiempo,row_temp.id_prod,row_temp.cantidad,row_temp.precio,row_temp.factura,row_temp.cliente,row_temp.nombre,medio);
	END LOOP;
END
$$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION "llenar_Ventas"() RETURNS void AS
$$
DECLARE 
medio text;
cursor_ventas CURSOR FOR SELECT * FROM "Eq_Ventas";
row_venta RECORD; 
BEGIN
	FOR row_venta IN cursor_ventas LOOP
		IF row_venta."nro_Factura1" IS NOT NULL THEN
			INSERT INTO "Ventas" VALUES (row_venta."Fecha_Vta1",(SELECT "Id_Tiempo" FROM 
						     "Tiempo" WHERE fecha = row_venta."Fecha_Vta1"),
						     row_venta."claveDW_Ventas",row_venta."nro_Cliente1",
						     (SELECT nro_producto FROM dblink('conexionFacturacion1',
						     'SELECT nro_producto FROM "Detalle_Vta" WHERE nro_factura ='
						      || row_venta."nro_Factura1") AS prodf1(nro_producto integer)),
						      1,(SELECT precio FROM dblink('conexionFacturacion1',
						     'SELECT precio FROM "Detalle_Vta" WHERE nro_factura ='||
						      row_venta."nro_Factura1") AS precf1(precio float)),
						      (SELECT cantidad FROM dblink('conexionFacturacion1',
						     'SELECT cantidad FROM "Detalle_Vta" WHERE nro_factura ='||
						      row_venta."nro_Factura1") AS cantf1(cantidad float)),
						      row_venta.forma_pago1);
		ELSE
		
			INSERT INTO "Ventas" (SELECT row_venta."Fecha_Vta2",row_venta."Id_Tiempo2",row_venta."Id_Factura2",row_venta."cod_Cliente2",
						row_venta."id_Prod",2,row_venta.monto,row_venta.cantidad, row_venta.cod_medio_pago 
						--FROM "Eq_Ventas" eq WHERE row_venta."Id_Factura2"=eq."claveDW_Ventas" 
						 ) ;
		END IF;
		
	END LOOP;
END;
$$ 
LANGUAGE plpgsql;

SELECT "crear_Ventas"();
--Inserto tuplas en la tabla local Ventas a partir de las tablas remotas 
--categoria de facturacion1 y de facturacion2.

CREATE OR REPLACE FUNCTION "crear_Ventas"() RETURNS TEXT AS
$$
DECLARE
BEGIN
	INSERT INTO "Eq_Ventas" ((SELECT "Fecha_Vta1","nro_Factura1","nro_Cliente1",
		"Nombre1",forma_pago1,"Fecha_Vta2","Id_Tiempo2","id_Prod",cantidad,monto,"Id_Factura2",
		"cod_Cliente2","Nombre2",cod_medio_pago2
		FROM dblink('conexionFacturacion1','SELECT 
		"nro_Factura","Fecha_Vta","nro_Cliente","Nombre",forma_pago,
		null,null,null,null,null,null,null,null,null
		FROM "Venta"') AS ventasf1("nro_Factura1" integer,"Fecha_Vta1" date,
		"nro_Cliente1" integer,"Nombre1" varchar(50),forma_pago1 varchar(15),
		"Fecha_Vta2" date,"id_Prod" integer,cantidad integer, monto float,"Id_Tiempo2" integer,"Id_Factura2" integer,
		"cod_Cliente2" integer, "Nombre2" varchar(50), cod_medio_pago2 integer))
		);
	CREATE TABLE "tmp_V2"(
		fecha date,
		tiempo integer,
		id_prod integer,
		factura integer,
		cliente integer,
		nombre varchar(50),
		cod_medio_pago integer,
		cantidad integer,
		precio float
	);
	INSERT INTO "tmp_V2" (
		SELECT ventasf2."Fecha_Vta2",ventasf2."Id_Tiempo2",ventasf2."Id_Factura2",ventasf2."id_Prod",ventasf2."cod_Cliente2",ventasf2."Nombre2",
		ventasf2.cod_medio_pago2, ventasf2.cantidad, ventasf2.precio FROM dblink('conexionFacturacion2a','SELECT v."Fecha_Vta",
		v."Id_Tiempo",d.cod_producto,v."Id_Factura",v."cod_Cliente",v."Nombre",v.cod_medio_pago, sum(d.unidad) as cantidad, sum(d.precio) as precio
		FROM "Venta" v, "Detalle_Venta" d WHERE v."Id_Factura"=d."Id_Factura"  GROUP BY (v."Id_Factura",d.cod_producto) ')AS ventasf2("Fecha_Vta2" date,"Id_Tiempo2" integer,
		"id_Prod" integer,"Id_Factura2" integer,"cod_Cliente2" integer, "Nombre2" varchar(50),
		cod_medio_pago2 integer, cantidad integer, precio float) 
		);
	PERFORM (SELECT "agregar_A_EqVentas"());
	DROP TABLE "tmp_V2";	
	
	PERFORM (SELECT "llenar_Ventas"());
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;


SELECT "crear_Ventas"();
---------------------------
-------------------
/*
CREATE OR REPLACE FUNCTION "llenar_Detalle"(fecha date, t integer, f integer, c integer,n text, cmp text, id_dw integer)RETURNS void AS
$$
DECLARE
cursor_detalles CURSOR FOR SELECT * FROM "tmp_Detalle";
row_detalle RECORD; 
BEGIN
	INSERT INTO "tmp_Detalle" (
			SELECT cod_producto,precio,unidad FROM(
			(SELECT id_f,cod_producto FROM dblink('conexionFacturacion2a',
			'SELECT "Id_Factura",cod_producto FROM "Detalle_Venta" 
		         WHERE "Id_Factura"=' || f)
			 AS prodf2(id_f integer,cod_producto integer)) AS t0
			 INNER JOIN (SELECT id_f,precio FROM dblink('conexionFacturacion2a',
				      'SELECT "Id_Factura",precio FROM "Detalle_Venta" 
		   	 	       WHERE "Id_Factura"=' || f)
				       AS preciof2(id_f integer,precio float)) AS t1 
			ON t0.id_f=t1.id_f
			INNER JOIN (SELECT id_f,unidad FROM dblink('conexionFacturacion2a',
				    'SELECT "Id_Factura",unidad FROM "Detalle_Venta" 
				     WHERE "Id_Factura"='||f)
				     AS cantf2(id_f integer,unidad integer)) AS t2
			ON t0.id_f = t2.id_f)
		);
	FOR row_detalle IN cursor_detalles LOOP
		INSERT INTO "Eq_Ventas" VALUES(null,null,null,null,null,fecha,t,f,c,cmp);
	END LOOP;
	DROP TABLE "tmp_Detalle";
	
END
$$
LANGUAGE plpgsql;
*/
---------------
------------------
-----------------------------------------------------------------------------------------
--Inserto tuplas en la tabla Local Categoria a partir de las tablas remotas 
--categoria de facturacion1 y de facturacion2.
INSERT INTO "Categoria" (
SELECT f1.nro_categ1, f1.descripcion1, f2.id_subcategoria2 
FROM (SELECT nro_categ1,descripcion1 
	FROM dblink('conexionFacturacion1',
		    'SELECT nro_categ, descripcion,null FROM "Categoria"') AS facturacion1
		    (nro_categ1 integer,descripcion1 varchar(100),cod_subcategoria1 integer) ) f1
FULL OUTER JOIN (
	SELECT nro_categ2,descripcion2,id_subcategoria2
	FROM dblink('conexionFacturacion2a','SELECT cod_categoria, descripcion,
		     cod_subcategoria FROM "Categoria"') AS facturacion2
	(nro_categ2 integer, descripcion2 varchar(100), id_subcategoria2 integer)
		) f2 ON f1.nro_categ1 = f2.nro_categ2 );
--Inserto a la tabla Productos Local los elementos de producto pertenecientes a las 2 tablas 
--remotas de productos(Productos ->Facturacion1 // Productos ->Facturacion2).
--------------------------------------------------------
CREATE OR REPLACE FUNCTION "llenar_Productos"() RETURNS void AS
$$
DECLARE 
cursor_productos CURSOR FOR SELECT * FROM "Eq_Productos";
row_producto RECORD; 
BEGIN
	FOR row_producto IN cursor_productos LOOP
		IF row_producto.idp2 IS NOT NULL THEN
			INSERT INTO "Productos" VALUES( row_producto.idp2, row_producto.nombre2, row_producto.cod_cat2, row_producto.cod_subcat2, row_producto.precio2);
		ELSE
			INSERT INTO "Productos" VALUES( row_producto.idp1, row_producto.nombre1, row_producto.nro_cat1, null, row_producto.precio1 );
		END IF;
	END LOOP;
END;
$$LANGUAGE plpgsql;

--------------------------------------------
CREATE OR REPLACE FUNCTION "cargar_Productos"() RETURNS text AS 
$$
DECLARE
BEGIN

INSERT INTO "Eq_Productos" (
SELECT f1.id_prod1,f1.nombre_prod1,f1.id_cat_prod1,f1.precio1, f2.id_prod2, f2.nombre_prod2,f2.id_cat_prod2,f2.id_subcat_prod2,f2.precio2   
FROM (SELECT id_prod2, nombre_prod2, id_cat_prod2,id_subcat_prod2 ,precio2
      FROM dblink('conexionFacturacion2a','SELECT "cod_Producto",
		  "Nombre",cod_categoria,cod_subcategoria,precio_actual FROM "Producto"')
		  AS facturacion2 (id_prod2 integer,nombre_prod2 varchar(50),
				  id_cat_prod2 integer, id_subcat_prod2 integer,precio2 float)) f2
FULL OUTER JOIN (
	SELECT id_prod1, nombre_prod1 ,id_cat_prod1 ,id_subcat_prod1 ,precio1
	FROM dblink('conexionFacturacion1','SELECT "nro_Producto","Nombre",
		     nro_categ,null,precio_actual FROM "Producto"') AS facturacion1 
			(id_prod1 integer,nombre_prod1 varchar(50), 
			id_cat_prod1 integer,id_subcat_prod1 integer,precio1 integer)
		) f1 ON f1.id_prod1 = f2.id_prod2
);
 PERFORM (SELECT "llenar_Productos"());
RETURN 'OK';
END;
$$ 
language plpgsql;


select "cargar_Productos"();


--Creo la clave foranea de PRODUCTOS hacia CATEGORIA
--ALTER TABLE "Productos" ADD CONSTRAINT "fk_Categoria" FOREIGN KEY ("Id_Categoria") REFERENCES "Categoria" ("Id_Categoria");
                            

--Inserto tuplas en la tabla Local Cliente a partir de las tablas remotas 
--categoria de facturacion1 y de facturacion2.
--------------------------------------------
CREATE OR REPLACE FUNCTION "llenar_Clientes"() RETURNS void AS
$$
DECLARE
var_tipo integer;
cursor_clientes CURSOR FOR SELECT * FROM "Eq_Clientes";
row_cliente RECORD;
BEGIN
	FOR row_cliente IN cursor_clientes LOOP
		IF row_cliente.idc1 IS NOT NULL THEN
			CASE row_cliente.tipo1
				WHEN 'TIPO 1' THEN
					var_tipo = 1;
				WHEN 'TIPO 2' THEN
					var_tipo = 2;
				WHEN 'TIPO 3' THEN
					var_tipo = 3;
				ELSE
					var_tipo = 4;
			END CASE;
			INSERT INTO "Clientes" (SELECT row_cliente.nueva_clave,row_cliente.nombre1,row_cliente.apellido1,var_tipo) ;
		ELSE
			INSERT INTO "Clientes" (SELECT row_cliente.nueva_clave,row_cliente.nombre2,row_cliente.apellido2,row_cliente.tipo2) ;
		END IF;
	END LOOP;
END
$$
LANGUAGE plpgsql;
--Función de carga para la tabla local Clientes utilizando los datos de clientes en facturacion1 y facturacion2.
-----------------------------------
CREATE OR REPLACE FUNCTION "cargar_Clientes"() RETURNS TEXT AS
$$
DECLARE
BEGIN

	INSERT INTO "Eq_Clientes" (SELECT  c1.id_cliente1,c2.id_cliente2,c1.nombre1,c2.nombre2,
					    c1.apellido1,c2.apellido2,c1.id_tipo1,c2.id_tipo2
				    FROM (SELECT id_cliente1,nombre1,apellido1,id_tipo1 
					  FROM dblink('conexionFacturacion1','SELECT "nro_Cliente",
						      "Nombre",null,tipo  FROM "Clientes"') 
					  AS clientes1(id_cliente1 integer, nombre1 varchar(50),
						       apellido1 varchar(50),id_tipo1 varchar(15))) AS c1
				    FULL OUTER JOIN ( 
					(SELECT id_cliente2,nombre2, apellido2, id_tipo2
					 FROM dblink('conexionFacturacion2a','SELECT "cod_Cliente",
						     "Nombre", null,cod_tipo FROM "Clientes" ')
					 AS clientes2(id_cliente2 varchar(8),nombre2 varchar(50),
						      apellido2 varchar(50),id_tipo2 integer))) AS c2 
				   --ON c1.id_cliente1 = (SELECT cast(id_cliente2 as integer)) 
				   ON c1.nombre1 = c2.nombre2
				   GROUP BY (c1.id_cliente1,c2.id_cliente2,
				   c1.nombre1,c2.nombre2,c1.apellido1,
				   c2.apellido2,c1.id_tipo1,c2.id_tipo2)
				   ORDER BY (id_cliente1,id_cliente2));

	PERFORM (SELECT "llenar_Clientes"());
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;

--Asigno a la tabla local "Tipo_Cliente" los valores de la tabla remota "Tipo_Cliente" de Facturacion1
INSERT INTO "Tipo_Cliente" (
			    SELECT ct,descr 
			    FROM dblink('conexionFacturacion2a','SELECT * FROM "Tipo_Cliente"') 
			    AS tipo_clientef2(ct integer, descr varchar(100)));

--Utilizo Funcion para inicializar la tabla local Clientes.

SELECT "cargar_Clientes"();


--Asigno a la tabla local "Tiempo" los datos de la tabla remota "Tiempo" de la BD Facturacion2.
------------------------
CREATE OR REPLACE FUNCTION "llenar_Tiempo2"() RETURNS void AS
$$
DECLARE
cursor_tiempo CURSOR FOR SELECT * FROM "tmp2_Tiempo";
row_tiempo RECORD;
id_tiempo integer;
BEGIN
	INSERT INTO "Tiempo" (
		SELECT idTf2,fecha2,diaf2,mesf2,trimestref2,añof2 
		FROM dblink('conexionFacturacion2a','SELECT "Id_fecha",fecha,
			    dia,mes,trimestre,año FROM "Tiempo"')AS (idTf2 integer,
			    fecha2 date, diaf2 integer, mesf2 integer, 
			    trimestref2 integer, añof2 integer)
	);
	FOR row_tiempo IN cursor_tiempo LOOP
		IF (SELECT fecha FROM "Tiempo" WHERE fecha=row_tiempo.fecha) IS NULL THEN
			id_tiempo = (SELECT MAX("Id_Tiempo")FROM "Tiempo")+1;
			INSERT INTO "Tiempo" VALUES(id_tiempo,row_tiempo.fecha,row_tiempo.dia,row_tiempo.mes,row_tiempo.trimestre,row_tiempo.año);
		END IF; 
	END LOOP;
	--NO borramos tmp2_Tiempo para tener referencia de las fechas ya creadas a partir de facturacion 1.
END
$$
LANGUAGE plpgsql;

---------------------------------
CREATE OR REPLACE FUNCTION "llenar_Tiempo1"() RETURNS void AS
$$
DECLARE

cursor_tiempo CURSOR FOR SELECT * FROM "tmp1_Tiempo";
row_tiempo RECORD;

dia_tiempo integer;
mes_tiempo integer;
trimestre_tiempo integer;
año_tiempo integer;

BEGIN
	CREATE TABLE "tmp2_Tiempo"(
		fecha date,
		dia integer,
		mes integer,
		trimestre integer,
		año integer
	);	
	FOR row_tiempo IN cursor_tiempo LOOP
		dia_tiempo = (SELECT EXTRACT (DAY FROM row_tiempo.fecha));
		mes_tiempo = (SELECT EXTRACT (MONTH FROM row_tiempo.fecha));
		año_tiempo = (SELECT EXTRACT (YEAR FROM row_tiempo.fecha));
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
		INSERT INTO "tmp2_Tiempo" VALUES(row_tiempo.fecha,dia_tiempo,mes_tiempo,
						 trimestre_tiempo,año_tiempo);
	END LOOP;
	DROP TABLE "tmp1_Tiempo";
	PERFORM(SELECT "llenar_Tiempo2"());

END
$$
LANGUAGE plpgsql; 
--------------------
CREATE OR REPLACE FUNCTION"crear_Tiempo"() RETURNS TEXT AS
$$
DECLARE
BEGIN
	
	CREATE TABLE "tmp1_Tiempo"(
		fecha date
	);
	INSERT INTO "tmp1_Tiempo" (
				 (SELECT DISTINCT "Fecha_Vta1" FROM dblink('conexionFacturacion1',
				'SELECT "Fecha_Vta" FROM "Venta"')AS tiempof1("Fecha_Vta1" date)) 
			      );
	PERFORM("llenar_Tiempo1"());
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;

SELECT "crear_Tiempo"();

--Asigno a la tabla local "Medios" los valores de la tabla remota "Medio_Pago"
INSERT INTO "Medios" (SELECT codf2, descf2 
			FROM dblink('conexionFacturacion2a','SELECT "tipo_operacion",descripcion FROM "Medio_Pago"') 
			AS (codf2 t_forma_pago, descf2 varchar(100)));
---------------------------------------

CREATE OR REPLACE FUNCTION "crear_Region"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
id_region integer;
descripcion_region varchar(100);
BEGIN
	i = 1;
	FOR i IN i..cantidad LOOP
		id_region = (SELECT MAX("Id_Region")FROM "Region")+1;
		descripcion_region = ('REGION NUMERO ' || id_region);
		INSERT INTO "Region" VALUES(id_region,descripcion_region);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto una primer tupla en la tabla Region.
INSERT INTO "Region" VALUES (1,'REGION NUMERO 1');
--Utilizo la funcion que inicializa tuplas en la tabla "Region".
SELECT "crear_Region"(9);
--Función que crea tuplas en la tabla "Provincia".
CREATE OR REPLACE FUNCTION "crear_Provincia"(cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
id_provincia integer;
descripcion_provincia varchar(100);
id_region_provincia integer;
BEGIN
	i = 1;
	FOR i IN i..cantidad LOOP
		id_provincia = (SELECT MAX("Id_Provincia")FROM "Provincia")+1;
		descripcion_provincia = ('PROVINCIA NUMERO '|| id_provincia);
		id_region_provincia = (SELECT "Id_Region" FROM "Region" ORDER BY RANDOM() LIMIT 1);
		INSERT INTO "Provincia" VALUES(id_provincia, descripcion_provincia, id_region_provincia);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto una primer tupla en la tabla "Region".
INSERT INTO "Provincia" VALUES(1,'PROVINCIA NUMERO 1',1);
--Utilizo la función para crear tuplas en la tabla "Provincia".
SELECT "crear_Provincia"(9);
--Funcion que crea tuplas en la tabla "Ciudad".
CREATE OR REPLACE FUNCTION "crear_Ciudad" (cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
id_ciudad integer;
descripcion_ciudad varchar(100);
id_provincia_ciudad integer;
BEGIN
	i=1;
	FOR i IN i..cantidad LOOP
		id_ciudad = (SELECT MAX("Id_Ciudad")FROM "Ciudad")+1;
		descripcion_ciudad = ('CIUDAD NUMERO '|| id_ciudad);
		id_provincia_ciudad = (SELECT "Id_Provincia" FROM "Provincia" ORDER BY RANDOM() LIMIT 1);
		INSERT INTO "Ciudad" VALUES(id_ciudad, descripcion_ciudad, id_provincia_ciudad);
	END LOOP;

	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto una primer tupla en la tabla "Ciudad"
INSERT INTO "Ciudad" VALUES (1,'CIUDAD NUMERO 1',1);
--Utilizo la función para crear tuplas de ciudad
SELECT "crear_Ciudad"(9);
--Funcion que crea tuplas en la tabla "Distrbucion_Geografica".
CREATE OR REPLACE FUNCTION "crear_DG" (cantidad integer) RETURNS TEXT AS
$$
DECLARE
i integer;
id_sucursal_DG integer;
descripcion_DG varchar(100);
id_ciudad_DG integer;
BEGIN
	i = 1;
	FOR i IN i..cantidad LOOP
		id_sucursal_DG = (SELECT MAX("Id_Sucursal") FROM "Distribucion_Geografica")+1;
		descripcion_DG = ('DISTRIBUCION GEOGRAFICA NUMERO ' || id_sucursal_DG);
		id_ciudad_DG = (SELECT "Id_Ciudad" FROM "Ciudad" ORDER BY RANDOM() LIMIT 1);
		INSERT INTO "Distribucion_Geografica" VALUES (id_sucursal_DG, descripcion_DG, id_ciudad_DG);
	END LOOP;
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Inserto una primer tupla en la tabla "Distribucion_Geografica".
INSERT INTO "Distribucion_Geografica" VALUES (1,'DISTRIBUCION GEOGRAFICA NUMERO 1',1);
--Utilizo la funcion para agregar tuplas a la tabla "Distribucion_Geografica".
SELECT "crear_DG"(9);


--Cierro las conexiones.
SELECT dblink_disconnect('conexionFacturacion1')
SELECT dblink_disconnect('conexionFacturacion2a')
