#!/usr/bin/perl



##read input from command line, print program requirements if no or missing input
$usage = "\nInsufficient command line arguments provided.\nUSAGE: $0 \n 1. directory containing MacSyFinder results file\n 2. txt file containing strain id to MacSyFinder id\n 3. file name main systems output\n 4. file name sub-systems output\n\n";

$macsyfinder_output_dir = shift(@ARGV) or die ($usage);
$ESL_id_match = shift(@ARGV) or die ($usage);
$output_sub = shift(@ARGV) or die ($usage);
$output_main = shift(@ARGV) or die ($usage);

open(MATCHINGGENOMES,'<'.$macsyfinder_output_dir.'/'.$ESL_id_match);

while(<MATCHINGGENOMES>){
    chomp $_;
    if ($_=~ /^ESL/){
	
		@array1 = split (/\t/, $_);
		$genome_match{$array1[2]} = $array1[0];
		}
	}

close MATCHINGGENOMES;

%subsystems = (Flagellum => 'unknown	0',pT4SSi => 'unknown	0',pT4SSt => 'unknown	0',T1SS => 'unknown	0',T2SS => 'unknown	0',T3SS => 'unknown	0',T4P => 'unknown	0',T4SS_typeB => 'unknown	0',T4SS_typeC => 'unknown	0',T4SS_typeF => 'unknown	0',T4SS_typeG => 'unknown	0',T4SS_typeI => 'na	0',T4SS_typeT => 'na	0',T5aSS => 'na	0',T5bSS => 'na	0',T5cSS => 'na	0',T6SSiii => 'na	0',T6SSii => 'na	0',T6SSi => 'na	0',T9SS => 'na	0',Tad => 'na	0');

foreach  $genome (keys %genome_match) {	
  foreach  $system (keys %subsystems){
  
  	$scores_subsystems{$genome_match{$genome}}{$system} = $subsystems{$system};
  	$number_mandatory{$genome_match{$genome}}{$system} = 'na';
  	}
  }


	
###############
# Read MacSyFinder results and store in hash
###############

opendir(DH, $macsyfinder_output_dir);
my @files = readdir(DH);
closedir(DH);

foreach my $file (@files)
{
    next if($file =~ /^\.$/);
    next if($file =~ /^\.\.$/);
    if ($file =~ /^Galaxy/){
    
		open(RESULTS,'<'.$macsyfinder_output_dir.'/'.$file);

		$file =~ /on_data_(\d+)/;
		$genome = $genome_match{$1};
		

		while(<RESULTS>){
    		
    		chomp $_;
			if ($_=~ /^(Flagellum|pT4SSi|pT4SSt|T1SS|T2SS|T3SS|T4P|T4SS_typeB|T4SS_typeC|T4SS_typeF|T4SS_typeG|T4SS_typeI|T|T5aSS|T5bSS|T5cSS|T6SSiii|T6SSii|T6SSi|T9SS|Tad)$/){
				
				$system = $1;
			}
		
			elsif ($system ne "none" && $_=~ /.+\t(\d+)/){
	
				$mandatory_genes += 1;
				if ($1 >0){
					$gene_counts += 1;
				} 
			}
		
			elsif ($gene_counts > 0){
				$score = $gene_counts/$mandatory_genes;
				$scores_subsystems{$genome}{$system} = "$score";
				$number_mandatory{$genome}{$system} = "$mandatory_genes";
				$mandatory_genes = 0;
				$gene_counts = 0;
    			$system = "none";
    		}
    	}
    
		close RESULTS;

    }

}

open(OUTPUTDETAILED,'>' .$output_sub);
open(OUTPUTSHORT,'>' .$output_main);


#Print out all steps and assigned KO as stored in the hash, sanity check...
foreach  $genome (keys %scores_subsystems) {	
  foreach  $system (keys %{$scores_subsystems{$genome}}) {  	
  	
  	print OUTPUTDETAILED $genome,"\t",$system,"\t",$number_mandatory{$genome}{$system},"\t",$scores_subsystems{$genome}{$system}, "\n";
	if ($system=~ /^(Flagellum|T1SS|T2SS|T3SS|T4SS|T5\SSS|T6SS|T9SS|T4P|Tad)/){
		 
		 $general_system = $1;
		 if ($1 =~ /T5\SSS/) { 
		 		$general_system = "T5SS"; 
		 	}
		 unless (exists $hash_systems{$genome}{$general_system}){ 
		 	print $general_system,"\n";
		 	$hash_systems{$genome}{$general_system} = 0;
		 	$number_general_mandatory{$genome}{$general_system} = 'na';
		 }
		
		 if ($scores_subsystems{$genome}{$system} > $hash_systems{$genome}{$general_system}){
		
			$hash_systems{$genome}{$general_system} = $scores_subsystems{$genome}{$system};
			$number_general_mandatory{$genome}{$general_system} = $number_mandatory{$genome}{$system};
		}
	
 	}
  }   
}
close OUTPUTDETAILED; 

foreach  $genome (keys %hash_systems) {	
  foreach  $system (keys %{$hash_systems{$genome}}) {  

	print OUTPUTSHORT $genome,"\t",$system,"\t",$number_general_mandatory{$genome}{$system},"\t", $hash_systems{$genome}{$system}, "\n";

 	}
 }

close OUTPUTSHORT;

