class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:email]&.downcase&.strip
    # Note: password and zip_code parameters intentionally ignored per requirements

    if email.present?
      user = User.find_or_create_by(email: email)

      if user.persisted?
        session[:user_email] = user.email
        # TODO: Redirect to voting page once implemented in Stage 7
        redirect_to root_path, notice: 'Successfully logged in!'
      else
        flash.now[:alert] = user.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Email is required'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_email] = nil
    redirect_to root_path, notice: 'Successfully logged out!'
  end
end