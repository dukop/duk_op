require 'spec_helper'

describe EventPresenter, type: :view do
  let(:request_context) { view }
  let(:event) { FactoryGirl.create(:event) }
  subject { EventPresenter.new(event, view) }

  it 'can be initialized with an event object and the view context' do
    expect(EventPresenter.new(event, request_context)).to be_an EventPresenter
  end

  describe 'Facebook metadata' do
    it 'returns a canonical url' do
      expect(subject.fb_url).to include(event.id.to_s)
      expect(subject.fb_url).to include('og:url')
    end

    it 'returns a type of article' do
      expect(subject.fb_type).to include 'og:type'
      expect(subject.fb_type).to include 'article'
    end
    it 'returns a title' do
      expect(subject.fb_title).to include 'og:title'
      expect(subject.fb_title).to include event.title
    end
    it 'includes the date in the title' do
      expect(subject.fb_title).to include Date.today.strftime("%e")
    end
    it 'includes the location in the title' do
      expect(subject.fb_title).to include 'Location'
    end
    describe 'description' do
      let(:event) do
        content = (1..5).collect {|x| " Sentence #{x}."}.join
        e = FactoryGirl.create(:event)
        e.short_description = content
        e
      end
      it 'returns a description' do
        expect(subject.fb_description).to include 'og:description'
      end

      it 'limits the description to four sentences' do
        expect(subject.fb_description.split('.').size).to be <= 4
      end
    end

    it 'returns a site name' do
      expect(subject.fb_site_name).to include 'og:site_name'
      expect(subject.fb_site_name).to include I18n.t(:app_name)
    end

    it 'returns a locale' do
      expect(subject.fb_locale).to include 'og:locale'
      expect(subject.fb_locale).to include 'da_DK'
    end
    describe 'images' do
      let(:event) do
        e = FactoryGirl.create(:event)
        picture = double('book', url: 'samplepicture.jpg')
        allow(e).to receive(:picture).and_return(picture)
        e
      end
      it 'returns a link to an image' do
        expect(subject.fb_image).to include 'og:image'
        expect(subject.fb_image).to include 'samplepicture.jpg'
      end

      it 'returns the height of the image'
      it 'returns the width of the image'
    end
  end
end
