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
| transactions_id | id da venda  | varchar (chave primária da tabela)  |
| sale_date   | data da venda   | date  |
| sale_time   | hoda da venda   | time(7)   |
| customer_id   | id do cliente   | varchar(50)  |
| gender  | gênero  | varchar(20)   |
| age   | idade   | int  |
| category  | categoria   | varchar(20)  |
| quantity   | quantidade   | int   |
| price_per_unit   | Preço por unidade  | float   |
| cogs   | Custo por unidade   | float   |
| total_sale   | Valor total da venda   | float   |
