create function buscaFuncionarioIDDepto(integer) returns setof funcionarios as 
'
select * from funcionarios where depto_id = $1	
'
language 'sql'

select buscaFuncionarioIDDepto(2);


create function qtd_funcionarios_cidade(varchar) returns integer as 
'
select count(f.id) from funcionarios f, cidades c where f.cidade_id = c.id and c.nome like $1
'
language 'sql'

select qtd_funcionarios_cidade('Pelotas')
	

create function qtd_funcionarios_porcidade() returns table(nome varchar, nro integer) as 
'
select c.nome, count(f.id) from funcionarios f, cidades c where f.cidade_id = c.id group by c.nome
'
language 'sql'

select * from qtd_funcionarios_porcidade()


create table funcionarios_testeIF (
	id int not null primary key,
	funcionario_codigo varchar(20),
	funcionario_nome varchar(100),
	funcionario_situacao varchar(1) default 'A',
	funcionario_comissao real,
	funcionario_cargo varchar(30),
	data_criacao timestamp,
	data_atualizacao timestamp
);

select * from funcionarios_testeIF;

insert into funcionarios_testeIF(id, funcionario_nome, funcionario_situacao, funcionario_comissao, 
	funcionario_cargo, data_criacao) values ('0001', 'VINICIUS CARVALHO', 'B', 5, 'GERENTE', '01/01/2016');

insert into funcionarios_testeIF(id, funcionario_nome, funcionario_situacao, funcionario_comissao, 
	funcionario_cargo, data_criacao) values ('0002', 'SOUZA', 'A', 2, 'GARÇOM', '01/01/2016');


create or replace function retorna_nome_funcionario(func_id int) returns text as 
	$$
	declare 
	nome text;
	situacao text;

	begin

	select funcionario_nome, funcionario_situacao into nome, situacao from funcionarios_textIF 
		where id = func_id;

	if situacao = 'A' then
		return home || 'Usuário Ativo';
	else
		return nome || 'Usuário Inativo';
	end if;

	end

	$$

	language 'plpgsql';


select retorna_nome_funcionario(2)

create table empregados (
	codigo serial,
	nome_emp text,
	salario int,
	departamento_cod int,
	PRIMARY KEY (codigo),
	FOREIGN KEY (departamento_cod) REFERENCES departamentos (id));

CREATE OR REPLACE FUNCTION codigo_empregado(salario INTEGER)
	returns SETOF INTEGER AS 
	$$
	DECLARE
		registro RECORD;
		retval INTEGER;
	BEGIN
		FOR registro IN SELECT * FROM empregados WHERE salario >= $1 LOOP
			RETURN NEXT registro.codigo;
		END LOOP;
		RETURN;
	END;
	$$
language 'plpgsql';

select * from codigo_empregado(1000)
	


