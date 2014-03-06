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
    Warrior.current.walk!(Warrior.current.direction_of self.class.enemy_list.first)
  end

  def bind_enemy
    Warrior.current.bind!(Warrior.current.enemies_around_me.first)
  end

  def hit_first_closest_enemy
    Warrior.current.attack! Warrior.current.enemies_around_me.first
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
