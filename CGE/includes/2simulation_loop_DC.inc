
*Loop over simulations
LOOP(XC$(NOT fail),


    execute_load "mcdem_start.gdx" MFHHT SFORE_X TFHPOP_X SIM_DEMX PKMFH Passengerkm Tonkm;
*    MFHHT(FH,H,'2045') = MFHHT(FH,H,'2040');
*    MFHHT(FH,H,'2050') = MFHHT(FH,H,'2040');


* Loop over TIMES model solve periods
  LOOP(TT$(NOT fail),

*   Calculate start to next TIMES model solve period (TT+1)
    TTC(T)  = no;
    TTC(TT) = yes;
    COUNT = 0;
   LOOP(T,
     COUNT$TTC(T) = ORD(T);
    );

 TABAR(A,RD)=TA0(A,RD);

*Identify factors with upward-sloping supply curves
 FLS(F) = NO;
 FLS(F)$(CLOSURES(F,XC) EQ 4) = YES;


* get demand data for SATIM run
if( not TT1(TT),
  execute 'gdxxrw.exe i=SATM\DMD_PRJ.xlsx o=mcdem2.gdx index=index_E2G!a6 checkdate';
  execute_load "mcdem2.gdx" SIM_DEMX PKMFH Passengerkm Tonkm;
);
* Demand DDS File
    PUT  SIM_DEM_FILE;
    SIM_DEM_FILE.pc = 2;
    SIM_DEM_FILE.nd = 5;
    SIM_DEM_FILE.ap = 0;

    PUT 'PARAMETER ACOM_PROJ /' /;

    LOOP((DEM1,NMY1),
  EFVAL = SIM_DEMX(DEM1,NMY1);
  if(EFVAL,
    PUT "REGION1.", DEM1.TL, ".", NMY1.TL, EFVAL /;
ELSE
    PUT "REGION1.", DEM1.TL, ".", NMY1.TL, "EPS" /;
  );
);
PUTCLOSE "/;";

*$exit
*Initialize CGE model parameters and variables
$include cge\includes\2varinit.inc

* Run SATIM
$include cge\includes\2runTIMES.inc

*Energy supply projection from TIMES
 TFLOW(A,RD,RUN,TC,TT) = SUM(PRC$MPRCARD(PRC,A,RD), TVACT(TC,PRC));
 TCAP(A,RD,RUN,TC,TT) = SUM(PRC$MPRCARD(PRC,A,RD), TVCAP(TC,PRC));
 ECAP(RD,XC,TC,TT) = TCAP('AELEC',RD,RUN,TC,TT);
 PCAP(RD,XC,TC,TT) = TCAP('APETR',RD,RUN,TC,TT);

*Extract electricity and oil products production from SATIM
 EFLOW(RD,XC,TC,TT) = TFLOW('AELEC',RD,RUN,TC,TT)/3.6;
 PFLOW(RD,XC,TC,TT) = TFLOW('APETR',RD,RUN,TC,TT)/36.35;

*Use EFLOW shares to split production (remove imports from EFLOW so that only domestic production is scaled)
 EFLOW('NAT',XC,TC,TT) = SUM(RDNT, EFLOW(RDNT,XC,TC,TT));
 PFLOW('NAT',XC,TC,TT) = SUM(RDNT, PFLOW(RDNT,XC,TC,TT));

 ECAP('NAT',XC,TC,TT) = SUM(RDNT, ECAP(RDNT,XC,TC,TT));
 PCAP('NAT',XC,TC,TT) = SUM(RDNT, PCAP(RDNT,XC,TC,TT));
*Electricity and petroleum build plan projection
*bm+fh 201118 removed - already in 2runtimes.inc !!!! note that ECAP and PCAP are also calculated in 2runTIMES, we need to clean this out
* ECAPGR('nat',XC,TC,TT)$ECAP('nat',XC,TC-1,TT) = ECAP('nat',XC,TC,TT)/ECAP('nat',XC,TC-1,TT)-1;


* Extract fuel inputs from SATIM

* For elc and oil products (until the other sectors are aggregated in the same way)
 FLOW_IN_A(A,COM,TC) = SUM(RDNT, SUM(PRC$MPRCA(PRC,A), TVFLOWIN(COM,TC,PRC)));
 FLOW_IN_AFuels(A,C,TC,TT) = SUM(COM$MCOMC(COM,C),FLOW_IN_A(A,COM,TC))*UCONV_C_T2C(C);

* do reverse mapping for industry sectors (excludes power and petroleum)
 ICAGR(CXEP,A,TC) = SUM(FSXEP$MFSA(FSXEP,A),ICAFSGR(CXEP,FSXEP,TC,TT));

*   Loop over CGE model solve periods
  LOOP(TC$(NOT fail),

*   CA calculate units of capital required given capacity from times (units not consistent with CGE)
    EAFXCAP(RDNT,XC,TC,TT)$(EFX(TT,TC) AND ifa('FEGY','AELEC',RDNT)) = ifa('FEGY','AELEC',RDNT)*iva('AELEC',RDNT)*ECAP(RDNT,XC,TC,TT);
    EAFXCAP('NAT',XC,TC,TT)$EFX(TT,TC)  = SUM(RDNT,EAFXCAP(RDNT,XC,TC,TT));
*bm+fh 201118 removed - already in 2runtimes.inc
    PAFXCAP(RDNT,XC,TC,TT)$(EFX(TT,TC) AND ifa('FCAP','APETR',RDNT)) = ifa('FCAP','APETR',RDNT)*iva('APETR',RDNT)*PCAP(RDNT,XC,TC,TT);
    PAFXCAP('NAT',XC,TC,TT)$EFX(TT,TC)  = SUM(RDNT,PAFXCAP(RDNT,XC,TC,TT));

      IF(NOT T1(TC),

*CATemp write in revised ica values
*CA Assume values for SPV and Wind way excessive for cmine, celec, and cimpt

 ica0('celec','aelec','spv')=ica0('celec','aelec','clw');
 ica0('celec','aelec','wnd')=ica0('celec','aelec','clw');
 ica0('cmine','aelec','spv')=ica0('cmine','aelec','clw');
 ica0('cmine','aelec','wnd')=ica0('cmine','aelec','clw');
 ica0('cimpt','aelec','spv')=ica0('cimpt','aelec','clw');
 ica0('cimpt','aelec','wnd')=ica0('cimpt','aelec','clw');
 ica0('cngas','aelec','gas')=7.2;

 ica0('celec','aelec','sth')=ica0('celec','aelec','clw');
 ica0('cmine','aelec','sth')=ica0('cmine','aelec','clw');
 ica0('cimpt','aelec','sth')=ica0('cimpt','aelec','clw');

 ica0('celec','aelec','nuc')=ica0('celec','aelec','clw');
 ica0('cmine','aelec','nuc')=ica0('cmine','aelec','clw');
 ica0('cimpt','aelec','nuc')=ica0('cimpt','aelec','clw');

 iva0('aelec','spv')=iva0('aelec','wnd');

*       ENERGY: Carbon tax rate
*        tco2d = SIM_CO2PRICE(RUN,TC)/1000;
*        tco2e = SIM_CO2PRICE(RUN,TC)/1000;
*        tco2m = SIM_CO2PRICE(RUN,TC)/1000;

*       ENERGY: Retaliatory carbon tax on RSA exports
        rtco2e = RTCO2ESIM(XC,TC);

*       ENERGY: Carbon content cofficient
$include cge\includes\2carbon.inc
        co2c(C)    = CO2CSIM(C,XC,TC);
        co2e(C,RW) = co2e(C,RW) * CLEANTECH(C,XC,TC);
        co2m(C,RW) = co2m(C,RW) * CLEANTECH(C,XC,TC);
*        co2e(C,RW) = CO2ESIM(C,RW,XC,TC);
*        co2m(C,RW) = CO2MSIM(C,RW,XC,TC);
*        co2e(C,RW) = 0;
*        co2m(C,RW) = 0;

*FH
        tabar(CTA,'NAT')=tabar(CTA,'NAT')+CTA_EMRR(CTA);

*       Long term TFP growth
        alphava(A,RD) = alphava(A,RD) * (1+TFPGR(A,RD,XC,TC));

*FH  removed inclusion by SG causing elec employment to explode
*        leova(A,RD) = leova(A,RD) * (1+TFPGR(A,RD,XC,TC));

*fh CHANGED TO ABOVE
*        alphava(A,RD) = alphava(A,RD) * (1+SECGR(A,RD,XC,TC)/100);
*        leova(A,RD) = leova(A,RD) * (1+SECGR(A,RD,XC,TC)/100);

*       Long term factor-specific productivity growth
        fprd(F,A,RD)$(NOT AFX(A,RD)) = fprd(F,A,RD) * (1+FPRDGR(F,XC,TC));

*       World price changes - standard CGE input
*FH: REMOVED CODE AND RESET TO ORIGINAL CODE
*        pwebar(C,RW) = pwebar(C,RW) * (1+PWGR(C,XC,TC));
*        pwmbar(C,RW) = pwmbar(C,RW) * (1+PWGR(C,XC,TC));
        pwebar(C,RW) = pwebar(C,RW) * (1+PWEGR(C,XC,TC));
        pwmbar(C,RW) = pwmbar(C,RW) * (1+PWMGR(C,XC,TC));

        rhova(A,RD) = rhova_coal(A,RD,XC,TC);

*       Population growth
        hpop(H) = hpop(H) * (1+POPGR(H,XC,TC));
$ontext
*fh: link population growth to average annual satim growth by group
        hpop('hhd-0' ) = hpop('hhd-0' ) * (1+(((tfhpop_x('hhd-le','2050')+tfhpop_x('hhd-ln','2050'))/(tfhpop_x('hhd-le','2012')+tfhpop_x('hhd-ln','2012')))**(1/(2050-2012))-1));
        hpop('hhd-1' ) = hpop('hhd-1' ) * (1+(((tfhpop_x('hhd-le','2050')+tfhpop_x('hhd-ln','2050'))/(tfhpop_x('hhd-le','2012')+tfhpop_x('hhd-ln','2012')))**(1/(2050-2012))-1));
        hpop('hhd-2' ) = hpop('hhd-2' ) * (1+(((tfhpop_x('hhd-le','2050')+tfhpop_x('hhd-ln','2050'))/(tfhpop_x('hhd-le','2012')+tfhpop_x('hhd-ln','2012')))**(1/(2050-2012))-1));
        hpop('hhd-3' ) = hpop('hhd-3' ) * (1+(((tfhpop_x('hhd-le','2050')+tfhpop_x('hhd-ln','2050'))/(tfhpop_x('hhd-le','2012')+tfhpop_x('hhd-ln','2012')))**(1/(2050-2012))-1));
        hpop('hhd-4' ) = hpop('hhd-4' ) * (1+(((tfhpop_x('hhd-me','2050')+tfhpop_x('hhd-mn','2050'))/(tfhpop_x('hhd-me','2012')+tfhpop_x('hhd-mn','2012')))**(1/(2050-2012))-1));
        hpop('hhd-5' ) = hpop('hhd-5' ) * (1+(((tfhpop_x('hhd-me','2050')+tfhpop_x('hhd-mn','2050'))/(tfhpop_x('hhd-me','2012')+tfhpop_x('hhd-mn','2012')))**(1/(2050-2012))-1));
        hpop('hhd-6' ) = hpop('hhd-6' ) * (1+(((tfhpop_x('hhd-me','2050')+tfhpop_x('hhd-mn','2050'))/(tfhpop_x('hhd-me','2012')+tfhpop_x('hhd-mn','2012')))**(1/(2050-2012))-1));
        hpop('hhd-7' ) = hpop('hhd-7' ) * (1+(((tfhpop_x('hhd-me','2050')+tfhpop_x('hhd-mn','2050'))/(tfhpop_x('hhd-me','2012')+tfhpop_x('hhd-mn','2012')))**(1/(2050-2012))-1));
        hpop('hhd-8' ) = hpop('hhd-8' ) * (1+(((tfhpop_x('hhd-he','2050')+tfhpop_x('hhd-hn','2050'))/(tfhpop_x('hhd-he','2012')+tfhpop_x('hhd-hn','2012')))**(1/(2050-2012))-1));
        hpop(hhd9)     = hpop(hhd9)     * (1+(((tfhpop_x('hhd-he','2050')+tfhpop_x('hhd-hn','2050'))/(tfhpop_x('hhd-he','2012')+tfhpop_x('hhd-hn','2012')))**(1/(2050-2012))-1));
$offtext
         IF(ord(TC) lt 8,
*bm            betaca('acoal','ccoal-low')=betaca('acoal','ccoal-low')*1.14;
*bm            betaca('acoal','ccoal-hgh')=betaca('acoal','ccoal-hgh')*1.14;
            tui(C,A,RD) = tui(C,A,RD)*.5;
         );
*b added August 2014 to capture continuing trend of coal price increase due to increasing costs of picking "higher hanging" fruit
*bm         IF(ord(TC) gt 7 and ord(TC) lt 19,
*bm            betaca('acoal','ccoal-low')=betaca('acoal','ccoal-low')*1.085;
*bm        );
*bm          IF(ord(TC) gt 18 and ord(TC) lt 29,
*bm            betaca('acoal','ccoal-low')=betaca('acoal','ccoal-low')*1.03;
*bm        );
*bm          IF(ord(TC) gt 28,
*bm            betaca('acoal','ccoal-low')=betaca('acoal','ccoal-low')*1.015;
*bm        );

*       CA driven by previous year gdp growth (see bottom of TC loop)
        trnsfr(INS,ACNT) = trnsfr(INS,ACNT) * (1+TRNSFRGR(INS,ACNT,XC,TC));

*       CA restrict supply of low quality coal (ccoal-low) in order to follow upward price move 2007-2012
*        IF(ord(TC) lt 6,
*            deltaca('acoal','ccoal-low')= deltaca('acoal','ccoal-low') + .03;
*        );

*        IF(ORD(TT) gt 1,

* Using A different approach for ica
*           ica(C,'APETR','NAT')$FLOW_INFuelsA('APETR',C,TC,TT-1) = FLOW_INFuelsA('APETR',C,TC,TT-1)/(EPROJ('APETR',XC,TC,TT-1)*UCONV_A_T2C('APETR'));
*if(ECEMLINK(XC) gt 2,
*
  ica(C,A,'NAT')$ICAGR(C,A,TC) = ica(C,A,'NAT')*ICAGR(C,A,TC);

*sr/bm/fh .L experiment
  QF.L(F,'ahydr',RD)$(ICAGR('chydr','atrps',TC)) = QF.L(F,'ahydr',RD)*ICAGR('chydr','atrps',TC);
  QA.L('ahydr')$(ICAGR('chydr','atrps',TC)) = QA.L('ahydr')*ICAGR('chydr','atrps',TC);

* for Households
  gammam(C,H)$gammamgr(C,H,TC,TT) = gammam(C,H)*gammamgr(C,H,TC,TT);

*bm work in progress          gammam(C,H)$(gammagr(C,H,TC) and not(gammam(C,H)) =

*);


*       ENERGY: Recalibrate electri9city sector coefficients based on changing supply composition
* Power Sector
$ontext
          iva('AELEC','NAT')
                 = SUM(RDNT, iva0('AELEC',RDNT)*EFLOW(RDNT,XC,TC,TT)/EFLOW('nat',XC,TC,TT));
          ifa(F,'AELEC','NAT')
                 = SUM(RDNT, ifa0(F,'AELEC',RDNT)*iva0('AELEC',RDNT)*EFLOW(RDNT,XC,TC,TT)/SUM(RDNTP, iva0('AELEC',RDNTP)*EFLOW(RDNTP,XC,TC,TT)));
          ica(C,'AELEC','NAT')
                 = SUM(RDNT, ica0(C,'AELEC',RDNT)*EFLOW(RDNT,XC,TC,TT)/EFLOW('nat',XC,TC,TT));
$offtext
*fh
         EFLOW(RDNT,XC,TC,TT) = max(EFLOW(RDNT,XC,TC,TT),0.1);
*          EFLOW(RDNT,XC,TC,TT) = max(EFLOW(RDNT,XC,TC,TT),1);

          iva('AELEC','NAT')
                 = SUM(RDNT, iva0('AELEC',RDNT)*EFLOW(RDNT,XC,TC,TT))/EFLOW('nat',XC,TC,TT);
          ifa(F,'AELEC','NAT')
                 = SUM(RDNT, ifa0(F,'AELEC',RDNT)*iva0('AELEC',RDNT)*EFLOW(RDNT,XC,TC,TT))/SUM(RDNTP, iva0('AELEC',RDNTP)*EFLOW(RDNTP,XC,TC,TT));
          ica(C,'AELEC','NAT')
                 = SUM(RDNT, ica0(C,'AELEC',RDNT)*EFLOW(RDNT,XC,TC,TT))/EFLOW('nat',XC,TC,TT);


* Oil supply sector (refineries)
* The approach used to calculate ica in the elc supply didn't work that well for refineries
          iva('APETR','NAT')
                 = SUM(RDNT, iva0('APETR',RDNT)*PFLOW(RDNT,XC,TC,TT)/PFLOW('nat',XC,TC,TT));
          ifa(F,'APETR','NAT')
                 = SUM(RDNT, ifa0(F,'APETR',RDNT)*iva0('APETR',RDNT)*PFLOW(RDNT,XC,TC,TT)/SUM(RDNTP, iva0('APETR',RDNTP)*PFLOW(RDNTP,XC,TC,TT)));

*bm/sr/fh added this to save model from crashing from demand for ccoal-low disapearing completely.
          ica('ccoal-low',A,'NAT')$ica0('ccoal-low',A,'NAT') = max(ica('ccoal-low',A,'NAT'),0.0004);



*          ica(C,'APETR','NAT')
*                 = SUM(RDNT, ica0(C,'APETR',RDNT)*PFLOW(RDNT,XC,TC,TT)/PFLOW('nat',XC,TC,TT));

*       ENERGY: Set electricity sector capital growth rate equal to TIMES results
*       CA: 2capital.inc modified to use EINVCOST
*       CA: below is modified to determine energy capital necessary given capacity data from TIMES
*       CA; below we do not worry about units of capital as we calculate growth rates
*       CA: note that below accommodates evluation in ifa and iva if imposed
          AFX('AELEC',RD) = NO;
          AFX('AELEC',RD)$EFX(TT,TC) = YES;
*CA  slow electricity capital growth when utilization rate is low outside of TIMES periods
          AFX('AELEC',RD)$(NOT EFX(TT,TC) AND QFSUPX('FEGY',XC,TC-1,TT) LT .9) = YES;

          AFX('APETR',RD) = NO;
          AFX('APETR',RD)$EFX(TT,TC) = YES;
          AFX('APETR',RD)$(NOT EFX(TT,TC) AND QFSUPX('FCAP',XC,TC-1,TT) LT .9) = YES;

         AFXGR('AELEC','NAT',XC,TC)$EFX(TT,TC) = EAFXCAP('NAT',XC,TC,TT)/EAFXCAP('NAT',XC,TC-1,TT)- 1;
         AFXGR('AELEC','NAT',XC,TC)$(NOT EFX(TT,TC) AND QFSUPX('FEGY',XC,TC-1,TT) LT .9) = -natdrate;

*bm/fh added petroleum sector
           AFXGR('APETR','NAT',XC,TC)$EFX(TT,TC) = PAFXCAP('NAT',XC,TC,TT)/PAFXCAP('NAT',XC,TC-1,TT)- 1;
           AFXGR('APETR','NAT',XC,TC)$(NOT EFX(TT,TC) AND QFSUPX('FCAP',XC,TC-1,TT) LT .9) = -natdrate;



*CA fix imports in accordance with TIMES for all periods
          QM.FX('CELEC','REST') = EFLOW('IMP',XC,TC,TT);


*CA
 ANFX(A,RD)=NO;
 ANFX(A,RD)$(NOT AFX(A,RD))=YES;

$ONTEXT
*fh Ceiling on coal exports due to rail limitations
 IF (NOT T1(TC) AND QE.L('CCOAL-HGH','REST') GT 97.5,
      QE.FX('CCOAL-HGH','REST') = 97.5;
      PWE.LO('CCOAL-HGH','REST')=-INF;
      PWE.UP('CCOAL-HGH','REST')=+INF;
* ELSE QE.FX('CCOAL-HGH','REST') = QE.L('CCOAL-HGH','REST');
*      PWE.LO('CCOAL-HGH','REST')= PWE('CCOAL-HGH','REST');
*      PWE.UP('CCOAL-HGH','REST')= PWE('CCOAL-HGH','REST');
     );
$OFFTEXT
*fh

 AFX('AGOLD',RD)=YES;
 ANFX(A,RD)$(NOT AFX(A,RD))=YES;
 AFXGR('AGOLD','NAT',XC,TC) = -0.001;
* AFXGR('AGOLD','NAT',XC,TC) = 0.08;

$ontext
 AFX('AMORE',RD)=YES;
 ANFX(A,RD)=NO;
 ANFX(A,RD)$(NOT AFX(A,RD))=YES;
 AFXGR('AMORE','NAT',XC,TC) = 0.03;
* AFXGR('AMORE','NAT',XC,TC) = 0.3;

 AFX('APAPR',RD)=YES;
 ANFX(A,RD)=NO;
 ANFX(A,RD)$(NOT AFX(A,RD))=YES;
 AFXGR('APAPR','NAT',XC,TC) = -0.005;
* AFXGR('APAPR','NAT',XC,TC) = -0.05;
$offtext

*tmp          QM.FX('CPETR','REST') = PFLOW('IMP',XC,TC,TT);
*         QE.FX?

*        );
*       end of IF ord(tt) gt 1 condition

*       Capital stock accumulation and allocation
$include cge\includes\2capital.inc

*       ENERGY: Tech change in energy use via input output matrix
*       Share of new capital in total
        ishr(A,RD)$SUM(FCAP, QF.L(FCAP,A,RD)) = SUM(FCAP, DKAP(FCAP,A,RD))/SUM(FCAP, QF.L(FCAP,A,RD));
        ishr(A,RD)$(ishr(A,RD) GT 1) = 1;
*       Evolve IO coefficient
*bm        ica(CEGY,A,RD)$ica(CEGY,A,RD) = (1-ishr(A,RD))*ica(CEGY,A,RD) + ishr(A,RD)*ica(CEGY,A,RD)*(PQ.L(CEGY)/PQ0(CEGY)/(DPI.L/DPI0))**rhoegyint(CEGY,XC,TC);
*       Tech change in energy use for households
*bm        betam(CEGY,H) = betam(CEGY,H)*((PQ.L(CEGY)/CPI.L)/(PQ0(CEGY)/CPI0))**rhoegyhhd(CEGY,XC,TC);
*bm        betam(C,H)$EH0(H) = betam(C,H)/SUM(CP, betam(CP,H));

*       Land expansion
        QF.L('FLND',A,RD) = QF.L('FLND',A,RD)*(1+FACGR('FLND',XC,TC));

*       Labor supply growth
        QF.L(FLAB,A,RD)$(NOT T1(TC)) = QF.L(FLAB,A,RD)*(1+FACGR(FLAB,XC,TC));

*       Total factor supply
        QFS.L(F) = SUM((RD,A), QF.L(F,A,RD));
      );
*     end NOT T1(TC) loop

$include cge\includes\2closures.inc

*FH: Removed code
$ontext
*CA     Trend wfdist factors for labor towards 1
        IF(ORD(TC) GE 2 AND ORD(TC) LE 11,
            WFDIST.FX(FLAB,A,RD)$WFDIST0(FLAB,A,RD)=WFDIST0(FLAB,A,RD)+(ORD(TC)-1)*(1-WFDIST0(FLAB,A,RD))/10;
        );
        IF(ORD(TC) GT 11,
            WFDIST.FX(FLAB,A,RD)$WFDIST0(FLAB,A,RD)=1;
        );
$offtext

*bm!    IF(ORD(TT) gt 1 AND NOT T1(TC),
    IF(NOT T1(TC),
*       CA add tax adjustment variable for electricity
*       ENERGY: Adjust fixed electricity price

        PQ.FX('CELEC') = EPRICE(TC,TT);
        TQELEC.LO('CELEC') = -INF;
        TQELEC.UP('CELEC') = +INF;
);
*     end of IF ord(tt) gt 1 condition

*CA Benchmark labor market supply curve on the fly
*JT: AE paper (removed this code)
*    WF_BAR(FLS)  = WFX(FLS,'BASE',TC,TT);
*    QFS_BAR(FLS) = QFSX(FLS,'BASE',TC,TT);

*CA set complementarity conditions on energy factor returns
      QFS_FOR.L(FCAP)=0;
      QFS_FOR.UP(FCAP)=+INF;
      QFS_FOR.lo(FCAP)=-INF;
      QFS_FOR.LO('FEGY')=0;
      ALPHAQF.LO= -INF;
      ALPHAQF.UP= +INF;
      QFS.FX('FCAP')=QFS.L('FCAP');
      QFS.UP('FEGY')=QFS.L('FEGY');

      QF.UP('FEGY','AELEC','NAT')= +INF;
      QF.LO('FEGY','AELEC','NAT')= -INF;

      QF.UP('FCAP',A,RD)$QF0('FCAP',A,RD)=+INF;
      QF.LO('FCAP',A,RD)$QF0('FCAP',A,RD)=-INF;

      SOLVE standcge USING MCP ;

      fail$(standcge.modelstat ne 1)=1;
      abort$(abs(walras.l) gt .001 AND NOT fail) "Walras' law lost", walras.l;

*CATemp make GAMS stop at or near error for debugging
*      fail$(ord(tt) eq 1 AND ord(tc) eq 1)=1;

        CTA_EM(A)=(QINT.L('CCOAL-LOW',A)*CO2C('CCOAL-LOW')
                  +QINT.L('CCOAL-HGH',A)*CO2C('CCOAL-HGH')
                  +QINT.L('CCOIL',A)*CO2C('CCOIL')
                  +QINT.L('CNGAS',A)*CO2C('CNGAS'));

        CTA_EMR(A)= CTA_EM(A)*(SIM_CO2PRICE(RUN,TC)/1000);

        CTA_EMRR(A)$(PAR.L(A,'NAT')*QAR.L(A,'NAT'))=CTA_EMR(A)/(PAR.L(A,'NAT')*QAR.L(A,'NAT'));

$include cge\includes\2results.inc

*       CA make growth in transfers from government to HH a function of nominal absorption growth plus a small increment
      IF(NOT T1(TC),
        TRNSFRGR(H,'GOV',XC,TC+1)=TABS.L/TABSX(XC,TC-1,TT)-1 + .005;
      );

     CTA_EMRR(CTA)=CTA_EMRRX(CTA,RUN,XC,TC,TT-1);
    );
*   end TC loop

* generate demand projection, fuel price projection and investment schedules for the next TIMES run
$include cge\includes\2energyfcast.inc
$include cge\includes\2energychecks.inc



  );
*end TT loop

);
*end XC loop



