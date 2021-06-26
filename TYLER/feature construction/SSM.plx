#! /usr/bin/perl


for($cn=0;$cn<@file;$cn++){
	open SS,"$taskID/cache/$cn.txt" or die "can not open";
	chomp($onlyline=<SS>);
	close SS;

	open XSS,">$taskID/cache/$cn.txt" or die "can not open";
	$xlocation='X';
	print XSS $xlocation;
	print XSS $onlyline;
	print XSS $xlocation;
	close XSS;

	open SS,"$taskID/cache/$cn.txt" or die "can not open";
	chomp($firstline=<SS>);
	close SS;
	$locate=0;
	@FR=();

	@struct=split(//,$firstline);
	for($i=0;$i<@struct;$i++){
		if(@struct[$i] eq @struct[$i+1]){
			;
		}else{
			$frag=substr($firstline,$locate,$i+1-$locate);
			push(@FR,$frag);	
			$locate=$i+1;
		}
	}
	
	open FRAG,">$taskID/cache/motif/$cn.txt";
	$motiflen=@FR;
	for($j=0;$j<$motiflen-2;$j++){
		print FRAG @FR[$j].@FR[$j+1].@FR[$j+2]."\n";

	}
	close FRAG;

	open FRAG,"$taskID/cache/motif/$cn.txt" or die "can not open ";
	open PERCENT,">$taskID/Motifpercent/$cn.txt" or die "can not open";
	 
	chomp(@motif=<FRAG>);
	$motifLen=@motif;
	$XEC=0;$XEH=0;$XCE=0;$XCH=0;$XHC=0;$XHE=0;$ECX=0;$EHX=0;$CHX=0;$CEX=0;$HCX=0;$HEX=0;
	$CEC=0;$CEH=0;$EHC=0;$ECH=0;$HCE=0;$HEC=0;$CHE=0;$CHC=0;$EHE=0;$ECE=0;$HCH=0;$HEH=0;


	for($j=0;$j<$motifLen;$j++){
		if(@motif[$j]=~ /X+E+C+/){$XEC++;}
		if(@motif[$j]=~ /X+E+H+/){$XEH++;}
		if(@motif[$j]=~ /X+C+E+/){$XCE++;}
		if(@motif[$j]=~ /X+C+H+/){$XCH++;}
		if(@motif[$j]=~ /X+H+C+/){$XHC++;}
		if(@motif[$j]=~ /X+H+E+/){$XHE++;}
		if(@motif[$j]=~ /E+C+X+/){$ECX++;}
		if(@motif[$j]=~ /E+H+X+/){$EHX++;}
		if(@motif[$j]=~ /C+H+X+/){$CHX++;}
		if(@motif[$j]=~ /C+E+X+/){$CEX++;}
		if(@motif[$j]=~ /H+C+X+/){$HCX++;}
		if(@motif[$j]=~ /H+E+X+/){$HEX++;}
		if(@motif[$j]=~ /C+E+C+/){$CEC++;}
		if(@motif[$j]=~ /C+E+H+/){$CEH++;}
		if(@motif[$j]=~ /E+H+C+/){$EHC++;}
		if(@motif[$j]=~ /E+C+H+/){$ECH++;}
		if(@motif[$j]=~ /H+C+E+/){$HCE++;}
		if(@motif[$j]=~ /H+E+C+/){$HEC++;}
		if(@motif[$j]=~ /C+H+E+/){$CHE++;}
		if(@motif[$j]=~ /C+H+C+/){$CHC++;}
		if(@motif[$j]=~ /E+H+E+/){$EHE++;}
		if(@motif[$j]=~ /E+C+E+/){$ECE++;}
		if(@motif[$j]=~ /H+C+H+/){$HCH++;}
		if(@motif[$j]=~ /H+E+H+/){$HEH++;}
	}
	printf PERCENT ("%4.3f ",$XEC/$motifLen);
	printf PERCENT ("%4.3f ",$XEH/$motifLen);
	printf PERCENT ("%4.3f ",$XCE/$motifLen);
	printf PERCENT ("%4.3f ",$XCH/$motifLen);
	printf PERCENT ("%4.3f ",$XHC/$motifLen);
	printf PERCENT ("%4.3f ",$XHE/$motifLen);
	printf PERCENT ("%4.3f ",$ECX/$motifLen);
	printf PERCENT ("%4.3f ",$EHX/$motifLen);
	printf PERCENT ("%4.3f ",$CHX/$motifLen);
	printf PERCENT ("%4.3f ",$CEX/$motifLen);
	printf PERCENT ("%4.3f ",$HCX/$motifLen);
	printf PERCENT ("%4.3f ",$HEX/$motifLen);
	printf PERCENT ("%4.3f ",$CEC/$motifLen);
	printf PERCENT ("%4.3f ",$CEH/$motifLen);
	printf PERCENT ("%4.3f ",$EHC/$motifLen);
	printf PERCENT ("%4.3f ",$ECH/$motifLen);
	printf PERCENT ("%4.3f ",$HCE/$motifLen);
	printf PERCENT ("%4.3f ",$HEC/$motifLen);
	printf PERCENT ("%4.3f ",$CHE/$motifLen);
	printf PERCENT ("%4.3f ",$CHC/$motifLen);
	printf PERCENT ("%4.3f ",$EHE/$motifLen);
	printf PERCENT ("%4.3f ",$ECE/$motifLen);
	printf PERCENT ("%4.3f ",$HCH/$motifLen);
	printf PERCENT ("%4.3f ",$HEH/$motifLen);
	close PERCENT;
	close FRAG;

}


































