# Projeto SQL - Análise de Performance

## Contexto
O orientador de um curso disponibilizou uma série de atividades para os usuários de sua plataforma, recebendo, posteriormente, as respostas para essas atividades. Ele deseja avaliar o desempenho dos estudantes nas questões propostas, que de acordo com as respostas, podem receber pontuação negativa ou positiva.

## Objetivos
O objetivo do projeto é realizar a análise da performance dos estudantes, levando em consideração as respostas enviadas e a pontuação recebida. Para tal análise, responderemos às questões abaixo:
* Liste todos os usuários distintos e suas estatísticas (retorne nome, total de submissões e pontos ganhos)
* Calcule a média diária de pontos para cada usuário
* Encontre os 3 usuários com o maior número de envios positivos em cada dia.
* Encontre os 5 usuários com o maior número de envios incorretos.
* Apresente, por usuário, o total de respostas corretas, incorretas, e sua pontuação final
* Encontre os 10 melhores desempenhos em cada semana

## Estrutura do Projeto
### 1. Banco de dados
A base de dados está em inglês e se encontra em anexo como "data.csv". Abaixo o dicionário dos dados:

| Coluna | Descrição | Tipo de Dado |
|----------|----------|----------|
| id | ID da submissão | varchar(10), chave primária da tabela |
| user_id | ID do usuário | varchar(30) |
| question_id | ID da questão | varchar(15) |
| points | Pontos recebidos | int |
| submitted_at | Data da submissão da resposta | datetime2(7) |
| username | Nome do Usuário | varchar(50) |

### 2. Respondendo perguntas de negócio
1. Liste todos os usuários distintos e suas estatísticas (retorne nome, total de submissões e pontos ganhos)
  ```sql
SELECT
	username AS nome_usuario,
	COUNT(id) AS total_submissoes,
	SUM(points) AS total_pontos
FROM data
GROUP BY username
ORDER BY total_submissoes DESC
```

2. Calcule a média diária de pontos para cada usuário
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



