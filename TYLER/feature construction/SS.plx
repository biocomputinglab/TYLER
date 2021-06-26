#! /usr/bin/perl


for($cn=0;$cn<@file;$cn++){

	open SS,"$taskID/SS/$cn.ss2" or die "can not open";
	chomp(@ss=<SS>);
	close SS;
	
	@newss=();
	open WRITE,">$taskID/C_H_Epercent/$cn.txt" or die "can not open123";
	for(my $i=2;$i<@ss;$i++){
		$thisSS=substr(@ss[$i],7,1);
		push(@newss,$thisSS);
	}
	$proteinLen=@newss;
	$Num_H=0;$Num_E=0;$Num_C=0;
	for($count=0;$count<@newss;$count++){
		if(@newss[$count] eq "H"){$Num_H++;}
		if(@newss[$count] eq "E"){$Num_E++;}
		if(@newss[$count] eq "C"){$Num_C++;}
	}
	printf WRITE ("%4.3f ",$Num_H/$proteinLen);
	printf WRITE ("%4.3f ",$Num_E/$proteinLen);
	printf WRITE ("%4.3f ",$Num_C/$proteinLen);
	print WRITE "\n";
	close WRITE;
}






