SELECT * FROM fraud_data


-- QUAL O TOTAL DE FRAUDES NO PERÍODO?
-- Há um total de 14.151 fraudes entre as transações. O equivalente a quase 10% do total
SELECT class, COUNT(*)
FROM fraudes.dbo.fraud_data
GROUP BY class


-- QUAL A PORCENTAGEM DE VENDAS COM FRAUDE?
-- 90.64% das transações são ok, enquanto 9.36% são fraudulentas
SELECT class,
COUNT(class) AS contagem_class,
COUNT(class) * 100.0 / (SELECT COUNT(class) FROM fraudes.dbo.fraud_data) AS porcentagem
FROM fraudes.dbo.fraud_data
GROUP BY class


-- QUAL O FATURAMENTO TOTAL E QUAL O VALOR DE FRAUDES
-- O faturamento total foi de R$5.057890,00. O total em fraudes foi de R$523.488,00
SELECT class, SUM(CAST(purchase_value as int))
FROM fraudes.dbo.fraud_data
GROUP BY class


-- QUAL O FATURAMENTO TOTAL E QUAL O VALOR DE FRAUDES EM PORCENTAGEM
-- A porcentagem do valor em fraudes é próximo da porcetagem da contagem de fraudes
-- Isso indica que o comportamento das fraudes é muito próximo do comportamento das operações não fraudulentas
SELECT class, SUM(CAST(purchase_value AS INT)) AS valor_vendas,
SUM(CAST(purchase_value AS INT)) *100.0 / SUM(SUM(CAST(purchase_value AS INT))) OVER() AS porcentagem
FROM fraudes.dbo.fraud_data
GROUP BY class

-- MAIS DE UM USUÁRIO REALIZOU FRAUDE?
SELECT class, user_id, COUNT(*) AS contagem
FROM fraudes.dbo.fraud_data
GROUP BY class, user_id
HAVING COUNT(*) > 1
ORDER BY contagem DESC

-- MAIS DE UM USUÁRIO REALIZOU FRAUDE (CONSIDERANDO O DEVICE)?
SELECT class, device_id, COUNT(*) AS contagem
FROM fraudes.dbo.fraud_data
GROUP BY class, device_id
HAVING COUNT(*) > 1
ORDER BY contagem DESC

-- MAIS DE UM USUÁRIO REALIZOU COMPRAS (CONSIDERANDO O DEVICE)?
-- Considerando o aparelho, usuários comuns fazem até 3 compras.
-- Usuários fraudulentos compram mais de 15 vezes através de um mesmo dispositivo
SELECT class, device_id, COUNT(*) AS contagem
FROM fraudes.dbo.fraud_data
GROUP BY class, device_id
HAVING COUNT(*) > 1 AND class = 0
ORDER BY contagem DESC

-- QUAL O INTERVALO NORMAL ENTRE CADASTRO E COMPRA NO SITE?
-- Compras fraudulentas, marjoritariamente, contam com cadastro e compra no mesmo dia, geralmente com 1s de diferença entre cadastro e compra
-- Isso indica uso de bots para realização dessas compras
SELECT class, signup_time, purchase_time,
DATEDIFF (DAY, signup_time, purchase_time) AS Diferenca_Datas
FROM fraudes.dbo.fraud_data WHERE class = 1
ORDER BY Diferenca_Datas ASC

SELECT class, signup_time, purchase_time,
DATEDIFF (SECOND, signup_time, purchase_time) AS Diferenca_Datas
FROM fraudes.dbo.fraud_data WHERE class = 1
ORDER BY Diferenca_Datas ASC

SELECT class, signup_time, purchase_time,
DATEDIFF (SECOND, signup_time, purchase_time) AS Diferenca_Datas
FROM fraudes.dbo.fraud_data WHERE class = 0
ORDER BY Diferenca_Datas ASC



