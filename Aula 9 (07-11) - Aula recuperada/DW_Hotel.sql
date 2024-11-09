
-- tabelas iniciais

CREATE TABLE Cliente (
    cliente_id INT PRIMARY KEY,
    nome VARCHAR(100),
    data_nascimento DATE,
    endereco VARCHAR(255),
    categoria_fidelidade VARCHAR(20),
    data_ultima_alteracao DATE
);

CREATE TABLE Quarto (
    quarto_id INT PRIMARY KEY,
    hotel_id INT,
    tipo_quarto VARCHAR(50),
    status_manutencao VARCHAR(20),
    data_ultima_reforma DATE,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id)
);

CREATE TABLE Hotel (
    hotel_id INT PRIMARY KEY,
    nome_hotel VARCHAR(100),
    cidade VARCHAR(100),
    pais VARCHAR(100),
    data_inauguracao DATE
);

CREATE TABLE Receitas (
    receita_id bigserial PRIMARY KEY,
    hotel_id INT,
    data DATE,
    receita_total_diaria DECIMAL(10, 2),
    despesas_operacionais_diarias DECIMAL(10, 2),
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id)
);

CREATE TABLE Reserva (
    reserva_id INT PRIMARY KEY,
    cliente_id INT,
    hotel_id INT,
    quarto_id INT,
    data_check_in DATE,
    data_check_out DATE,
    valor_total_reserva DECIMAL(10, 2),
    FOREIGN KEY (cliente_id) REFERENCES Cliente(cliente_id),
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id),
    FOREIGN KEY (quarto_id) REFERENCES Quarto(quarto_id)
);

INSERT INTO Cliente (cliente_id, nome, data_nascimento, endereco, categoria_fidelidade, data_ultima_alteracao)
VALUES 
(1, 'Alice Silva', '1985-06-15', 'Rua das Flores, 123', 'Ouro', '2024-01-10'),
(2, 'João Santos', '1990-04-22', 'Av. Brasil, 456', 'Prata', '2024-02-20');

INSERT INTO Hotel (hotel_id, nome_hotel, cidade, pais, data_inauguracao)
VALUES 
(1, 'Hotel Central', 'São Paulo', 'Brasil', '2005-03-01'),
(2, 'Hotel Vista Mar', 'Rio de Janeiro', 'Brasil', '2010-08-15');

INSERT INTO Quarto (quarto_id, hotel_id, tipo_quarto, status_manutencao, data_ultima_reforma)
VALUES 
(101, 1, 'Luxo', 'Disponível', '2023-12-01'),
(102, 2, 'Standard', 'Em manutenção', '2024-01-05');

INSERT INTO Reserva (reserva_id, cliente_id, hotel_id, quarto_id, data_check_in, data_check_out, valor_total_reserva)
VALUES 
(1, 1, 1, 101, '2024-02-15', '2024-02-20', 1500.00),
(2, 2, 2, 102, '2024-03-01', '2024-03-05', 800.00);

INSERT INTO Receitas (hotel_id, data, receita_total_diaria, despesas_operacionais_diarias)
VALUES 
(1, '2024-02-15', 5000.00, 2000.00),
(2, '2024-03-01', 4000.00, 1500.00);


-- tabelas de dimensões e fato

CREATE TABLE dim_cliente (
    cliente_sk bigserial PRIMARY KEY,
    cliente_id INT NOT NULL,
    nome VARCHAR(100),
    data_nascimento DATE,
    endereco VARCHAR(255),
    categoria_fidelidade VARCHAR(50),
    data_ultima_alteracao DATE,
    data_inicio DATE,
    data_fim DATE
);

CREATE TABLE dim_hotel (
    hotel_id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(100),
    pais VARCHAR(100),
    data_inauguracao DATE
);

CREATE TABLE dim_quarto (
    quarto_sk bigserial PRIMARY KEY,
    quarto_id INT NOT NULL,
    tipo_quarto VARCHAR(50),
    status_manutencao VARCHAR(50),
    data_ultima_reforma DATE,
    data_inicio DATE,
    data_fim DATE
);

CREATE TABLE dim_tempo (
    data_id bigserial PRIMARY KEY,
    data DATE NOT NULL,
    ano INT,
    trimestre INT,
    mes INT,
    semana INT,
    dia INT,
    dia_da_semana VARCHAR(20),
    final_de_semana BOOLEAN
);

CREATE TABLE fato_reservas (
    id_reserva bigserial PRIMARY KEY,
    cliente_id INT REFERENCES dim_cliente(cliente_sk),
    hotel_id INT REFERENCES dim_hotel(hotel_id),
    quarto_id INT REFERENCES dim_quarto(quarto_sk),
    tempo_id INT REFERENCES dim_tempo(data_id),
    valor_total_reserva float,
    receita_total_diaria float
);

INSERT INTO dim_cliente (cliente_id, nome, data_nascimento, endereco, categoria_fidelidade, data_ultima_alteracao, data_inicio, data_fim)
VALUES 
(1, 'Alice Silva', '1985-06-15', 'Rua das Flores, 123', 'Ouro', '2024-01-10', '2024-01-01', NULL),
(2, 'João Santos', '1990-04-22', 'Av. Brasil, 456', 'Prata', '2024-02-20', '2024-02-01', NULL);

INSERT INTO dim_hotel (nome, cidade, pais, data_inauguracao)
VALUES 
('Hotel Central', 'São Paulo', 'Brasil', '2005-03-01'),
('Hotel Vista Mar', 'Rio de Janeiro', 'Brasil', '2010-08-15');

INSERT INTO dim_quarto (quarto_id, tipo_quarto, status_manutencao, data_ultima_reforma, data_inicio, data_fim)
VALUES 
(101, 'Luxo', 'Disponível', '2023-12-01', '2024-01-01', NULL),
(102, 'Standard', 'Em manutenção', '2024-01-05', '2024-01-01', NULL);

INSERT INTO dim_tempo (data, ano, trimestre, mes, semana, dia, dia_da_semana, final_de_semana)
VALUES 
('2024-02-15', 2024, 1, 2, 7, 15, 'Quinta-feira', FALSE),
('2024-03-01', 2024, 1, 3, 9, 1, 'Sexta-feira', TRUE);

INSERT INTO fato_reservas (cliente_id, hotel_id, quarto_id, tempo_id, valor_total_reserva, receita_total_diaria)
VALUES 
(1, 1, 1, 1, 1500.00, 5000.00),
(2, 2, 2, 2, 800.00, 4000.00);


-- consultas

-- Qual é a receita média por cliente em cada categoria de fidelidade?

SELECT 
    d.categoria_fidelidade,
    AVG(f.valor_total_reserva) AS receita_media_por_cliente
FROM 
    fato_reservas f
JOIN 
    dim_cliente d ON f.cliente_id = d.cliente_sk
GROUP BY 
    d.categoria_fidelidade;

-- Quais hotéis possuem as taxas de ocupação mais altas em um período específico?

SELECT 
    h.nome AS hotel,
    COUNT(f.id_reserva) AS total_reservas
FROM 
    fato_reservas f
JOIN 
    dim_hotel h ON f.hotel_id = h.hotel_id
JOIN 
    dim_tempo t ON f.tempo_id = t.data_id
WHERE 
    t.data BETWEEN '2024-01-01' AND '2024-12-31'  -- Período específico
GROUP BY 
    h.nome
ORDER BY 
    total_reservas DESC;

-- Qual a média de tempo que os clientes de uma determinada categoria de fidelidade
-- permanecem nos hotéis?

SELECT 
    c.categoria_fidelidade,
    AVG(f.valor_total_reserva / f.receita_total_diaria) AS media_tempo_permanencia  -- tempo estimado
FROM 
    fato_reservas f
JOIN 
    dim_cliente c ON f.cliente_id = c.cliente_sk
GROUP BY 
    c.categoria_fidelidade;

-- Quais quartos são mais frequentemente reformados, e com que frequência?

SELECT 
    q.quarto_id,
    q.tipo_quarto,
    COUNT(q.data_ultima_reforma) AS frequencia_reformas
FROM 
    dim_quarto q
GROUP BY 
    q.quarto_id, q.tipo_quarto
ORDER BY 
    frequencia_reformas DESC;


-- Qual o perfil dos clientes com maior gasto em reservas por país e categoria de fidelidade?

SELECT 
    h.pais,
    c.categoria_fidelidade,
    c.nome AS cliente,
    SUM(f.valor_total_reserva) AS gasto_total
FROM 
    fato_reservas f
JOIN 
    dim_cliente c ON f.cliente_id = c.cliente_sk
JOIN 
    dim_hotel h ON f.hotel_id = h.hotel_id
GROUP BY 
    h.pais, c.categoria_fidelidade, c.nome
ORDER BY 
    gasto_total DESC;
