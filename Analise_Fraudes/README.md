# Projeto SQL - Análise de Fraudes

## Contexto
Uma empresa fictícia de e-commerce contou com uma série de fraudes em suas compras. Preocupados com a proporção destas, eles desejam saber qual o impacto em seu faturamento e qual o perfil dessas operações.

## Objetivos
Atendendo à demanda da empresa, faremos uma análise das transações para identificar o perfil das fraudes e seu impacto no faturamento da empresa. Nos guiaremos através das perguntas abaixo:

* Qual o total de fraudes no período avaliado?
* Qual o impacto das fraudes no faturamento?
* Que navegador é mais utilizado nas fraudes?
* Há diferença, no número de compras, entre operações comuns e fraudulentas?
* Há diferença, no tempo de cadastro até a primeira compra, entre operações comuns e fraudulentas?

## Estrutura do Projeto
### 1. Banco de dados
A base de dados está em inglês e se encontra em anexo como "fraud_data.csv". Abaixo o dicionário dos dados:

| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| user_id | Código do usuário | varchar (chave primária da tabela)  |
| signup_time | Data de cadastro com horário | datetime2(7)  |
| purchase_time | Data da primeira compra com horário | datetime2(7) |
| purchase_value | Valor da compra | float |
| device_id | Código do aparelho utilizado | varchar(20) |
| source | Origem do cliente, se através de anúncio, contato direto, busca em site | varchar(15) |
| browser | Navegador utilizado | varchar(15)  |
| sex | Gênero do usuário | varchar(5) |
| age | Idade do usuário | in  |
| ip_address | Endereço IP do aparelho utilizado | varchar(50) |
| class | Classificação da operação: 1 para fraudulenta, 0 para não fraudulenta | varchar(5) |

### 3. Respondendo perguntas de negócio
1.  Qual o total de fraudes no período avaliado?
  ```sql
-- Há um total de 14.151 fraudes entre as transações, o equivalente a 9.36% do total
SELECT
	class AS classificacao,
	COUNT(class) AS total_transacoes,
	FORMAT(COUNT(class) * 100.0 / (SELECT COUNT(class) FROM fraudes.dbo.fraud_data), 'N2') AS porcentagem
FROM fraudes.dbo.fraud_data
GROUP BY class
```
2.  Qual o impacto das fraudes no faturamento?
  ```sql
-- O faturamento total foi de R$5.057.890,00. O total em fraudes foi de R$523.488,00, pouco mais de 10% do total
SELECT
	class AS classificacao,
	SUM(purchase_value) AS faturamento
	FROM fraudes.dbo.fraud_data
GROUP BY class
```
3. Que navegador é o mais utilizado nas fraudes?
  ```sql
-- O navegador mais utilizado é o Chrome, mas ele também é o mais utilizado nas operações comuns, assim como os demais, na ordem em que se apresentam.
-- Logo, não é possível estabelecer uma relação entre o navegador e as atividades fraudulentas
SELECT
	browser,
	COUNT(*) AS total_fraudes
FROM fraud_data
WHERE class = 1
GROUP BY browser
ORDER BY COUNT(*) DESC
```
4. Há diferença, no número de compras, entre operações comuns e fraudulentas?
   Aqui, vamos considerar o ID do cliente e o ID do aparelho.
   * De acordo com o ID do cliente: Não encontramos relação entre a quantidade de compras e a classificação (se fraude ou não).
  ```sql
-- ID do cliente, compras normais
SELECT
	class AS classificacao,
	user_id AS id_usuario,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, user_id
HAVING COUNT(*) = 1 AND class = 0
ORDER BY total_compras DESC
```
  ```sql
-- ID do cliente, compras fraudulentas
SELECT
	class AS classificacao,
	user_id AS id_usuario,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, user_id
HAVING COUNT(*) = 1 AND class = 1
ORDER BY total_compras DESC
```
  * De acordo com o ID do aparelho: Enquanto usuários comuns costumam realizar até 3 transações por aparelho, usuários fraudulentos realizam mais de 15 compras num mesmo aparelho.
  ```sql
-- ID do aparelho, compras normais
SELECT
	class AS classificacao,
	device_id AS id_aparelho,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, device_id
HAVING COUNT(*) > 1 AND class = 0
ORDER BY total_compras DESC
```
  ```sql
-- ID do aparelho, compras fraudulentas
SELECT
	class AS classificacao,
	device_id AS id_usuario,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, device_id
HAVING COUNT(*) > 1 AND class = 1
ORDER BY total_compras DESC
```

5. Há diferença, no tempo de cadastro até a primeira compra, entre operações comuns e fraudulentas?
 * Compras comuns: O tempo decorrido do cadastro até a primeira compra é no mínimo 130s (pouco mais de 2 minutos)
  ```sql
-- Tempo em segundos entre cadastro e compra de operações normais
SELECT
	class AS classificacao,
	signup_time AS hora_assinatura,
	purchase_time AS hora_compra,
	DATEDIFF (SECOND, signup_time, purchase_time) AS diferenca_segundos
FROM fraudes.dbo.fraud_data WHERE class = 0
ORDER BY Diferenca_Segundos ASC
```

 * Compras fraudulentas: Marjoritariamente, contam com cadastro e compra no mesmo dia, geralmente com 1s de diferença entre cadastro e compra, o que pode indicar uso de bots para realização dessas compras
  ```sql
-- Tempo em segundos entre cadastro e compra de operações fraudulentas
SELECT
	class AS classificacao,
	signup_time AS hora_cadastro,
	purchase_time AS hora_compra,
	DATEDIFF (SECOND, signup_time, purchase_time) AS diferenca_segundos
FROM fraudes.dbo.fraud_data WHERE class = 1
ORDER BY Diferenca_Segundos ASC
```

6. Qual o perfil de cliente mais comum nas operações fraudulentas?
  ```sql
-- O perfil mais comum em fraudes é do sexo masculino, com idade entre 26-35 anos.
-- No entanto, esse também é o perfil geral predominante de clientes da empresa, então não é possível estabelecer uma relação "perfil cliente x fraude"
WITH perfil_fraude AS (
  SELECT
    class AS classificacao,
    sex AS genero,
    CASE
      WHEN age BETWEEN 18 AND 25 THEN '18-25'
      WHEN age BETWEEN 26 AND 35 THEN '26-35'
      WHEN age BETWEEN 36 AND 50 THEN '36-50'
      ELSE '50+'
    END AS faixa_etaria
  FROM fraud_data
  WHERE class = 1
),
ranking_fraude AS (
  SELECT
    genero,
    faixa_etaria,
    COUNT(*) AS total_compras,
    RANK() OVER(ORDER BY COUNT(*) DESC) AS ranking
  FROM perfil_fraude
  GROUP BY genero, faixa_etaria
)
SELECT *
FROM ranking_fraude
WHERE ranking <= 4
ORDER BY ranking
```
