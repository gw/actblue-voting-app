class User < ApplicationRecord
  belongs_to :voted_for_candidate, class_name: 'Candidate', optional: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def has_voted?
    voted_for_candidate_id.present?
  end
end
