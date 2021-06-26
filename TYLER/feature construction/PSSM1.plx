#! /usr/bin/perl


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
    for (my $i=0; $i<20;$i++)
    {
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
$result="0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 ";
}
	else{
	for(my $i=0;$i<@newresult;$i++){
	$result.=$newresult[$i]." ";
}	
}
	return $result;
}
for($cn=0;$cn<@file;$cn++){

open PSSM,"$taskID/PSSM/$cn.pssm" or die "can not open";
open FASTA,"$taskID/fastas/$cn.txt" or die "can not open fasts";
chomp(@pssm=<PSSM>);
close PSSM;
open PSSM,">$taskID/cache/pssm/$cn.txt";
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

@residue=split(//,@fasta[1]);
$A_NUM=0;$C_NUM=0;$D_NUM=0;$E_NUM=0;$F_NUM=0;$G_NUM=0;$H_NUM=0;$I_NUM=0;$K_NUM=0;$L_NUM=0;
$M_NUM=0;$N_NUM=0;$P_NUM=0;$Q_NUM=0;$R_NUM=0;$S_NUM=0;$T_NUM=0;$V_NUM=0;$W_NUM=0;$Y_NUM=0;
@A=();@C=();@D=();@E=();@F=();@G=();@H=();@I=();@K=();@L=();@M=();@N=();@P=();@Q=();@R=();@S=();@T=();@V=();@W=();@Y=();


for(my $index=0;$index<@residue;$index++){
	if(@RE[$index] eq 'A'){$A_NUM++;}	
	if(@RE[$index] eq 'C'){$C_NUM++;}	
	if(@RE[$index] eq 'D'){$D_NUM++;}
	if(@RE[$index] eq 'E'){$E_NUM++;}
	if(@RE[$index] eq 'F'){$F_NUM++;}
	if(@RE[$index] eq 'G'){$G_NUM++;}
	if(@RE[$index] eq 'H'){$H_NUM++;}
	if(@RE[$index] eq 'I'){$I_NUM++;}
	if(@RE[$index] eq 'K'){$K_NUM++;}
	if(@RE[$index] eq 'L'){$L_NUM++;}
	if(@RE[$index] eq 'M'){$M_NUM++;}
	if(@RE[$index] eq 'N'){$N_NUM++;}
	if(@RE[$index] eq 'P'){$P_NUM++;}
	if(@RE[$index] eq 'Q'){$Q_NUM++;}
	if(@RE[$index] eq 'R'){$R_NUM++;}
	if(@RE[$index] eq 'S'){$S_NUM++;}
	if(@RE[$index] eq 'T'){$T_NUM++;}
	if(@RE[$index] eq 'V'){$V_NUM++;}
	if(@RE[$index] eq 'W'){$W_NUM++;}
	if(@RE[$index] eq 'Y'){$Y_NUM++;}
}

open PSSM,"$taskID/cache/pssm/$cn.txt" or die "can not open";
chomp(@array=<PSSM>);
close PSSM;
for(my $index=0;$index<@RE;$index++){
	if(@RE[$index] eq 'A'){
	@thisarr=split(/\s+/,@array[$index]);
	@A=add(\@A,\@thisarr);
}
	if(@RE[$index] eq 'C'){
	@thisarr=split(/\s+/,@array[$index]);
	@C=add(\@C,\@thisarr);

}
	if(@RE[$index] eq 'D'){
	@thisarr=split(/\s+/,@array[$index]);
	@D=add(\@D,\@thisarr);
}
	if(@RE[$index] eq 'E'){
	@thisarr=split(/\s+/,@array[$index]);
	@E=add(\@E,\@thisarr);
}
	if(@RE[$index] eq 'F'){
	@thisarr=split(/\s+/,@array[$index]);
	@F=add(\@F,\@thisarr);
}	
	if(@RE[$index] eq 'G'){
	@thisarr=split(/\s+/,@array[$index]);
	@G=add(\@G,\@thisarr);
}
	if(@RE[$index] eq 'H'){
	@thisarr=split(/\s+/,@array[$index]);
	@H=add(\@H,\@thisarr);
}
	if(@RE[$index] eq 'I'){
	@thisarr=split(/\s+/,@array[$index]);
	@I=add(\@I,\@thisarr);
}
	if(@RE[$index] eq 'K'){
	@thisarr=split(/\s+/,@array[$index]);
	@K=add(\@K,\@thisarr);
}
	if(@RE[$index] eq 'L'){
	@thisarr=split(/\s+/,@array[$index]);
	@L=add(\@L,\@thisarr);
}
	if(@RE[$index] eq 'M'){
	@thisarr=split(/\s+/,@array[$index]);
	@M=add(\@M,\@thisarr);
}
	if(@RE[$index] eq 'N'){
	@thisarr=split(/\s+/,@array[$index]);
	@N=add(\@N,\@thisarr);
}
	if(@RE[$index] eq 'P'){
	@thisarr=split(/\s+/,@array[$index]);
	@P=add(\@P,\@thisarr);
}
	if(@RE[$index] eq 'Q'){
	@thisarr=split(/\s+/,@array[$index]);
	@Q=add(\@Q,\@thisarr);
}	
	if(@RE[$index] eq 'R'){
	@thisarr=split(/\s+/,@array[$index]);
	@R=add(\@R,\@thisarr);
}
	if(@RE[$index] eq 'S'){
	@thisarr=split(/\s+/,@array[$index]);
	@S=add(\@S,\@thisarr);
}
	if(@RE[$index] eq 'T'){
	@thisarr=split(/\s+/,@array[$index]);
	@T=add(\@T,\@thisarr);
}
	if(@RE[$index] eq 'V'){
	@thisarr=split(/\s+/,@array[$index]);
	@V=add(\@V,\@thisarr);
}
	if(@RE[$index] eq 'W'){
	@thisarr=split(/\s+/,@array[$index]);
	@W=add(\@W,\@thisarr);
}
	if(@RE[$index] eq 'Y'){
	@thisarr=split(/\s+/,@array[$index]);
	@Y=add(\@Y,\@thisarr);
}


}
open PSSM,">$taskID/pssm400/$cn.txt";
$A_str=addfeature(\@A,\$A_NUM);print PSSM $A_str;
$C_str=addfeature(\@C,\$C_NUM);print PSSM $C_str;
$D_str=addfeature(\@D,\$D_NUM);print PSSM $D_str;
$E_str=addfeature(\@E,\$E_NUM);print PSSM $E_str;
$F_str=addfeature(\@F,\$F_NUM);print PSSM $F_str;
$G_str=addfeature(\@G,\$G_NUM);print PSSM $G_str;
$H_str=addfeature(\@H,\$H_NUM);print PSSM $H_str;
$I_str=addfeature(\@I,\$I_NUM);print PSSM $I_str;
$K_str=addfeature(\@K,\$K_NUM);print PSSM $K_str;
$L_str=addfeature(\@L,\$L_NUM);print PSSM $L_str;
$M_str=addfeature(\@M,\$M_NUM);print PSSM $M_str;
$N_str=addfeature(\@N,\$N_NUM);print PSSM $N_str;
$P_str=addfeature(\@P,\$P_NUM);print PSSM $P_str;
$Q_str=addfeature(\@Q,\$Q_NUM);print PSSM $Q_str;
$R_str=addfeature(\@R,\$R_NUM);print PSSM $R_str;
$S_str=addfeature(\@S,\$S_NUM);print PSSM $S_str;
$T_str=addfeature(\@T,\$T_NUM);print PSSM $T_str;
$V_str=addfeature(\@V,\$V_NUM);print PSSM $V_str;
$W_str=addfeature(\@W,\$W_NUM);print PSSM $W_str;
$Y_str=addfeature(\@Y,\$Y_NUM);print PSSM $Y_str;
close PSSM;

}

