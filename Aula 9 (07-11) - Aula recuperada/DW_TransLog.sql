-- tabelas iniciais

CREATE TABLE Clientes (
    cliente_id bigserial PRIMARY KEY,
    nome varchar(255),
    endereco varchar(255),
    cidade varchar(100),
    estado varchar(2)
);

CREATE TABLE Centros (
    centro_id bigserial PRIMARY KEY,
    nome varchar(255),
    endereco varchar(255),
    cidade varchar(100),
    estado varchar(2)
);

CREATE TABLE Pedidos (
    pedido_id bigserial PRIMARY KEY,
    data_pedido date,
    cliente_id int,
    centro_saida_id int,
    centro_destino_id int,
    quantidade int ,
    valor_total float,
    foreign key (cliente_id) references Clientes(cliente_id),
    foreign key (centro_saida_id) references Centros(centro_id),
    foreign key (centro_destino_id) references Centros(centro_id)
);

CREATE TABLE Entregas (
    entrega_id bigserial PRIMARY KEY,
    pedido_id int,
    data_saida date,
    data_chegada date,
    quilometragem float,
    foreign key (pedido_id) references Pedidos(pedido_id)
);

INSERT INTO Clientes(nome, endereco, cidade, estado) VALUES
    ('Cliente A', 'Rua das Flores, 123', 'São Paulo', 'SP'),
    ('Cliente B', 'Avenida Central, 456', 'Rio de Janeiro', 'RJ');

INSERT INTO Centros(nome, endereco, cidade, estado) VALUES
    ('Centro de Distribuição Norte', 'Estrada Norte, 789', 'Fortaleza', 'CE'),
    ('Centro de Distribuição Sul', 'Avenida Sul, 101', 'Porto Alegre', 'RS');

INSERT INTO Pedidos (data_pedido, cliente_id, centro_saida_id, centro_destino_id, quantidade, valor_total) VALUES
    ('2024-10-01', 1, 1, 2, 50, 1500.00),
    ('2024-10-05', 2, 2, 1, 100, 3000.00);

INSERT INTO Entregas (pedido_id, data_saida, data_chegada, quilometragem) VALUES
    (1, '2024-10-02', '2024-10-04', 1200.5),
    (2, '2024-10-06', '2024-10-08', 950.3);


-- tabelas de DW

create table dim_cliente(
	cliente_sk bigserial primary key,
	cliente_id int,
    nome VARCHAR(255),
    endereco VARCHAR(255),
    cidade VARCHAR(100),
    estado VARCHAR(2),
	data_inicio date,
	data_fim date,
	ativo boolean
)

create table dim_centro(
	centro_sk bigserial primary key,
	centro_id int,
    nome VARCHAR(255),
    endereco VARCHAR(255),
    cidade VARCHAR(100),
    estado VARCHAR(2),
	data_inicio date,
	data_fim date,
	ativo boolean
)

create table dim_tempo(
	data_id bigserial primary key,
	data date
) 

create table fato_entregas(
	cliente_id int,
	centro_id int,
	data_id int,
	data date,
	quantidade int,
	valor_total float,
	foreign key (cliente_id) references dim_cliente(cliente_sk),
	foreign key (centro_id) references dim_centro(centro_sk),
	foreign key (data_id) references dim_tempo(data_id)
)

INSERT INTO dim_cliente (cliente_id, nome, endereco, cidade, estado, data_inicio, data_fim, ativo)
VALUES 
    (1, 'Cliente A', 'Rua A, 123', 'Cidade A', 'AA', '2023-01-01', NULL, true),
    (2, 'Cliente B', 'Rua B, 456', 'Cidade B', 'BB', '2023-02-01', NULL, true);

INSERT INTO dim_centro (centro_id, nome, endereco, cidade, estado, data_inicio, data_fim, ativo)
VALUES 
    (1, 'Centro X', 'Avenida X, 789', 'Cidade X', 'XX', '2023-01-15', NULL, true),
    (2, 'Centro Y', 'Avenida Y, 321', 'Cidade Y', 'YY', '2023-03-01', NULL, true);

INSERT INTO dim_tempo (data)
VALUES 
    ('2023-01-01'),
    ('2023-02-01');

INSERT INTO fato_entregas (cliente_id, centro_id, data_id, data, quantidade, valor_total)
VALUES 
    (1, 1, 1, '2023-01-01', 10, 500.0),
    (2, 2, 2, '2023-02-01', 20, 1000.0);

-- total de produtos transportados
SELECT SUM(quantidade) AS total_produtos_transportados, COUNT(data) AS 
tempo_total_entrega FROM fato_entregas;

-- tempo total de entrega
SELECT AVG(EXTRACT(DAY FROM (fato_entregas.data - dim_tempo.data))) AS 
tempo_medio_entrega FROM fato_entregas JOIN dim_tempo ON 
fato_entregas.data_id = dim_tempo.data_id;

-- tempo médio de entrega por pedido
SELECT AVG(EXTRACT(DAY FROM (fato_entregas.data - dim_tempo.data))) AS 
tempo_medio_entrega FROM fato_entregas JOIN dim_tempo ON 
fato_entregas.data_id = dim_tempo.data_id;

--  custo médio por quilômetro
SELECT AVG(valor_total / quantidade) AS custo_medio_por_unidade FROM fato_entregas 
WHERE quantidade > 0;
