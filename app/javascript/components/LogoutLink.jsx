import React from "react";
import { getCsrfToken } from "../utils/csrf";

const LogoutLink = () => {
    const handleLogout = async (e) => {
        e.preventDefault();

        try {
            const csrfToken = getCsrfToken();

            const response = await fetch('/logout', {
                method: 'DELETE',
                headers: {
                    'X-CSRF-Token': csrfToken,
                },
            });

            if (response.redirected) {
                window.location.href = response.url;
            } else if (response.ok) {
                // Fallback redirect to root if no redirect in response
                window.location.href = '/';
            }
        } catch (error) {
            console.error('Logout error:', error);
            // Fallback - still redirect to home
            window.location.href = '/';
        }
    };

    return (
        <a href="#" onClick={handleLogout} className="logout-link">
            Logout
        </a>
    );
};

export default LogoutLink;
