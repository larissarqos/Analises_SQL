# Projeto SQL - Análise de Vendas

## Contexto
O projeto visa analisar uma base de dados de vendas, realizando a análise exploratória desses dados e respondendo a perguntas de negócio.
## Objetivos
O objetivo do projeto é inicialmente tratar os dados, realizar uma análise exploratória geral para entender melhor as informações disponíveis e por fim responder a uma série de perguntas de negócios, trazendo insights sobre as vendas.

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
     Resposta: Contamos com um total de 1987 vendas
  ```sql
SELECT COUNT(*) AS total_vendas
FROM retail_sales
```
