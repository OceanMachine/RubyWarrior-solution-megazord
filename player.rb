require 'pry'
class Player
  def play_turn(warrior)
    Warrior.current= warrior

    if Warrior.healthy?
      if Warrior.enemies_around_me.any?
        Warrior.hit_first_closest_enemy
      else
        Warrior.walk_to_stairs
      end
    else
      Warrior.smart_heal
    end

  end
end

class Warrior
  DIRECTIONS = %i(forward backward left right)
  OPOSITE_DIRECTIONS = {:left => :right,:right => :left,:forward => :backward, :backward => :forward}
  HEALTH_LOW_LEVEL = 7

  @@dangerous_direction = nil

  def self.current= original_warrior
    @current = original_warrior
  end

  def self.current
    @current
  end

  def self.smart_heal
    TurnAction.get(:smart_heal).perform
  end

  def self.walk_to_stairs
    current.walk! current.direction_of_stairs
  end

  def self.healthy?
    current.health > Warrior::HEALTH_LOW_LEVEL
  end

  def self.hit_first_closest_enemy
    current.attack! enemies_around_me.first
  end

  def self.enemies_around_me
    DIRECTIONS.select{|direction|current.feel(direction).enemy?}
  end

  def self.im_in_safe_place?
    enemies_around_me.empty?
  end

  def self.escape
    @@dangerous_direction = OPOSITE_DIRECTIONS[current.direction_of_stairs]
    current.walk! first_safe_direction
  end

  def self.first_safe_direction
    DIRECTIONS.detect do |direction|
      is_safe_direction?(direction)
    end
  end

  def self.is_safe_direction?(direction)
    current.feel(direction).empty? and not current.feel(direction).stairs?
  end

end

class TurnAction
  def self.get name
    if :smart_heal
      SmartHeal.new
    end
  end
end

class SmartHeal < TurnAction
  def perform
    if Warrior.im_in_safe_place?
      Warrior.current.rest!
    else
      Warrior.escape
    end
  end
end
