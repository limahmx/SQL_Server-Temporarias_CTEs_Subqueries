# Comparando Abordagens no SQL Server: Tabelas Temporárias, CTEs e Subqueries em Consultas de Análise de Dados

Este projeto demonstra três formas diferentes de estruturar a mesma consulta no **SQL Server**:  

- **Tabelas Temporárias (`#temp`)**  
- **CTEs (Common Table Expressions)**  
- **Subqueries**  

O contexto utilizado é o banco de dados **AdventureWorksDW2019**, comum em cenários de **Business Intelligence (BI)** e **análise de dados**.  

Embora todas as alternativas cheguem ao mesmo resultado, o foco aqui é evidenciar que **as tabelas temporárias são geralmente mais adequadas em consultas analíticas**, principalmente quando lidamos com **grandes volumes de dados**, **múltiplas etapas de transformação** e **necessidade de depuração**.  

---

## 📂 Estrutura do Repositório


- [`README.md`](./README.md) → Documentação do projeto
- [`AdventureWorksDW2019.zip`](./AdventureWorksDW2019.zip) → Pasta compactada com banco de dados em formato ".bak"
- [`query_CTE.sql`](./query_CTE.sql) → versão alternativa, com **CTEs**  
- [`query_subqueries.sql`](./query_subqueries.sql) → versão alternativa, com **subqueries aninhadas**
- [`query_temp_tables.sql`](./query_temp_tables.sql) → versão principal, com **tabelas temporárias**   
- [`resultados.png`](./resultados.png) → imagem com resultados de exemplo
---

## 🛠️ Script com Tabelas Temporárias

Tabelas temporárias são criadas usando a cláusula "INTO", acompanhada de "#nometabela".

O arquivo [`query_temp_tables.sql`](./query_temp_tables.sql) cria quatro tabelas temporárias para organizar os dados antes de consolidar o resultado final:

1. **#tabela_produtos** → organiza categorias e subcategorias de produtos  
2. **#tabela_vendas** → agrega valores de vendas por funcionário/produto/data  
3. **#tabela_datas** → referência de datas dos pedidos  
4. **#tabela_funcionarios** → dados dos colaboradores  

Essas tabelas são unidas ao final para gerar a consulta consolidada.

---
### Exemplo de criação de tabela temporária:

```sql
IF OBJECT_ID('tempdb.dbo.#tabela_produtos','U') IS NOT NULL -- Verifica se já existe temporária com 
BEGIN DROP TABLE tempdb.dbo.#tabela_produtos; END			-- mesmo nome, previnindo ERRO na execução


SELECT 
	PD.ProductKey,
	(CASE WHEN PDC.EnglishProductCategoryName IS NULL THEN 'N/A'
		ELSE PDC.EnglishProductCategoryName END) AS 'EnglishProductCategoryName',
	(CASE WHEN PDS.EnglishProductSubcategoryName IS NULL THEN 'N/A'
		ELSE PDS.EnglishProductSubcategoryName END) AS 'EnglishProductSubcategoryName'

INTO #tabela_produtos			-- "INTO" copia dados de uma tabela para uma nova tabela
								-- "#" antes do nome da tabela, define como uma temporária local

FROM AdventureWorksDW2019.dbo.DimProduct AS PD WITH (NOLOCK)

LEFT JOIN DimProductSubcategory PDS		ON PD.ProductSubcategoryKey = PDS.ProductSubcategoryKey
LEFT JOIN DimProductCategory PDC		ON PDS.ProductCategoryKey = PDC.ProductCategoryKey
```

### Exemplo de resultado final:

```sql
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
```

<img width="786" height="306" alt="resultados" src="https://github.com/user-attachments/assets/e97911c1-b754-4773-b979-ef257c61d1d4" />

---
## 🚀 Vantagens das Tabelas Temporárias

- Organização → a query fica dividida em blocos claros e independentes

- Reaproveitamento → resultados intermediários podem ser usados em diferentes trechos da consulta

- Performance em BI → evita cálculos repetidos em tabelas grandes, aproveitando índices e cache no tempdb

- Depuração → facilita inspecionar cada etapa de forma isolada

💡 Por esses motivos, as tabelas temporárias são frequentemente a melhor escolha em consultas analíticas e pipelines de BI.

---
## 🔄 Alternativas

Também incluí versões sem tabelas temporárias para comparação:

- [`query_CTE.sql`](./query_CTE.sql) → usando CTEs

- [`query_subqueries.sql`](./query_subqueries.sql) → usando subqueries aninhadas

Essas abordagens são válidas, mas têm restrições que, em cenários de BI, podem limitar seu uso.

### 📊 Comparação: Tabelas Temporárias x CTEs x Subqueries

| Critério             | Tabelas Temporárias (`#temp`)              | CTEs (`WITH`)                                  | Subqueries                 |
| -------------------- | ------------------------------------------ | ---------------------------------------------- | -------------------------- |
| **Escopo**           | Sessão/conexão                             | Apenas na query                                | Apenas na query            |
| **Reaproveitamento** | ✅ Sim (múltiplas vezes)                    | ❌ Não                                          | ❌ Não                      |
| **Performance**      | ✅ Boa para grandes datasets (pode indexar) | Boa em cenários simples, mas pode recalcular   | Similar a CTE, recalcula   |
| **Legibilidade**     | Média (mais código)                        | ✅ Muito alta                                   | Baixa se muito aninhada    |
| **Depuração**        | ✅ Fácil (pode inspecionar)                 | Difícil                                        | Difícil                    |
| **Uso típico**       | ETL, BI, queries complexas                 | Queries complexas não reutilizadas, recursivas | Consultas simples e locais |

---
## 🔬 Teste de Performance

Para validar o comportamento das três abordagens, executei múltiplos testes em cada uma, usando o **AdventureWorksDW2019**.  
Cada consulta retornou **30.029 linhas**, e os resultados médios foram:

| Método        | CPU médio (ms) | Tempo decorrido médio (ms) |
|---------------|----------------|-----------------------------|
| Temp Table    | 72,67          | 298,00                      |
| CTE           | 168,33         | 363,33                      |
| Subqueries    | 137,33         | 351,67                      |

📌 **Diferença de performance em relação às tabelas temporárias**:
- **CTE** → +131,65% de CPU e +21,92% de tempo  
- **Subqueries** → +88,99% de CPU e +18,01% de tempo  

### 🚀 Por que as temporárias foram mais rápidas?

As **tabelas temporárias** levam vantagem porque:  
- São armazenadas no `tempdb` e podem ter **estatísticas próprias**, permitindo ao otimizador criar planos de execução mais eficientes.  
- **Evita recalcular dados**: os resultados intermediários são gravados uma vez e reutilizados.  
- Suportam **índices adicionais**, melhorando consultas sobre grandes volumes.  

Já **CTEs** e **subqueries** tendem a recalcular seus resultados a cada utilização dentro da query, o que aumenta o consumo de CPU e tempo.

💡 **Observação**: A diferença tende a ser ainda maior em hardware empresarial, bancos maiores e consultas mais complexas, reforçando que, em cenários de **ETL e BI**, as tabelas temporárias geralmente oferecem o melhor custo-benefício.  

---
## 🎯 Quando usar cada um?

- **Tabelas Temporárias**
  👉 Ótima opção em análise de dados/BI, quando há grandes volumes, múltiplas etapas de transformação e necessidade de reaproveitamento.

- **CTEs**
  👉 Úteis para melhorar legibilidade, principalmente em queries complexas de leitura única ou recursivas.

- **Subqueries**
  👉 Ideais em transformações pontuais e simples, geralmente em consultas pequenas.

---
## ✅ Conclusão

Este projeto mostra como a mesma análise pode ser resolvida de três formas diferentes.
No entanto, no contexto de BI e análise de dados, as tabelas temporárias geralmente oferecem a melhor combinação de clareza, performance e reaproveitamento, sendo especialmente úteis em pipelines de dados e consultas analíticas.
