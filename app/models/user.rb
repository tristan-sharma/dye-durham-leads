class User < ApplicationRecord
  has_many :user_match_states
  has_many :matches, through: :user_match_states
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
