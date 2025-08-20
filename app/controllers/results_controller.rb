class ResultsController < ApplicationController
  def index
    # Efficiently calculate vote counts in a single database query to avoid N+1 issues.
    # Uses left_joins to include candidates with zero votes, groups by candidate ID,
    # and selects the vote count as 'votes_count' attribute for use in the view.
    @candidates = Candidate.left_joins(:voters)
                          .group('candidates.id')
                          .select('candidates.*, COUNT(users.id) AS votes_count')
                          .order('votes_count DESC')
  end
end
