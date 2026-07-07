# Book Tracker

A small Rails app that tracks books and whether they are checked out.

**Stack:** Rails, SQLite, RSpec + Capybara.

## Run it

    bundle install
    bin/rails db:prepare
    bin/rails s
    bundle exec rspec

Then open `http://localhost:3000`.

## Scope

The app can:

- list all books
- show whether each book is available or checked out
- check out an available book
- return a checked-out book
- prevent a book that is already checked out from being checked out again

Each `Book` row is one physical copy of a book. There are no borrowers, due dates, users, reminders, or multiple-copy inventory because those were outside the requested scope, but those are the natural next steps for turning this into a fuller product workflow.

## Main Design Decision

The requirement is that "a book that's already checked out cannot be checked out until returned."
The simple version would be a Ruby-level check like:

    return false if checked_out?
    update!(checked_out: true)

That works in a single-user demo, but it is a check-then-set pattern. If two requests load the same available book at the same time, both can see `checked_out: false`.

Therefore, checkout is implemented as a guarded database update instead:

    Book.where(id: id, checked_out: false)
        .update_all(checked_out: true, updated_at: Time.current) == 1

That keeps the state transition atomic: only one request can successfully move the book from available to checked out. The return flow uses the same pattern in reverse.

The logic is kept in the model so the controller stays thin and the state rule lives close to the data it protects.

## Tests

The tests cover:

- model validations
- checking out an available book
- refusing to check out a book that is already checked out
- returning a checked-out book
- the request flow through the controller
- the basic UI flow through Capybara
- two stale copies of the same book record to simulate the double-checkout case without needing threads or timing-sensitive test code.

## How This Evolves

For this exercise, a `checked_out` boolean is enough.

In a real product, I would probably move toward a `Checkout` model with fields like:

- `book_id`
- `borrower_id` or borrower details
- `checked_out_at`
- `due_on`
- `returned_at`

That gives the system history, due dates, reminders, borrower context, and auditability. In a healthcare environment, I would generally prefer explicit state history over overwriting state when the workflow matters.

If the library had multiple physical copies of the same title, I would also separate the concept of a book title from a specific inventory copy.

## Production Considerations

For the exercise, I kept the implementation intentionally small. In a real customer environment, the next layer of questions I would ask are:

- How many books and users are we supporting?
- Is checkout volume low and internal, or are there peak periods where concurrency matters?
- Who can add, edit, remove, or troubleshoot books?
- Do we need an audit trail for every checkout and return?
- Do customers need reminders, due dates, overdue notices, or reporting?
- Which parts should be configurable per customer, and which parts should become core product behavior?

The implementation would change depending on those answers. For example, a larger catalog might need pagination, search, and indexes. A higher-concurrency environment might need stronger locking or database constraints. A customer-specific reminder workflow might start as configuration or a small extension, but if several customers need it, I would feed that back as a product opportunity rather than rebuilding it repeatedly.

## My process

- understand the prompt and define the smallest useful scope
- use AI as a tutor and reviewer while getting comfortable with the Rails shape of the app
- build the Rails model, routes, controller, view, and tests
- verify the checkout and return flows manually
- add tests around the important state transition
- think through how the solution would evolve in a real customer environment

The main thing I focused on was not just making the app work, but being able to explain the tradeoffs clearly: what belongs in the model, what belongs in the controller, what is intentionally out of scope, and what would change in production.