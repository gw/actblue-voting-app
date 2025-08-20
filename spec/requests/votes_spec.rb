require 'rails_helper'

RSpec.describe "Votes", type: :request do
  describe "GET /votes" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        get votes_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user is authenticated but has not voted" do
      it "shows the voting page with candidates" do
        user = User.create!(email: 'newvoter@example.com')
        candidate1 = Candidate.create!(name: 'Test Candidate 1')
        candidate2 = Candidate.create!(name: 'Test Candidate 2')
        
        # Simulate login by posting to login first
        post login_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)
        
        get votes_path
        
        expect(response).to be_successful
        expect(response.body).to include('data-react-class="Vote"')
        expect(response.body).to include('Test Candidate 1')
        expect(response.body).to include('Test Candidate 2')
      end
    end

    context "when user is authenticated and has already voted" do
      it "redirects to results page" do
        candidate = Candidate.create!(name: 'Test Candidate')
        user = User.create!(email: 'voteduser@example.com', voted_for_candidate: candidate)
        
        # Simulate login by posting to login first
        post login_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)
        
        get votes_path
        
        expect(response).to redirect_to(results_path)
      end
    end
  end
end