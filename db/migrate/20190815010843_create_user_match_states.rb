class CreateUserMatchStates < ActiveRecord::Migration[6.0]
  def change
    create_table :user_match_states do |t|
      t.belongs_to :match, index: true
      t.belongs_to :user, index: true
      t.timestamps
    end
  end
end
