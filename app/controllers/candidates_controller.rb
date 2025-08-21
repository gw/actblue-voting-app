class CandidatesController < ApplicationController
  before_action :require_authentication

  def create
    # Check if user can add a candidate
    if current_user.has_voted?
      render json: { success: false, errors: ["You have already voted"] }, status: :unprocessable_entity
      return
    elsif Candidate.count >= 10
      render json: { success: false, errors: ["Maximum number of candidates reached"] }, status: :unprocessable_entity
      return
    end

    # Validate candidate name
    candidate_name = params[:name]&.strip
    if candidate_name.blank?
      render json: { success: false, errors: ["Candidate name can't be blank"] }, status: :unprocessable_entity
      return
    end

    # Create new candidate
    candidate = Candidate.new(name: candidate_name)

    if candidate.save
      # Auto-vote for the newly created candidate
      if current_user.update(voted_for_candidate: candidate)
        render json: { success: true, redirect_url: results_path }
      else
        # If auto-vote fails, delete the candidate to maintain consistency
        candidate.destroy
        render json: { success: false, errors: ["Unable to record your vote. Please try again."] }, status: :unprocessable_entity
      end
    else
      # Handle validation errors (e.g., duplicate name)
      render json: { success: false, errors: candidate.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
