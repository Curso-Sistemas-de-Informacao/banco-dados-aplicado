CREATE FUNCTION ProdComedia(ano_interesse INT, estudio_interesse VARCHAR(30))
RETURNS BOOLEAN
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Filme WHERE ano = ano_interesse AND nome_estudio = estudio_interesse) THEN
        RETURN TRUE;
    
    ELSIF (SELECT COUNT(*) FROM Filme WHERE ano = ano_interesse AND nome_estudio = estudio_interesse AND genero = 'comedia') >= 1 THEN
        RETURN TRUE;
    
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT ProdComedia(2022, 'Pixar');

--------------------

CREATE OR REPLACE FUNCTION MediaVariancia(
    IN e VARCHAR(30),
    OUT media REAL,
    OUT variancia REAL
)
AS $$
BEGIN

    SELECT AVG(duracao) INTO media
    FROM Filme
    WHERE nome_estudio = e;

 
    SELECT VARIANCE(duracao) INTO variancia
    FROM Filme
    WHERE nome_estudio = e;
    
   
    IF media IS NULL THEN
        media := 0;
        variancia := 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-------------------------

CREATE PROCEDURE MediaVariancia(
IN e VARCHAR(20), OUT media REAL, OUT variancia REAL)
DECLARE contFilme INTEGER;
BEGIN
SET media = 0.0; SET variancia = 0.0; SET contFilme = 0;
FOR loopFilme AS CursorFilme CURSOR FOR

SELECT duracao FROM Filme WHERE nome_estudio = e;

DO
SET contFilme = contFilme + 1;
SET media = media + duracao;
SET variancia = variancia + duracao * duracao;
END FOR;
SET media = media/contFilme;
SET variancia = variancia/contFilme - media * media
END;