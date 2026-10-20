# frozen_string_literal: true

RSpec.describe "Require event in category" do
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category)
  fab!(:other_category, :category)

  before do
    SiteSetting.require_event_enabled = true
    SiteSetting.require_event_categories = category.id.to_s
  end

  def create(raw, cat)
    PostCreator.new(user, title: "Inventura test tema naslov", raw: raw, category: cat.id).create
  end

  it "rejects a new topic without an event in a configured category" do
    post = create("Bez događaja ovdje, samo tekst.", category)
    expect(post).to be_nil.or(satisfy { |p| !p.persisted? })
  end

  it "allows a new topic with an event" do
    post = create(%([event start="2030-01-01" allDay="true" end="2030-01-01"]\n[/event]\n\nTekst teme), category)
    expect(post.persisted?).to eq(true)
  end

  it "ignores other categories" do
    post = create("Bez događaja ovdje, samo tekst.", other_category)
    expect(post.persisted?).to eq(true)
  end
end
