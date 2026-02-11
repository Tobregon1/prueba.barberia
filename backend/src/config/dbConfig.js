import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

// Crear pool de conexiones
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'barberia_db',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    timezone: '+00:00',
    // ESTA ES LA PARTE CLAVE:
    ssl: process.env.DB_HOST && process.env.DB_HOST !== 'localhost' ? {
        rejectUnauthorized: false
    } : undefined
});

// Probar conexión
pool.getConnection()
    .then(connection => {
        console.log('✅ Conexión a la base de datos establecida');
        connection.release();
    })
    .catch(err => {
        console.error('❌ Error al conectar a la base de datos:', err.message);
    });

export default pool;
