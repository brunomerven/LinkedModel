sets
  MOD models /SATIM, eSAGE/
  QType quantitity types /qq, qd, qint, qe, qm, qh, qx, qxac/
  IN_OUT flow direction /IN, OUT/

;

parameters
 BalanceCheck(QType,C,TC,RUN) balance check

 EBCHECK(MOD,FSATIM,IN_OUT,C,TC,TT,RUN) Final Energy Demand for SATIM sectors in SATIM and eSAGE models

 EIntensity(MOD,FSATIM,C,TC,TT,RUN) Energy Intensity in SATIM and ESAGE models

;
