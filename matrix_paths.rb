# This program takes several separate lines of input.
# The first is the dimentions of a matrix.
# The next several are the matrix itself.
# The third is a number representing how many coordinates will follow.
# The forth is the list of coordinates in that matrix.
# The program calculates the "path" through the matrix, from the coordinate to the bottom right, that has the least sum.

# Read in the data and format it.
m, n = gets.chomp.split
m, n = m.to_i, n.to_i

intersections = []

m.times do |time|
  row = gets.chomp.split
  row.map!(&:to_i)
  intersections << row
end

number_employees = gets.chomp.to_i
coordinates = []

number_employees.times do |employee|
  coordinates << gets.chomp.split.map(&:to_i)
end


coordinates.each do |coordinate|
  # We generate all possible paths by starting with the end point, and replacing each 'partial' path with
  # the possible paths that continue it. This process stops when the paths connect to the origin.
  paths = []
  partial_paths = [{coor: [m-1, n-1], val: intersections[m-1][n-1]}]
  while !partial_paths.empty?
    new_partial_paths = []
    partial_paths.each do |partial_path|
      partial_coor = partial_path[:coor]
      if partial_coor[0] > coordinate[0]
        new_value = partial_path[:val] + intersections[partial_coor[0]-1][partial_coor[1]]
        new_partial_paths << {coor: [partial_coor[0]-1, partial_coor[1]], val: new_value}
      end
      if partial_coor[1] > coordinate[1]
        new_value = partial_path[:val] + intersections[partial_coor[0]][partial_coor[1]-1]
        new_partial_paths << {coor: [partial_coor[0], partial_coor[1]-1], val: new_value}
      end
      if partial_coor == coordinate
        paths << partial_path[:val]
      end
    end

    partial_paths = new_partial_paths
  end

  puts paths.min
end
