#! /usr/bin/perl


for($cn=0;$cn<@file;$cn++){

	open SS,"$taskID/SS/$cn.ss2" or die "can not open";
	chomp(@ss=<SS>);
	close SS;

	@newss=();
	open WRITE,">$taskID/cache/secondstruct/$cn.txt" or die "can not open";
	for(my $tempindex=2;$tempindex<@ss;$tempindex++){
		$thisSS=substr(@ss[$tempindex],7,1);
		push(@newss,$thisSS);
	}

	for($count=0;$count<@newss;$count++){
		print WRITE @newss[$count];
	}
	print WRITE "\n";
	close WRITE;
	
	
	@FR=();
	open FRAG,"$taskID/cache/secondstruct/$cn.txt" or die "can not open";
	chomp($firstline=<FRAG>);
	close FRAG;
	$locate=0;
	@struct=split(//,$firstline);
	for ($ck=0;$ck<@struct;$ck++){
		if(@struct[$ck] eq @struct[$ck+1]){
			;
		}else{
			$frag=substr($firstline,$locate,$ck+1-$locate);
			push(@FR,$frag);	
			$locate=$ck+1;
		}
	}
	
	$H_frag=0;$E_frag=0;$C_frag=0;
	$len=0;
	
	open FRAG,">$taskID/cache/FR/$cn.txt";
	for($j=0;$j<@FR;$j++){
		print FRAG @FR[$j]."\n";
		if(@FR[$j]=~ /C/ && length(@FR[$j])>1){
		$C_frag++;
		$len++;}
		if(@FR[$j]=~ /H/){
		$H_frag++;
		$len++;}
		if(@FR[$j]=~ /E/){
		$E_frag++;
		$len++}
	}
	close FRAG;
	
	
	open WRITE,">$taskID/fragpercent/$cn.txt";
	printf WRITE ("%4.3f ",$C_frag/$len);
	printf WRITE ("%4.3f ",$H_frag/$len);
	printf WRITE ("%4.3f ",$E_frag/$len);
	print WRITE "\n";
	close WRITE;
	
}

























