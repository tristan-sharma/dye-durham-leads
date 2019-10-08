class AddFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :invite_code, :string
    add_column :users, :name, :string

  end
end
