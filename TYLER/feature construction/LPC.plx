#! /usr/bin/perl



for($cn=0;$cn<@file;$cn++){
	open SS,"$taskID/cache/secondstruct/$cn.txt" or die "can not open";
	open FAST,"$taskID/fastas/$cn.txt" or die "can not open";
	chomp(@array=<FAST>);
	chomp($firstline=<SS>);
	close SS;
	close FAST;
	$locate=0;
	@fragment=();
	@peptide=();
	@struct=split(//,$firstline);


	for($i=0;$i<@struct;$i++){
		if(@struct[$i] eq @struct[$i+1]){
			;
		}else{		
			$peptide=substr(@array[1],$locate,$i+1-$locate);
			$frag=substr($firstline,$locate,$i+1-$locate);
			push(@fragment,$frag);
			push(@peptide,$peptide);	
			$locate=$i+1;
		}
	}
	open PEPTIDE,">$taskID/cache/fragmentresidue/$cn.txt";

	$maxlength=0;
	$index=0;
	for($j=0;$j<@fragment;$j++){
		print PEPTIDE @fragment[$j]." ".@peptide[$j]."\n";
		if(length(@fragment[$j])>=$maxlength){
		$maxlength=length(@fragment[$j]);	
		$index=$j;
		}
	}
	
	close PEPTIDE;
	$maxpeptide=@peptide[$index];
	open WRITE,">$taskID/maxpiptidepercent/$cn.txt";
	$hydroxylic=0;$tiny=0;$small=0;$acidic=0;$positive=0;$polar=0;
	$charged=0;$hydrophobic=0;$aromatic=0;$sulphur=0;$aliphatic=0;
	@callen=split(//,$maxpeptide);
	$length=0;$templen=0;
	for($temp=0;$temp<@callen;$temp++){
		if(@callen[$temp] =~ /[A-Z]/){$templen++;}
	}
	$length=$templen;
	
	@AAs=split(//,$maxpeptide);
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /T|S/){
		$hydroxylic++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /A|C|G|S/){
		$tiny++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /A|C|G|S|T|P|N|D|V/){
		$small++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /N|Q/){
		$acidic++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /H|K|R/){
		$positive++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /S|T|C|N|Q|D|E|K|R|H|Y|W/){
		$polar++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /D|E|H|K|R/){
		$charged++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /I|V|L|M|C|A|T|H|K|F|Y|W/){
		$hydrophobic++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /F|Y|W|H/){
		$aromatic++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /M|C/){
		$sulphur++;}
	}
	for($cn=0;$cn<$length;$cn++){
		if(@AAs[$cn] =~ /I|L|V/){
		$aliphatic++;}
	}
	
	undef @fragment;
	undef @peptide;
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






















































