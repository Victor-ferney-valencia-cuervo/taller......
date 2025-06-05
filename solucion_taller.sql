-- ====================================
-- ✅ Ejercicio 1: Creación de índices básicos
-- ====================================
USE Biblioteca;

CREATE INDEX idx_libros_titulo ON Libros(titulo);
CREATE INDEX idx_libros_autor ON Libros(autor);

EXPLAIN SELECT id_libro, titulo, autor 
FROM Libros 
WHERE titulo LIKE 'Algoritmos%' OR autor = 'Donald Knuth';

-- ====================================
-- ✅ Ejercicio 2: Uso de EXPLAIN para optimizar consultas
-- ====================================
EXPLAIN SELECT p.id_prestamo, u.nombre, l.titulo, p.fecha_prestamo
FROM Prestamos p
JOIN Usuarios u ON p.id_usuario = u.id_usuario
JOIN Ejemplares e ON p.id_ejemplar = e.id_ejemplar
JOIN Libros l ON e.id_libro = l.id_libro
WHERE p.fecha_devolucion IS NULL
  AND l.categoria = 'Ciencia de la Computación';

CREATE INDEX idx_prestamos_devolucion ON Prestamos(fecha_devolucion);
CREATE INDEX idx_libros_categoria_id ON Libros(categoria, id_libro);
CREATE INDEX idx_ejemplares_libro_ejemplar ON Ejemplares(id_libro, id_ejemplar);

EXPLAIN SELECT p.id_prestamo, u.nombre, l.titulo, p.fecha_prestamo
FROM Prestamos p
JOIN Usuarios u ON p.id_usuario = u.id_usuario
JOIN Ejemplares e ON p.id_ejemplar = e.id_ejemplar
JOIN Libros l ON e.id_libro = l.id_libro
WHERE p.fecha_devolucion IS NULL
  AND l.categoria = 'Ciencia de la Computación';

-- ====================================
-- ✅ Ejercicio 3: Implementación de transacción segura
-- ====================================
START TRANSACTION;

SELECT disponible 
FROM Ejemplares 
WHERE id_ejemplar = 321 
FOR UPDATE;

INSERT INTO Prestamos(fecha_prestamo, fecha_limite, id_ejemplar, id_usuario)
VALUES (CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 14 DAY), 321, 789);

UPDATE Ejemplares 
SET disponible = FALSE 
WHERE id_ejemplar = 321;

COMMIT;

-- ====================================
-- ✅ Ejercicio 4: Procedimiento almacenado para cálculo de multa
-- ====================================
DELIMITER //
CREATE PROCEDURE calcular_multa_simple(
    IN p_id_prestamo INT,
    OUT p_monto_multa DECIMAL(10,2)
)
BEGIN
    DECLARE v_fecha_limite DATE;
    DECLARE v_fecha_devolucion DATE;
    DECLARE v_dias_retraso INT;

    SELECT fecha_limite, fecha_devolucion 
    INTO v_fecha_limite, v_fecha_devolucion
    FROM Prestamos
    WHERE id_prestamo = p_id_prestamo;

    IF v_fecha_devolucion IS NULL THEN
        SET v_fecha_devolucion = CURRENT_DATE();
    END IF;

    SET v_dias_retraso = DATEDIFF(v_fecha_devolucion, v_fecha_limite);

    IF v_dias_retraso > 0 THEN
        SET p_monto_multa = v_dias_retraso * 1.00;
    ELSE
        SET p_monto_multa = 0.00;
    END IF;
END //
DELIMITER ;

SET @multa = 0.00;
CALL calcular_multa_simple(15, @multa);
SELECT @multa;

-- ====================================
-- ✅ Ejercicio 5: Función para obtener usuarios morosos
-- ====================================
DELIMITER //
CREATE FUNCTION es_usuario_moroso(
    p_id_usuario INT
) RETURNS BOOL
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*)
    INTO v_count
    FROM Prestamos
    WHERE id_usuario = p_id_usuario
      AND fecha_devolucion IS NULL
      AND fecha_limite < CURRENT_DATE();

    RETURN v_count > 0;
END //
DELIMITER ;

SELECT id_usuario, es_usuario_moroso(id_usuario) AS moroso
FROM Usuarios
WHERE id_usuario IN (123, 456, 789);

-- ====================================
-- ✅ Ejercicio 6: Triggers para historial de préstamos
-- ====================================
DELIMITER //
CREATE TRIGGER trg_historial_prestamo
AFTER INSERT ON Prestamos
FOR EACH ROW
BEGIN
    INSERT INTO Historial_Prestamos(
        id_prestamo,
        id_usuario,
        id_ejemplar,
        tipo_evento,
        fecha_evento
    ) VALUES (
        NEW.id_prestamo,
        NEW.id_usuario,
        NEW.id_ejemplar,
        'PRESTAMO',
        NOW()
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_historial_devolucion
AFTER UPDATE ON Prestamos
FOR EACH ROW
BEGIN
    IF NEW.fecha_devolucion IS NOT NULL AND OLD.fecha_devolucion IS NULL THEN
        INSERT INTO Historial_Prestamos(
            id_prestamo,
            id_usuario,
            id_ejemplar,
            tipo_evento,
            fecha_evento
        ) VALUES (
            NEW.id_prestamo,
            NEW.id_usuario,
            NEW.id_ejemplar,
            'DEVOLUCION',
            NOW()
        );
    END IF;
END //
DELIMITER ;

-- ====================================
-- ✅ Ejercicio 7: Backup y restauración (en comentarios porque se hace en bash)
-- ====================================
-- mysqldump -u root -p --single-transaction --routines --triggers Biblioteca > backup_biblioteca.sql
-- mysql -u root -p Biblioteca < backup_biblioteca.sql

-- ====================================
-- ✅ Ejercicio 8: Gestión de usuarios y roles
-- ====================================
CREATE ROLE rol_docente;
GRANT SELECT ON Biblioteca.Libros TO rol_docente;
GRANT SELECT ON Biblioteca.Ejemplares TO rol_docente;
GRANT SELECT ON Biblioteca.Prestamos TO rol_docente;

CREATE USER 'profesorA'@'localhost' IDENTIFIED BY 'Prof3s0rSegur0!';
GRANT rol_docente TO 'profesorA'@'localhost';
SET DEFAULT ROLE rol_docente FOR 'profesorA'@'localhost';
