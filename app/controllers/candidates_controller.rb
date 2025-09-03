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

    begin
      Candidate.transaction do
        candidate.save!
        current_user.update!(voted_for_candidate: candidate)
      end

      render json: { success: true, redirect_url: results_path }
    rescue ActiveRecord::RecordInvalid => e
      render json: { success: false, errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
