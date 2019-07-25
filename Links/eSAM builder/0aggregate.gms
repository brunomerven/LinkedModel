
$ONEMPTY

$SETGLOBAL aggregate "1rsaaggregate2012.xlsx"

$SETGLOBAL energy "2rsaenergy2012.xlsx"

$call "gdxxrw i=%aggregate% o=aggregate.gdx index=index!a6"
$gdxin aggregate.gdx

SET
 DAC             disaggregated SAM accounts
 AAC             aggregated SAM accounts
 MAD(AAC,DAC)    mapping: aggregated and disaggregated accounts
;

$load AAC DAC
$loaddc MAD

ALIAS (AAC,AACP), (DAC,DACP);

PARAMETER
 DSAM(DAC,DACP)  disaggregated SAM
 ASAM(AAC,AACP)  aggregated SAM
;

$loaddc DSAM

*Sum disaggregated accounts into aggregated accounts
 ASAM(AAC,AACP) = SUM((DAC,DACP)$(MAD(AAC,DAC) AND MAD(AACP,DACP)), DSAM(DAC,DACP));

PARAMETER
 DDIFF(DAC)      check difference in disaggregated SAM
 ADIFF(AAC)      check difference in aggregated SAM
;

*Remove totals from SAMs
 DSAM(DAC,'TOTAL') = 0;
 DSAM('TOTAL',DAC) = 0;
 ASAM(AAC,'TOTAL') = 0;
 ASAM('TOTAL',AAC) = 0;

*Calculate new totals
 DSAM(DAC,'TOTAL') = SUM(DACP, DSAM(DAC,DACP));
 DSAM('TOTAL',DAC) = SUM(DACP, DSAM(DACP,DAC));
 ASAM(AAC,'TOTAL') = SUM(AACP, ASAM(AAC,AACP));
 ASAM('TOTAL',AAC) = SUM(AACP, ASAM(AACP,AAC));

*Calculate row and column differences
 DDIFF(DAC) = DSAM(DAC,'TOTAL') - DSAM('TOTAL',DAC);
 ADIFF(AAC) = ASAM(AAC,'TOTAL') - ASAM('TOTAL',AAC);

*Ignore very small imbalances
 DDIFF(DAC)$(ABS(DDIFF(DAC)) LT 1E-6) = 0;
 ADIFF(AAC)$(ABS(ADIFF(AAC)) LT 1E-6) = 0;

DISPLAY DDIFF, ADIFF;

PARAMETER XLTEST;

execute_unload "aggregate.gdx" ASAM
execute 'xlstalk.exe -m %aggregate%';
 XLTEST = ERRORLEVEL;
IF(XLTEST = 1,
execute 'xlstalk.exe -c %aggregate%';
);
IF(XLTEST = 2,
execute 'xlstalk.exe -s %aggregate%';
);
execute 'gdxxrw.exe i=aggregate.gdx o=%aggregate% index=index!a20';

execute_unload "energy.gdx" ASAM
execute 'xlstalk.exe -m %energy%';
 XLTEST = ERRORLEVEL;
IF(XLTEST = 1,
execute 'xlstalk.exe -c %energy%';
);
IF(XLTEST = 2,
execute 'xlstalk.exe -s %energy%';
);
execute 'gdxxrw.exe i=energy.gdx o=%energy% index=index!a2';








