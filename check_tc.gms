SETS
AY  all years
FS  SATIM sectors
;


PARAMETERS
SFORE_X(FS,AY)
result(FS)

;

$gdxin w_ifa_cre.gdx
$loaddc FS AY
$load SFORE_X

if(SFORE_X('COM','2050'),
result(FS) = SFORE_X(FS,'2021');

);


