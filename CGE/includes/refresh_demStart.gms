sets
COM
AY
FS
FT
FH
H
;
parameters
MFHHT(FH,H,AY) reverse mapping (TIMES to CGE) for households
SFORE_X(FS,AY)           GDP by SATIM sector for sim XC
TFHPOP_X(FH,AY)          Population by SATIM income group for sim XC
SIM_DEMX(COM,AY)               Demand extracted from excel
PKMFH(FT,FH,AY)             Passenger km demand share by income group
Passengerkm(COM,AY)       Pkm for passenger transport
Tonkm(COM,AY)             Tonkm for Freight transport

;

$gdxin baselinked.gdx
$load COM AY FS FH FT H

$GDXout mcdem_start.gdx
$unload MFHHT SFORE_X TFHPOP_X SIM_DEMX PKMFH Passengerkm Tonkm;