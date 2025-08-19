require 'rails_helper'

RSpec.describe Candidate, type: :model do
  describe 'validations' do
    it 'requires a name' do
      candidate = Candidate.new
      expect(candidate).not_to be_valid
      expect(candidate.errors[:name]).to include("can't be blank")
    end
    
    it 'requires a unique name' do
      Candidate.create!(name: 'Adele')
      duplicate = Candidate.new(name: 'Adele')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end
    
    it 'is valid with a unique name' do
      candidate = Candidate.new(name: 'Ed Sheeran')
      expect(candidate).to be_valid
    end
  end
  
  describe 'associations' do
    it 'has many voters through voted_for_candidate_id' do
      candidate = Candidate.create!(name: 'Billie Eilish')
      user1 = User.create!(email: 'voter1@example.com', zip_code: '12345', voted_for_candidate: candidate)
      user2 = User.create!(email: 'voter2@example.com', zip_code: '54321', voted_for_candidate: candidate)
      
      expect(candidate.voters).to include(user1, user2)
      expect(candidate.voters.count).to eq(2)
    end
    
    it 'can exist without any voters' do
      candidate = Candidate.create!(name: 'Bruno Mars')
      expect(candidate.voters).to be_empty
    end
  end
  
  describe '#vote_count' do
    it 'returns 0 when no users have voted for the candidate' do
      candidate = Candidate.create!(name: 'Lady Gaga')
      expect(candidate.vote_count).to eq(0)
    end
    
    it 'returns the correct count when users have voted' do
      candidate = Candidate.create!(name: 'Drake')
      3.times do |i|
        User.create!(email: "voter#{i}@example.com", zip_code: '12345', voted_for_candidate: candidate)
      end
      
      expect(candidate.vote_count).to eq(3)
    end
    
    it 'updates when new votes are added' do
      candidate = Candidate.create!(name: 'Ariana Grande')
      expect(candidate.vote_count).to eq(0)
      
      User.create!(email: 'voter@example.com', zip_code: '12345', voted_for_candidate: candidate)
      expect(candidate.vote_count).to eq(1)
      
      User.create!(email: 'voter2@example.com', zip_code: '54321', voted_for_candidate: candidate)
      expect(candidate.vote_count).to eq(2)
    end
    
    it 'decreases when votes are removed' do
      candidate = Candidate.create!(name: 'The Weeknd')
      user = User.create!(email: 'voter@example.com', zip_code: '12345', voted_for_candidate: candidate)
      
      expect(candidate.vote_count).to eq(1)
      
      user.update!(voted_for_candidate: nil)
      expect(candidate.vote_count).to eq(0)
    end
  end
  
  describe 'when candidate is destroyed' do
    it 'nullifies the voted_for_candidate_id on associated users' do
      candidate = Candidate.create!(name: 'Post Malone')
      user = User.create!(email: 'voter@example.com', zip_code: '12345', voted_for_candidate: candidate)
      
      expect(user.voted_for_candidate_id).to eq(candidate.id)
      
      candidate.destroy
      user.reload
      
      expect(user.voted_for_candidate_id).to be_nil
    end
  end
end