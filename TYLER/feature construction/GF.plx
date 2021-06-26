#! /usr/bin/perl
use List::Util qw/max min/;

open FEATURE,">allfeatrues.txt" or die "can not open";
for($cn=0;$cn<@file;$cn++){
	open PC,"$taskID/PCproperty/$cn.txt" or die "can not open";
	chomp($only=<PC>);
	print FEATURE $only;
	close PC;
	open CHE,"$taskID/C_H_Epercent/$cn.txt" or die "can not open";
	chomp($only=<CHE>);
	print FEATURE $only;
	close CHE;
	open FRAG,"$taskID/fragpercent/$cn.txt" or die "can not open";
	chomp($only=<FRAG>);
	print FEATURE $only;
	close FRAG;
	open MOTIF,"$taskID/Motifpercent/$cn.txt" or die "can not open";
	chomp($only=<MOTIF>);
	print FEATURE $only;
	close MOTIF;
	open MAX1,"$taskID/maxpiptidepercent/$cn.txt" or die "can not open";
	chomp($only=<MAX1>);
	print FEATURE $only;
	close MAX1;
	open MAX2,"$taskID/maxmotifpercent/$cn.txt" or die "can not open";
	chomp($only=<MAX2>);
	print FEATURE $only;
	close MAX2;
	open PSSM,"$taskID/pssm121/$cn.txt" or die "can not open";
	chomp($only=<PSSM>);
	print FEATURE $only;
	close PSSM;
	print FEATURE "\n";
}
close FEATURE;
sub maxmin
{
	my @arr1 =  @{$_[0]};
	my $max=max @arr1;
	my $min=min @arr1;
	my @maxmin;
	my @result;
	@maxmin=map{($_-$min)/($max-$min)} @arr1;
	for (my $i=0;$i<@maxmin;$i++){
		push(@result,sprintf("%.4f",$maxmin[$i]));
	}
	return @result;
}
open FEATURE,"allfeatrues.txt" or die "can't open";
open MAXMIN,">maxminFeatures.txt";
while(chomp($eachline=<FEATURE>)){
	@eachline=split(/\s+/,$eachline);
	@feature=maxmin(\@eachline);
	foreach my $num (@feature){
		print MAXMIN $num." "; 
	}
	print MAXMIN "\n";	
}

close MAXMIN;
close FEATURE;





