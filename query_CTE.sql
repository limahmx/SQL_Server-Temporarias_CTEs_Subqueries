USE [AdventureWorksDW2019]

;WITH Produtos AS (
	SELECT 
		PD.ProductKey,
		(CASE WHEN PDC.EnglishProductCategoryName IS NULL THEN 'N/A'
			ELSE PDC.EnglishProductCategoryName END) AS 'EnglishProductCategoryName',
		(CASE WHEN PDS.EnglishProductSubcategoryName IS NULL THEN 'N/A'
			ELSE PDS.EnglishProductSubcategoryName END) AS 'EnglishProductSubcategoryName'
	FROM AdventureWorksDW2019.dbo.DimProduct AS PD WITH (NOLOCK)
	LEFT JOIN DimProductSubcategory PDS		ON PD.ProductSubcategoryKey = PDS.ProductSubcategoryKey
	LEFT JOIN DimProductCategory PDC		ON PDS.ProductCategoryKey = PDC.ProductCategoryKey
),
Vendas AS (
	SELECT
		EmployeeKey,
		ProductKey,
		OrderDateKey,
		SUM (ExtendedAmount) AS total_vendido
	FROM AdventureWorksDW2019.dbo.FactResellerSales WITH (NOLOCK)
	GROUP BY EmployeeKey,ProductKey,OrderDateKey
),
Datas AS (
	SELECT
		DateKey,
		FullDateAlternateKey
	FROM AdventureWorksDW2019.dbo.DimDate WITH (NOLOCK)
),
Funcionarios AS (
	SELECT 
		EmployeeKey,
		FirstName,
		LastName,
		Title
	FROM AdventureWorksDW2019.dbo.DimEmployee WITH (NOLOCK)
)

SELECT 
	A.EmployeeKey 'ID Funcionario',
	D.FirstName 'Nome',
	D.LastName 'Sobrenome',
	D.Title 'Cargo',
	B.EnglishProductCategoryName 'Categoria Produto',
	B.EnglishProductSubcategoryName 'Subcategoria Produto',
	C.FullDateAlternateKey 'Data Pedido',
	A.total_vendido 'Total Vendido'

FROM Vendas A

LEFT JOIN Produtos B		ON A.ProductKey = B.ProductKey
LEFT JOIN Datas C			ON A.OrderDateKey = C.DateKey
LEFT JOIN Funcionarios D	ON A.EmployeeKey = D.EmployeeKey

WHERE B.EnglishProductCategoryName = 'Bikes' and YEAR(C.FullDateAlternateKey) = '2012' 

ORDER BY [ID Funcionario],[Data Pedido]
