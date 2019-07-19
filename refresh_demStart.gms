sets
COM
AY
FS
FT
FH
H
MFHHT(FH,H,AY) reverse mapping (TIMES to CGE) for households
;
parameters
SFORE_X(FS,AY)           GDP by SATIM sector for sim XC
TFHPOP_X(FH,AY)          Population by SATIM income group for sim XC
SIM_DEMX(COM,AY)               Demand extracted from excel
PKMFH(FT,FH,AY)             Passenger km demand share by income group
Passengerkm(COM,AY)       Pkm for passenger transport
Tonkm(COM,AY)             Tonkm for Freight transport

;

$gdxin FreightUcon_NB6C.gdx
$load COM AY FS FH FT H MFHHT SFORE_X TFHPOP_X SIM_DEMX Passengerkm Tonkm

$call   "gdxxrw i=SATM\DMD_PRJ.xlsx o=dmd_prj_temp.gdx index=Index_E2G!a6"
$gdxin  dmd_prj_temp.gdx
$load PKMFH

$GDXout mcdem_start.gdx
$unload MFHHT SFORE_X TFHPOP_X SIM_DEMX PKMFH Passengerkm Tonkm
