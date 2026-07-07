require "rails_helper"

RSpec.describe "Books", type: :request do
  describe "GET /" do
    it "lists books with availability" do
      Book.create!(title: "Dune", author: "Frank Herbert")
      get root_path
      expect(response.body).to include("Dune", "Available")
    end
  end

  describe "POST /books/:id/check_out" do
    it "checks out an available book" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      post check_out_book_path(book)
      expect(book.reload).to be_checked_out
    end

    it "rejects a double checkout with a friendly message" do
      book = Book.create!(title: "Dune", author: "Frank Herbert", checked_out: true)
      post check_out_book_path(book)
      expect(book.reload).to be_checked_out
      follow_redirect!
      expect(response.body).to include("already checked out")
    end
  end

  describe "POST /books/:id/check_in" do
    it "returns a checked-out book" do
      book = Book.create!(title: "Dune", author: "Frank Herbert", checked_out: true)
      post check_in_book_path(book)
      expect(book.reload).not_to be_checked_out
    end
  end
end
