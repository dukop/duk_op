require 'spec_helper'

describe User do

  describe 'can_edit' do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    it 'should allow a user to edit themselves' do
      expect(@user.can_edit? @user).to be true
    end

    it 'should not allow a normal user to edit another user' do
      u = FactoryGirl.create(:user, email: 'something@user.com', username: 'another_user')
      expect(u.can_edit? @user).to be false
    end

    it 'should allow an admin user to edit another user' do
      admin = FactoryGirl.create(:admin_user)
      expect(admin.can_edit? @user).to be true
    end
  end

  describe 'events' do
    let(:user) { FactoryGirl.create(:user) }
    let(:future_event) { FactoryGirl.create(:event_tomorrow) }
    let(:past_event) { f = FactoryGirl.build(:event_yesterday); f.save(validate: false); f }
    let(:unpublished_event) { FactoryGirl.create(:unpublished_event) }
    before do
      user.events.clear
      user.events << future_event << past_event << unpublished_event
    end
    describe 'coming events' do
      subject { user.coming_events }
      it { should include future_event }
      it { should_not include past_event }
      it { should_not include unpublished_event }
    end

    describe 'unpublished events' do
      subject { user.unpublished_events }
      it { should =~ [unpublished_event] }
    end
  end
end
