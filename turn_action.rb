class TurnAction
  def self.get name
    if name == :smart_heal
      SmartHeal
    elsif name == :neutralize_enemy
      NeutralizeEnemy
    elsif name == :handle_captive
      HandleCaptive
    end
  end

  def self.perform
    new.perform
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

  def self.enemy_list= enemy_list
    @enemy_list = enemy_list
  end

  def self.any_enemies?
    not @enemy_list.empty?
  end

  def self.enemy_list
    @enemy_list
  end

  def perform
    if Warrior.current.healthy?
      if Warrior.current.surrounded?
        bind_enemy
      else
        if Warrior.current.enemies_around_me.any?
          hit_first_closest_enemy
        else
          search_for_enemy
        end
      end
    else
      Warrior.current.smart_heal
    end
  end

  private

  def search_for_enemy
    where_to_go = Warrior.current.direction_of self.class.enemy_list.first
    #the direction i must go is the same as the stairs
     where_to_go = first_empty_direction if Directions::NAMES.select{|direction| Warrior.current.feel(direction).stairs?}.first == Warrior.current.direction_of_stairs 
      #choose a random direction that is not a "stair" neither a wall
      Warrior.current.walk!(where_to_go)
  end

  def bind_enemy
    Warrior.current.bind!(Warrior.current.enemies_around_me.first)
  end

  def first_empty_direction
    Directions::NAMES.select do |direction| 
      not Warrior.current.feel(direction).wall? and not Warrior.current.feel(direction).stairs? and not Warrior.current.feel(direction).enemy? and not Warrior.current.feel(direction).captive?
    end.first
  end

  def enemy_bound? space
    space.captive?
  end

  def hit_first_closest_enemy
    if Warrior.current.enemies_around_me(false).any?
      Warrior.current.attack! Warrior.current.enemies_around_me(false).first
    elsif Warrior.current.enemies_around_me.any?
      Warrior.current.attack! Warrior.current.enemies_around_me.first
    end
  end
end

class HandleCaptive < TurnAction

  def self.captive_list= captive_list
    @captive_list = captive_list
  end

  def self.any_captives?
    not @captive_list.empty?
  end

  def self.captive_list
    @captive_list
  end

  def perform
    if self.class.any_captives?
      if Warrior.current.captives_around_me.any?
        rescue_closest_captive
      else
        search_for_captive
      end
    else
      Warrior.current.walk_to_stairs
    end
  end

  private

  def search_for_captive
    Warrior.current.walk!(Warrior.current.direction_of self.class.captive_list.first)
  end
  def rescue_closest_captive
    Warrior.current.rescue!(Warrior.current.captives_around_me.first)
  end
end
