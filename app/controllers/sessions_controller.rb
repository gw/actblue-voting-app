class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new]

  def new
  end

  def create
    user = User.find_or_create_by(email: params.require(:email).downcase.strip)

    if user.persisted?
      session[:user_email] = user.email
      render json: { redirect_url: votes_path }, status: :ok
    else
      error_messages = user.errors.full_messages
      render json: { errors: error_messages }, status: :unprocessable_entity
    end
  rescue ActionController::ParameterMissing => e
    error_message = "#{e.param.to_s.humanize} is required"
    render json: { errors: [error_message] }, status: :unprocessable_entity
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def redirect_if_logged_in
    if logged_in?
      if current_user.has_voted?
        redirect_to results_path
      else
        redirect_to votes_path
      end
    end
  end
end
