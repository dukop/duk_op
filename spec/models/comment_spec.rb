require 'spec_helper'

describe 'Comment' do

  it 'should create a comment when given valid params' do
    u = FactoryGirl.create(:user)
    e = FactoryGirl.create(:event)
    comment = Comment.new(content: 'Sample comment', hidden: false, user: u, event: e)
    expect(comment.save).to be true
    expect(comment.content).to eql 'Sample comment'
  end

  it 'should not create a comment without an associated event' do
    u = FactoryGirl.create(:user)
    comment = Comment.new(content: 'Sample comment', hidden: false, user: u)
    expect(comment.save).not_to be true
  end
end