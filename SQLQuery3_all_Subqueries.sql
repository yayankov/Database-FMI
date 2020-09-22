USE movies

/*1. Напишете заявка, която извежда имената на актрисите, които са също и
продуценти с нетни активи над 10 милиона.*/
SELECT me.name
FROM movieexec me
JOIN moviestar ms ON me.name = ms.name
WHERE ms.gender = 'F' 
AND me.networth > 1000000

/*2. Напишете заявка, която извежда имената на тези актьори (мъже и жени),
които не са продуценти.*/
SELECT name
FROM moviestar
WHERE name NOT IN (SELECT name FROM movieexec);

/*3. Напишете заявка, която извежда имената на всички филми с дължина,
по-голяма от дължината на филма ‘Star Wars’*/
SELECT title
FROM movie 
WHERE length > (SELECT length FROM movie WHERE title LIKE 'Star Wars')

/*4. Напишете заявка, която извежда имената на продуцентите и имената на
филмите за всички филми, които са продуцирани от продуценти с нетни
активи по-големи от тези на ‘Merv Griffin’*/
SELECT m.title, c.name
FROM movie m
JOIN (SELECT * FROM movieexec WHERE networth > 
			  (SELECT networth FROM movieexec 
			WHERE name = 'Merv Griffin')) c ON m.producerc# = c.cert#

---------------------------------------------------------------
USE pc

/*1. Напишете заявка, която извежда производителите на персонални
компютри с честота над 500.*/
SELECT DISTINCT pr.maker
FROM pc
JOIN (SELECT * FROM product WHERE type='PC') pr ON pc.model = pr.model
WHERE speed > 500

/*2. Напишете заявка, която извежда код, модел и цена на принтерите
с най-висока цена.*/
SELECT code, model, price
FROM printer 
WHERE price = (SELECT MAX(price) FROM printer)
 
/*3. Напишете заявка, която извежда лаптопите, чиято честота е по-ниска от
честотата на всички персонални компютри.*/
SELECT *
FROM laptop
WHERE speed < ALL (SELECT speed FROM pc)

/*4. Напишете заявка, която извежда модела и цената на продукта (PC,
лаптоп или принтер) с най-висока цена.*/
SELECT a.model, a.price
FROM (SELECT model, price
	 FROM printer 
	 UNION
	 SELECT model, price
	 FROM laptop 
	 UNION
	 SELECT model, price
	 FROM pc) a
WHERE a.price = (SELECT MAX(b.price) FROM (SELECT model, price
	 FROM printer 
	 UNION
	 SELECT model, price
	 FROM laptop 
	 UNION
	 SELECT model, price
	 FROM pc) b)

/*5. Напишете заявка, която извежда производителя на цветния принтер с
най-ниска цена.*/
SELECT pr.maker
FROM printer p
JOIN product pr ON p.model = pr.model
WHERE p.price = (SELECT MIN(a.price) FROM printer a 
				 WHERE a.color = 'y')
AND p.color = 'y'

/*6. Напишете заявка, която извежда производителите на тези персонални
компютри с най-малко RAM памет, които имат най-бързи процесори.*/
SELECT pr.maker
FROM (SELECT *
	  FROM pc
	  WHERE pc.ram = ( SELECT MIN(ram) FROM pc)) a
JOIN product pr ON pr.model = a.model
WHERE a.speed = (SELECT MAX(b.speed) FROM (SELECT *
	  FROM pc
	  WHERE pc.ram = ( SELECT MIN(ram) FROM pc)) b) 


---------------------------------------------------------------
USE ships

/*1. Напишете заявка, която извежда страните, чиито кораби са с най-голям
брой оръдия.*/
SELECT DISTINCT country
FROM classes
WHERE numguns = (SELECT MAX(numguns) FROM classes)

/*2. Напишете заявка, която извежда класовете, за които поне един от
корабите е потънал в битка.*/
SELECT DISTINCT s.class
FROM ships s
JOIN outcomes o ON s.name = o.ship
WHERE o.result = 'sunk'

/*3. Напишете заявка, която извежда името и класа на корабите с 16 инчови
оръдия.*/
SELECT s.name, s.class
FROM classes c
JOIN ships s ON s.class = c.class
WHERE c.bore = 16

/*4. Напишете заявка, която извежда имената на битките, в които са
участвали кораби от клас ‘Kongo’.*/
SELECT o.battle
FROM outcomes o
JOIN ships s ON o.ship = s.name
WHERE s.class = 'Kongo'

/*5. Напишете заявка, която извежда класа и името на корабите, чиито брой
оръдия е по-голям или равен на този на корабите със същия калибър
оръдия*/
SELECT s.name, s.class
FROM ships s
JOIN classes c1 ON s.class = c1.class
WHERE c1.numguns >= ALL (SELECT numguns 
						 FROM classes c2 
						 WHERE c2.bore = c1.bore)



