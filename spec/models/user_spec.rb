require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'requires an email' do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires a valid email format' do
      user = User.new(email: 'invalid')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it 'requires a unique email' do
      User.create!(email: 'test@example.com')
      duplicate = User.new(email: 'test@example.com')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it 'is valid with just an email' do
      user = User.new(email: 'test@example.com')
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it 'can belong to a candidate (voted_for_candidate)' do
      candidate = Candidate.create!(name: 'Taylor Swift')
      user = User.create!(email: 'voter@example.com', voted_for_candidate: candidate)
      expect(user.voted_for_candidate).to eq(candidate)
    end

    it 'can exist without voting for anyone' do
      user = User.create!(email: 'voter@example.com')
      expect(user.voted_for_candidate).to be_nil
    end
  end

  describe '#has_voted?' do
    it 'returns false when user has not voted' do
      user = User.create!(email: 'voter@example.com')
      expect(user.has_voted?).to be false
    end

    it 'returns true when user has voted' do
      candidate = Candidate.create!(name: 'Beyonce')
      user = User.create!(email: 'voter@example.com', voted_for_candidate: candidate)
      expect(user.has_voted?).to be true
    end
  end
end
