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
end