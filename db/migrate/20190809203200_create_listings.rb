class CreateListings < ActiveRecord::Migration[6.0]
  def change
    create_table :listings do |t|
      t.string :address
      t.string :formatted_address
      t.string :code
      t.string :retrieved_at
      t.datetime :added_on


      t.timestamps
    end
  end
end
