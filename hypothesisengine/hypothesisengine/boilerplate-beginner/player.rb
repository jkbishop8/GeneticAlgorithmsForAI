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
    tacticA = Tactic_RetreatAndRest.new
    tacticB = Tactic_RestUp.new
	tacticC = SubTactic_ICanTakeEm.new
	tacticD = SubTactic_TheresOnlyOneLeft.new
	tacticE = SubTactic_IllBeFullyHealedOnTheNextLevel.new
	tacticF = SubTactic_LookLeftLookRight.new
	tacticG = SubTactic_PreferArchers.new
	tacticH = SubTactic_TooHurtToContinue.new
	tacticI = SubTactic_SweepTheLevel.new
	my_damage_per_turn = 5
	
	# determine if damage was taken last turn
	@under_attack = @health < @health_last_turn
	@damage_taken_this_turn = @health_last_turn - @health
	
	@tactic_options = [REPLACEMETACTICLISTREPLACEME]
    @tactic_selected = false
	
	@tactic_options.each do |item|
	   if item.Criteria( self, warrior, @direction_of_advance, @health, @tactic, @damage_taken_this_turn, my_damage_per_turn, @under_attack )
	      item.Action(self)
		  @tactic_selected = true
		  break
	   end
	end
	
	if !@tactic_selected
	   @tactic = :advance
	end
	
	# execute the tactic
	if @tactic == :retreat_and_rest
       PerformRetreatAndRest(warrior)
	else
	   PerformAdvance(warrior)
	end
	
	@health_last_turn = @health
  end
  
  def PerformRetreatAndRest(warrior)
	   # perform retreat_and_rest
	   if not warrior.respond_to?('feel') 
	     # if not able to feel, just rest
	     warrior.rest!
	   elsif warrior.feel.empty? and not @under_attack
	      # if no threat in front, and not being wounded, this is a safe place -- rest here
	      warrior.rest!
	   else
	      # if locked in combat, retreat first
	      warrior.walk! @direction_of_retreat
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
  
  def PerformAdvance(warrior)
	   # perform advance
	   if warrior.respond_to?('look')
	      whatsAhead = LookAhead(warrior)
	   elsif warrior.respond_to?('feel')
	     whatsAhead = warrior.feel
	   else
	     whatsAhead = nil
	   end
	   
	   if whatsAhead == nil
	      warrior.walk!
	   elsif @turn_around && warrior.respond_to?('pivot')
	      # if a tactic criteria specified a command, do it
		  @turn_around = false
		  warrior.pivot!
	   elsif whatsAhead.empty?
	      # if there is nothing in front of me, walk
	      warrior.walk! @direction_of_advance
	   elsif whatsAhead.wall?
	      # if the current direction has been fully explored, look in a new direction
		  #@direction_of_advance = :forward
		  #@direction_of_retreat = :backward
		  @cleared_behind_me = true
		  warrior.pivot!
		  # PerformAdvance(warrior)
	   elsif whatsAhead.captive?
	      # if there is something in front of me, and it is a captive, then rescue it
		  if (warrior.feel(@direction_of_advance).captive?)
		     warrior.rescue! @direction_of_advance
		  else
		     warrior.walk! @direction_of_advance
		  end
	   elsif whatsAhead.enemy?
	      # if there is something in front of me, and it's not a captive, it's a bad guy -- attack it
		  if (warrior.feel(@direction_of_advance).enemy?)
		     # if the enemy is immediately in front of me, attack it
	         warrior.attack! @direction_of_advance
		  else
		     # if the enemy is downrange, shoot it
		     warrior.shoot! @direction_of_advance
		  end
	   else
	      # if it's something unknown, advance
	      warrior.walk! @direction_of_advance
	   end  
  end
  
  def SwapDirections
  end
  
end

class Tactic_RetreatAndRest
  def initialize
  end
  
   def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     # if badly wounded, retreat and rest
    (under_attack and health < 10)
   end
   
   def Action( player )
      player.Tactic = :retreat_and_rest
   end
end

class Tactic_RestUp
  def initialize
  end

   def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
      # if currently resting, but not fully recovered, keep resting
      (tactic == :retreat_and_rest and health < 18)
   end
   
   def Action( player )
      player.Tactic = :retreat_and_rest
   end   
end

class SubTactic_ICanTakeEm
  def initialize
  end

   def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack, turnsToFallBack = 2 )
      if (!warrior.respond_to?('feel'))
	     return false
	  end
      # if engaged with an enemy
	  if (warrior.feel(direction_of_advance).enemy?)
	     # use the enemy's health
		 enemyHealth = warrior.feel(direction_of_advance).unit.health
		 # we're in contact with the enemy, so an advance is not required
		 turnsToAdvance = 0
	  else
	     # if fighting an enemy imagined to be ahead, use an average health
		 enemyHealth = 24
		 turnsToAdvance = 2
	  end
	  
      anticipatedTurnsToWhackEnemy = (enemyHealth / my_damage_per_turn).round + turnsToAdvance + turnsToFallBack
	  
	  #printf("ICanTakeEm calculation: myhealth = %f, damageSustainedPerTurn = %f, turnsToWhackEnemy = %f", health, damageSustainedPerTurn, anticipatedTurnsToWhackEnemy)
	  
	  # return value
	  (health > (damage_taken_this_turn * anticipatedTurnsToWhackEnemy))
   end
   
   def Action( player )
      player.Tactic = :advance
   end   
end

class SubTactic_TooHurtToContinue
   def initialize
   end

  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
    averageSingleEnemyDamagePerTurn = 3
    (health <= averageSingleEnemyDamagePerTurn && !under_attack)
  end  

  def Action( player )
      player.Tactic = :retreat_and_rest
  end
end

class SubTactic_SweepTheLevel
  def initialize
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     if not warrior.respond_to?('feel') 
	   return false
	 end
     if warrior.feel.stairs? && !player.ClearedBehindMe
	   return true
	 end
	 false
  end
  
  def Action( player )
      player.TurnAround = true
      player.Tactic = :advance
  end
		      
end

class SubTactic_TheresOnlyOneLeft
  def initialize
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     averageSingleEnemyDamagePerTurn = 3
     if (damage_taken_this_turn <= averageSingleEnemyDamagePerTurn)
	     # if there is only one enemy, calculate "I Can Take Em" without a fallback parameter
		 subtactic_icantakeem = SubTactic_ICanTakeEm.new
		 # return value
	     (subtactic_icantakeem.Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack, 0))
	 else
	     # return value
	     false
	 end
  end
  
  def Action( player )
     player.Tactic = :advance
  end
end

class SubTactic_IllBeFullyHealedOnTheNextLevel
  def initialize
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     averageSingleEnemyDamagePerTurn = 3
     return [(damage_taken_this_turn == 0 and health > averageSingleEnemyDamagePerTurn)]
  end
  
  def Action( player )
      player.Tactic = :advance
  end  
end

class SubTactic_LookLeftLookRight
  def initialize
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     resultsCurrentDirection = player.LookAheadDetails(warrior, direction_of_advance)
	 if (resultsCurrentDirection == nil)
	    return false
	 end
	 resultsOtherDirection = player.LookAheadDetails(warrior, player.OppositeDirection(direction_of_advance))
	 
     if (resultsCurrentDirection.enemyCount == resultsOtherDirection.enemyCount)
	    # if the enemy count is the same, but one is closer, go that way
		if (resultsCurrentDirection.closestEnemy <= resultsOtherDirection.closestEnemy)
		else
		   # change directions (unless we have already cleared that direction)
		   if (!player.ClearedBehindMe)
		      turnAround = true
		   end
		end
	 elsif (resultsCurrentDirection.enemyCount < resultsOtherDirection.enemyCount)
	    # if there are fewer enemy in the current direction, go that way
	 else
	    # if there are fewer enemy in the other direction, go that way 
		#  (unless we have already cleared that direction)
		if (!player.ClearedBehindMe)
		   turnAround = true
		end
	 end
	 true
  end
  
  def Action( player )
      player.Tactic = :advance
  end    
end

class SubTactic_PreferArchers
  def initialize
  end
  
  def Criteria( player, warrior, direction_of_advance, health, tactic, damage_taken_this_turn, my_damage_per_turn, under_attack )
     resultsCurrentDirection = player.LookAheadDetails(warrior, direction_of_advance)
	 if (resultsCurrentDirection == nil)
	    puts("Couldn't look ahead!!!")
	    return false
	 end
	 resultsOtherDirection = player.LookAheadDetails(warrior, player.OppositeDirection(direction_of_advance))
	 criteriaResult = false
	 
	 if (resultsCurrentDirection.archerCount == 0 && resultsOtherDirection.archerCount == 0)
	    criteriaResult = false
     elsif (resultsCurrentDirection.archerCount == resultsOtherDirection.archerCount)
	    # if the enemy count is the same, but one is closer, go that way
		if (resultsCurrentDirection.closestArcher <= resultsOtherDirection.closestArcher)
		else
		   # change directions (unless we have already cleared that direction)
		   if (!player.ClearedBehindMe)
		      player.TurnAround = true
		      puts("Turn around!!")			  
		   end
		end
		criteriaResult = true
	 elsif (resultsCurrentDirection.archerCount >= resultsOtherDirection.archerCount)
	    # if there are more enemy in the current direction, go that way
		criteriaResult = true
	 else
	    # if there are more enemy in the other direction, go that way 
		#  (unless we have already cleared that direction)
		if (!player.ClearedBehindMe)
		   puts("Turn around!!")
		   player.TurnAround = true
		end
		criteriaResult = true
	 end
	 criteriaResult
  end
  
  def Action( player )
      player.Tactic = :advance
  end    
end


class LookAheadResults
   
   def initialize
	   @enemyCount = 0
	   @closestEnemy = 0   
	   @archerCount = 0
	   @closestArcher = 0   
   end
   
   def enemyCount
      @enemyCount
   end
   
   def enemyCount=(count)
      @enemyCount = count
   end
   
   def closestEnemy
      @closestEnemy
   end
   
   def closestEnemy=(closestEnemy)
      @closestEnemy = closestEnemy
   end
   
   def archerCount
      @archerCount
   end
   
   def archerCount=(count)
      @archerCount = count
   end
   
   def closestArcher
      @closestEnemy
   end
   
   def closestArcher=(closestArcher)
      @closestArcher = closestArcher
   end   
end