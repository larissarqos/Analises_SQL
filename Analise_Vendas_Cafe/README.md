# Projeto SQL - Análise de Expansão de Negócios

## Contexto
Uma rede fictícia de lojas de café deseja ampliar seus negócios, para isso, deseja saber quais as melhores cidades para abertura de filiais, assim como quais os melhores produtos.

## Objetivos
Para identificar os melhores locais e produtos para expansão da rede, responderemos a uma série de perguntas de negócio, voltadas a atender a três pontos chave para essa identificação:
* Cidades que geram maior receita
* Produtos que mais vendem
* Estimativa de consumo para as possíveis novas lojas

## Estrutura do Projeto
### 1. Banco de dados
A base de dados está em inglês e possui quatro tabelas: city (cidades), customers (clientes), products (produtos) e sales (vendas). O dicionário de dados das tabelas se enconta ao final do arquivo. Abaixo o relacionamento das tabelas:

<p align="center">
  <img src="https://github.com/user-attachments/assets/533bf009-ce4b-45fb-9b51-532b02b91ce8" height="500" width="700"/>
</p>

### 2. Respondendo às perguntas de negócio

1. Quantos clientes por cidade nós temos?
  ```sql
SELECT
	ci.city_name AS cidade,
	COUNT(DISTINCT cs.customer_id) AS total_clientes
FROM city as ci
LEFT JOIN
customers as cs
ON cs.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_clientes DESC
```

2. Qual é o valor médio de receita por cliente em cada cidade?
  ```sql
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
```

3. Quantas unidades de cada produto foram vendidas?
  ```sql
SELECT
	p.product_name AS produto,
	COUNT(s.sale_id) AS total_pedidos
FROM products AS p
LEFT JOIN
sales AS s
ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_pedidos DESC
```

4. Quais são os três produtos mais vendidos em cada cidade?
  ```sql
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
```

5. Forneça o valor médio de vendas e aluguel estimado por cliente, de cada cidade.
  ```sql
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
```

6. Qual a estimativa, por cidade, do consumo de café, considerando o comportamento de 25% da populaçã
  ```sql
SELECT
	city_name AS cidade,
	population AS populacao,
	FORMAT((population * 0.25) / 1000000, 'N2') AS estimativa_consumo_milhoes
FROM city
ORDER BY populacao DESC
```

7. Gere uma lista de cidades com seus clientes e estimativa de consumidores de café.
  ```sql
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
```

8. Qual é a receita total das vendas, considerando todas as cidades, no último trimestre de 2023?
  ```sql
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
```

9. Informe as taxas de crescimento ou declínio nas vendas de café, ao longo do período
  ```sql
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
```

10. Identifique as 3  cidades com a maior receita média por cliente. Considere: cidade, venda, aluguel, clientes e consumidor estimado de café).
  ```sql
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
```

7. Gere uma amostra das vendas realizadas em maio de 2022
  ```sql
-- Arquivo gerado como "sale_05_2022.csv".
SELECT *
FROM retail_sales
WHERE sale_date LIKE '2022-05%'
ORDER BY sale_date ASC
```

### Dicionário dos Dados

| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| transactions_id | ID da venda  | varchar (chave primária da tabela)  |
| sale_date   | Data da venda   | date  |
| sale_time   | Hora da venda   | time(7)   |
| customer_id   | ID do cliente   | varchar(50)  |
| gender  | Gênero  | varchar(20)   |
| age   | Idade   | int  |
| category  | Categoria   | varchar(20)  |
| quantity   | Quantidade   | int   |
| price_per_unit   | Preço por unidade  | float   |
| cogs   | Custo por unidade   | float   |
| total_sale   | Valor total da venda   | float   |


