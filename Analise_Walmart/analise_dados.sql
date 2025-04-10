USE walmart
GO

-- == Análise Exploratória dos Dados ==

-- Total de transações
-- Contamos com 9.969 transações
SELECT COUNT(*)
FROM walmart_data

-- Tipos de pagamento
-- Há 3 tipos de pagamento: Credit card, Ewallet e Cash
SELECT
	payment_method AS metodo_pagamento,
	COUNT(*) AS total
FROM walmart_data
GROUP BY payment_method
ORDER BY total DESC

-- Total de filiais
-- Contamos com 100 filiais
SELECT
	COUNT(DISTINCT branch) AS total_filiais
FROM walmart_data

-- Quantidade máxima de itens comprados por venda
-- A quantidade máxima de itens comprados por venda foi 10
SELECT MAX(quantity) AS qtd_maxima
FROM walmart_data

-- Quantidade mínima de itens comprados por venda
-- A quantidade mínima de itens comprados por venda foi 1
SELECT MIN(quantity) As qtd_minima
FROM walmart_data

-- == Resolvendo problemas de negócio ==

-- 1. Qual o método de pagamento mais utilizado? Indique também a quantidade vendida por método
-- O método mais utilizado é Credit card, possuindo também a maior quantia de vendas (9.567)
SELECT
	payment_method AS metodo_pagamento,
	COUNT(*) AS qtd_pagamentos,
	SUM(quantity) AS qtd_vendida
FROM walmart_data
GROUP BY payment_method
ORDER BY qtd_pagamentos DESC

-- 2. Qual a receita por tipo de pagamento?
-- Credit card: 488.821,02; Ewallet: 457.316,07; Cash: 263.589,29
SELECT
	payment_method AS metodo_pagamento,
	SUM(total) AS receita
FROM walmart_data
GROUP BY payment_method
ORDER BY receita DESC

-- 3. Qual o método de pagamento mais utilizado em cada filial?
SELECT *
FROM
	(SELECT
		branch AS filial,
		payment_method AS metodo_pagamento,
		COUNT(*) AS total_transacoes,
		RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) AS ranking
	FROM walmart_data
	GROUP BY branch, payment_method
) AS ranking_metodo_pagamento
WHERE ranking = 1

-- 4. Qual a categoria mais bem avaliada em cada filial?
SELECT *
FROM
(	SELECT
		branch AS filial,
		category AS categoria,
		ROUND(AVG(rating), 2) AS avaliacao_media,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
	FROM walmart_data
	GROUP BY branch, category
) AS ranking_por_filial
WHERE ranking = 1

-- 5. Qual dia da semana possui mais transações? Avalie por filial
SELECT *
FROM
	(SELECT
		branch AS filial,
		DATENAME(WEEKDAY, date) AS dia,
		COUNT(*) AS total_transacoes,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM walmart_data
	GROUP BY branch, DATENAME(WEEKDAY, date)
) AS ranking_por_dia
WHERE ranking = 1

-- 6. Quais os valores médio, mínimo e máximo das avaliações de categoria dos produtos, por cidade?
SELECT
	city AS cidade,
	category AS categoria,
	MIN(rating) AS nota_minima,
	MAX(rating) AS nota_maxima,
	ROUND(AVG(rating), 2) AS media_nota
FROM walmart_data
GROUP BY city, category
ORDER BY city, category

-- 7. Quais os 3 meses com maior receita média no último ano?
SELECT * FROM
(	
	SELECT
			DATEPART(YEAR, date) AS ano,
			DATENAME(MONTH, date) AS mes,
			ROUND(AVG(total), 2) AS receita_media,
			RANK() OVER(PARTITION BY DATEPART(YEAR, date) ORDER BY ROUND(AVG(total), 2) DESC) AS ranking
	FROM walmart_data
	GROUP BY DATEPART(YEAR, date), DATENAME(MONTH, date)
) AS resultado
WHERE ano = 2023 AND ranking IN (1, 2, 3)

-- 8. Qual a margem de lucro total para cada categoria? Considere: Margem de lucro total = (total * profit_margin)
SELECT
	category AS categoria,
	SUM(total) as receita_total,
	ROUND(SUM(total * profit_margin), 2) AS margem_lucro
FROM walmart_data
GROUP BY category
ORDER BY receita_total DESC

-- 9. Qual o total de transações de acordo com o turno (manhã, tarde e noite), em cada filial?
SELECT
	branch AS filial,
	turno,
	COUNT(*) AS total
FROM (
	SELECT
		branch,
		CASE
			WHEN DATEPART(HOUR, time) < 12 THEN 'Manhã'
			WHEN DATEPART(HOUR, time) BETWEEN 12 AND 17 THEN 'Tarde'
			ELSE 'Noite'
		END AS turno
	FROM walmart_data
) AS vendas_por_turno
GROUP BY branch, turno
ORDER BY branch, turno DESC

-- 10. Quais as 5 filiais com a maior taxa de redução de receita do ano passado para o ano atual?
-- Taxa: (última_receita - receita_atual) / ultima_receita * 100

-- Vendas de 2022
WITH vendas_2022 AS
(
	SELECT
		branch AS filial,
		SUM(total) AS receita,
		DATEPART(YEAR, date) AS ano_venda
	FROM walmart_data
	WHERE DATEPART(YEAR, date) = 2022
	GROUP BY branch, DATEPART(YEAR, date)
),
vendas_2023 AS
(
	SELECT
		branch AS filial,
		SUM(total) AS receita,
		DATEPART(YEAR, date) AS ano_venda
	FROM walmart_data
	WHERE DATEPART(YEAR, date) = 2023
	GROUP BY branch, DATEPART(YEAR, date)
)

SELECT
	TOP 5 ua.filial,
	ua.receita AS receita_ultimo_ano,
	aa.receita AS receita_ano_atual, 
	ROUND((ua.receita - aa.receita) / ua.receita * 100, 2) AS taxa_reducao
FROM vendas_2022 AS ua -- último ano
JOIN vendas_2023 AS aa -- ano atual
ON ua.filial = aa.filial
WHERE ua.receita > aa.receita
ORDER BY taxa_reducao DESC
