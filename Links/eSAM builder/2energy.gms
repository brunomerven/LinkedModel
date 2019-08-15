$SETGLOBAL energy "2rsaenergy2012.xlsx"
$SETGLOBAL final "0final.xlsx"

$ontext
 STEP 1: Determine producer and market prices for energy products
         Inputs:  Price estimates from external sources
                  Price estimates implied by the SAM and energy balances

 STEP 2: Separate out fossil fuels from aggregate mining sector (coal, oil and gas)
         Inputs:  Production and trade quantities, prices and technologies
                  Fossil fuel user quantities
         Caution: Track producer and market prices for fossil fuels
                  Check for missing trade and user data
                  Make sure remaining mining is never negative

 STEP 3: Split petroleum and electricity into subsectors
         Inputs:  Production quantities and prices and user quantities
                  User differentiated prices or tariffs (for electricity only)
         Caution: Maintain fossil fuel SAM entries

 STEP 4: Separate out electricity utlity enterprise
         Inputs:  Utility expenditure shares
                  User-specific electricity prices

 STEP 5: Adding more detailed coal and solar energy
         Inputs:

 STEP 6: Adding more detailed savings and investment for energy subsectors
         Inputs:

 STEP 7: Checking for SAM imbalances or negative entries
         Inputs:

$offtext

$call "gdxxrw i=%energy% o=energy.gdx index=index!a15"
$gdxin energy.gdx

SET
*Sets
 AC              Global accounts
 ACNT(AC)        Global accounts without total
 A(AC)           Activities
 AF(A)           Activities: Fuels (petroleum)
 AE(A)           Activities: Electricity
 C(AC)           Commodities
 F(AC)           Factors
 UF(AC)          Users: Fuels (petroleum)
 UE(AC)          Users: Electricity
 UI(AC)          Users: Industry
 UT(AC)          Users: Transport
 UA(AC)          Users: Agriculture
 UC(AC)          Users: Commerce and public services
 UH(AC)          Users: Households (residential)
 US(AC)          Users: Stocks (and investment)
 USE(AC)         Users: Energy investment
 UO(AC)          Users: All domestic consumers except electricity and petroleum
 EBAC            Energy balance accounts
 TAX(AC)         Tax accounts
*Sets mappings
 MON(A,A)        Mapping: Old to new activities
 MAC(A,C)        Mapping: Activities to commodities
 MEA(EBAC,AC)    Mapping: Energy balance and global accounts
*Sets used to generate energy SAM and reporting
 PR              prices / prod, impt, expt, demd, elec, petr/
 CE(C)           energy products
 CPETRPR(C)      petroleum products
;

$load AC A AF AE C F UF UE UI UT UA UC UH US USE TAX EBAC
$loaddc MON MAC MEA

 ACNT(AC) = YES;
 ACNT('TOTAL') = NO;

*Used for improving splitting coal and better matching between EB and SAM
Sets
 H(AC) /hhd-0,hhd-1,hhd-2,hhd-3,hhd-4,hhd-5,hhd-6,hhd-7,hhd-8,hhd-91,hhd-92,hhd-93,hhd-94,hhd-95/
 CMIN(AC) /cmore, cmine/
;

 UO(ACNT)      = YES;
 UO(AC)$UF(AC) = NO;
 UO(AC)$UE(AC) = NO;
 UO('aelec')   = NO;
 UO('apetr')   = NO;
 UO('abchm')   = NO;
 UO('aochm')   = NO;
 UO('arubb')   = NO;
 UO('aplas')   = NO;
 UO('acoal')   = NO;
 UO('ROW')     = NO;

ALIAS (AC,ACP), (A,AP), (C,CP), (H,HP), (ACNT,ACNTP), (UH,UHP), (UO,UOP), (UF,UFP), (UE,UEP), (USE,USEP);

PARAMETER
*Data from Excel
 SAM(AC,ACP)     energy SAM
 EBAL(EBAC,A)    energy balance table (summarized)
 ETAB(AC,*)      electricity generation table (by subsector)
 FTAB(AC,*)      petroleum fuel production table (by subsector)
 XPRICE(C,PR)    external estimates for energy producer and market prices
 PCHOICE(C,PR)   use external (0) or SAM-based (1) prices?
 TECH(AC,AC)     technology coefficients for new energy subsectors
 EUTIL(AC)       electricity utility expenditure shares
 EDEM(AC,*)      electricity demand and price data from utility
 EPRICES(AC)     electricity price differences
*Data generated in GAMS
 SPRICE(C,PR)    energy producer and market prices implied by the SAM and EBAL
 FPRICE(C,PR)    final energy producer and market prices used in GAMS
 EFUEL(*,*)      volumes of peroleum liquid fuels
 LFPRICE2(c)
;

$loaddc SAM EBAL ETAB FTAB XPRICE EUTIL EDEM CE CPETRPR TECH EFUEL LFPRICE2

 ALIAS  (CPETRPR,CPETRPRP);

Parameter
 Temp(AC,*)      temporary placeholder
 BALCHCK(*)
;

*-------------------------------------------------------------------------------
* STEP 1: Split coal and better match EB and SAM data using differential pricing
* ------------------------------------------------------------------------------
*2.1 Estimates of what coal values should be
Parameter
 coal_est(*,*,ac)        coal value using ew price for commodity
 coal_shr(EBAC,A)        shares for splitting energy balance sector volumes to SAM sectors
 coal_shrh(EBAC,H)       shares for splitting energy balance household volumes to SAM households
 MEH(EBAC,H)             mapping energy balance and SAM households
;

Set
 H1(H) high income households /hhd-8,hhd-91,hhd-92,hhd-93,hhd-94,hhd-95/
 H2(H) low income households /hhd-0,hhd-1,hhd-2,hhd-3,hhd-4/
 H3(H) middle income households /hhd-5,hhd-6,hhd-7/
 ATRA(A) /altrp, awtrp, aatrp, altrp-p, altrp-f/
;

 MEH(EBAC, H)=NO;
 MEH('h1',H1)=YES;
 MEH('h2',H2)=YES;
 MEH('h3',H3)=YES;

*shift coal use out of transport. move into other transport services, assume rest of transport consumes
*more of this
 SAM('ccoal','atrps')=SAM('ccoal','atrps')
                         +SAM('ccoal','awtrp')
                         +SAM('ccoal','aatrp')
                         +SAM('ccoal','altrp-p')
                         +SAM('ccoal','altrp-f');

 SAM('atrps','ctrps')    =SAM('atrps','ctrps')
                         +SAM('ccoal','awtrp')
                         +SAM('ccoal','aatrp')
                         +SAM('ccoal','altrp-p')
                         +SAM('ccoal','altrp-f');

 SAM('ctrps','awtrp')    =SAM('ctrps','awtrp')  +SAM('ccoal','awtrp');
 SAM('ctrps','aatrp')    =SAM('ctrps','aatrp')  +SAM('ccoal','aatrp');
 SAM('ctrps','altrp-p')  =SAM('ctrps','altrp-p')+SAM('ccoal','altrp-p');
 SAM('ctrps','altrp-f')  =SAM('ctrps','altrp-f')+SAM('ccoal','altrp-f');

 SAM('ccoal','awtrp')  =0;
 SAM('ccoal','aatrp')  =0;
 SAM('ccoal','altrp-p')=0;
 SAM('ccoal','altrp-f')=0;

 coal_shr(EBAC,A)$(SUM(AP$MEA(EBAC,AP),SAM('CCOAL',AP)) and MEA(EBAC,A) and not MEA('amin',A))
                         = SAM('CCOAL',A)/SUM(AP$MEA(EBAC,AP),SAM('CCOAL',AP));

*Mining treated differently as high grade coal use is removed from the coal mining sector
 coal_shr('amin','agold')=SAM('CCOAL','agold')/(SAM('CCOAL','agold')
                         +SAM('CCOAL','amore')+SAM('CCOAL','amine'));
 coal_shr('amin','amore')=SAM('CCOAL','amore')/(SAM('CCOAL','agold')
                         +SAM('CCOAL','amore')+SAM('CCOAL','amine'));
 coal_shr('amin','amine')=SAM('CCOAL','amine')/(SAM('CCOAL','agold')
                         +SAM('CCOAL','amore')+SAM('CCOAL','amine'));
 coal_shr('amin','acoal')=0;

 coal_shrh(EBAC,H)$MEH(EBAC,H)= SAM('CCOAL',H)/SUM(HP$MEH(EBAC,HP),SAM('CCOAL',HP));

*low grade coal value estimates - used for calculatin subsidy/premium and ------
*also for new values for consumption--------------------------------------------
 coal_est('low','prod','total') =(XPRICE('CCOAL-LOW','PROD')*EBAL('PROD','ACOAL-LOW'));
 coal_est('low','imp','total')  =(XPRICE('CCOAL-LOW','impt')*EBAL('imp' ,'ACOAL-LOW'));
 coal_est('low','exp','total')  =(XPRICE('CCOAL-LOW','expt')*EBAL('exp' ,'ACOAL-LOW'));
 coal_est('low','dem','aelec') =(XPRICE('CCOAL-LOW','elec')*EBAL('aelc','ACOAL-LOW'));
 coal_est('low','dem','apetr') =(XPRICE('CCOAL-LOW','petr')*EBAL('aref','ACOAL-LOW'));
 coal_est('low','dem',A)$MEA('airo',A)        = coal_shr('airo',A)
                                 *(XPRICE('CCOAL-LOW','demd')*EBAL('airo','ACOAL-LOW'));
 coal_est('low','dem',A)$MEA('achm',A)        = coal_shr('achm',A)
                                 *(XPRICE('CCOAL-LOW','demd')*EBAL('achm','ACOAL-LOW'));
 coal_est('low','dem','acoal')  = XPRICE('CCOAL-LOW','demd')*EBAL('amin','ACOAL-LOW');

*high grade coal

 coal_est('high','prod','total') =(XPRICE('CCOAL-HGH','PROD')*EBAL('PROD' ,'ACOAL-HGH'));
 coal_est('high','imp','total')  =(XPRICE('CCOAL-HGH','impt')*EBAL('imp'  ,'ACOAL-HGH'));
 coal_est('high','exp','total')  =(XPRICE('CCOAL-HGH','expt')*EBAL('exp'  ,'ACOAL-HGH'));
 coal_est('high','dem',A)        = sum(EBAC$MEA(EBAC,A),coal_shr(EBAC,A))
                                 *(XPRICE('CCOAL-HGH','demd')*sum(EBAC$MEA(EBAC,A),EBAL(EBAC,'ACOAL-HGH')));
 coal_est('high','dem',A)$MEA('airo',A)        = coal_shr('airo',A)
                                 *(XPRICE('CCOAL-HGH','demd')*EBAL('airo','ACOAL-HGH'));
 coal_est('high','dem',A)$MEA('amin',A)        = coal_shr('amin',A)
                                 *(XPRICE('CCOAL-HGH','demd')*EBAL('amin','ACOAL-HGH'));
 coal_est('high','dem',H)        = sum(EBAC$MEH(EBAC,H),coal_shrh(EBAC,H))
                                 *(XPRICE('CCOAL-HGH','demd')*sum(EBAC$MEH(EBAC,H),EBAL(EBAC,'ACOAL-HGH')));

*2.2 Splitting between high and low grade coal

*Coal demand - activities
 SAM('ccoal-low','aelec')        = SAM('ccoal','aelec');
 SAM('ccoal-low','apetr')        = SAM('ccoal','apetr');
*using electricity price
 SAM('ccoal-low',A)$MEA('airo',A)= coal_shr('airo',A)*
                                  ((SAM('ccoal','aelec')/ebal('aelc','acoal-low'))*
                                   EBAL('airo','ACOAL-LOW'));
 SAM('ccoal-low',A)$MEA('achm',A)= coal_shr('achm',A)*sum(AP$MEA('achm',AP),SAM('ccoal',AP));
*using refinery price
 SAM('ccoal-low','acoal')        = ((SAM('ccoal','apetr')/ebal('aref','acoal-low'))*
                                   EBAL('amin','ACOAL-LOW'));

 SAM('ccoal-hgh',UO)             = SAM('ccoal',UO);
 SAM('ccoal-hgh',H)              = SAM('ccoal',H);
 SAM('ccoal-hgh',A)$MEA('airo',A)= SAM('ccoal',A)- SAM('ccoal-low',A);

 SAM('ccoal-hgh',A)$MEA('amin',A)= coal_shr('amin',A)*(SUM(AP$MEA('amin',AP),SAM('ccoal',AP))
                                 -SAM('ccoal-low','acoal'));
 SAM('ccoal-hgh','acoal')        =0;

*Coal demand - exports
 SAM('ccoal-hgh','row')= SAM('ccoal','row');
 SAM('ccoal','row')=0;

*Coal commodity
 SAM('row','ccoal-hgh')  =SAM('row','ccoal');
 SAM('trc','ccoal-hgh')  =SAM('trc','ccoal');
 SAM('stax','ccoal-hgh') =SAM('stax','ccoal');
 SAM('mtax','ccoal-hgh') =SAM('mtax','ccoal');

*Supply of coal
 SAM('acoal','ccoal-hgh')= coal_est('high','prod','total');
*sum(ACNT,SAM('ccoal-hgh',ACNT))-
*                         (SAM('row','ccoal-hgh')+SAM('trc','ccoal-hgh')
*                         +SAM('stax','ccoal-hgh')+SAM('mtax','ccoal-hgh'));
 SAM('acoal','ccoal-low')= coal_est('low','prod','total');
*sum(ACNT,SAM('ccoal-low',ACNT));

 SAM('ccoal',AC) = 0;
 SAM(AC,'ccoal') = 0;

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
*Expenditure-Income
 BALCHCK(ACNT)= SAM('TOTAL',ACNT)-SAM(ACNT,'TOTAL');

*balancing SAM
*coal consumption of all other mining categories declines as it is shifted to the coal sector
*to present coal washing. In line the production by other sectors of ores and other mining commodities is decreased.
*This production is now done by the coal mining sector who already produces these commodities.
 SAM('agold','cmore')= SAM('agold','cmore')-BALCHCK('agold');
 SAM('amore','cmore')= SAM('amore','cmore')-BALCHCK('amore');
 SAM('amine','cmine')= SAM('amine','cmine')-BALCHCK('amine');

 SAM('acoal','cmore')= SAM('acoal','cmore')+BALCHCK('agold')+BALCHCK('amore');
 SAM('acoal','cmine')= SAM('acoal','cmine')+BALCHCK('amine');

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
*Expenditure-Income
 BALCHCK(ACNT)= SAM('TOTAL',ACNT)-SAM(ACNT,'TOTAL');

*2.3 Calculating premium/subsidy
*need utax-cl and utax-ch
*including taxes/subisdies to account for price differences
 SAM('utax-ch',A)$(SAM('ccoal-hgh',A) and not ATRA(A))= SAM('ccoal-hgh',A)-coal_est('high','dem',A);
 SAM('utax-ch',H)$SAM('ccoal-hgh',H)= SAM('ccoal-hgh',H)-coal_est('high','dem',H);
* SAM('utax-ch','row')$SAM('ccoal-hgh','row')= SAM('ccoal-hgh','row')-coal_est('high','exp','total');
 SAM('utax-cl',A)$SAM('ccoal-low',A)= SAM('ccoal-low',A)-coal_est('low','dem',A);

*Pay total tax earnings to enterprise (should be zero if calculation was correct)
 SAM('ent','utax-cl')  = sum(ACNT,SAM('utax-cl',ACNT));
 SAM('ent','utax-ch')  = sum(ACNT,SAM('utax-ch',ACNT));
 SAM('ent','utax-cl')$(ABS(SAM('ent','utax-cl')) GT 1E-6) = 1/0;
 SAM('ent','utax-ch')$(ABS(SAM('ent','utax-ch')) GT 1E-6) = 1/0;

*2.4 Calculating premium/subsidy
*setting coal values to estimates to ensure that correct volumes are achieved
*Coal demand
 SAM('ccoal-hgh',A)= coal_est('high','dem',A);
 SAM('ccoal-hgh',H)= coal_est('high','dem',H);
 SAM('ccoal-hgh','row')= coal_est('high','exp','total');
 SAM('ccoal-low',A)= coal_est('low','dem',A);

 SAM('acoal','ccoal-hgh')=coal_est('high','prod','total');
 SAM('acoal','ccoal-low')=coal_est('low','prod','total');

*Balance check
 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));

*FH 15052019
 UO(ACNT)      = YES;
 UO(AC)$UF(AC) = NO;
 UO(AC)$UE(AC) = NO;
 UO('AELEC')   = NO;
 UO('APETR')   = NO;
 UO('ROW')     = NO;

*-------------------------------------------------------------------------------
* STEP 2: Separate out fossil fuels from aggregate mining sector (oil)
* ------------------------------------------------------------------------------
*2.1: Crude oil --------------------------------
 SAM(ACNT,'ACOIL') = TECH(ACNT,'ACOIL')*(XPRICE('CCOIL','PROD')*EBAL('PROD','ACOIL'));

*Marketed output (if crude oil  is already in SAM then use first line, otherwise use second)
* SAM('ACOIL',C) = SAM('ACOIL',C) / SUM(CP, SAM('ACOIL',CP)) * SUM(ACNT, SAM(ACNT,'ACOIL'));
 SAM('ACOIL','CCOIL') = SUM(ACNT, SAM(ACNT,'ACOIL'));

*Exports
 SAM('CCOIL','ROW') = XPRICE('CCOIL','EXPT')*EBAL('EXP','ACOIL');

*Imports
 SAM('ROW','CCOIL') = XPRICE('CCOIL','IMPT')*EBAL('IMP','ACOIL');

*Domestic consumption
* Oil refineries demand
 SAM('CCOIL','APETR') = XPRICE('CCOIL','PETR')*EBAL('AREF','ACOIL');

*Add crude oil's own use to mining's calculated use of crude oil (double-count to prepare for subtraction below)
 SAM('CCOIL','AMINE') = SAM('CCOIL','AMINE') + SAM('CCOIL','ACOIL');

* Remove crude oil from mining (if crude oil does not already appear in the SAM, other do not use this code)
 SAM('AMINE','CMINE') = SAM('AMINE','CMINE') - SAM('ACOIL','CCOIL');
 SAM(ACNT,'AMINE') = SAM(ACNT,'AMINE') - SAM(ACNT,'ACOIL');
 SAM('CMINE',ACNT) = SAM('CMINE',ACNT) - SAM('CCOIL',ACNT);
 SAM(ACNT,'CMINE')$(NOT A(ACNT)) = SAM(ACNT,'CMINE') - SAM(ACNT,'CCOIL');

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));

*2.3: Natural gas ------------------------------

*Production (if natural gas is already in SAM then use first line, otherwise use second)
* SAM(ACNT,'ANGAS')$SAM('TOTAL','ANGAS') = SAM(ACNT,'ANGAS')/SAM('TOTAL','ANGAS') * (FPRICE('CNGAS','PROD')*EBAL('PROD','ANGAS')/CEUNIT('CNGAS'));
 SAM(ACNT,'ANGAS') = TECH(ACNT,'ANGAS') * (XPRICE('CNGAS','PROD')*EBAL('PROD','ANGAS'));

*Marketed output (if crude oil  is already in SAM then use first line, otherwise use second)
* SAM('ANGAS',C) = SAM('ANGAS',C) / SUM(CP, SAM('ANGAS',CP)) * SUM(ACNT, SAM(ACNT,'ANGAS'));
 SAM('ANGAS','CNGAS') = SUM(ACNT, SAM(ACNT,'ANGAS'));

*Exports
 SAM('CNGAS','ROW') = XPRICE('CNGAS','EXPT')*EBAL('EXP','ANGAS');

*Imports
 SAM('ROW','CNGAS') = XPRICE('CNGAS','IMPT')*EBAL('IMP','ANGAS');

*Domestic consumption
* Gas-to-liquid demand
 SAM('CNGAS','APETR') = XPRICE('CNGAS','PETR')*EBAL('AREF','ANGAS');
* Gas electricity demand
 SAM('CNGAS','AELEC') = XPRICE('CNGAS','ELEC')*EBAL('AELC','ANGAS');

* All remaining direct consumers of natural gas (or gas works gas)
 SAM('CNGAS',ACNT)$SUM(EBAC$MEA(EBAC,ACNT), EBAL(EBAC,'ANGAS')) =
         XPRICE('CNGAS','DEMD')*SUM(EBAC$MEA(EBAC,ACNT), EBAL(EBAC,'ANGAS'))
   * SAM('CMINE',ACNT) / SUM((EBAC,ACNTP)$(MEA(EBAC,ACNT) AND MEA(EBAC,ACNTP)), SAM('CMINE',ACNTP));

*FH!Issues with subtracting cngas from amine. Use stocks to assist. Essentially shifting other mining stocks
*to respecctive sectors

 Parameter
 temp2(c,a)
 ;

 Temp2('cmine','airon')=-(SAM('cmine','airon')-xprice('cngas','demd')*ebal('airo','angas'));
 Temp2('cmine','apapr')=-(SAM('cmine','apapr')-xprice('cngas','demd')*ebal('apap','angas'));
 Temp2('cmine','anfrm')=-(SAM('cmine','anfrm')-xprice('cngas','demd')*ebal('anfrm','angas'));
 Temp2('cmine','ametp')=-(SAM('cmine','ametp')-(XPRICE('cngas','demd')*EBAL('airo','angas')
         *SAM('cmine','ametp')/(SAM('cmine','ametp')+SAM('cmine','airon'))));

 SAM(c,a)=SAM(c,a)+Temp2(c,a);
 SAM(a,c)=SAM(a,c)+sum(cp$MAC(a,c),Temp2(cp,a));
 SAM('cmine','dstk')=SAM('cmine','dstk')-sum(a,Temp2('cmine',a));
 SAM(c,'dstk')=SAM(c,'dstk')+sum(a$MAC(a,c),Temp2('cmine',a));

*Add natural gas' own use to mining's calculated use of natural gas (double-count to prepare for subtraction below)
 SAM('CNGAS','AMINE') = SAM('CNGAS','AMINE') + SAM('CNGAS','ANGAS');
* Remove natural gas from mining (if natural gas does not already appear in the SAM, other do not use this code)
 SAM(ACNT,'AMINE') = SAM(ACNT,'AMINE') - SAM(ACNT,'ANGAS');
 SAM('AMINE','CMINE') = SAM('AMINE','CMINE') - SAM('ANGAS','CNGAS');
 SAM(ACNT,'CMINE')$(NOT A(ACNT)) = SAM(ACNT,'CMINE') - SAM(ACNT,'CNGAS');
 SAM('CMINE',ACNT) = SAM('CMINE',ACNT) - SAM('CNGAS',ACNT);

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));

* ------------------------------------------------------------------------------
* STEP 7: ADDING IN HYDROGEN
* ------------------------------------------------------------------------------
*FH: 6/6/17
*1. New sector: hydrogen
*NB! No sales tax etc. applied
 Parameter
 shrangas(AC,AC);

 SAM('ahydr','chydr') = 1;
 SAM('abchm','cbchm') = SAM('abchm','cbchm')-SAM('ahydr','chydr');

 SAM(ACNT,'ahydr') = SAM('ahydr','chydr')*(SAM(ACNT,'abchm')/sum(ACNTP,SAM(ACNTP,'abchm')));
 SAM(ACNT,'abchm')=SAM(ACNT,'abchm')-SAM(ACNT,'ahydr');

 SAM('chydr','altrp-f')=SAM('ahydr','chydr');
 SAM('cbchm','altrp-f')=SAM('cbchm','altrp-f')-SAM('chydr','altrp-f');

*Calculate new totals
 SAM(ACNT,'TOTAL') = SUM(ACNTP, SAM(ACNT,ACNTP));
 SAM('TOTAL',ACNT) = SUM(ACNTP, SAM(ACNTP,ACNT));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* STEP 3: Petrol and electricity
* ------------------------------------------------------------------------------
$ontext
*3.1: Petrol ------------------------
SET
 EDEMA(EBAC) /aaff, amin, afab, aoin, apap, airo, acom, atra, atrl_p, atrl_f, h1, h2, h3/
;

PARAMETER
* APETRSHR(EDEMA,CPETRPR)
 APETRSHR(CPETRPR)
;

ALIAS (AE,AEP), (AF,AFP);

*Production
* SAM(ACNT,'APETR')$SAM('TOTAL','APETR') = SAM(ACNT,'APETR')/SAM('TOTAL','APETR')*(XPRICE('cpetr_p','PROD')*EBAL('PROD','APETR'));
 SAM(ACNT,'APETR')$SAM('TOTAL','APETR') = SAM(ACNT,'APETR')/SAM('TOTAL','APETR')*(EFUEL('PROD','DIESEL')*LFPRICE2('CPETR_D')
                                         +EFUEL('PROD','PETROL')*LFPRICE2('CPETR_P')+EFUEL('PROD','OTHER')*LFPRICE2('CPETR_O'));

*Marketed output
 SAM('APETR',C) = SAM('APETR',C) / SUM(CP, SAM('APETR',CP)) * SUM(ACNT, SAM(ACNT,'APETR'));

*Exports
 SAM(CPETRPR,'ROW')$SUM(CPETRPRP,EFUEL('EXP',CPETRPRP)) = XPRICE(CPETRPR,'EXPT')*(EBAL('EXP','APETR')*(EFUEL('EXP',CPETRPR)/SUM(CPETRPRP,EFUEL('EXP',CPETRPRP))));

*Imports
 SAM('ROW',CPETRPR)$SUM(CPETRPRP,EFUEL('IMP',CPETRPRP))= XPRICE(CPETRPR,'IMPT')*(EBAL('IMP','APETR')*(EFUEL('IMP',CPETRPR)/SUM(CPETRPRP,EFUEL('IMP',CPETRPRP))));

*Domestic consumption
* Coal-fired electricity demand
 SAM(CPETRPR,'AELEC')$SUM((AEP,CPETRPRP),EFUEL(AEP,CPETRPRP)) = XPRICE(CPETRPR,'ELEC')*(EBAL('AELC','APETR')*SUM(AE,(EFUEL(AE,CPETRPR))/SUM((AEP,CPETRPRP),EFUEL(AEP,CPETRPRP))));

* Coal-to-liquid demand
 SAM(CPETRPR,'APETR')$SUM((AFP,CPETRPRP),EFUEL(AFP,CPETRPRP)) = XPRICE(CPETRPR,'PETR')*(EBAL('AREF','APETR')*SUM(AF,(EFUEL(AF,CPETRPR))/SUM((AFP,CPETRPRP),EFUEL(AFP,CPETRPRP))));

 APETRSHR('CPETR_P')=SUM(EDEMA,EFUEL(EDEMA,'PETROL'))/SUM(EDEMA,EFUEL(EDEMA,'PETROL')+EFUEL(EDEMA,'DIESEL')+EFUEL(EDEMA,'OTHER'));
 APETRSHR('CPETR_D')=SUM(EDEMA,EFUEL(EDEMA,'DIESEL'))/SUM(EDEMA,EFUEL(EDEMA,'PETROL')+EFUEL(EDEMA,'DIESEL')+EFUEL(EDEMA,'OTHER'));
 APETRSHR('CPETR_O')=SUM(EDEMA,EFUEL(EDEMA,'OTHER'))/SUM(EDEMA,EFUEL(EDEMA,'PETROL')+EFUEL(EDEMA,'DIESEL')+EFUEL(EDEMA,'OTHER'));
*$exit
* APETRSHR(EDEMA,'CPETR_P')=EFUEL(EDEMA,'PETROL')/(EFUEL(EDEMA,'PETROL')+EFUEL(EDEMA,'DIESEL')+EFUEL(EDEMA,'OTHER'));
* APETRSHR(EDEMA,'CPETR_D')=EFUEL(EDEMA,'DIESEL')/(EFUEL(EDEMA,'PETROL')+EFUEL(EDEMA,'DIESEL')+EFUEL(EDEMA,'OTHER'));
* APETRSHR(EDEMA,'CPETR_O')=EFUEL(EDEMA,'OTHER') /(EFUEL(EDEMA,'PETROL')+EFUEL(EDEMA,'DIESEL')+EFUEL(EDEMA,'OTHER'));

*$ONTEXT
parameter
 cpetrpr_shr(CPETRPR,A)
 cpetrpr_shrh(CPETRPR,H)
;

 cpetrpr_shr(CPETRPR,A)$(SUM(EBAC$MEA(EBAC,A),(SUM((AP)$MEA(EBAC,AP),SAM(CPETRPR,AP)))))
         =SAM(CPETRPR,A)/SUM(EBAC$MEA(EBAC,A),(SUM((AP)$MEA(EBAC,AP),SAM(CPETRPR,AP))));
 cpetrpr_shrh(CPETRPR,H)
         =SAM(CPETRPR,H)/SUM(EBAC$MEH(EBAC,H),(SUM((HP)$MEH(EBAC,HP),SAM(CPETRPR,HP))));
****$OFFTEXT

* All remaining consumers of petroleum (demand spread proportionally based on SAM expenditure values)
 SAM(CPETRPR,UO) = SAM(CPETRPR,UO)/SUM(UOP,SAM(CPETRPR,UOP))*XPRICE(CPETRPR,'DEMD')
         *((EBAL('DEMAND','APETR')-EBAL('AELC','APETR')-EBAL('AREF','APETR'))*APETRSHR(CPETRPR));
* SAM(CPETRPR,A)=cpetrpr_shr(CPETRPR,A)*SUM(EDEMA$MEA(EDEMA,A),XPRICE(CPETRPR,'DEMD')*(XPRICE(CPETRPR,'DEMD')*((EBAL(EDEMA,'APETR')*APETRSHR(EDEMA,CPETRPR)))));
* SAM(CPETRPR,H)=cpetrpr_shrh(CPETRPR,H)*SUM(EDEMA$MEH(EDEMA,H),XPRICE(CPETRPR,'DEMD')*(XPRICE(CPETRPR,'DEMD')*((EBAL(EDEMA,'APETR')*APETRSHR(EDEMA,CPETRPR)))));

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));
*$EXIT
$offtext
*3.2: Electricity ------------------------

*Production
 SAM(ACNT,'AELEC')$SAM('TOTAL','AELEC') = SAM(ACNT,'AELEC')/SAM('TOTAL','AELEC')*(XPRICE('celec','PROD')*EBAL('PROD','AELEC'));

*Marketed output
 SAM('AELEC',C) = SAM('AELEC',C)/SUM(CP, SAM('AELEC',CP)) * SUM(ACNT, SAM(ACNT,'AELEC'));

*Exports
 SAM('CELEC','ROW') = XPRICE('CELEC','EXPT')*EBAL('EXP','AELEC');

*Imports
 SAM('ROW','CELEC') = XPRICE('CELEC','IMPT')*EBAL('IMP','AELEC');

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));

*-------------------------------------------------------------------------------
* STEP 4: Separate out electricity utlity enterprise
* ------------------------------------------------------------------------------
*4.1 Electricity utility enterprise -------------------

* Convert physical capital into energy capital
 SAM('FEGY','AELEC') = SAM('FCAP','AELEC');
 SAM('FCAP','AELEC') = 0;
* Remove energy capital from physical capital payments to normal enterprises
 SAM('ENT-E','FEGY') = SUM(A, SAM('FEGY',A));
 SAM('ENT','FCAP') = SAM('ENT','FCAP') - SAM('ENT-E','FEGY');
* Utility expenditures based on externally determined profile
 SAM(ACNT,'ENT-E') = SUM(ACNTP, SAM('ENT-E',ACNTP)) * (EUTIL(ACNT)/SUM(ACNTP,EUTIL(ACNTP)));

*FH INCLUDED CODE TO ACCOUNT FOR NO (ENT,ROW) PYMENTS IN CURRENT STRUCTURE OF SAM
 SAM('ENT','FCAP')=SAM('ENT','FCAP')+SAM('ROW','ENT-E');
 SAM('ROW','ENT')= SAM('ROW','ENT')+SAM('ROW','ENT-E');
 SAM('ROW','FCAP')= SAM('ROW','FCAP')-SAM('ROW','ENT-E');

* Remove utility payments from normal enterprise payments
*2012 SAM HAS FCAP PAYMENT TO ROW. JT SAM HAS ENT WHICH SHOULD IT BE?
 SAM(ACNT,'ENT') = SAM(ACNT,'ENT') - SAM(ACNT,'ENT-E');
* Correct for multiple savings options for utilities
 SAM('S-I','ENT') = SAM('S-I','ENT') + SAM('S-E','ENT');
 SAM('S-E','ENT') = 0;
* Distribute utility electricity power plant savings into investment demand
 SAM(C,'S-E') = SAM(C,'S-I')/SUM(CP, SAM(CP,'S-I')) * SAM('S-E','ENT-E');
 SAM(C,'S-I') = SAM(C,'S-I') - SAM(C,'S-E');
*Move ent to ent-n
 SAM(ACNT,'ENT-N') = SAM(ACNT,'ENT');
 SAM('ENT-N',ACNT) = SAM('ENT',ACNT);
 SAM(ACNT,'ENT') = 0;
 SAM('ENT',ACNT) = 0;

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));

*4.2 Electricity price subsidies and taxes ----------------

* Adjust electricity purchases in the IO table to reflect average market price
* and include implicit subsidy/tax for individual users

* Make electricity demand table consistent with SAM expenditures (assume utility prices)
 EDEM(AC,'Rm')  = 0;
 EDEM(AC,'PJ') = 0;
 EDEM(A,'Rm')   = SAM('CELEC',A);
 EDEM(UH,'Rm')  = SAM('CELEC',UH);
 EDEM(ACNT,'PJ')$EDEM(ACNT,'R mil/PJ') = EDEM(ACNT,'Rm') / EDEM(ACNT,'R mil/PJ');
 EDEM('TOTAL','PJ') = SUM(ACNT,  EDEM(ACNT,'PJ'));
 EDEM('TOTAL','Rm')  = SUM(ACNT,  EDEM(ACNT,'Rm'));
 EDEM('TOTAL','R mil/PJ') = EDEM('TOTAL','Rm')/EDEM('TOTAL','PJ');

*Normalize direct electricity prices and assign tax/subsidy
 SAM('UTAX',ACNT)$EDEM(ACNT,'Rm')  = SAM('CELEC',ACNT) - EDEM(ACNT,'PJ')*EDEM('TOTAL','R mil/PJ');
 SAM('CELEC',ACNT)$EDEM(ACNT,'Rm') = EDEM(ACNT,'PJ')*EDEM('TOTAL','R mil/PJ');

*Pay total tax earnings to electricity enterprise (should be zero if calculation was correct)
 SAM('ENT-E','UTAX') = SUM(ACNT, SAM('UTAX',ACNT));
 SAM('ENT-E','UTAX')$(ABS(SAM('ENT-E','UTAX')) GT 1E-6) = 1/0;

 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 BALCHCK(ACNT)= SUM(ACNTP, SAM(ACNT,ACNTP)) - SUM(ACNTP, SAM(ACNTP,ACNT));

*-------------------------------------------------------------------------------
* STEP 6: Imported tech
* ------------------------------------------------------------------------------
Parameter
 IMPTECH(C,AC);

 IMPTECH(C,AC)=0;
*0.35 IS CHOSEN AS NO SOLAR PV OR WIND EXISTS IN 2012
 IMPTECH('CMACH','AELEC')=0.35;
 IMPTECH('CEMCH','AELEC')=0.35;
 IMPTECH('CMACH','S-E')=0.35;
 IMPTECH('CEMCH','S-E')=0.35;

*Create technology commodity
 SAM('CIMPT',A) = SUM(C, SAM(C,A)*IMPTECH(C,A));

* Sales taxes
 SAM('STAX','CIMPT') = SUM(C, SAM('STAX',C)/(SUM(ACNT, SAM(C,ACNT))-SAM(C,'ROW')) * SUM(A, SAM(C,A)*IMPTECH(C,A)));

* Transaction costs
 SAM('TRC','CIMPT')  = SUM(C, SAM('TRC',C)/SUM(ACNT, SAM(C,ACNT)) * SUM(A, SAM(C,A)*IMPTECH(C,A)));

* Import taxes
 SAM('MTAX','CIMPT') = SUM(C, SAM('MTAX',C)/(SUM(ACNT, SAM(C,ACNT))-SAM(C,'ROW')) * SUM(A, SAM(C,A)*IMPTECH(C,A)));

*Residual is imported technology
 SAM('ROW','CIMPT') = SUM(C, SUM(A, SAM(C,A)*IMPTECH(C,A))) - SAM('STAX','CIMPT') - SAM('TRC','CIMPT') - SAM('MTAX','CIMPT');

*Remove imports from existing intermediates (add back in sales taxes, import taxes and transaction costs
 SAM('ROW',C)       = SAM('ROW',C) - SUM(A, SAM(C,A)*IMPTECH(C,A))
         + SAM('STAX',C)/(SUM(ACNT, SAM(C,ACNT))-SAM(C,'ROW')) * SUM(A, SAM(C,A)*IMPTECH(C,A))
         + SAM('TRC',C)/SUM(ACNT, SAM(C,ACNT)) * SUM(A, SAM(C,A)*IMPTECH(C,A))
         + SAM('MTAX',C)/(SUM(ACNT, SAM(C,ACNT))-SAM(C,'ROW')) * SUM(A, SAM(C,A)*IMPTECH(C,A))
;

*Remove sales taxes, import taxes and transaction costs from existing intermediates
 SAM('STAX',C) = SAM('STAX',C) - SAM('STAX',C)/(SUM(ACNT, SAM(C,ACNT))-SAM(C,'ROW')) * SUM(A, SAM(C,A)*IMPTECH(C,A));
 SAM('TRC',C)  = SAM('TRC',C)  - SAM('TRC',C)/SUM(ACNT, SAM(C,ACNT)) * SUM(A, SAM(C,A)*IMPTECH(C,A));
 SAM('MTAX',C) = SAM('MTAX',C) - SAM('MTAX',C)/(SUM(ACNT, SAM(C,ACNT))-SAM(C,'ROW')) * SUM(A, SAM(C,A)*IMPTECH(C,A));

*Remove imported tech from existing intermediates
 SAM(C,A) = SAM(C,A)*(1-IMPTECH(C,A));

*Remove import technology from energy investment vector
 SAM('CIMPT','S-E') = SUM(C, SAM(C,'S-E')*IMPTECH(C,'S-E'));
 SAM(C,'S-E') = SAM(C,'S-E')*(1-IMPTECH(C,'S-E'));
 SAM(C,'DSTK')$IMPTECH(C,'S-E') = SAM(C,'DSTK') + SUM(ACNT, SAM(ACNT,C)-SAM(C,ACNT));
 SAM('ROW','CIMPT') = SAM('ROW','CIMPT') + SAM('CIMPT','S-E');
 SAM('DSTK','S-I') = 0;
 SAM('DSTK','S-I') = SUM(C, SAM(C,'DSTK'));
 SAM('S-I','ROW') = 0;
 SAM('S-I','ROW') = SUM(ACNT, SAM(ACNT,'S-I')-SAM('S-I',ACNT));

* ------------------------------------------------------------------------------
* STEP 8: Checking for SAM imbalances or negative entries
* ------------------------------------------------------------------------------

PARAMETER
 CNEG(AC,ACP)    negative cell entries for SAM
 DIFF(AC)        check difference in disaggregated SAM
;

*Check for negatives in energy sector SAM entries
* If in fossil fuels (i.e., mine activities and commodities) then scale prices in Excel
 CNEG(A,ACNT)$(SAM(A,ACNT) LT 0) = SAM(A,ACNT);
 CNEG(ACNT,A)$(SAM(ACNT,A) LT 0) = SAM(ACNT,A);
 CNEG(C,ACNT)$(SAM(C,ACNT) LT 0) = SAM(C,ACNT);
 CNEG(ACNT,C)$(SAM(ACNT,C) LT 0) = SAM(ACNT,C);
*  Remove activity and commodity accounts that are allowed to be negative (i.e., taxes and stocks)
 CNEG(TAX,ACNT) = 0;
 CNEG(C,'DSTK') = 0;

*Calculate new totals
 SAM(ACNT,'TOTAL') = SUM(ACNTP, SAM(ACNT,ACNTP));
 SAM('TOTAL',ACNT) = SUM(ACNTP, SAM(ACNTP,ACNT));

*Calculate row and column differences
 DIFF(ACNT) = SAM(ACNT,'TOTAL') - SAM('TOTAL',ACNT);
 DIFF(ACNT)$(ABS(DIFF(ACNT)) LT 1E-6) = 0;


DISPLAY CNEG, DIFF;

PARAMETER XLTEST;

execute_unload "final.gdx" SAM
execute 'xlstalk.exe -m %final%';
 XLTEST = ERRORLEVEL;
IF(XLTEST = 1,
execute 'xlstalk.exe -c %final%';
);
IF(XLTEST = 2,
execute 'xlstalk.exe -s %final%';
);
execute 'gdxxrw.exe i=final.gdx o=%final% index=index!a2';
execute 'xlstalk.exe -o %final%';
