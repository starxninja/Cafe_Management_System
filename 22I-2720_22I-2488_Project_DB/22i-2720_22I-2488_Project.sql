                      ---Users
CREATE TABLE users (
    Id INT Primary key IDENTITY (1, 1) NOT NULL,
    userfname VARCHAR(MAX) NULL,
    userlastname VARCHAR(MAX) NULL,
    userpassword VARCHAR(MAX) NULL,
    userrole VARCHAR(MAX) NULL,
    userstatus VARCHAR(MAX) NULL,
    Email VARCHAR(255) NULL,
    datereg DATE NULL,
);
select *from users;
                    --Administrator
CREATE TABLE Administrator
(
    AdminId INT Primary key NOT NULL,
    FOREIGN KEY (AdminId) REFERENCES users(Id)
);
                   ---Customer
CREATE TABLE Customer
(
    CustomerId int primary key  NOT NULL,
    FOREIGN KEY (CustomerId) REFERENCES users(Id)
);
                  --Employees
select *from Employees;
CREATE TABLE Employees
(
    EmpId INT primary key NOT NULL,
    age   INT  NULL,
    availability VARCHAR (MAX) NULL,
    FOREIGN KEY (EmpId) REFERENCES users(Id)
);
select *from Employees;
                         ---Discount
create table Discount
(
DiscountId int primary key,
DiscountType varchar(MAX) NULL,
DisscountPer int null,
);
INSERT INTO Discount (DiscountId, DiscountType, DisscountPer) 
VALUES 
(1, 'Percentage', 10),
(2, 'Fixed Amount', 50),
(3,'Large Sale',60);
Select *from Discount;
                        ---Category
create table categories
(
catId int primary key identity(1,1),
catName varchar(max) null,
);
insert into categories (catName) values ('Food'),('Coffee');
insert into categories (catName) values ('Tea'),('Sandwiches'),('Smoothies'),('Juices'),('Desserts'),
('Breakfast Items'),('Snacks');
                        ---Products
CREATE TABLE Products (
    PID INT Primary key NOT NULL,
    name VARCHAR(MAX) NULL,
    price INT NULL,
    categoryid INT NULL,
    DiscountId INT NULL,
    Description VARCHAR(MAX) NULL,
    FOREIGN KEY (categoryid) REFERENCES categories (catId),
    FOREIGN KEY (DiscountId) REFERENCES Discount (DiscountId),
    Inventory INT
);
select *from Products;
                       ---Cart
CREATE TABLE cart (
    CId INT primary key IDENTITY (1, 1) NOT NULL,
    CDate DATE NULL,
    TotalAmount DECIMAL(10, 2) NULL,
    customerId INT NULL,
    FOREIGN KEY (customerId) REFERENCES Customer (CustomerId)
);
select *from cart;
                        ---Cart Items
CREATE TABLE cartItems (
    CItemsId INT Primary key IDENTITY (1, 1) NOT NULL,
    CId INT NULL,
    PID INT NULL,
    Quantity INT NULL,
    FOREIGN KEY (CId) REFERENCES cart (CId),
    FOREIGN KEY (PID) REFERENCES Products (PID)
);
select *from cartItems;
                        ---Orders
CREATE TABLE Orders (
    OrderId INT Primary key IDENTITY (1, 1) NOT NULL,
    customerId INT NULL,
    TotalAmount DECIMAL(10, 2) NULL,
    OrderDate DATE NULL,
    OrderTime TIME(7) NULL,
    OrderType VARCHAR(250) NULL,
    OrderStatus VARCHAR(250) NULL,
    FOREIGN KEY (customerId) REFERENCES Customer (CustomerId)
);
select *from Orders;
                      ---OrderItems
CREATE TABLE OrderItems (
    OIID INT  Primary key IDENTITY (1, 1) NOT NULL,
    OrderId INT NULL,
    PID INT NULL,
    Quantity INT NULL,
    FOREIGN KEY (PID) REFERENCES Products (PID),
    FOREIGN KEY (OrderId) REFERENCES Orders (OrderId)
);
select *from OrderItems;
                  ---Feedback
CREATE TABLE Feedback (
    FeedbackId INT Primary key IDENTITY (1, 1) NOT NULL,
    Description VARCHAR(MAX) NULL,
    date DATE NULL,
    time TIME(7) NULL,
    Rating INT NULL,
    PID INT NULL,
    customerId INT NULL,
    FOREIGN KEY (PID) REFERENCES Products (PID),
    FOREIGN KEY (customerId) REFERENCES Customer (CustomerId)
);
select *from Feedback;
                         ---Payment
CREATE TABLE Payment (
    PaymentId INT primary key IDENTITY (1, 1) NOT NULL,
    OrderId INT NULL,
    PaymentDate DATE NULL,
    PaymentTime TIME(7) NULL,
    PaymentType VARCHAR(250) NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders (OrderId),
    PaymentStatus VARCHAR(250) NULL
);
select *from Payment;
                          ---Recipt
CREATE TABLE Recipt (
    ReciptId INT  primary key IDENTITY (1, 1) NOT NULL,
    R_time TIME(7) NULL,
    R_date DATE NULL,
    PaymentId INT NULL,
    FOREIGN KEY (PaymentId) REFERENCES Payment (PaymentId)
); 
-----------------------------------------
CREATE TRIGGER OrdersQuantity ON OrderItems
AFTER INSERT
AS BEGIN 
DECLARE @ProductID INT
SELECT @ProductID=PID FROM INSERTED
DECLARE @Quantity INT
SELECT @Quantity=Quantity FROM INSERTED 
UPDATE Products 
SET Inventory=Inventory-@Quantity
WHERE PID=@ProductID
END;

DROP TRIGGER OrdersQuantity
--------------------------------------
CREATE TRIGGER CheckQuantity ON CartItems
FOR INSERT
AS BEGIN 
IF EXISTS(SELECT * FROM INSERTED I
JOIN Products P ON I.PID=P.PID
WHERE P.Inventory<0 OR P.Inventory=0 OR P.Inventory-I.Quantity<0)
BEGIN 
PRINT ('NOT ENOUGH PRODUCTS IN INVENTORY')
ROLLBACK TRANSACTION
END
END

DROP TRIGGER CheckQuantity
-------------------------------------
CREATE VIEW PendingOrders
AS 
SELECT O.OrderId, U.userfname AS CustomerName, O.OrderTime, O.OrderType, O.TotalAmount, P.name, OT.Quantity 
FROM Orders O
JOIN Customer C ON O.customerId = C.customerId 
JOIN OrderItems OT ON O.OrderId = OT.OrderId
JOIN Products P ON OT.PID = P.PID 
JOIN users U ON C.customerId = U.Id
WHERE O.OrderStatus = 'Pending'
GROUP BY O.OrderId, U.userfname, O.OrderTime, O.OrderType, O.TotalAmount, P.name, OT.Quantity

---------------------------------------
CREATE VIEW PendingOrders
AS 
SELECT O.OrderId, U.userfname AS CustomerName, O.OrderTime, O.OrderType, O.TotalAmount, P.name, OT.Quantity 
FROM Orders O
JOIN Customer C ON O.customerId = C.customerId 
JOIN OrderItems OT ON O.OrderId = OT.OrderId
JOIN Products P ON OT.PID = P.PID 
JOIN users U ON C.customerId = U.Id
WHERE O.OrderStatus = 'Pending'
GROUP BY O.OrderId, U.userfname, O.OrderTime, O.OrderType, O.TotalAmount, P.name, OT.Quantity

SELECT * FROM PendingOrders

-------------------------------
CREATE VIEW productsorderedtimes 
AS
SELECT TOP 3 P.name,P.price,COUNT(OT.PID) AS TimesOrdered
FROM Products P
JOIN OrderItems OT ON P.PID=OT.PID
GROUP BY P.name,P.price;


SELECT * FROM productsorderedtimes


----------------------------
CREATE VIEW EmployeeDetails AS
SELECT E.EmpId,U.userfname,E.age FROM Employees E 
JOIN users U ON E.EmpId=U.Id;

SELECT * FROM EmployeeDetails


-------------------------

CREATE VIEW customerrec AS
SELECT 
                    c.*, 
                    u.userfname AS Username, 
                    u.userlastname AS UserLastname, 
                    u.userrole AS UserRole, 
                    u.userstatus AS UserStatus, 
                    u.Email AS UserEmail, 
                    u.datereg AS UserDateReg 
                FROM 
                    Customer c 
                INNER JOIN 
                    users u ON c.CustomerId = u.Id;

                    SELECT * FROM customerrec;

-------------------------
  CREATE VIEW customerorders AS
     SELECT oi.PID, COUNT(DISTINCT o.customerId) AS TotalCustomers
     FROM OrderItems oi
     INNER JOIN Orders o ON oi.OrderId = o.OrderId
     GROUP BY oi.PID;
SELECT * FROM customerorders