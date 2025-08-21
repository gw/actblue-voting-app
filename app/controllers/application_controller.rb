class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_error

  # Health check endpoint for fly.io
  def health
    render json: { status: 'healthy' }, status: :ok
  end

  private

  def current_user
    @current_user ||= User.find_by(email: session[:user_email]) if session[:user_email]
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    unless logged_in?
      redirect_to login_path, alert: 'Please log in to continue'
    end
  end

  # Client expects JSON responses
  def handle_csrf_error
    render json: { errors: ['Invalid CSRF token'] }, status: :unprocessable_entity
  end
end
