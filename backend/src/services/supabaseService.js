import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.warn('⚠️ Supabase URL or Key not found in environment variables. Image uploads will fail.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

export const supabaseService = {
    /**
     * Sube un archivo a un bucket de Supabase
     * @param {Buffer} fileBuffer - El buffer del archivo
     * @param {string} fileName - Nombre del archivo
     * @param {string} bucketName - Nombre del bucket (default: 'empleados')
     * @returns {Promise<string>} - URL pública del archivo
     */
    async subirArchivo(fileBuffer, fileName, bucketName = 'empleados') {
        try {
            const { data, error } = await supabase.storage
                .from(bucketName)
                .upload(fileName, fileBuffer, {
                    contentType: 'image/jpeg', // O detectar dinámicamente
                    upsert: true
                });

            if (error) {
                throw error;
            }

            // Obtener URL pública
            const { data: { publicUrl } } = supabase.storage
                .from(bucketName)
                .getPublicUrl(fileName);

            return publicUrl;
        } catch (error) {
            console.error('Error en Supabase Storage:', error);
            throw new Error('Error al subir archivo a la nube');
        }
    }
};

export default supabase;
