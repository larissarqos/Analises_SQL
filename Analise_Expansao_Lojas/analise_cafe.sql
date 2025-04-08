USE COFFEE
GO

-- 1. Quantos clientes por cidade nós temos?
-- Organizando um "TOP 3", Jaipur, Delhi e Pune possuem maior quantidade de clientes (acima de 50)
SELECT
	ci.city_name AS cidade,
	COUNT(DISTINCT cs.customer_id) AS total_clientes
FROM city as ci
LEFT JOIN
customers as cs ON cs.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_clientes DESC

-- 2. Qual é o valor médio de receita por cliente em cada cidade?
-- Em termos de receita, analisando novamente os 3 maiores índices, Pune, Chennai e Bangalore encabeçam a lista
SELECT
	ci.city_name AS cidade,
	SUM(total) AS receita_total,
	COUNT(DISTINCT s.customer_id) AS total_clientes,
	FORMAT(SUM(total) / COUNT(DISTINCT s.customer_id), 'N2') AS receita_media_por_cliente
FROM sales AS s
JOIN customers AS cs
ON s.customer_id = cs.customer_id
JOIN city as ci
ON ci.city_id = cs.city_id
GROUP BY ci.city_name
ORDER BY receita_total DESC

-- 3. Quantas unidades de cada produto foram vendidas?
-- Há 4 produtos com maior destaque nas vendas:
-- Cold Brew Coffee Pack (6 Bottles), Ground Espresso Coffee (250g), Instant Coffee Powder (100g) e Coffee Beans (500g)
SELECT
	p.product_name AS produto,
	COUNT(s.sale_id) AS total_pedidos,
	SUM(s.total) AS total_receita
FROM products AS p
LEFT JOIN
sales AS s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_receita DESC

-- 4. Quais são os três produtos mais vendidos em cada cidade?
-- Mesmo em diferentes cidades, os 4 produtos listados anteriormente com maior quantidade de vendas ocupam ao menos
-- uma das posições no TOP 3 de cada cidade
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

-- 5. Forneça o valor médio de vendas e aluguel estimado por cliente, de cada cidade.
-- As cidades com maior receita média são Pune, Chennai e Bangalore
-- Analisando o custo benefício x receita média, Pune, Chennai e Jaipur têm melhor desempenho
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
-- Delhi e Mumbai têm maiores populações e, consequentemente, uma maior estimativa de consumo
SELECT
	city_name AS cidade,
	population AS populacao,
	FORMAT((population * 0.25) / 1000000, 'N2') AS estimativa_consumo_milhoes
FROM city
ORDER BY populacao DESC

-- 7. Gere uma lista de cidades com seus clientes e estimativa de consumidores de café.
-- Delhi possui uma maior quantidade de clientes e também maior estimativa de consumidores
-- Especialmente se comparada com Jaipur, que possui quase a mesma quantidade de clientes, mas uma estimativa 7x menor
SELECT 
	ci.city_name AS cidade,
	COUNT(DISTINCT cs.customer_id) as cont_distinta_clientes,
	FORMAT((ci.population * 0.25) / 1000000, 'N2') AS estimativa_consumo_milhoes
FROM sales as s
JOIN customers as cs
ON cs.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = cs.city_id
GROUP BY ci.city_name, ci.population
ORDER BY (ci.population * 0.25) / 1000000 DESC

-- 8. Qual é a receita total das vendas, considerando todas as cidades, no último trimestre de 2023?
-- Dado o último trimestre, Pune, Chennai, Bangalore, Jaipur e Delhi têm maior desempenho
-- Essas mesmas 5 cidades também têm receita geral mais alta
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
-- Pune, Chennai e Bangalore possuem maior receita média por cliente
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

SELECT
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















