import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
    const msg = '⚠️ Supabase URL or Key not found in environment variables. Make sure to set SUPABASE_URL and SUPABASE_KEY in Vercel settings.';
    console.error(msg);
    // Don't throw here at top level to avoid crashing the whole app, 
    // but the service will fail when called.
}

const supabase = createClient(supabaseUrl || 'https://placeholder.supabase.co', supabaseKey || 'placeholder');

export const supabaseService = {
    /**
     * Sube un archivo a un bucket de Supabase
     * @param {Buffer} fileBuffer - El buffer del archivo
     * @param {string} fileName - Nombre del archivo
     * @param {string} mimetype - Tipo de archivo
     * @param {string} bucketName - Nombre del bucket (default: 'empleados')
     * @returns {Promise<string>} - URL pública del archivo
     */
    async subirArchivo(fileBuffer, fileName, mimetype, bucketName = 'empleados') {
        if (!supabaseUrl || !supabaseKey) {
            throw new Error('Supabase configuration missing (URL or Key). Please set them in your environment.');
        }
        try {
            const { data, error } = await supabase.storage
                .from(bucketName)
                .upload(fileName, fileBuffer, {
                    contentType: mimetype || 'image/jpeg',
                    upsert: true
                });

            if (error) {
                console.error('Supabase Error Details:', JSON.stringify(error, null, 2));
                throw error;
            }

            // Obtener URL pública
            const { data: { publicUrl } } = supabase.storage
                .from(bucketName)
                .getPublicUrl(fileName);

            return publicUrl;
        } catch (error) {
            console.error('Error completo en Supabase Storage:', error);
            throw error;
        }
    }
};

export default supabase;
