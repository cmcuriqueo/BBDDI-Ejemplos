--1) Para cada vendedor determine si realizó ventas de calzoncillos.
SELECT DISTINCT v.nombre, vv.cant_ventas > 0 AS cant_ventas_c
FROM vendedor v
	FULL JOIN 
	(
	SELECT v.nombre, COUNT(p.codigo) cant_ventas
	FROM vendedor v
		LEFT JOIN venta vent
		ON v.codigo = vent.vendedor
		LEFT JOIN producto p
		ON p.codigo = vent.producto 
	WHERE ( p.nombre ILIKE 'calzoncillo%' OR p.codigo IS NUll)
	GROUP BY v.nombre
	) as vv
	ON vv.nombre = v.nombre
;
--Otra forma
SELECT DISTINCT v.nombre, (
	SELECT COUNT(*) c_ventas
	FROM venta vent
		
		LEFT JOIN producto p
		ON p.codigo = vent.producto
	WHERE p.nombre ILIKE 'calzoncillo%' AND v.codigo = vent.vendedor
	)
FROM vendedor v
;

--2) Muestre los clientes que no compraron bulones ni calzoncillos
SELECT c.nombre
FROM cliente c
WHERE c.nombre NOT IN (
	SELECT c.nombre
	FROM cliente c
		INNER JOIN venta v
		ON v.cliente = c.numero_documento
		INNER JOIN producto p
		ON p.codigo = v.producto
	WHERE p.nombre ILIKE 'bulon%' OR p.nombre ILIKE 'calzoncillo%'
);

--3) Muestre los vendedores que hayan realizado ventas por más de cien pesos durante el mes de marzo de 2011.BETWEEN
SELECT v.nombre
FROM vendedor v
WHERE v.nombre IN (
	SELECT DISTINCT vend.nombre
	FROM venta v 
		INNER JOIN vendedor vend
		ON vend.codigo = v.vendedor
	WHERE (v.fecha NOT BETWEEN '2011-03-01' AND '2011-03-31' AND v.total <= 100)
);

--4) Muestre los productos que hayan sido comprados por alguna mujer mayor de cien años y por hombres de gaiman que tengan más de 50 años.
SELECT DISTINCT p.nombre
FROM producto p
	INNER JOIN venta v
	ON p.codigo = v.producto
WHERE v.cliente IN (
	SELECT c.numero_documento
	FROM cliente c, localidad lc
	WHERE (lc.codigo = c.localidad) AND (lc.nombre ILIKE 'gaiman') AND (c.fecha_nacimiento > '1966-01-01') AND (c.sexo = 'M')
	) OR v.cliente IN (
	SELECT c.numero_documento
	FROM cliente c
	WHERE (c.sexo='F') AND (2016 - EXTRACT(YEAR from c.fecha_nacimiento) > 100)
	);
	
--5) Obtenga el producto más comprado por el mejor cliente y muestre el ranking de los diez clientes que más unidades compraron de ese producto.
 --Nota: el mejor cliente es el que más dinero gasta.
SELECT c.apellido || ', ' || c.nombre as nombre_cliente
FROM cliente c
	INNER JOIN venta v
	ON v.cliente = c.numero_documento
WHERE 	
	(SELECT p.codigo
	FROM producto p,
		(SELECT c.nombre, v.producto
		FROM cliente c
			INNER JOIN venta v
			ON v.cliente=c.numero_documento
		GROUP BY 1, 2
		ORDER BY SUM(v.total) DESC
			LIMIT 1
		) as v
	WHERE v.producto = p.codigo
	) = v.producto
GROUP BY 1
ORDER BY COUNT(1) DESC
	LIMIT 10;