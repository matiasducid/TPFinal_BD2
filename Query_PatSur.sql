CREATE EXTENSION dblink
--Conexion a la base de Facturacion1.
SELECT dblink_connect('conexionFacturacion1','dbname = Facturacion1 user=postgres password = postgres');
--Conexion a la base de Facturacion2.
SELECT dblink_connect('conexionFacturacion2a','dbname = Facturacion2 user=postgres password = postgres');--tuve que poner "a" al final porque no le gustaba sino.

--Creo la tabla Producto.
CREATE TABLE "Productos" (
	"Id_Producto" integer,
	"Nombre" varchar(50),
	"Id_Categoria" integer,
	"Id_Subcategoria" integer
);
ALTER TABLE "Productos" ADD CONSTRAINT "pk_Producto" PRIMARY KEY ("Id_Producto");
--Creo la tabla Categoria
CREATE TABLE "Categoria" (
	"Id_Categoria" integer,
	descripcion varchar(100),
	"Id_Subcategoria" integer
);
--Agrego clave primaria.
ALTER TABLE "Categoria" ADD CONSTRAINT "pk_Categoria" PRIMARY KEY ("Id_Categoria");

﻿CREATE DOMAIN t_tipo AS varchar(10)
	DEFAULT 'TIPO 1'
	CHECK (VALUE IN ('TIPO 1','TIPO 2','TIPO 3','TIPO 4') );
--Creo la tabla Clientes
CREATE TABLE "Clientes" (
	"Id_Cliente" integer,
	"Nombre" varchar(50),
	"Apellido" varchar(50),--¿No puede ir en nombre como en las otras de cliente?¿Necesario?
	"Id_tipo" integer
)
ALTER TABLE "Clientes" ALTER "Id_tipo" TYPE integer;
ALTER TABLE "Clientes" ADD CONSTRAINT "pk_Cliente" PRIMARY KEY ("Id_Cliente");
ALTER TABLE "Clientes" ADD CONSTRAINT "fk_Tipo_Cliente" FOREIGN KEY ("Id_tipo") REFERENCES "Tipo_Cliente" ("Id_Tipo");
--Creo la tabla Tipo_Cliente.
CREATE TABLE "Tipo_Cliente" (
"Id_Tipo" integer NOT NULL,
descripcion varchar(100),
CONSTRAINT "pk_Tipo_Cliente" PRIMARY KEY ("Id_Tipo")
);
--Creo la tabla Tiempo.
CREATE TABLE "Tiempo" (
	"Id_Tiempo" integer,
	dia integer CHECK (dia between 1 AND 31),
	mes integer CHECK (mes between 1 AND 12),
	trimestre integer CHECK (trimestre between 1 AND 4),
	año integer CHECK (año between 2000 and date_part('year',now())),
	CONSTRAINT "pk_Tiempo" PRIMARY KEY ("Id_Tiempo"))

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
	"Fecha" integer,
	"Id_Factura" integer,
	"Id_Cliente" integer,
	"Id_Producto" integer,
	"Id_Sucursal" integer,
	"Monto_vendido" float,
	"Cantidad_Vendida" integer,
	CONSTRAINT "pk_Venta" PRIMARY KEY ("Id_Factura"),
	CONSTRAINT "fk_Tiempo" FOREIGN KEY ("Fecha") REFERENCES "Tiempo" ("Id_Tiempo"),
	CONSTRAINT "fk_Cliente" FOREIGN KEY ("Id_Cliente") REFERENCES "Clientes" ("Id_Cliente"),
	CONSTRAINT "fk_Producto" FOREIGN KEY ("Id_Producto") REFERENCES "Productos" ("Id_Producto"),
	CONSTRAINT "fk_DG" FOREIGN KEY ("Id_Sucursal") REFERENCES "Distribucion_Geografica" ("Id_Sucursal")
	)


 
--Inserto a la tabla Productos Local los elementos de producto pertenecientes a las 2 tablas 
--remotas de productos(Productos ->Facturacion1 // Productos ->Facturacion2).

INSERT INTO "Productos" (
SELECT f1.id_prod1,f1.nombre_prod1,f1.id_cat_prod1,f2.id_subcat_prod2  
FROM (SELECT id_prod2, nombre_prod2, id_cat_prod2,id_subcat_prod2 
      FROM dblink('conexionFacturacion2a','SELECT "cod_Producto",
		  "Nombre",cod_categoria,cod_subcategoria FROM "Producto"')
		  AS facturacion2 (id_prod2 integer,nombre_prod2 varchar(50),
				  id_cat_prod2 integer, id_subcat_prod2 integer)) f2
FULL OUTER JOIN (
	SELECT id_prod1, nombre_prod1 ,id_cat_prod1 ,id_subcat_prod1 
	FROM dblink('conexionFacturacion1','SELECT "nro_Producto","Nombre",
		     nro_categ,null FROM "Producto"') AS facturacion1 
			(id_prod1 integer,nombre_prod1 varchar(50), 
			id_cat_prod1 integer,id_subcat_prod1 integer)
		) f1 ON f1.id_prod1 = f2.id_prod2 ) ;
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

--Creo la clave foranea de PRODUCTOS hacia CATEGORIA
ALTER TABLE "Productos" ADD CONSTRAINT "fk_Categoria" FOREIGN KEY ("Id_Categoria") REFERENCES "Categoria" ("Id_Categoria");

--Inserto tuplas en la tabla Local Cliente a partir de las tablas remotas 
--categoria de facturacion1 y de facturacion2.
--HERRAMIENTA DE CARGA DEL DATAWAREHOUSE.
CREATE OR REPLACE FUNCTION "llenar_Clientes"() RETURNS void AS
$$
DECLARE
var_tipo integer;
cursor_clientes CURSOR FOR SELECT * FROM "tmp_Clientes";
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
CREATE OR REPLACE FUNCTION "cargar_Clientes"() RETURNS TEXT AS
$$
DECLARE
BEGIN
	CREATE TABLE "tmp_Clientes" (idc1 integer,
				     idc2 varchar(8),
				     nombre1 varchar(50),
				     nombre2 varchar(50),
				     apellido1 varchar(50),
				     apellido2 varchar(50),
				     tipo1 t_tipo,
				     tipo2 integer,
				     nueva_clave serial);

	INSERT INTO "tmp_Clientes" (SELECT  c1.id_cliente1,c2.id_cliente2,c1.nombre1,c2.nombre2,
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
				   ON c1.id_cliente1 = (SELECT cast(id_cliente2 as integer)) 
				   GROUP BY (c1.id_cliente1,c2.id_cliente2,
				   c1.nombre1,c2.nombre2,c1.apellido1,
				   c2.apellido2,c1.id_tipo1,c2.id_tipo2)
				   ORDER BY (id_cliente1,id_cliente2));

	PERFORM (SELECT "llenar_Clientes"());
	DROP TABLE "tmp_Clientes";
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;
--Utilizo Funcion para inicializar la tabla local Clientes.
SELECT "cargar_Clientes"();
--Asigno a la tabla local "Tipo_Cliente" los valores de la tabla remota "Tipo_Cliente" de Facturacion1
INSERT INTO "Tipo_Cliente" (
			    SELECT ct,descr 
			    FROM dblink('conexionFacturacion2a','SELECT * FROM "Tipo_Cliente"') 
			    AS tipo_clientef2(ct integer, descr varchar(100)));
--Asigno a la tabla local "Tiempo" los datos de la tabla remota "Tiempo" de la BD Facturacion2.
INSERT INTO "Tiempo" (SELECT idTf2,diaf2,mesf2,trimestref2,añof2 
		      FROM dblink('conexionFacturacion2a',
				  'SELECT "Id_fecha",dia,mes,trimestre,año FROM "Tiempo"') 
			AS (idTf2 integer, diaf2 integer, mesf2 integer, trimestref2 integer, añof2 integer));
--Asigno a la tabla local "Medios" los valores de la tabla remota "Medio_Pago"
INSERT INTO "Medios" (SELECT codf2, descf2 FROM dblink('conexionFacturacion2a',
				 'SELECT "cod_Medio_Pago",descripcion FROM "Medio_Pago"') 
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
