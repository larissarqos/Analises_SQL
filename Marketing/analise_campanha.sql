USE MARKETING
GO

SELECT * FROM bank

-- FILTRANDO COLUNAS COM DADOS UNKNOWN
-- Foram filtradas 20 linhas de dados com alguma linha 'unknown' nas colunas job, contact, education ou poutcome
-- O resultado foi exportado para .csv
SELECT TOP 20 * FROM bank
WHERE
	job = 'unknown' OR
	contact = 'unknown' OR
	education = 'unknown' OR
	poutcome = 'unknown'


-- QUANTOS CLIENTES A CAMPANHA DE MARKETING OBTEVE? QUAL O PERCENTUAL DE SUCESSO?
-- A campanha obtve 521 clientes, uma taxa de 11,52% de sucesso
SELECT COUNT(*) AS total_retorno_campanha,
ROUND(COUNT(y) * 100.0 / (SELECT COUNT(y) FROM bank), 2) AS porcentagem
FROM bank
WHERE y = 'yes'

SELECT COUNT(*) AS total_retorno_campanha,
FROM bank


-- QUEREMOS CLIENTES QUE ADOTEM DEPÓSITOS A PRAZO, COM BASTANTE CAPITAL. CONSEGUIMOS ISSO?
-- Os clientes obtidos através da campanha têm média de saldo maior que os não obtidos
-- Logo, aparentemente a campanha teve sucesso ao atingir clientes com maior capital
SELECT y,
COUNT(*) AS qtd_clientes,
ROUND(AVG(balance), 2) AS avg_balance,
ROUND(STDEV(balance), 2) AS std_balance,
MIN(balance) AS min_balance,
MAX(balance) AS max_balance
FROM bank
GROUP BY y


-- A TAXA DE SUCESSO DA CAMPANHA MUDA DE ACORDO COM O MEIO DE CONTATO?
-- Não há impacto significativo do tipo de contato em relação ao resultado da campanha
SELECT y, contact, COUNT(*) AS contagem_contato
FROM bank
GROUP BY y, contact
ORDER BY y, contagem_contato DESC


-- COMO O PADRÃO IDADE, TRABALHO E ESTADO CIVIL MUDA ENTRE ASSINANTES E NÃO ASSINANTES?
-- Casados e com casa tiveram menor conversão. A idade não teve muito impacto

-- Resultado campanha por idade
SELECT y,
	AVG(age) AS media_idade
FROM bank
GROUP BY y
ORDER BY y, media_idade

-- Resultado campanha por trabalho
SELECT y,
	job,
	COUNT(job) AS count_job
FROM bank
GROUP BY y, job
ORDER BY y, count_job DESC

-- Resultado campanha por estado civil
SELECT y, marital,
	COUNT(marital) AS count_marital
FROM bank
WHERE y = 'yes'
GROUP BY y, marital
ORDER BY y, count_marital DESC


