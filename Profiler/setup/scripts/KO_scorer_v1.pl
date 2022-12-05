#!/usr/bin/perl



##read input from command line, print program requirements if no or missing input is provided
$usage = "\nInsufficient command line arguments provided.\nUSAGE: $0 \n 1. input pathway rules file\n 2. input annotation file file\n 3. name of output file\n\n";

$input_rules = shift(@ARGV) or die ($usage);
$input_annotations = shift(@ARGV) or die ($usage);
$output = shift(@ARGV) or die ($usage);

###############
# Read rules files and store in hash
###############

#open pathway rules file and store all steps in a hash
open(PATHWAYS,'<'.$input_rules);

while(<PATHWAYS>){
    chomp $_;
    #go through all lines except for header which starts with 'Pathway'
    unless ($_ =~ /^Pathway/){

    	#split line into an array, pathway type is at pos 0, KO number at pos 1, step of the KO at position 2
    	@KO = split (/\t/, $_);


    	#each KO can contribute to several steps in a pathway, split these steps at ':' sign as used in the rules file
    	@step = split (/\:/, $KO[2]);

    	#go through each step the KO contributes to (for most it is only one)
    	foreach (@step){

    		#split step info into an array, pathway version (e.g. A or B) is at pos 0, step number at pos 1, step variant at pos 2, subunits of the step variant at pos 3 if exists
    		@step_info = split (/\_/, $_);

    		#if KO contributes to a step that needs several KOs (enzyme subunits) resulting in the step_info array being being larger than 3, we need to store all KOs contributing to this step together, else we can simply store the pathway type, the version, the step number, and the variant of this KO in a hash
    		if (scalar(@step_info)>3){

 				#if hash at this key is empty, assign first KO to the hash without comma (first entry), otherwise concatenate and separate with a comma
 			 	unless (exists $pathway{$KO[0]}{$step_info[0]}{$step_info[1]}{$step_info[2]}){

 			 		#store subunit one
 			 		$pathway{$KO[0]}{$step_info[0]}{$step_info[1]}{$step_info[2]} = $KO[1];
 			 		}else{
 			 			#store further subunits
 			 			$pathway{$KO[0]}{$step_info[0]}{$step_info[1]}{$step_info[2]} .= ",".$KO[1];
 			 		}

  			#if no subunits...only one KO will be stored for this pathway step
    		}else{

			$pathway{$KO[0]}{$step_info[0]}{$step_info[1]}{$step_info[2]} = $KO[1];
    		}
		}
	}
}


#Print out all steps and assigned KO as stored in the hash, sanity check...
foreach  $type (keys %pathway) {
  foreach  $version (keys %{$pathway{$type}}) {
  	foreach  $step_number (keys %{$pathway{$type}{$version}}) {
  		foreach  $alternative (keys %{$pathway{$type}{$version}{$step_number}}) {

  		  		print $type,"\t",$version,"\t",$step_number,"\t",$alternative,"\t",$pathway{$type}{$version}{$step_number}{$alternative}, "\n";
 	 		}
		}
	}
}

close PATHWAYS;

###############
# Store KO annotations of all genomes in a hash
###############

#open genome annotation file
open(ANNOTATIONS,'<'.$input_annotations);

  		while(<ANNOTATIONS>){

    	chomp $_;

    	#go through all lines except for header which starts with 'Pathway'
    	unless ($_ =~ /^Strain/){

    		#split line into an array, strain name is at pos 0, KO number at pos 1
    		@annotation = split (/\t/, $_);

    		#Generate a hash of a hash containing each KO of each genome
    		$genes{$annotation[0]}{$annotation[2]} = "TRUE";
			$genome{$annotation[0]} = "TRUE";

		}
	}

close ANNOTATIONS;


###############
# Check for completeness of all pathways in all genomes
###############


#Go through all strains stored in the %genes hash
foreach $strain (sort { $a <=> $b} keys %genes) {

	#after ordering, go through all types, version, and steps of the stored rules in the %pathway hash for all strains
	foreach  $type (sort { $a <=> $b} keys %pathway) {

		$all_scores{$strain}{$type} = 0;

  		foreach  $version (sort { $a <=> $b} keys %{$pathway{$type}}) {

    		#print some key info about the pathways analyzed to the stdout
    		print $strain,", ",$type,", path variant:",$version,"\n";

			#set score to 0 for each new version of the pathway analyzed
			$score = 0;

  			foreach  $step_number (sort { $a <=> $b} keys %{$pathway{$type}{$version}}) {

  	  			#go through all alternative KOs for this step of this version of the pathway, exit with 'last' in case one of the alternatives exist
  				foreach  $alternative (sort keys %{$pathway{$type}{$version}{$step_number}}) {

  		  			#split KOs stored for this alternative of the step on comma to separate eventual subunits
    				@ko_subunits = split (/,/, $pathway{$type}{$version}{$step_number}{$alternative});
					$candidate = $pathway{$type}{$version}{$step_number}{$alternative};
  		  			$exist = "TRUE";

  		  			#check if KO(s) exist, if one of the subunits does not exist, switch to false.
  		  			foreach (@ko_subunits){

  		  				unless (exists $genes{$strain}{$_}){

  		  					$exist = "FALSE";
  		  				}
  		  			}

  		  			#here we exit the foreach loop of alternatives, if we find one which exists, i.e. $exist not turned to FALSE
  		  			last if ($exist eq "TRUE");
  		  		}

  		  		#if one alternative exists and $exist is on TRUE, we increase the score for this pathway version by +1, KO is printed to Stdout
  				if ($exist eq "TRUE"){
  				print $candidate,"\n";
  				$score += 1;

  				}
			}

			#determine step number of each pathway version
			$step_numbers = keys %{$pathway{$type}{$version}};
			#determine score normalized by pathway length
			$perc_score = $score/$step_numbers;
			#print to Stdout
			print "Total steps: $step_numbers\n\n";

			#if the score of the current version of the pathway is higher than a previously stored score of another version than replace
			if ($perc_score >= $all_scores{$strain}{$type}){

				$all_scores{$strain}{$type} = $perc_score;
				$all_step_numbers{$strain}{$type} = $step_numbers;
			}

		}


	}
}

open(OUTPUT,'>'.$output);


#Print strain, pathway, number of steps and score to the output file specified in the beginning.
foreach  $strain (keys %all_scores) {
  foreach  $type (keys %{$all_scores{$strain}}) {

  		  		print OUTPUT $strain,"\t",$type,"\t",$all_step_numbers{$strain}{$type}, "\t",$all_scores{$strain}{$type}, "\n";
	}
}

close OUTPUT;
