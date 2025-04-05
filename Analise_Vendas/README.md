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
