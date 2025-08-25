USE [AdventureWorksDW2019]

----------- Cria temporária de Produtos -------

IF OBJECT_ID('tempdb.dbo.#tabela_produtos','U') IS NOT NULL
BEGIN DROP TABLE tempdb.dbo.#tabela_produtos; END

SELECT 
	PD.ProductKey,
	(CASE WHEN PDC.EnglishProductCategoryName IS NULL THEN 'N/A'
		ELSE PDC.EnglishProductCategoryName END) AS 'EnglishProductCategoryName',
	(CASE WHEN PDS.EnglishProductSubcategoryName IS NULL THEN 'N/A'
		ELSE PDS.EnglishProductSubcategoryName END) AS 'EnglishProductSubcategoryName'

INTO #tabela_produtos

FROM AdventureWorksDW2019.dbo.DimProduct AS PD WITH (NOLOCK)

LEFT JOIN DimProductSubcategory PDS		ON PD.ProductSubcategoryKey = PDS.ProductSubcategoryKey
LEFT JOIN DimProductCategory PDC		ON PDS.ProductCategoryKey = PDC.ProductCategoryKey


---------- Cria temporária de Vendas -------

IF OBJECT_ID('tempdb.dbo.#tabela_vendas','U') IS NOT NULL
BEGIN DROP TABLE tempdb.dbo.#tabela_vendas; END

SELECT
	EmployeeKey,
	ProductKey,
	OrderDateKey,
	SUM (ExtendedAmount) AS total_vendido

INTO #tabela_vendas

FROM AdventureWorksDW2019.dbo.FactResellerSales WITH (NOLOCK)

GROUP BY EmployeeKey,ProductKey,OrderDateKey


----------- Cria temporária de Data -------

IF OBJECT_ID ('tempdb.dbo.#tabela_datas','U') IS NOT NULL
BEGIN DROP TABLE tempdb.dbo.#tabela_datas; END

SELECT
	DateKey,
	FullDateAlternateKey

INTO #tabela_datas

FROM AdventureWorksDW2019.dbo.DimDate WITH (NOLOCK)


----------- Cria temporária de Funcionários -------

IF OBJECT_ID('tempdb.dbo.#tabela_funcionarios','U') IS NOT NULL
BEGIN DROP TABLE tempdb.dbo.#tabela_funcionarios; END

SELECT 
	EmployeeKey,
	FirstName,
	LastName,
	Title

INTO #tabela_funcionarios

FROM AdventureWorksDW2019.dbo.DimEmployee WITH (NOLOCK)


----------- Cria Tabela Final -------

SELECT 
	A.EmployeeKey 'ID Funcionario',
	D.FirstName 'Nome',
	D.LastName 'Sobrenome',
	D.Title 'Cargo',
	B.EnglishProductCategoryName 'Categoria Produto',
	B.EnglishProductSubcategoryName 'Subcategoria Produto',
	C.FullDateAlternateKey 'Data Pedido',
	A.total_vendido 'Total Vendido'

FROM #tabela_vendas A

LEFT JOIN #tabela_produtos B		ON A.ProductKey = B.ProductKey
LEFT JOIN #tabela_datas C			ON A.OrderDateKey = C.DateKey
LEFT JOIN #tabela_funcionarios D	ON A.EmployeeKey = D.EmployeeKey

WHERE B.EnglishProductCategoryName = 'Bikes' and YEAR(C.FullDateAlternateKey) = '2012' 

ORDER BY [ID Funcionario],[Data Pedido]


