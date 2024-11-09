CREATE TABLE VEICULO (
    NUMEROCHASSI CHAR(30) PRIMARY KEY,
    NOME CHAR(30),
    MODELO CHAR(10),
    DATAINICIOFABRICACAO DATE,
    DATAFIMFABRICACAO DATE,
    CGCFABRICANTE CHAR(12)
);

CREATE TABLE VENDA (
	id_venda bigserial primary key,
    NUMEROCHASSI CHAR(30),
    CGCLOJA CHAR(12),
    CPF CHAR(12),
    DATACOMPRA DATE,
    VALORCOMPRA numeric(15, 2),
    VALORIMPOSTO numeric(15, 2),
    VALORIMPOSTOICMS numeric(15, 2),
    FOREIGN KEY (NUMEROCHASSI) REFERENCES VEICULO(NUMEROCHASSI)
);


CREATE TABLE LOJA (
    CGCLOJA CHAR(12) PRIMARY KEY,
    ENDERECO CHAR(100),
    CIDADE CHAR(30),
    ESTADO CHAR(2),
    PAIS CHAR(20)
);

CREATE TABLE CLIENTE (
    CPF CHAR(12) PRIMARY KEY,
    NOME CHAR(30),
    ENDERECO CHAR(100),
    CIDADE CHAR(30),
    BAIRRO CHAR(10),
    ESTADO CHAR(2),
    PAIS CHAR(20),
    RENDA numeric(15, 2)
);

INSERT INTO VEICULO (NUMEROCHASSI, NOME, MODELO, DATAINICIOFABRICACAO, DATAFIMFABRICACAO, CGCFABRICANTE)
VALUES ('1HGCM82633A004352', 'Civic', 'Sedan', '2022-01-10', '2023-05-15', '123456789012');
INSERT INTO VEICULO (NUMEROCHASSI, NOME, MODELO, DATAINICIOFABRICACAO, DATAFIMFABRICACAO, CGCFABRICANTE)
VALUES ('JH4KA9650MC004256', 'Accord', 'Coupe', '2021-03-12', '2022-08-20', '987654321098');

INSERT INTO VENDA (NUMEROCHASSI, CGCLOJA, CPF, DATACOMPRA, VALORCOMPRA, VALORIMPOSTO, VALORIMPOSTOICMS)
VALUES ('1HGCM82633A004352', 'LOJ123456789', '12345678901', '2023-06-01', 85000.00, 1200.50, 850.75);
INSERT INTO VENDA (NUMEROCHASSI, CGCLOJA, CPF, DATACOMPRA, VALORCOMPRA, VALORIMPOSTO, VALORIMPOSTOICMS)
VALUES ('JH4KA9650MC004256', 'LOJ987654321', '98765432100', '2023-07-15', 95000.00, 1500.30, 920.20);

INSERT INTO LOJA (CGCLOJA, ENDERECO, CIDADE, ESTADO, PAIS)
VALUES ('LOJ123456789', 'Av. Paulista, 1000', 'São Paulo', 'SP', 'Brasil');
INSERT INTO LOJA (CGCLOJA, ENDERECO, CIDADE, ESTADO, PAIS)
VALUES ('LOJ987654321', 'Rua das Flores, 200', 'Curitiba', 'PR', 'Brasil');

INSERT INTO CLIENTE (CPF, NOME, ENDERECO, CIDADE, BAIRRO, ESTADO, PAIS, RENDA)
VALUES ('12345678901', 'João Silva', 'Rua A, 123', 'Rio de Janeiro', 'Centro', 'RJ', 'Brasil', 5000.00);
INSERT INTO CLIENTE (CPF, NOME, ENDERECO, CIDADE, BAIRRO, ESTADO, PAIS, RENDA)
VALUES ('98765432100', 'Maria Oliveira', 'Av. B, 456', 'Belo Horizonte', 'Savassi', 'MG', 'Brasil', 8000.00);

-- Tabelas dimensões e fatos

CREATE TABLE dim_cliente (
    cpf VARCHAR(11) PRIMARY KEY,
    nome VARCHAR(100),
    endereco VARCHAR(150),
    cidade VARCHAR(50),
    bairro VARCHAR(50),
    estado VARCHAR(2),
    pais VARCHAR(50),
    renda DECIMAL(10, 2)
);


CREATE TABLE dim_veiculo (
    numero_chassi VARCHAR(17) PRIMARY KEY,
    nome VARCHAR(100),
    modelo VARCHAR(50),
    data_inicio_fabric DATE,
    data_fim_fabric DATE,
    cgc_fabricante VARCHAR(14)
);

CREATE TABLE dim_loja (
    cgc_loja CHAR(12) PRIMARY KEY,
    endereco VARCHAR(150),
    cidade VARCHAR(50),
    estado VARCHAR(2),
    pais VARCHAR(50)
);

CREATE TABLE dim_tempo (
    id_tempo INT PRIMARY KEY,
    data DATE NOT NULL
);

CREATE TABLE fato_venda (
    id_venda INT PRIMARY KEY,
    id_loja CHAR,
    id_cliente varchar,
    id_veiculo varchar,
    id_tempo INT,
    valor_venda DECIMAL(12, 2),
    FOREIGN KEY (id_loja) REFERENCES dim_loja(cgc_loja),
    FOREIGN KEY (id_cliente) REFERENCES dim_cliente(cpf),
    FOREIGN KEY (id_veiculo) REFERENCES dim_veiculo(numero_chassi),
    FOREIGN KEY (id_tempo) REFERENCES dim_tempo(id_tempo)
);

-- popular tabelas dimensões

INSERT INTO dim_cliente (cpf, nome, endereco, cidade, bairro, estado, pais, renda)
SELECT CPF, NOME, ENDERECO,  CIDADE,  BAIRRO,  ESTADO, PAIS, RENDA FROM CLIENTE;

INSERT INTO dim_veiculo (numero_chassi, nome, modelo, data_inicio_fabric, data_fim_fabric, cgc_fabricante)
SELECT  NUMEROCHASSI, NOME, MODELO,  DATAINICIOFABRICACAO, DATAFIMFABRICACAO, CGCFABRICANTE
FROM VEICULO;

INSERT INTO dim_loja (cgc_loja, endereco, cidade, estado, pais) SELECT CGCLOJA, ENDERECO, 
CIDADE, ESTADO, PAIS FROM LOJA;

INSERT INTO dim_tempo (data)
SELECT DISTINCT DATACOMPRA
FROM VENDA

INSERT INTO fato_venda (id_loja, id_cliente, id_veiculo, id_tempo, valor_venda)
SELECT 
    l.cgc_loja,
    c.cpf,
    v.numero_chassi,
    t.id_tempo,
    venda.valorcompra
FROM VENDA venda
JOIN dim_loja l ON venda.cgcloja = l.cgc_loja
JOIN dim_cliente c ON venda.cpf = c.cpf
JOIN dim_veiculo v ON venda.numerochassi = v.numero_chassi
JOIN dim_tempo t ON t.data = venda.datacompra;

-- Consultas

-- Total das vendas de uma determinada loja, num determinado período

SELECT 
    l.cgc_loja,
    SUM(f.valor_venda) AS total_vendas
FROM 
    fato_venda f
JOIN 
    dim_loja l ON f.id_loja = l.cgc_loja
JOIN 
    dim_tempo t ON f.id_tempo = t.id_tempo
WHERE 
    l.cgc_loja = 'LOJ123456789' -- aqui coloquei uma loja q eu inseri acima
    AND t.data BETWEEN '2023-06-01' AND '2023-12-31'  -- Período desejado
GROUP BY 
    l.cgc_loja;

-- Lojas que mais venderam num determinado período de tempo

SELECT 
    l.cgc_loja, 
    l.endereco,
    l.cidade,
    SUM(f.valor_venda) AS total_vendas
FROM 
    fato_venda f
JOIN 
    dim_loja l ON f.id_loja = l.cgc_loja
JOIN 
    dim_tempo t ON f.id_tempo = t.id_tempo
WHERE 
    t.data BETWEEN '2023-06-01' AND '2023-12-31'
GROUP BY 
    l.cgc_loja, l.endereco, l.cidade
ORDER BY 
    total_vendas DESC;


-- Lojas que menos venderam num determinado período de tempo.

SELECT 
    l.cgc_loja, 
    l.endereco,
    l.cidade,
    SUM(f.valor_venda) AS total_vendas
FROM 
    fato_venda f
JOIN 
    dim_loja l ON f.id_loja = l.cgc_loja
JOIN 
    dim_tempo t ON f.id_tempo = t.id_tempo
WHERE 
    t.data BETWEEN '2023-06-01' AND '2023-12-31'
GROUP BY 
    l.cgc_loja, l.endereco, l.cidade
ORDER BY 
    total_vendas ASC; 


-- Perfil de clientes que devem-se investir.

SELECT 
    c.cpf, 
    c.nome, 
    c.renda,
    c.cidade,
    c.estado,
    SUM(f.valor_venda) AS total_gasto
FROM 
    fato_venda f
JOIN 
    dim_cliente c ON f.id_cliente = c.cpf
GROUP BY 
    c.cpf, c.nome, c.renda, c.cidade, c.estado
HAVING 
    c.renda > 10000 -- aqui a ideia é filtrar por cliente que tem uma renda acima de 10000, coloquei um valor qualquer
ORDER BY 
    total_gasto DESC, c.renda DESC


-- Veículos de maior aceitação numa determinada região

SELECT 
    v.nome AS nome_veiculo,
    v.modelo,
    COUNT(f.id_venda) AS total_vendas,
    l.cidade,
    l.estado
FROM 
    fato_venda f
JOIN 
    dim_veiculo v ON f.id_veiculo = v.numero_chassi
JOIN 
    dim_loja l ON f.id_loja = l.cgc_loja
WHERE 
    l.estado = 'RS' 
GROUP BY 
    v.nome, v.modelo, l.cidade, l.estado
ORDER BY 
    total_vendas DESC

