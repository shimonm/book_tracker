class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.boolean :checked_out, null: false, default: false

      t.timestamps
    end
  end
end
