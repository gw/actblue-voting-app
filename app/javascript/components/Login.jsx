import React, { useState } from "react";
import { getCsrfToken } from "../utils/csrf";

const Login = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    zipCode: ''
  });
  const [clientErrors, setClientErrors] = useState({});
  const [serverError, setServerError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Clear errors when user starts typing
    if (clientErrors[name]) {
      setClientErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
    // Clear server error when user starts typing
    if (serverError) {
      setServerError('');
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email is invalid';
    }

    if (!formData.password.trim()) {
      newErrors.password = 'Password is required';
    }

    if (!formData.zipCode.trim()) {
      newErrors.zipCode = 'Zip code is required';
    }

    return newErrors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formErrors = validateForm();
    if (Object.keys(formErrors).length > 0) {
      setClientErrors(formErrors);
      return;
    }

    setIsSubmitting(true);
    setServerError(''); // Clear any previous server errors

    const csrfToken = getCsrfToken();

    const formDataToSubmit = new FormData();
    formDataToSubmit.append('email', formData.email);
    formDataToSubmit.append('password', formData.password);
    formDataToSubmit.append('zip_code', formData.zipCode);

    try {
      const response = await fetch('/login', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json',
        },
        body: formDataToSubmit,
      });

      if (response.ok) {
        // Success - parse JSON response and redirect
        const data = await response.json();
        if (data.redirect_url) {
          window.location.href = data.redirect_url;
        }
      } else {
        // Handle server validation errors
        const data = await response.json();
        if (data.errors && data.errors.length > 0) {
          setServerError(data.errors.join(', '));
        } else {
          setServerError('An unexpected error occurred. Please try again.');
        }
        setIsSubmitting(false);
      }
    } catch (error) {
      console.error('Login error:', error);
      setServerError('Network error. Please check your connection and try again.');
      setIsSubmitting(false);
    }
  };

  return (
    <div className="login-container">
      <header className="login-header">
        <h1>VOTE.WEBSITE</h1>
      </header>

      <div className="login-form-container">
        <h2>Sign in to vote</h2>

        {serverError && (
          <div className="alert alert-error">
            {serverError}
          </div>
        )}

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className={clientErrors.email ? 'error' : ''}
              placeholder="myemail@example.com"
              required
            />
            {clientErrors.email && <span className="error-message">{clientErrors.email}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              className={clientErrors.password ? 'error' : ''}
              required
            />
            {clientErrors.password && <span className="error-message">{clientErrors.password}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="zipCode">Zip code</label>
            <input
              type="text"
              id="zipCode"
              name="zipCode"
              value={formData.zipCode}
              onChange={handleChange}
              className={clientErrors.zipCode ? 'error' : ''}
              placeholder="12345"
              required
            />
            {clientErrors.zipCode && <span className="error-message">{clientErrors.zipCode}</span>}
          </div>

          <button
            type="submit"
            className="login-button"
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Signing in...' : 'Sign in'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;
