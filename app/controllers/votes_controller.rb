class VotesController < ApplicationController
  before_action :require_authentication

  def index
    # If user has already voted, redirect to results page
    if current_user.has_voted?
      redirect_to results_path
      return
    end

    # Fetch all candidates for voting
    @candidates = Candidate.all.order(:name)
  end

  def create
    # Check if user can vote
    if current_user.has_voted?
      render json: { success: false, errors: ["You have already voted"] }, status: :unprocessable_entity
      return
    end

    # Find the candidate
    candidate = Candidate.find_by(id: params[:candidate_id])
    unless candidate
      render json: { success: false, errors: ["Invalid candidate selected"] }, status: :unprocessable_entity
      return
    end

    # Update user's vote
    if current_user.update(voted_for_candidate: candidate)
      render json: { success: true, redirect_url: results_path }
    else
      render json: { success: false, errors: ["Unable to record your vote. Please try again."] }, status: :unprocessable_entity
    end
  end
end
