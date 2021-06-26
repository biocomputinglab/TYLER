#! /usr/bin/perl

open VALUE,"VALUE.txt" or die "can not open";
chomp(@VA=<VALUE>);
close VALUE;
close CYC;
open WRITE,">motifVA.txt";
for(my $i=1;$i<$length;$i+=2){
	$thisnum=0;
	if($AR[$i]=~ /W[^a-z]?Y[^a-z]?R[^a-z]?P/){$TN+=$VA[0];}
	if($AR[$i]=~ /HRDLK/){$TN+=$VA[1];}
	if($AR[$i]=~ /S[^a-z]?L[^a-z]?SS[^a-z]?S/){$TN+=$VA[2];}
	if($AR[$i]=~ /H[^a-z]?R[^a-z]?D[^a-z]?L[^a-z]?K/){$TN+=$VA[3];}
	if($AR[$i]=~ /V[^a-z]?V[^a-z]?T[^a-z]?WYR[^a-z]?P/){$TN+=$VA[4];}
	if($AR[$i]=~ /VT[^a-z]?W[^a-z]?Y[^a-z]?R/){$TN+=$VA[5];}
	if($AR[$i]=~ /DFGLA/){$TN+=$VA[6];}
	if($AR[$i]=~ /DFGL[^a-z]?A/){$TN+=$VA[7];}
	if($AR[$i]=~ /V[^a-z]?V[^a-z]?T[^a-z]?W[^a-z]?R/){$TN+=$VA[8];}
	if($AR[$i]=~ /D[^a-z]?W[^a-z]?VGC/){$TN+=$VA[9];}
	if($AR[$i]=~ /Q[^a-z]?Q[^a-z]?H[^a-z]?H/){$TN+=$VA[10];}
	if($AR[$i]=~ /YR[^a-z]?PELLL/){$TN+=$VA[11];}
	if($AR[$i]=~ /SSH[^a-z]?S/){$TN+=$VA[12];}
	if($AR[$i]=~ /LW[^a-z]?YR/){$TN+=$VA[13];}
	if($AR[$i]=~ /LWYR/){$TN+=$VA[14];}
	if($AR[$i]=~ /LW[^a-z]?Y[^a-z]?R/){$TN+=$VA[15];}
	if($AR[$i]=~ /SLSS[^a-z]?S/){$TN+=$VA[16];}
	if($AR[$i]=~ /K[^a-z]?ADFG[^a-z]?AR/){$TN+=$VA[17];}
	if($AR[$i]=~ /ADFGLAR/){$TN+=$VA[18];}
	if($AR[$i]=~ /TLWY/){$TN+=$VA[19];}
	if($AR[$i]=~ /TL[^a-z]?WY/){$TN+=$VA[20];}
	if($AR[$i]=~ /LHRDLK/){$TN+=$VA[21];}
	if($AR[$i]=~ /WYRP/){$TN+=$VA[22];}
	if($AR[$i]=~ /L[^a-z]?W[^a-z]?Y[^a-z]?R/){$TN+=$VA[23];}
	if($AR[$i]=~ /VV[^a-z]?TLW/){$TN+=$VA[24];}
	if($AR[$i]=~ /RSNS/){$TN+=$VA[25];}
	if($AR[$i]=~ /NNEN/){$TN+=$VA[26];}
	if($AR[$i]=~ /KIADF/){$TN+=$VA[27];}
	if($AR[$i]=~ /I[^a-z]?D[^a-z]?M[^a-z]?W/){$TN+=$VA[28];}
	if($AR[$i]=~ /QQHH/){$TN+=$VA[29];}
	if($AR[$i]=~ /DEDEE/){$TN+=$VA[30];}
	if($AR[$i]=~ /QTPK/){$TN+=$VA[31];}
	if($AR[$i]=~ /C[^a-z]?E[^a-z]?FS/){$TN+=$VA[32];}
	if($AR[$i]=~ /D[^a-z]?MWS/){$TN+=$VA[33];}
	if($AR[$i]=~ /C[^a-z]?EFS/){$TN+=$VA[34];}
	if($AR[$i]=~ /DMWS/){$TN+=$VA[35];}
	if($AR[$i]=~ /CEFS/){$TN+=$VA[36];}
	if($AR[$i]=~ /MHRD/){$TN+=$VA[37];}
	if($AR[$i]=~ /KLCG/){$TN+=$VA[38];}
	if($AR[$i]=~ /LMGH/){$TN+=$VA[39];}
	if($AR[$i]=~ /PQHQ/){$TN+=$VA[40];}
	if($AR[$i]=~ /DRFLS/){$TN+=$VA[41];}
	if($AR[$i]=~ /QLVG/){$TN+=$VA[42];}
	if($AR[$i]=~ /LDRFL/){$TN+=$VA[43];}
	if($AR[$i]=~ /DRYL/){$TN+=$VA[44];}
	if($AR[$i]=~ /EYRH/){$TN+=$VA[45];}
	if($AR[$i]=~ /FESP/){$TN+=$VA[46];}
	if($AR[$i]=~ /GCIF/){$TN+=$VA[47];}
	if($AR[$i]=~ /GDDD/){$TN+=$VA[48];}
	if($AR[$i]=~ /KKIK/){$TN+=$VA[49];}
	if($AR[$i]=~ /LACK/){$TN+=$VA[50];}
	if($AR[$i]=~ /LIDW/){$TN+=$VA[51];}
	if($AR[$i]=~ /LKPQ/){$TN+=$VA[52];}
	if($AR[$i]=~ /PGPE/){$TN+=$VA[53];}
	if($AR[$i]=~ /PLKP/){$TN+=$VA[54];}
	if($AR[$i]=~ /QKVQ/){$TN+=$VA[55];}
	if($AR[$i]=~ /RLNL/){$TN+=$VA[56];}
	if($AR[$i]=~ /RPPP/){$TN+=$VA[57];}
	if($AR[$i]=~ /RPST/){$TN+=$VA[58];}
	if($AR[$i]=~ /RRTS/){$TN+=$VA[59];}
	if($AR[$i]=~ /RSRT/){$TN+=$VA[60];}
	if($AR[$i]=~ /RYRR/){$TN+=$VA[61];}
	if($AR[$i]=~ /SNSQ/){$TN+=$VA[62];}
	if($AR[$i]=~ /SPVK/){$TN+=$VA[63];}
	if($AR[$i]=~ /SRRR/){$TN+=$VA[64];}
	if($AR[$i]=~ /SSHS/){$TN+=$VA[65];}
	if($AR[$i]=~ /CC[^a-z]?HC/){$TN+=$VA[66];}
	if($AR[$i]=~ /CCL[^a-z]?L/){$TN+=$VA[67];}
	if($AR[$i]=~ /CIF[^a-z]?A/){$TN+=$VA[68];}
	if($AR[$i]=~ /CIF[^a-z]?E/){$TN+=$VA[69];}
	if($AR[$i]=~ /DI[^a-z]?TN/){$TN+=$VA[70];}
	if($AR[$i]=~ /E[^a-z]?EWR/){$TN+=$VA[71];}
	if($AR[$i]=~ /E[^a-z]?IWP/){$TN+=$VA[72];}
	if($AR[$i]=~ /EME[^a-z]?D/){$TN+=$VA[73];}
	if($AR[$i]=~ /ESQ[^a-z]?S/){$TN+=$VA[74];}
	if($AR[$i]=~ /ES[^a-z]?QS/){$TN+=$VA[75];}
	if($AR[$i]=~ /E[^a-z]?SDP/){$TN+=$VA[76];}
	if($AR[$i]=~ /E[^a-z]?SPT/){$TN+=$VA[77];}
	if($AR[$i]=~ /EYR[^a-z]?H/){$TN+=$VA[78];}
	if($AR[$i]=~ /EY[^a-z]?RH/){$TN+=$VA[79];}
	if($AR[$i]=~ /GC[^a-z]?IF/){$TN+=$VA[80];}
	if($AR[$i]=~ /GCI[^a-z]?F/){$TN+=$VA[81];}
	if($AR[$i]=~ /HS[^a-z]?KR/){$TN+=$VA[82];}
	if($AR[$i]=~ /IQN[^a-z]?S/){$TN+=$VA[83];}
	if($AR[$i]=~ /ISP[^a-z]?K/){$TN+=$VA[84];}
	if($AR[$i]=~ /KR[^a-z]?SN/){$TN+=$VA[85];}
	if($AR[$i]=~ /K[^a-z]?RRI/){$TN+=$VA[86];}
	if($AR[$i]=~ /K[^a-z]?SPP/){$TN+=$VA[87];}
	if($AR[$i]=~ /K[^a-z]?STR/){$TN+=$VA[88];}
	if($AR[$i]=~ /LE[^a-z]?CA/){$TN+=$VA[89];}
	if($AR[$i]=~ /LHR[^a-z]?D/){$TN+=$VA[90];}
	if($AR[$i]=~ /LH[^a-z]?RD/){$TN+=$VA[91];}
	if($AR[$i]=~ /LK[^a-z]?PQ/){$TN+=$VA[92];}
	if($AR[$i]=~ /L[^a-z]?KPQ/){$TN+=$VA[93];}
	if($AR[$i]=~ /LW[^a-z]?YR/){$TN+=$VA[94];}
	if($AR[$i]=~ /NI[^a-z]?DT/){$TN+=$VA[95];}
	if($AR[$i]=~ /NY[^a-z]?DR/){$TN+=$VA[96];}
	if($AR[$i]=~ /P[^a-z]?SPK/){$TN+=$VA[97];}
	if($AR[$i]=~ /QL[^a-z]?LC/){$TN+=$VA[98];}
	if($AR[$i]=~ /QSS[^a-z]?P/){$TN+=$VA[99];}
	if($AR[$i]=~ /SFK[^a-z]?S/){$TN+=$VA[100];}
	if($AR[$i]=~ /S[^a-z]?FKS/){$TN+=$VA[101];}
	if($AR[$i]=~ /SH[^a-z]?RS/){$TN+=$VA[102];}
	if($AR[$i]=~ /SN[^a-z]?QN/){$TN+=$VA[103];}
	if($AR[$i]=~ /S[^a-z]?NSQ/){$TN+=$VA[104];}
	if($AR[$i]=~ /SPF[^a-z]?P/){$TN+=$VA[105];}
	if($AR[$i]=~ /SP[^a-z]?NK/){$TN+=$VA[106];}
	if($AR[$i]=~ /SPV[^a-z]?K/){$TN+=$VA[107];}
	if($AR[$i]=~ /SQS[^a-z]?N/){$TN+=$VA[108];}
	if($AR[$i]=~ /SSH[^a-z]?T/){$TN+=$VA[109];}
	if($AR[$i]=~ /S[^a-z]?TSE/){$TN+=$VA[110];}
	if($AR[$i]=~ /TL[^a-z]?WY/){$TN+=$VA[111];}
	if($AR[$i]=~ /T[^a-z]?LWY/){$TN+=$VA[112];}
	if($AR[$i]=~ /TR[^a-z]?SC/){$TN+=$VA[113];}
	if($AR[$i]=~ /WL[^a-z]?EV/){$TN+=$VA[114];}
	if($AR[$i]=~ /WLI[^a-z]?V/){$TN+=$VA[115];}
	if($AR[$i]=~ /Y[^a-z]?DDD/){$TN+=$VA[116];}
	if($AR[$i]=~ /Y[^a-z]?KKC/){$TN+=$VA[117];}
	print WRITE $TN."\n";
}
close WRITE;

open MTF,"motifVA.txt" or die "can not open";
@new=();
chomp(@motif=<MTF>);
close MTF;
open FINAL,">firstlayer.txt" or die "no open";
for(my $i=0;$i<@motif;$i++){
	if($motif[$i]==0){
		push(@new,-rand(1));
	}
	else{push(@new,$motif[$i])};
}
foreach my $num(@new){
	print FINAL $num."\n";
}

close FINAL;





