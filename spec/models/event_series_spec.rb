require 'spec_helper'

describe EventSeries do
  shared_examples 'series' do
    describe 'creating' do
      it { should be_valid }
      it 'should have child events' do
        expect(subject.events.size).to be > 0
      end
      it 'should have child events with the same details' do
        expect(subject.events.first.short_description).to eql subject.description
      end
    end
    describe 'updating' do
      it 'does not create new events' do
        expect{
          subject.update(description: 'A new description')
        }.not_to change{subject.events.count}
      end
      it 'should update the child events' do
        subject.update(description: 'A new description')
        expect(subject.coming_events.first.short_description).to eql 'A new description'
      end
    end
  end

    describe 'weekly series' do
      subject { FactoryGirl.create(:weekly_series) }
      it_behaves_like 'series'
      it 'should create events with a week between them' do
        first_time = subject.events.first.start_time
        second_time = subject.events.second.start_time
        expect(first_time + 1.week).to eql second_time
      end
    end

    describe 'biweekly series (even weeks)' do
      subject { FactoryGirl.create(:biweekly_series_even) }
      it_behaves_like 'series'
      it 'should create events with two weeks between them in even weeks' do
        first_time = subject.events.first.start_time
        second_time = subject.events.second.start_time
        expect(first_time + 2.week).to eql second_time
        expect(first_time.to_datetime.cweek % 2).to eql 0
        expect(second_time.to_datetime.cweek % 2).to eql 0
      end
    end

    describe 'biweekly series (odd weeks)' do
      subject { FactoryGirl.create(:biweekly_series_odd) }
      it_behaves_like 'series'
      it 'should create events with two weeks between them in odd weeks' do
        first_time = subject.events.first.start_time
        second_time = subject.events.second.start_time
        expect(first_time + 2.week).to eql second_time
        expect(first_time.to_datetime.cweek % 2).to eql 1
        expect(second_time.to_datetime.cweek % 2).to eql 1
      end
    end

    describe 'updating a first in month series' do
      subject{ FactoryGirl.create(:first_in_month) }
      it_behaves_like 'series'
    end
    describe 'updating a second in month series' do
      subject{ FactoryGirl.create(:second_in_month) }
      it_behaves_like 'series'
    end
  describe 'updating a third in month series' do
    subject{ FactoryGirl.create(:third_in_month) }
    it_behaves_like 'series'
  end
  describe 'updating a last in month series' do
    subject{ FactoryGirl.create(:last_in_month) }
    it_behaves_like 'series'
  end

  describe '#active_weekly' do
    subject { EventSeries.active_weekly }
    context 'a normal series' do
      it 'includes the active series' do
        FactoryGirl.create(:weekly_series, start_date: DateTime.now - 1.day)
        expect(subject.size).to eql 1
      end
    end
    context 'an unpublished series' do
      it 'is empty' do
        FactoryGirl.create(:weekly_series, published: false)
        expect(subject.size).to eql 0
      end
    end
  end
  describe 'repeating_by_day' do
    subject { EventSeries.repeating_by_day }
    it { should be_a Hash }
    it 'should not have empty values' do
      expect(subject.values).not_to include []
    end

    let(:tomorrow) { (DateTime.now + 1.day).strftime '%A' }
    let(:two_days_from_now ) { (DateTime.now + 2.day).strftime '%A' }
    let(:start_date) { DateTime.now }
    let(:rule) { tomorrow }
    before do
      FactoryGirl.create(:weekly_series, days: rule, start_date: start_date)
    end
    context 'when there is a weekly series starting tomorrow' do
      it 'should have an event today' do
        expect(subject[tomorrow]).to be_an Array
        expect(subject[tomorrow].first).to be_an Event
      end
    end
    context 'when there is a weekly series starting next week' do
      let(:start_date) { (DateTime.now + 1.day) + 1.week }
      it 'should not include events not starting within the current week' do
        expect(subject.keys).not_to include tomorrow
      end
    end
    context 'when there is a series running both tomorrow and the next day' do
      let(:rule) { "#{tomorrow},#{two_days_from_now}" }
      it 'should place tomorrow before the next day' do
        expect(subject.keys.index(tomorrow)).to be < subject.keys.index(two_days_from_now)
      end
    end
  end

  describe 'expiring scopes' do
    let(:expiring_series) { FactoryGirl.create(:expiring_series) }
    let(:expired_series) { FactoryGirl.create(:expired_series) }
    let(:expiring_series_already_warned) { FactoryGirl.create(:expiring_series_expiring_warning_sent) }
    let(:expired_series_already_warned) { FactoryGirl.create(:expired_series_expired_warning_sent) }

    describe 'expiring' do
      subject { EventSeries.expiring }
      it { should include expiring_series }
      it { should_not include expired_series }
    end
    describe 'expired' do
      subject { EventSeries.expired }
      it { should include expired_series }
      it { should_not include expiring_series }
    end
    describe 'expiring.expiring_warning_not_sent' do
      subject { EventSeries.expiring.expiring_warning_not_sent }
      it { should include expiring_series }
      it { should_not include expired_series }
      it { should_not include expiring_series_already_warned }
    end
    describe 'expired.expiry_warning_not_sent' do
      subject { EventSeries.expired.expired_warning_not_sent }
      it { should include expired_series }
      it { should_not include expiring_series }
      it { should_not include expired_series_already_warned }
    end
  end
end
