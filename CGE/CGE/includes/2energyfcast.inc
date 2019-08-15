*---------------------------------------------------------------
*ESTIMATE DEMAND FORECAST
*---------------------------------------------------------------

* Previous: SFORE(FS,XC,T) = SUM((A,RD)$MFSA(FS,A), PVA0(A,RD)*QVAX(A,RD,XC,T,TT));
* changed to output as that's the main driver
* SFORE(FS,XC,T) = SUM(A$MFSA(FS,A), QVAX(A,'nat',XC,T,TT));
 SFORE(FS,XC,T) = SUM(A$MFSA(FS,A), QAX(A,XC,T,TT));

 HFORE(FH,XC,TC)$SUM(H$MFHH(FH,H), HPOPX(H,XC,TC,TT)) = SUM(H$MFHH(FH,H), YIX(H,XC,TC,TT)/HPOPX(H,XC,TC,TT))/CPIX(XC,TC,TT);
 PFORE(FH,XC,TC) = SUM(H$MFHH(FH,H), HPOPX(H,XC,TC,TT));

 sumSFORE = SUM(FS,SFORE(FS,XC,'2012'));
*INCOME CALCULATIONS

*Calculate mean (assume uniform population distribution within each group)
 FHMM(FH,'MEAN')$FHMM(FH,'MAX') = (FHMM(FH,'MAX') + FHMM(FH,'MIN'))/2;

*Forecast mean incomes based on TIMES data
 FHMEAN(FH,T) = FHMM(FH,'MEAN') * HFORE(FH,XC,T);

*POPULATION CALCULATIONS

 FHMMB(FH,'MIN',TC)$SUM(T1, HFORE(FH,XC,T1)) = FHMM(FH,'MIN') * HFORE(FH,XC,TC)/SUM(T1, HFORE(FH,XC,T1));
 FHMMB(FH,'MAX',TC)$SUM(T1, HFORE(FH,XC,T1)) = FHMM(FH,'MAX') * HFORE(FH,XC,TC)/SUM(T1, HFORE(FH,XC,T1));

*Lowest group to highest group
 FHMOVE('HHD-LE','HHD-HE',TC)
         = (FHMMB('HHD-LE','MAX',TC) - FHMM('HHD-HE','MIN'))
         / (FHMMB('HHD-LE','MAX',TC) - FHMMB('HHD-LE','MIN',TC));
 FHMOVE('HHD-LE','HHD-HE',TC)$(FHMOVE('HHD-LE','HHD-HE',TC) LT 0) = 0;

*Lowest group to middle group
 FHMOVE('HHD-LE','HHD-ME',TC)
         = (FHMMB('HHD-LE','MAX',TC) - FHMM('HHD-ME','MIN'))
         / (FHMMB('HHD-LE','MAX',TC) - FHMMB('HHD-LE','MIN',TC))
         - FHMOVE('HHD-LE','HHD-HE',TC);

*Middle group to highest group
 FHMOVE('HHD-ME','HHD-HE',TC)$(FHMMB('HHD-ME','MIN',TC) LT FHMM('HHD-HE','MIN'))
         = (FHMMB('HHD-ME','MAX',TC) - FHMM('HHD-HE','MIN'))
         / (FHMMB('HHD-ME','MAX',TC) - FHMMB('HHD-ME','MIN',TC));
 FHMOVE('HHD-ME','HHD-HE',TC)$(FHMMB('HHD-ME','MIN',TC) GT FHMM('HHD-HE','MIN')) = 1;
 FHMOVE('HHD-ME','HHD-HE',TC)$(FHMOVE('HHD-ME','HHD-HE',TC) LT 0) = 0;

*Final population numbers
 TFHPOP('HHD-LE',XC,TC) = PFORE('HHD-LE',XC,TC) *
         (1 - FHMOVE('HHD-LE','HHD-ME',TC) - FHMOVE('HHD-LE','HHD-HE',TC));

 TFHPOP('HHD-ME',XC,TC) = PFORE('HHD-ME',XC,TC) *
         (1 - FHMOVE('HHD-ME','HHD-HE',TC))
         + FHMOVE('HHD-LE','HHD-ME',TC)*PFORE('HHD-LE',XC,TC);

 TFHPOP('HHD-HE',XC,TC) = PFORE('HHD-HE',XC,TC)
         + FHMOVE('HHD-LE','HHD-HE',TC)*PFORE('HHD-LE',XC,TC)
         + FHMOVE('HHD-ME','HHD-HE',TC)*PFORE('HHD-ME',XC,TC);

*INCOME CALCULATIONS (CONT)

loop (H,
 popval(H,XC,TC) =  (sum(FH,TFHPOP(FH,XC,TC))/10)*ORD(H)*popvalfact(H,XC,TC);
 );

*Reverse mapping
 MFHHT(FH,H,TC)=no;
 MFHHT('hhd-le',H,TC)$((popval(H,XC,TC) LE TFHPOP('hhd-le',XC,TC)))=YES;
 MFHHT('hhd-me',H,TC)$(((popval(H,XC,TC) GT TFHPOP('hhd-le',XC,TC)) and (popval(H,XC,TC) LE (TFHPOP('hhd-le',XC,TC)+TFHPOP('hhd-me',XC,TC)))))=YES;
 MFHHT('hhd-he',H,TC)$((popval(H,XC,TC) GT (TFHPOP('hhd-me',XC,TC)+TFHPOP('hhd-le',XC,TC))))=YES;

 HFORE(FH,XC,TC)$SUM(H$MFHHT(FH,H,TC), HPOPX(H,XC,TC,TT)) = SUM(H$MFHHT(FH,H,TC), YIX(H,XC,TC,TT)/HPOPX(H,XC,TC,TT))/CPIX(XC,TC,TT);



*Electricity Demand -------------------------------
*   Only used when non-electricity sectors are not used in TIMES (i.e., power sector only)

$ontext
 Historical and initial years: use external (IRP) demand forecast
 Subsequent years: use GDP estimates to derive forecast
 Past years estimates: remain unchange
 Idea: If real electricity price is falling then supply less, electricity price is rising then supply more
$offtext

*IF(TT1(TT),

*   EPROJ(A,XC,TC,TT) = IFORE(TC,A);
*ELSE


  IF(SATIMODE EQ 1,

* remove these lines below when running with TC > 2040
* remove all lines below with '2040' to run to 2050
*    SFORE(FS,XC,MYPTC) = SFORE(FS,XC,'2040');
*    HPOPX(H,XC,MYPTC,TT) = HPOPX(H,XC,'2040',TT);
*    TFHPOP(FH,XC,MYPTC) = TFHPOP(FH,XC,'2040');

* remember to update HFORE with new mappings
*    HFORE(FH,XC,MYPTC) = HFORE(FH,XC,'2040');

    SFORE_X(FS,T) = SFORE(FS,XC,T);
    GDP_FSX(FS,MILESTONYR) = SFORE(FS,XC,MILESTONYR)/sumSFORE;
*    POPSX(MILESTONYR) = sum(H, HPOPX(H,XC,MILESTONYR,TT));
    POPSX(MILESTONYR) = SIM_POP(RUN,MILESTONYR);
    TFHPOP_X(FH,T) = TFHPOP(FH,XC,T);
    TFHPOPMY(FH,MILESTONYR) = TFHPOP(FH,XC,MILESTONYR)/POPSX(MILESTONYR);
    YHE(MILESTONYR) = HFORE('hhd-he',XC,MILESTONYR);

    TRAMOD = SIM_TRAMOD(RUN);

* write new demand driver values to demand workbook

  if(SFORE_X('COM','2050'),
    execute_unload "MCDem.gdx" POPSX SFORE_X GDP_FSX TRAMOD TFHPOPMY YHE MFHHT PAMS
    execute 'gdxxrw.exe i=MCDem.gdx o=SATM\DMD_PRJ.xlsx index=index_G2E!a6';
  );


  ELSE


*    EPROJ(ALS,XC,TC,TT) = (SUM(RD, QARX(ALS,RD,XC,TC,TT)) + SUM(RW, SUM(C$mAC(ALS,C),QMX(C,RW,XC,TC,TT))))/UCONV_A_T2C(ALS);
*    EPROJ('AELEC',XC,TC,TT) = (SUM(RD, QARX('AELEC',RD,XC,TC,TT)) + SUM(RW, QMX('CELEC',RW,XC,TC,TT)))*3.6;
*    EPROJ('APETR',XC,TC,TT) = (SUM(RD, QARX('APETR',RD,XC,TC,TT)) + SUM(RW, QMX('CPETR',RW,XC,TC,TT)))*36.35;
*extrapolation to 2050 - remove when running CGE to 2050
    EPROJGR(A,'2045')$EPROJ(A,XC,'2035',TT) = EPROJ(A,XC,'2040',TT)/EPROJ(A,XC,'2035',TT);
    EPROJ(A,XC,'2045',TT) = EPROJ(A,XC,'2040',TT)*EPROJGR(A,'2045');
    EPROJ(A,XC,'2050',TT) = EPROJ(A,XC,'2045',TT)*EPROJGR(A,'2045');
*DDS files for TIMES ------------------------------------------

*Compile demand forecast in single parameter (EFCAST)

*Agriculture and industry

*Demand projections for electricity sector only

$ontext
    PUT  EFFILE;
    EFFILE.pc = 2;
    EFFILE.nd = 5;
    EFFILE.ap = 0;



    PUT 'PARAMETER ACOM_PROJ /' /;
    LOOP((A,T)$EPROJ(A,XC,T,TT),
      EFVAL = EPROJ(A,XC,T,TT);
      IF(EPROJ(A,XC,T,TT),
        PUT "REGION1.",A.TL,".", T.TL, EFVAL /;
      );
    );
    PUTCLOSE "/;";
$offtext


    );
* IF(SATIMODE EQ 1,

*);
*IF(TT1(TT),


*Fuel prices for TIMES -------------------------
* this will be done in a different way
$ontext
* we still need to do timeseries for other fuels
IF(NOT TT1(TT),

*Export prices
 FUELPPROJ(FUELP,TC)$(SUM(C, MFUELP(FUELP,C,'EXP')) AND SUM((RW,C)$MFUELP(FUELP,C,'EXP'), QEX(C,RW,XC,TC,TT)))
   = SUM(C$MFUELP(FUELP,C,'EXP'),
         SUM(RW, PEX(C,RW,XC,TC,TT)*QEX(C,RW,XC,TC,TT)) / SUM(RW, QEX(C,RW,XC,TC,TT))
         / DPIX(XC,TC,TT)
     );
*Import prices
* FUELPPROJ(FUELP,TC)$(SUM(C, MFUELP(FUELP,C,'IMP')) AND SUM((RW,C)$MFUELP(FUELP,C,'IMP'), QMX(C,RW,XC,TC,TT)))
*   = SUM(C$MFUELP(FUELP,C,'IMP'),
*         SUM(RW, PMX(C,RW,XC,TC,TT)*QMX(C,RW,XC,TC,TT)) / SUM(RW, QMX(C,RW,XC,TC,TT))
*         / DPIX(XC,TC,TT)
*     );
*JT: Composite price assigned to fuels assuming imports and domestic fuels are treated the same way
*  (and because the carbon tax is not applied to
 FUELPPROJ(FUELP,TC)$SUM(C, MFUELP(FUELP,C,'IMP'))
   = SUM(C$MFUELP(FUELP,C,'IMP'), PQX(C,XC,TC,TT)/CPIX(XC,TC,TT));

*Domestic prices
 FUELPPROJ(FUELP,TC)$SUM(C, MFUELP(FUELP,C,'DOM'))
   = SUM(C$MFUELP(FUELP,C,'DOM'), PQX(C,XC,TC,TT)/CPIX(XC,TC,TT));

*Price index
 FUELPPROJ(FUELP,TC)$SUM(T1, FUELPPROJ(FUELP,T1))
   = FUELPPROJ(FUELP,TC) / SUM(T1, FUELPPROJ(FUELP,T1));
*Apply price index to base year prices
 AACT_COST(FUELP,T) = AACT_COST_BASE(FUELP) * FUELPPROJ(FUELP,T);

);


 PUT  PRCFILE;
 PRCFILE.pc = 2;
 PRCFILE.nd = 5;
 PRCFILE.ap = 0;

 PUT 'PARAMETER AACT_COST /' /;

IF(TT1(TT),
 PUTCLOSE "/;";
ELSE

 LOOP((FUELP,TC),
  EFVAL = AACT_COST(FUELP,TC);
  IF(EFVAL,
    PUT "REGION1.", FUELP.TL, ".", TC.TL, EFVAL /;
  ELSE
    PUT "REGION1.", FUELP.TL, ".", TC.TL, "EPS" /;
  );
 );
 PUTCLOSE "/;";

);
$offtext




