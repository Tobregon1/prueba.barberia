import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuración de almacenamiento
// NOTA: Vercel tiene un sistema de archivos de solo lectura. 
// Usamos /tmp para evitar errores, pero las fotos no persistirán entre reinicios.
const isVercel = process.env.VERCEL || process.env.NODE_ENV === 'production';
const storage = isVercel
    ? multer.diskStorage({
        destination: (req, file, cb) => {
            cb(null, '/tmp');
        },
        filename: (req, file, cb) => {
            const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
            cb(null, 'empleado-' + uniqueSuffix + path.extname(file.originalname));
        }
    })
    : multer.diskStorage({
        destination: (req, file, cb) => {
            cb(null, path.join(__dirname, '../../uploads/empleados'));
        },
        filename: (req, file, cb) => {
            const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
            cb(null, 'empleado-' + uniqueSuffix + path.extname(file.originalname));
        }
    });

// Filtro para validar tipo de archivo
const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
        return cb(null, true);
    } else {
        cb(new Error('Solo se permiten archivos de imagen (JPEG, JPG, PNG)'));
    }
};

// Configurar multer
const upload = multer({
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB máximo
    },
    fileFilter: fileFilter
});

export default upload;
