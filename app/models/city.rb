class City < ActiveRecord::Base
  has_many :neighborhoods
  has_many :listings, :through => :neighborhoods

  def city_openings(start_date, end_date)
    all_listings = Listing.avail(start_date, end_date)
    all_city_neighborhoods = self.neighborhoods.pluck(:id)
    all_listings.keep_if {|listing| all_city_neighborhoods.include?(listing.neighborhood_id)}
  end

  def self.highest_ratio_res_to_listings
    highest_ratio = 0.00

    City.all.each do |city|
      current_ratio = city.all_reservations.count / city.listings.count
      if current_ratio > highest_ratio
        @@result_city = city
        highest_ratio = current_ratio
      end
    end
    @@result_city
  end

  def all_reservations
    all_listings = self.listings
    all_listing_ids = all_listings.pluck(:id)
    Reservation.where("listing_id IN (?)", all_listing_ids)
  end

  def self.most_res
    highest_reservations = 0
   City.all.each do |city|
    if city.all_reservations.count > highest_reservations
      highest_reservations = city.all_reservations.count
      @@result_city = city
    end
   end

    @@result_city
  end

end

