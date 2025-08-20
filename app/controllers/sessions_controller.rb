class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by(email: session_params[:email])

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
    session[:user_email] = nil
    redirect_to root_path
  end

  private

  def session_params
    params.require(:email)
    { email: params.require(:email).downcase.strip }
  end
end
