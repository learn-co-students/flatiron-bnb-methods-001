class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :guest, :class_name => "User"
  has_one :review
  validates :checkin, presence: true
  validates :checkout, presence: true

  validate :validate_id, :avail, :validate_date

  def validate_id
    if self.guest == self.listing.host
      errors.add(:guest_id, "cannot reserve your own listing")
    end
  end

  def avail
    if checkin && checkout
      conflicting_reservation = Reservation.where("
        (
        ((checkin BETWEEN ? AND ?) OR
        (checkout BETWEEN ? AND ?)) OR
        (checkin <= ? AND checkout >= ?)
        )", self.checkin, self.checkout, self.checkin, self.checkout, self.checkin, self.checkout).where("listing_id = ?", self.listing_id).where.not(id: id)
      if conflicting_reservation != []
        errors.add(:checkin, "unavail")
      end
    end
  end

  def validate_date
    if checkin && checkout 
      if self.checkin >= self.checkout
        errors.add(:checkin, "invalid checkin and checkout dates")
      end
    end
  end

  def duration
    self.checkout - self.checkin
  end

  def total_price
    duration * self.listing.price
  end


end
