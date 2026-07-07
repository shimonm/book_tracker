require "rails_helper"

RSpec.describe "Managing books", type: :system do
  before { driven_by(:rack_test) }

  it "checks a book out and back in from the list" do
    Book.create!(title: "Dune", author: "Frank Herbert")

    visit root_path
    expect(page).to have_content("Available")

    click_button "Check out"
    expect(page).to have_content("Checked out")

    click_button "Return"
    expect(page).to have_content("Available")
  end
end
