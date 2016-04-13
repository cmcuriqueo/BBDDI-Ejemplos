--Los paises que tengan actores como directores.
SELECT DISTINCT p.nombre
FROM pais p
	INNER JOIN actor a
	ON a.pais = p.id
	INNER JOIN director d
	ON d.pais = p.id
;
--los actores que no trabajaron en ninguna pelicula
SELECT a.nombre
FROM actor a
EXCEPT
SELECT a.nombre
FROM actor a
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id;
--Otra forma
SELECT a.nombre, pa.actor
FROM actor a
	LEFT JOIN pelicula_actor pa
	ON pa.actor = a.id
WHERE pa.actor IS NULL;

--los actores extranjeros que trabajaron en peliculas argentinas
SELECT a.nombre AS nombre_actor, p.nombre AS nombre_pelicula
FROM actor a
	INNER JOIN pais pi
	ON pi.id = a.pais
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON pa.pelicula = p.id
WHERE pi.nombre != 'Argentina'
INTERSECT 
SELECT a.nombre, p.nombre
FROM pelicula p
	INNER JOIN pais pi
	ON p.pais = pi.id
	INNER JOIN pelicula_actor pa
	ON pa.pelicula = p.id
	INNER JOIN actor a
	ON a.id = pa.actor
WHERE pi.nombre = 'Argentina';
--Otra forma mas SQL
SELECT a.nombre AS nombre_actor, p.nombre AS nombre_pelicula
FROM actor a
	INNER JOIN pais pi
	ON pi.id = a.pais
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON pa.pelicula = p.id
	INNER JOIN pais pp
	ON pp.id = p.pais
WHERE pi.nombre != 'Argentina' AND pp.nombre = 'Argentina' ;

--los actores extranjeros que trabajaron en peliculas de los estados unidos
SELECT a.nombre AS nombre_actor, p.nombre AS nombre_pelicula
FROM actor a
	INNER JOIN pais pi
	ON pi.id = a.pais
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON pa.pelicula = p.id
WHERE pi.nombre != 'Argentina'
INTERSECT
SELECT a.nombre, p.nombre
FROM pelicula p
	INNER JOIN pais pi
	ON p.pais = pi.id
	INNER JOIN pelicula_actor pa
	ON pa.pelicula = p.id
	INNER JOIN actor a
	ON a.id = pa.actor
WHERE pi.nombre = 'Estados Unidos';
--Otra forma mas SQL
SELECT a.nombre AS nombre_actor, p.nombre AS nombre_pelicula
FROM actor a
	INNER JOIN pais pi
	ON pi.id = a.pais
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON pa.pelicula = p.id
	INNER JOIN pais pp
	ON pp.id = p.pais
WHERE pi.nombre != 'Argentina' AND pp.nombre = 'Estados Unidos' ;

--El actor que trabajo con Benicio del Toro y tambien con Daniel Day Lewis
SELECT DISTINCT oa.nombre AS nombre_actor
FROM actor a
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON p.id = pa.pelicula
	INNER JOIN pelicula_actor poa
	ON p.id = poa.pelicula
	INNER JOIN actor oa 
	ON oa.id = poa.actor
	WHERE a.nombre = 'Daniel Day Lewis' 
		OR a.nombre = 'Benicio del Toro' 
		AND oa.nombre != 'Daniel Day Lewis'
		AND oa.nombre != 'Benicio del Toro'

--Los actores que compartieron set con Francis Ford Coppola y Al Pacino
SELECT DISTINCT oa.nombre
FROM actor a
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON p.id = pa.pelicula
	INNER JOIN pelicula_actor poa
	ON p.id = poa.pelicula
	INNER JOIN actor oa 
	ON oa.id = poa.actor
	WHERE a.nombre = 'Francis Ford Coppola' 
		OR a.nombre = 'Al Pacino' 
		AND oa.nombre != 'Al Pacino'
		AND oa.nombre != 'Francis Ford Coppola';
	
--Los actores que fueron dirigidos pos Stanley Kubrik
SELECT a.nombre 
	AS nombre_actor, d.nombre 
	AS nombre_director, p.nombre 
	AS nombre_pelicula
FROM actor a
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON p.id = pa.pelicula
	INNER JOIN director d
	ON d.id = p.director
WHERE d.nombre = 'Stanley Kubrik';

--Las peliculas protagonizadas por la dupla Pacino - Pfreiffer
SELECT p.nombre
FROM pelicula p
	INNER JOIN pelicula_actor pa
	ON pa.pelicula = p.id
	INNER JOIN actor a
	ON a.id = pa.actor
WHERE a.nombre ILIKE '%Pacino%'
INTERSECT
SELECT p.nombre
FROM pelicula p
	INNER JOIN pelicula_actor pa
	ON pa.pelicula = p.id
	INNER JOIN actor a
	ON a.id = pa.actor
WHERE a.nombre ILIKE '%Pfeiferr%';

--Los directores ingleses que dirigieron en estados unidos
SELECT --DISTINCT  si solo muestro el nombre del director
	d.nombre AS nombre_director, 
	pd.nombre AS pais_director,
	p.nombre AS nombre_pelicula,
	pp.nombre AS pais_pelicula
FROM director d
	INNER JOIN pelicula p
	ON p.director = d.id
	INNER JOIN pais pd
	ON pd.id = d.pais
	INNER JOIN pais pp
	ON pp.id = p.pais
WHERE pd.nombre = 'Inglaterra' AND pp.nombre = 'Estados Unidos';

--El actor y el director que participaron en más péliculas (devuelva una sola relacion con un atributo nombre)
SELECT * FROM (SELECT a.nombre
FROM actor a
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
GROUP BY a.nombre
ORDER BY COUNT(a.nombre)
LIMIT 1) AS a
UNION
SELECT * FORM(SELECT d.nombre
FROM director d
	INNER JOIN pelicula p
	ON p.director = d.id
GROUP BY d.nombre
ORDER BY COUNT(d.nombre)
LIMIT 1) AS b;

--Para cada artista: el periodo en que trabajo y la cantidad de peliculas que realizo en ese tiempo
SELECT a.nombre AS nombre_actor, 
	MIN(p.anio)||' - '|| MAX(p.anio) AS periodo,  
	COUNT(pa.pelicula) AS cantidad_peliculas
FROM actor a
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula p
	ON p.id = pa.pelicula
GROUP BY a.nombre
ORDER BY 1

--Para cada artista: la cantidad de peliculas que realizo en su pais
SELECT a.nombre AS nombre_actor, COUNT(*) AS cantidad_peliculas
FROM actor a
	INNER JOIN pais p
	ON p.id = a.pais
	INNER JOIN pelicula_actor pa
	ON pa.actor = a.id
	INNER JOIN pelicula peli
	ON peli.id = pa.pelicula
WHERE a.pais = peli.pais
