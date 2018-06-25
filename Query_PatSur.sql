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

CREATE DOMAIN t_cod_tipo AS integer
    DEFAULT 1 
    CHECK (VALUE IN (1,2,3,4));--son cuatro tipos en facturacion1
--Creo la tabla Clientes
CREATE TABLE "Clientes" (
	"Id_Cliente" integer,
	"Nombre" varchar(50),
	"Apellido" varchar(50),--¿No puede ir en nombre como en las otras de cliente?¿Necesario?
	"Id_tipo" t_cod_tipo
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

SELECT count(clientes.*) FROM (
SELECT  c1.id_cliente1,c2.id_cliente2,c1.nombre1,c2.nombre2,c1.apellido1,c1.id_tipo1,c2.id_tipo2
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
		  ON c1.id_cliente1 = (SELECT cast(id_cliente2 as integer)) )AS clientes;		
--esto ultimo sin terminar

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
				     tipo2 t_cod_tipo,
				     nueva_clave integer);
	INSERT INTO "tmp_Clientes" (SELECT  c1.id_cliente1,c2.id_cliente2,c1.nombre1,c2.nombre2,c1.apellido1,c2.apellido2,c1.id_tipo1,c2.id_tipo2, count(*)
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
				   ON c1.id_cliente1 = (SELECT cast(id_cliente2 as integer)) GROUP BY (c1.id_cliente1,c2.id_cliente2,c1.nombre1,c2.nombre2,c1.apellido1,c2.apellido2,c1.id_tipo1,c2.id_tipo2)ORDER BY (id_cliente1,id_cliente2));
--SIN TERMINAR ...





	--IF ()
	
	DROP TABLE "tmp_Clientes";
	RETURN 'OK';
END
$$
LANGUAGE plpgsql;


SELECT ("cargar_Clientes"());


--Cierro las conexiones.
SELECT dblink_disconnect('conexionFacturacion1')
SELECT dblink_disconnect('conexionFacturacion2a')
