class Candidate < ApplicationRecord
  has_many :voters, class_name: 'User', foreign_key: 'voted_for_candidate_id', dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
