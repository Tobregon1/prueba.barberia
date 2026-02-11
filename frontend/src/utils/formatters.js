/**
 * Formatea un número como moneda de Pesos Argentinos (ARS)
 * @param {number|string} cantidad - El monto a formatear
 * @returns {string} - El monto formateado (ej: $ 1.500)
 */
export const formatCurrency = (cantidad) => {
    return new Intl.NumberFormat('es-AR', {
        style: 'currency',
        currency: 'ARS',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(cantidad || 0);
};

/**
 * Obtiene la URL completa de una imagen (manejando Supabase y local)
 * @param {string} path - El path o URL de la imagen
 * @returns {string} - La URL completa
 */
export const getImageUrl = (path) => {
    if (!path) return '';
    if (path.startsWith('http')) return path;

    const baseUrl = import.meta.env.VITE_API_URL
        ? import.meta.env.VITE_API_URL.split('/api')[0]
        : 'http://localhost:3000';

    const cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
    const cleanPath = path.startsWith('/') ? path : `/${path}`;

    return `${cleanBaseUrl}${cleanPath}`;
};
