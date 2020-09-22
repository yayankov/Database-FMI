USE master
GO
if exists (select * from sysdatabases where name='Restaurant')
	DROP DATABASE Restaurant
GO

CREATE DATABASE Restaurant
GO
USE Restaurant
GO

CREATE TABLE Menus(
	Id INT,
	Type VARCHAR(30) NOT NULL,
	IsActive BIT NOT NULL,

	CONSTRAINT PK_Menus PRIMARY KEY (Id)
);

CREATE TABLE Categories(
	Id INT,
	Name VARCHAR(20) NOT NULL,

	CONSTRAINT PK_TypesOfItem PRIMARY KEY (Id),
);

CREATE TABLE TypesOfAmount(
	 Id INT,
	 Name varchar(20) NOT NULL,

	 CONSTRAINT PK_TypesOfAmount PRIMARY KEY (Id)
);

CREATE TABLE Products(
	Id INT,
	Name VARCHAR(50) NOT NULL,
	Description VARCHAR(120),
	CategoryId INT NOT NULL,
	Price FLOAT NOT NULL,
	PortionAmount FLOAT NOT NULL,
	AmountTypeId INT NOT NULL,

	CONSTRAINT PK_Products PRIMARY KEY (Id),
	CONSTRAINT FK_Products_Categories FOREIGN KEY(CategoryId) REFERENCES Categories(Id),
	CONSTRAINT FK_Products_TypesOfAmount FOREIGN KEY(AmountTypeId) REFERENCES TypesOfAmount(Id),
	CONSTRAINT PortionAmount_ck CHECK (PortionAmount >= 0),
	CONSTRAINT Price_Product_ck CHECK (Price >= 0)
);

CREATE TABLE MenusProducts(
	MenuId INT,
	ProductId INT NOT NULL,

	CONSTRAINT PK_MenusProducts PRIMARY KEY (MenuId,ProductId),
	CONSTRAINT FK_MenusProducts_Menus FOREIGN KEY(MenuId) REFERENCES Menus(Id),
	CONSTRAINT FK_MenusProducts_Products FOREIGN KEY(ProductId) REFERENCES Products(Id)
);

CREATE TABLE Orders(
	 Id INT, 
	 Date DATE NOT NULL,

	 CONSTRAINT PK_Orders PRIMARY KEY (Id)
 );

CREATE TABLE OrdersProducts(
	OrderId INT, 
	ProductId INT NOT NULL, 
	ProductQuantity INT NOT NULL,

	CONSTRAINT PK_OrdersProducts PRIMARY KEY (OrderId,ProductId),
	CONSTRAINT FK_OrdersProducts_Orders FOREIGN KEY(OrderId) REFERENCES Orders(Id),
	CONSTRAINT FK_OrdersProducts_Products FOREIGN KEY(ProductId) REFERENCES Products(Id),
	CONSTRAINT ProductQuantity_ck CHECK (ProductQuantity >= 0)
 );

CREATE TABLE Ingredients(
	Id INT,
	Name varchar(40) NOT NULL,
	Amount FLOAT NOT NULL,
	AmountTypeId INT NOT NULL,
	Price FLOAT NOT NULL,

	CONSTRAINT PK_Ingredients PRIMARY KEY (Id),
	CONSTRAINT FK_Ingredients_TypesOfAmount FOREIGN KEY(AmountTypeId) REFERENCES TypesOfAmount(Id),
	CONSTRAINT Price_Ingredients_ck CHECK (Price >= 0),
	CONSTRAINT Amount_Ingredients_ck CHECK (Amount >= 0)
);

CREATE TABLE ProductsAuditLog(
	Id INT IDENTITY(1,1),
	Name VARCHAR(50) NOT NULL,
	Description VARCHAR(120),
	CategoryId INT NOT NULL,
	EventTime DATE NOT NULL,
	Action VARCHAR(50) NOT NULL

	CONSTRAINT PK_Products_AuditLog PRIMARY KEY (Id),
	CONSTRAINT FK_ProductsAuditLog_Categories FOREIGN KEY(CategoryId) REFERENCES Categories(Id)
);

CREATE TABLE ProductsIngredients(
	ProductId INT,
	IngredientId INT NOT NULL,
	IngredientAmountTypeId INT NOT NULL,
	IngredientQuantity INT NOT NULL,

	CONSTRAINT PK_ProductsIngredients PRIMARY KEY (ProductId,IngredientId),
	CONSTRAINT FK_ProductsIngredients_Ingredients FOREIGN KEY(IngredientId) REFERENCES Ingredients(Id),
	CONSTRAINT FK_ProductsIngredients_Products FOREIGN KEY(ProductId) REFERENCES Products(Id),
	CONSTRAINT FK_ProductsIngredients_QuantityAmount FOREIGN KEY(IngredientAmountTypeId) REFERENCES TypesOfAmount(Id),
	CONSTRAINT Products_Ingredients_ck CHECK (IngredientQuantity >= 0)

);

--TRIGGERS
GO
CREATE OR ALTER TRIGGER tr_soft_delete 
ON dbo.Menus
INSTEAD OF DELETE
AS
UPDATE dbo.Menus
SET IsActive = 0
WHERE Id IN (SELECT Id FROM deleted)
PRINT 'SUCCESSFULLY DISABLED'

GO
CREATE OR ALTER TRIGGER tr_productEvent 
ON dbo.Products
FOR INSERT,UPDATE,DELETE
AS

    declare @pName varchar(50);
    declare @pDescription varchar(150);
    declare @pCategoryId int;
    declare @pEventTime DATE;
    declare @pAction varchar(50);

if exists(SELECT * FROM inserted) and exists (select * from deleted)
begin

    select @pName = i.Name from inserted i;
    select @pDescription = i.DESCRIPTION from inserted i;
    select @pCategoryId = i.CategoryId from inserted i;
    SET @pAction = 'Updated'

    insert into ProductsAuditLog (Name,[Description],CategoryId,EventTime,[Action])
    values(@pName,@pDescription,@pCategoryId,GETDATE(),@pAction);
end

if exists(SELECT * FROM deleted) and not exists (select * from inserted)
begin

    select @pName = d.Name from deleted d;
    select @pDescription = d.DESCRIPTION from deleted d;
    select @pCategoryId = d.CategoryId from deleted d;
    SET @pAction = 'Deleted'

    insert into ProductsAuditLog (Name,[Description],CategoryId,EventTime,[Action])
    values(@pName,@pDescription,@pCategoryId,GETDATE(),@pAction);
end

if exists(SELECT * FROM inserted) and not exists (select * from deleted)
begin

    select @pName = i.Name from inserted i;
    select @pDescription = i.DESCRIPTION from inserted i;
    select @pCategoryId = i.CategoryId from inserted i;
    SET @pAction = 'Inserted'

    insert into ProductsAuditLog (Name,[Description],CategoryId,EventTime,[Action])
    values(@pName,@pDescription,@pCategoryId,GETDATE(),@pAction);
end
    PRINT 'TRIGGER fired'
	
--Insert Infromation
GO
INSERT INTO Categories
	Values(1,'Main Dish');
INSERT INTO Categories
	Values(2,'Salad');
INSERT INTO Categories
	Values(3,'Starter');
INSERT INTO Categories
	Values(8,'Drink');
INSERT INTO Categories
	Values(7,'Dessert');
INSERT INTO Categories
	Values(4,'Pasta & Risotto');
INSERT INTO Categories
	Values(5,'Pizza');
INSERT INTO Categories
	Values(6,'Sushi');
INSERT INTO Categories
	Values(9,'Soups');

INSERT INTO TypesOfAmount
	Values(1,'grams');
INSERT INTO TypesOfAmount
	Values(2,'milliliters');
INSERT INTO TypesOfAmount
	Values(3,'units');

Insert INTO Ingredients
	Values(1,'tomatoes',15000,1,2);
Insert INTO Ingredients
	Values(2,'cucumbers',15000,1,2.2);
Insert INTO Ingredients
	Values(3,'peppers',12000,1,1.8);
Insert INTO Ingredients
	Values(4,'onion',18000,1,0.8);
Insert INTO Ingredients
	Values(5,'white cheese',9000,1,10);
Insert INTO Ingredients
	Values(6,'mushrooms',6000,1,5.5);
Insert INTO Ingredients
	Values(7,'cheese',15000,1,12);
Insert INTO Ingredients
	Values(8,'olive oil',6000,2,20);
Insert INTO Ingredients
	Values(9,'cooking oil',6000,2,2.5);
Insert INTO Ingredients
	Values(10,'butter',15000,1,10);
Insert INTO Ingredients
	Values(11,'olives',12000,1,12);
Insert INTO Ingredients
	Values(12,'chicken',15000,1,6);
Insert INTO Ingredients
	Values(13,'beef',4500,1,15);
Insert INTO Ingredients
	Values(14,'pork',4000,1,12);
Insert INTO Ingredients
	Values(15,'rabbit meat',3600,1,10);
Insert INTO Ingredients
	Values(16,'tuna fish',2400,1,25);
Insert INTO Ingredients
	Values(17,'laurels',3600,1,18);
Insert INTO Ingredients
	Values(18,'sea bream',3600,1,19);
Insert INTO Ingredients
	Values(19,'corn',600,1,9);
Insert INTO Ingredients
	Values(20,'courgettes',6000,1,3);
Insert INTO Ingredients
	Values(21,'shrimps',4500,1,32);
Insert INTO Ingredients
	Values(22,'lettuces',6000,1,5);
Insert INTO Ingredients
	Values(23,'iceberg salad',6000,1,6);
Insert INTO Ingredients
	Values(24,'arugulas',3000,1,8);
Insert INTO Ingredients
	Values(25,'white wine',6000,2,7);
Insert INTO Ingredients
	Values(26,'red wine',6000,2,8);
Insert INTO Ingredients
	Values(27,'tomato sauce',6000,2,10);
Insert INTO Ingredients
	Values(28,'squids',6000,1,42);
Insert INTO Ingredients
	Values(29,'octopus',6000,1,50);
Insert INTO Ingredients
	Values(30,'oregano',600,1,3);
Insert INTO Ingredients
	Values(31,'basil',1500,1,5);
Insert INTO Ingredients
	Values(32,'egg plant',12000,1,2.5);
Insert INTO Ingredients
	Values(33,'parsley',1500,1,1);
Insert INTO Ingredients
	Values(34,'gavros',9000,1,10);
Insert INTO Ingredients
	Values(35,'scad',9000,1,9);
Insert INTO Ingredients
	Values(36,'white fish',7500,1,29);
Insert INTO Ingredients
	Values(37,'cherry tomatoes',150,3,0.2);
Insert INTO Ingredients
	Values(38,'spinach',6000,1,11);
Insert INTO Ingredients
	Values(39,'avocado',4200,1,7);
Insert INTO Ingredients
	Values(40,'red beans',6000,1,11);
Insert INTO Ingredients
	Values(41,'broccoli',6000,1,7);
Insert INTO Ingredients
	Values(42,'bacon',4200,1,10);
Insert INTO Ingredients
	Values(43,'edamame',3000,1,22);
Insert INTO Ingredients
	Values(44,'salmon',4200,1,34);
Insert INTO Ingredients
	Values(45,'mozzarella',4200,1,24);
Insert INTO Ingredients
	Values(46,'croutons',900,3,3);
Insert INTO Ingredients
	Values(47,'Caesar souce',600,2,6);
Insert INTO Ingredients
	Values(48,'potatoes',6000,1,3);
Insert INTO Ingredients
	Values(49,'carrots',6000,1,2.5);
Insert INTO Ingredients
	Values(50,'cream',6000,2,7);
Insert INTO Ingredients
	Values(51,'tagliatelle',6000,1,7);
Insert INTO Ingredients
	Values(52,'spaghetti',6000,1,7);
Insert INTO Ingredients
	Values(53,'rice',6000,1,5);
Insert INTO Ingredients
	Values(54,'parmesan',240,1,15);
Insert INTO Ingredients
	Values(55,'milk',6000,2,2.5);
Insert INTO Ingredients
	Values(56,'biscuits',600,3,0.05);
Insert INTO Ingredients
	Values(57,'dough',4500,1,2.5);
Insert INTO Ingredients
	Values(58,'Coca-cola',240,3,2);
Insert INTO Ingredients
	Values(59,'Sprite',240,3,2);
Insert INTO Ingredients
	Values(60,'Fanta Orange',240,3,2);
Insert INTO Ingredients
	Values(61,'Fanta Lemon',240,3,2);
Insert INTO Ingredients
	Values(62,'Beer Heineken',240,3,3.5);
Insert INTO Ingredients
	Values(63,'Beer Staropramen',240,3,3.5);
Insert INTO Ingredients
	Values(64,'Vodka Beluga',3000,2,60);
Insert INTO Ingredients
	Values(65,'Vodka Ciroc',3000,2,70);
Insert INTO Ingredients
	Values(66,'Whiskey Jack Daniels',3000,2,50);
Insert INTO Ingredients
	Values(67,'Whiskey Johney Walker',3000,2,40);
Insert INTO Ingredients
	Values(68,'Coffee Lavazza',3000,1,100);
Insert INTO Ingredients
	Values(69,'Coffee Bianci',3000,1,120);
Insert INTO Ingredients
	Values(70,'Apple Juice',800,3,2);
Insert INTO Ingredients
	Values(71,'Orange Juice',800,3,2);
Insert INTO Ingredients
	Values(72,'Ice-cream',3000,2,20);
Insert INTO Ingredients
	Values(73,'Shardone Frutino',800,3,8);
Insert INTO Ingredients
	Values(74,'Rose Frutino',800,3,9);
Insert INTO Ingredients
	Values(75,'Syra Frutino',800,3,7.5);
Insert INTO Ingredients
	Values(76,'Shardone Verano Azur',800,3,8.5);
Insert INTO Ingredients
	Values(77,'Rose Verano Azur',800,3,10);
Insert INTO Ingredients
	Values(78,'Syra Verano Azur',800,3,8);
Insert INTO Ingredients
	Values(79,'capers',600,1,0.2);
Insert INTO Ingredients
	Values(80,'Greek pita bread',600,3,0.5);
Insert INTO Ingredients
	Values(81,'tzatziki',3000,1,12);
Insert INTO Ingredients
	Values(82,'Greek yoghurt',3000,1,5);
Insert INTO Ingredients
	Values(83,'honey',2000,1,21);
Insert INTO Ingredients
	Values(84,'walnuts',3000,1,26);
Insert INTO Ingredients
	Values(85,'eggs',300,3,0.3);
Insert INTO Ingredients
	Values(86,'sugar',3000,1,2);
Insert INTO Ingredients
	Values(87,'Water',240,3,2);


INSERT INTO Products
	Values (1,'Shopska Salad','tomatoes, cucumbers, peppers, white cheese, onion',2,7.8,350,1);
INSERT INTO ProductsIngredients
	Values(1,1,1,100);
INSERT INTO ProductsIngredients
	Values(1,2,1,100);
INSERT INTO ProductsIngredients
	Values(1,3,1,80);
INSERT INTO ProductsIngredients
	Values(1,4,1,20);
INSERT INTO ProductsIngredients
	Values(1,5,1,50);

INSERT INTO Products
	Values (2,'Greek Salad','tomatoes, cucumbers, peppers, white cheese, onion, olives, olive oil, oregano',2,8.2,350,1);
INSERT INTO ProductsIngredients
	Values(2,1,1,80);
INSERT INTO ProductsIngredients
	Values(2,2,1,80);
INSERT INTO ProductsIngredients
	Values(2,3,1,80);
INSERT INTO ProductsIngredients
	Values(2,4,1,20);
INSERT INTO ProductsIngredients
	Values(2,5,1,50);
INSERT INTO ProductsIngredients
	Values(2,11,1,20);
INSERT INTO ProductsIngredients
	Values(2,8,2,10);
INSERT INTO ProductsIngredients
	Values(2,30,1,10);

INSERT INTO Products
	Values (3,'Caprese','tomatoes, mozzarella, basil, olive oil',2,9,290,1);
INSERT INTO ProductsIngredients
	Values(3,1,2,200);
INSERT INTO ProductsIngredients
	Values(3,45,1,60);
INSERT INTO ProductsIngredients
	Values(3,30,2,20);
INSERT INTO ProductsIngredients
	Values(3,31,1,10);

INSERT INTO Products
	Values (4,'Caesar','lettuce, crispy chicken, cheese, Caesar souce',2,11,290,1);
INSERT INTO ProductsIngredients
	Values(4,22,1,150);
INSERT INTO ProductsIngredients
	Values(4,12,1,80);
INSERT INTO ProductsIngredients
	Values(4,7,1,40);
INSERT INTO ProductsIngredients
	Values(4,47,2,20);
INSERT INTO ProductsIngredients
	Values(4,46,3,15);


INSERT INTO Products
	Values (5,'Home Salad','tomatoes, roasted peppers,white cheese, onion, parsley',2,9.5,300,1);
INSERT INTO ProductsIngredients
	Values(5,1,1,150);
INSERT INTO ProductsIngredients
	Values(5,3,1,90);
INSERT INTO ProductsIngredients
	Values(5,5,1,40);
INSERT INTO ProductsIngredients
	Values(5,4,1,10);
INSERT INTO ProductsIngredients
	Values(5,33,1,10);


INSERT INTO Products
	Values (6,'Chicken Soup','chicken, peppers, potatoes, carrots, onion, parsley',9,4.5,350,2);
INSERT INTO ProductsIngredients
	Values(6,12,1,50);
INSERT INTO ProductsIngredients
	Values(6,3,1,20);
INSERT INTO ProductsIngredients
	Values(6,48,1,50);
INSERT INTO ProductsIngredients
	Values(6,49,1,20);
INSERT INTO ProductsIngredients
	Values(6,4,1,20);
INSERT INTO ProductsIngredients
	Values(6,33,1,20);

INSERT INTO Products
	Values (7,'Spinach Cream Soup','spinach, onion, cream, carrots, parsley',9,4.5,300,2);
INSERT INTO ProductsIngredients
	Values(7,38,1,150);
INSERT INTO ProductsIngredients
	Values(7,4,1,30);
INSERT INTO ProductsIngredients
	Values(7,50,2,30);
INSERT INTO ProductsIngredients
	Values(7,49,1,30);
INSERT INTO ProductsIngredients
	Values(7,33,1,10);

INSERT INTO Products
	Values (8,'Homemade Chips','potatoes',3,4,200,1);
INSERT INTO ProductsIngredients
	Values(8,48,1,200);
INSERT INTO ProductsIngredients
	Values(8,9,2,80);

INSERT INTO Products
	Values (13,'Homemade Courgette','courgette',3,4,200,1);
INSERT INTO ProductsIngredients
	Values(13,20,1,200);
INSERT INTO ProductsIngredients
	Values(13,9,2,80);

INSERT INTO Products
	Values (9,'Edamame','edamame',3,3.5,200,1);
INSERT INTO ProductsIngredients
	Values(9,43,1,200);

INSERT INTO Products
	Values (10,'Tagliatelle Frutti Di Mare','tagliatelle, shrims, squids, octopus, olive oil',4,12.8,320,1);
INSERT INTO ProductsIngredients
	Values(10,52,1,200);
INSERT INTO ProductsIngredients
	Values(10,21,1,50);
INSERT INTO ProductsIngredients
	Values(10,28,1,30);
INSERT INTO ProductsIngredients
	Values(10,29,1,30);
INSERT INTO ProductsIngredients
	Values(10,8,2,10);

INSERT INTO Products
	Values (11,'Spaghetti bolognese','spaghetti, tomato souce, minced beef, cheese',4,12,320,1);
INSERT INTO ProductsIngredients
	Values(11,52,1,200);
INSERT INTO ProductsIngredients
	Values(11,27,2,40);
INSERT INTO ProductsIngredients
	Values(11,13,1,60);
INSERT INTO ProductsIngredients
	Values(11,7,1,20);

INSERT INTO Products
	Values (12,'Risotto with vegetables','rice, mushrooms, courgettes, carrots, parmesan',4,11,360,1);
INSERT INTO ProductsIngredients
	Values(12,53,1,220);
INSERT INTO ProductsIngredients
	Values(12,6,1,40);
INSERT INTO ProductsIngredients
	Values(12,49,1,40);
INSERT INTO ProductsIngredients
	Values(12,20,1,40);
INSERT INTO ProductsIngredients
	Values(12,54,1,20);


INSERT INTO Products
	Values (14,'Coca-Cola','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(14,58,3,1);

INSERT INTO Products
	Values (15,'Sprite','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(15,59,3,1);

INSERT INTO Products
	Values (16,'Fanta Orange','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(16,60,3,1);

INSERT INTO Products
	Values (17,'Fanta Lemon','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(17,61,3,1);

INSERT INTO Products
	Values (18,'Small Vodka Beluga','',8,5,50,2);
INSERT INTO ProductsIngredients
	Values(18,64,1,50);

INSERT INTO Products
	Values (19,'Large Vodka Beluga','',8,10,100,2);
INSERT INTO ProductsIngredients
	Values(19,64,1,100);

INSERT INTO Products
	Values (20,'Small Vodka Ciroc','',8,6,50,2);
INSERT INTO ProductsIngredients
	Values(20,65,1,50);

INSERT INTO Products
	Values (21,'Large Vodka Ciroc','',8,12,100,2);
INSERT INTO ProductsIngredients
	Values(21,65,1,100);

INSERT INTO Products
	Values (22,'Beer Heineken','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(22,62,3,1);

INSERT INTO Products
	Values (23,'Beer Staropramen','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(23,63,3,1);

INSERT INTO Products
	Values (24,'Coffee Lavazza','',8,1,40,2);
INSERT INTO ProductsIngredients
	Values(24,68,1,20);

INSERT INTO Products
	Values (25,'Coffee Bianci','',8,1.2,40,2);
INSERT INTO ProductsIngredients
	Values(25,69,1,20);


INSERT INTO Products
	Values (26,'Apple Juice','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(26,70,3,1);


INSERT INTO Products
	Values (27,'Orange juice','',8,2.5,1,3);
INSERT INTO ProductsIngredients
	Values(27,71,3,1);

INSERT INTO Products
	Values (28,'Homemade Biscuit cake','buscuits, milk', 7, 3.5, 150,1);
INSERT INTO ProductsIngredients
	Values(28,55,2,30);
INSERT INTO ProductsIngredients
	Values(28,56,3,15);

INSERT INTO Products
	Values (29,'Ice-cream','', 7, 4.5, 100,2);
INSERT INTO ProductsIngredients
	Values(29,72,2,100);

INSERT INTO Products
	Values (30,'Shardone Frutino','',8,10,1,3);
INSERT INTO ProductsIngredients
	Values(30,73,3,1);

INSERT INTO Products
	Values (31,'Rose Frutino','',8,12,1,3);
INSERT INTO ProductsIngredients
	Values(31,74,3,1);

INSERT INTO Products
	Values (32,'Syra Frutino','',8,12,1,3);
INSERT INTO ProductsIngredients
	Values(32,75,3,1);

INSERT INTO Products
	Values (33,'Shardone Verano Azur','',8,10.5,1,3);
INSERT INTO ProductsIngredients
	Values(33,76,3,1);

INSERT INTO Products
	Values (34,'Rose Verano Azur','',8,12.5,1,3);
INSERT INTO ProductsIngredients
	Values(34,77,3,1);

INSERT INTO Products
	Values (35,'Syra Verano Azur','',8,12.5,1,3);
INSERT INTO ProductsIngredients
	Values(35,78,3,1);

INSERT INTO Products
	Values(36,'Summer Greek','roaster white cheese,roasted pepper, roasted egg plant, tomatoes, onion, parsley',2, 8.5, 350, 1);
INSERT INTO ProductsIngredients
	Values(36,5,1,40);
INSERT INTO ProductsIngredients
	Values(36,32,1,120);
INSERT INTO ProductsIngredients
	Values(36,3,1,100);
INSERT INTO ProductsIngredients
	Values(36,1,1,80);
INSERT INTO ProductsIngredients
	Values(36,33,1,10);

INSERT INTO Products
	Values(37,'Krit','tomatoes, olives, croutons, white cheese, capers, basil',2, 9.5, 250, 1);
INSERT INTO ProductsIngredients
	Values(37,11,1,40);
INSERT INTO ProductsIngredients
	Values(37,46,3,20);
INSERT INTO ProductsIngredients
	Values(37,5,1,100);
INSERT INTO ProductsIngredients
	Values(37,1,1,80);
INSERT INTO ProductsIngredients
	Values(37,79,1,10);

INSERT INTO Products
	Values(38,'Greek Meatballs','minced beef, fried potatoes',1, 7, 250, 1);
INSERT INTO ProductsIngredients
	Values(38,13,1,160);
INSERT INTO ProductsIngredients
	Values(38,48,1,90);

INSERT INTO Products
	Values(39,'Meatballs With RoastedVegetables','minced beef, roasted potatoes, roasted cougette, roasted carrots',1, 7, 250, 1);
INSERT INTO ProductsIngredients
	Values(39,13,1,160);
INSERT INTO ProductsIngredients
	Values(39,48,1,30);
INSERT INTO ProductsIngredients
	Values(39,49,1,30);
INSERT INTO ProductsIngredients
	Values(39,20,1,30);

INSERT INTO Products
	Values(40,'Chicken Kavarma','chicken, potatoes, cougette, carrots, onion',1, 11, 300, 1);
INSERT INTO ProductsIngredients
	Values(40,13,1,160);
INSERT INTO ProductsIngredients
	Values(40,48,1,40);
INSERT INTO ProductsIngredients
	Values(40,49,1,40);
INSERT INTO ProductsIngredients
	Values(40,20,1,40);
INSERT INTO ProductsIngredients
	Values(40,4,1,20);

INSERT INTO Products
	Values(41,'Roasted laurel with roasted potatoes','laurel,roastet potatoes',1, 15, 260, 1);
INSERT INTO ProductsIngredients
	Values(41,17,1,220);
INSERT INTO ProductsIngredients
	Values(41,48,1,40);

INSERT INTO Products
	Values(42,'Fried Gavros','',1, 9, 260, 1);
INSERT INTO ProductsIngredients
	Values(42,34,1,220);

INSERT INTO Products
	Values(43,'Fried Scad','',1, 8.5, 260, 1);
INSERT INTO ProductsIngredients
	Values(43,35,1,220);

INSERT INTO Products
	Values(44,'Crispy squids and shrimps','',1, 12.5, 250, 1);
INSERT INTO ProductsIngredients
	Values(44,21,1,150);
INSERT INTO ProductsIngredients
	Values(44,28,1,150);

INSERT INTO Products
	Values(45,'Fish Soup','sea bream, laurel, courgette, carrots, shrims, parsley',9, 4.5, 250, 1);
INSERT INTO ProductsIngredients
	Values(45,18,1,40);
INSERT INTO ProductsIngredients
	Values(45,17,1,40);
INSERT INTO ProductsIngredients
	Values(45,21,1,40);
INSERT INTO ProductsIngredients
	Values(45,20,1,40);
INSERT INTO ProductsIngredients
	Values(45,49,1,40);
INSERT INTO ProductsIngredients
	Values(45,33,1,40);

INSERT INTO Products
	Values(46,'Chicken Suvlaki','chicken, Greek pita bread,tomatoes, cucumbers, tzatziki',1, 10, 340, 1);
INSERT INTO ProductsIngredients
	Values(46,12,1,180);
INSERT INTO ProductsIngredients
	Values(46,80,3,1);
INSERT INTO ProductsIngredients
	Values(46,81,1,40);
INSERT INTO ProductsIngredients
	Values(46,1,1,40);
INSERT INTO ProductsIngredients
	Values(46,2,1,40);

INSERT INTO Products
	Values(47,'Pork Suvlaki','pork, Greek pita bread,tomatoes, cucumbers, tzatziki',1, 12.5, 340, 1);
INSERT INTO ProductsIngredients
	Values(47,14,1,180);
INSERT INTO ProductsIngredients
	Values(47,80,3,1);
INSERT INTO ProductsIngredients
	Values(47,81,1,40);
INSERT INTO ProductsIngredients
	Values(47,1,1,40);
INSERT INTO ProductsIngredients
	Values(47,2,1,40);

INSERT INTO Products
	Values(48,'Yoghurt with honey and walnuts','Greek yoghurt, honey, walnuts',7, 4.5, 180, 1);
INSERT INTO ProductsIngredients
	Values(48,82,1,150);
INSERT INTO ProductsIngredients
	Values(48,83,1,15);
INSERT INTO ProductsIngredients
	Values(48,84,1,15);

INSERT INTO Products
	Values(49,'Salad Sardinya','lettuce, tuna, arugula, red beans, olives',2, 7.5, 310, 1);
INSERT INTO ProductsIngredients
	Values(49,22,1,150);
INSERT INTO ProductsIngredients
	Values(49,16,1,40);
INSERT INTO ProductsIngredients
	Values(49,40,1,40);
INSERT INTO ProductsIngredients
	Values(49,24,1,40);
INSERT INTO ProductsIngredients
	Values(49,11,1,20);

INSERT INTO Products
	Values(50,'Polo E Pasta','iceberd-salad, arugula, egg, olives, croutons, tagliatelle, roasted chicken',2, 11.5, 300, 1);
INSERT INTO ProductsIngredients
	Values(50,23,1,120);
INSERT INTO ProductsIngredients
	Values(50,24,1,40);
INSERT INTO ProductsIngredients
	Values(50,85,3,1);
INSERT INTO ProductsIngredients
	Values(50,11,1,20);
INSERT INTO ProductsIngredients
	Values(50,46,3,15);
INSERT INTO ProductsIngredients
	Values(50,51,1,50);
INSERT INTO ProductsIngredients
	Values(50,12,1,60);

INSERT INTO Products
	Values(51,'Homemade meatballs with chicken and broccoli','',3, 10.5, 250, 1);
INSERT INTO ProductsIngredients
	Values(51,12,1,170);
INSERT INTO ProductsIngredients
	Values(51,41,1,80);

INSERT INTO Products
	Values(52,'Italian Roasted vegetables','potatoes, courgette, mushrooms, carrots, capers, parmesan',3, 9.5, 260, 1);
INSERT INTO ProductsIngredients
	Values(52,48,1,60);
INSERT INTO ProductsIngredients
	Values(52,20,1,60);
INSERT INTO ProductsIngredients
	Values(52,6,1,40);
INSERT INTO ProductsIngredients
	Values(52,49,1,60);
INSERT INTO ProductsIngredients
	Values(52,79,1,20);
INSERT INTO ProductsIngredients
	Values(52,54,1,20);

INSERT INTO Products
	Values(53,'Tagliatelle Carbonara','tagliatelles, bacon, cream, egg, parmesan, parsley',4, 9.5, 310, 1);
INSERT INTO ProductsIngredients
	Values(53,51,1,150);
INSERT INTO ProductsIngredients
	Values(53,50,2,50);
INSERT INTO ProductsIngredients
	Values(53,42,1,60);
INSERT INTO ProductsIngredients
	Values(53,85,3,1);
INSERT INTO ProductsIngredients
	Values(53,33,1,10);
INSERT INTO ProductsIngredients
	Values(53,54,1,20);

INSERT INTO Products
	Values(54,'Risoto with beef','rice, beef, mushrooms, cream, parmesan, parsley',4, 11.5, 330, 1);
INSERT INTO ProductsIngredients
	Values(54,53,1,150);
INSERT INTO ProductsIngredients
	Values(54,13,1,80);
INSERT INTO ProductsIngredients
	Values(54,6,1,40);
INSERT INTO ProductsIngredients
	Values(54,50,2,30);
INSERT INTO ProductsIngredients
	Values(54,33,1,10);
INSERT INTO ProductsIngredients
	Values(54,54,1,20);


INSERT INTO Products
	Values(55,'Margaritha','dough, tomato souce, mozzarella, basil',5, 10.5, 330, 1);
INSERT INTO ProductsIngredients
	Values(55,57,1,200);
INSERT INTO ProductsIngredients
	Values(55,27,2,30);
INSERT INTO ProductsIngredients
	Values(55,45,1,40);
INSERT INTO ProductsIngredients
	Values(55,21,1,10);

INSERT INTO Products
	Values(56,'Chef Pizza','dough, beef, bacon, mushrooms, mozzarella, basil',5, 12.5, 400, 1);
INSERT INTO ProductsIngredients
	Values(56,57,1,200);
INSERT INTO ProductsIngredients
	Values(56,13,1,80);
INSERT INTO ProductsIngredients
	Values(56,42,1,40);
INSERT INTO ProductsIngredients
	Values(56,6,1,30);
INSERT INTO ProductsIngredients
	Values(56,45,1,40);
INSERT INTO ProductsIngredients
	Values(56,21,1,10);

INSERT INTO Products
	Values(57,'Pollo','dough, chicken, red beans, egg, mozzarella, corn',5, 11.5, 400, 1);
INSERT INTO ProductsIngredients
	Values(57,57,1,200);
INSERT INTO ProductsIngredients
	Values(57,12,1,80);
INSERT INTO ProductsIngredients
	Values(57,40,1,40);
INSERT INTO ProductsIngredients
	Values(57,85,3,1);
INSERT INTO ProductsIngredients
	Values(57,45,1,40);
INSERT INTO ProductsIngredients
	Values(57,19,1,40);

INSERT INTO Products
	Values(58,'Tomato soup','tomatoe souce, cream, mozzarella, basil, croutons',9, 5.5, 300, 2);
INSERT INTO ProductsIngredients
	Values(58,27,1,200);
INSERT INTO ProductsIngredients
	Values(58,50,1,40);
INSERT INTO ProductsIngredients
	Values(58,45,1,40);
INSERT INTO ProductsIngredients
	Values(58,31,1,10);
INSERT INTO ProductsIngredients
	Values(58,46,3,15);

INSERT INTO Products
	Values(59,'Paradise Cream','eggs, ice-cream, sugar, biscuits, cream',7, 5.5, 250, 1);
INSERT INTO ProductsIngredients
	Values(59,85,3,1);
INSERT INTO ProductsIngredients
	Values(59,72,2,100);
INSERT INTO ProductsIngredients
	Values(59,86,1,40);
INSERT INTO ProductsIngredients
	Values(59,56,1,40);
INSERT INTO ProductsIngredients
	Values(59,50,2,40);

INSERT INTO Products
	Values(60,'Water','',8, 1.5, 1, 3);

INSERT INTO Products
	Values (61,'Small Jack Whiskey','',8,6,50,2);
INSERT INTO ProductsIngredients
	Values(61,66,1,50);

INSERT INTO Products
	Values (62,'Large Jack Whiskey','',8,12,100,2);
INSERT INTO ProductsIngredients
	Values(62,66,1,100);

INSERT INTO Products
	Values (63,'Small Johny Whiskey','',8,5,50,2);
INSERT INTO ProductsIngredients
	Values(63,67,1,50);

INSERT INTO Products
	Values (64,'Large Johny Whiskey','',8,10,100,2);
INSERT INTO ProductsIngredients
	Values(64,67,1,100);




INSERT INTO Menus
	Values(1,'Drinks',1);
INSERT INTO MenusProducts
	Values(1,14);
INSERT INTO MenusProducts
	Values(1,15);
INSERT INTO MenusProducts
	Values(1,16);
INSERT INTO MenusProducts
	Values(1,17);
INSERT INTO MenusProducts
	Values(1,18);
INSERT INTO MenusProducts
	Values(1,19);
INSERT INTO MenusProducts
	Values(1,20);
INSERT INTO MenusProducts
	Values(1,21);
INSERT INTO MenusProducts
	Values(1,22);
INSERT INTO MenusProducts
	Values(1,23);
INSERT INTO MenusProducts
	Values(1,24);
INSERT INTO MenusProducts
	Values(1,25);
INSERT INTO MenusProducts
	Values(1,26);
INSERT INTO MenusProducts
	Values(1,27);
INSERT INTO MenusProducts
	Values(1,30);
INSERT INTO MenusProducts
	Values(1,31);
INSERT INTO MenusProducts
	Values(1,32);
INSERT INTO MenusProducts
	Values(1,33);
INSERT INTO MenusProducts
	Values(1,34);
INSERT INTO MenusProducts
	Values(1,35);
INSERT INTO MenusProducts
	Values(1,60);

INSERT INTO Menus
	Values(2,'Main',1);
INSERT INTO MenusProducts
	Values(2,1);
INSERT INTO MenusProducts
	Values(2,2);
INSERT INTO MenusProducts
	Values(2,3);
INSERT INTO MenusProducts
	Values(2,4);
INSERT INTO MenusProducts
	Values(2,5);
INSERT INTO MenusProducts
	Values(2,6);
INSERT INTO MenusProducts
	Values(2,7);
INSERT INTO MenusProducts
	Values(2,8);
INSERT INTO MenusProducts
	Values(2,9);
INSERT INTO MenusProducts
	Values(2,10);
INSERT INTO MenusProducts
	Values(2,11);
INSERT INTO MenusProducts
	Values(2,12);
INSERT INTO MenusProducts
	Values(2,13);
INSERT INTO MenusProducts
	Values(2,28);
INSERT INTO MenusProducts
	Values(2,29);
INSERT INTO MenusProducts
	Values(2,39);
INSERT INTO MenusProducts
	Values(2,40);
INSERT INTO MenusProducts
	Values(2,41);

INSERT INTO Menus
	Values(3,'Greek',1);
INSERT INTO MenusProducts
	Values(3,2);
INSERT INTO MenusProducts
	Values(3,9);
INSERT INTO MenusProducts
	Values(3,13);
INSERT INTO MenusProducts
	Values(3,36);
INSERT INTO MenusProducts
	Values(3,37);
INSERT INTO MenusProducts
	Values(3,38);
INSERT INTO MenusProducts
	Values(3,41);
INSERT INTO MenusProducts
	Values(3,42);
INSERT INTO MenusProducts
	Values(3,43);
INSERT INTO MenusProducts
	Values(3,44);
INSERT INTO MenusProducts
	Values(3,45);
INSERT INTO MenusProducts
	Values(3,46);
INSERT INTO MenusProducts
	Values(3,47);
INSERT INTO MenusProducts
	Values(3,48);

INSERT INTO Menus
	Values(4,'Italian',0);
INSERT INTO MenusProducts
	Values(4,49);
INSERT INTO MenusProducts
	Values(4,50);
INSERT INTO MenusProducts
	Values(4,51);
INSERT INTO MenusProducts
	Values(4,52);
INSERT INTO MenusProducts
	Values(4,53);
INSERT INTO MenusProducts
	Values(4,54);
INSERT INTO MenusProducts
	Values(4,55);
INSERT INTO MenusProducts
	Values(4,56);
INSERT INTO MenusProducts
	Values(4,57);
INSERT INTO MenusProducts
	Values(4,58);
INSERT INTO MenusProducts
	Values(4,59);
INSERT INTO MenusProducts
	Values(4,10);
INSERT INTO MenusProducts
	Values(4,11);
INSERT INTO MenusProducts
	Values(4,12);


INSERT INTO Orders
	Values(1,'2020-4-10');
INSERT INTO OrdersProducts
	Values(1,1,1);
INSERT INTO OrdersProducts
	Values(1,3,1);
INSERT INTO OrdersProducts
	Values(1,6,1);
INSERT INTO OrdersProducts
	Values(1,11,1);
INSERT INTO OrdersProducts
	Values(1,14,2);

INSERT INTO Orders
	Values(2,'2020-4-10');
INSERT INTO OrdersProducts
	Values(2,2,1);
INSERT INTO OrdersProducts
	Values(2,49,1);
INSERT INTO OrdersProducts
	Values(2,53,1);
INSERT INTO OrdersProducts
	Values(2,54,1);
INSERT INTO OrdersProducts
	Values(2,31,1);

INSERT INTO Orders
	Values(3,'2020-4-11');
INSERT INTO OrdersProducts
	Values(3,50,2);
INSERT INTO OrdersProducts
	Values(3,12,1);
INSERT INTO OrdersProducts
	Values(3,10,1);
INSERT INTO OrdersProducts
	Values(3,35,1);

INSERT INTO Orders
	Values(4,'2020-4-17');
INSERT INTO OrdersProducts
	Values(4,2,1);
INSERT INTO OrdersProducts
	Values(4,3,1);
INSERT INTO OrdersProducts
	Values(4,49,1);
INSERT INTO OrdersProducts
	Values(4,51,1);
INSERT INTO OrdersProducts
	Values(4,55,1);
INSERT INTO OrdersProducts
	Values(4,59,1);
INSERT INTO OrdersProducts
	Values(4,14,1);
INSERT INTO OrdersProducts
	Values(4,15,1);


INSERT INTO Orders
	Values(5,'2020-4-18');
INSERT INTO OrdersProducts
	Values(5,55,1);
INSERT INTO OrdersProducts
	Values(5,56,1);
INSERT INTO OrdersProducts
	Values(5,58,1);
INSERT INTO OrdersProducts
	Values(5,28,1);
INSERT INTO OrdersProducts
	Values(5,29,1);
INSERT INTO OrdersProducts
	Values(5,22,1);
INSERT INTO OrdersProducts
	Values(5,23,1);


INSERT INTO Orders
	Values(6,'2020-4-18');
INSERT INTO OrdersProducts
	Values(6,8,2);
INSERT INTO OrdersProducts
	Values(6,56,1);
INSERT INTO OrdersProducts
	Values(6,22,2);
INSERT INTO OrdersProducts
	Values(6,23,2);

INSERT INTO Orders
	Values(7,'2020-4-19');
INSERT INTO OrdersProducts
	Values(7,24,1);
INSERT INTO OrdersProducts
	Values(7,25,1);
INSERT INTO OrdersProducts
	Values(7,14,2);
INSERT INTO OrdersProducts
	Values(7,28,2);

INSERT INTO Orders
	Values(8,'2020-4-21');
INSERT INTO OrdersProducts
	Values(8,50,1);
INSERT INTO OrdersProducts
	Values(8,58,1);
INSERT INTO OrdersProducts
	Values(8,56,2);
INSERT INTO OrdersProducts
	Values(8,59,2);
INSERT INTO OrdersProducts
	Values(8,33,1);
INSERT INTO OrdersProducts
	Values(8,60,2);

INSERT INTO Orders
	Values(9,'2020-4-22');
INSERT INTO OrdersProducts
	Values(9,26,1);
INSERT INTO OrdersProducts
	Values(9,27,1);
INSERT INTO OrdersProducts
	Values(9,53,1);
INSERT INTO OrdersProducts
	Values(9,54,1);
INSERT INTO OrdersProducts
	Values(9,28,1);
INSERT INTO OrdersProducts
	Values(9,59,2);

INSERT INTO Orders
	Values(10,'2020-4-25');
INSERT INTO OrdersProducts
	Values(10,57,1);
INSERT INTO OrdersProducts
	Values(10,52,1);
INSERT INTO OrdersProducts
	Values(10,49,1);
INSERT INTO OrdersProducts
	Values(10,19,1);
INSERT INTO OrdersProducts
	Values(10,21,1);
INSERT INTO OrdersProducts
	Values(10,27,2);


INSERT INTO Orders
	Values(11,'2020-4-26');
INSERT INTO OrdersProducts
	Values(11,3,2);
INSERT INTO OrdersProducts
	Values(11,14,2);
INSERT INTO OrdersProducts
	Values(11,50,1);
INSERT INTO OrdersProducts
	Values(11,51,1);
INSERT INTO OrdersProducts
	Values(11,55,1);
INSERT INTO OrdersProducts
	Values(11,58,2);
INSERT INTO OrdersProducts
	Values(11,54,1);
INSERT INTO OrdersProducts
	Values(11,53,2);
INSERT INTO OrdersProducts
	Values(11,59,2);
INSERT INTO OrdersProducts
	Values(11,60,2);
INSERT INTO OrdersProducts
	Values(11,35,1);
INSERT INTO OrdersProducts
	Values(11,25,2);

INSERT INTO Orders
	Values(12,'2020-4-28');
INSERT INTO OrdersProducts
	Values(12,39,1);
INSERT INTO OrdersProducts
	Values(12,6,2);
INSERT INTO OrdersProducts
	Values(12,23,4);
INSERT INTO OrdersProducts
	Values(12,8,2);
INSERT INTO OrdersProducts
	Values(12,28,2);
INSERT INTO OrdersProducts
	Values(12,60,2);

INSERT INTO Orders
	Values(13,'2020-4-29');
INSERT INTO OrdersProducts
	Values(13,2,2);
INSERT INTO OrdersProducts
	Values(13,42,2);
INSERT INTO OrdersProducts
	Values(13,43,1);
INSERT INTO OrdersProducts
	Values(13,23,2);
INSERT INTO OrdersProducts
	Values(13,22,2);
INSERT INTO OrdersProducts
	Values(13,60,2);

INSERT INTO Orders
	Values(14,'2020-4-29');
INSERT INTO OrdersProducts
	Values(14,38,1);
INSERT INTO OrdersProducts
	Values(14,37,1);
INSERT INTO OrdersProducts
	Values(14,36,1);
INSERT INTO OrdersProducts
	Values(14,45,2);
INSERT INTO OrdersProducts
	Values(14,60,2);

INSERT INTO Orders
	Values(15,'2020-4-30');
INSERT INTO OrdersProducts
	Values(15,24,2);
INSERT INTO OrdersProducts
	Values(15,28,2);
INSERT INTO OrdersProducts
	Values(15,60,2);

INSERT INTO Orders
	Values(16,'2020-4-30');
INSERT INTO OrdersProducts
	Values(16,38,1);
INSERT INTO OrdersProducts
	Values(16,37,2);
INSERT INTO OrdersProducts
	Values(16,8,1);
INSERT INTO OrdersProducts
	Values(16,22,1);
INSERT INTO OrdersProducts
	Values(16,23,1);

INSERT INTO Orders
	Values(17,'2020-5-1');
INSERT INTO OrdersProducts
	Values(17,44,2);
INSERT INTO OrdersProducts
	Values(17,33,1);
INSERT INTO OrdersProducts
	Values(17,60,2);
INSERT INTO OrdersProducts
	Values(17,48,2);

INSERT INTO Orders
	Values(18,'2020-5-2');
INSERT INTO OrdersProducts
	Values(18,40,1);
INSERT INTO OrdersProducts
	Values(18,42,1);
INSERT INTO OrdersProducts
	Values(18,5,1);
INSERT INTO OrdersProducts
	Values(18,26,1);
INSERT INTO OrdersProducts
	Values(18,14,1);

INSERT INTO Orders
	Values(19,'2020-5-2');
INSERT INTO OrdersProducts
	Values(19,11,2);
INSERT INTO OrdersProducts
	Values(19,8,1);
INSERT INTO OrdersProducts
	Values(19,38,1);
INSERT INTO OrdersProducts
	Values(19,41,1);
INSERT INTO OrdersProducts
	Values(19,42,1);
INSERT INTO OrdersProducts
	Values(19,45,2);
INSERT INTO OrdersProducts
	Values(19,60,4);
INSERT INTO OrdersProducts
	Values(19,28,1);
INSERT INTO OrdersProducts
	Values(19,29,1);
INSERT INTO OrdersProducts
	Values(19,46,1);
INSERT INTO OrdersProducts
	Values(19,47,1);
INSERT INTO OrdersProducts
	Values(19,48,2);

INSERT INTO Orders
	Values(20,'2020-5-3');
INSERT INTO OrdersProducts
	Values(20,30,1);
INSERT INTO OrdersProducts
	Values(20,7,2);
INSERT INTO OrdersProducts
	Values(20,4,1);
INSERT INTO OrdersProducts
	Values(20,46,1);
INSERT INTO OrdersProducts
	Values(20,48,2);


INSERT INTO Orders
	Values(21,'2020-5-3');
INSERT INTO OrdersProducts
	Values(21,12,1);
INSERT INTO OrdersProducts
	Values(21,9,2);
INSERT INTO OrdersProducts
	Values(21,16,1);
INSERT INTO OrdersProducts
	Values(21,17,1);
INSERT INTO OrdersProducts
	Values(21,18,2);
INSERT INTO OrdersProducts
	Values(21,10,1);

INSERT INTO Orders
	Values(22,'2020-5-4');
INSERT INTO OrdersProducts
	Values(22,19,2);
INSERT INTO OrdersProducts
	Values(22,21,2);
INSERT INTO OrdersProducts
	Values(22,18,1);
INSERT INTO OrdersProducts
	Values(22,20,1);
INSERT INTO OrdersProducts
	Values(22,27,6);
INSERT INTO OrdersProducts
	Values(22,41,2);

INSERT INTO Orders
	Values(23,'2020-5-4');
INSERT INTO OrdersProducts
	Values(23,42,2);
INSERT INTO OrdersProducts
	Values(23,43,2);
INSERT INTO OrdersProducts
	Values(23,38,1);
INSERT INTO OrdersProducts
	Values(23,22,6);
INSERT INTO OrdersProducts
	Values(23,47,1);
INSERT INTO OrdersProducts
	Values(23,46,1);

INSERT INTO Orders
	Values(24,'2020-5-5');
INSERT INTO OrdersProducts
	Values(24,40,1);
INSERT INTO OrdersProducts
	Values(24,41,1);
INSERT INTO OrdersProducts
	Values(24,36,2);
INSERT INTO OrdersProducts
	Values(24,48,2);
INSERT INTO OrdersProducts
	Values(24,44,1);
INSERT INTO OrdersProducts
	Values(24,21,1);
INSERT INTO OrdersProducts
	Values(24,60,4);

INSERT INTO Orders
	Values(25,'2020-5-5');
INSERT INTO OrdersProducts
	Values(25,45,2);
INSERT INTO OrdersProducts
	Values(25,23,2);
INSERT INTO OrdersProducts
	Values(25,9,1);
INSERT INTO OrdersProducts
	Values(25,5,1);
INSERT INTO OrdersProducts
	Values(25,13,1);
INSERT INTO OrdersProducts
	Values(25,22,2);
INSERT INTO OrdersProducts
	Values(25,47,2);

INSERT INTO Orders
	Values(26,'2020-5-5');
INSERT INTO OrdersProducts
	Values(26,4,2);
INSERT INTO OrdersProducts
	Values(26,41,1);
INSERT INTO OrdersProducts
	Values(26,11,1);
INSERT INTO OrdersProducts
	Values(26,16,1);
INSERT INTO OrdersProducts
	Values(26,17,1);
INSERT INTO OrdersProducts
	Values(26,29,2);

INSERT INTO Orders
	Values(27,'2020-5-6');
INSERT INTO OrdersProducts
	Values(27,9,2);
INSERT INTO OrdersProducts
	Values(27,2,1);
INSERT INTO OrdersProducts
	Values(27,36,1);
INSERT INTO OrdersProducts
	Values(27,37,1);
INSERT INTO OrdersProducts
	Values(27,5,1);
INSERT INTO OrdersProducts
	Values(27,38,1);
INSERT INTO OrdersProducts
	Values(27,13,1);
INSERT INTO OrdersProducts
	Values(27,41,1);
INSERT INTO OrdersProducts
	Values(27,42,1);
INSERT INTO OrdersProducts
	Values(27,43,1);
INSERT INTO OrdersProducts
	Values(27,47,1);
INSERT INTO OrdersProducts
	Values(27,48,2);
INSERT INTO OrdersProducts
	Values(27,35,1);
INSERT INTO OrdersProducts
	Values(27,60,2);

INSERT INTO Orders
	Values(28,'2020-5-6');
INSERT INTO OrdersProducts
	Values(28,7,2);
INSERT INTO OrdersProducts
	Values(28,3,2);
INSERT INTO OrdersProducts
	Values(28,43,1);
INSERT INTO OrdersProducts
	Values(28,45,1);
INSERT INTO OrdersProducts
	Values(28,28,2);
INSERT INTO OrdersProducts
	Values(28,23,1);
INSERT INTO OrdersProducts
	Values(28,15,2);
INSERT INTO OrdersProducts
	Values(28,24,1);

INSERT INTO Orders
	Values(29,'2020-5-6');
INSERT INTO OrdersProducts
	Values(29,26,2);
INSERT INTO OrdersProducts
	Values(29,59,2);
INSERT INTO OrdersProducts
	Values(29,13,1);
INSERT INTO OrdersProducts
	Values(29,37,1);
INSERT INTO OrdersProducts
	Values(29,39,1);
INSERT INTO OrdersProducts
	Values(29,46,1);


INSERT INTO Orders
	Values(30,'2020-5-7');
INSERT INTO OrdersProducts
	Values(30,12,1);
INSERT INTO OrdersProducts
	Values(30,9,1);
INSERT INTO OrdersProducts
	Values(30,5,1);
INSERT INTO OrdersProducts
	Values(30,19,1);
INSERT INTO OrdersProducts
	Values(30,27,1);
INSERT INTO OrdersProducts
	Values(30,38,1);
INSERT INTO OrdersProducts
	Values(30,48,3);
INSERT INTO OrdersProducts
	Values(30,43,1);
INSERT INTO OrdersProducts
	Values(30,60,2);

INSERT INTO Orders
	Values(31,'2020-5-7');
INSERT INTO OrdersProducts
	Values(31,10,1);
INSERT INTO OrdersProducts
	Values(31,11,1);
INSERT INTO OrdersProducts
	Values(31,4,1);
INSERT INTO OrdersProducts
	Values(31,3,1);
INSERT INTO OrdersProducts
	Values(31,6,1);
INSERT INTO OrdersProducts
	Values(31,28,1);
INSERT INTO OrdersProducts
	Values(31,29,3);
INSERT INTO OrdersProducts
	Values(31,60,3);

INSERT INTO Orders
	Values(32,'2020-5-7');
INSERT INTO OrdersProducts
	Values(32,6,2);
INSERT INTO OrdersProducts
	Values(32,39,2);
INSERT INTO OrdersProducts
	Values(32,23,1);
INSERT INTO OrdersProducts
	Values(32,22,1);
INSERT INTO OrdersProducts
	Values(32,28,2);
INSERT INTO OrdersProducts
	Values(32,60,2);

INSERT INTO Orders
	Values(33,'2020-5-7');
INSERT INTO OrdersProducts
	Values(33,7,1);
INSERT INTO OrdersProducts
	Values(33,45,1);
INSERT INTO OrdersProducts
	Values(33,36,1);
INSERT INTO OrdersProducts
	Values(33,37,1);
INSERT INTO OrdersProducts
	Values(33,2,1);
INSERT INTO OrdersProducts
	Values(33,1,1);
INSERT INTO OrdersProducts
	Values(33,13,2);
INSERT INTO OrdersProducts
	Values(33,23,2);
INSERT INTO OrdersProducts
	Values(33,26,1);
INSERT INTO OrdersProducts
	Values(33,27,1);
INSERT INTO OrdersProducts
	Values(33,48,2);

INSERT INTO Orders
	Values(34,'2020-5-8');
INSERT INTO OrdersProducts
	Values(34,4,2);
INSERT INTO OrdersProducts
	Values(34,60,2);
INSERT INTO OrdersProducts
	Values(34,24,1);
INSERT INTO OrdersProducts
	Values(34,25,1);

INSERT INTO Orders
	Values(35,'2020-5-8');
INSERT INTO OrdersProducts
	Values(35,15,4);
INSERT INTO OrdersProducts
	Values(35,19,2);
INSERT INTO OrdersProducts
	Values(35,13,2);
INSERT INTO OrdersProducts
	Values(35,44,1);
INSERT INTO OrdersProducts
	Values(35,29,2);

INSERT INTO Orders
	Values(36,'2020-5-9');
INSERT INTO OrdersProducts
	Values(36,3,2);
INSERT INTO OrdersProducts
	Values(36,5,1);
INSERT INTO OrdersProducts
	Values(36,37,1);
INSERT INTO OrdersProducts
	Values(36,8,2);
INSERT INTO OrdersProducts
	Values(36,9,1);
INSERT INTO OrdersProducts
	Values(36,46,1);
INSERT INTO OrdersProducts
	Values(36,47,1);
INSERT INTO OrdersProducts
	Values(36,42,2);
INSERT INTO OrdersProducts
	Values(36,41,1);
INSERT INTO OrdersProducts
	Values(36,60,2);
INSERT INTO OrdersProducts
	Values(36,23,1);
INSERT INTO OrdersProducts
	Values(36,15,1);
INSERT INTO OrdersProducts
	Values(36,28,1);
INSERT INTO OrdersProducts
	Values(36,29,1);
INSERT INTO OrdersProducts
	Values(36,48,2);

--Indexes
CREATE iNDEX idx_Products
ON Products(Name);

CREATE INDEX idx_Ingredients
ON Ingredients(Name);

CREATE INDEX idx_Orders
ON Orders(Date);

--Views

/* View for active menus. */
GO
CREATE VIEW v_ActiveMenus
AS
SELECT *
FROM Menus
WHERE IsActive=1;
GO

Select Type
from v_ActiveMenus;

/* View for all product, which are in active menu. */
GO
CREATE VIEW v_ActiveProducts
AS
SELECT pr.Name, c.Name as TypeOfProduct, pr.Description, pr.Price, m.Type as TypeOfMenu
FROM Products pr 
JOIN MenusProducts mp ON pr.id=mp.ProductId 
JOIN Menus m ON mp.MenuId=m.Id 
JOIN Categories c ON pr.CategoryId=c.Id
WHERE m.IsActive=1;
GO

SELECT *
FROM v_ActiveProducts;

/* View for all ingredients in worehouse and their quantity. */
GO
CREATE VIEW v_Ingredients
AS
SELECT i.Name, i.Amount, ta.Name as TypeOfAmount
FROM Ingredients i JOIN TypesOfAmount ta ON i.AmountTypeId=ta.Id;
GO

SELECT *
FROM v_Ingredients
ORDER BY Name;

/* View for all orders and their sum bills by date.*/
GO
CREATE VIEW v_Number_Of_OrderProducts_per_Day
AS
SELECT o.Date, COUNT(Distinct o.Id) AS Orders,
SUM(op.ProductQuantity) AS NumberOrderProducts,
SUM(op.ProductQuantity*pr.Price) AS Bill
FROM Orders o
JOIN OrdersProducts op ON o.Id=op.OrderId
JOIN Products pr ON op.ProductId=pr.Id 
GROUP BY o.Date;
GO

SELECT *
FROM v_Number_Of_OrderProducts_per_Day;


