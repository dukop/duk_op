require 'spec_helper'

describe LocationsController do

  describe 'GET#index' do
    it 'creates an array of locations' do
      location = FactoryGirl.create(:location)
      get :index
      assigns(:locations).should eq([location])
    end
  end

  describe 'GET#show' do
    it 'assigns the correct location' do
      l = FactoryGirl.create(:location)
      get :show, id: l
      assigns(:location).should eq l
    end
  end

  describe 'POST#create' do
    it 'should create a location' do
      expect {
        post :create, location: FactoryGirl.attributes_for(:location)
      }.to change(Location, :count).by(1)
    end

    it 'redirects to the location path' do
      post :create, location: FactoryGirl.attributes_for(:location)
      assert_match /http:\/\/test.host\/location/, @response.redirect_url
    end
  end

  describe 'PUT#update' do
    before :each do
      @location = FactoryGirl.create(:location)
    end
    it 'should assign the correct location' do
      put :update, id: @location, location: FactoryGirl.attributes_for(:location)
      assigns(:location).should eq @location
    end

    it 'should update the location' do
      l_mod = FactoryGirl.attributes_for(:location, description: 'A new description')
      put :update, id: @location, location: l_mod
      @location.reload
      @location.description.should eq('A new description')
    end
  end

  describe 'DELETE#destroy' do
    before :each do
      @location = FactoryGirl.create(:location)
    end

    it 'deletes the location' do
      expect {
        delete :destroy, id: @location
      }.to change(Location, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, id: @location
      response.should redirect_to locations_url
    end
  end
end
