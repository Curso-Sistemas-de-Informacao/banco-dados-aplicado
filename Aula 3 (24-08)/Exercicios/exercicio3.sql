create table Clientes(
	id serial primary key,
	nome varchar(200),
	saldo float
);

create table Contas(
	id serial primary key,
	cliente int,
	descricao varchar(200),
	saldo float,
	foreign key (cliente) references Clientes(id)
);

create table Movimentos(
	id serial primary key,
	conta int,
	historico float,
	debito float,
	credito float,
	foreign key(conta) references Contas(id)
);

INSERT INTO Clientes (nome, saldo) VALUES ('Cliente 1', 1000.00);
INSERT INTO Clientes (nome, saldo) VALUES ('Cliente 2', 1500.00);

INSERT INTO Contas (cliente, descricao, saldo) VALUES (1, 'corrente', 500.00);
INSERT INTO Contas (cliente, descricao, saldo) VALUES (2, 'poupança', 800.00);

INSERT INTO Movimentos (conta, historico, debito, credito) VALUES (1, 100.00, 50.00, 150.00);
INSERT INTO Movimentos (conta, historico, debito, credito) VALUES (2, 200.00, 80.00, 120.00);

CREATE FUNCTION incrementar(INTEGER)
RETURNS INTEGER AS '
         SELECT $1 + 1 ;
'
LANGUAGE 'sql';

SELECT incrementar(10);

CREATE FUNCTION ncontas(INTEGER)
    RETURNS INT8 AS '
      SELECT COUNT(*) FROM contas
         WHERE cliente = $1;
    '
    LANGUAGE 'sql';

SELECT ncontas(2);

CREATE FUNCTION cliente_contadesc(VARCHAR(30), VARCHAR(30))
     RETURNS INT8 AS '
              INSERT INTO clientes(nome) VALUES($1);
              INSERT INTO contas(cliente, descricao)
                  VALUES(CURRVAL(''clientes_id_seq''),$2);
              SELECT CURRVAL(''clientes_id_seq'');
     '
     LANGUAGE 'sql';

SELECT cliente_contadesc('SILVIO','SEMANA04');

CREATE FUNCTION quemdeve() RETURNS SETOF INTEGER AS '
              SELECT clientes.id FROM clientes
              INNER JOIN contas ON clientes.id = contas.cliente
              INNER JOIN movimentos ON contas.id = movimentos.conta
              GROUP BY clientes.id
              HAVING SUM(movimentos.credito - movimentos.debito) < 0;
     '
     LANGUAGE 'sql';

SELECT quemdeve()

CREATE FUNCTION devedores()
     RETURNS SETOF clientes AS '
              SELECT * FROM clientes WHERE id IN
              (
                        SELECT clientes.id FROM clientes
                        INNER JOIN contas ON clientes.id = contas.cliente
                        INNER JOIN movimentos ON contas.id = movimentos.conta
                        GROUP BY clientes.id
                        HAVING SUM(movimentos.credito - movimentos.debito) < 0
              );
     '
     LANGUAGE 'sql';

CREATE FUNCTION MaioresClientes(NUMERIC(15,2))
     RETURNS SETOF clientes AS '
              SELECT * FROM clientes WHERE id IN
              (
                        SELECT clientes.id FROM clientes
                        INNER JOIN contas ON clientes.id = contas.cliente
                        INNER JOIN movimentos ON contas.id = movimentos.conta
                        GROUP BY clientes.id
                        HAVING SUM(movimentos.credito) >= $1
              );
     '
     LANGUAGE 'sql';

select id, nome from MaioresClientes (10000);

-------------------------------------------------------
Create table teste(id int4, nome text);
     Create table teste2(id_teste int4, nome text);

         create or replace Function ftr_ins_teste() returns trigger as’
         Begin
            if new.id is not null then
               insert into teste2(id_teste, nome) values(new.id, new.nome);
            end if;
            return new;
         end;
         ‘Language ‘plpgsql’;
