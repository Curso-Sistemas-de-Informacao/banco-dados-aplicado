create table aluno (
	matricula integer primary key,
	nome varchar(200),
	sexo varchar(200)
);

create table disciplina(
	codigo integer primary key,
	nome varchar(200),
	creditos integer
);

create table cursa(
	matricula integer,
	codigo integer,
	semestreAno float,
	nota float,
	falta integer,
	primary key(matricula, codigo),
	foreign key(matricula) references aluno(matricula),
	foreign key (codigo) references disciplina(codigo)
);



insert into aluno(matricula, nome, sexo) values (1, 'João Silva', 'Masculino');
insert into aluno(matricula, nome, sexo) values (2, 'Maria Santos', 'Feminino');
insert into aluno(matricula, nome, sexo) values (3, 'Carlos Lima', 'Masculino');
insert into aluno(matricula, nome, sexo) values (4, 'Ana Oliveira', 'Feminino');
insert into aluno(matricula, nome, sexo) values (5, 'Pedro Souza', 'Masculino');
insert into aluno(matricula, nome, sexo) values (6, 'Sofia Alves', 'Feminino');
insert into aluno(matricula, nome, sexo) values (7, 'Rafael Pereira', 'Masculino');
insert into aluno(matricula, nome, sexo) values (8, 'Luana Fernandes', 'Feminino');
insert into aluno(matricula, nome, sexo) values (9, 'Lucas Rodrigues', 'Masculino');
insert into aluno(matricula, nome, sexo) values (10, 'Beatriz Costa', 'Feminino');


insert into disciplina(codigo, nome, creditos) values (1, 'Estrutura de Dados', 4);
insert into disciplina(codigo, nome, creditos) values (2, 'Projeto Integrador', 6);
insert into disciplina(codigo, nome, creditos) values (3, 'Orientação a objetos', 4);
insert into disciplina(codigo, nome, creditos) values (4, 'Requisitos de Software', 2);
insert into disciplina(codigo, nome, creditos) values (5, 'Sistema de Banco de dados', 4);


insert into cursa(matricula, codigo, semestreAno, nota, falta) values (1, 1, 1.2021, 8.5, 0);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (2, 1, 1.2021, 4.0, 3);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (3, 2, 1.2021, 9.0, 1);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (4, 2, 2.2021, 7.8, 2);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (5, 3, 2.2021, 3.5, 4);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (6, 3, 2.2021, 8.2, 1);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (7, 1, 1.2022, 7.0, 0);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (8, 2, 1.2022, 4.2, 2);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (9, 4, 2.2022, 9.5, 0);
insert into cursa(matricula, codigo, semestreAno, nota, falta) values (10, 5, 2.2022, 8.8, 1);

-- 1. Determinar o número de alunos matriculados em cada disciplina;

CREATE VIEW numero_alunos_disciplina AS
	SELECT d.codigo, d.nome as disciplina, COUNT(c.matricula) as numero_alunos 
	FROM disciplina d LEFT JOIN cursa c ON d.codigo = c.codigo
	GROUP BY d.codigo, d.nome;

select * from numero_alunos_disciplina

-- 2. Média geral das notas desses alunos em cada disciplina.

CREATE VIEW media_notas_disciplina AS
	SELECT d.codigo, d.nome as disciplina, AVG(c.nota) as media_nota
	FROM disciplina d JOIN cursa c ON d.codigo = c.codigo
	GROUP BY d.codigo, d.nome;

select * from media_notas_disciplina

-- 3. Média de faltas dos alunos em cada disciplina.

CREATE VIEW media_faltas_disciplina AS
	SELECT d.codigo, d.nome as disciplina, AVG(c.falta) as media_faltas
	FROM disciplina d JOIN cursa c ON d.codigo = c.codigo
	GROUP BY d.codigo, d.nome;

select * from media_faltas_disciplina

