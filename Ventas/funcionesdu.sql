--a) el total de ventas de un vendedor.
CREATE FUNCTION total_ventas_vendedor(p_cod_vendedor char(3)) RETURNS numeric AS $$
DECLARE v_total numeric;
BEGIN
	SELECT SUM(total) INTO v_total FROM ventas WHERE cod_vendedor = p_cod_vendedor;
	RETURN v_total;
END;
$$ LANGUAGE 'plpgsql';

--b) el total de ventas de una tarjeta determinada

CREATE FUNCTION total_ventas_tarjeta(p_cod_tarjeta integer) RETURNS numeric AS $$
DECLARE v_total numeric;
BEGIN
	SELECT SUM(tarjeta) INTO v_total FROM venta WHERE tarjeta = p_cod_tarjeta;
	RETURN v_total;
END;
$$ LANGUAGE 'plpgsql';

--c) la cantidad vendida de un determinado producto

CREATE FUNCTION total_vendido_producto(p_cod_producto char(5)) RETURNS numeric AS $$
DECLARE v_total numeric;
BEGIN 
	SELECT SUM(cantidad) INTO v_total FROM venta WHERE producto = p_cod_producto;
	RETURN v_total;
END;
$$ LANGUAGE 'plpgsql';

--d) la última fecha de venta a un cliente determinado

CREATE FUNCTION fecha_ultima_venta(p_cod_cliente numeric) RETURNS date AS $$
DECLARE v_fecha date;
BEGIN
	SELECT MAX(fecha) INTO v_fecha FROM venta WHERE cliente = p_cod_cliente;
	RETURN v_fecha;
END;
$$ LANGUAGE 'plpgsql';


--e) el nombre del producto más vendido
CREATE FUNCTION nombre_prod_mas_vendido() RETURNS text AS $$
DECLARE v_nombre_producto text;
BEGIN
	SELECT MAX(total_vendido_producto(p.codigo) ), p.nombre INTO v_nombre_producto
	FROM venta v
		INNER JOIN producto p
		ON v.producto = p.codigo;
	GROUP BY 
	RETURN v_nombre_producto;
END;
$$ LANGUAGE 'plpgsql';

--2) Cree una función que retorne el conjunto (SETOF) de ventas realizados con la tarjeta de crédito 
--que sea pasada como parámetro. Use la función en una consulta para poder mostrar el ranking de los 
--vendedores que más facturaron con VISA.
--SELECT * FROM venta_con_tarjetas(1);
CREATE FUNCTION ventas_con_tarjetas( p_cod_tarjeta int ) RETURNS SETOF venta AS $$
BEGIN
	RETURN QUERY SELECT * FROM venta WHERE p_cod_tarjeta = tarjeta; 
END;
$$ LANGUAGE 'plpgsql';

--SELECT * FROM venta_con_tarjetas(1);
CREATE FUNCTION ventas_con_tarjetas( p_cod_tarjeta int ) RETURNS SETOF venta AS $$
DECLARE r venta%rowtype;
BEGIN
	FOR r IN SELECT * FROM venta
	LOOP
		if r.tarjeta = p.tarjeta then
			RETURN NEXT r;
		end if;
		
	END LOOP;
	RETURN;
END;
$$ LANGUAGE 'plpgsql';

--3) Cree una funcion que retorne un conjunto de clientes (SETOF) 
--con los datos de todos los clientes que hayan comprado más de cinco productos 
--o cuyas compras hayan superado los tres mil pesos. Use la función para armar una 
--consulta que muestre el número de documento y el nombre de cada uno de ellos.
CREATE OR REPLACE FUNCTION clientes_ventas() RETURNS SETOF cliente AS $$
BEGIN
	RETURN QUERY 
			SELECT c.*
			FROM cliente c, 
				(
					SELECT c.numero_documento, COUNT(v.cliente)AS cant_compras, SUM(v.total) AS total_compras
					FROM cliente c, venta v
					WHERE c.numero_documento = v.cliente
					GROUP BY c.numero_documento
				) as cv
			WHERE c.numero_documento = cv.numero_documento AND 
				(cv.cant_compras > 5 OR cv.total_compras > 3000);

END;
$$ LANGUAGE 'plpgsql';

SELECT * FROM clientes_ventas();

--4) Cree una función que devuelva el número de documento y nombre de los clientes 
--	 que compraron en determinada fecha con cierto vendedor.
CREATE OR REPLACE FUNCTION cliente_compra_fecha( p_vendedor char(3), p_fecha Date) 
	RETURNS TABLE (numero_documento int, nombre char) AS $$
BEGIN
	RETURN QUERY 
		SELECT c.numero_documento, c.nombre 
		FROM cliente c, venta v, vendedor ve
		WHERE c.numero_documento = v.cliente AND ( v.fecha = p_fecha AND ve.codigo = p_vendedor);
END;
$$ LANGUAGE 'plpgsql0';

--5) Cree una función llamada guardar_vendedor que reciba todos los datos de un vendedor 
--y los inserte en la base de datos si el vendedor no existe en la base de datos, 
--o actualice los datos si el vendedor ya existe. (Ayuda, investige la variable FOUND de PL/pgSQL).
CREATE FUNCTION guardar_vendedor( p_codigo char(3), p_legajo int, p_nombre char, p_comision numeric(4,3) ) RETURNS void as 
$$
	BEGIN
	    PERFORM * FROM vendedor WHERE codigo = p_codigo;
	    IF FOUND THEN
	        UPDATE vendedor SET p_legajo = p_legajo, nombre = p_nombre, comision = p_comision WHERE legajo = p_legajo;
	    ELSE
	        INSERT INTO vendedor VALUES ( p_codigo, p_legajo, p_nombre, p_comision );
	    END IF;
	END;
$$ LANGUAGE 'plpgsql';

--6) Cree una función que reciba el número de documento de un cliente y retorne el importe total de sus compras. 
--Use un ciclo de iteración sobre una consulta para implementar la solución. 
--Luego realice una consulta que muestre el nombre y el total de compras de cada cliente en la base de datos.
CREATE OR REPLACE FUNCTION total_compras_cliente(p_numero_documento int) RETURNS numeric(11,2) as
$$
	DECLARE
    i venta%rowtype;
    total numeric(11,2) = 0;
	BEGIN
		FOR i IN SELECT * FROM venta 
		LOOP
			if i.cliente = p_numero_documento then
				total = total + i.total;
			end if;
		END LOOP;
		RETURN total;
	END;
$$ LANGUAGE 'plpgsql';

SELECT total_compras_cliente(3860819); -- 23 ms

SELECT nombre, total_compras_cliente(numero_documento) FROM cliente;

--7) Implemente la solución anterior con una única consulta sql. Compare los tiempos de ejecución y saque sus conclusiones.

SELECT SUM(total) FROM venta WHERE cliente = 3860819; -- 12 ms 

SELECT SUM(total) FROM venta;
