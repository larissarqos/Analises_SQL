# Projeto SQL - Análise de Fraudes

## Contexto
Uma empresa fictícia de e-commerce contou uma série de fraudes em suas compras. Preocupados com a proporção destas, eles desejam saber qual o impacto em seu faturamento e qual o perfil dessas operações.

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
Para realizar a análise que nos ajudará a entender melhor as fraudes, responderemos a uma série de perguntas.
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
   * Vamos considerar o ID do cliente e o ID do aparelho.
ID do cliente: Não encontramos relação entre a quantidade de compras e a classificação (se fraude ou não).
| Operações Comuns | Operações Fraudulentas |
|----------|----------|
|   ```sql
O faturamento total é de 908.230 dólares
SELECT SUM(total_sale) AS faturamento_total
FROM retail_sales
``` |  opa |




  ```sql
-- Contamos com 3 categorias: Clothing, Eletronics e Beauty
SELECT DISTINCT category
FROM retail_sales
```
5. Qual a relação do tempo de cadastro até a primeira compra nas operações fraudulentas?
  ```sql
O faturamento total é de 908.230 dólares
SELECT SUM(total_sale) AS faturamento_total
FROM retail_sales
```


6. Qual categoria foi a mais comprada por nossos clientes e qual o valor total?
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





