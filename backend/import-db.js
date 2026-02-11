import mysql from 'mysql2/promise';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Manuel Environment Parser (fail-safe for .env encoding issues on Windows)
async function loadEnvManually() {
    try {
        const envPath = path.join(__dirname, '.env');
        const content = await fs.readFile(envPath, 'utf8');
        const lines = content.split('\n');

        lines.forEach(line => {
            const [key, ...valueParts] = line.split('=');
            if (key && valueParts.length > 0) {
                const value = valueParts.join('=').trim();
                process.env[key.trim()] = value;
            }
        });
        console.log('✅ Variables cargadas manualmente desde .env');
    } catch (err) {
        console.error('❌ Error cargando .env manualmente:', err.message);
    }
}

async function importDatabase() {
    await loadEnvManually();

    console.log('--- Debug de Conexión ---');
    console.log('Host:', process.env.DB_HOST || '❌ NO ENCONTRADO');
    console.log('Puerto:', process.env.DB_PORT || '❌ NO ENCONTRADO');
    console.log('Usuario:', process.env.DB_USER || '❌ NO ENCONTRADO');
    console.log('-------------------------\n');

    if (!process.env.DB_HOST) {
        console.error('❌ Error: No se encontraron variables. Asegúrate de que el archivo .env existe y tiene contenido.');
        return;
    }

    const config = {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        port: process.env.DB_PORT,
        multipleStatements: true,
        ssl: { rejectUnauthorized: false }
    };

    try {
        const connection = await mysql.createConnection(config);
        console.log('✅ ¡Conectado con éxito a Aiven!');

        const sqlPath = path.join(__dirname, 'database_produccion.sql');
        let sql = await fs.readFile(sqlPath, 'utf8');

        // Quitar el BOM (Byte Order Mark) si existe (común en archivos de Windows)
        if (sql.charCodeAt(0) === 0xFEFF) {
            sql = sql.slice(1);
        }

        console.log('⏳ Importando tablas en la nube... (por favor espera)');
        await connection.query(sql);

        console.log('✨ ¡IMPORTACIÓN COMPLETADA CON ÉXITO! ✨');
        await connection.end();
    } catch (error) {
        console.error('❌ ERROR CRÍTICO AL IMPORTAR:');
        console.error(error.message);
    }
}

importDatabase();
