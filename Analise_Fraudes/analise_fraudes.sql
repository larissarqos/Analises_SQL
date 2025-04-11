USE fraudes
GO

SELECT * FROM fraud_data

-- 1. Qual o total de fraudes no per�odo avaliado?
-- H� um total de 14.151 fraudes entre as transa��es, o equivalente a 9.36% do total
SELECT
	class AS classificacao,
	COUNT(class) AS total_transacoes,
	FORMAT(COUNT(class) * 100.0 / (SELECT COUNT(class) FROM fraudes.dbo.fraud_data), 'N2') AS porcentagem
FROM fraudes.dbo.fraud_data
GROUP BY class

-- 2.  Qual o impacto das fraudes no faturamento?
-- O faturamento total foi de R$5.057890,00. O total em fraudes foi de R$523.488,00, pouco mais de 10% do total
SELECT
	class AS classificacao,
	SUM(purchase_value) AS faturamento
	FROM fraudes.dbo.fraud_data
GROUP BY class

-- 3. H� diferen�a, no n�mero de compras, entre opera��es comuns e fraudulentas?
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

-- 4. H� diferen�a, no tempo de cadastro at� a primeira compra, entre opera��es comuns e fraudulentas?
-- Compras comuns: O tempo decorrido do cadastro at� a primeira compra � no m�nimo 130s (pouco mais de 2 minutos)
-- Compras fraudulentas: Marjoritariamente, contam com cadastro e compra no mesmo dia, geralmente com 1s de diferen�a entre cadastro e compra,
-- o que pode indicar uso de bots para realiza��o dessas compras

-- Tempo em dias entre cadastro e compra de opera��es fraudulentas
SELECT
	class AS classificacao,
	signup_time AS hora_cadastro,
	purchase_time AS hora_compra,
	DATEDIFF (DAY, signup_time, purchase_time) AS diferenca_dias
FROM fraudes.dbo.fraud_data WHERE class = 1
ORDER BY Diferenca_Dias ASC

-- Tempo em dias entre cadastro e compra de opera��es comuns
SELECT class AS classificacao,
	signup_time AS hora_cadastro,
	purchase_time AS hora_compra,
	DATEDIFF (DAY, signup_time, purchase_time) AS diferenca_dias
FROM fraudes.dbo.fraud_data WHERE class = 0
ORDER BY Diferenca_Dias ASC

-- Tempo em segundos entre cadastro e compra de opera��es fraudulentas
SELECT
	class AS classificacao,
	signup_time AS hora_cadastro,
	purchase_time AS hora_compra,
	DATEDIFF (SECOND, signup_time, purchase_time) AS diferenca_segundos
FROM fraudes.dbo.fraud_data WHERE class = 1
ORDER BY Diferenca_Segundos ASC

-- Tempo em segundos entre cadastro e compra de opera��es normais
SELECT
	class AS classificacao,
	signup_time AS hora_assinatura,
	purchase_time AS hora_compra,
	DATEDIFF (SECOND, signup_time, purchase_time) AS diferenca_segundos
FROM fraudes.dbo.fraud_data WHERE class = 0
ORDER BY Diferenca_Segundos ASC