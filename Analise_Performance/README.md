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
SELECT 
    FORMAT(submitted_at, 'dd/MM') AS dia,
    username AS nome_usuario,
    AVG(points) AS media_diaria_pontos
FROM data
GROUP BY FORMAT(submitted_at, 'dd/MM'), username
ORDER BY username
```

3. Encontre os 3 usuários com o maior número de envios positivos em cada dia
  ```sql
WITH submissoes_dia
AS
(	
	SELECT
		FORMAT(submitted_at, 'dd/MM') AS dia,
		username AS nome_usuario,
			SUM(CASE
				WHEN points > 0 THEN 1
				ELSE 0
			END) AS resp_corretas
	FROM data
	GROUP BY FORMAT(submitted_at, 'dd/MM'), username
),
ranking_usuarios AS
(
	SELECT
		dia,
		nome_usuario,
		resp_corretas,
		DENSE_RANK() OVER(PARTITION BY dia ORDER BY resp_corretas DESC) AS ranking
	FROM submissoes_dia
)
SELECT
	dia,
	nome_usuario,
	resp_corretas,
	ranking
FROM ranking_usuarios
WHERE ranking <=3
```

4. Encontre os 5 usuários com o maior número de envios incorretos
  ```sql
SELECT TOP 5
	username AS nome_usuario,
		SUM(CASE
			WHEN points < 0 THEN 1
			ELSE 0
		END) AS resp_incorretas
FROM data
GROUP BY username
ORDER BY resp_incorretas DESC
```

5. Apresente, por usuário, o total de respostas corretas, incorretas, e sua pontuação final
  ```sql
SELECT 
    username AS nome_usuario,
    SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) AS resp_incorretas,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS resp_corretas,
    SUM(CASE WHEN points < 0 THEN points ELSE 0 END) AS pontos_resp_incorretas,
    SUM(CASE WHEN points > 0 THEN points ELSE 0 END) AS pontos_resp_corretas,
    SUM(points) AS pontuacao_final
FROM data
GROUP BY username
ORDER BY resp_incorretas DESC
```

6. Encontre os 10 melhores desempenhos em cada semana
  ```sql
SELECT *
FROM
(	SELECT
		DATEPART(WEEK, submitted_at) AS semana,
		username AS nome_usuario,
		SUM(points) AS total_pontos,
		DENSE_RANK() OVER(PARTITION BY DATEPART(WEEK, submitted_at) ORDER BY SUM(points) DESC) AS ranking
	FROM data
	GROUP BY DATEPART(WEEK, submitted_at), username
) AS ranking_semanal
WHERE ranking <= 10
```



