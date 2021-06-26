#! /usr/bin/perl




for($C=0;$C<@file;$C++){

	open FAST,"$taskID/fastas/$C.txt" or die "can not open";
	open MFAST,">$taskID/cache/motiffasta/$C.txt" or die "can not open";
	chomp(@array=<FAST>);
	$xlocation='X';
	print MFAST $xlocation;
	print MFAST @array[1];
	print MFAST $xlocation;
	close FAST;
	close MFAST;
	open FAST,"$taskID/cache/motiffasta/$C.txt" or die "can not open";
	open SS,"$taskID/cache/Motifsecondstruct/$C.txt" or die "can not open";
	chomp($firstline=<SS>);
	close SS;
	chomp($fasta=<FAST>);
	close FAST;
	$locate=0;
	@fragment=();
	@peptide=();
	@struct=split(//,$firstline);

	for($i=0;$i<@struct;$i++){
		if(@struct[$i] eq @struct[$i+1]){
			;
		}else{
			$peptide=substr($fasta,$locate,$i+1-$locate);
			$frag=substr($firstline,$locate,$i+1-$locate);
			push(@fragment,$frag);
			push(@peptide,$peptide);	
			$locate=$i+1;
		}
	}
	open MOTIF,">$taskID/cache/motifresidue/$C.txt" or die "can not open";
	$motiflen=@fragment;
	for($j=0;$j<$motiflen-2;$j++){
		print MOTIF @fragment[$j].@fragment[$j+1].@fragment[$j+2]." ".@peptide[$j].@peptide[$j+1].@peptide[$j+2]."\n";
	}
	close MOTIF;
	undef @fragment;undef @peptide;
	open MOTIF,"$taskID/cache/motifresidue/$C.txt" or die "can not open";
	$maxlength=0;
	$index=0;
	chomp(@motif=<MOTIF>);
	for($k=0;$k<@motif;$k++){
		if(length(@motif[$k])>=$maxlength){
			$maxlength=length(@motif[$k]);
			$index=$k;
		}
	}
	close MOTIF;
	$maxmotif=@motif[$index];
	@residue=split(/\s+/,$maxmotif);
	open WRITE,">$taskID/maxmotifpercent/$C.txt" or die "can not open";
	$hydroxylic=0;$tiny=0;$small=0;$acidic=0;$positive=0;$polar=0;
	$charged=0;$hydrophobic=0;$aromatic=0;$sulphur=0;$aliphatic=0;
	@callen=split(//,@residue[1]);
	$length=0;$templen=0;
	for($temp=0;$temp<@callen;$temp++){
		if(@callen[$temp] =~ /[A-Z]/){$templen++;}
	}
	$length=$templen;
	
	@AAs=split(//,@residue[1]);
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /T|S/){
		$hydroxylic++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /A|C|G|S/){
		$tiny++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /A|C|G|S|T|P|N|D|V/){
		$small++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /N|Q/){
		$acidic++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /H|K|R/){
		$positive++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /S|T|C|N|Q|D|E|K|R|H|Y|W/){
		$polar++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /D|E|H|K|R/){
		$charged++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /I|V|L|M|C|A|T|H|K|F|Y|W/){
		$hydrophobic++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /F|Y|W|H/){
		$aromatic++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /M|C/){
		$sulphur++;}
	}
	for($C=0;$C<$length;$C++){
		if(@AAs[$C] =~ /I|L|V/){
		$aliphatic++;}
	}
	
	printf WRITE ("%4.3f ",$hydroxylic/$length);
	printf WRITE ("%4.3f ",$tiny/$length);
	printf WRITE ("%4.3f ",$small/$length);
	printf WRITE ("%4.3f ",$acidic/$length);
	printf WRITE ("%4.3f ",$positive/$length);
	printf WRITE ("%4.3f ",$polar/$length);
	printf WRITE ("%4.3f ",$charged/$length);
	printf WRITE ("%4.3f ",$hydrophobic/$length);
	printf WRITE ("%4.3f ",$aromatic/$length);
	printf WRITE ("%4.3f ",$sulphur/$length);
	printf WRITE ("%4.3f ",$aliphatic/$length);	
	close WRITE;
}
























