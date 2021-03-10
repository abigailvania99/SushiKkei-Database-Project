--1
SELECT CustomerName, 'Total Item Sold'=SUM(SalesQuantity)
FROM Customer c
	JOIN HeaderSalesTransaction hst ON c.CustomerId = hst.CustomerId
	JOIN DetailSalesTransaction dst ON dst.SalesTransactionId = hst.SalesTransactionId
WHERE MONTH(SalesTransactionDate) = 12
GROUP BY CustomerName
HAVING SUM(SalesQuantity) > 5

--2
SELECT IngredientName, 'PurchaseDate' = PurchaseTransactionDate, 'Total Cost' = IngredientPrice*PurchaseQuantity
FROM Ingredient i
	JOIN DetailPurchaseTransaction dpt ON dpt.IngredientId = i.IngredientId
	JOIN HeaderPurchaseTransaction hpt ON hpt.PurchaseTransactionId = dpt.PurchaseTransactionId
WHERE MONTH(PurchaseTransactionDate) = 3 AND IngredientPrice*PurchaseQuantity > 10000

--3
SELECT FoodName, FoodPrice, 'Total Food Sold' = SUM(SalesQuantity), 'Total Transaction' = COUNT(dst.SalesTransactionId)
FROM Food f
	JOIN DetailSalesTransaction dst ON dst.FoodId = f.FoodId
	JOIN HeaderSalesTransaction hst ON hst.SalesTransactionId = dst.SalesTransactionId
WHERE FoodPrice > 15000 AND FoodPrice < 30000
GROUP BY FoodName, FoodPrice
HAVING COUNT(dst.SalesTransactionId)>2

--4
SELECT StaffName, 'Staff Gender' = LEFT(StaffGender,1), 'Total Food Sold' = SUM(SalesQuantity), 'Total Food Variance' = COUNT(f.FoodId), 'Transaction Date' = CONVERT(varchar(12),SalesTransactionDate,107)
FROM Staff s
	JOIN HeaderSalesTransaction hst ON hst.StaffId = s.StaffId
	JOIN DetailSalesTransaction dst ON dst.SalesTransactionId = hst.SalesTransactionId
	JOIN Food f ON f.FoodId = dst.FoodId
WHERE StaffGender = 'Male'
GROUP BY StaffName, StaffGender, SalesTransactionDate
HAVING SUM(SalesQuantity)>10

--5
SELECT StaffName, 'Rp.'+CAST(StaffSalary AS varchar)[Staff Salary], CONVERT(varchar(12),SalesTransactionDate,113)[Transaction Date], CustomerName
FROM Staff s
	JOIN HeaderSalesTransaction hst ON hst.StaffId = s.StaffId
	JOIN Customer c ON c.CustomerId = hst.CustomerId,
	( SELECT AVG(StaffSalary)[Staff Salary] FROM Staff ) AvgSalary
WHERE StaffSalary > AvgSalary.[Staff Salary] AND DATEPART(MONTH,SalesTransactionDate)<=3

--6
SELECT 'Customer Name' = SUBSTRING(CustomerName,1,CHARINDEX(' ',CustomerName)), CustomerAddress, FoodName, SalesTransactionDate
FROM Customer c
	JOIN HeaderSalesTransaction hst ON c.CustomerId = hst.CustomerId
	JOIN DetailSalesTransaction dst ON dst.SalesTransactionId = hst.SalesTransactionId
	JOIN Food f ON f.FoodId = dst.FoodId,
	( SELECT 'Price' = AVG(FoodPrice) FROM Food ) AvgPrice
WHERE FoodPrice > AvgPrice.Price AND LEN(FoodName) > 2

--7
SELECT StaffName, REPLACE(StaffPhoneNumber, left(StaffPhoneNumber,1),'+62')StaffPhone, 'Most Quantity Bought' = CAST(MAX(SalesQuantity) AS VARCHAR) + ' FOOD(S)', 'Least Quantity Bought' = CAST(MIN(SalesQuantity) AS VARCHAR) + ' FOOD(S)'
FROM Staff s
	JOIN HeaderSalesTransaction hst ON s.StaffId = hst.StaffId
	JOIN DetailSalesTransaction dst ON dst.SalesTransactionId = hst.SalesTransactionId,
	( SELECT 'Salary' = AVG(StaffSalary) FROM Staff ) AvgSalary
WHERE StaffSalary > AvgSalary.Salary 
GROUP BY StaffName, StaffPhoneNumber
HAVING MAX(SalesQuantity)<10
ORDER BY StaffName ASC

--8
SELECT 'Distributor Number' = REPLACE(d.DistributorId, 'DS','Distributor No, '), 'Distributor Name' = SUBSTRING(DistributorName,1,CHARINDEX(' ',DistributorName)), 'Ingredient Purchase' = SUM(PurchaseQuantity)
FROM Distributor d
	JOIN HeaderPurchaseTransaction hpt ON d.DistributorId = hpt.DistributorId
	JOIN DetailPurchaseTransaction dpt ON dpt.PurchaseTransactionId = hpt.PurchaseTransactionId,
	( SELECT 'Ingredient Purchased' = AVG(PurchaseQuantity) FROM DetailPurchaseTransaction ) AvgQuantity
WHERE PurchaseQuantity> AvgQuantity.[Ingredient Purchased]
GROUP BY d.DistributorId, DistributorName
HAVING SUM(PurchaseQuantity) > 10

--9
CREATE VIEW IngredientCost
AS
SELECT IngredientName, 'Total Cost' = COUNT(i.IngredientId)*IngredientPrice, 'Total Transaction' = COUNT(hpt.PurchaseTransactionId)
FROM Ingredient i
	JOIN DetailPurchaseTransaction dpt ON dpt.IngredientId = i.IngredientId
	JOIN HeaderPurchaseTransaction hpt ON hpt.PurchaseTransactionId = dpt.PurchaseTransactionId
WHERE DATEDIFF(MONTH, PurchaseTransactionDate, '2019-01-01') <= 2 OR DATEDIFF(MONTH, '2019-01-01', PurchaseTransactionDate) <= 2
GROUP BY IngredientName,IngredientPrice
HAVING COUNT(i.IngredientId)*IngredientPrice > 100000

--10
CREATE VIEW CustomerFavoriteMenu
AS
SELECT
	CustomerName, CustomerPhone, 'Total Food' = SUM(SalesQuantity), 'Sales Transaction' = COUNT(hst.SalesTransactionId)
FROM Customer c
	JOIN HeaderSalesTransaction hst ON hst.CustomerId = c.CustomerId
	JOIN DetailSalesTransaction dst ON dst.SalesTransactionId = hst.SalesTransactionId
	JOIN Food f ON f.FoodId = dst.FoodId
WHERE CHARINDEX(' ',CustomerName)!=0
GROUP BY CustomerName, CustomerPhone
HAVING COUNT(hst.SalesTransactionId) > 1
