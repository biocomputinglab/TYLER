#! /usr/bin/perl


$ENV{PATH} = "/home/ubuntu/mmseqs/bin/";

for($cn=0;$cn<@file;$cn++){
	system("mmseqs createdb $taskID/fastas/$cn.txt $mmseqsdir/query/$cn.DB");
	system("mmseqs search $mmseqsdir/query/$cn.DB $mmseqsdir/swissprot/swissprot $mmseqsdir/result/$cn.out $mmseqsdir/tmp -a");
	system("mmseqs result2profile $mmseqsdir/query/$cn.DB $mmseqsdir/swissprot/swissprot  $mmseqsdir/result/$cn.out $mmseqsdir/profile/$cn.profile");
	system("mmseqs profile2pssm $mmseqsdir/profile/$cn.profile $taskID/PSSM/$cn.pssm");
}


sub add
{
    my @arr1 =  @{$_[0]};
    my @arr2 =  @{$_[1]};
    my @result;
    for (my $i=0; $i<@arr2;$i++){
		push (@result, $arr1[$i] + $arr2[$i]);
    }    
    return @result;   
}
sub addfeature
{
	my @arr1 =  @{$_[0]};
	my $len =  ${$_[1]};
	my $result;
	my @result;
	my @newresult;
	@result=map{$_/$len} @arr1;
	for(my $j=0;$j<@result;$j++){
		push(@newresult,(sprintf "%.3f",$result[$j]));
	}
	my $arrlength=@newresult;
	if($arrlength==0){
		$result="0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 ";
	}else{
		for(my $i=0;$i<@newresult;$i++){
			$result.=$newresult[$i]." ";
		}	
	}	
	return $result;
}
for($cn=0;$cn<@file;$cn++){
	open PSSM,"$taskID/PSSM/$cn.pssm" or die "can not open";
	open FASTA,"$taskID/fastas/$cn.txt" or die "can not open";
	chomp(@pssm=<PSSM>);
	close PSSM;
	open PSSM,">$taskID/cache/pssm/$cn.txt" or die "can not open";
	for($i=2;$i<@pssm;$i++){
		@eachline=split(/\s+/,@pssm[$i]);
		for($j=2;$j<@eachline;$j++){
			print PSSM @eachline[$j]." ";
		}
		print PSSM "\n";
	}
	close PSSM;
	chomp(@fasta=<FASTA>);
	close FASTA;

	open PSSM,"$taskID/cache/pssm/$cn.txt" or die "can not open";
	chomp(@array=<PSSM>);
	close PSSM;
	@A_clu=();@C_clu=();@D_clu=();@E_clu=();@F_clu=();@G_clu=();@H_clu=();@I_clu=();@K_clu=();@L_clu=();
	@M_clu=();@N_clu=();@P_clu=();@Q_clu=();@R_clu=();@S_clu=();@T_clu=();@V_clu=();@W_clu=();@Y_clu=();

	@hydroxylic=();@tiny=();@small=();@acidic=();@positive=();@polar=();
	@charged=();@hydrophobic=();@aromatic=();@sulphur=();@aliphatic=();

	for(my $i=0;$i<@array;$i++){
		@eachline=split(/\s+/,@array[$i]);	push(@A_clu,@eachline[0]);push(@C_clu,@eachline[1]);push(@D_clu,@eachline[2]);push(@E_clu,@eachline[3]);push(@F_clu,@eachline[4]);
		push(@G_clu,@eachline[5]);push(@H_clu,@eachline[6]);push(@I_clu,@eachline[7]);push(@K_clu,@eachline[8]);push(@L_clu,@eachline[9]);
		push(@M_clu,@eachline[10]);push(@N_clu,@eachline[11]);push(@P_clu,@eachline[12]);push(@Q_clu,@eachline[13]);push(@R_clu,@eachline[14]);
		push(@S_clu,@eachline[15]);push(@T_clu,@eachline[16]);push(@V_clu,@eachline[17]);push(@W_clu,@eachline[18]);push(@Y_clu,@eachline[19]);
	}
	@hydroxylic=add(\@hydroxylic,\@T_clu);
	@hydroxylic=add(\@hydroxylic,\@S_clu);
	@hydroxylic=map{(sprintf "%.3f",$_/2)} @hydroxylic;

	@tiny=add(\@tiny,\@A_clu);@tiny=add(\@tiny,\@C_clu);
	@tiny=add(\@tiny,\@G_clu);@tiny=add(\@tiny,\@S_clu);
	@tiny=map{(sprintf "%.3f",$_/4)} @tiny;

	@small=add(\@small,\@A_clu);@small=add(\@small,\@C_clu);
	@small=add(\@small,\@G_clu);@small=add(\@small,\@S_clu);
	@small=add(\@small,\@T_clu);@small=add(\@small,\@P_clu);
	@small=add(\@small,\@N_clu);@small=add(\@small,\@D_clu);
	@small=add(\@small,\@V_clu);
	@small=map{(sprintf "%.3f",$_/9)} @small;

	@acidic=add(\@acidic,\@N_clu);@acidic=add(\@acidic,\@Q_clu);
	@acidic=map{(sprintf "%.3f",$_/2)} @acidic;

	@positive=add(\@positive,\@H_clu);
	@positive=add(\@positive,\@K_clu);
	@positive=add(\@positive,\@R_clu);
	@positive=map{(sprintf "%.3f",$_/3)} @positive;

	@polar=add(\@polar,\@S_clu);@polar=add(\@polar,\@T_clu);
	@polar=add(\@polar,\@C_clu);@polar=add(\@polar,\@N_clu);
	@polar=add(\@polar,\@Q_clu);@polar=add(\@polar,\@D_clu);
	@polar=add(\@polar,\@E_clu);@polar=add(\@polar,\@K_clu);
	@polar=add(\@polar,\@R_clu);@polar=add(\@polar,\@H_clu);
	@polar=add(\@polar,\@Y_clu);@polar=add(\@polar,\@W_clu);
	@polar=map{(sprintf "%.3f",$_/12)} @polar;

	@charged=add(\@charged,\@D_clu);@charged=add(\@charged,\@E_clu);
	@charged=add(\@charged,\@H_clu);@charged=add(\@charged,\@K_clu);
	@charged=add(\@charged,\@R_clu);
	@charged=map{(sprintf "%.3f",$_/5)} @charged;

	@hydrophobic=add(\@hydrophobic,\@I_clu);
	@hydrophobic=add(\@hydrophobic,\@V_clu);
	@hydrophobic=add(\@hydrophobic,\@L_clu);
	@hydrophobic=add(\@hydrophobic,\@M_clu);
	@hydrophobic=add(\@hydrophobic,\@C_clu);
	@hydrophobic=add(\@hydrophobic,\@A_clu);
	@hydrophobic=add(\@hydrophobic,\@T_clu);
	@hydrophobic=add(\@hydrophobic,\@H_clu);
	@hydrophobic=add(\@hydrophobic,\@K_clu);
	@hydrophobic=add(\@hydrophobic,\@F_clu);
	@hydrophobic=add(\@hydrophobic,\@Y_clu);
	@hydrophobic=add(\@hydrophobic,\@W_clu);
	@hydrophobic=map{(sprintf "%.3f",$_/12)} @hydrophobic;

	@aromatic=add(\@aromatic,\@F_clu);
	@aromatic=add(\@aromatic,\@Y_clu);
	@aromatic=add(\@aromatic,\@W_clu);
	@aromatic=add(\@aromatic,\@H_clu);
	@aromatic=map{(sprintf "%.3f",$_/4)} @aromatic;

	@sulphur=add(\@sulphur,\@M_clu);@sulphur=add(\@sulphur,\@C_clu);
	@sulphur=map{(sprintf "%.3f",$_/2)} @sulphur;

	@aliphatic=add(\@aliphatic,\@I_clu);
	@aliphatic=add(\@aliphatic,\@L_clu);
	@aliphatic=add(\@aliphatic,\@V_clu);
	@aliphatic=map{(sprintf "%.3f",$_/3)} @aliphatic;

	open PSSM,">$taskID/cache/pssm121/$cn.txt" or die "can not open";
	for (my $i=0;$i<@tiny;$i++){
		print PSSM $hydroxylic[$i]." ".$tiny[$i]." ".$small[$i]." ".$acidic[$i]." ".$positive[$i]." ".$polar[$i]." ".$charged[$i]." ".$hydrophobic[$i]." ".$aromatic[$i]." ".$sulphur[$i]." ".$aliphatic[$i]." "."\n";
	}
	close PSSM;

	@residue=split(//,@fasta[1]);
	$hydroxylic=0;$tiny=0;$small=0;$acidic=0;$positive=0;$polar=0;
	$charged=0;$hydrophobic=0;$aromatic=0;$sulphur=0;$aliphatic=0;

	for(my $index=0;$index<@residue;$index++){
		if(@residue[$index] =~ /T|S/){
			$hydroxylic++;
		}
		if(@residue[$index]  =~ /A|C|G|S/){
			$tiny++;
		}
		if(@residue[$index] =~ /A|C|G|S|T|P|N|D|V/){
			$small++;
		}
		if(@residue[$index] =~ /N|Q/){
			$acidic++;
		}
		if(@residue[$index] =~ /H|K|R/){
			$positive++;
		}
		if(@residue[$index] =~ /S|T|C|N|Q|D|E|K|R|H|Y|W/){
			$polar++;
		}
		if(@residue[$index] =~ /D|E|H|K|R/){
			$charged++;
		}
		if(@residue[$index] =~ /I|V|L|M|C|A|T|H|K|F|Y|W/){
			$hydrophobic++;
		}
		if(@residue[$index] =~ /F|Y|W|H/){
			$aromatic++;
		}
		if(@residue[$index] =~ /M|C/){
			$sulphur++;
		}
		if(@residue[$index] =~ /I|L|V/){
			$aliphatic++;
		}
	}
	open PSSM,"$taskID/cache/pssm121/$cn.txt" or die "can not open";
	chomp(@array=<PSSM>);
	close PSSM;
	@hydroxylic=();@tiny=();@small=();@acidic=();@positive=();@polar=();
	@charged=();@hydrophobic=();@aromatic=();@sulphur=();@aliphatic=();

	for(my $index=0;$index<@residue;$index++){
		if(@residue[$index] =~ /T|S/){
			@thisarr=split(/\s+/,@array[$index]);
			@hydroxylic=add(\@hydroxylic,\@thisarr);
		}
		if(@residue[$index] =~ /A|C|G|S/){
			@thisarr=split(/\s+/,@array[$index]);
			@tiny=add(\@tiny,\@thisarr);	
		}
		if(@residue[$index] =~ /A|C|G|S|T|P|N|D|V/){
			@thisarr=split(/\s+/,@array[$index]);
			@small=add(\@small,\@thisarr);
		}
		if(@residue[$index] =~ /N|Q/){
			@thisarr=split(/\s+/,@array[$index]);
			@acidic=add(\@acidic,\@thisarr);
		}
		if(@residue[$index] =~ /H|K|R/){
			@thisarr=split(/\s+/,@array[$index]);
			@positive=add(\@positive,\@thisarr);
		}
		if(@residue[$index] =~ /S|T|C|N|Q|D|E|K|R|H|Y|W/){
			@thisarr=split(/\s+/,@array[$index]);
			@polar=add(\@polar,\@thisarr);
		}
		if(@residue[$index] =~ /D|E|H|K|R/){
			@thisarr=split(/\s+/,@array[$index]);
			@charged=add(\@charged,\@thisarr);
		}
		if(@residue[$index] =~ /I|V|L|M|C|A|T|H|K|F|Y|W/){
			@thisarr=split(/\s+/,@array[$index]);
			@hydrophobic=add(\@hydrophobic,\@thisarr);
		}
		if(@residue[$index] =~ /F|Y|W|H/){
			@thisarr=split(/\s+/,@array[$index]);
			@aromatic=add(\@aromatic,\@thisarr);
		}
		if(@residue[$index] =~ /M|C/){
			@thisarr=split(/\s+/,@array[$index]);
			@sulphur=add(\@sulphur,\@thisarr);
		}
		if(@residue[$index] =~ /I|L|V/){
			@thisarr=split(/\s+/,@array[$index]);
			@aliphatic=add(\@aliphatic,\@thisarr);
		}
	}

	open PSSM,">$taskID/pssm121/$cn.txt";
	$hydroxylic_str=addfeature(\@hydroxylic,\$hydroxylic);print PSSM $hydroxylic_str;
	$tiny_str=addfeature(\@tiny,\$tiny);print PSSM $tiny_str;
	$small_str=addfeature(\@small,\$small);print PSSM $small_str;
	$acidic_str=addfeature(\@acidic,\$acidic);print PSSM $acidic_str;
	$positive_str=addfeature(\@positive,\$positive);print PSSM $positive_str;
	$polar_str=addfeature(\@polar,\$polar);print PSSM $polar_str;
	$charged_str=addfeature(\@charged,\$charged);print PSSM $charged_str;
	$hydrophobic_str=addfeature(\@hydrophobic,\$hydrophobic);print PSSM $hydrophobic_str;
	$aromatic_str=addfeature(\@aromatic,\$aromatic);print PSSM $aromatic_str;
	$sulphur_str=addfeature(\@sulphur,\$sulphur);print PSSM $sulphur_str;
	$aliphatic_str=addfeature(\@aliphatic,\$aliphatic);print PSSM $aliphatic_str;
	close PSSM;
}














