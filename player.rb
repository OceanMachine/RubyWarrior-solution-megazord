require 'pry'
require_relative 'warrior'

class Player
  def play_turn(warrior)
    Warrior.current= warrior
    Warrior.current.gather_environment_information

    if TurnAction.get(:neutralize_enemy).any_enemies?
      Warrior.current.neutralize_enemy
    else
      Warrior.current.handle_captive
    end

  end
end