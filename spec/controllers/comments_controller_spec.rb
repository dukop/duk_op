require 'spec_helper'

describe CommentsController do

  describe 'POST#Create' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @event = FactoryGirl.create(:event)
    end

    it 'should create a comment object when sent valid parameters' do
        expect {
          post :create, params: { comment: FactoryGirl.attributes_for(:comment, event_id: @event.id) }
        }.to change(Comment, :count).by(1)
    end

    it 'should not create a comment object without an associated event' do
      expect {
        post :create, params: { comment: FactoryGirl.attributes_for(:comment) }
      }.to_not change(Comment, :count)
    end

    it 'should not create a comment object without a logged in user' do
      sign_out @user
      expect {
        post :create, params: { comment: FactoryGirl.attributes_for(:comment, event_id: @event.id) }
      }.to_not change(Comment, :count)
    end

    it 'should not allow anonymous users to leave comments' do
      sign_out @user
      sign_in FactoryGirl.create(:anonymous_user)

      expect {
        post :create, params: { comment: FactoryGirl.attributes_for(:comment, event_id: @event.id) }
      }.to_not change(Comment, :count)
    end
  end

  describe 'PATCH#Update' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @event = FactoryGirl.create(:event)
      @comment = FactoryGirl.create(:comment, event_id: @event.id, user_id: @user.id)
      @modified_comment = FactoryGirl.attributes_for(:comment,
        content: 'Actually, I reconsider...', comment_id: @comment.id)
    end

    it 'should allow a user to update their comment' do
      patch :update, params: { id: @comment, comment: @modified_comment }
      @comment.reload
      expect(@comment.content).to eql 'Actually, I reconsider...'
    end

    it "should not allow a user to update another user's comment" do
      sign_out @user
      sign_in FactoryGirl.create(:different_user)
      patch :update, params: { id: @comment, comment: @modified_comment }
      @comment.reload
      expect(@comment.content).not_to eql 'Actually, I reconsider...'
    end

    it "should allow an admin user to update another user's comment" do
      sign_out @user
      sign_in FactoryGirl.create(:admin_user)
      patch :update, params: { id: @comment, comment: @modified_comment }
      @comment.reload
      expect(@comment.content).to eql 'Actually, I reconsider...'
    end

  end

  describe 'GET#Edit' do

    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @event = FactoryGirl.create(:event)
      @comment = FactoryGirl.create(:comment, event_id: @event.id, user_id: @user.id)
    end

    it 'should return a comment object' do
      get :edit, params: { id: @comment }
      expect(assigns(:comment)).to eql @comment
    end

    it 'should not respond to an unauthorized user' do
      sign_out @user
      sign_in FactoryGirl.create(:different_user)
      get :edit, params: { id: @comment }
      expect(response).to redirect_to root_path
    end

    it "should allow an admin user to edit another user's comment" do
      sign_out @user
      sign_in FactoryGirl.create(:admin_user)
      get :edit, params: { id: @comment }
      expect(assigns(:comment)).to eql @comment
    end
  end
end
