CREATE EXTENSION dblink
--Conexion a la base de Facturacion1.
SELECT dblink_connect('conexionFacturacion1','dbname = Facturacion1 user=postgres password = postgres');
--Conexion a la base de Facturacion2.
SELECT dblink_connect('conexionFacturacion2a','dbname = Facturacion2 user=postgres password = postgres');--tuve que poner "a" al final porque no le gustaba sino.


--Creo la tabla producto Localmente.
CREATE TABLE "Productos" (
	"Id_Producto" integer,
	"Nombre" varchar(50),
	"Id_Categoria" integer,
	"Id_Subcategoria" integer
);
ALTER TABLE "Productos" ADD CONSTRAINT "pk_Producto" PRIMARY KEY ("Id_Producto");
--ALTER TABLE "Productos" ADD CONSTRAINT "fk_Categoria" FOREIGN KEY ("Id_Categoria") REFERENCES "Categoria" ("Id_Categoria");
--Creo la tabla Categoria
CREATE TABLE "Categoria" (
	"Id_Categoria" integer,
	descripcion varchar(100),
	"Id_Subcategoria" integer
);
ALTER TABLE "Categoria" ADD CONSTRAINT "pk_Categoria" PRIMARY KEY ("Id_Categoria");



--Inserto a la tabla Productos Local los elementos de producto pertenecientes a las 2 tablas 
--remotas de productos(Productos ->Facturacion1 // Productos ->Facturacion2).
INSERT INTO "Productos" (
SELECT f1.id_prod1,f1.nombre_prod1,f1.id_cat_prod1,f2.id_prod2  
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
--Inserto tuplas en la tabla Local Categoria a partir de las tablas remotas categoria de facturacion1 y de facturacion2.
INSERT INTO "Categoria" (
SELECT f1.nro_categ1, f1.descripcion1, id_subcategoria2 
FROM (SELECT nro_categ1,descripcion1 
	FROM dblink('conexionFacturacion1',
		    'SELECT nro_categ, descripcion FROM "Categoria"') AS facturacion1
		    (nro_categ1 integer,descripcion1 varchar(100)) ) f1
FULL OUTER JOIN (
	SELECT nro_categ2,descripcion2,id_subcategoria2
	FROM dblink('conexionFacturacion2a','SELECT cod_categoria, descripcion,
		     cod_subcategoria FROM "Categoria"') AS facturacion2
	(nro_categ2 integer, descripcion2 varchar(100), id_subcategoria2 integer)
		) f2 ON f1.nro_categ1 = f2.nro_categ2 );







--Cierro las conexiones.
SELECT dblink_disconnect('conexionFacturacion1')
SELECT dblink_disconnect('conexionFacturacion2a')
