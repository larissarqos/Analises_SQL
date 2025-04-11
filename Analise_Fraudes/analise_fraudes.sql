USE fraudes
GO

SELECT *
FROM fraud_data

-- 1. Qual o total de fraudes no per�odo avaliado?
-- H� um total de 14.151 fraudes entre as transa��es, o equivalente a 9.36% do total
SELECT
	class AS classificacao,
	COUNT(class) AS total_transacoes,
	FORMAT(COUNT(class) * 100.0 / (SELECT COUNT(class) FROM fraudes.dbo.fraud_data), 'N2') AS porcentagem
FROM fraudes.dbo.fraud_data
GROUP BY class

-- 2.  Qual o impacto das fraudes no faturamento?
-- O faturamento total foi de R$5.057.890,00. O total em fraudes foi de R$523.488,00, pouco mais de 10% do total
SELECT
	class AS classificacao,
	SUM(purchase_value) AS faturamento
	FROM fraudes.dbo.fraud_data
GROUP BY class

-- 3. Que navegador � o mais utilizado nas fraudes?
-- Os navegadores mais utilizados nas fraudes t�m uma mesma propor��o dos utilizados nas opera��es comuns
-- Logo, n�o � poss�vel estabelecer uma rela��o entre o navegador e as atividades fraudulentas
SELECT
	browser,
	COUNT(*) AS total_fraudes
FROM fraud_data
WHERE class = 1
GROUP BY browser
ORDER BY COUNT(*) DESC

-- 4. H� diferen�a, no n�mero de compras, entre opera��es comuns e fraudulentas?
-- Vamos considerar o ID do cliente e o ID do aparelho.
-- ID do cliente: N�o encontramos rela��o entre a quantidade de compras e a classifica��o (se fraude ou n�o).
-- ID do aparelho: Enquanto usu�rios comuns costumam realizar at� 3 transa��es por aparelho,
-- usu�rios fraudulentos realizam mais de 15 compras num mesmo aparelho.

-- ID do cliente, compras normais
SELECT
	class AS classificacao,
	user_id AS id_usuario,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, user_id
HAVING COUNT(*) = 1 AND class = 0
ORDER BY total_compras DESC

-- ID do cliente, compras fraudulentas
SELECT
	class AS classificacao,
	user_id AS id_usuario,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, user_id
HAVING COUNT(*) = 1 AND class = 1
ORDER BY total_compras DESC

-- ID do aparelho, compras normais
SELECT
	class AS classificacao,
	device_id AS id_aparelho,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, device_id
HAVING COUNT(*) > 1 AND class = 0
ORDER BY total_compras DESC

-- ID do aparelho, compras fraudulentas
SELECT
	class AS classificacao,
	device_id AS id_usuario,
	COUNT(*) AS total_compras
FROM fraudes.dbo.fraud_data
GROUP BY class, device_id
HAVING COUNT(*) > 1 AND class = 1
ORDER BY total_compras DESC

-- 5. H� diferen�a, no tempo de cadastro at� a primeira compra, entre opera��es comuns e fraudulentas?
-- Compras comuns: O tempo decorrido do cadastro at� a primeira compra � no m�nimo 130s (pouco mais de 2 minutos)
-- Compras fraudulentas: Marjoritariamente, contam com cadastro e compra no mesmo dia, geralmente com 1s de diferen�a entre cadastro e compra,
-- o que pode indicar uso de bots para realiza��o dessas compras

-- Tempo em dias entre cadastro e compra de opera��es comuns
SELECT class AS classificacao,
	signup_time AS hora_cadastro,
	purchase_time AS hora_compra,
	DATEDIFF (DAY, signup_time, purchase_time) AS diferenca_dias
FROM fraudes.dbo.fraud_data WHERE class = 0
ORDER BY Diferenca_Dias ASC

-- Tempo em dias entre cadastro e compra de opera��es fraudulentas
SELECT
	class AS classificacao,
	signup_time AS hora_cadastro,
	purchase_time AS hora_compra,
	DATEDIFF (DAY, signup_time, purchase_time) AS diferenca_dias
FROM fraudes.dbo.fraud_data WHERE class = 1
ORDER BY Diferenca_Dias ASC


-- Tempo em segundos entre cadastro e compra de opera��es normais
SELECT
	class AS classificacao,
	signup_time AS hora_assinatura,
	purchase_time AS hora_compra,
	DATEDIFF (SECOND, signup_time, purchase_time) AS diferenca_segundos
FROM fraudes.dbo.fraud_data WHERE class = 0
ORDER BY Diferenca_Segundos ASC

-- Tempo em segundos entre cadastro e compra de opera��es fraudulentas
SELECT
	class AS classificacao,
	signup_time AS hora_cadastro,
	purchase_time AS hora_compra,
	DATEDIFF (SECOND, signup_time, purchase_time) AS diferenca_segundos
FROM fraudes.dbo.fraud_data WHERE class = 1
ORDER BY Diferenca_Segundos ASC


-- 6. Qual o perfil de cliente mais comum nas opera��es fraudulentas?
-- O perfil mais comum em fraudes � do sexo masculino, com idade entre 26-35 anos.
-- No entanto, esse tamb�m � o perfil geral predominante de clientes da empresa,
-- ent�o n�o � poss�vel estabelecer uma rela��o "perfil cliente x fraude"
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