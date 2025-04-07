USE SALES
GO

-- VISUALIZANDO OS DADOS
SELECT * FROM retail_sales

-- VERIFICANDO VALORES NULOS
-- Os valores nulos foram convertidos em 0
SELECT * FROM retail_sales
WHERE customer_id = 0
OR gender = '0'
OR age = 0
OR category = '0'
OR quantity = 0
OR price_per_unit = 0
OR cogs = 0
OR total_sale = 0

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

-- 2. Qual o total de clientes?
-- Contamos com 155 clientes
SELECT COUNT(DISTINCT customer_id) AS total_clientes
FROM retail_sales

-- 3. Quantas e quais são as categorias dos nossos produtos?
-- Contamos com 3 categorias: Clothing, Eletronics e Beauty
SELECT DISTINCT category
FROM retail_sales

-- 4. Qual o faturamento total?
-- O faturamento total é de 908.230 dólares
SELECT SUM(total_sale) AS faturamento_total
FROM retail_sales

-- == Análise dos dados ==

-- 1. Qual categoria foi a mais comprada por nossos clientes e qual o valor de venda?
-- A categoria Clothing foi a mais comprada.
SELECT category,
	COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY category 
ORDER BY total_pedidos DESC

-- 2. Que gênero teve maior impacto nas vendas e no faturamento?
-- O gênero feminino foi o que mais comprou (), gerando também maior faturamento ().
SELECT gender,
COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY gender 
ORDER BY valor_total DESC

-- 3. Gere uma amostra de transações com valor total igual ou maior a 1000
-- arquivo gerado como "sales_equals_higher_1000.csv"
SELECT *
FROM retail_sales
WHERE total_sale >= 1000
ORDER BY total_sale ASC

-- 4. Quais os 5 clientes que mais compraram conosco?
-- Os clientes de maior valor do período foram os de ID: 3, 1, 5, 2 e 4
SELECT TOP 5 customer_id,
	SUM(total_sale) as valor_total
FROM retail_sales
GROUP BY customer_id
ORDER BY valor_total DESC

-- 5. Qual o total de vendas, considerando a categoria dos produtos e gênero dos clientes?
SELECT category,
	gender,
	COUNT(*) AS total_vendas
	FROM retail_sales
GROUP BY category, gender
ORDER BY total_vendas DESC

-- 6. Qual a média de idade dos clientes que compram na categoria 'Beauty', do gênero feminino?
SELECT 
	category,
	gender,
	ROUND(AVG(age), 2) AS media_idade
FROM retail_sales
WHERE category = 'Beauty' AND gender = 'Female'
GROUP BY gender, category
ORDER BY gender

-- 7. Gere uma amostra das vendas realizadas em maio de 2022
-- Arquivo gerado como "sale_05_2022.csv"
SELECT *
FROM retail_sales
WHERE sale_date LIKE '2022-05%'
ORDER BY sale_date ASC

-- 8. Retorne as transações de categoria 'Clothing', em que a quantidade vendida é mais que 10, no mês de novembro
-- A quantidade máxima vendida da categoria 'Clothing' em novembro de 2022 é 4
-- Não há quantidade de vendas maior ou igual a 10
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND sale_date LIKE '2022-11%'
	AND quantity >= 4

-- 9. Indique o valor médio em vendas de cada mês
SELECT
	DATEPART(yyyy, sale_date) AS ano_venda,
	DATEPART(month, sale_date) AS mes_venda,
	ROUND(AVG(total_sale), 2) AS total_vendas
FROM retail_sales
GROUP BY DATEPART(yyyy, sale_date), DATEPART(month, sale_date)
ORDER BY ano_venda, total_vendas DESC

-- 10. Qual o mês de melhor desempenho em cada ano?
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

-- 11. Organize os horários de compra em turnos (manhã, tarde e noite) e indique que turnos contém mais transações
-- Manhã <=12; Tarde > 12, <=17; Noite > 17
--  O turno da noite possui o maior número de transações: 1062 pedidos (53,45% do total).
WITH horario_vendas
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
	COUNT(*) AS total_pedidos
FROM horario_vendas
GROUP BY turno
ORDER BY total_pedidos DESC