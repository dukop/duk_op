require 'spec_helper'

describe AnalyticsService do
  before { Event.delete_all }
  describe 'group_by' do
    before do
      FactoryGirl.create(:ahoy_event_frontpage)
      FactoryGirl.create(:ahoy_event_frontpage)
      FactoryGirl.create(:ahoy_location_show)
    end
    subject { described_class.group_by(:name) }
    it { should be_a Hash }
    it 'should group by name' do
      expect(subject.values.size).to eql 2
    end
    it 'should be ordered by count' do
      expect(subject.first.first).to eql 'calendar#index'
    end
    it 'returns values as an array' do
      expect(subject.values.first).to be_an Array
    end
    it 'returns the absolute count as the first value' do
      expect(subject.values.first.first).to eql 2
    end
    it 'returns the percentage as the second value' do
      expect(subject.values.first.second.round(0)).to eql 67
    end
    it 'should render percentage values' do
      expect(subject.values.collect(&:last).inject(&:+)).to eql 100.0
    end
  end

  describe 'timeseries' do
    before do
      FactoryGirl.create(:ahoy_event_frontpage, time: DateTime.now - 1.week)
      FactoryGirl.create(:ahoy_event_frontpage)
      FactoryGirl.create(:ahoy_location_show)
    end
    let(:interval) { 'week' }
    let(:field) { 'calendar#index' }
    subject { described_class.time_series(field, interval) }
    it { should be_a Hash }
    it 'should group by date' do
      expect(subject.keys.size).to eql 2
    end
    it 'should only include the relevant events' do
      expect(subject.values).to eql [ 1, 1 ]
    end
    context 'when given an invalid interval' do
      let(:interval) { 'invalid' }
      it { should eql({}) }
    end
    context 'when given a sql injection attempt' do
      let(:field) { "calendar#index'; SELECT * FROM ahoy_events;'"}
      it { should eql({})}
    end
  end

  describe 'event_creation' do
    before do
      FactoryGirl.create(:event, created_at: DateTime.now - 4.weeks)
      FactoryGirl.create(:event, created_at: DateTime.now - 2.weeks)
    end
    let(:interval) { 'week' }
    subject { described_class.events_created(interval) }
    it { should be_a Hash }
    it 'should group by date' do
      expect(subject.keys.size).to eql 2
    end
    it 'should only include the relevant events' do
      expect(subject.values).to eql [1, 1]
    end
    context 'when supplied a start date and end date' do
      let(:start_date) { DateTime.now - 3.weeks }
      let(:end_date) { DateTime.now + 3.weeks }
      subject { described_class.events_created(interval, start_date) }
      it 'should only include events within the scope' do
        expect(subject.keys.size).to eql 1
      end
    end
  end
end
