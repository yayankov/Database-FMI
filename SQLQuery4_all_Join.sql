USE movies

--1. Напишете заявка, която извежда името на продуцента и имената на
--филмите, продуцирани от продуцента на филма ‘Star Wars’.
SELECT  movie.title, m.name
FROM movie
JOIN movieexec m ON movie."producerc#" = m."cert#"
WHERE movie.producerc# = (SELECT producerc# 
						  FROM movie 
						  WHERE title = 'Star Wars')

--2. Напишете заявка, която извежда имената на продуцентите на филмите, в
--които е участвал ‘Harrison Ford’.
SELECT DISTINCT me.name
FROM starsin s
JOIN movie m ON s.movietitle = m.title
JOIN movieexec me ON me.cert# = m.producerc#
WHERE s.starname = 'Harrison Ford'

--3. Напишете заявка, която извежда името на студиото и имената на
--актьорите, участвали във филми, произведени от това студио, подредени
--по име на студио.
SELECT DISTINCT m.studioname,  ss.starname
FROM movie m
JOIN starsin ss ON ss.movietitle = m.title

--4. Напишете заявка, която извежда имената на актьорите, участвали във
--филми на продуценти с най-големи нетни активи.
SELECT s.starname, me.networth, m.title
FROM movieexec me
JOIN movie m ON m.producerc# = me.cert#
JOIN starsin s ON s.movietitle = m.title
WHERE me.networth = (SELECT MAX(networth) FROM movieexec)

--5. Напишете заявка, която извежда имената на актьорите, които не са
--участвали в нито един филм.
SELECT m.name, s.movietitle
FROM moviestar m
LEFT JOIN starsin s ON s.starname = m.name
WHERE m.name NOT IN (SELECT starname FROM starsin)

---------------------------------------------------------------------
USE pc

--1. Напишете заявка, която извежда производител, модел и тип на продукт
--за тези производители, за които съответният продукт не се продава
--(няма го в таблиците PC, Laptop или Printer)
SELECT * 
FROM product
WHERE model NOT IN (SELECT model FROM laptop
					UNION ALL
					SELECT model FROM pc
					UNION ALL
					SELECT model FROM printer)

--2. Намерете всички производители, които правят както лаптопи, така и
--принтери.
SELECT maker 
FROM product		
WHERE type = 'Laptop'
INTERSECT
SELECT maker 
FROM product		
WHERE type = 'Printer';

--3. Намерете размерите на тези твърди дискове, които се появяват в два
--или повече модела лаптопи.
SELECT hd
FROM laptop 
GROUP BY hd
HAVING COUNT(hd) > 1;

--4. Намерете всички модели персонални компютри, които нямат регистриран
--производител.
SELECT * 
FROM pc
RIGHT JOIN product pr ON pr.model = pc.model
WHERE pr.type = 'PC'

-------------------------------------------------------------------
USE ships

--1. Напишете заявка, която извежда цялата налична информация за всеки
--кораб, включително и данните за неговия клас. В резултата не трябва да
--се включват тези класове, които нямат кораби.
SELECT *
FROM ships s
LEFT JOIN classes c ON c.class = s.class

--2. Повторете горната заявка, като този път включите в резултата и
--класовете, които нямат кораби, но съществуват кораби със същото име
--като тяхното.
SELECT *
FROM ships s
FULL JOIN classes c ON c.class = s.class

--3. За всяка страна изведете имената на корабите, които никога не са
--участвали в битка.
SELECT c.country, s.name
FROM ships s
JOIN classes c ON c.class = s.class
WHERE s.name NOT IN (SELECT ship FROM outcomes)
ORDER BY c.country;

--4. Намерете имената на всички кораби с поне 7 оръдия, пуснати на вода
--през 1916, но наречете резултатната колона Ship Name.
SELECT s.name AS 'Ship Name'
FROM classes c
JOIN ships s ON c.class = s.class
WHERE s.launched = 1916
AND c.numguns > 6;

--5. Изведете имената на всички потънали в битка кораби, името и дата на
--провеждане на битките, в които те са потънали. Подредете резултата по
--име на битката.
SELECT o.ship, b.name, b.date
FROM outcomes o
JOIN battles b ON o.battle = b.name
WHERE result = 'sunk'
ORDER BY b.name;

--6. Намерете името, водоизместимостта и годината на пускане на вода на
--всички кораби, които имат същото име като техния клас.
SELECT s.name, c.displacement, s.launched
FROM ships s
JOIN classes c ON c.class = s.class
WHERE c.class = s.name

--7. Намерете всички класове кораби, от които няма пуснат на вода нито един
--кораб.
SELECT *
FROM classes c
WHERE c.class NOT IN ( SELECT class FROM ships)

--8. Изведете името, водоизместимостта и броя оръдия на корабите,
--участвали в битката ‘North Atlantic’, а също и резултата от битката.
SELECT s.name, c.displacement, c.numguns, o.result
FROM classes c
JOIN ships s ON s.class = c.class
JOIN outcomes o ON o.ship = s.name
WHERE o.battle = 'North Atlantic';