USE pc

/* 1. Напишете заявка, която извежда средната честота на персоналните 
компютри.*/
SELECT ROUND(AVG(speed),2) AS AvgSpeed
FROM pc;

/*2. Напишете заявка, която извежда средния размер на екраните на 
лаптопите за всеки производител.*/
SELECT p.maker, AVG(l.screen) AS AvgScreen
FROM laptop l
JOIN product p ON p.model = l.model
GROUP BY p.maker;

/*3. Напишете заявка, която извежда средната честота на лаптопите с 
цена над 1000.*/
SELECT ROUND(AVG(speed),2)
FROM laptop
WHERE price > 1000

/*4. Напишете заявка, която извежда средната цена на персоналните 
компютри, произведени от производител ‘A’.*/
SELECT pr.maker, ROUND(AVG(pc.price),2)
FROM pc
JOIN product pr ON pr.model = pc.model
GROUP BY pr.maker
HAVING pr.maker = 'A';

/*5. Напишете заявка, която извежда средната цена на персоналните 
компютри и лаптопите за производител ‘B’.*/
USE pc
SELECT pr.maker, AVG(al.price)
FROM product pr
JOIN (SELECT model, price FROM laptop 
	  UNION ALL
SELECT model, price FROM pc ) al ON al.model = pr.model
GROUP BY pr.maker
HAVING pr.maker = 'B';

/*6. Напишете заявка, която извежда средната цена на персоналните 
компютри според различните им честоти. */
SELECT speed, AVG(price) AS AvgPrice
FROM pc
GROUP BY speed;

/*7. Напишете заявка, която извежда производителите, които са произвели
поне 3 различни персонални компютъра (с различен код).*/
SELECT maker, COUNT(DISTINCT pc.code) AS number_of_pc
FROM product p
JOIN pc ON p.model = pc.model
GROUP BY maker
HAVING COUNT(DISTINCT pc.code) >= 3

/*8. Напишете заявка, която извежда производителите с най-висока цена 
на персонален компютър.*/
SELECT pr.maker, pc.price
FROM pc
JOIN product pr ON pr.model = pc.model
WHERE pc.price IN (SELECT MAX(price) FROM pc);

/*9. Напишете заявка, която извежда средната цена на персоналните
компютри за всяка честота по-голяма от 800.*/
SELECT speed, AVG(price) AS AvgPrice
FROM pc
GROUP BY speed
HAVING speed > 800;

/*10.Напишете заявка, която извежда средния размер на диска на тези
персонални компютри, произведени от производители, които произвеждат и 
принтери. Резултатът да се изведе за всеки отделен производител. */SELECT pr.maker, AVG(pc.hd) FROM pcJOIN product pr ON pr.model = pc.modelWHERE pr.maker IN (SELECT maker FROM product WHERE type = 'Printer')GROUP BY pr.maker----------------------------------------------------------------------USE ships/*1. Напишете заявка, която извежда броя на класовете бойни кораби.*/
SELECT COUNT(class)
FROM classes
GROUP BY type
HAVING type = 'bb';

/*2. Напишете заявка, която извежда средния брой оръдия за всеки клас
боен кораб.*/
SELECT class, AVG(numguns) AS AvgGuns
FROM classes
WHERE type = 'bb'
GROUP BY class

/*3. Напишете заявка, която извежда средния брой оръдия за всички бойни
кораби.*/
SELECT AVG(numguns) AS avgGuns
FROM classes

/*4. Напишете заявка, която извежда за всеки клас първата и последната 
година, в която кораб от съответния клас е пуснат на вода.*/
SELECT class, MIN(launched) AS FistYear, MAX(launched) AS LastYear
FROM ships
GROUP BY class

/*5. Напишете заявка, която извежда броя на корабите, потънали в битка 
според класа. */
SELECT ships.class, COUNT(result)
FROM outcomes o
JOIN ships ON ships.name = o.ship
WHERE o.result = 'sunk'
GROUP BY ships.class;

/*6. Напишете заявка, която извежда броя на корабите, потънали в битка
според класа, за тези класове с повече от 2 кораба.*/
SELECT ships.class, COUNT(result)
FROM ships
JOIN (SELECT * FROM outcomes 
	  WHERE result = 'sunk') o ON ships.name = o.ship
GROUP BY ships.class

/*7. Напишете заявка, която извежда средния калибър на оръдията на 
корабите за всяка страна.*/
SELECT country, ROUND(AVG(bore),2)
FROM classes c
JOIN ships s ON s.class = c.class
GROUP BY country