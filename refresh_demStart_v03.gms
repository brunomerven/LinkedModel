sets
A
COM
AY
FS
FT
FH
H
TT
TC(AY)
XC
MFHHT(FH,H,AY) reverse mapping (TIMES to CGE) for households
MFSA(FS,A)
;
parameters
QAX(A,XC,TC,TT)
SFORE_X(FS,TC)           GDP by SATIM sector for sim XC
TFHPOP_X(FH,TC)          Population by SATIM income group for sim XC
SIM_DEMX(COM,AY)               Demand extracted from excel
PKMFH(FT,FH,AY)             Passenger km demand share by income group
Passengerkm(COM,AY)       Pkm for passenger transport
Tonkm(COM,AY)             Tonkm for Freight transport

;
file mcdem_start2;
$gdxin starttest.gdx
$load  XC AY TT TC A QAX COM FS FH FT H MFHHT MFSA TFHPOP_X SFORE_X SIM_DEMX Passengerkm Tonkm

$call   "gdxxrw i=SATM\DMD_PRJ.xlsx o=dmd_prj_temp.gdx index=Index_E2G!a6 checkdate"
$gdxin  dmd_prj_temp.gdx
$load PKMFH



$GDXout mcdem_start2.gdx
$unload MFHHT TFHPOP_X SFORE_X SIM_DEMX PKMFH Passengerkm Tonkm
*put_utilities mcdem_start2 'gdxout' / mcdem_start2;
*execute_unload SFORE_X;
