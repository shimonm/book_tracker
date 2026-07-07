class Book < ApplicationRecord
  validates :title, presence: true
  validates :author, presence: true

  scope :available, -> { where(checked_out: false) }

  # Since requirement 4 says that "a book that's already checked out cannot
  # be checked out until returned", there can be a race condition here.
  # Just checking `if checked_out?` check in Ruby with check-then-set
  # can cause 2 simultaneous requests to be false and both "succeed."
  #
  # This is an atomic compare-and-swap instead: the WHERE clause is the
  # guard, it's a single SQL statement, and the database picks exactly one
  # winner. Row count == 1 means we won; 0 means someone beat us to it.
  def check_out
    self.class.where(id: id, checked_out: false)
        .update_all(checked_out: true, updated_at: Time.current) == 1
  end

  def check_in
    self.class.where(id: id, checked_out: true)
        .update_all(checked_out: false, updated_at: Time.current) == 1
  end
end
