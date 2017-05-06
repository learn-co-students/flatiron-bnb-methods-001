class Review < ActiveRecord::Base
  belongs_to :reservation
  belongs_to :guest, :class_name => "User"
  validates :rating, presence: true
  validates :description, presence: true
  validates :reservation, presence: true

  validate :reservation_check

  def reservation_check
    if reservation 
      if self.reservation.status != "accepted" || self.reservation.checkout > Date.today
        errors.add(:reservation, "cannot write review")
      end
    end
  end


end
