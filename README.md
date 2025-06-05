# 📚 Taller MySQL 8.0 - Solución

Solución completa y resumida del taller de MySQL 8.0:

- **Índices:** Creamos índices en `Libros(titulo)` y `Libros(autor)` para acelerar búsquedas.
- **Consultas EXPLAIN:** Optimización con `idx_prestamos_devolucion`, `idx_libros_categoria_id`, y `idx_ejemplares_libro_ejemplar`.
- **Transacciones:** Flujo seguro para registrar préstamos evitando duplicados.
- **Procedimiento almacenado:** `calcular_multa_simple` calcula multas por atraso.
- **Función:** `es_usuario_moroso` identifica usuarios con préstamos vencidos.
- **Triggers:** Auditoría automática de préstamos y devoluciones en `Historial_Prestamos`.
- **Backup y restauración:** Uso de `mysqldump` y recuperación.
- **Roles y seguridad:** Creación de `rol_docente` con solo lectura y usuario `profesorA`.

```sql
-- Ejemplo de ejecución:
mysql -u root -p < solucion_taller.sql
