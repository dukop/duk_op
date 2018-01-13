require 'spec_helper'

describe LocationsController do

  describe 'GET#index' do
    it 'creates an array of locations' do
      location = FactoryGirl.create(:other_location)
      get :index
      expect(assigns(:locations)).to include(location)
    end
  end

  describe 'GET#show' do
    before do
      @location = FactoryGirl.create(:other_location)
      @event = FactoryGirl.build(:event, start_time: DateTime.now, end_time: DateTime.now + 1.day)
      @event.save(validate: false)
      @location.events << @event
    end
    it 'assigns the correct location' do
      get :show, params: { id: @location }
      expect(assigns(:location)).to eq @location
    end
    it 'includes events in a calendar' do
      get :show, params: { id: @location }
      expect(assigns(:calendar)).to be_a Calendar
      expect(assigns(:calendar).events).to include @event
    end
  end

  describe 'show RSS' do
    render_views
    before do
      @location = FactoryGirl.create(:other_location)
      @location.events << FactoryGirl.create(:event)
    end
    it 'renders correct xml' do
      get :show, params: { id: @location, format: 'rss' }
      expect {
        Nokogiri::XML(response.body) { |config| config.strict }
      }.not_to raise_error
    end
  end

  describe 'POST#create' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it 'should create a location' do
      expect {
        post :create, params: { location: FactoryGirl.attributes_for(:location) }
      }.to change(Location, :count).by(1)
    end
  end

  describe 'PUT#update' do
    before :each do
      @location = FactoryGirl.create(:location)
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    it 'should assign the correct location' do
      put :update, params: { id: @location, location: FactoryGirl.attributes_for(:location) }
      expect(assigns(:location).id).to eq @location.id
    end

    it 'should update the location' do
      l_mod = FactoryGirl.attributes_for(:location, description: 'A new description')
      put :update, params: { id: @location, location: l_mod }
      @location.reload
      expect(@location.description).to eq('A new description')
    end
  end

  describe 'DELETE#destroy' do
    before :each do
      @location = FactoryGirl.create(:location)
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it 'deletes the location' do
      expect {
        delete :destroy, params: { id: @location }
      }.to change(Location, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, params: { id: @location }
      expect(response).to redirect_to locations_url
    end
  end
end

