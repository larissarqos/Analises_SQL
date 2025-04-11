# Projeto SQL - Análise de Fraudes

## Contexto
Uma empresa fictícia de e-commerce contou uma série de fraudes em suas compras. Preocupados com a proporção dessas fraudes, eles desejam saber qual o impacto dessas fraudes em seu faturamento e qual o perfil dessas operações fraudulentas.

## Objetivos
Atendendo à demanda da empresa, utilizaremos SQL (SQL Server) para analisar o perfil dessas transações fraudulentas e qual seu impacto no faturamento da empresa. Nos guiaremos através das perguntas abaixo:

* Qual o total de fraudes no período avaliado?
* Qual o impacto das fraudes no faturamento?
* Qual a relação entre número de compras e operações fraudulentas?
* Qual a relação do tempo de cadastro até a primeira compra com as fraudes?

## Estrutura do Projeto
### 1. Banco de dados
A base de dados está em inglês e se encontra em anexo como "fraud_data.csv". Abaixo o dicionário dos dados:

| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| user_id | Código do usuário | varchar (chave primária da tabela)  |
| signup_time | Data de cadastro com horário | date  |
| purchase_time | Data da primeira compra com horário | time(7)   |
| purchase_value | Valor da compra | varchar(50)  |
| device_id | Código do aparelho utilizado | varchar(20) |
| source | Origem do cliente, se através de anúncio, contato direto, busca em site | int  |
| browser | Navegador utilizado | varchar(20)  |
| sex | Gênero do usuário | int   |
| age | Idade do usuário | float   |
| ip_address | Endereço IP do aparelho utilizado | float |
| class | Classificação da operação: 1 para fraudulenta, 0 para não fraudulenta | float   |

### 3. Respondendo perguntas de negócio
Para realizar a análise que nos ajudará a entender melhor as fraudes, responderemos a uma série de perguntas.
1.  Qual o total de fraudes no período avaliado?
  ```sql
-- Há um total de 14.151 fraudes entre as transações.
-- 90.64% das transações são ok, enquanto 9.36% são fraudulentas
SELECT
	class AS classificacao,
	COUNT(class) AS total_transacoes,
	FORMAT(COUNT(class) * 100.0 / (SELECT COUNT(class) FROM fraudes.dbo.fraud_data), 'N2') AS porcentagem
FROM fraudes.dbo.fraud_data
GROUP BY class
```
2.  Qual o impacto das fraudes no faturamento?
  ```sql
-- O faturamento total foi de R$5.057890,00. O total em fraudes foi de R$523.488,00
SELECT
	class AS classificacao,
	SUM(CAST(purchase_value as int)) AS faturamento
	FROM fraudes.dbo.fraud_data
GROUP BY class
```
3. Qual a relação entre número de compras e operações fraudulentas?
  ```sql
-- Contamos com 3 categorias: Clothing, Eletronics e Beauty
SELECT DISTINCT category
FROM retail_sales
```
4. Qual a relação do tempo de cadastro até a primeira compra nas operações fraudulentas?
  ```sql
O faturamento total é de 908.230 dólares
SELECT SUM(total_sale) AS faturamento_total
FROM retail_sales
```


1. Qual categoria foi a mais comprada por nossos clientes e qual o valor total?
  ```sql
-- A categoria mais compra foi Clothing: 698 vendas (35,13% do total).
-- Considerando o faturamento, a categoria Eletronics teve maior rendimento: 311.445 dólares (34,29% do total).
SELECT category,
	COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY category 
ORDER BY total_pedidos DESC
```

2. A quantidade de vendas e o faturamento apresenta grande diferença por gênero?
  ```sql
-- Não. Tanto o gênero feminino quanto masculino têm impacto semelhante nas vendas e faturamento:
-- Feminino: 1012 pedidos (50.93% do total de vendas); Valor total de 463.110 dólares (50.99% do faturamento);
-- Masculino: 975 pedidos (49,07% do total de vendas); Valor total de 445.120 dólares (49,01% do faturamento).
SELECT gender,
COUNT(*) AS total_pedidos,
	SUM(total_sale) AS valor_total
FROM retail_sales
GROUP BY gender 
ORDER BY valor_total DESC
```

3. Gere uma amostra de transações com valor total igual ou maior a 1000
  ```sql
--Arquivo gerado como "sales_equals_higher_1000.csv".
SELECT *
FROM retail_sales
WHERE total_sale >= 1000
ORDER BY total_sale ASC
```

4. Quais os 5 clientes que mais compraram conosco?
  ```sql
-- Os clientes de maior valor do período foram os de ID: 3, 1, 5, 2 e 4.
SELECT TOP 5 customer_id,
	SUM(total_sale) as valor_total
FROM retail_sales
GROUP BY customer_id
ORDER BY valor_total DESC
```

5. Qual o total de vendas, considerando o gênero dos clientes e categoria dos produtos?
  ```sql
SELECT category,
	gender,
	COUNT(*) AS total_vendas
	FROM retail_sales
GROUP BY category, gender
ORDER BY total_vendas DESC
```

6. Qual a média de idade dos clientes que compram na categoria 'Beauty', do gênero feminino?
  ```sql
-- De acordo com a categoria Beauty, a média de idade pa é de 40 anos para o gênero feminino.
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
  ```sql
-- Arquivo gerado como "sale_05_2022.csv".
SELECT *
FROM retail_sales
WHERE sale_date LIKE '2022-05%'
ORDER BY sale_date ASC
```

8. Retorne as transações de categoria 'Clothing', em que a quantidade vendida é mais que 10, no mês de novembro
  ```sql
-- A quantidade máxima vendida da categoria 'Clothing' em novembro de 2022 é 4.
-- Não há quantidade de vendas maior ou igual a 10.
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND sale_date LIKE '2022-11%'
	AND quantity >= 4
```

9. Indique o valor médio em vendas de cada mês
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
  ```sql
-- 2022: mês de julho; 2023: mês de fevereiro
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
  ```sql
-- O turno da noite possui o maior número de transações: 1062 pedidos (53,45% do total).
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


