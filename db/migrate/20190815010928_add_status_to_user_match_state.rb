class AddStatusToUserMatchState < ActiveRecord::Migration[6.0]
  def change
    add_column :user_match_states, :status, :integer, default: 0
  end
end
