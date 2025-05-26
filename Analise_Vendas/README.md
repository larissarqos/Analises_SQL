<h1 align="center"> SQL - Análise de Vendas </h1>

<p align="center">
  <img src="https://github.com/user-attachments/assets/f4ad952c-19f4-4e2a-a73c-94b8aa0facdc" alt="img" width="1100"/>
</p>

<br>


## 📃 Contexto 
O projeto conta com uma base de dados de venda fictícia, em que será feita a limpeza e tratamento dos dados, uma análise exploratória e por fim, uma série de soluções a perguntas de negócio, voltadas a identificar os fatores que mais influenciam a quantidade de vendas e faturamento.

***

<br>

## 🛠️ Ferramentas e Métodos Utilizados
- Microsoft Excel (fórmulas, tabelas dinâmicas, gráficos, slicers)
- Business Intelligence
  
***

<br>

## 🎯 Objetivos  
O objetivo do projeto é realizar uma limpeza dos dados, identificando valores nulos; uma análise exploratória para entender melhor as informações disponíveis e então resolver os problemas de negócio apresentados, trazendo insights sobre as vendas.

***

<br>

## 🧱 Estrutura do Projeto  
### 🗄 Banco de dados 
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

***

<br>

### 🧹 Limpeza dos dados
#### Verificação e tratamento de valores nulos

```sql
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

***

<br>

### 🔎 Análise exploratória dos dados
Para realizar a análise exploratória, foram respondidas as seguinte perguntas:
#### 📌 1. Qual o total de vendas?  
Contamos com um total de 1987 vendas

  ```sql
SELECT COUNT(*) AS total_vendas
FROM retail_sales
```
--

#### 📌 2. Qual o total de clientes?  
Contamos com um total 155 clientes
  ```sql
SELECT COUNT(DISTINCT customer_id) AS total_clientes
FROM retail_sales
```
--

#### 📌 3. Quantas e quais são as categorias dos nossos produtos?  
Contamos com 3 categorias: Clothing, Eletronics e Beauty
  ```sql
SELECT DISTINCT category
FROM retail_sales
```
--

#### 📌 4. Qual o faturamento total?  
O faturamento total é de 908.230 dólares
  ```sql
SELECT SUM(total_sale) AS faturamento_total
FROM retail_sales
```

***

<br>

### 📍 Solução de problemas de negócios
Aqui, serão respondidas uma série de perguntas de negócio para entendermos os principais fatores que
impactam as vendas e faturamento, considerando o perfil dos clientes, categoria dos produtos e o período de venda

#### 📌 1. Qual categoria foi a mais comprada por nossos clientes e qual o valor total?  
A categoria mais comprada foi **Clothing: 698 vendas** (35,13% do total).Considerando o faturamento, a categoria **Eletronics teve maior rendimento**: 311.445 dólares (34,29% do total).
  ```sql
SELECT category,
	COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY category 
ORDER BY total_pedidos DESC
```
--

#### 📌 2. A quantidade de vendas e o faturamento apresenta grande diferença por gênero?  
Não. Tanto o gênero feminino quanto masculino têm impacto semelhante nas vendas e faturamento:
* Feminino: 1012 pedidos (50.93% do total de vendas); Valor total de 463.110 dólares (50.99% do faturamento);
* Masculino: 975 pedidos (49,07% do total de vendas); Valor total de 445.120 dólares (49,01% do faturamento)

```sql
SELECT gender,
COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY gender 
ORDER BY valor_total DESC
```
--

#### 📌 3. Gere uma amostra de transações com valor total igual ou maior a 1000.  
Arquivo gerado como "sales_equals_higher_1000.csv".
  ```sql
SELECT *
FROM retail_sales
WHERE total_sale >= 1000
ORDER BY total_sale ASC
```
--

#### 📌 4. Quais os 5 clientes que mais compraram conosco?  
 Os clientes de maior valor do período foram os de ID: 3, 1, 5, 2 e 4.
  ```sql
SELECT TOP 5 customer_id,
	SUM(total_sale) as valor_total
FROM retail_sales
GROUP BY customer_id
ORDER BY valor_total DESC
```
--

#### 📌 5. Qual o total de vendas, considerando o gênero dos clientes e categoria dos produtos?
  ```sql
SELECT category,
	gender,
	COUNT(*) AS total_vendas
	FROM retail_sales
GROUP BY category, gender
ORDER BY total_vendas DESC
```
--

#### 📌 6. Qual a média de idade dos clientes que compram na categoria 'Beauty', do gênero feminino?  
-- De acordo com a categoria Beauty, a média de idade pa é de 40 anos para o gênero feminino.
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
--

#### 📌 7. Gere uma amostra das vendas realizadas em maio de 2022  
Arquivo gerado como "sale_05_2022.csv".
  ```sql
SELECT *
FROM retail_sales
WHERE sale_date LIKE '2022-05%'
ORDER BY sale_date ASC
```
--

#### 📌 8. Retorne as transações de categoria 'Clothing', em que a quantidade vendida é mais que 10, no mês de novembro   
 Não há quantidade de vendas maior ou igual a 10.
  ```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND sale_date LIKE '2022-11%'
	AND quantity >= 4
```
--

#### 📌 9. Indique o valor médio em vendas de cada mês
  ```sql
SELECT
	DATEPART(yyyy, sale_date) AS ano_venda,
	DATEPART(month, sale_date) AS mes_venda,
	ROUND(AVG(total_sale), 2) AS total_vendas
FROM retail_sales
GROUP BY DATEPART(yyyy, sale_date), DATEPART(month, sale_date)
ORDER BY ano_venda, total_vendas DESC
```
--

#### 📌 10. Qual o mês de melhor desempenho em cada ano?  
2022: mês de julho; 2023: mês de fevereiro
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
--

#### 📌 11. Organize os horários de compra em turnos (manhã, tarde e noite) e indique que turnos contém mais transações. Considere: 
** - Manhã <=12;
- Tarde > 12, <=17;
- Noite > 17.**  
O turno da noite possui o maior número de transações: 1062 pedidos (53,45% do total).

```sql
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
```

