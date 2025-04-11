USE performance
GO

SELECT *
FROM data

-- 1 Liste todos os usuários distintos e suas estatísticas (retorne nome, total de submissões e pontos ganhos)
SELECT
	username AS nome_usuario,
	COUNT(id) AS total_submissoes,
	SUM(points) AS total_pontos
FROM data
GROUP BY username
ORDER BY total_submissoes DESC

-- 2 Calcule a média diária de pontos para cada usuário.
SELECT 
    FORMAT(submitted_at, 'dd/MM') AS dia,
    username AS nome_usuario,
    AVG(points) AS media_diaria_pontos
FROM data
GROUP BY FORMAT(submitted_at, 'dd/MM'), username
ORDER BY username

-- 3 Encontre os 3 usuários com o maior número de envios positivos em cada dia.
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

-- 4 Encontre os 5 usuários com o maior número de envios incorretos.
SELECT TOP 5
	username AS nome_usuario,
		SUM(CASE
			WHEN points < 0 THEN 1
			ELSE 0
		END) AS resp_incorretas
FROM data
GROUP BY username
ORDER BY resp_incorretas DESC

-- 5. Apresente, por usuário, o total de respostas corretas, incorretas, e sua pontuação final
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

-- 6. Encontre os 10 melhores desempenhos em cada semana
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

