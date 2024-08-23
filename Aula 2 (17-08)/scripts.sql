-- Sistema para gerenciar inventários

-- Uma loja de roupas em restinga seca possui o 5 tipos de produtos e 5 fornecedores, a cada pedido de novos produtos de determinado tipo
-- é necessário informar o produto, o fornecedor, a quantidade de produtos e a data que o pedido foi emitido


-- Criar database aula2-exercicio

CREATE DATABASE aula2-exercicio;


-- 4) Criar tabelas

CREATE TABLE produtos(
	id_prod serial primary key,
	nome VARCHAR(200),
	qtd_estoque int,
	preco float
);

CREATE TABLE fornecedores(
	id_forn serial primary key,
	nome VARCHAR(200)
);

CREATE TABLE pedidos(
	id_pedido serial primary key,
	id_produto int references produtos(id_prod),
	id_fornecedor int references fornecedores(id_forn),
	quantidade int,
	data_pedido DATE
);

-- 5) Inserir dados

-- produtos
insert into produtos(nome, qtd_estoque, preco) values ('tenis', 50, 25.99);
insert into produtos(nome, qtd_estoque, preco) values ('camisas', 200, 39.99);
insert into produtos(nome, qtd_estoque, preco) values ('calcas', 300, 29.99);
insert into produtos(nome, qtd_estoque, preco) values ('chapeus', 100, 19.99);
insert into produtos(nome, qtd_estoque, preco) values ('oculos', 30, 34.99);

-- fornecedores
insert into fornecedores(nome) values ('nike');
insert into fornecedores(nome) values ('adidas');
insert into fornecedores(nome) values ('aramis');
insert into fornecedores(nome) values ('tuff');
insert into fornecedores(nome) values ('prada');

-- pedidos
insert into pedidos(id_produto, id_fornecedor, quantidade, data_pedido) values (1, 1, 10, '2024-08-17');
insert into pedidos(id_produto, id_fornecedor, quantidade, data_pedido) values (2, 2, 15, '2024-01-05');
insert into pedidos(id_produto, id_fornecedor, quantidade, data_pedido) values (3, 3, 35, '2024-02-09');
insert into pedidos(id_produto, id_fornecedor, quantidade, data_pedido) values (4, 4, 40, '2024-07-08');
insert into pedidos(id_produto, id_fornecedor, quantidade, data_pedido) values (5, 5, 45, '2024-11-04');


-- 6) 

-- 6.1) select comum (três tabelas)
select p.id_pedido, prod.nome as produto, f.nome as fornecedor, p.quantidade, 
	p.data_pedido, prod.qtd_estoque, prod.preco from
	pedidos p, produtos prod, fornecedores f where
	p.id_produto = prod.id_prod and p.id_fornecedor = f.id_forn;

-- 6.2) select / inner join
select p.id_pedido, prod.nome as produto, f.nome as fornecedor, p.quantidade, 
	p.data_pedido, prod.qtd_estoque, prod.preco from pedidos p
	inner join produtos prod on p.id_produto = prod.id_prod 
	inner join fornecedores f on p.id_fornecedor = f.id_forn;

-- 6.3) select / left join (duas tabelas)
select p.id_pedido, prod.nome as produto, p.quantidade, p.data_pedido, prod.qtd_estoque, prod.preco FROM
pedidos p left join produtos prod on p.id_produto = prod.id_prod;

-- 6.4) select / left join (três tabelas)
select p.id_pedido, prod.nome as produto, f.nome as fornecedor, p.quantidade, p.data_pedido, prod.qtd_estoque FROM
pedidos p left join produtos prod on p.id_produto = prod.id_prod left join fornecedores f on p.id_fornecedor = f.id_forn;

-- 6.5) select / right join (duas tabelas)
select p.id_pedido, f.nome as fornecedor, p.quantidade, p.data_pedido from 
pedidos p right join fornecedores f on p_id_fornecedor = f.id_forn;

-- 6.6) select / full outer (duas tabelas)
select * FROM pedidos p full outer join produtos prod on p.id_produto = prod.id_prod;

-- 6.7) select / full outer (três tabelas)
select * from pedidos p full outer join produtos prod 
on p.id_pedido = prod.id_prod
full outer join fornecedores f on p.id_fornecedor = f.id_forn


-- 8)

-- 8.1) max
select max(preco) from produtos;

-- 8.2) min
select min(preco) from produtos;

-- 8.3) avg
select avg(preco) from produtos;

-- 8.4) sum
select sum(preco) from produtos;

-- 8.5) count
select count(*) from fornecedores;


-- 9) Group by
select nome, max(preco), count(*) from produtos group by nome

-- 10) Having
 select nome, max(preco), count(*) from produtos group by nome having max(preco) > 26