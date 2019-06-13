require 'fileutils'

class Chromosome
  attr_accessor :name, :tactic
end

class Result
  attr_accessor :name, :level, :score
end

def WriteAndPushAnyNumberOfChromosomes(genes)
   chromosome_name = "" 
   chromosome_tactic = "" 
   genes.each do |item|
    chromosome_name += item
	chromosome_tactic += "tactic" + item + ","
  end
  
  chromosome_tactic.chomp(",")
  newChromosome = Chromosome.new
  newChromosome.name = chromosome_name
  newChromosome.tactic = chromosome_tactic
  @chromosomes.push(newChromosome)  
end

def InitializeFirstGeneration
    puts "Initializing First Generation"
	for b in 0..@num_chromosomes do
	    puts "Chromosome " + b.to_s()
		@chromosome_length = rand(@max_chromosome_length)
		chromosome_genes = Array.new
		# build an n-length chromosome
		for i in 0..@chromosome_length
		  chromosome_genes.push(@genes[rand(@genes.length)])
		  puts "Gene Added" + i.to_s()
		end
		WriteAndPushAnyNumberOfChromosomes(chromosome_genes)
	end
end

def RunSimulation
	@chromosomes.each do |item|
	   puts "Running simulation for " + item.name
	   # run rubywarrior to create the profile
	   system("rubywarrior", "-c", "beginner,"+item.name)
	   # copy the boilerplate to the profile
	   targetFolder = ".\\rubywarrior\\"+item.name+"-beginner\\"
	   FileUtils.copy(".\\rubywarrior-templates\\boilerplate-beginner-alt\\player.rb", targetFolder)
	   # customize the boilerplate
	   text = File.read(targetFolder +"\\player.rb")
	   customized_boilerplate =  text.gsub(/REPLACEMETACTICLISTREPLACEME/,  item.tactic)
	   File.open(targetFolder +"\\player.rb", "w") {|file| file.puts customized_boilerplate}
	   # run rubywarrior to get results
	   for runNumber in 0..@max_simulation_runs
		  system("rubywarrior", "-s", "-q", "-t", "0", "-d", targetFolder)
	   end
	end

	# collate results (TBD)
	system("rubywarrior -r > " + @resultsFile)
end 

def ReviewResults
	results = File.read(@resultsFile)

	@scores = Array.new
	@best_level = 0
	@best_score = 0
	results.each_line do |line|
	  # get name, best level completed, and score
	  newScore = Result.new
	  /(?<name>\w+) - (?<skilllevel>\w+) - level (?<level>\d) - score (?<score>\d+)/ =~ line
	  newScore.name = name
	  newScore.level = level.to_i
	  newScore.score = score.to_i
	  @scores.push(newScore)
	  
	  # collect best level and best score for fitness function, later
	  if (level.to_i > @best_level)
		 @best_level = level.to_i
	  end  
	  if (score.to_i > @best_score)
		 @best_score = score.to_i
	  end
	end
end

def MakeNextGeneration	
	@next_generation = Array.new
	@parents = Array.new
	# apply fitness
	# select next generation, only allow 1/3rd of the population to come from previous generation
	@count = 0
	@scores.each do |item|
	  if item.level == @best_level
		 @next_generation.push(String.new(item.name))
		 @parents.push(String.new(item.name))
		 @count = @count + 1
	  elsif item.score == @best_score
		 @next_generation.push(String.new(item.name))
		 @parents.push(String.new(item.name))
		 puts "Pushing " + item.name
		 @count = @count + 1
	  end
	  if (@count > (@num_chromosomes/3))
		 break
	  end
	end
	puts "Copied over " + @count.to_s() + " parents"

	while @count < @num_chromosomes
		# apply breeding
		parent1 = String.new(@parents.sample)
		parent2 = String.new(@parents.sample)
		puts "parent1 " + parent1 + ", parent2 " + parent2
		amount_to_copy_from_parent1 = rand(parent1.length)
		amount_to_copy_from_parent2 = rand(parent2.length)
		if amount_to_copy_from_parent1 < 1
		  amount_to_copy_from_parent1 = 1
		end
		if amount_to_copy_from_parent2 < 1
		  amount_to_copy_from_parent2 = 1
		end		   
		place_to_copy_from_parent1 = rand(parent1.length)
		place_to_copy_from_parent2 = rand(parent2.length)		   
		genes_copied_parent1 = parent1[place_to_copy_from_parent1, amount_to_copy_from_parent1]
		genes_copied_parent2 = parent2[place_to_copy_from_parent2, amount_to_copy_from_parent2]
		puts "Genes copied from parent1 " + genes_copied_parent1
		puts "Genes copied from parent2 " + genes_copied_parent2
		child1 = String.new(parent1)
		child2 = String.new(parent2)
		place_to_insert_on_child1 = rand(child1.length)
		place_to_insert_on_child2 = rand(child2.length)
		puts "Insert at " + place_to_insert_on_child1.to_s() + ", " + place_to_insert_on_child2.to_s()
		child1.insert(place_to_insert_on_child1,genes_copied_parent2)
		child2.insert(place_to_insert_on_child2,genes_copied_parent1)
		   # trim the genes back down to maximum size
		#child1 = child1[0..@max_chromosome_length]
		#child2 = child2[0..@max_chromosome_length]
		@next_generation.push(child1)
		@next_generation.push(child2)
		puts "Pushing " + child1
		puts "Pushing " + child2
		@count = @count + 2
		
		puts "Created children, count now " + @count.to_s()

		#apply mutation
		parent_to_mutate = String.new(@parents.sample)
		child = parent_to_mutate
		child[rand(child.length)] = @genes.sample
		@next_generation.push(child)
		puts "Pushing " + child
		@count = @count + 1
		
		puts "Created mutations, count now " + @count.to_s()
	end
	
	#prepare simulation for next run
	@count = 0
	@chromosomes = Array.new
	@next_generation.each do |newgeneration|
	   puts "Writing new chromosome " + @count.to_s() + ", " + newgeneration
	   @count = @count + 1
	   WriteAndPushAnyNumberOfChromosomes(newgeneration.scan(/./))
	end
end

def SetLevelParameters
	#best level dependent parameters
	if @best_level == 1
	  @max_chromosome_length = 1
	  @max_simulation_runs = 1
	  @num_chromosomes = 50
	elsif @best_level == 2
	  @max_chromosome_length = 3
	  @max_simulation_runs = 2
	  @num_chromosomes = 300
	elsif @best_level == 3
	  @max_chromosome_length = 6
	  @max_simulation_runs = 3
	  @num_chromosomes = 1000
	elsif @best_level == 4
	  @max_chromosome_length = 18
	  @max_simulation_runs = 4
	  @num_chromosomes = 1000
	elsif @best_level == 5
	  @max_chromosome_length = 36
	  @max_simulation_runs = 5
	  @num_chromosomes = 1000
	else @best_level == 6
	  @max_simulation_runs = @best_level
	  @max_chromosome_length = 100
	  @num_chromosomes = 1500	  
	end
end
	
@genes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x']
@chromosomes = Array.new

@num_chromosomes = 3500
@max_chromosome_length = 30
@max_simulation_runs = 9
@max_generations = 80
@resultsFile = "hypothesisengine-results.txt"

@best_level = 1
ReviewResults()
puts @max_chromosome_length.to_s()
SetLevelParameters()
#InitializeFirstGeneration()
MakeNextGeneration()

for generation in 0..@max_generations
    system("echo " + generation.to_s() + " > gen-run.txt")
	FileUtils.rm_rf(Dir['hypothesisengine/*'])
	RunSimulation()
	# re-run the simulation
	ReviewResults()
    SetLevelParameters()	
	MakeNextGeneration()
end