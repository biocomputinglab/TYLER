#! /usr/bin/perl


for($cn=0;$cn<@file;$cn++){
	open READ,"$taskID/fastas/$cn.txt";
	chomp(@array=<READ>);
	close READ;

	$hydroxylic=0;$tiny=0;$small=0;$acidic=0;$positive=0;$polar=0;
	$charged=0;$hydrophobic=0;$aromatic=0;$sulphur=0;$aliphatic=0;

	@callen=split(//,@array[1]);
	$length=0;$templen=0;
	for($temp=0;$temp<@callen;$temp++){
		if(@callen[$temp] =~ /[A-Z]/){$templen++;}
	}
	$length=$templen;
	
	@AAs=split(//,@array[1]);
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
	
	open WRITE,">$taskID/PCproperty/$cn.txt";
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
	print WRITE "\n";
	close WRITE;
}














