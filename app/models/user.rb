class User < ApplicationRecord
  belongs_to :voted_for_candidate, class_name: 'Candidate', optional: true
  
  def has_voted?
    voted_for_candidate_id.present?
  end
end
