--1. Consideremos as tabelas Produtos e ItensVenda. Ao registrar uma nova venda em
--estoque, queremos atualizar a quantidade do produto no estoque.

--Produto (cod_prod, descrição, qtd_disponivel)
--ItensVenda(cod_venda, id_produto, qtd_vendida)


create table produto(
	cod_prod bigserial primary key,
	descricao varchar(200),
	qtd_disponivel int
);

create table itensVendas(
	cod_venda bigserial primary key,
	id_produto int,
	qtd_vendida int,
	foreign key(id_produto) references produto(cod_prod)
)

insert into produto(descricao, qtd_disponivel) values ('camisa', 10);

CREATE OR REPLACE FUNCTION atualizar_qtd_produto()
RETURNS TRIGGER AS $$
BEGIN
IF (SELECT qtd_disponivel FROM produto WHERE cod_prod = NEW.id_produto) >= NEW.qtd_vendida THEN
  UPDATE produto
  SET qtd_disponivel = qtd_disponivel - NEW.qtd_vendida
  WHERE cod_prod = NEW.id_produto;
  ELSE
    RAISE EXCEPTION 'estoque insuficiente';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER atualizar_qtd AFTER INSERT ON itensVendas
	FOR EACH ROW
	EXECUTE FUNCTION atualizar_qtd_produto();


-- 2. Crie uma procedure que armazena o dado do usuário excluído numa tabela de backup
-- tb_bkp_usuarios (id, nome, senha)
-- tb_ usuarios (id, nome, senha)

create table tb_bkp_usuarios(
	id bigserial primary key,
	nome varchar(200),
	senha varchar(10)
);

create table tb_usuarios(
	id bigserial primary key,
	nome varchar(200),
	senha varchar(10)
);

insert into tb_usuarios(nome, senha) values ('pedro', '12345');

CREATE OR REPLACE FUNCTION usuario_excluido()
RETURNS TRIGGER AS $$
BEGIN
 insert into tb_bkp_usuarios(nome, senha) values (OLD.nome, OLD.senha);
END;
$$ LANGUAGE 'plpgsql'

CREATE TRIGGER usuario_excluido_trigger BEFORE DELETE on tb_usuarios
FOR EACH ROW
	execute function usuario_excluido();
