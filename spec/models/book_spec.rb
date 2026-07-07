require "rails_helper"

RSpec.describe Book, type: :model do
  describe "validations" do
    it "requires a title and an author" do
      expect(Book.new(title: "", author: "")).not_to be_valid
      expect(Book.new(title: "Dune", author: "Frank Herbert")).to be_valid
    end
  end

  describe "database constraints" do
    # check_out/check_in write via update_all, which skips validations, so the
    # NOT NULL columns are the real backstop. save!(validate: false) reproduces
    # that bypass and proves the database — not just the model — rejects nulls.
    it "rejects a NULL title at the database level" do
      expect {
        Book.new(author: "Anon").save!(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "rejects a NULL author at the database level" do
      expect {
        Book.new(title: "Untitled").save!(validate: false)
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe "#check_out" do
    it "checks out an available book" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      expect(book.check_out).to be true
      expect(book.reload).to be_checked_out
    end

    it "refuses a book that is already checked out" do
      book = Book.create!(title: "Dune", author: "Frank Herbert", checked_out: true)
      expect(book.check_out).to be false
    end

    it "lets exactly one of two racing checkouts win" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")

      # Two request handlers load the same row at the same moment —
      # both see checked_out: false in memory.
      copy_a = Book.find(book.id)
      copy_b = Book.find(book.id)

      expect(copy_a.check_out).to be true
      expect(copy_b.check_out).to be false   # the guard, not the stale memory, decides
      expect(book.reload).to be_checked_out
    end
  end

  describe "#check_in" do
    it "returns a checked-out book" do
      book = Book.create!(title: "Dune", author: "Frank Herbert", checked_out: true)
      expect(book.check_in).to be true
      expect(book.reload).not_to be_checked_out
    end

    it "refuses a book that is not checked out" do
      book = Book.create!(title: "Dune", author: "Frank Herbert")
      expect(book.check_in).to be false
    end
  end
end
