require 'delegate'
require_relative 'directions'
require_relative 'turn_action'

class Warrior < SimpleDelegator
  HEALTH_LOW_LEVEL = 4

  def self.current= original_warrior
    @current = new(original_warrior)
  end

  def self.current
    @current
  end

  def gather_environment_information
    important_spaces = listen
    TurnAction.get(:neutralize_enemy).enemy_list = important_spaces.select{|space|is_enemy? space}
    TurnAction.get(:handle_captive).captive_list = important_spaces.select{|space|space.captive?}
    TurnAction.get(:handle_bomb).bomb = important_spaces.select{|space|space.ticking?}
  end

  def defuse_bomb
    TurnAction.get(:handle_bomb).perform
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

  def enemies_around_me(include_captives = true)
    if include_captives
      Directions::NAMES.select{|direction| is_enemy?(feel direction)}
    else
      Directions::NAMES.select{|direction| feel(direction).enemy?}
    end
  end

  def bombs_around_me
    Directions::NAMES.select{|direction| feel(direction).ticking?}
  end

  def is_enemy? space
    space.enemy? or space.character.downcase == 's'
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
    include_captives = false
    enemies_around_me(include_captives).length > 1
  end

  def attack! direction
    puts "Attack!!"
    super direction
  end
end
