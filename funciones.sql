﻿--Para ejercitar funciones
--1) Escriba una consulta SQL que permita exportar los datos de productos en un archivo de texto de campos de ancho fijo.

--tipo 2 ALiniados izquierda.
--codigo 5:numeric alineado derecha completar con espacios izquierda.
--nombre 18 truncado completado con espacios.
--precio 11 aliniado derecha, completado con ceros.
SELECT rpad(tipo, 2, ' ') || lpad(codigo::text, 5, ' ') || RPAD(nombre, 18) || lpad(replace(precio::text, '.', ''),11, '0' ) FROM producto
UNION ALL
SELECT format( '%-2s%5s%18s%s', tipo, codigo::text, rpad(nombre, 18, ' ' ), lpad(replace(precio::text, '.', ''),11, '0' )) FROM producto
ORDER BY 1;

--2) Escriba un consulta donde se muestre para cada cliente el rengo etáreo en que se encuentra usando rangos de cinco en cinco años, debe expresarse como una cadena de texto en forma ‘de X a X’.
SELECT format('%s de %s a %s', nombre, ((EXTRACT(years from age(fecha_nacimiento))/5)::int*5), (((EXTRACT(years from age(fecha_nacimiento))/5)::int+1)*5)) as rango FROM cliente;

