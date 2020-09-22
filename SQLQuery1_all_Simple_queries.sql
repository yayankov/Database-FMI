USE ships

SELECT class, country
FROM classes
WHERE numguns < 10

SELECT name AS shipName
FROM ships
WHERE launched < 1918

SELECT ship, battle
FROM outcomes
WHERE result = 'sunk'

SELECT name
FROM ships
WHERE name = class

SELECT name
FROM ships
WHERE name LIKE 'R%'

SELECT name
FROM ships
WHERE name LIKE '% %'

--------------------------------------------------
USE pc

SELECT model, speed AS Mhz, hd AS GB  FROM pc
WHERE price < 1200;

SELECT DISTINCT maker FROM product
WHERE type = 'Printer'; 

SELECT model,ram,screen FROM laptop
WHERE price > 1000;

SELECT * FROM printer
WHERE color = 'y';

SELECT model,speed,hd FROM pc
WHERE (cd = '12x' OR cd = '16x') AND price < 2000

----------------------------------------------------
USE movies

SELECT ADDRESS FROM STUDIO
WHERE NAME LIKE 'Disney';

SELECT BIRTHDATE FROM MOVIESTAR
WHERE NAME LIKE 'Jack Nicholson';

SELECT STARNAME FROM STARSIN
WHERE MOVIEYEAR = 1980 
OR MOVIETITLE LIKE '%Knight%';

SELECT NAME FROM MOVIEEXEC
WHERE NETWORTH > 10000000;

SELECT NAME FROM MOVIESTAR
WHERE GENDER = 'M' 
OR ADDRESS = 'Prefect Rd.';

--Напишете заявка, която иьвежда имената на актьорите мъже,
--участвали във филма Тhe usual suspects 

SELECT m.NAME as star_name
FROM moviestar m
JOIN starsin s ON m.name = s.starname
WHERE m.gender ='M'
AND s.movietitle = 'The usual suspects'

SELECT * FROM starsin 
SELECT * FROM moviestar

SELECT s.starname, star.address 
FROM movie m
JOIN starsin s ON m.title = s.movietitle AND m.year = s.movieyear
JOIN moviestar star ON s.starname=star.name
WHERE m.studioname = 'MGM' 
AND m.year = 1995
