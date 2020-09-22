USE movies

/*1. Напишете заявка, която извежда имената на актьорите мъже,
участвали във филма The Usual Suspects*/
SELECT s.starname
FROM starsin s
JOIN moviestar m ON s.starname = m.name
WHERE s.movietitle = 'The Usual Suspects'
AND m.gender = 'M'

/* 2. Напишете заявка, която извежда имената на актьорите, 
участвали във филми от 1995, продуцирани от студио MGM. */
SELECT s.starname
FROM movie m
JOIN starsin s ON m.title = s.movietitle
WHERE s.movieyear = 1995 
AND m.studioname = 'MGM'

/*3. Напишете заявка, която извежда имената на продуцентите,
които са продуцирали филми на студио MGM.*/
SELECT DISTINCT me.name
FROM movie m
JOIN movieexec me ON m.producerc# = me.cert#
WHERE m.studioname = 'MGM'

/* 4. Напишете заявка, която извежда имената на всички филми 
с дължина, поголяма от дължината на филма Star Wars*/
SELECT title FROM movie
WHERE length >
(SELECT length
FROM movie 
WHERE title LIKE 'Star Wars')

/* 5. Напишете заявка, която извежда имената на продуцентите 
с нетни активи поголеми от тези на Stephen Spielberg.*/
SELECT name FROM movieexec
WHERE networth > (SELECT networth FROM movieexec 
				  WHERE name = 'Stephen Spielberg')

/*6. Напишете заявка, която извежда имената на всички филми, 
които сапродуцирани от продуценти с нетни активи по-големи 
от тези на Stephen Spielberg. */
SELECT title FROM movie m
JOIN (SELECT * FROM movieexec
	  WHERE networth > (SELECT networth FROM movieexec 
	  WHERE name = 'Stephen Spielberg')) me
ON m.producerc# = me.cert#

-----------------------------------------------------------
USE pc

/*1. Напишете заявка, която извежда производителя и честотата
на лаптопите с размер на диска поне 9 GB.*/
SELECT p.maker, l.speed
FROM laptop l
JOIN product p ON l.model = p.model
WHERE l.hd > 9

/*2. Напишете заявка, която извежда модел и цена на продуктите,
произведени от производител с име B.*/
SELECT DISTINCT p.model, pc.price
FROM product p
JOIN pc ON pc.model = p.model
WHERE maker LIKE 'B'
UNION
SELECT DISTINCT p.model, l.price--
FROM product p
JOIN laptop l ON l.model = p.model
WHERE maker LIKE 'B';

/*3. Напишете заявка, която извежда производителите, които
произвеждат лаптопи, но не произвеждат персонални компютри*/
SELECT DISTINCT maker
FROM product
WHERE type LIKE 'Laptop'
EXCEPT
SELECT DISTINCT maker
FROM product
WHERE type LIKE 'PC'

/*4. Напишете заявка, която извежда размерите на тези дискове,
които се предлагат в поне два различни персонални компютъра 
(два компютъра с различен код).*/
SELECT DISTINCT p1.hd
FROM pc p1, pc p2
WHERE p1.code != p2.code AND p1.hd = p2.hd;

/*5. Напишете заявка, която извежда двойките модели на 
персонални компютри, които имат еднаква честота и памет. 
Двойките трябва да се показват само по веднъж, например 
само (i, j), но не и (j, i).*/
SELECT DISTINCT p2.model, p1.model
FROM pc p1, pc p2
WHERE p1.model > p2.model AND p1.code != p2.code AND p1.ram = p2.ram AND p1.speed = p2.speed;

/*6. Напишете заявка, която извежда производителите на поне 
два различни персонални компютъра с честота поне 400.*/
SELECT DISTINCT pr.maker
FROM pc
JOIN product pr ON pr.model = pc.model
WHERE pc.speed >= 400

SELECT * 
FROM product
SELECT *
FROM pc
------------------------------------------------------------
USE ships
/*1. Напишете заявка, която извежда името на корабите с 
водоизместимост над 50000.*/
SELECT s.name
FROM classes c
JOIN ships s ON s.class = c.class
WHERE c.displacement > 50000

/*2. Напишете заявка, която извежда имената, 
водоизместимостта и броя оръдия на всички кораби, 
участвали в битката при Guadalcanal.*/
SELECT s.name, c.displacement, c.numguns
FROM ships s
JOIN outcomes o ON s.name = o.ship
JOIN classes c ON s.class = c.class
WHERE o.battle LIKE 'Guadalcanal'

/*3. Напишете заявка, която извежда имената на тези държави,
които имат както бойни кораби, така и бойни крайцери.*/
SELECT country
FROM classes
WHERE type LIKE 'bc' 
INTERSECT
SELECT country
FROM classes
WHERE type LIKE 'bb'

/*4. Напишете заявка, която извежда имената на тези 
кораби, които са били повредени в една битка, но
по-късно са участвали в друга битка. ?????  */    
SELECT ship FROM outcomes WHERE result = 'damaged'
INTERSECT
SELECT ship FROM outcomes WHERE result = 'ok'