require 'pry'
class Player
  def play_turn(warrior)
    Warrior.current= warrior
    if Warrior.healthy?
      Warrior.neutralize_enemy
    else
      Warrior.smart_heal
    end

  end
end

class Warrior
  HEALTH_LOW_LEVEL = 4
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

  def self.neutralize_enemy
    TurnAction.get(:neutralize_enemy).perform 
  end

  def self.walk_to_stairs
    current.walk! current.direction_of_stairs
  end

  def self.healthy?
    current.health > Warrior::HEALTH_LOW_LEVEL
  end

  def self.enemies_around_me
    Directions::NAMES.select{|direction|current.feel(direction).enemy?}
  end

  def self.im_in_safe_place?
    enemies_around_me.empty?
  end

  def self.escape
    @@dangerous_direction = Directions::OPOSITE_DIRECTIONS[current.direction_of_stairs]
    current.walk! Directions::first_safe_direction
  end

  def self.surrounded?
    enemies_around_me.length > 1
  end
end

class TurnAction
  def self.get name
    if name == :smart_heal
      SmartHeal.new
    elsif name == :neutralize_enemy
      NeutralizeEnemy.new
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

class NeutralizeEnemy < TurnAction
  def perform
    if Warrior.surrounded?
      bind_enemy
    else
      if Warrior.enemies_around_me.empty?
        Warrior.walk_to_stairs
      else
        hit_first_closest_enemy
      end
    end
  end

  def bind_enemy
    Warrior.current.bind!(Warrior.enemies_around_me.first)
  end

  def hit_first_closest_enemy
    Warrior.current.attack! Warrior.enemies_around_me.first
  end

end

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
