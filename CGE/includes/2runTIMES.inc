
*--------------------------------------------------------------
*SETUP AND CALL TIMES MODEL IN GAMS -------------------------------------
*--------------------------------------------------------------

  PUT  ShowRunNumber;
  RUNTIMES2.pc = 2;
  RUNTIMES2.nd = 5;
  RUNTIMES2.ap = 0;

  put "echo ", RUN.TL;

  PUTCLOSE "";

* Write executable for running SATIM with specified path and run-name
  PUT  RUNTIMES2;
  RUNTIMES2.pc = 2;
  RUNTIMES2.nd = 5;
  RUNTIMES2.ap = 0;
  put 'copy "%workingfolder%SATM\%TIMESfolder%\DMDTECHAFRES+REGION1.bu" "%workingfolder%SATM\%TIMESfolder%\DMDTECHAFRES+REGION1.dds"'/;
  put 'copy "%workingfolder%SATM\%TIMESfolder%\DMDTECHAFCOM+REGION1.bu" "%workingfolder%SATM\%TIMESfolder%\DMDTECHAFCOM+REGION1.dds"'/;

  loop(MRUNCASE(RUN,TIMESCASE), put ".\satm\%TIMESfolder%\RUNTIMES.CMD ", "%workingfolder%":38,TIMESCASE.TL:20,"%TIMESfolder%");

  PUTCLOSE "";

* Run TIMES model
 execute ".\satm\%TIMESfolder%\ShowRunNumber.CMD"
 execute ".\satm\%TIMESfolder%\RUNTIMES2.CMD"
 execute "echo --- Return to CGE model"



*--------------------------------------------------------------
*PASS RESULTS FROM TIMES TO CGE
*--------------------------------------------------------------
loop(MRUNCASE(RUN,TIMESCASE), put_utilities SATIM_Scen 'gdxin' / "%GDXfolder%",TIMESCASE.TL:20);
*LOOP(MXCT(XC,XCT), put_utilities SATIM_Scen 'gdxin' / "..\satm\gams_wrkti\",XCT.TL:20);
execute_load REG_OBJ PAR_NCAPL PAR_NCAPR PRC_RESID PRC_CAPACT PAR_NCAPR PAR_CAPL VARACT F_IN F_OUT NCAP_ILED OB_ICOST PAR_COMBALEM CST_FIXC CST_ACTC CST_INVC;

* perform interpolation
$BATINCLUDE interpolate PRC_RESID 'REG' 'PRC' ",'0','0','0','0','0'" TC 'RTP(REG,TC,PRC)'

$BATINCLUDE interpolate PAR_CAPL 'REG' 'PRC' ",'0','0','0','0','0'" TC 'PAR_CAPL(REG,TC,PRC)'

$BATINCLUDE interpolate VARACT 'REG' 'PRC' ",'0','0','0','0','0'" TC 'VARACT(REG,TC,PRC)'

 NCAP_ILED(REG,TC,PRC) = NCAP_ILED(REG,'2012',PRC);

 OBICOST(REG,TC,PRC) = OB_ICOST(REG,PRC,'CUR',TC);
$BATINCLUDE interpolate OBICOST 'REG' 'PRC' ",'0','0','0','0','0'" TC 'RTP(REG,TC,PRC)'

 TVFLOWIN(COM,TC,PRC) = SUM((V,S), F_IN('REGION1',V,TC,PRC,COM,S));
$BATINCLUDE interpolate TVFLOWIN 'COM' 'PRC' ",'0','0','0','0','0'" TC 'TVFLOWIN(COM,TC,PRC)'


 TCST_INVC(REG,TC,PRC)= sum(V,CST_INVC(REG,V,TC,PRC,'INV'));
$BATINCLUDE interpolate TCST_INVC 'REG' 'PRC' ",'0','0','0','0','0'" TC 'TCST_INVC(REG,TC,PRC)'

 TCST_ACTC(REG,TC,PRC)= sum(V,CST_ACTC(REG,V,TC,PRC));
$BATINCLUDE interpolate TCST_ACTC 'REG' 'PRC' ",'0','0','0','0','0'" TC 'TCST_ACTC(REG,TC,PRC)'

 TCST_FIXC(REG,TC,PRC)= sum(V,CST_FIXC(REG,V,TC,PRC));
$BATINCLUDE interpolate TCST_FIXC 'REG' 'PRC' ",'0','0','0','0','0'" TC 'TCST_FIXC(REG,TC,PRC)'

 T_COMBALEM(REG,TC,COM) = PAR_COMBALEM(REG,TC,COM,'ANNUAL');
$BATINCLUDE interpolate T_COMBALEM 'REG' 'COM' ",'0','0','0','0','0'" TC 'T_COMBALEM(REG,TC,COM)'






*excluding TVCOMBAL because of CO2 marginals TVCOMBAL(T,COM)  = PAR_COMBALEM('REGION1',T,COM,'ANNUAL');



* for TVNCAP we assume uniform spread of the investment (although TIMES uses the discount rate to spread it - we could do this later)
 TVNCAP(TC,PRC)    = PAR_NCAPL('REGION1',TC,PRC);
 TVNCAP(MILESTONYR,PRC) = TVNCAP(MILESTONYR,PRC)/TGAP(MILESTONYR);
 LOOP(MILESTONYR,
   LOOP(TC,
     if(YEARVALT(TC) GE B(MILESTONYR) and YEARVALT(TC) LE E(MILESTONYR),
       TVNCAP(TC,PRC) = TVNCAP(MILESTONYR,PRC);
     );
   );
  );


 TVCAP(TC,PRC)     = PRC_RESID('REGION1',TC,PRC)+PAR_CAPL('REGION1',TC,PRC);
 TVACT(TC,PRC)     = VARACT('REGION1',TC,PRC);


*Electricity and petroleum supply from TIMES ------------------

$ontext
 Initial years: Use historical generation data
 Subsequent years: Use TIMES results
$offtext

* Calculate final consumption for SATIM industry sectors and freight
 FLOW_IN_FS(FS,COM,TC) = SUM(PRC$MPRCFS(PRC,FS), TVFLOWIN(COM,TC,PRC));
* calculate final consumption
 FLOW_IN_FSFuels(FS,C,TC,TT) = SUM(COM$MCOMC(COM,C),FLOW_IN_FS(FS,COM,TC));
*UCONV_C_T2C(C);

*bm not sure why yet but model goes unstable the second time round - need to look into it
IF(TT1(TT),
 EIntensity_FS(FS,C,T)$SFORE_X(FS,T) = FLOW_IN_FSFuels(FS,C,T,TT)/SFORE_X(FS,T);
 EIntensity_FS(FS,'cpetr_t',T)$SFORE_X('tran',T) = FLOW_IN_FSFuels('tran','cpetr_t',T,TT)/SFORE_X('tran',T);
);

 ICAFSGR(C,FS,T,TT)$EIntensity_FS(FS,C,T-1) = EIntensity_FS(FS,C,T)/EIntensity_FS(FS,C,T-1);




* For households excluding private transport fuel expenditure
 FLOW_IN_FH(FH,COM,TC) = SUM(PRC$MPRCFH(PRC,FH), TVFLOWIN(COM,TC,PRC));
 FLOW_IN_FHFuels(FH,C,TC) = SUM(COM$MCOMC(COM,C),FLOW_IN_FH(FH,COM,TC));
*UCONV_C_T2C(C);



* For households on transport
 FLOW_IN_FT(FT,COM,TC) = SUM(PRC$MPRCFT(PRC,FT), TVFLOWIN(COM,TC,PRC));
 FLOW_IN_FTFuels(FT,C,TC) = SUM(COM$MCOMC(COM,C),FLOW_IN_FT(FT,COM,TC));
*UCONV_C_T2C(C);

* multiply by share of pkm by household to allocate consumption to different hh
 FLOW_IN_FTFHFuels(FH,C,TC) = FLOW_IN_FTFuels('TPPR',C,TC)*PKMFH('TPPR',FH,TC);
* add transport fuels to other fuels
 FLOW_IN_FHAllFuels(FH,C,TC) = FLOW_IN_FHFuels(FH,C,TC)+FLOW_IN_FTFHFuels(FH,C,TC);

*!!! need to sort out public transport!!!
 EIntensity_FH(FH,C,TC)$TFHPOP_X(FH,TC) = FLOW_IN_FHAllFuels(FH,C,TC)/TFHPOP_X(FH,TC);

IF(TT1(TT),

 FLOW_IN_FHFuelsGR(FH,C,TC)$EIntensity_FH(FH,C,TC-1) = EIntensity_FH(FH,C,TC)/EIntensity_FH(FH,C,TC-1);
);


 gammamgr(C,H,TC,TT) = SUM(FH$MFHHT(FH,H,TC),FLOW_IN_FHFuelsGR(FH,C,TC));



*b
 ENCAP(SUPELE,XC,TC,TT) = TVNCAP(TC,SUPELE);


*Use EFLOW shares to split production (remove imports from EFLOW so that only domestic production is scaled)
 EFLOW('NAT',XC,TC,TT) = SUM(RDNT, EFLOW(RDNT,XC,TC,TT));
 PFLOW('NAT',XC,TC,TT) = SUM(RDNT, PFLOW(RDNT,XC,TC,TT));


 ECAP('NAT',XC,TC,TT) = SUM(RDNT, ECAP(RDNT,XC,TC,TT));

*Electricity and petroleum build plan projection
 ECAPGR('nat',XC,TC,TT)$ECAP('nat',XC,TC-1,TT) = ECAP('nat',XC,TC,TT)/ECAP('nat',XC,TC-1,TT)-1;

*Investment costs from TIMES ----------------------------------

$ontext
 Investment costs are based on year of build decision (TVNCAP) and the number
 of years needed to build the plant (lead time NCAP_LEAD).
 Annual cost = build capacity (TVNCAP) x unit cost (OBJ_ICOST) / years to build (NCAP_ILED)
 Calculation: Keep track of vintages (TP)
$offtext



*LOOP((REG,TTCH,T)$TVNCAP(REG,T,TTCH),
* LOOP(TP$((ORD(TP) GE ORD(T)) AND (ORD(TP) LT (ORD(T)+NCAP_ILED(REG,'2006',TTCH)))),
*  BPINV(XC,REG,T,TP,TTCH) = TVNCAP(REG,T,TTCH)/NCAP_ILED(REG,'2006',TTCH) * OBJ_ICOST(REG,T,TTCH,'CUR');
* );
*);
*b
NCAP_ILED('REGION1','2012',PRC)$(NCAP_ILED('REGION1','2012',PRC) EQ eps)= -1;


LOOP((PRC,TC)$(TVNCAP(TC,PRC) AND NCAP_ILED('REGION1','2012',PRC) GT 0),
 LOOP(TCP$((ORD(TCP) GE ORD(TC)) AND (ORD(TCP) LT (ORD(TC)+NCAP_ILED('REGION1','2012',PRC)))),
  BPINV(XC,TC,TCP,PRC)$NCAP_ILED('REGION1','2012',PRC) = TVNCAP(TC,PRC)/NCAP_ILED('REGION1','2012',PRC) * OBICOST('REGION1',TC,PRC);
 );
);
* investment cost with negative NCAL_ILED
LOOP((PRC,TC)$(TVNCAP(TC,PRC) AND NCAP_ILED('REGION1','2012',PRC) LT 0),
 LOOP(TCP$((ORD(TCP) LT ORD(TC)) AND (ORD(TCP) GE (ORD(TC)+NCAP_ILED('REGION1','2012',PRC)))),
  BPINV(XC,TC,TCP,PRC)$NCAP_ILED('REGION1','2012',PRC) = TVNCAP(TC,PRC)/(-1*NCAP_ILED('REGION1','2012',PRC)) * OBICOST('REGION1',TC,PRC);
 );
);


* expenditure schedule in billions (2007 from 2010)
 INVCOST(RUN,TC,TT,PRC) = SUM(TCP, BPINV(XC,TCP,TC,PRC))/1000;

*Sum across vintages to get total annual cost (billions of rands)
* EINVCOST(XC,T,TT) = SUM((SUPELE AND SUPOIL), INVCOST(XC,T,TT,ELE));
 EINVCOST(XC,TC,TT) = SUM(SUPELE, INVCOST(RUN,TC,TT,SUPELE));
 EFLOW('NAT',XC,TC,TT) = SUM(SUPELE, TVACT(TC,SUPELE))/3.6;

* carbon tax resulting from cap (marginal)
*bm TCARBONTAX(XC,TC,TT) = T_COMBALEM('REGION1',TC,'CO2EQS')*(-0.791);


*Regulated Commodity price from TIMES ----------------------


* PAR_NCAPR is a shortcut way of getting the price but doesn't seem to work very well when running all years
* ETPRICE(TC) = PAR_NCAPR('REGION1',TC,'ETRANS','LEVCOST') * 3.6 / 1000;

* The long way round:
* Electricity Price = (power plant costs + fuel costs)/total elc transmitted
*Power Plant Costs (excluding fuel)
TCST_ELE(RUN,TC) = SUM(SUPELE,TCST_INVC('REGION1',TC,SUPELE)+TCST_ACTC('REGION1',TC,SUPELE)+TCST_FIXC('REGION1',TC,SUPELE))+SUM(XELC,TCST_INVC('REGION1',TC,XELC));

* Coal costs
* dedicated mines
TCST_PWRCL(TC) = sum(MINCLPWR,TCST_INVC('REGION1',TC,MINCLPWR)+TCST_ACTC('REGION1',TC,MINCLPWR)+TCST_FIXC('REGION1',TC,MINCLPWR));
* non-dedicated mines central basin
TCST_PWRDUAL(TC) = TVACT(TC,'XPWRCLE')* SIM_CLN(RUN,TC)/COAL_CV('MINCLN');
*/1.172*1.309;
*bm problems here: TCST_PWRDUAL(T) = sum(MINCLDUAL,TCST_INVC('REGION1',T,MINCLDUAL)+TCST_ACTC('REGION1',T,MINCLDUAL)+TCST_FIXC('REGION1',T,MINCLDUAL));
*bm problems here: TCST_PWRDUAL(T)$sum(MINCLDUAL,TVACT(T,MINCLDUAL)) = TCST_PWRDUAL(T)*TVACT(T,'XPWRCLE')/sum(MINCLDUAL,TVACT(T,MINCLDUAL));
* non-dedicated mines waterberg
*bm problems here: TCST_PWRDUAL_A(T) = sum(MINCLDUAL_A,TCST_INVC('REGION1',T,MINCLDUAL_A)+TCST_ACTC('REGION1',T,MINCLDUAL_A)+TCST_FIXC('REGION1',T,MINCLDUAL_A));
*bm problems here: TCST_PWRDUAL_A(T)$sum(MINCLDUAL_A,TVACT(T,MINCLDUAL_A)) = TCST_PWRDUAL_A(T)*TVACT(T,'XPWRCLE-A')/sum(MINCLDUAL_A,TVACT(T,MINCLDUAL_A));
TCST_PWRDUAL_A(TC) = TVACT(TC,'XPWRCLE-A')* SIM_CLN_A(RUN,TC)/COAL_CV('MINCLN-A');

*/1.172*1.309;
*Total Coal costs
TCST_PWRCLT(RUN,TC) = TCST_PWRCL(TC)+TCST_PWRDUAL(TC)+TCST_PWRDUAL_A(TC);
*TPWRCLE(T) = TVACT(T,'XPWRCLE-A')+TVACT(T,'XPWRCLE')+TVACT(T,'XPWRCLEC-A')+TVACT(T,'XPWRCLEC');
*TPWRCLETAX(T) = TPWRCLE(T)*T_COMBALEM('REGION1',T,'CO2EQS')*(-1)*96.25;
*TCST_PWRCLT(RUN,T) = TCST_PWRCL(T)+TCST_PWRDUAL(T)+TCST_PWRDUAL_A(T)+TPWRCLETAX(T);

* Gas costs !!! need to finish this up at some point soon
*approach 1: tested and comparable to approach 2 for pwrg*
*TCST_SUPGIC(T) = sum(SUPGIC,TCST_INVC(T,SUPGIC)+TCST_ACTC(T,SUPGIC)+TCST_FIXC(T,SUPGIC));
*GICM(T) = TCST_SUPGIC(T)/(TVACT(T,'UGASGIC-N')+TVACT(T,'XPWRGIC')+TVACT(T,'XUPSGIC'));
*approach 2: marginals, is fine until we impose a carbon cap
*TCST_PWROTH(RUN,T) = SUM((XPWR,PWR)$MFUELPWR(XPWR,PWR), TVACT(T,XPWR)*TVCOMBAL(T,PWR));
*TCST_PWROTH(RUN,T) = SUM((PRC,COM)$MPRCCOM(PRC,COM), TVACT(T,PRC)*TVCOMBAL(T,COM));
*TCST_PWROTH(TC) = 0;

*SIM_FUELP('IMPGWL',RUN,MY) = (SIM_GGAS(RUN,MY)+1) * XRATE(RUN,MY) / 1.055;
*SIM_FUELP('IMPGRL',RUN,MY) = (SIM_GGAS(RUN,MY)+0.5) * XRATE(RUN,MY) / 1.055;

*TCST_PWROTH(RUN,TC) = (SIM_GGAS(RUN,TC)+1) * XRATE(RUN,'2012') / 1.055 * TVACT(TC,'IMPGWL')+(SIM_GGAS(RUN,TC)+0.5) * XRATE(RUN,'2012') / 1.055 * TVACT(TC,'IMPGRL');
TCST_PWROTH(RUN,TC) = (SIM_GGAS(RUN,TC)+1) * XRATE(RUN,'2012') / 1.055 * TVACT(TC,'XPWRGIC');

*still need to add CO2 tax here

* Elc Price
 ETPRICE(TC) = (TCST_PWRCLT(RUN,TC)+TCST_PWROTH(RUN,TC)+TCST_ELE(RUN,TC))/EFLOW('NAT',XC,TC,TT);

*b add growth rates from TIMES from 2014 onward
 ETPRICEGR(TC)$(not (TIEPG(TC)+T1(TC)+TT1(TC))) = ETPRICE(TC)/ETPRICE(TC-1)-1;
* ETPRICEGR(TC) = 0.001;

 EPRICE(T1,TT)=PQ0('CELEC');

*b apply growth rate to calculate EPRICE
 loop(TC,
   if(not T1(TC),
     EPRICE(TC,TT) = EPRICE(TC-1,TT) * (1+ETPRICEGR(TC));
   );
 );



*Bil rands / TWh
*Rands/kWh
*celec        0.255008
*191


*--------------------------------------------------------------
*PASS RESULTS CGE TO TIMES
*--------------------------------------------------------------

*Committed build for TIMES -------------------------

*LOOP(T$(ORD(T) LT SMAX(TP$TT(TP), ORD(TP))),
LOOP(T$(ORD(T) LT COUNT),
 COMBUILD(PRC,T) = TVNCAP(T,PRC);
);


$ontext
 PUT  COMFILE;
 COMFILE.pc = 2;
 COMFILE.nd = 5;
 COMFILE.ap = 0;

 PUT 'PARAMETER ANCAP_BND /' /;
 LOOP((PRC,T)$(ORD(T) LT COUNT),
  EFVAL = COMBUILD(PRC,T);
  IF(EFVAL,
    PUT "REGION1.", T.TL, ".", PRC.TL, ".FX    ", EFVAL /;
  ELSE
    PUT "REGION1.", T.TL, ".", PRC.TL, ".FX    ", "EPS" /;
  );
 );
 PUTCLOSE "/;";
$offtext

SIM_FUELPX(FUELP,MY)   = SIM_FUELP(FUELP,RUN,MY);
SIM_TECHCX(TECHC,MY)   = SIM_TECHC(TECHC,RUN,MY);
SIM_NUCLEARCFX         = SIM_NUCLEARCF(RUN);
SIM_NUCLEARLTX         = SIM_NUCLEARLT(RUN);
SIM_SOLTPKNTX          = SIM_SOLTPKNT(RUN);
SIM_HYDIMPX            = SIM_HYDIMP(RUN);


* write results to viz-GDX file
   put_utilities SATIM_Scen 'gdxout' / "%GDXoutfolder%",RUN.TL:20;
*inputs
*   execute_unload Passengerkm Tonkm GDP_FSX POPSX SIM_DEMX F_IN F_OUT VARACT PRC_CAPACT PRC_RESID PAR_CAPL PAR_NCAPL PAR_COMBALEM PAR_NCAPR REG_OBJ CST_INVC CST_ACTC CST_FIXC;
  execute_unload MRUNCASE Passengerkm Tonkm GDP_FSX POPSX SIM_DEMX SIM_FUELPX SIM_TECHCX SIM_NUCLEARCFX SIM_NUCLEARLTX SIM_SOLTPKNTX SIM_HYDIMPX F_IN F_OUT VARACT PRC_CAPACT PRC_RESID PAR_CAPL PAR_NCAPL PAR_COMBALEM PAR_NCAPR REG_OBJ CST_INVC CST_ACTC CST_FIXC ERPRICE ETPRICE INVCOST;

*SIM_FUELPX SIM_TECHCX SIM_NUCLEARCFX SIM_NUCLEARLTX SIM_SOLTPKNTX SIM_HYDIMPX

* Reset BPINV
 BPINV(XC,TC,TCP,PRC) = 0;
