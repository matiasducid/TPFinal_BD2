﻿--Punto 4.

--a)
--Por cada venta, mostrar segun las dimensiones solicitadas.
SELECT v."Fecha",v."Id_Factura",v."Id_Producto",
       t.mes,t.año,dg."Id_Sucursal",dg.descripcion,
       c."Id_Cliente",c."Nombre", r."Id_Region",
       r.descripcion,SUM (v."Monto_vendido") AS "Ventas",
       SUM(v."Cantidad_Vendida") AS "Cantidad Vendida"
FROM "Ventas" v,"Tiempo" t, "Distribucion_Geografica" dg, "Clientes" c, "Ciudad" ciu, "Provincia" p, "Region" r
WHERE v."Id_Tiempo" = t."Id_Tiempo" AND v."Id_Sucursal" = dg."Id_Sucursal" AND v."Id_Cliente" = c."Id_Cliente"
      AND dg."Id_Ciudad"=ciu."Id_Ciudad" AND ciu."Id_Provincia"=p."Id_Provincia" AND p."Id_Region"=r."Id_Region"
GROUP BY CUBE (	(v."Fecha",v."Id_Factura",v."Id_Producto"),
		(t.mes),(t.año),(dg."Id_Sucursal",dg.descripcion),
		(r."Id_Region",r.descripcion),(c."Id_Cliente",c."Nombre")
	       );

--b)
--Por producto vendido, monto obtenido y cantidad de unidades vendida.
SELECT "Id_Producto", SUM("Cantidad_Vendida") AS Ventas, SUM("Monto_vendido")
FROM "Ventas"
GROUP BY ("Id_Producto")

--c)
--Ventas listadas por el orden de las que mas productos vendio a la que menos vendió con su distrtibucion geográfica.
SELECT v."Fecha",v."Id_Tiempo",v."Id_Cliente",v."Id_Producto",v."Monto_vendido",dg."Id_Sucursal",
       dg.descripcion,v."Cantidad_Vendida",row_number() OVER (ORDER BY v."Cantidad_Vendida") as "Posicion"
FROM "Ventas" v, "Distribucion_Geografica" dg
WHERE v."Id_Sucursal"=dg."Id_Sucursal"

--d)
-- Rankin de los clientes que menos gastos generan a los que mas generan.
SELECT c."Id_Cliente",c."Nombre",c."Apellido",c."Id_tipo",
       SUM(v."Monto_vendido") AS "Gasto", RANK() OVER (ORDER BY SUM(v."Monto_vendido"))
FROM "Ventas" v, "Clientes" c
WHERE v."Id_Cliente"=c."Id_Cliente"
GROUP BY (c."Id_Cliente",c."Nombre",c."Apellido")



--e)
--Analisis de las unidades vendidas y los montos totales segun año-trimeste-mes-dia.
SELECT t.dia,t.mes,t.trimestre,t.año,
       SUM(v."Monto_vendido") AS "Ganancia",SUM(v."Cantidad_Vendida") AS "Unidades Vendidas"
FROM "Ventas" v, "Tiempo" t
WHERE v."Id_Tiempo"=t."Id_Tiempo"
GROUP BY ROLLUP (t.año,t.trimestre,t.mes,t.dia);


--e) Armada para enviar a BIRT.
SELECT t.dia,t.mes,t.trimestre,t.año,
       SUM(v."Monto_vendido") AS "Ganancia",SUM(v."Cantidad_Vendida") AS "Unidades Vendidas"
FROM "Ventas" v, "Tiempo" t
WHERE v."Id_Tiempo"=t."Id_Tiempo"
GROUP BY GROUPING SETS ((t.año,t.trimestre,t.mes,t.dia),
			(t.año,t.trimestre,t.mes),
			(t.año,t.trimestre),
			(t.año));





