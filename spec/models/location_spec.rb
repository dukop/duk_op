require 'spec_helper'

describe Location do

  before(:each) do
    @location = FactoryGirl.attributes_for(:location)
  end

  it 'should save a valid location' do
    l = Location.new(@location)
    expect(l.valid?).to be true
  end

  it 'should refuse to save without a name' do
    @location.delete(:name)
    l = Location.new(@location)
    expect(l.valid?).to be false
  end

  describe 'display name' do
    it 'should eql name when this is present' do
      l = Location.new(@location.merge(name: 'Fancy Place'))
      expect(l.display_name).to eql 'Fancy Place'
    end

    it 'should be the street address when no name is present' do
      l = Location.new(@location.merge(name: '', street_address: 'Nørrebrogade 22'))
      expect(l.display_name).to eql 'Nørrebrogade 22'
    end
  end

  describe 'sort' do
    it 'should order by display name' do
      b = FactoryGirl.create(:other_location, name: 'B')
      a = FactoryGirl.create(:location, name: 'a')
      locs = Location.all.sort
      expect(locs.first).to eql a
    end
  end
end