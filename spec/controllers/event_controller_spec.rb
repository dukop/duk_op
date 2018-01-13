require 'spec_helper'

describe EventsController do

  describe 'GET#show' do
    let(:event) { FactoryGirl.create(:event) }

    context 'a normal event' do
      render_views
      before do
        get :show, params: { id: event }
      end

      it 'should return the event itself' do
        expect(assigns(:event)).to eql event
      end

      it 'assigns an event presenter' do
        expect(assigns(:event_presenter).object).to eql event
      end

      it 'includes the fb tags' do
        expect(response.body).to include 'og:url'
        expect(response.body).to include 'og:title'
        expect(response.body).to include 'og:description'
      end
    end
    context 'when there are comments' do

      it 'should return all the events comments' do
        c = FactoryGirl.create(:comment, event: event)
        get :show, params: { id: event }
        expect(assigns(:event).comments.first).to eql c
      end
    end
  end

  describe 'GET#debug' do
    let(:event) { FactoryGirl.create(:event) }
    it 'should load a page' do
      get :debug, params: { id: event }
      expect(response.status).to eql 200
    end
  end

end
