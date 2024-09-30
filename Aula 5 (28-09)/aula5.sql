

-- 1) Crie um Procedimento armazenado em PostgreSQL (somente SQL) que insere uma
-- nova linha em uma tabela, composta por três colunas: nome, sobrenome e idade:

CREATE TABLE pessoas (
nome varchar(20),
sobrenome varchar(40),
idade smallint
);

CREATE OR REPLACE PROCEDURE nova_linha(IN p_nome VARCHAR(20), IN p_sobrenome VARCHAR(40), IN p_idade smallint)
	LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO pessoas (nome, sobrenome, idade)
	VALUES (p_nome, p_sobrenome, p_idade);
END
$$ 
	
CALL nova_linha('Pedro' ::varchar, 'Lovatto' ::varchar, 25 ::smallint)

select * from pessoas

-- 2) Criar um procedimento armazenado que permita inserir um novo produto na tabela de
-- produtos de nosso banco de dados.

Create TABLE produto (
p_cod_produto INT,
p_nome_produto VARCHAR(30),
p_descricao TEXT,
p_preco NUMERIC,
p_qtde_estoque SMALLINT
)

CREATE OR REPLACE PROCEDURE novo_produto(cod_produto integer, nome_produto varchar, descricao text, 
	preco numeric, qtd_estoque smallint)
	LANGUAGE plpgsql
AS $$
BEGIN
	insert into produto (p_cod_produto, p_nome_produto, p_descricao, p_preco, p_qtde_estoque)
	VALUES (cod_produto, nome_produto, descricao, preco, qtd_estoque);
END
$$

CALL novo_produto(1 ::int, 'camisa' ::varchar, 'uma camisa' ::varchar, 49.99 ::numeric, 5 ::smallint)
CALL novo_produto(2 ::int, 'chuteira' ::varchar, 'uma chuteira' ::varchar, 39.99 ::numeric, 3 ::smallint)
CALL novo_produto(3 ::int, 'bermuda' ::varchar, 'uma bermuda' ::varchar, 19.99 ::numeric, 10 ::smallint)
CALL novo_produto(4 ::int, 'boné' ::varchar, 'um boné' ::varchar, 14.99 ::numeric, 14 ::smallint)

select * from produto

-------------

-- 3) Crie um procedimento que atualize o preço de um produto específico, identificado
-- pelo seu código de produto:


CREATE OR REPLACE PROCEDURE atualizar_preco(codigo integer, preco numeric)
	LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE produto SET p_preco = preco WHERE p_cod_produto = codigo;
END
$$

CALL atualizar_preco(1 ::integer, 45.99 ::numeric)

select * from produto

------------------

-- 4) Crie um procedimento que retorne todos os produtos com quantidade em estoque
-- abaixo de um valor especificado na chamada da procedure.

CREATE OR REPLACE PROCEDURE prod_valor_especif(p_estoque integer)
	LANGUAGE plpgsql
	AS $$
	DECLARE resultado RECORD;
BEGIN
	FOR resultado in
		SELECT cod_produto, nome_produto, qtde_estoque
		FROM Produtos
		WHERE qtde_estoque < p_limite_estoque
	LOOP
		RAISE NOTICE 'Produto: %, Estoque: % ', resultado.nome_produto, resultado.qtde_estoque;
	END LOOP;
END;
$$;

CALL prod_valor_especif(6 ::integer)

---------------------------

-- 5) Criar um procedimento armazenado que insira um novo produto na tabela de
-- produtos, ao mesmo tempo em que aplica um desconto percentual especificado a
-- todos os produtos logo após.

CREATE OR REPLACE PROCEDURE insere_atualiza(cod int, prod varchar(30), descr text, valor
numeric, qtde smallint, desc_perc numeric)
	LANGUAGE plpgsql
	AS $$
BEGIN
	INSERT INTO produtos(cod_produto, nome_produto, descricao, preco, qtde_estoque)
	VALUES (cod, prod, descr, valor, qtde);
	UPDATE produtos SET preco = preco * (100 - desc_perc) / 100;
END;

CALL insere_atualiza(6,'Alvejante'::varchar(30),'Alvejante de roupas'::text, 12.30, 12::smallint,
10);

---------------------

-- 6) O PostgreSQL permite criar funções para facilitar operações diárias e abstrair a
-- complexidade na leitura e utilização dos códigos. Isto posto, analise a função a seguir:

CREATE OR REPLACE FUNCTION totalProcessos (integer)
RETURNS integer AS $total$
	declare total integer;
BEGIN
	SELECT count(*) into total FROM processo where id <= $1;
	RETURN total;
END;
$total$ LANGUAGE plpgsql;

-- Sobre essa função, é correto afirmar que ela
Resposta: C) retorna um número do tipo inteiro.

----------------------

-- 7) Criar uma função que retorna o número total de registros na tabela COMPANY.
-- A tabela COMPANY, que tem os seguintes registros –

-- testdb# select * from COMPANY;
-- id | name | age | address | salary
-- ----+-------+-----+-----------+--------
-- 1 | Paul | 32 | California| 20000
-- 2 | Allen | 25 | Texas | 15000
-- 3 | Teddy | 23 | Norway | 20000
-- 4 | Mark | 25 | Rich-Mond | 65000
-- 5 | David | 27 | Texas | 85000
-- 6 | Kim | 22 | South-Hall| 45000
-- 7 | James | 24 | Houston | 10000
-- (7 rows)

CREATE OR REPLACE FUNCTION totalRecords()
RETURNS integer AS $total$
declare
total integer;
BEGIN
	SELECT count(*) into total FROM COMPANY;
	RETURN total;
END;
$total$ LANGUAGE plpgsql;

select totalRecords();

---------------------

-- 8) Quais são as diferentes formas de fazer referencias a parâmetros de uma função?

Há diferentes formas de se fazer referência a parâmetros:
CREATE FUNCTION minhaFuncao1(VARCHAR, INT) RETURNS INT AS $$ DECLARE
param1 ALIAS FOR $1; param2 ALIAS FOR $2;
BEGIN
	RETURN length(param1) + param2; 
END; $$ LANGUAGE plpgsql;

CREATE FUNCTION minhaFuncao2(param1 VARCHAR, param2 INT) RETURNS INT AS
$$
BEGIN
	RETURN length(param1) + param2; END; $$ LANGUAGE plpgsql;
	CREATE FUNCTION minhaFuncao3(VARCHAR, INT) RETURNS INT AS $$ BEGIN
	RETURN length($1) + $2; 
END; $$ LANGUAGE plpgsql;


-------------------------------

-- 9) Criar uma função que retorne todos os funcionários que recebem acima de R$ 3000.
-- Usar laço de repetição.

CREATE TABLE departamentos (id serial primary key, descricao varchar);
	
CREATE TABLE empregados(
codigo serial,
nome_emp text,
salario int,
departamento_cod int,
PRIMARY KEY (codigo),
FOREIGN KEY (departamento_cod) REFERENCES departamentos (id));

INSERT INTO departamentos(descricao) values ('financeiro')
INSERT INTO departamentos(descricao) values ('marketing')
INSERT INTO departamentos(descricao) values ('TI')

select * from departamentos
	
INSERT INTO empregados(nome_emp, salario, departamento_cod) values ('pedro', 2000, 1)
INSERT INTO empregados(nome_emp, salario, departamento_cod) values ('maria', 1000, 3)
INSERT INTO empregados(nome_emp, salario, departamento_cod) values ('marcio', 1500, 1)
INSERT INTO empregados(nome_emp, salario, departamento_cod) values ('joao', 4000, 2)

select * from empregados


CREATE OR REPLACE FUNCTION func_acima_3000(empr_salario int)
RETURNS SETOF INTEGER AS $$
DECLARE
    registro RECORD;
BEGIN
    FOR registro IN SELECT * FROM empregados WHERE salario > $1 LOOP
        RETURN NEXT registro.salario;
    END LOOP;
    RETURN;
END;
$$ 
LANGUAGE plpgsql;

DROP FUNCTION func_acima_3000(integer) 

select func_acima_3000(3000)


----------------------------

CREATE TABLE COMPANY(
	ID INT PRIMARY KEY NOT NULL,
	NAME TEXT NOT NULL,
	AGE INT NOT NULL,
	ADDRESS CHAR(50),
	SALARY REAL
);

CREATE TABLE AUDIT(
	EMP_ID INT NOT NULL,
	ENTRY_DATE TEXT NOT NULL
);
