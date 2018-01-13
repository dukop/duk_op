require 'spec_helper'

describe Calendar do

  describe 'Calendar.new(:coming)' do
    before(:all) do
      l1 =  FactoryGirl.create(:location)
      l2 = FactoryGirl.create(:other_location, street_address: 'Strandvejen 49')
      @cat = FactoryGirl.create(:random_category)
      other_cat = FactoryGirl.create(:random_category)
      @event_now = FactoryGirl.build(
        :event, start_time: DateTime.now - 5.minutes, categories: [@cat], location: l1
      )
      @event_now.save(validate: false)
      FactoryGirl.create(:event, start_time: DateTime.now + 1.hour,
                         categories: [@cat], location: l1)
      @event_tomorrow = FactoryGirl.create(:event_tomorrow, categories: [other_cat],
                                           location: l2)
      @event_yesterday = FactoryGirl.build(:event_yesterday, location: l2)
      @event_yesterday.save
      @unpublished_event = FactoryGirl.create(:unpublished_event)
      @cal = Calendar.new
    end

    it 'should not return past events' do
      expect(@cal.events).not_to include(@event_yesterday)
    end

    it 'should include future events' do
      expect(@cal.events).to include(@event_tomorrow)
    end

    it 'should not crash if an event does not have a location' do
      Event.new(start_time: DateTime.now + 1.hour, end_time: DateTime.now + 2.hour).save(validate: false)
      expect { Calendar.new }.not_to raise_exception
    end
  end
  describe 'Calendar.for_user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:published) { FactoryGirl.create(:event, user: user) }
    let(:unpublished) { FactoryGirl.create(:unpublished_event, user: user) }
    subject { Calendar.with_hidden(user) }
    # make sure everything is initialized
    before { published && unpublished }

    it 'should include unpublished events' do
      expect(subject.events).to include unpublished
    end
    it 'should include published events' do
      expect(subject.events).to include published
    end
  end
end
