class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by(email: session_params[:email])

    if user.persisted?
      session[:user_email] = user.email
      redirect_to root_path, notice: 'Successfully logged in!'
    else
      flash.now[:alert] = user.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  rescue ActionController::ParameterMissing => e
    flash.now[:alert] = "#{e.param.to_s.humanize} is required"
    render :new, status: :unprocessable_entity
  end

  def destroy
    session[:user_email] = nil
    redirect_to root_path, notice: 'Successfully logged out!'
  end

  private

  def session_params
    params.require(:email)
    { email: params.require(:email).downcase.strip }
  end
end
