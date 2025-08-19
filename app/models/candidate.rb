class Candidate < ApplicationRecord
  has_many :voters, class_name: 'User', foreign_key: 'voted_for_candidate_id'
  
  def vote_count
    voters.count
  end
end
