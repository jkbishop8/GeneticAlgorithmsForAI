require 'fileutils'

class Chromosome
  attr_accessor :name, :tactic
end

def WriteAndPushChromosome1(firstgene)
   chromosome_name = firstgene
   chromosome_tactic = "tactic" + firstgene + ","
   chromosome_tactic.chomp(",")
   newChromosome = Chromosome.new
   newChromosome.name = chromosome_name
   newChromosome.tactic = chromosome_tactic
   @chromosomes.push(newChromosome)
end

def WriteAndPushChromosome2(firstgene, secondgene)
   chromosome_name = firstgene + secondgene
   chromosome_tactic = "tactic" + firstgene + "," + "tactic" + secondgene + ","
   chromosome_tactic.chomp(",")
   newChromosome = Chromosome.new
   newChromosome.name = chromosome_name
   newChromosome.tactic = chromosome_tactic
   @chromosomes.push(newChromosome)
end

def WriteAndPushChromosome3(firstgene, secondgene, thirdgene)
   chromosome_name = firstgene + secondgene + thirdgene
   chromosome_tactic = "tactic" + firstgene + "," + "tactic" + secondgene + "," + "tactic" + thirdgene + ","
   chromosome_tactic.chomp(",")
   newChromosome = Chromosome.new
   newChromosome.name = chromosome_name
   newChromosome.tactic = chromosome_tactic
   @chromosomes.push(newChromosome)
end

def WriteAndPushChromosome4(firstgene, secondgene, thirdgene, fourthgene)
   chromosome_name = firstgene + secondgene + thirdgene + fourthgene
   chromosome_tactic = "tactic" + firstgene + "," + "tactic" + secondgene + "," + "tactic" + thirdgene + "," + "tactic" + fourthgene + ","
   chromosome_tactic.chomp(",")
   newChromosome = Chromosome.new
   newChromosome.name = chromosome_name
   newChromosome.tactic = chromosome_tactic
   @chromosomes.push(newChromosome)
end

def WriteAndPushChromosome5(firstgene, secondgene, thirdgene, fourthgene, fifthgene)
   chromosome_name = firstgene + secondgene + thirdgene + fourthgene + fifthgene
   chromosome_tactic = "tactic" + firstgene + "," + "tactic" + secondgene + "," + "tactic" + thirdgene + "," + "tactic" + fourthgene + "," + "tactic" + fifthgene + ","
   chromosome_tactic.chomp(",")
   newChromosome = Chromosome.new
   newChromosome.name = chromosome_name
   newChromosome.tactic = chromosome_tactic
   @chromosomes.push(newChromosome)
end

@genes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I']
@chromosomes = Array.new
@num_levels = 4

@genes.each do |firstgene|
  # build an n-length chromosome
  if @num_levels == 1
     WriteAndPushChromosome1(firstgene, secondgene)
  else  
	  @genes.each do |secondgene|
		if secondgene == firstgene
		  next
		end
		if @num_levels == 2
		   WriteAndPushChromosome2(firstgene, secondgene)
		else
			@genes.each do |thirdgene|
			  if thirdgene == firstgene || thirdgene == secondgene
				next
			  end	
			  if @num_levels == 3
				  WriteAndPushChromosome3(firstgene, secondgene, thirdgene)	  
			  else	  
				  @genes.each do |fourthgene|
					if fourthgene == thirdgene || fourthgene == firstgene || fourthgene ==  secondgene
					  next
					end		  
					if @num_levels == 4
						  WriteAndPushChromosome4(firstgene, secondgene, thirdgene, fourthgene)			
					else
					   @genes.each do |fifthgene|	  
						  if fifthgene == fourthgene || fifthgene == thirdgene || fifthgene == firstgene || fifthgene ==  secondgene
							next
						  end		  		
						  WriteAndPushChromosome5(firstgene, secondgene, thirdgene, fourthgene, fifthgene)
					   end
					end
				  end
			   end
			end
 		end
	end
  end
end

@chromosomes.each do |item|
   # run rubywarrior to create the profile
   system("rubywarrior", "-c", "beginner,"+item.name)
   # copy the boilerplate to the profile
   targetFolder = ".\\rubywarrior\\"+item.name+"-beginner\\"
   FileUtils.copy(".\\rubywarrior\\boilerplate-beginner\\player.rb", targetFolder)
   # customize the boilerplate
   text = File.read(targetFolder +"\\player.rb")
   customized_boilerplate =  text.gsub(/REPLACEMETACTICLISTREPLACEME/,  item.tactic)
   File.open(targetFolder +"\\player.rb", "w") {|file| file.puts customized_boilerplate}
   # run rubywarrior to get results
   for i in 0..9
      system("rubywarrior", "-s", "-t", "0", "-d", targetFolder)
   end
   # collate results (TBD)
end