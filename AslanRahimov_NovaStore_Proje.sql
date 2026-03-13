/* PROJE ADI: NovaStore E-Ticaret Veri Yönetim Sistemi
   HAZIRLAYAN: Aslan Rahimov
*/

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NovaStoreDB')
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

CREATE DATABASE NovaStoreDB;
GO
USE NovaStoreDB;
GO


CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50),
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE
);

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT
);
GO


INSERT INTO Categories (CategoryName) VALUES 
('Elektronik'), ('Giyim'), ('Kitap'), ('Kozmetik'), ('Ev ve Yaşam');

INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES 
('Laptop', 25000.00, 15, 1), 
('Akıllı Telefon', 18000.00, 50, 1),
('Kışlık Mont', 1200.00, 8, 2), 
('Spor Ayakkabı', 850.00, 30, 2),
('SQL Kitabı', 150.00, 100, 3), 
('Roman', 80.00, 12, 3),
('Parfüm', 600.00, 25, 4), 
('Nemlendirici', 120.00, 5, 4),
('Masa', 1500.00, 10, 5), 
('Lamba', 250.00, 40, 5);

INSERT INTO Customers (FullName, City, Email) VALUES 
('Ahmet Yılmaz', 'İstanbul', 'ahmet@mail.com'),
('Ayşe Kaya', 'Ankara', 'ayse@mail.com'),
('Mehmet Demir', 'İzmir', 'mehmet@mail.com'),
('Fatma Çelik', 'Bursa', 'fatma@mail.com'),
('Ali Can', 'Antalya', 'ali@mail.com');

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES 
(1, '2026-03-01', 25000.00), 
(1, '2026-03-05', 150.00), 
(2, '2026-03-10', 1200.00),
(3, '2026-02-15', 18000.00),
(4, '2026-01-20', 600.00),
(5, '2026-03-12', 1750.00);

INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES 
(1, 1, 1), (2, 5, 1), (3, 3, 1), (4, 2, 1), (5, 7, 1), (6, 9, 1);
GO


-- Kritik Stok Raporu
SELECT ProductName, Stock FROM Products WHERE Stock < 20 ORDER BY Stock DESC;

-- Müşteri ve Sipariş Detayları
SELECT C.FullName, C.City, O.OrderDate, O.TotalAmount 
FROM Customers C INNER JOIN Orders O ON C.CustomerID = O.CustomerID;

-- Ahmet Yılmaz'ın Aldığı Ürünler
SELECT P.ProductName, P.Price, Cat.CategoryName 
FROM Customers C 
JOIN Orders O ON C.CustomerID = O.CustomerID 
JOIN OrderDetails OD ON O.OrderID = OD.OrderID 
JOIN Products P ON OD.ProductID = P.ProductID 
JOIN Categories Cat ON P.CategoryID = Cat.CategoryID 
WHERE C.FullName = 'Ahmet Yılmaz';

-- Kategori Başına Ürün Sayısı
SELECT Cat.CategoryName, COUNT(P.ProductID) AS UrunSayisi 
FROM Categories Cat LEFT JOIN Products P ON Cat.CategoryID = P.CategoryID 
GROUP BY Cat.CategoryName;

-- Ciro Analizi (Müşteri Bazlı)
SELECT C.FullName, SUM(O.TotalAmount) AS ToplamCiro 
FROM Customers C JOIN Orders O ON C.CustomerID = O.CustomerID 
GROUP BY C.FullName ORDER BY ToplamCiro DESC;

-- Zaman Analizi (Kaç Gün Geçti)
SELECT OrderID, OrderDate, DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGunSayisi FROM Orders;
GO


-- View Oluşturma
CREATE VIEW vw_SiparisOzet AS 
SELECT C.FullName AS MusteriAdi, O.OrderDate AS SiparisTarihi, P.ProductName AS UrunAdi, OD.Quantity AS Adet 
FROM Customers C 
JOIN Orders O ON C.CustomerID = O.CustomerID 
JOIN OrderDetails OD ON O.OrderID = OD.OrderID 
JOIN Products P ON OD.ProductID = P.ProductID;
GO

--Rapor Listeleme
SELECT * FROM vw_SiparisOzet;
GO
