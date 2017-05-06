class Neighborhood < ActiveRecord::Base
  belongs_to :city
  has_many :listings

  def neighborhood_openings(start_date, end_date)
    all_listings = Listing.avail(start_date, end_date)

    all_listings.keep_if {|listing| listing.neighborhood_id == self.id}
  end

  def self.highest_ratio_res_to_listings
    ratios = {}
    Neighborhood.all.each do |neighborhood|
      all_listings = neighborhood.listings
      ids = all_listings.pluck(:id)
      if all_listings.count == 0
        next
      end
      all_reservations = neighborhood.all_reservations(ids)
      ratios[neighborhood] = (all_reservations.count / all_listings.count).to_f
    end

    result_neighborhood = ratios.select {|k,v| v == ratios.values.max}
    result_neighborhood.to_a[0][0]
  end

  def all_reservations(ids)
    Reservation.where("listing_id IN (?)", ids)
  end

  def self.most_res
    reservations = {}
    Neighborhood.all.each do |neighborhood|
      all_listings = neighborhood.listings
      ids = all_listings.pluck(:id)
      if all_listings.count == 0
        next
      end
      all_reservations = neighborhood.all_reservations(ids)
      reservations[neighborhood] = all_reservations.count
    end

    result_neighborhood = reservations.select {|k,v| v == reservations.values.max}
    result_neighborhood.to_a[0][0]

  end

end
