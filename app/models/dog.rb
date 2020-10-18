# == Schema Information
#
# Table name: dogs
#
#  id            :integer          not null, primary key
#  adoption_date :datetime
#  birthday      :datetime
#  description   :text
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#
# Indexes
#
#  index_dogs_on_user_id  (user_id)
#
class Dog < ApplicationRecord
  has_many_attached :images
  belongs_to :user
  has_many :likes
end
