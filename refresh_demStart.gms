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
SIM_DEMX(COM,AY)         Demand extracted from excel
PKMFH(FT,FH,AY)          Passenger km demand share by income group
Passengerkm(COM,AY)      Pkm for passenger transport
Tonkm(COM,AY)            Tonkm for Freight transport
;

$gdxin REF_LEO_Coal.gdx
$load COM AY FS FH FT SFORE_X TFHPOP_X

$call   "gdxxrw i=C:\SATIMGE_03\SATM\DMD_PRJ.xlsx o=dmd_prj_tempcge.gdx index=Index_CGE!a6"
$gdxin  dmd_prj_tempcge.gdx
$load H

$call   "gdxxrw i=C:\SATIMGE_03\SATM\DMD_PRJ.xlsx o=dmd_prj_temp.gdx index=Index_E2G!a6"
$gdxin  dmd_prj_temp.gdx
$load SIM_DEMX PKMFH Passengerkm Tonkm MFHHT

$GDXout mcdem_start.gdx
$unload MFHHT SFORE_X TFHPOP_X SIM_DEMX PKMFH Passengerkm Tonkm
