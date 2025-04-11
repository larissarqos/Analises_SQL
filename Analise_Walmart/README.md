# Projeto SQL - Análise de Vendas Walmart

## Contexto
O projeto busca analisar um recorte de vendas do Walmart (dados retirados do Kaggle), levando em consideração filiais, categorias de produtos e métodos de pagamento, para identificar o desempenho de cada um desses fatores e suas relações.

## Objetivos
Iniciaremos realizando uma limpeza e tratamento dos dados através do Python e então análise exploratória dos dados para entender melhor as informações disponíveis, seguida da resolução de problemas de negócio.

## Estrutura do Projeto
### 1. Banco de dados
A base de dados está em inglês e se encontra em anexo como "retail_sales.csv". As datas estão no formato americano (mês/dia/ano) e os valores relacionados a dinheiro são em dólar. Abaixo o dicionário dos dados:

| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| invoice_id | ID da venda | varchar(15), chave primária da tabela |
| branch | Filial | varchar(15) |
| city | Cidade | varchar(30) |
| category | Categoria do produto | varchar(20)  |
| unit_price | Preço unitário do produto | float |
| quantity | Quantidade vendida | int |
| date | Data da venda | date |
| time | Hora da venda | time(7) |
| payment_method | Método de pagamento | varchar(15) |
| rating | Avaliação do produto | float |
| profit_margin | Margem de lucro | float   |
| total | Receita total (unit_price * quantity) | float |

### 2. Limpeza dos dados
```python
# == Visão geral da base de dados ==
# Head
df.head()

# Shape
df.shape

# Describe
df.describe()

# Info
df.info()

# == Limpeza ==
# Identificando dados duplicados
df.duplicated().sum()

# Removendo duplicadas
df.drop_duplicates(inplace = True)
df.duplicated().sum()

# Identificando valores nulos
df.isnull().sum()

# Removendo valores nulos
df.dropna(inplace = True)
df.isnull().sum()

# == Verificando base de dados após limpeza ==
# Shape
df.shape

# Tipo dos dados
df.dtypes

# == Ajustando informações ==
# Convertendo o tipo object para float da coluna unit_price. Para isso removeremos o '$'
df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)

# Criando coluna com valor total das vendas (unit_price * quantitiy)
df['total'] = df['unit_price'] * df['quantity']
df.head()

# Ajustando o nome das colunas para tudo com letra minúscula
df.columns = df.columns.str.lower()
df.head()

# Exportando dados tratados
df.to_csv('walmart_data_cleaned.csv', index  = False)
```

### 3. Análise exploratória dos dados
1. Qual o total de transações analisadas?
  ```sql
-- Contamos com 9.969 transações
SELECT COUNT(*)
FROM walmart_data
```

2. Quais os tipos de pagamento?
  ```sql
-- Há 3 tipos de pagamento: Credit card, Ewallet e Cash
SELECT
	payment_method AS metodo_pagamento,
	COUNT(*) AS total
FROM walmart_data
GROUP BY payment_method
ORDER BY total DESC
```

3. Qual o total de filiais?
  ```sql
-- Contamos com 100 filiais
SELECT
	COUNT(DISTINCT branch) AS total_filiais
FROM walmart_data
```

4. Qual a quantidade máxima de itens comprados por venda?
  ```sql
-- A quantidade máxima de itens comprados por venda foi 10
SELECT MAX(quantity) AS qtd_maxima
FROM walmart_data
```

5. Qual a quantidade mínima de itens comprados por venda?
  ```sql
-- A quantidade mínima de itens comprados por venda foi 1
SELECT MIN(quantity) As qtd_minima
FROM walmart_data
```

### 4. Análise dos dados e solução de problemas de negócios
1. Qual o método de pagamento mais utilizado? Indique também a quantidade vendida por método
  ```sql
-- O método mais utilizado é Credit card, possuindo também a maior quantia de vendas (9.567)
SELECT
	payment_method AS metodo_pagamento,
	COUNT(*) AS qtd_pagamentos,
	SUM(quantity) AS qtd_vendida
FROM walmart_data
GROUP BY payment_method
ORDER BY qtd_pagamentos DESC
```

2. Qual a receita por tipo de pagamento?
  ```sql
-- Credit card: 488.821,02; Ewallet: 457.316,07; Cash: 263.589,29
SELECT
	payment_method AS metodo_pagamento,
	SUM(total) AS receita
FROM walmart_data
GROUP BY payment_method
ORDER BY receita DESC
```

3. Qual o método de pagamento mais utilizado em cada filial?
  ```sql
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
```
4. Qual a categoria mais bem avaliada em cada filial?
  ```sql
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
```

5. Qual dia da semana possui mais transações? Avalie por filial
  ```sql
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
```

6. Quais os valores médio, mínimo e máximo das avaliações de categoria dos produtos, por cidade?
  ```sql
SELECT
	city AS cidade,
	category AS categoria,
	MIN(rating) AS nota_minima,
	MAX(rating) AS nota_maxima,
	ROUND(AVG(rating), 2) AS media_nota
FROM walmart_data
GROUP BY city, category
ORDER BY city, category
```

7. Quais os 3 meses com maior receita média no último ano?
  ```sql
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
```

8. Qual a margem total de lucro para cada categoria? Considere: Margem de lucro total = (total * profit_margin)
  ```sql
SELECT
	category AS categoria,
	SUM(total) as receita_total,
	ROUND(SUM(total * profit_margin), 2) AS margem_lucro
FROM walmart_data
GROUP BY category
ORDER BY receita_total DESC
```

9. Qual o total de transações de acordo com o turno (manhã, tarde e noite), em cada filial?
  ```sql
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
```

10. Quais as 5 filiais com a maior taxa de redução de receita do ano passado para o ano atual? Considere: Taxa = (última_receita - receita_atual) / ultima_receita * 100
  ```sql
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
```

