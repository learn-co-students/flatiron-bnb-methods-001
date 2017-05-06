class Listing < ActiveRecord::Base
  belongs_to :neighborhood, required: true
  belongs_to :host, :class_name => "User"
  has_many :reservations
  has_many :reviews, :through => :reservations
  has_many :guests, :class_name => "User", :through => :reservations
  validates :address, presence: true
  validates :listing_type, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :price, presence: true
  after_save :set_host
  before_destroy :remove_host_check

  def self.avail(start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date

    unavail_listings = self.joins(:reservations).where("
      ((reservations.checkin BETWEEN ? AND ?) OR
      (reservations.checkout BETWEEN ? AND ?)) OR
      (reservations.checkin <= ? AND reservations.checkout >= ?)", start_date, end_date, start_date, end_date, start_date, end_date)
    avail_listings = Listing.all.to_a
    avail_listings.delete_if {|listing| unavail_listings.include?(listing)}
    avail_listings
  end

  def set_host
    self.host.host = true
    self.host.save
  end

  def remove_host_check
    if self.host.listings.count == 1
      self.host.host = false
      self.host.save
    end
  end

  def average_review_rating
    all_ratings = self.reviews.pluck(:rating)
    all_ratings.sum.to_f / all_ratings.size.to_f
  end
  
end
