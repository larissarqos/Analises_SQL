USE SALES
GO

-- VISUALIZANDO OS DADOS
SELECT * FROM retail_sales

-- VERIFICANDO VALORES NULOS
-- Os valores nulos foram convertidos em 0
SELECT * FROM retail_sales
WHERE customer_id = '0'
OR gender = '0'
OR age = '0'
OR category = '0'
OR quantity = '0'
OR price_per_unit = '0'
OR cogs = '0'
OR total_sale = '0'

-- DELETANDO VALORES NULOS
-- Foram deletadas 13 linhas com valores nulos numa ou mais das colunas abaixo
-- Antes da exclusão, foi verificado na base de dados original se todos os valores 0 eram de fato os nulos, o que foi confirmado
DELETE FROM retail_sales
WHERE customer_id = '0'
OR gender = '0'
OR age = '0'
OR category = '0'
OR quantity = '0'
OR price_per_unit = '0'
OR cogs = '0'
OR total_sale = '0'

-- == EXPLORAÇÃO DOS DADOS ==

-- 1. Qual o total de vendas?
-- Contamos com 1987 vendas
SELECT COUNT(*) AS total_vendas
FROM retail_sales

-- 2. Quantos clientes nós temos?
-- Contamos com 155 clientes
SELECT COUNT(DISTINCT customer_id) AS total_clientes
FROM retail_sales

-- 3. Quantas e quais são as categorias dos nossos produtos?
-- Contamos com 3 categorias: clothing, eletronics e beauty
SELECT DISTINCT category
FROM retail_sales

-- == Análise dos dados ==

-- 4. Qual categoria foi a mais comprada por nossos clientes e qual o valor de venda?
-- A categoria Clothing foi a mais comprada.
SELECT category,
	COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY category 
ORDER BY total_pedidos DESC

-- 5. Há grande diferença na quantidade de pedidos e valor total de vendas, considerando o gênero dos nossos clientes?
-- O gênero feminino foi o que mais comprou (), gerando também maior faturamento ().
SELECT gender,
COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY gender 
ORDER BY valor_total DESC

-- 6. Gere uma amostra de transações com valor total igual ou maior a 1000
-- arquivo gerado como "sales_equals_higher_1000.csv"
SELECT *
FROM retail_sales
WHERE total_sale >= 1000
ORDER BY total_sale ASC

-- 7. Quais os 5 clientes que mais compraram conosco?
-- Os clientes de maior valor do período foram os de ID: 3, 1, 5, 2 e 4
SELECT TOP 5 customer_id,
	SUM(total_sale) as valor_total
FROM retail_sales
GROUP BY customer_id
ORDER BY valor_total DESC

-- 8. Qual o total de vendas, considerando o gênero dos clientes e categoria dos produtos?
SELECT category,
	gender,
	COUNT(*) AS total_vendas
	FROM retail_sales
GROUP BY category, gender
ORDER BY total_vendas DESC

-- 9. Qual a média de idade dos clientes que compram na categoria 'Beauty', por gênero?
SELECT 
	category,
	gender,
	ROUND(AVG(age), 2) AS media_idade
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY gender, category
ORDER BY gender

-- 10. Gere uma amostra das vendas realizadas em maio de 2022
-- arquivo gerado como "sale_05_2022.csv"
SELECT *
FROM retail_sales
WHERE sale_date LIKE '2022-05%'
ORDER BY sale_date ASC

-- 11. Retorne as transações de categoria 'Clothing', em que a quantidade vendida é mais que 10, no mês de novembro
-- A quantidade máxima vendida da categoria 'Clothing' em novembro de 2022 é 4
-- Não há quantidade de vendas maior ou igual a 10
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND sale_date LIKE '2022-11%'
	AND quantity >= 4

-- 12. Indique o valor médio em vendas de cada mês
SELECT
	DATEPART(yyyy, sale_date) AS ano_venda,
	DATEPART(month, sale_date) AS mes_venda,
	ROUND(AVG(total_sale), 2) AS total_vendas
FROM retail_sales
GROUP BY DATEPART(yyyy, sale_date), DATEPART(month, sale_date)
ORDER BY ano_venda, total_vendas DESC

-- Qual o mês de melhor desempenho em cada ano?
SELECT * FROM
(	
	SELECT
			DATEPART(yyyy, sale_date) AS ano_venda,
			DATEPART(month, sale_date) AS mes_venda,
			ROUND(AVG(total_sale), 2) AS total_vendas,
			RANK() OVER(PARTITION BY DATEPART(yyyy, sale_date) ORDER BY ROUND(AVG(total_sale), 2) DESC) AS ranking
	FROM retail_sales
	GROUP BY DATEPART(yyyy, sale_date), DATEPART(month, sale_date)
) AS resultado
WHERE ranking = 1

-- Organize os horários de compra em turnos: manhã, tarde e noite
-- Manhã <=12; Tarde > 12, <=17; Noite > 17
SELECT *,
	CASE
		WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Manhã'
		WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Tarde'
		ELSE 'Noite'
	END AS turno
FROM retail_sales

-- 15. Que turno costumar ter mais transações?
-- Nossos clientes costumam comprar mais à noite. Esse período conta mais que 2x mais compras que os turnos de manhã e tarde.
WITH hourly_sail
AS(
	SELECT *,
		CASE
			WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Manhã'
			WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Tarde'
			ELSE 'Noite'
		END AS turno
	FROM retail_sales
)
SELECT
	turno,
	COUNT(*) AS total_orders
FROM hourly_sail
GROUP BY turno
ORDER BY total_orders DESC