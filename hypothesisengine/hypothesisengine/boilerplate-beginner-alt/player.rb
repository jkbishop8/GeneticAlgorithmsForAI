class Player
  TACTIC = [:advance, :retreat_and_rest]
  PARAMETER = [:backward, :forward]
  
  # 'knowledge' parameters, for calculating tactic to use
  archer_damage_per_turn = 3
  archer_health = 7
  archer_range = 3
  sludge_damage_per_turn = 3
  sludge_health = 24
  @cleared_behind_me = false
  @turn_around = false
  
  def ClearedBehindMe
    @cleared_behind_me
  end
  
  def TurnAround=(value)
    # allows remote class to queue a pivot command
    @turn_around = value
  end
  
  def Tactic=(value)
    # allows remote class to queue a tactic change
	@tactic = value
  end
  
  def play_turn(warrior)
    # add your code here
	
	# initialize
	if (@health_last_turn == nil)
	   if (warrior.respond_to?("health"))
	      @health_last_turn = warrior.health
	   else
	      @health_last_turn = 10
	   end
	end
    if (warrior.respond_to?("health"))
	  @health = warrior.health
    else
	  @health = 10
    end	
	if (@direction_of_advance == nil)
	   @direction_of_advance = :forward
	   @direction_of_retreat = :backward
	end
	if (@tactic == nil)
	   @tactic = :advance
	end
	
	# tactical classes
#////////////////////////////////
#// All Available Genes
#// -----------------------------
#//
#// ------------------------
#// look conditionals
#// ------------------------
tacticA = LookAndHealth.new(:forward, "Sl", 6)
tacticB = LookAndHealth.new(:backward, "Sl", 6)
tacticC = LookAndHealth.new(:forward, "Th", 7)
tacticD = LookAndHealth.new(:backward, "Th", 7)
tacticE = LookAndHealth.new(:forward, "Ar", 6)
tacticF = LookAndHealth.new(:backward, "Ar", 6)
tacticG = LookAndHealth.new(:forward, "Wi", 6)
tacticH = LookAndHealth.new(:backward, "Wi", 6)
tacticI = Look.new(:forward, "Sl")
tacticJ = Look.new(:backward, "Sl")
tacticK = Look.new(:forward, "Th")
tacticL = Look.new(:backward, "Th")
tacticM = Look.new(:forward, "Ar")
tacticN = Look.new(:backward, "Ar")
tacticO = Look.new(:forward, "Wi")
tacticP = Look.new(:backward, "Wi")
tacticQ = Look.new(:forward, "no")
tacticR = Look.new(:backward, "no")
tacticQ = Look.new(:forward, "wa")
tacticR = Look.new(:backward, "wa")
tacticQ = Look.new(:forward, "Ca")
tacticR = Look.new(:backward, "Ca")
#// ------------------------
#// feel conditionals
#// ------------------------
tacticS = FeelAndHealth.new(:forward, "Sl", 6)
tacticT = FeelAndHealth.new(:backward, "Sl", 6)
tacticU = FeelAndHealth.new(:forward, "Th", 7)
tacticV = FeelAndHealth.new(:backward, "Th", 7)
tacticW = FeelAndHealth.new(:forward, "Ar", 6)
tacticX = FeelAndHealth.new(:backward, "Ar", 6)
tacticY = FeelAndHealth.new(:forward, "Wi", 6)
tacticZ = FeelAndHealth.new(:backward, "Wi", 6)
tactica = Feel.new(:forward, "Sl")
tacticb = Feel.new(:backward, "Sl")
tacticc = Feel.new(:forward, "Th")
tacticd = Feel.new(:backward, "Th")
tactice = Feel.new(:forward, "Ar")
tacticf = Feel.new(:backward, "Ar")
tacticg = Feel.new(:forward, "Wi")
tactich = Feel.new(:backward, "Wi")
tactici = Feel.new(:forward, "no")
tacticj = Feel.new(:backward, "no")
tactick = Feel.new(:forward, "wa")
tacticl = Feel.new(:backward, "wa")
tacticm = Feel.new(:forward, "Ca")
tacticn = Feel.new(:backward, "Ca")
#// ------------------------
#// actions
#// ------------------------
tactico = Shoot.new(:forward)
tacticp = Shoot.new(:backward)
tacticq = Attack.new(:forward)
tacticr = Attack.new(:backward)
tactics = Walk.new(:forward)
tactict = Walk.new(:backward)
tacticu = RescueCaptive.new(:forward)
tacticv = RescueCaptive.new(:backward)
tacticw = Rest.new
tacticx = Pivot.new
	
	# determine if damage was taken last turn
	@under_attack = @health < @health_last_turn
	@damage_taken_this_turn = @health_last_turn - @health
	
	@tactic_options = [REPLACEMETACTICLISTREPLACEME]
    @tactic_selected = false
	
	@skip_next = false
	@tactic_options.each do |item|
	   # if told to from previous iteration, skip this one
	   if @skip_next
	     @skip_next = false
		 next
	   end
	   # evaluate this node
	   if item.isTerminal
	      item.Action(warrior)
		  break
	   elsif item.Criteria( self, warrior, @direction_of_advance, @health, @tactic, @damage_taken_this_turn, 0, @under_attack )
	     # next criteria/node will be next in loop
		 next
       else
	     @skip_next = true # jump over the next item, this item's action
	   end
	end
	
  end
  

  
  def LookAhead(warrior)
     if (!warrior.respond_to?('look'))
	    return nil
	 end
     whatsAhead = warrior.look @direction_of_advance
	 founditem = whatsAhead.first
     whatsAhead.each do |item|
	    #puts item
	    if ((not item.empty?) or item.stairs?)
		   founditem = item
		   break
		end
	 end
	 founditem
  end
  
  def LookAheadDetails(warrior, direction)
     if (!warrior.respond_to?('look'))
	    return nil
	 end
     whatsAhead = warrior.look direction
	 results = LookAheadResults.new
	 distance = 0
	 closest = 90
	 closest_archer = 90
     whatsAhead.each do |item|
	    #puts item
		distance += 1
	    if ((not item.empty?) or item.stairs?)
		   # if it is not a blank square
		   if (item.enemy?)
		      # if an enemy is ahead, record the count and distance to the enemy
		      results.enemyCount += 1
		      if (distance < closest)
			     closest = distance
				 results.closestEnemy = distance
			  end
			  if (item.archer?)
			     puts("Saw an archer!!!")
			     results.archerCount += 1
				 if (distance < closest_archer)
				    closest_archer = distance
					results.closestArcher = distance
				 end
			  end
		   end
		end
	 end
	 results  
  end
  
  def OppositeDirection(direction)
     if (direction == :forward)
	     :backward
     else
	     :forward
	 end
  end
  
  
end



#////////////////////////////////
#// Criteria Blocks
#// -----------------------------
#//
class LookAndHealth
  attr_accessor :isTerminal
  
  def initialize(direction, tag, health)
    @health_criteria = health
	@direction = direction
	@tag = tag
	@isTerminal = false
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     if not warrior.respond_to?('look') or not warrior.respond_to?('health')
	    return false
     elsif warrior.look(@direction).to_s.match(/wa|no|Ca|Ar|Sl|Wi|Th/).to_s == @tag and warrior.health > @health_criteria
	    return false
     elsif warrior.health < 20 
	    return true
	 else
	    return false
	 end
  end 
  
  def Action( warrior )
  end  
end

class Look
  attr_accessor :isTerminal
  
  def initialize(direction, tag)
	@direction = direction
	@tag = tag
	@isTerminal = false
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     if not warrior.respond_to?('look')
	    return false
     elsif warrior.look(@direction).to_s.match(/wa|no|Ca|Ar|Sl|Wi|Th/).to_s == @tag
	    return false
	 else
	    return false
	 end
  end 
  
  def Action( warrior )
  end  
end

class FeelAndHealth
  attr_accessor :isTerminal
  
  def initialize(direction, tag, health)
    @health_criteria = health
	@direction = direction
	@tag = tag
	@isTerminal = false
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     if not warrior.respond_to?('feel') or not warrior.respond_to?('health')
	    return false
     elsif warrior.feel(@direction).to_s.match(/wa|no|Ca|Ar|Sl|Wi|Th/).to_s == @tag and warrior.health > @health_criteria
	    return false
     elsif warrior.health < 20 
	    return true
	 else
	    return false
	 end
  end 
  
  def Action( warrior )
  end  
end

class Feel
  attr_accessor :isTerminal
  
  def initialize(direction, tag)
	@direction = direction
	@tag = tag
	@isTerminal = false
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     if not warrior.respond_to?('feel')
	    return false  
     elsif warrior.feel(@direction).to_s.match(/wa|no|Ca|Ar|Sl|Wi|Th/).to_s == @tag
	    return false
	 else
	    return false
	 end
  end 
  
  def Action( warrior )
  end  
end


#////////////////////////////////
#// Action Blocks
#// -----------------------------
#//
class Walk
  attr_accessor :isTerminal
  
  def initialize(direction)
	@direction = direction
	@isTerminal = true
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
	 return true
  end 
  
  def Action( warrior )
     if warrior.respond_to?('walk!')
        warrior.walk!(@direction)
	 end
  end	 
end  

class Shoot
  attr_accessor :isTerminal
  
  def initialize(direction)
	@direction = direction
	@isTerminal = true
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
	 return true
  end 
  
  def Action( warrior )
     if warrior.respond_to?('shoot!')
        warrior.shoot!(@direction)
	 end
  end	 
end

class Attack
  attr_accessor :isTerminal
  
  def initialize(direction)
	@direction = direction
	@isTerminal = true
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
	 return true
  end 
  
  def Action( warrior )
     if warrior.respond_to?('attack!')
        warrior.attack!(@direction)
	 end
  end	 
end

class RescueCaptive
  attr_accessor :isTerminal
  
  def initialize(direction)
	@direction = direction
	@isTerminal = true
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
	 return true
  end 
  
  def Action( warrior )
     if warrior.respond_to?('rescue!')
        warrior.rescue!(@direction)
	 end
  end	 
end

class Rest
  attr_accessor :isTerminal
  
  def initialize()
	@isTerminal = true
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
	 return true
  end 
  
  def Action( warrior )
     if warrior.respond_to?('rest!')
        warrior.rest!
	 end
  end	 
end

class Pivot
  attr_accessor :isTerminal
  
  def initialize()
	@isTerminal = true
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
	 return true
  end 
  
  def Action( warrior )
     if warrior.respond_to?('pivot!')
        warrior.pivot!
	 end
  end	 
end

#//
#////////////////////////////////
