class User < ApplicationRecord
  belongs_to :voted_for_candidate, class_name: 'Candidate', optional: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def has_voted?
    voted_for_candidate_id.present?
  end

  def can_vote?
    !has_voted?
  end

  def can_add_candidate?
    !has_voted? && Candidate.count < 10
  end
end
