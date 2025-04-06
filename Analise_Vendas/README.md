# Projeto SQL - Análise de Vendas

## Contexto
O projeto visa analisar uma base de vendas, identificando os fatores que mais influenciam a quantidade de vendas e faturamento.

## Objetivos
O objetivo do projeto é realizar uma análise exploratória geral para entender melhor as informações disponíveis e por fim responder a uma série de perguntas de negócios, trazendo insights sobre as vendas.

## Estrutura do Projeto
### 1. Banco de dados
A base de dados está em inglês e se encontra em anexo como "retail_sales.csv". As datas estão no formato americano (mês/dia/ano) e os valores relacionados a dinheiro são em dólar. Abaixo o dicionário dos dados:

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

### 2. Limpeza dos dados
* Verificação e tratamento de valores nulos
```sql
-- VISÃO GERAL DOS DADOS
SELECT * FROM retail_sales

-- VERIFICANDO VALORES NULOS
-- No processo de importação dos dados, valores nulos foram convertidos em 0
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
-- Antes da exclusão, foi verificado na base de dados original se todos os valores 0 eram de fato os nulos,
-- o que foi confirmado
DELETE FROM retail_sales
WHERE customer_id = '0'
OR gender = '0'
OR age = '0'
OR category = '0'
OR quantity = '0'
OR price_per_unit = '0'
OR cogs = '0'
OR total_sale = '0'
```

### 3. Análise exploratória dos dados
Para realizar a análise exploratória, foram respondidas as seguinte perguntas:
1. Qual o total de vendas?
  * Resposta: Contamos com um total de 1987 vendas
  ```sql
SELECT COUNT(*) AS total_vendas
FROM retail_sales
```
2. Qual o total de clientes?
  * Resposta: Contamos com um total 155 clientes
  ```sql
SELECT COUNT(DISTINCT customer_id) AS total_clientes
FROM retail_sales
```
3. Quantas e quais são as categorias dos nossos produtos?
  * Resposta:Contamos com 3 categorias: clothing, eletronics e beauty
  ```sql
SELECT DISTINCT category
FROM retail_sales
```
### 3. Análise dos dados e solução de problemas de negócios
Aqui, serão respondidas uma série de perguntas de negócio para entendermos os principais fatores que
impactam as vendas e faturamento, considerando o perfil dos clientes, categoria dos produtos e o período de venda

1. Qual categoria foi a mais comprada por nossos clientes e qual o valor total?
  * Resposta: A categoria Clothing foi a mais comprada, com um valor total de venda de $309,995.
    Considerando o faturamento, a categoria Eletronics teve maior faturamento, 311,445.
  ```sql
SELECT category,
	COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY category 
ORDER BY total_pedidos DESC
```
2. A quantidade de vendas e o faturamento apresenta grande diferença por gênero?
  * Resposa: Não. Tanto o gênero feminino quanto masculino têm impacto semelhante nas vendas e faturamento:
    - Feminino: 1012 pedidos (50.93% do total de vendas); Valor total de $463,.110 (50.99% do faturamento);
    - Masculino: 975 pedidos (49,07% do total de vendas); Valor total de $445,120 (49,01% do faturamento).
  ```sql
SELECT gender,
COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY gender 
ORDER BY valor_total DESC
```
3. Gere uma amostra de transações com valor total igual ou maior a 1000
  * Resposta: Arquivo gerado como "sales_equals_higher_1000.csv".
  ```sql
SELECT *
FROM retail_sales
WHERE total_sale >= 1000
ORDER BY total_sale ASC
```
4. Quais os 5 clientes que mais compraram conosco?
  * Resposta: Os clientes de maior valor do período foram os de ID: 3, 1, 5, 2 e 4.
  ```sql
SELECT TOP 5 customer_id,
	SUM(total_sale) as valor_total
FROM retail_sales
GROUP BY customer_id
ORDER BY valor_total DESC
```
5. Qual o total de vendas, considerando o gênero dos clientes e categoria dos produtos?
  * Resposta: Analisando o total de vendas pela categoria do produto e gênero dos clientes, temos que:
| Categoria | Genero | Total Vendas |
|----------|----------|----------|
| Clothing | Male  | 351  |
| Clothing  | Female   | 347  |
| Eletronics  | Male   | 343   |
| Eletronics   | Female  | 335  |
| Beauty  | Female  | 330   |
| Beauty   | Male   | 281  |

  ```sql
SELECT category,
	gender,
	COUNT(*) AS total_vendas
	FROM retail_sales
GROUP BY category, gender
ORDER BY total_vendas DESC
```
6. Qual a média de idade dos clientes que compram na categoria 'Beauty', do gênero feminino?
  * Resposta: De acordo com a categoria Beauty, a média de idade pa é de 40 anos para o gênero feminino.
  ```sql
SELECT 
	category,
	gender,
	ROUND(AVG(age), 2) AS media_idade
FROM retail_sales
WHERE category = 'Beauty' AND gender = 'Female'
GROUP BY gender, category
ORDER BY gender
```
7. Gere uma amostra das vendas realizadas em maio de 2022
  * Resposta: Arquivo gerado como "sale_05_2022.csv".
  ```sql
SELECT *
FROM retail_sales
WHERE sale_date LIKE '2022-05%'
ORDER BY sale_date ASC
```
8. Retorne as transações de categoria 'Clothing', em que a quantidade vendida é mais que 10, no mês de novembro
  * Resposta: A quantidade máxima vendida da categoria 'Clothing' em novembro de 2022 é 4.
    Não há quantidade de vendas maior ou igual a 10.
  ```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND sale_date LIKE '2022-11%'
	AND quantity >= 4
```
9. Indique o valor médio em vendas de cada mês
10. 
  ```sql
SELECT
	DATEPART(yyyy, sale_date) AS ano_venda,
	DATEPART(month, sale_date) AS mes_venda,
	ROUND(AVG(total_sale), 2) AS total_vendas
FROM retail_sales
GROUP BY DATEPART(yyyy, sale_date), DATEPART(month, sale_date)
ORDER BY ano_venda, total_vendas DESC
```
10. Qual o mês de melhor desempenho em cada ano?
  * Resposta: A quantidade máxima vendida da categoria 'Clothing' em novembro de 2022 é 4.
  ```sql
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
```
11. Organize os horários de compra em turnos (manhã, tarde e noite) e indique que turnos contém mais transações.
    Considere: Manhã <=12; Tarde > 12, <=17; Noite > 17
  * Resposta: A quantidade máxima vendida da categoria 'Clothing' em novembro de 2022 é 4.
  ```sql
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
```

