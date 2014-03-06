require 'pry'
require 'delegate'
class Player
  def play_turn(warrior)
    Warrior.current= warrior

    if Warrior.current.enemies_around_me.empty?
      Warrior.current.handle_captive
    else
      Warrior.current.neutralize_enemy
    end

  end
end

class Warrior < SimpleDelegator
  HEALTH_LOW_LEVEL = 4
  @@dangerous_direction = nil

  def self.current= original_warrior
    @current = new(original_warrior)
  end

  def self.current
    @current
  end

  def smart_heal
    TurnAction.get(:smart_heal).perform
  end

  def neutralize_enemy
    TurnAction.get(:neutralize_enemy).perform
  end

  def handle_captive
    TurnAction.get(:handle_captive).perform
  end

  def walk_to_stairs
    walk! direction_of_stairs
  end

  def healthy?
    health > Warrior::HEALTH_LOW_LEVEL
  end

  def enemies_around_me
    Directions::NAMES.select{|direction|feel(direction).enemy?}
  end

  def captives_around_me
    Directions::NAMES.select do |direction|
      space = feel(direction)
      space.captive? and space.character.downcase != 's'
    end
  end

  def im_in_safe_place?
    enemies_around_me.empty?
  end

  def escape
    @@dangerous_direction = Directions::OPOSITE_DIRECTIONS[direction_of_stairs]
    walk! Directions::first_safe_direction
  end

  def surrounded?
    enemies_around_me.length > 1
  end

  def attack! direction
    puts "Attack!!"
    super direction
  end
end

class TurnAction
  def self.get name
    if name == :smart_heal
      SmartHeal.new
    elsif name == :neutralize_enemy
      NeutralizeEnemy.new
    elsif name == :handle_captive
      HandleCaptive.new
    end
  end
end

class SmartHeal < TurnAction
  def perform
    if Warrior.current.im_in_safe_place?
      Warrior.current.rest!
    else
      Warrior.current.escape
    end
  end
end

class NeutralizeEnemy < TurnAction
  def perform
    if Warrior.current.healthy?
      if Warrior.current.surrounded?
        bind_enemy
      else
        hit_first_closest_enemy
      end
    else
      Warrior.current.smart_heal
    end
  end
  def bind_enemy
    Warrior.current.bind!(Warrior.current.enemies_around_me.first)
  end

  def hit_first_closest_enemy
    Warrior.current.attack! Warrior.current.enemies_around_me.first
  end
end

class HandleCaptive < TurnAction
  def perform
    if Warrior.current.captives_around_me.empty?
      Warrior.current.walk_to_stairs
    else
      Warrior.current.rescue!(Warrior.current.captives_around_me.first)
    end
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
