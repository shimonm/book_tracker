class BooksController < ApplicationController
  before_action :set_book, only: [ :check_out, :check_in ]

  def index
    @books = Book.order(:title)
  end

  # POST /books/:id/check_out
  def check_out
    if @book.check_out
      redirect_to books_path, notice: "#{@book.title} checked out."
    else
      redirect_to books_path, alert: "#{@book.title} is already checked out."
    end
  end

  # POST /books/:id/check_in
  def check_in
    if @book.check_in
      redirect_to books_path, notice: "#{@book.title} returned."
    else
      redirect_to books_path, alert: "#{@book.title} wasn't checked out."
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end
end
