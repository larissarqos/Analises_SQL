USE COFFEE
GO

-- 1. Quantos clientes únicos existem em cada cidade que compraram café?
SELECT
	ci.city_name AS cidade,
	COUNT(DISTINCT cs.customer_id) AS total_clientes
FROM city as ci
LEFT JOIN
customers as cs
ON cs.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_clientes DESC

-- 2. Qual é o valor médio de receita por cliente em cada cidade?
SELECT
	ci.city_name AS cidade,
	SUM(total) AS receita_total,
	COUNT(DISTINCT s.customer_id) AS total_clientes,
	FORMAT(SUM(total)/COUNT(DISTINCT s.customer_id), 'N2') AS receita_media_por_cliente
FROM sales AS s
JOIN customers AS cs
ON s.customer_id = cs.customer_id
JOIN city as ci
ON ci.city_id = cs.city_id
GROUP BY ci.city_name
ORDER BY receita_total DESC

-- 3. Quantas unidades de cada produto foram vendidas?
SELECT
	p.product_name AS produto,
	COUNT(s.sale_id) AS total_pedidos
FROM products AS p
LEFT JOIN
sales AS s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_pedidos DESC

-- 4. Quais são os três produtos mais vendidos em cada cidade?
SELECT *
FROM
(
	SELECT ci.city_name AS cidade,
		p.product_name AS produto,
		COUNT(s.sale_id) AS total_pedidos,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS ranking
	FROM sales AS s
	JOIN
	products AS p
	ON s.product_id = p.product_id
	JOIN customers as cs
	ON cs.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = cs.city_id
	GROUP BY ci.city_name, p.product_name
) AS rank_pedidos
WHERE ranking <= 3

-- 5. Forneca o valor médio de vendas e aluguel por cliente, de cada cidade.
SELECT
	ci.city_name AS cidade,
	ci.estimated_rent AS aluguel_estimado,
	COUNT(DISTINCT s.customer_id) AS total_clientes,
	ROUND(SUM(s.total) * 1.0 / COUNT(DISTINCT s.customer_id), 2) AS receita_media_cliente,
	ROUND(ci.estimated_rent * 1.0 / COUNT(DISTINCT cs.customer_id), 2) AS aluguel_medio_cliente
FROM sales AS s
JOIN customers AS cs
ON s.customer_id = cs.customer_id
JOIN city as ci
ON ci.city_id = cs.city_id
GROUP BY ci.city_name, ci.estimated_rent
ORDER BY receita_media_cliente DESC

-- 6. Qual a estimativa, por cidade, do consumo de café, considerando o comportamento de 25% da população?
SELECT
	city_name AS cidade,
	population AS populacao,
	FORMAT((population * 0.25)/1000000, 'N2') AS estimativa_consumo_milhoes
FROM city
ORDER BY populacao DESC

-- 7. Gere uma lista de cidades com suas respectivas populações e consumidores estimados de café.
SELECT 
	ci.city_name AS cidade,
	COUNT(DISTINCT cs.customer_id) as cont_distinta_clientes,
	FORMAT((ci.population * 0.25)/1000000, 'N2') AS estimativa_consumo_milhoes
FROM sales as s
JOIN customers as cs
ON cs.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = cs.city_id
GROUP BY ci.city_name, ci.population
ORDER BY (ci.population * 0.25)/1000000 DESC

-- 8. Qual é a receita total das vendas, considerando todas as cidades, no último trimestre de 2023?
SELECT
	ci.city_name AS cidade,
	SUM(total) AS receita_total
FROM sales AS s
JOIN customers AS cs
ON s.customer_id = cs.customer_id
JOIN city as ci
ON ci.city_id = cs.city_id
WHERE
	DATEPART(YEAR, s.sale_date) = 2023
	AND
	DATEPART(QUARTER, s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY receita_total DESC

-- 9. Informe as taxas de crescimento ou declínio nas vendas de café, ao longo do período
WITH vendas_mensais AS
(
	SELECT 
		ci.city_name AS cidade,
		DATEPART(MONTH, sale_date) AS mes_venda,
		DATEPART(YEAR, sale_date) AS ano_venda,
		SUM(s.total) AS valor_vendas
	FROM sales AS s
	JOIN customers AS cs
	ON cs.customer_id = s.customer_id
	JOIN city AS ci
	ON ci.city_id = cs.city_id
	GROUP BY ci.city_name, DATEPART(MONTH, sale_date), DATEPART(YEAR, sale_date)
),
taxa_crescimento
AS
(
	SELECT
		cidade,
		mes_venda,
		ano_venda,
		valor_vendas,
		LAG(valor_vendas, 1) OVER(PARTITION BY cidade ORDER BY ano_venda, mes_venda) AS ultimo_mes_vendas
	FROM vendas_mensais
)
SELECT
	cidade,
	mes_venda,
	ano_venda,
	valor_vendas,
	ultimo_mes_vendas,
	ROUND((valor_vendas - ultimo_mes_vendas)/ultimo_mes_vendas * 100, 2) AS taxa_cresc
FROM taxa_crescimento
WHERE ultimo_mes_vendas IS NOT NULL

-- 10. Identifique as 3  cidades com a maior receita média por cliente. Considere: cidade, venda, aluguel, clientes e consumidor estimado de café).
WITH cidade_receita
AS
(
	SELECT
		ci.city_name AS cidade,
		SUM(s.total) as receita_total,
		COUNT(DISTINCT s.customer_id) as total_clientes,
		ROUND(SUM(s.total)/COUNT(DISTINCT s.customer_id),2) as receita_media_por_cliente
	FROM sales as s
	JOIN customers as cs
	ON s.customer_id = cs.customer_id
	JOIN city as ci
	ON ci.city_id = cs.city_id
	GROUP BY ci.city_name
),

cidade_aluguel
AS
(
	SELECT
		city_name AS cidade, 
		estimated_rent AS aluguel_estimado,
		FORMAT((population * 0.25)/1000000, 'N2') as estimativa_consumo_milhoes
	FROM city
)
SELECT TOP 3
	ca.cidade AS cidade,
	receita_total,
	cr.total_clientes,
	ca.aluguel_estimado,
	cr.receita_media_por_cliente,
	FORMAT(ca.aluguel_estimado/cr.total_clientes, 'N2') as aluguel_medio_estimado,
	estimativa_consumo_milhoes
FROM cidade_aluguel as ca
JOIN cidade_receita as cr
ON ca.cidade = cr.cidade
ORDER BY receita_total DESC