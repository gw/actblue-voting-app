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

  describe "POST /votes" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        candidate = Candidate.create!(name: 'Test Candidate')

        post votes_path, params: { candidate_id: candidate.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user is authenticated and has not voted" do
      it "successfully records the vote and returns success" do
        user = User.create!(email: 'voter@example.com')
        candidate = Candidate.create!(name: 'Test Candidate')

        # Simulate login
        post login_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)

        post votes_path, params: { candidate_id: candidate.id }

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['redirect_url']).to eq(results_path)

        # Verify user's vote was recorded
        user.reload
        expect(user.voted_for_candidate).to eq(candidate)
      end
    end

    context "when user has already voted" do
      it "returns error and does not allow duplicate voting" do
        existing_candidate = Candidate.create!(name: 'Existing Candidate')
        new_candidate = Candidate.create!(name: 'New Candidate')
        user = User.create!(email: 'voteduser@example.com', voted_for_candidate: existing_candidate)

        # Simulate login
        post login_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)

        post votes_path, params: { candidate_id: new_candidate.id }

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to eq(["You have already voted"])

        # Verify user's vote remains unchanged
        user.reload
        expect(user.voted_for_candidate).to eq(existing_candidate)
      end
    end

    context "when candidate does not exist" do
      it "returns error for invalid candidate ID" do
        user = User.create!(email: 'voter@example.com')

        # Simulate login
        post login_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)

        post votes_path, params: { candidate_id: 999999 }

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to eq(["Invalid candidate selected"])

        # Verify user has not voted
        user.reload
        expect(user.voted_for_candidate).to be_nil
      end
    end

    context "when no candidate_id is provided" do
      it "returns error for missing candidate" do
        user = User.create!(email: 'voter@example.com')

        # Simulate login
        post login_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)

        post votes_path, params: {}

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to eq(["Invalid candidate selected"])
      end
    end
  end
end
