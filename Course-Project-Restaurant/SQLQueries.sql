
USE Restaurant

---------------------------------------------------------------------------------

--                  GROUP BY

---------------------------------------------------------------------------------

/* 1. Заявка, която извежда името на продукт и броят поръчвания
в поръчки. Принтирайте ги от най-срещаните п
родукти към най-малко срещаните.*/

SELECT pr.Name AS Product, COUNT(op.orderId) AS AmountOfOrders
FROM OrdersProducts op
JOIN Products pr ON op.ProductId = pr.Id
GROUP BY pr.Name
ORDER BY  AmountOfOrders DESC;

/* 2. Заявка, която извежда номер на поръчка, датата,
както и цялата сума, която трябва да се заплати за 
поръчки, които са поръчали повече от 7 продукта.
Нека са подредени по датата на издаване. */

SELECT o.Id as OrderId,
	   o.Date,
	   SUM(op.ProductQuantity*pr.Price) AS TotalSum
FROM OrdersProducts op
JOIN Orders o ON op.OrderId = o.Id
JOIN Products pr ON pr.Id = op.ProductId
GROUP BY o.Id, o.Date
HAVING COUNT(op.ProductId) > 7
ORDER BY  o.Date ASC;

/* 3.  Заявка, която извежда храни, тяхната производствена
цена (в зависимост от продуктите, които съдържа) и цената, на която
се продава в ресторанта. Подредени от най-висока към най-ниска цена
на производство.*/

SELECT pr.Name AS Product, 
       SUM((i.Price/1000)*pin.IngredientQuantity) AS PriceProduction,
	   pr.Price 
FROM Ingredients i
JOIN ProductsIngredients pin ON i.Id = pin.IngredientId
JOIN Products pr ON pin.ProductId = pr.Id
JOIN Categories c ON c.id = pr.CategoryId
WHERE c.Name NOT LIKE 'Drink'
GROUP BY pr.Name, pr.Price
ORDER BY PriceProduction DESC;

/* 4. Заявка, която извежда име на меню, продуктът от менюто с
най-ниска цена и подуктът с най-висока. */

SELECT m.Type AS Menu, MIN(pr.Price) AS MinPriceProduct, MAX(pr.Price) AS MaxPriceProduct
FROM Products pr
JOIN MenusProducts mp ON pr.Id = mp.ProductId
JOIN Menus m ON mp.MenuId = m.Id 
GROUP BY m.Type

/* 5. Заявка, която извежда името на съставката и броят ястия, в които
се съдържа. Изведете ги от към най-използваните ястия. */

SELECT i.Name AS Ingredient, COUNT(pr.Name) AS CountProducts
FROM Products pr
JOIN ProductsIngredients pin ON pin.ProductId = pr.Id
JOIN Ingredients i ON i.Id = pin.IngredientId
GROUP BY i.Name
ORDER BY countProducts DESC;

/* 6. Заявка, която извежда име на съставка, количество и тип 
количество, в каквато се използва във всички продукти. Изведете ги от към
най-използваните съставки.*/

SELECT i.Name AS Ingredient, SUM (pin.IngredientQuantity) AS Quantity, ta.Name AS QuantityUnit
FROM Products pr
JOIN ProductsIngredients pin ON pin.ProductId = pr.Id
JOIN Ingredients i ON i.Id = pin.IngredientId
JOIN TypesOfAmount ta ON ta.Id = i.AmountTypeId
GROUP BY i.Name, ta.Name
ORDER BY ta.Name, Quantity  DESC;

/* 7. Заявка, която извежда името на продуктите, които са съставени
от поне 6 съставки. Извеждаме също кои са съставките, както и
категория на продукта. Сортирани са според категорията на продукта.*/

SELECT pr.Name AS Product, pr.Description, c.Name AS Category
FROM Products pr
JOIN Categories c ON c.Id = pr.CategoryId
JOIN ProductsIngredients pin ON pin.ProductId = pr.Id 
GROUP BY pr.Name, c.Name, pr.Description
HAVING COUNT(pin.IngredientId) > 5
ORDER BY c.Name ASC;

/* 8. Заявката извежда име на съставка, количество и количествена единица
за всички продукти, които се намират в неактивното меню (Италианското)
( с цел подготвка за пускане). */

SELECT i.Name AS Ingredient,
	   SUM (pin.IngredientQuantity) AS Quantity,
	   ta.Name AS QuantityUnit
FROM Products pr
JOIN ProductsIngredients pin ON pin.ProductId = pr.Id
JOIN Ingredients i ON i.Id = pin.IngredientId
JOIN TypesOfAmount ta ON ta.Id = i.AmountTypeId
JOIN MenusProducts mp ON pr.Id = mp.ProductId
JOIN Menus m ON mp.MenuId = m.Id 
WHERE m.IsActive = 0
GROUP BY i.Name, ta.Name
ORDER BY ta.Name, Quantity  DESC;

/* 9. Заявка, коятo извежда номер на поръчката, дата и обща сума,
за тези поръчки, които са поръчвали поне 10 различни продукта */

SELECT op.OrderId, o.Date, SUM(pr.Price) AS TotalSum
FROM Products pr
JOIN OrdersProducts op ON op.ProductId = pr.Id
JOIN Orders o ON o.Id = op.OrderId
GROUP BY op.OrderId, o.Date
HAVING COUNT(DISTINCT op.ProductId) > 9;

/* 10. Заявка, която извежда активните менюта и колко
на брой продукта от него са били поръчвани. */

SELECT m.Type AS Menu, SUM(op.ProductId*op.ProductQuantity) AS QuantityProducts
FROM Products pr
JOIN MenusProducts mp ON pr.Id = mp.ProductId
JOIN Menus m ON mp.MenuId = m.Id 
JOIN OrdersProducts op ON op.ProductId = pr.Id
JOIN Orders o ON o.Id = op.OrderId
WHERE m.IsActive = 1
GROUP BY m.Type;

------------------------------------------------------------------------------------

--                           Subqueries

------------------------------------------------------------------------------------

/* 1. Заявка, която извежда имената на артикулите, чиято цена е по-висока от
най-високата цена на продукт, поръчан в поръчка преди 2020-04-11. */

SELECT Name FROM Products
WHERE Price > (
	SELECT MAX(Price)
	FROM Orders o JOIN OrdersProducts op ON o.Id=op.OrderId JOIN Products p ON p.Id = op.ProductId
	WHERE Date < '2020-04-11'
);

/*  2. Заявка, която извежда броя на поръчките, в които присъства
"Homemade" артикул (напр. Hommemade Chips) */

SELECT COUNT(DISTINCT o.Id)
FROM Orders o
JOIN OrdersProducts op ON o.Id=op.OrderId
WHERE op.ProductId IN (
	SELECT Id FROM Products WHERE Name LIKE 'Homemade%'
);

/* 3. Заявка, която извежда датата от най-скорошната поръчка,
в която присъства салата от гръцкото меню. */

SELECT MAX(o.Date) AS Date 
FROM Orders o JOIN OrdersProducts op ON op.OrderId = o.Id
WHERE op.ProductId IN (
	SELECT mp.ProductId
	FROM Menus m JOIN MenusProducts mp ON mp.MenuId=m.Id 
	JOIN Categories c ON c.Id = mp.ProductId
	WHERE c.Name = 'Salad' AND m.Type = 'Greek'
);

/* 4. Името на продукта, съдържащ най-скъпата съставка. */

SELECT p.Name 
FROM Products p 
JOIN ProductsIngredients pi ON p.id=pi.ProductId
WHERE pi.IngredientId = (
	SELECT Id FROM Ingredients
	WHERE Price = (
		SELECT MAX(Price) FROM Ingredients
	)
);

/* 5. Заявка, която извежда продуктите, които не
са "Fried" от гръцкото меню.*/

SELECT DISTINCT pr.Name AS Product FROM ProductsIngredients pi 
JOIN Products pr ON pr.Id = pi.ProductId
JOIN Ingredients i ON pi.IngredientId=i.Id
WHERE pi.ProductId IN (
	SELECT mp.ProductId FROM Menus m 
	JOIN MenusProducts mp ON mp.MenuId=m.Id
		WHERE mp.ProductId IN (
			SELECT Id FROM Products WHERE Name NOT LIKE '%Fried%'
		) AND m.Type = 'Greek'	
);

-----------------------------------------------------------------------------------------

--                                 Simple queries

-----------------------------------------------------------------------------------------
/* 1. Заявка, която връща имената на продуктите 
,които не съдържат дадена съставка. */

SELECT NAME 
FROM Products 
WHERE [Description] NOT LIKE '%tomatoes%' 

/*2. Зявка, която връща Id  и име на съставките ,на които
количеството им е над 2000 грама ,подредени по азбучен 
ред и по грамаж в нарастващ ред.*/

SELECT Id,Name
FROM Ingredients
WHERE Amount >2000
AND AmountTypeId = 1 
ORDER BY Name,Amount ASC;

/*3.Заявка ,която връща имената и грамажа на порцията на
всички десерти с цена до 5 лева ,подредени по цена във 
възходящ ред.*/

SELECT NAME,PortionAmount 
FROM Products 
WHERE CategoryId = 7 
AND Price < 5 
ORDER BY Price ASC;

/*4.Заявка ,която връща имената на всички активни менюта*/

SELECT Type 
FROM Menus 
WHERE IsActive = 1;


/*5.Заявка ,която връща ID и дата на поръчките
,направени през месец Април 2020г.*/

SELECT *
FROM Orders 
WHERE Date LIKE '%2020-04%';

------------------------------------------------------------------------------------

--                               Many relations

------------------------------------------------------------------------------------

/*1.Заявка, която връща име, описание, цена и размер на
порцията на ястията ,които са в категория Пица ,
подредени по азбучен ред.*/

SELECT Products.Name,[Description],Price,PortionAmount
FROM Products,Categories
WHERE Categories.Name='Pizza' 
AND CategoryId=5 
ORDER By Products.Name;

/*2.Заявка ,която връща общата сума на цената на продуктите
,които са под ID 14 (Coca Cola)
в поръчка с ID номер 1.*/

SELECT SUM(Price)
FROM OrdersProducts,Orders,Products
WHERE [Date]='2020-04-10' 
AND OrderId = 1 
AND ProductId = 14
AND Products.Id = 14;

/*3.Заявка ,която връща датата ,ID и количество на продуктите
,на поръчка с ID = 1*/

SELECT Date,ProductId,ProductQuantity 
FROM Orders,OrdersProducts 
WHERE Id = 1 AND OrderId = 1;

/*4.Заявка ,която връща име ,описание ,цена ,количество и
мерната единица за количество на всички продукти ,които 
се измерват в грамове.*/

SELECT Products.Name,[Description],Price,PortionAmount,TypesOfAmount.Name
FROM Products,TypesOfAmount 
WHERE AmountTypeId = 1
AND TypesOfAmount.Id= 1;

/*5.Заявка, която извежда име ,описание ,цена ,количество 
и мерната единица за количество на всички продукти ,които 
се измерват в милилитри и са ястия.*/

SELECT Products.Name,[Description],Price,PortionAmount,TypesOfAmount.Name
FROM Products,TypesOfAmount 
WHERE AmountTypeId = 2
AND TypesOfAmount.Id= 2 
AND [Description] LIKE '% %';


------------------------------------------------------------------------------------

--                                  JOIN

------------------------------------------------------------------------------------

/* 1. Заявка, която да извежда кои продукти се съдържат в повече от едно меню и
борят на менютата, в които се съдържа. */

SELECT pr.Name, COUNT(pr.Name) as NumberOfMenus
FROM Products pr 
JOIN MenusProducts mp ON pr.id=mp.ProductId 
JOIN Menus m ON mp.MenuId=m.Id
GROUP BY pr.Name
HAVING COUNT(pr.Name)>1;

/* 2. Заявка, извеждаща всички продукти, техния тип,
описание на съставките и цената в Италианското меню. */

SELECT pr.Name, c.Name as 'Type of product', 
	   pr.Description, pr.Price,
	   m.Type as 'Type of menu'
FROM Products pr 
JOIN MenusProducts mp ON pr.id=mp.ProductId 
JOIN Menus m ON mp.MenuId=m.Id 
JOIN Categories c ON pr.CategoryId=c.Id
WHERE m.Type='Italian';

/* 3. Заявка, която извежда датите, на които са поръчани продукти от тип Салата 
с цени по-ниски от 10 лева. */

use Restaurant
SELECT o.Date, pr.Name, c.Name as 'Type of product' , pr.Price, m.Type as 'Type of menu'
FROM Orders o 
JOIN OrdersProducts op ON o.id=op.OrderId 
JOIN Products pr ON op.ProductId=pr.Id 
JOIN MenusProducts mp ON pr.id=mp.ProductId 
JOIN Menus m ON mp.MenuId=m.Id 
JOIN Categories c ON pr.CategoryId=c.Id
WHERE c.Name='Salad' AND pr.Price<10;

/* 4. Заявка, която извежда десертите, за направата, 
на които са използвани по-малко от 50 грама захар */

SELECT DISTINCT pr.Name AS Product,
	   c.Name AS Category
FROM Products pr
JOIN ProductsIngredients pi ON pr.Id=pi.ProductId 
JOIN Ingredients i ON pi.IngredientId=i.Id
JOIN Categories c ON pr.CategoryId=c.Id
WHERE pi.IngredientQuantity < 50
AND c.Name='Dessert'
AND i.Name='sugar';

/* 5. Заявка, която извежда всички наливни напитки. */

SELECT pr.Name, c.Name as 'Category', ta.Name as 'Type of Amount', pr.PortionAmount
FROM Products pr 
JOIN Categories c ON pr.CategoryId=c.Id 
JOIN TypesOfAmount ta ON pr.AmountTypeId=ta.Id
WHERE c.Name='Drink' AND ta.Name='milliliters';
