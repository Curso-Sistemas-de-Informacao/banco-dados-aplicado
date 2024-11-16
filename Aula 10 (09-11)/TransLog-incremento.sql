-- o exercício ficou bem parecido, pra falar a verdade igual (tirando o final) pois é 
-- bem semelhante ao que já havia sido feito né

-- tabelas de origem

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
    ('Cliente C', 'Praça da Liberdade, 789', 'Belo Horizonte', 'MG'),
    ('Cliente D', 'Rua das Palmeiras, 456', 'Curitiba', 'PR');

INSERT INTO Centros(nome, endereco, cidade, estado) VALUES
    ('Centro de Distribuição Norte', 'Estrada Norte, 789', 'Fortaleza', 'CE'),
    ('Centro de Distribuição Sul', 'Avenida Sul, 101', 'Porto Alegre', 'RS');
    ('Centro de Distribuição Leste', 'Rua Leste, 202', 'Recife', 'PE'),
    ('Centro de Distribuição Oeste', 'Avenida Oeste, 303', 'Manaus', 'AM');

INSERT INTO Pedidos (data_pedido, cliente_id, centro_saida_id, centro_destino_id, quantidade, valor_total) VALUES
    ('2024-10-01', 1, 1, 2, 50, 1500.00),
    ('2024-10-05', 2, 2, 1, 100, 3000.00);
    ('2024-10-10', 3, 3, 4, 70, 2100.00),
    ('2024-10-12', 4, 4, 3, 30, 900.00);

INSERT INTO Entregas (pedido_id, data_saida, data_chegada, quilometragem) VALUES
    (1, '2024-10-02', '2024-10-04', 1200.5),
    (2, '2024-10-06', '2024-10-08', 950.3);
    (3, '2024-10-11', '2024-10-13', 800.0),
    (4, '2024-10-13', '2024-10-15', 1200.0);


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

-- SQL para Preencher as tabelas do DW com os dados da tabela de origem.
	
	-- as datas estão como CURRENT_DATE pois esse campo não tem na tabela de origem
	-- então coloquei pra pegar a data atual e data_fim tá como NULL pois também não
	-- tem na tabela de origem e colocar CURRENT_DATE não faria sentido

INSERT INTO dim_cliente (cliente_id, nome, endereco, cidade, estado, data_inicio, 
data_fim, ativo) SELECT cliente_id, nome, endereco, cidade, estado, 
CURRENT_DATE, NULL, TRUE FROM Clientes;

INSERT INTO dim_centro (centro_id, nome, endereco, cidade, estado, data_inicio, data_fim, ativo)
SELECT centro_id, nome, endereco, cidade, estado, CURRENT_DATE, NULL, TRUE
FROM Centros;

INSERT INTO dim_tempo (data) SELECT DISTINCT data_pedido FROM Pedidos
UNION SELECT DISTINCT data_saida FROM Entregas UNION SELECT DISTINCT data_chegada
FROM Entregas;

INSERT INTO fato_entregas (cliente_id, centro_id, data_id, data, quantidade, valor_total)
SELECT 
    dc.cliente_sk AS cliente_id,
    dc2.centro_sk AS centro_id,
    dt.data_id AS data_id,
    e.data_saida AS data,
    p.quantidade,
    p.valor_total
FROM Entregas e
JOIN Pedidos p ON e.pedido_id = p.pedido_id
JOIN dim_cliente dc ON p.cliente_id = dc.cliente_id
JOIN dim_centro dc2 ON p.centro_saida_id = dc2.centro_id
JOIN dim_tempo dt ON e.data_saida = dt.data;
