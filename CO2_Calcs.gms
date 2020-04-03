* Code to calculate CO2 for SATIM (and eSAGE) given SATIM_OUTPUT and INTX and QHX
$SETGLOBAL referencerun REF_EV-IN_RB-ZERO

Sets
  RUN                            simulations
  INCLRUN(RUN)                        whether to include or not run in batch
  GDXFile                        GDX file per simulation /NoLink_EV-IN, REF_EV-IN_RB-ZERO,REF_EV-IN_RB-0-25,REF_EV-IN_RB-0-5,REF_EV-OUT_RB-ZERO,REF_EV-OUT_RB-0-25,REF_EV-OUT_RB-0-5 /
*  GDXFile                        GDX file per simulation /REF_EV-IN_RB-ZERO,REF_EV-OUT_RB-ZERO/
  MGDXRUN(GDXFile,RUN)           Map of RUN and GDX file
* SATIM sets
  REG                            TIMES regions    /REGION1/
  ALLYEAR                        All Years
  T(ALLYEAR)                     Time periods
  V(ALLYEAR)                     Vintage
  S                              TIMES timeslices
  PRC                            TIMES Processes
  P(PRC)                         Processes
  COM                            TIMES Commodities
  X                       simulations
  XC(X)                   active simulations
  TC(T)                   active time periods
*Times model sets
  TT(T)                   TIMES model years
  IN_OUT flow direction /IN, OUT/
  SATIM_IND /Activity, Capacity, NewCapacity, FlowIn, FlowOut, CO2C, CO2P, CO2F, Investment, GVA, Employment/
  HH_EI Household Energy Indicators
  C                   commodities
  H               households
  MOD models /SATIM, eSAGE/
;

Parameters
  SATIM_OUTPUT(PRC,COM,TC,SATIM_IND,RUN) SATIM indicators by run and activity
  SATIM_OUTPUT2(PRC,COM,TC,SATIM_IND,GDXFile) SATIM indicators by run and activity
  HH_Energy(MOD,HH_EI,C,TC,RUN) Household energy consumption
  HH_Energy2(MOD,HH_EI,C,TC,GDXFile) Household energy consumption
  QHX(C,H,X,T,TT)                  qnty consumed of market commodity c by household h

  EmisFactor(COM) Combustion Emission Factor


;

$gdxin  %referencerun%.gdx
$load PRC P COM ALLYEAR S V T X XC TC TT RUN HH_EI H C

$call   "gdxxrw i=EmissionFactors.xlsx o=EmisFac index=Index!a6 checkdate"
$gdxin  EmisFac.gdx
$load EmisFactor

MGDXRUN('NoLink_EV-IN','REF2019-UCE-L') = YES;
MGDXRUN('REF_EV-IN_RB-ZERO','REF2019-UCE-L') = YES;
MGDXRUN('REF_EV-IN_RB-0-25','REF2019-UCE-L') = YES;
MGDXRUN('REF_EV-IN_RB-0-5','REF2019-UCE-L') = YES;
MGDXRUN('REF_EV-OUT_RB-ZERO','TRAPES-UCE-L') = YES;
MGDXRUN('REF_EV-OUT_RB-0-25','TRAPES-UCE-L') = YES;
MGDXRUN('REF_EV-OUT_RB-0-5','TRAPES-UCE-L') = YES;



FILE SATIM_Scen;

LOOP(GDXFile,

put_utilities SATIM_Scen 'gdxin' / GDXFile.TL:20;

execute_load SATIM_OUTPUT HH_Energy;
Loop(RUN,
SATIM_OUTPUT2(PRC,COM,TC,SATIM_IND,GDXFile)$MGDXRUN(GDXFile,RUN) = SATIM_OUTPUT(PRC,COM,TC,SATIM_IND,RUN);
HH_Energy2(MOD,HH_EI,C,TC,GDXFile)$MGDXRUN(GDXFile,RUN) = HH_Energy(MOD,HH_EI,C,TC,RUN);
);

SATIM_OUTPUT2(PRC,COM,TC,'CO2C',GDXFile) = SATIM_OUTPUT2(PRC,COM,TC,'FlowIn',GDXFile)*EmisFactor(COM);

SATIM_OUTPUT2(PRC,'ACTGRP',TC,'CO2C',GDXFile) = SATIM_OUTPUT2(PRC,'UPSCO2S',TC,'FlowOut',GDXFile)+
                                     SATIM_OUTPUT2(PRC,'UPSCH4S',TC,'FlowOut',GDXFile)*25;
SATIM_OUTPUT2(PRC,'ACTGRP',TC,'CO2P',GDXFile) = SATIM_OUTPUT2(PRC,'CO2SP',TC,'FlowOut',GDXFile);
SATIM_OUTPUT2(PRC,'ACTGRP',TC,'CO2F',GDXFile) = SATIM_OUTPUT2(PRC,'CO2SF',TC,'FlowOut',GDXFile)+SATIM_OUTPUT2(PRC,'CH4SF',TC,'FlowOut',GDXFile)*25;


);

execute_unload "SATIM_OUTPUT.gdx" SATIM_OUTPUT2
execute 'gdxxrw.exe i=SATIM_OUTPUT.gdx o=.\Tableau\SATIM_OUTPUT.xlsx index=index!a6';

execute_unload "HH_En.gdx" HH_Energy2
execute 'gdxxrw.exe i=HH_En.gdx o=.\Tableau\Private_Transport_Results_v00.xlsx index=index!a6';
