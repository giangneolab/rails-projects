# == Schema Information
#
# Table name: restaurants
#
#  id          :integer          not null, primary key
#  name        :string
#  about       :text
#  image       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer
#
# Indexes
#
#  index_restaurants_on_location_id  (location_id)
#

class Restaurant < ActiveRecord::Base
  after_create :send_new_restaurant_notifier

  has_many :cat_res
  has_many :categories, through: :cat_res

  has_many :favorites
  has_many :comments
  has_many :checkins

  belongs_to :location

  validates :name, uniqueness: { scope: :location_id,
                                 message: "A location should not have two duplicated restaurants" }

  def send_new_restaurant_notifier
    Notifier.new_restaurant_notifier(User.first, self).deliver_now
  end
end
