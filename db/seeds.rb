# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
[
  [ "The Pragmatic Programmer", "Hunt & Thomas" ],
  [ "Designing Data-Intensive Applications", "Martin Kleppmann" ],
  [ "The Mythical Man-Month", "Fred Brooks" ],
  [ "Refactoring", "Martin Fowler" ],
  [ "Dune", "Frank Herbert" ]
].each { |title, author| Book.find_or_create_by!(title:, author:) }

Book.find_by(title: "Dune")&.update!(checked_out: true)
Book.find_by(title: "Refactoring")&.update!(checked_out: true)

puts "Seeded #{Book.count} books."
