/**
 * Utility function to get the CSRF token from the document's meta tag
 * @returns {string|null} The CSRF token value or null if not found
 */
export const getCsrfToken = () => {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
};
