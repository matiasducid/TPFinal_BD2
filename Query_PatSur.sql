CREATE EXTENSION dblink
--Conexion a la base de Facturacion1.
SELECT dblink_connect('conexionFacturacion1','dbname = Facturacion1 user=postgres password = postgres');
--Conexion a la base
SELECT dblink_connect('conexionFacturacion2','dbname = Facturacion2 user=postgres password = postgres');


--Creo la tabla producto.
CREATE TABLE "Productos" (
	"Id_Producto" integer,
	"Nombre" varchar(50),
	"Id_Categoria" integer,
	"Id_Subcategoria" integer
);
ALTER TABLE "Productos" ADD CONSTRAINT "pk_Producto" PRIMARY KEY ("Id_Producto");


--Inicializo Productos
SELECT dblink_connect('conexionFacturacion1','dbname = Facturacion1 user=postgres password = postgres')
SELECT id_prod1, nombre_prod1 ,id_cat_prod1 ,id_subcat_prod1 FROM dblink('conexionFacturacion1','SELECT "nro_Producto","Nombre",nro_categ,null FROM "Producto"') AS facturacion1 (id_prod1 integer,nombre_prod1 varchar(50), id_cat_prod1 integer, id_subcat_prod1 integer)
SELECT dblink_disconnect('conexionFacturacion1')

SELECT dblink_connect('conexionFacturacion2a','dbname = Facturacion2 user=postgres password = postgres')--Parece que no le gusta que la conexion se llame tan parecido a la otra, agrege una "a" al final.
SELECT id_prod2, nombre_prod2, id_cat_prod2,id_subcat_prod2 FROM dblink('conexionFacturacion2a','SELECT "cod_Producto","Nombre",cod_categoria,cod_subcategoria FROM "Producto"') AS facturacion2 (id_prod2 integer,nombre_prod2 varchar(50), id_cat_prod2 integer, id_subcat_prod2 integer)
SELECT dblink_disconnect('conexionFacturacion2a')



SELECT dblink_connect('conexionFacturacion1','dbname = Facturacion1 user=postgres password = postgres')
INSERT INTO "Aux_Productos" SELECT id_prod1, nombre_prod1 ,id_cat_prod1 ,id_subcat_prod1 FROM dblink('conexionFacturacion1','SELECT "nro_Producto","Nombre",nro_categ,null FROM "Producto"') AS facturacion1 (id_prod1 integer,nombre_prod1 varchar(50), id_cat_prod1 integer, id_subcat_prod1 integer)
SELECT dblink_disconnect('conexionFacturacion1')


SELECT dblink_connect('conexionFacturacion2a','dbname = Facturacion2 user=postgres password = postgres')--Parece que no le gusta que la conexion se llame tan parecido a la otra, agrege una "a" al final.
INSERT INTO "Aux_Productos" SELECT id_prod2, nombre_prod2, id_cat_prod2,id_subcat_prod2 FROM dblink('conexionFacturacion2a','SELECT "cod_Producto","Nombre",cod_categoria,cod_subcategoria FROM "Producto"') AS facturacion2 (id_prod2 integer,nombre_prod2 varchar(50), id_cat_prod2 integer, id_subcat_prod2 integer)
SELECT dblink_disconnect('conexionFacturacion2a')



SELECT dblink_connect('conexionFacturacion1','dbname = Facturacion1 user=postgres password = postgres')

--Inserto a la tabla Productos los elementos de producto pertenecientes a las 2 tablas remotas de productos.
INSERT INTO "Productos" (
SELECT f1.id_prod1,f1.nombre_prod1,f1.id_cat_prod1,f2.id_prod2 FROM (SELECT id_prod2, nombre_prod2, id_cat_prod2,id_subcat_prod2 
									  FROM dblink('conexionFacturacion2a','SELECT "cod_Producto",
									  "Nombre",cod_categoria,cod_subcategoria FROM "Producto"')
									  AS facturacion2 (id_prod2 integer,nombre_prod2 varchar(50),
									  id_cat_prod2 integer, id_subcat_prod2 integer)) f2
FULL OUTER JOIN (
	SELECT id_prod1, nombre_prod1 ,id_cat_prod1 ,id_subcat_prod1 
	FROM dblink('conexionFacturacion1','SELECT "nro_Producto","Nombre",
		     nro_categ,null FROM "Producto"') AS facturacion1 
	(id_prod1 integer,nombre_prod1 varchar(50), id_cat_prod1 integer,
	 id_subcat_prod1 integer)
		) f1 ON f1.id_prod1 = f2.id_prod2 ) ;

--Hacer bien el join.

SELECT dblink_disconnect('conexionFacturacion1')


SELECT * FROM "Aux_Productos"

--SELECT idc FROM dblink('conexion1','SELECT "idCurso" FROM cursos WHERE "idCurso" = 1') AS tabla(idc integer)
