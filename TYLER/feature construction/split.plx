#! /usr/bin/perl

$flag=-1;
while($EA=<READ>){
	chomp($EA);
	if($EA =~ /^>/){
		$flag=$flag+1;
		print NAME $EA."\n";
		open FASTA,">$taskID/orgifastas/$flag.txt";
		print FASTA $EA."\n";
		close FASTA;
	}else{
		open FASTA,">>$taskID/orgifastas/$flag.txt";
		print FASTA $EA."\n";
		close FASTA;
	}
}
close READ;
close NAME;


opendir DIR,"$taskID/orgifastas" or die "Cannot open $dir:$!\n";
@file = ();
while(defined($file = readdir(DIR))){
    next if $file =~ /^\.\.?$/;# delete . and .. in the file
    if ($file =~ m/\./){$FL = $`;}
    push(@file,$FL);
}
closedir DIR;


for($cn=0;$cn<@file;$cn++){

	open FASTA,"$taskID/orgifastas/$cn.txt";
	chomp(@array=<FASTA>);
	close FASTA;

	@callen=split(//,@array[1]);

	$length=0;$templen=0;
	for($temp=0;$temp<@callen;$temp++){
		if(@callen[$temp] =~ /[A-Z]/){$templen++;}
	}
	$length=$templen;

	$proID=@array[0];
	@AA=split(//,@array[1]);
	
	open WRITE,">$taskID/fastas/$cn.txt";
	print WRITE $proID."\n";
	for($cm=0;$cm<$length;$cm++){
		if(@AA[$cm] =~ /B|J|O|U|X|Z/){
			print WRITE "C";
		}else{
			print WRITE @AA[$cm];
		}
	}
	print WRITE "\n";
	close WRITE;
}
