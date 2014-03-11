module Model
  CONDITIONS = [
                  lambda {|number, turn_number| turn_number % number == 0},
                  lambda do |number, turn_number|
                    digits = turn_number.to_s.split('')
                    digits.include?(number.to_s)
                  end,
                  lambda do |number, turn_number|
                    digits = turn_number.to_s.split('')
                    digits.map!(&:to_i)
                    is_adjacent = false
                    digits[0...-1].each_with_index do |digit, index|
                      is_adjacent ||= (digit + digits[index+1] == number)
                    end
                    is_adjacent
                  end
                ]

  class << self

    def nish?(number, turn_number)
      CONDITIONS.inject(false) do |memo, condition|
        memo || condition.call(number, turn_number)
      end
    end

    def fiveish?(turn_number)
      nish?(5, turn_number)
    end

    def sevenish?(turn_number)
      nish?(7, turn_number)
    end

    def bk(turn_number)
      if fiveish?(turn_number) && sevenish?(turn_number)
        "bottles and kegs"
      elsif fiveish?(turn_number)
        "kegs"
      elsif sevenish?(turn_number)
        "bottles"
      else
        turn_number.to_s
      end
    end
  end
end

module View
  def self.greet
    puts "What's your number?"
    gets.chomp
  end

  def self.respond_with(answer)
    puts "Say #{answer}"
  end
end

while true
  input = View.greet
  break if input == "exit"
  number = input.to_i
  answer = Model::bk(number)
  View.respond_with(answer)
end





module Test
  class << self
    def conditions(turn_number)
      digits = turn_number.to_s.split('')
      [
          Model::CONDITIONS[0].call(5, turn_number),
          Model::CONDITIONS[1].call(5, turn_number),
          Model::CONDITIONS[2].call(5, turn_number),
          Model::CONDITIONS[0].call(7, turn_number),
          Model::CONDITIONS[1].call(7, turn_number),
          Model::CONDITIONS[2].call(7, turn_number),
      ]
    end

    def int_to_bool_array(integer)
      [32, 16, 8, 4, 2, 1].map{|power| power & integer == power }
    end

    def test_bk
      (0..(2**6)).each do |number|
        cond_set = int_to_bool_array(number)
        test_num = 1
        while conditions(test_num) != cond_set
          test_num += 1
        end
        p test_num
        p cond_set
        p Model::bk(test_num)
      end
    end
  end
end


# puts Test::test_bk