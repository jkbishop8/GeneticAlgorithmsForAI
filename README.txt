========================
Getting Started
========================
Thanks for downloading GA for RubyWarrior! Hopefully, this guide will get you through the steps of getting started.

---------------------------
1. Install Ruby
---------------------------
https://rubyinstaller.org/downloads/

Tested 5/31/2019 with "=> Ruby+Devkit 2.5.5-1 (x64)" on Windows

---------------------------
2. Install rubywarrior
---------------------------
From a command prompt, type : gem install rubywarrior

You may be prompted which version to install. Use rubywarrior-0.1.3

---------------------------
3. Copy rubywarrior code extensions
---------------------------
You may need to find your rubywarrior installation. 
These steps assume it's at --> C:\Ruby25-x64\lib\ruby\gems\2.5.0\gems\rubywarrior-0.1.3

From the same folder at this readme:

Copy "rubywarrior-0.1.3" to "C:\Ruby25-x64\lib\ruby\gems\2.5.0\gems\rubywarrior-0.1.3"

---------------------------
4. Navigate to starting directory and start
---------------------------
Navigate to the "rubywarrior" folder, located in the same folder as this README

Type: ruby rubywarrior-genetic.rb to get started

---------------------------
5. Manipulating new gene sequences
---------------------------
Open "rubywarrior-genetic.rb" in your favorite text editor.

The "@genes" variable is the list of genes

The "@num_levels" variable is the chromosome length

The loop below these two variable definitions creates chromosomes of the length specified from the genes provided.

IF YOU WANT RANDOM CHROMOSOMES, use "rubywarrior-genetic-alt.rb"

---------------------------
6. Manipulating genes
---------------------------
Navigate to "rubywarrior\rubywarrior\boilerplate-beginner"

Open "player.rb" in your favorite text editor.

Look for the "# tactical classes" label. The variable definitions below are the gene letters : 
A through I (as of 5/30/2019). Each letter represents a subtask that will be executed in order
of preference.

Each gene class has an "Initialize", "Criteria" and "Action" method.
"Initialize" is where you may perform some sort of pre-processing.
"Criteria" is a method that, based on the provided state, determines if the gene "Action" method should be called
and "Action" is the action for the gene to take, if activated.

Further down in "player.rb", you will find a "@tactic_options = [REPLACEMETACTICLISTREPLACEME]".
"@tactic_options" is where the generated gene sequence is inserted.

The loop immediate following tests genes in order, using the gene's own Criteria for activation.
If Criteria returns true, the Action method is called.