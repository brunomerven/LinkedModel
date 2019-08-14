$call "gdxxrw i=%aggregate% o=aggregate.gdx index=index!a6"
$gdxin aggregate.gdx

SET
 DAC              disaggregated SAM accounts
 AAAC             aggregated SAM accounts
 MAD(AAAC,DAC)    mapping: aggregated and disaggregated accounts
;

$load AAAC DAC
$loaddc MAD

ALIAS (AAAC,AAACP), (DAC,DACP);

PARAMETER
 DSAM(DAC,DACP)          disaggregated SAM
 AASAM(AAAC,AAACP)       aggregated SAM
;

$loaddc DSAM

*Sum disaggregated accounts into aggregated accounts
 AASAM(AAAC,AAACP) = SUM((DAC,DACP)$(MAD(AAAC,DAC) AND MAD(AAACP,DACP)), DSAM(DAC,DACP));

PARAMETER
 DDIFF(DAC)      check difference in disaggregated SAM
 ADIFF(AAAC)      check difference in aggregated SAM
;

*Remove totals from SAMs
 DSAM(DAC,'TOTAL') = 0;
 DSAM('TOTAL',DAC) = 0;
 AASAM(AAAC,'TOTAL') = 0;
 AASAM('TOTAL',AAAC) = 0;

*Calculate new totals
 DSAM(DAC,'TOTAL') = SUM(DACP, DSAM(DAC,DACP));
 DSAM('TOTAL',DAC) = SUM(DACP, DSAM(DACP,DAC));
 AASAM(AAAC,'TOTAL') = SUM(AAACP, AASAM(AAAC,AAACP));
 AASAM('TOTAL',AAAC) = SUM(AAACP, AASAM(AAACP,AAAC));

*Calculate row and column differences
 DDIFF(DAC) = DSAM(DAC,'TOTAL') - DSAM('TOTAL',DAC);
 ADIFF(AAAC) = AASAM(AAAC,'TOTAL') - AASAM('TOTAL',AAAC);

*Ignore very small imbalances
 DDIFF(DAC)$(ABS(DDIFF(DAC)) LT 1E-6) = 0;
 ADIFF(AAAC)$(ABS(ADIFF(AAAC)) LT 1E-6) = 0;

DISPLAY DDIFF, ADIFF;

PARAMETER XLTEST;

execute_unload "aggregate.gdx" AASAM
execute 'xlstalk.exe -m %aggregate%';
 XLTEST = ERRORLEVEL;
IF(XLTEST = 1,
execute 'xlstalk.exe -c %aggregate%';
);
IF(XLTEST = 2,
execute 'xlstalk.exe -s %aggregate%';
);
execute 'gdxxrw.exe i=aggregate.gdx o=%aggregate% index=index!a20';

execute_unload "aenergy.gdx" AASAM
execute 'xlstalk.exe -m %energy%';
 XLTEST = ERRORLEVEL;
IF(XLTEST = 1,
execute 'xlstalk.exe -c %energy%';
);
IF(XLTEST = 2,
execute 'xlstalk.exe -s %energy%';
);
execute 'gdxxrw.exe i=aenergy.gdx o=%energy% index=index!a2';
