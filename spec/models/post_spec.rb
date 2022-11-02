require 'rails_helper'
# User signup rspec
RSpec.describe Post, type: :model do
  subject {Post.new(content: "hi", user_id: 23, created_at: "2022-11-02 11:49:05.837836", updated_at: "2022-11-02 11:49:05.837836", content_html: "<p>hi</p>")}
  before { subject.save }

  it "user_id should not be absent" do # user_id blank
    subject.user_id = nil
    expect(subject).to_not be_valid
  end

  it "user_id should be present" do # user_id valid
    subject.user_id = 23
    expect(subject).to be_valid
  end

  it "user_id should not be invalid" do # invalid user_id
    subject.user_id = "heyhihey"
    expect(subject).to_not be_valid
  end

  it "content should not be absent" do # content blank
    subject.content = nil
    expect(subject).to_not be_valid
  end

  it "content should be present" do # content valid
    subject.content = "hi"
    expect(subject).to be_valid
  end

  it "content_html should not be absent" do # content_html blank
    subject.content_html = nil
    expect(subject).to_not be_valid
  end

  it "content_html should be present" do # content_html valid
    subject.content_html = "<p>hi</p>"
    expect(subject).to be_valid
  end

end