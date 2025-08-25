USE [AdventureWorksDW2019]

SELECT 
	A.EmployeeKey 'ID Funcionario',
	F.FirstName 'Nome',
	F.LastName 'Sobrenome',
	F.Title 'Cargo',
	P.EnglishProductCategoryName 'Categoria Produto',
	P.EnglishProductSubcategoryName 'Subcategoria Produto',
	D.FullDateAlternateKey 'Data Pedido',
	A.total_vendido 'Total Vendido'

FROM (
	SELECT
		EmployeeKey,
		ProductKey,
		OrderDateKey,
		SUM (ExtendedAmount) AS total_vendido
	FROM AdventureWorksDW2019.dbo.FactResellerSales WITH (NOLOCK)
	GROUP BY EmployeeKey,ProductKey,OrderDateKey
) A

LEFT JOIN (
	SELECT 
		PD.ProductKey,
		(CASE WHEN PDC.EnglishProductCategoryName IS NULL THEN 'N/A'
			ELSE PDC.EnglishProductCategoryName END) AS 'EnglishProductCategoryName',
		(CASE WHEN PDS.EnglishProductSubcategoryName IS NULL THEN 'N/A'
			ELSE PDS.EnglishProductSubcategoryName END) AS 'EnglishProductSubcategoryName'
	FROM AdventureWorksDW2019.dbo.DimProduct AS PD WITH (NOLOCK)
	LEFT JOIN DimProductSubcategory PDS		ON PD.ProductSubcategoryKey = PDS.ProductSubcategoryKey
	LEFT JOIN DimProductCategory PDC		ON PDS.ProductCategoryKey = PDC.ProductCategoryKey
) P	ON A.ProductKey = P.ProductKey

LEFT JOIN (
	SELECT
		DateKey,
		FullDateAlternateKey
	FROM AdventureWorksDW2019.dbo.DimDate WITH (NOLOCK)
) D	ON A.OrderDateKey = D.DateKey

LEFT JOIN (
	SELECT 
		EmployeeKey,
		FirstName,
		LastName,
		Title
	FROM AdventureWorksDW2019.dbo.DimEmployee WITH (NOLOCK)
) F	ON A.EmployeeKey = F.EmployeeKey

WHERE P.EnglishProductCategoryName = 'Bikes' and YEAR(D.FullDateAlternateKey) = '2012' 

ORDER BY [ID Funcionario],[Data Pedido]