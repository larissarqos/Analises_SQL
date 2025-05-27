<h1 align="center">Análise - Expansão de Rede de Lojas </h1>

<p align="center">
  <img src="https://github.com/user-attachments/assets/691c4372-49e4-43d2-92b2-b32e98b721cb" alt="img" width="1100"/>
</p>

<br>

## 📃 Contexto 
Uma rede fictícia de cafeterias deseja ampliar seus negócios, abrindo novas filiais em cidades promissoras. A rede deseja saber os melhores locais e produtos para abertura de suas novas lojas, com base no rendimento de suas vendas em filiais já existentes.

***

<br>

## 🛠️ Ferramentas e Métodos Utilizados
### 🔸 Métodos
- Limpeza e tratamento de dados
- Análise exploratória
- Engenharia de atributos
- Estatística
- Businnes Intelligence

### 🔸 Ferramentas
- SQL Server (window function)
- Excel (fonte de dados)
- Power BI (visualização)
  
***

<br>

## 🎯 Objetivos 
Identificaremos os lugares com possibilidade de maior retorno, bem como os produtos de maior sucesso das cafeterias. Basicamente 3 pontos principais guiarão a análise:
* Cidades que geram maior receita
* Produtos que mais vendem
* Estimativa de consumo para as possíveis novas lojas

***

<br>

## 🧱 Estrutura do Projeto

#### - Banco de dados
#### - Respondendo às perguntas de negócio
#### - Recomendações Estratégicas

***

<br>

### 🗄 Banco de dados
A base de dados está em inglês e possui quatro tabelas: city (cidades), customers (clientes), products (produtos) e sales (vendas). Segue abaixo o dicionário dos dados e o relacionamento das tabelas:

**Tabela city**
| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| city_id | ID da cidade  | varchar(15), chave primária da tabela  |
| city_name   | Nome da cidade   | varchar(20)  |
| population   | Quantidade de habitantes  |  bigint |
| estimated_rent  | Valor estimado do aluguel   | float  |
| city_rank  | Ranking das cidades  | int  |

**Tabela customers**
| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| customer_id | ID do cliente  | varchar(15), chave primária da tabela |
| customer_name   | Nome do cliente   | varchar(50)  |
| city_id   |  ID da cidade  | varchar(15), chave estrangeira  |

**Tabela products**
| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| product_id | ID do produto  | varchar(15), chave primária da tabela  |
| product_name   | Nome do produto   | varchar(40)  |
| price   | Preco do produto   | float   |

**Tabela sales**
| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| sale_id | ID da venda  | varchar(15), chave primária da tabela  |
| sale_date   | Data da venda   | date  |
| product_id   | ID do produto  | varchar(15), chave estrangeira  |
| customer_id  | ID do cliente   | varchar(15), chave estrangeira |
| total  | Valor total da venda  | floar   |
| rating  | Nota da venda, de 1 a 5   | int  |


<h4 align="center">Relacionamento das Tabelas</h4>
<p align="center">
  <img src="https://github.com/user-attachments/assets/533bf009-ce4b-45fb-9b51-532b02b91ce8" height="400" width="600"/>
</p>

<br>

### 📍 Respondendo às perguntas de negócio

#### 📌 1. Quantos clientes por cidade nós temos?
  ```sql
-- Organizando um "TOP 3", Jaipur, Delhi e Pune possuem maior quantidade de clientes (acima de 50)
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
--

#### 📌 2. Qual é o valor médio de receita por cliente em cada cidade?
  ```sql
-- Em termos de receita, analisando novamente os 3 maiores índices, Pune, Chennai e Bangalore encabeçam a lista
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
--

#### 📌 3. Quantas unidades de cada produto foram vendidas?
  ```sql
-- Há 4 produtos com maior destaque nas vendas:
-- Cold Brew Coffee Pack (6 Bottles), Ground Espresso Coffee (250g), Instant Coffee Powder (100g) e Coffee Beans (500g)
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
--

#### 📌 4. Quais são os três produtos mais vendidos em cada cidade?
  ```sql
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
```
--

#### 📌 5. Forneça o valor médio de vendas e aluguel estimado por cliente, de cada cidade.
  ```sql
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
```
--

#### 📌 6. Qual a estimativa, por cidade, do consumo de café, considerando o comportamento de 25% da população?
  ```sql
-- Delhi e Mumbai têm maiores populações e, consequentemente, uma maior estimativa de consumo
SELECT
	city_name AS cidade,
	population AS populacao,
	FORMAT((population * 0.25) / 1000000, 'N2') AS estimativa_consumo_milhoes
FROM city
ORDER BY populacao DESC
```
--

#### 📌 7. Gere uma lista de cidades com seus clientes e estimativa de consumidores de café.
  ```sql
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
```
--

#### 📌 8. Qual é a receita total das vendas, considerando todas as cidades, no último trimestre de 2023?
  ```sql
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
```
--

#### 📌 9. Informe as taxas de crescimento ou declínio nas vendas de café, ao longo do período
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
--

#### 📌 10. Identifique as 3  cidades com a maior receita média por cliente. Considere: cidade, venda, aluguel, clientes e consumidor estimado de café).
  ```sql
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
```
<br>

### 📈 Recomendações Estratégicas
De acordo com a análise dos dados, segue as melhores cidades para novas lojas (menor custo e maiores estimativas de receita e quantidade de clientes) e os produtos de melhor desempenho:

#### 🟦 Cidades:
   * **Delhi:** Segunda maior quantidade de clientes (68); Maior estimativa de consumidores (7,7 milhões); Média de aluguel baixa (330);
   * **Pune:** Terceira maior quantidade de clientes (52); Maior receita média por clientes (24 mil); Média de aluguel baixa (294);
   * **Jaipur:** Maior quantidade de clientes (69); Receita média considerável (11 mil); Menor média de aluguel (156);
   * **Chennai:** Quarta maior quantidade de clientes (42); Segunda maior receita média (22 mil); Estimativa de consumidores considerável (2,78 milhões).
     
#### 🟦 Produtos:
   * **Cold Brew Coffee Pack (6 Bottles):** Possui maior quantidade de vendas (1326) e gera também a maior receita (1.193.400);
   * **Coffee Beans (500g):** Terceira maior quantidade de vendas (1218) e segunda maior receita (730.800);
   * **Ground Espresso Coffee (250g):** Segunda maior quantidade de clientes (1271) e quarta maior receita (444.850);
   * **Instante Coffee Powder (100g):** Alta quantidade de vendas (1226) e faturamento considerável (306.500);
   * **Coffee Gift Hamper:** Apesar da baixa quantidade de vendas comparado aos produtos anteriores (270), gerou a terceira maior receita (486.000).

***

<br>

### 🚀 Impacto Esperado

#### 🟩

***

<br>

*Este projeto foi desenvolvido como parte do meu portfólio em análise de dados. Sinta-se à vontade para explorar os dados, sugerir melhorias ou entrar em contato!*
