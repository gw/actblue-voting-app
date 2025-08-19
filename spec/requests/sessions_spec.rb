require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "renders the login page successfully" do
      get login_path
      expect(response).to be_successful
    end
  end

  describe "POST /login" do
    context "with valid parameters" do
      it "logs in an existing user" do
        user = User.create!(email: 'test@example.com')
        
        post login_path, params: { email: 'test@example.com', zip_code: '12345' }
        
        expect(response).to redirect_to(root_path)
        expect(session[:user_email]).to eq('test@example.com')
        expect(flash[:notice]).to eq('Successfully logged in!')
      end

      it "creates and logs in a new user" do
        expect {
          post login_path, params: { email: 'new@example.com', zip_code: '54321' }
        }.to change(User, :count).by(1)
        
        expect(response).to redirect_to(root_path)
        expect(session[:user_email]).to eq('new@example.com')
        expect(flash[:notice]).to eq('Successfully logged in!')
      end

      it "handles case insensitive email and strips whitespace" do
        post login_path, params: { email: '  TEST@EXAMPLE.COM  ', zip_code: ' 12345 ' }
        
        expect(response).to redirect_to(root_path)
        expect(session[:user_email]).to eq('test@example.com')
      end
    end

    context "with invalid parameters" do
      it "renders error when email is missing" do
        post login_path, params: { zip_code: '12345' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Email is required')
        expect(session[:user_email]).to be_nil
      end

      it "renders error when email format is invalid" do
        post login_path, params: { email: 'invalid-email', zip_code: '12345' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Email is invalid')
        expect(session[:user_email]).to be_nil
      end
    end
  end

  describe "DELETE /logout" do
    it "logs out the user and clears the session" do
      user = User.create!(email: 'test@example.com')
      
      # Log in first
      post login_path, params: { email: 'test@example.com', zip_code: '12345' }
      expect(session[:user_email]).to eq('test@example.com')
      
      # Then log out
      delete logout_path
      
      expect(response).to redirect_to(root_path)
      expect(session[:user_email]).to be_nil
      expect(flash[:notice]).to eq('Successfully logged out!')
    end
  end

  describe "authentication helpers" do
    it "current_user returns nil when not logged in" do
      get root_path
      expect(controller.send(:current_user)).to be_nil
    end

    it "current_user returns user when logged in" do
      user = User.create!(email: 'test@example.com')
      post login_path, params: { email: 'test@example.com', zip_code: '12345' }
      
      get root_path
      expect(controller.send(:current_user)).to eq(user)
    end

    it "logged_in? returns false when not logged in" do
      get root_path
      expect(controller.send(:logged_in?)).to be false
    end

    it "logged_in? returns true when logged in" do
      user = User.create!(email: 'test@example.com')
      post login_path, params: { email: 'test@example.com', zip_code: '12345' }
      
      get root_path
      expect(controller.send(:logged_in?)).to be true
    end
  end
end