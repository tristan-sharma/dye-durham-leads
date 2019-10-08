class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.string :address
      t.string :code
      t.string :dd_key
      t.date :matched_on
      t.integer :week_matched
      t.boolean :viewed
      t.integer :year_matched

      t.timestamps
    end
  end
end
