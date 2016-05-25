﻿--Realice un Trigger que guarde en una tabla ventas_superiores, las ventas cuyo total  
--supere los $ 300. La tabla deberá almacenar el id de la venta, el código del   
--vendedor, el código del producto y el total. Verificar realizando inserciones en la tabla venta. 

CREATE TABLE ventas_superiores (
	id integer NOT NULL,
	vendedor character(3) NOT NULL,
	producto character(5) NOT NULL,
	total numeric(11,2)
);

CREATE OR REPLACE FUNCTION ventas_superiores() RETURNS TRIGGER AS $$
DECLARE
BEGIN
	IF (NEW.total > 300) THEN
		INSERT INTO ventas_superiores VALUES (NEW.id, NEW.vendedor, NEW.producto, NEW.total );
		RETURN NEW;
	END IF;
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ventas_superiores
AFTER INSERT ON venta
FOR EACH ROW EXECUTE PROCEDURE ventas_superiores();

INSERT INTO venta VALUES (5302, '2016-05-25', 3860819, 1, 'HE001', 3000.34, 'JUA', NULL);

--Realizar un trigger que ante la inserción, modificación o borrado de un cliente de la base de  
--datos, almacene dichas operaciones en una tabla complementaria guardando la fecha de  
--modificación, tipo de operación y usuario que la efectuó. 

CREATE TABLE cliente_log (
	fecha_modificacion DATE,
	operacion CHAR(6),
	usuario TEXT
);

CREATE OR REPLACE FUNCTION cliente_log() RETURNS TRIGGER AS $$
DECLARE
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO cliente_log SELECT now(), 'INSERT', user;
		RETURN NULL;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO cliente_log SELECT now(), 'UPDATE', user;
		RETURN NULL;
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO cliente_log SELECT now(), 'DELETE', user;
		RETURN NULL;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cliente_log
AFTER INSERT OR UPDATE OR DELETE ON cliente
FOR EACH ROW EXECUTE PROCEDURE cliente_log();

INSERT INTO cliente VALUES (39443529, 'Curiqueo', 'Cesar Matias', '1996-06-22', 'M', 'Pairo 100', 65);

SELECT * FROM cliente_log;

SELECT * FROM cliente WHERE numero_documento = 39443529;

--Cree un trigger registrar_actualizacion para que ante las operaciones de actualización  
--se pueda cargar para cada registro el usuario y de última actualización. Para que el  
--trigger funcione   la   tabla   deberá   tener   definidos   los   campos   ​
--usr_update (text) y ​time_update (timestamp). 