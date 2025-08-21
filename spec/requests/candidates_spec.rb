require 'rails_helper'

RSpec.describe "/candidates", type: :request do
  let(:user) { User.create!(email: "test@example.com") }

  describe "POST /candidates" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        post candidates_path, params: { name: "New Candidate" }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Please log in to continue")
      end
    end

    context "when user is authenticated" do
      before do
        # Simulate login
        post login_path, params: { email: user.email }
        expect(response).to have_http_status(:ok)
      end

      context "with valid candidate name" do
        it "creates a new candidate and auto-votes for them" do
          expect {
            post candidates_path, params: { name: "New Artist" }
          }.to change(Candidate, :count).by(1)

          candidate = Candidate.last
          expect(candidate.name).to eq("New Artist")
          
          # Check auto-vote was cast
          user.reload
          expect(user.voted_for_candidate).to eq(candidate)

          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["success"]).to be true
          expect(json["redirect_url"]).to eq(results_path)
        end
      end

      context "with blank candidate name" do
        it "returns error for blank name" do
          post candidates_path, params: { name: "" }

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]).to include("Candidate name can't be blank")
        end

        it "returns error for whitespace-only name" do
          post candidates_path, params: { name: "   " }

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]).to include("Candidate name can't be blank")
        end
      end

      context "with duplicate candidate name" do
        before do
          Candidate.create!(name: "Existing Artist")
        end

        it "returns error for duplicate name" do
          post candidates_path, params: { name: "Existing Artist" }

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]).to include("Name has already been taken")
        end
      end

      context "when user has already voted" do
        before do
          existing_candidate = Candidate.create!(name: "Previous Artist")
          user.update!(voted_for_candidate: existing_candidate)
        end

        it "returns error when user already voted" do
          post candidates_path, params: { name: "New Artist" }

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]).to include("You have already voted")
        end
      end

      context "when maximum candidates limit is reached" do
        before do
          # Create 10 candidates (the maximum)
          10.times do |i|
            Candidate.create!(name: "Artist #{i}")
          end
        end

        it "returns error when trying to add 11th candidate" do
          post candidates_path, params: { name: "11th Artist" }

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]).to include("Maximum number of candidates reached")
        end
      end

      context "when auto-vote fails" do
        it "deletes the candidate and returns error" do
          # Mock the user update to fail
          allow_any_instance_of(User).to receive(:update).and_return(false)

          expect {
            post candidates_path, params: { name: "Test Artist" }
          }.not_to change(Candidate, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]).to include("Unable to record your vote. Please try again.")
        end
      end

      context "with special characters and edge cases" do
        it "accepts candidate names with special characters" do
          post candidates_path, params: { name: "Artist & The Band" }

          expect(response).to have_http_status(:ok)
          candidate = Candidate.last
          expect(candidate.name).to eq("Artist & The Band")
        end

        it "trims whitespace from candidate names" do
          post candidates_path, params: { name: "  Spaced Artist  " }

          expect(response).to have_http_status(:ok)
          candidate = Candidate.last
          expect(candidate.name).to eq("Spaced Artist")
        end
      end
    end
  end
end