module Directions
  NAMES = %i(forward backward left right)
  OPOSITE_DIRECTIONS = {:left => :right,:right => :left,:forward => :backward, :backward => :forward}

  def self.first_safe_direction
    NAMES.detect do |direction|
      is_safe_direction?(direction)
    end
  end

  def self.is_safe_direction?(direction)
    Warrior.current.feel(direction).empty? and not Warrior.current.feel(direction).stairs?
  end
end