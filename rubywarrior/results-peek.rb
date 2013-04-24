require 'fileutils'

class Result
  attr_accessor :name, :level, :score
end

    @resultsFile = ".\\rubywarrior-results.txt"
	
	results = File.read(@resultsFile)

	@scores = Array.new
	@best_level = 0
	@best_score = 0
	count = 0
	results.each_line do |line|
	  # get name, best level completed, and score
	  newScore = Result.new
	  /(?<name>\w+) - (?<skilllevel>\w+) - level (?<level>\d) - score (?<score>\d+)/ =~ line
	  newScore.name = name
	  newScore.level = level
	  newScore.score = score
	  @scores.push(newScore)
	  
	  # collect best level and best score for fitness function, later
	  if (level.to_i > @best_level)
		 @best_level = level.to_i
	  end  
	  if (score.to_i > @best_score)
		 @best_score = score.to_i
	  end
	  count = count + 1
	end
	
	puts count.to_s + " items reviewed."
	puts "Best level: " + @best_level.to_s
	puts "Best score: " + @best_score.to_s