require 'rails_helper'

RSpec.describe Team, type: :model do

  let(:team) { create(:team) } 
  let(:user) { create(:user) }

  it { is_expected.to have_many(:members) }
  
  it { is_expected.to have_many(:form_actions) } 

  it "can delete members" do
    team.members << user
    team.members.delete user
    expect(team.members).to be_empty
  end
end
