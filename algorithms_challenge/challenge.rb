require 'csv'
require 'pp'

def is_near?(coordinate1, coordinate2)
  (coordinate1[0] - coordinate2[0]).abs <= 1 &&
  (coordinate1[1] - coordinate2[1]).abs <= 1
end

properties = CSV.read("data/properties.csv")
dates_unavailable_raw = CSV.read("data/calendar.csv")
searches = CSV.read("data/searches.csv")

# Change the data to more readable hashes, and convert from strings to nicer types
properties.map! do |property|
  {
    id: property[0].to_i,
    lat: property[1].to_f,
    lng: property[2].to_f,
    price: property[3].to_i
  }
end

dates_unavailable = Array.new(properties.length) { |index| [] }
dates_unavailable_raw.each do |date_info|
  id = date_info[0].to_i
  date_info = {
    id: id,
    date: Date.parse(date_info[1]),
    available?: date_info[2] != "0",
    price: date_info[3].to_i
  }
  # This groups the unavailability dates by property id.
  dates_unavailable[id-1] << date_info
end

searches.map! do |search|
  {
    id: search[0].to_i,
    lat: search[1].to_f,
    lng: search[2].to_f,
    # This date range is really useful for later.
    date_range: (Date.parse(search[3])...Date.parse(search[4]))
  }
end




results = []
searches.each do |search|
  # Remove properties too far away
  matching_properties = properties.select do |property|
    is_near?([property[:lat], property[:lng]], [search[:lat], search[:lng]])
  end

  # Remove properties unavailable during searched days
  matching_properties = matching_properties.select do |property|
    all_must_be_true = dates_unavailable[property[:id]-1].each do |date_info|
      !(search[:date_range] === date_info[:date]) || date_info[:available?]
    end
    all_must_be_true.all?
  end

  # Get total price for each result
  matching_properties.each do |property|
    higher_price_days = dates_unavailable[property[:id]-1].select {|date_info| date_info[:available?] } #---------This line is probably wrong.
    higher_price_total = higher_price_days.inject(0) {|sum, day| sum + day[:price] }
    regular_price_total = (search[:date_range].count - higher_price_days.count)*property[:price]
    property.merge!(total_price: higher_price_total + regular_price_total)
  end

  # Sort by price
  matching_properties.sort! do |property1, property2|
    property1[:total_price] <=> property2[:total_price]
  end

  results << {search: search,
            matches: matching_properties[0...10]
            }

  # results << matching_properties[0...10]
end




# Output;
# search_id rank property_id total_price


pp results

# total = 0
# results.each do |result|
#   total += result.length
# end

# puts total