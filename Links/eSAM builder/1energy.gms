$onempty
*This file takes the disaggregated SAM and develops the detailed energy SAM
*Code of James Thurlow was adjusted

*Excel files used
*SAM aggregation using 1Aggregate.inc
$SETGLOBAL aggregate "1rsaaggregate.xlsx"
*Data for developing energy SAM
$SETGLOBAL energy "0data.xlsx"
$SETGLOBAL energy2 "2rsaenergy2012.xlsx"

*-------------------------------------------------------------------------------
*0. SAM formatting
*-------------------------------------------------------------------------------
*Turn on if first time running new SAM to create aggregate SAM
$include 1Aggregate.inc

*-------------------------------------------------------------------------------
*1. SETS
*-------------------------------------------------------------------------------
SETS
*a. Disaggregated SAM sets
 AC                      global set for all SAM accounts
 ACNT(AC)                all elements in AC except TOTAL
 A(AC)                   activities
 C(AC)                   commodities
 F(AC)                   factors
 FCAP(F)                 capital
 INS(AC)                 institutions
 INSD(INS)               domestic institutions
 INSDNG(INSD)            domestic non-government institutions
 H(INSDNG)               households
 EN(INSDNG)              enterprises

*b. Aggregated SAM sets
 AGGAC                   global set for all SAM accounts
 AGGACNT(AGGAC)          all elements except total
 AGG(AGGAC)              activities
 CAGG(AGGAC)             commodities
 FLAB(AGGAC)             labor
 HAGG(AGGAC)             households
 TAX(AGGAC)              taxes

*c. EB sets
 EBA                     energy demand-supply accounts
 EELEC(EBA)              electricity accounts
 EPETR(EBA)              liquid fuel accounts
 FUEL                    fuel source
 LFUELT(FUEL)            liquid fuel: petrol and diesel
 LFUELO(FUEL)            liquid fuel: paraffin LPG HFA and jet fuel

*d. mappings
 MAC(A,C)
 MAC2(A,C)
 MAGG(A,AGG)
 MCAGG(C,CAGG)
 MHAGG(H,HAGG)
 MAGGAC(AC,AGGAC)
 MECAGGAC(EBA,AGGAC)
;

*--------------------------------------------------------------------------------------------
*2. Database
*--------------------------------------------------------------------------------------------
PARAMETER
 SAM(AC,AC)              standard SAM
 ASAM(AGGAC,AGGAC)       aggregate SAM
 SAMBALCHK1(AC)
 SAMBALCHK2(AGGAC)

 EBAL(EBA,FUEL)          energy balance
 PFUEL(FUEL)             fuel price
 kmshr(HAGG)             km share for private transport
;

$call "gdxxrw i=%energy% o=energy.gdx index=index!a7 checkdate"
$gdxin energy.gdx

$load AC A C F FCAP INS INSD INSDNG H EN AGGAC AGG CAGG FLAB HAGG TAX MAGG MCAGG MHAGG EBA FUEL MAC MAC2 kmshr
$load PFUEL EELEC EPETR LFUELT LFUELO MECAGGAC
$loaddc MAGGAC SAM EBAL

 ACNT(AC)=YES;
 ACNT('TOTAL')=NO;
 ALIAS (ACNT,ACNTP);

 AGGACNT(AGGAC)=YES;
 AGGACNT('TOTAL')=NO;
 ALIAS (AGGACNT,AGGACNTP);

 ALIAS (AC,ACP), (A,AP), (C,CP), (AGGAC,AGGACP), (AGG,AGGP), (H,HP), (HAGG,HAGGP);

*EXPENDITURE-INCOME
 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
 DISPLAY SAMBALCHK1;

$include 2diagonal.inc

*EXPENDITURE-INCOME
 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
 DISPLAY SAMBALCHK1;

*Account for low electricity coal consumption while considering natural gas need
 SAM('acoal','ccoal')=SAM('acoal','ccoal')+(SAM('cmine','aelec')-410.2);
 SAM('acoal','cmine')=SAM('acoal','cmine')-(SAM('cmine','aelec')-410.2);

 SAM('ccoal','aelec')=SAM('ccoal','aelec')+(SAM('cmine','aelec')-410.2);
 SAM('cmine','aelec')=410.2;

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));

*--------------------------------------------------------------------------------------------
*3. Aggregate SAM
*--------------------------------------------------------------------------------------------
*First calculate value of household expenditure on ctyre and cmtvp for use later
*should ships/boats be included? small number - left out for now
Parameter
 htrval(h)
 atrval(a);

 htrval(h)=(SAM('cvehi',h))/1000;
 atrval(a)=SAM('cpetr',a)*(SAM('cvehi','altrp')/sum(acntp,SAM(acntp,'altrp')))/(SAM('cpetr','altrp')/sum(acntp,SAM(acntp,'altrp')))/1000;
$ontext
*Shift non-ferrous metals consumption of liquid fuels to iron. EB reports no liquid fuel consumption for non-ferrous.Iron chosen as a large share of iron
*is consumed by non-ferrous metals and the average price for other fuels (non-petrol and diesel) is higher than the average suggested by the EB.
 SAM('cpetr','airon')=SAM('cpetr','airon')+SAM('cpetr','anfrm');
 SAM('airon','ciron')=SAM('airon','ciron')+SAM('cpetr','anfrm');
 SAM('ciron','anfrm')=SAM('ciron','anfrm')+SAM('cpetr','anfrm');
 SAM('cpetr','anfrm')=0;
$offtext

*Aggregate SAM to match to EB
 ASAM(AGGACNT,AGGACNTP) =SUM((ACNT,ACNTP)$(MAGGAC(ACNT,AGGACNT) and MAGGAC(ACNTP,AGGACNTP)),SAM(ACNT,ACNTP))/1000;
 ASAM(AGGAC,'TOTAL')=SUM(AGGACNTP,ASAM(AGGAC,AGGACNTP));
 ASAM('TOTAL',AGGAC)=SUM(AGGACNTP,ASAM(AGGACNTP,AGGAC));

 SAMBALCHK2(AGGACNT)=SUM(AGGACNTP,ASAM(AGGACNT,AGGACNTP))-SUM(AGGACNTP,ASAM(AGGACNTP,AGGACNT));
 DISPLAY SAMBALCHK2;

*shift dstk into exports
*shift s-i into other - temporary
 ASAM('cref','row')=ASAM('cref','row')+ASAM('cref','dstk');
 ASAM('s-i','row')=ASAM('s-i','row')-ASAM('cref','dstk');
 ASAM('dstk','s-i')=ASAM('dstk','s-i')-ASAM('cref','dstk');
 ASAM('cref','dstk')=0;

 ASAM('cref','aoin')= ASAM('cref','aoin')+ASAM('cref','s-i');
 ASAM('aoin','coin')= ASAM('aoin','coin')+ASAM('cref','s-i');
 ASAM('coin','row') = ASAM('coin','row')+ASAM('cref','s-i');
 ASAM('s-i','row')  = ASAM('s-i','row')-ASAM('cref','s-i');
 ASAM('cref','s-i') =0;

 SAMBALCHK2(AGGACNT)=SUM(AGGACNTP,ASAM(AGGACNT,AGGACNTP))-SUM(AGGACNTP,ASAM(AGGACNTP,AGGACNT));
 DISPLAY SAMBALCHK2;

*--------------------------------------------------------------------------------------------
*3. Calculating energy consumption using energy balance
*--------------------------------------------------------------------------------------------
PARAMETER
 EPROD(FUEL)                    Energy production
 EIMP(FUEL)                     Energy imports
 EEXP(FUEL)                     Energy exports
 EDEM(EBA,FUEL)                 Energy demand
 EBALITEM(FUEL)                 Difference in energy demand and supply
 HPRTRNS(HAGG,FUEL)
;

 HPRTRNS(HAGG,FUEL) = EBAL('atrl_pr',FUEL)*kmshr(HAGG);

 EPROD(FUEL)=EBAL('EXTRACT',FUEL);
 EPROD('ELECTRICITY')=SUM(EELEC,EBAL(EELEC,'ELECTRICITY'));
 EPROD(LFUELT)=SUM(EPETR,EBAL(EPETR,LFUELT));
 EPROD(LFUELO)=SUM(EPETR,EBAL(EPETR,LFUELO));

 EIMP(FUEL)=EBAL('IMP',FUEL);
 EEXP(FUEL)=-EBAL('EXP',FUEL);

 EDEM(EBA,FUEL)=-EBAL(EBA,FUEL);
 EDEM('H1',FUEL)=-(EBAL('H1',FUEL)+HPRTRNS('H1',FUEL));
 EDEM('H2',FUEL)=-(EBAL('H2',FUEL)+HPRTRNS('H2',FUEL));
 EDEM('H3',FUEL)=-(EBAL('H3',FUEL)+HPRTRNS('H3',FUEL));
 EBAL('atrl_pr',FUEL)=0;

 EDEM('atrl_pr',FUEL)=0;
 EDEM(EELEC,'ELECTRICITY')=0;
 EDEM(EPETR,LFUELT)=0;
 EDEM(EPETR,LFUELO)=0;
 EDEM('IMP',FUEL)=0;
 EDEM('EXTRACT',FUEL)=0;
 EDEM('EXP',FUEL)=0;

*Balancing the energy balance by shifting differences into production
 EBALITEM(FUEL)=(EPROD(FUEL)+EIMP(FUEL))-(SUM(EBA,EDEM(EBA,FUEL))+EEXP(FUEL));
 EPROD(FUEL)$EPROD('GAS')=EPROD(FUEL)-EBALITEM(FUEL);
 EIMP('GAS')=EIMP('GAS')-EBALITEM('GAS');

*EBALITEM should now be zero
 EBALITEM(FUEL)=(EPROD(FUEL)+EIMP(FUEL))-(SUM(EBA,EDEM(EBA,FUEL))+EEXP(FUEL));

*--------------------------------------------------------------------------------------------
*4. Reallocation of sector transport use to the land transport sector
*--------------------------------------------------------------------------------------------
Parameter
 trfuelshr(agg)                    share of transport fuel use per sector
 trshr(aggac)                      land transport sector shares
 ebval(EBA,FUEL)                   energy balance value for liquid fuels
 trvaggac(aggac,agg)               values to be extracted from other sectors
 trvaggh(aggac,hagg)               values to be extracted from households
;

*Calculating consumption shares of land transport sector
 trshr(aggacnt)=0;
 trshr('flab')=ASAM('flab',"atrl")/sum(aggacntp,ASAM(aggacntp,"atrl"));
 trshr('cref')=ASAM('cref',"atrl")/sum(aggacntp,ASAM(aggacntp,"atrl"));
*relative to trshr
 trshr(aggacnt)= trshr(aggacnt)/trshr('cref');
*dampened to avoid negative values in SAM
 trshr(aggacnt)=trshr(aggacnt)*0.5;
 trshr('cref')=1;

*Energy balance value of sector fuel usage (divided by billion to be consistent with SAM)
 ebval(EBA,FUEL)  =(EDEM(EBA,FUEL)*PFUEL(FUEL))/1000;
 ebval('exp',FUEL)=(EEXP(FUEL)*PFUEL(FUEL))/1000;
 ebval('imp',FUEL)=(EIMP(FUEL)*PFUEL(FUEL))/1000;

*scale up eb values such that there totals match that in the SAM
*note: SAM numbers reflect more consumption by industry (relative to exports and households)
*than what is implied by the energy balance values. exports and household consumption is
*therefore likely to be lower than that reflected in the energy balance.
 parameter
 scalar1
 scalar2
 scalar3;

 scalar1=sum(AGG,ASAM('cref',AGG))/
          sum(fuel,
             (ebval('aaff',fuel)+
              ebval('amin',fuel)+
              ebval('afab',fuel)+
              ebval('aoin',fuel)+
              ebval('apap',fuel)+
              ebval('airo',fuel)+
              ebval('acom',fuel)+
              ebval('atra',fuel)+
              ebval('aelc_oil',fuel)+
              ebval('atrl_f',fuel)+
              ebval('atrl_p',fuel)));

 scalar2=sum(HAGG,ASAM('cref',HAGG))/
          sum(fuel,
             (ebval('h1',fuel)+
              ebval('h2',fuel)+
              ebval('h3',fuel)));

 scalar3=ASAM('cref','row')/
          sum(fuel,ebval('exp',fuel));

 ebval('aaff',fuel)    = ebval('aaff',fuel)     *scalar1;
 ebval('amin',fuel)    = ebval('amin',fuel)     *scalar1;
 ebval('afab',fuel)    = ebval('afab',fuel)     *scalar1;
 ebval('aoin',fuel)    = ebval('aoin',fuel)     *scalar1;
 ebval('apap',fuel)    = ebval('apap',fuel)     *scalar1;
 ebval('airo',fuel)    = ebval('airo',fuel)     *scalar1;
 ebval('acom',fuel)    = ebval('acom',fuel)     *scalar1;
 ebval('atra',fuel)    = ebval('atra',fuel)     *scalar1;
 ebval('aelc_oil',fuel)= ebval('aelc_oil',fuel) *scalar1;
 ebval('atrl_f',fuel)  = ebval('atrl_f',fuel)   *scalar1;
 ebval('atrl_p',fuel)  = ebval('atrl_p',fuel)   *scalar1;

 ebval('h1',fuel)  = ebval('h1',fuel)   *scalar2;
 ebval('h2',fuel)  = ebval('h2',fuel)   *scalar2;
 ebval('h3',fuel)  = ebval('h3',fuel)   *scalar2;

 ebval('exp',fuel)  = ebval('exp',fuel) *scalar3;

*Calculating values to subtract from other activities
 trvaggac('cref',agg)$(ASAM('cref',agg) and ASAM('cref',agg))=(ASAM('cref',agg)
         - sum(EBA$MECAGGAC(EBA,AGG),sum(FUEL,ebval(EBA,FUEL))));
 trvaggac('cref',agg)$(trvaggac('cref',agg) lt 0) =0;
 trvaggac(aggac,agg)$ASAM(aggac,agg)= trvaggac('cref',agg)*trshr(aggac);
 trvaggac('coin',agg)$ASAM('coin',agg)=sum(a$MAGGAC(a,agg),atrval(a));
 trvaggac(aggac,'atrl')=0;
 trvaggac(aggac,'atra')=0;
*Treat aref differently to avoid inescapable small negative value
* trvaggac(aggac,'aref')=0;
 trvaggac('cref','aref')=ASAM('cref','aref');

$ontext
*Code must be changed - come back to this
*Calculating values to subtract from other activities
*For households only remove petroleum, tyre and motor vehicle purchases. Due to
*aggregation of the SAM shares from the disaggregate SAM are used. Expenditure on
*sale,maintenance and repair of motor vehicles as activity does not have its own commodity
 trvaggh('cref','h1')=ASAM('cref','h1')-sum(lfuelt,ebval('h1',lfuelt))-sum(lfuelo,ebval('h1',lfuelo));
 trvaggh('cref','h2')=ASAM('cref','h2')-sum(lfuelt,ebval('h2',lfuelt))-sum(lfuelo,ebval('h2',lfuelo));
 trvaggh('cref','h3')=ASAM('cref','h3')-sum(lfuelt,ebval('h3',lfuelt))-sum(lfuelo,ebval('h3',lfuelo));
 trvaggh('coin',hagg)=sum(h$MHAGG(h,hagg),htrval(h));
$offtext

 trvaggh('cref','h1')=0;
 trvaggh('cref','h2')=0;
 trvaggh('cref','h3')=0;
 trvaggh('coin',hagg)=0;

*Removing petrol related values from SAM and adding to transport sector
 ASAM(aggac,agg)=ASAM(aggac,agg)-trvaggac(aggac,agg);
 ASAM(aggac,'atrl')=ASAM(aggac,'atrl')+ sum(agg,trvaggac(aggac,agg));

 ASAM(aggac,'h1')=ASAM(aggac,'h1')-trvaggh(aggac,'h1');
 ASAM(aggac,'h2')=ASAM(aggac,'h2')-trvaggh(aggac,'h2');
 ASAM(aggac,'h3')=ASAM(aggac,'h3')-trvaggh(aggac,'h3');
 ASAM(aggac,'atrl')=ASAM(aggac,'atrl')+ trvaggh(aggac,'h1')+ trvaggh(aggac,'h2')+ trvaggh(aggac,'h3');

*Replacing petrol related values of sectors with increased transport service use
 ASAM('ctrf',agg)=ASAM('ctrf',agg) + sum(aggac,trvaggac(aggac,agg));
 ASAM('ctrp','h1')=ASAM('ctrp','h1')+sum(aggac,trvaggh(aggac,'h1'));
 ASAM('ctrp','h2')=ASAM('ctrp','h2')+sum(aggac,trvaggh(aggac,'h2'));
 ASAM('ctrp','h3')=ASAM('ctrp','h3')+sum(aggac,trvaggh(aggac,'h3'));

*Increasing production of land transport
 ASAM('atrl','ctrf')=ASAM('atrl','ctrf')+sum((aggac,agg),trvaggac(aggac,agg));
 ASAM('atrl','ctrp')=ASAM('atrl','ctrp')+sum((aggac,hagg),trvaggh(aggac,hagg));

*special case: mining and fab petrol consumption not enough. therefore increase
*and decrease consumption of freight services used
 ASAM('ctrf','amin')=ASAM('ctrf','amin')+(ASAM('cref','amin')-sum(fuel,ebval('amin',fuel)));
 ASAM('ctrf','afab')=ASAM('ctrf','afab')+(ASAM('cref','afab')-sum(fuel,ebval('afab',fuel)));
 ASAM('ctrf','aelc')=ASAM('ctrf','aelc')+(ASAM('cref','aelc')-sum(fuel,ebval('aelc_oil',fuel)));
 ASAM('atrl','ctrf')= ASAM('atrl','ctrf')
                          +(ASAM('cref','amin')-sum(fuel,ebval('amin',fuel)))
                          +(ASAM('cref','afab')-sum(fuel,ebval('afab',fuel)))
                          +(ASAM('cref','aelc')-sum(fuel,ebval('aelc_oil',fuel)));

 ASAM('cref','atrl')=ASAM('cref','atrl')
                          +(ASAM('cref','amin')-sum(fuel,ebval('amin',fuel)))
                          +(ASAM('cref','afab')-sum(fuel,ebval('afab',fuel)))
                          +(ASAM('cref','aelc')-sum(fuel,ebval('aelc_oil',fuel)));

 ASAM('cref','amin')=sum(fuel,ebval('amin',fuel));
 ASAM('cref','afab')=sum(fuel,ebval('afab',fuel));
 ASAM('cref','aelc')=sum(fuel,ebval('aelc_oil',fuel));

*household split of liquid fuel consumption is different from thet suggested by the energy
*balance therefore adjust to bring in line. Aggregate household is the same.
 ASAM('ctrp',HAGG)=ASAM('ctrp',HAGG)+(ASAM('cref',HAGG)-sum((eba,fuel)$MECAGGAC(EBA,HAGG),ebval(eba,fuel)));
 ASAM('cref',HAGG)=sum((eba,fuel)$MECAGGAC(EBA,HAGG),ebval(eba,fuel));

 ASAM(AGGAC,'TOTAL')=SUM(AGGACNTP,ASAM(AGGACNTP,AGGAC));
 ASAM('TOTAL',AGGAC)=SUM(AGGACNTP,ASAM(AGGAC,AGGACNTP));

 SAMBALCHK2(AGGACNT)=SUM(AGGACNTP,ASAM(AGGACNT,AGGACNTP))-SUM(AGGACNTP,ASAM(AGGACNTP,AGGACNT));

*include three refinery products (diesel, petrol and other)
*handling the consumption side (rows)
Parameter
 tempagg(eba,*)
 tempagg2(eba,*);

 tempagg(eba,'petrol')$(ebval(eba,'petrol')+ebval(eba,'diesel')+sum(lfuelo,ebval(eba,lfuelo)))
                 =ebval(eba,'petrol')/(ebval(eba,'petrol')+ebval(eba,'diesel')+sum(lfuelo,ebval(eba,lfuelo)));
 tempagg(eba,'diesel')$(ebval(eba,'petrol')+ebval(eba,'diesel')+sum(lfuelo,ebval(eba,lfuelo)))
                 =ebval(eba,'diesel')/(ebval(eba,'petrol')+ebval(eba,'diesel')+sum(lfuelo,ebval(eba,lfuelo)));
 tempagg(eba,'other')$(ebval(eba,'petrol')+ebval(eba,'diesel')+sum(lfuelo,ebval(eba,lfuelo)))
                  =sum(lfuelo,ebval(eba,lfuelo))/(ebval(eba,'petrol')+ebval(eba,'diesel')+sum(lfuelo,ebval(eba,lfuelo)));

*atrl_f includes atrl_p - atrl is combined
 tempagg('atrl_f','petrol')
                 =(ebval('atrl_f','petrol')+ebval('atrl_p','petrol'))
         /(ebval('atrl_f','petrol')+ebval('atrl_f','diesel')+sum(lfuelo,ebval('atrl_f',lfuelo)+ebval('atrl_p',lfuelo))
         + ebval('atrl_p','petrol')+ebval('atrl_p','diesel'));
 tempagg('atrl_f','diesel')
                 =(ebval('atrl_f','diesel')+ebval('atrl_p','diesel'))
         /(ebval('atrl_f','petrol')+ebval('atrl_f','diesel')+sum(lfuelo,ebval('atrl_f',lfuelo)+ebval('atrl_p',lfuelo))
         + ebval('atrl_p','petrol')+ebval('atrl_p','diesel'));

 tempagg('atrl_f','other')
                  =sum(lfuelo,ebval('atrl_f',lfuelo)+ebval('atrl_p',lfuelo))
         /(ebval('atrl_f','petrol')+ebval('atrl_f','diesel')+sum(lfuelo,ebval('atrl_f',lfuelo)+ebval('atrl_p',lfuelo))
         + ebval('atrl_p','petrol')+ebval('atrl_p','diesel'));

 tempagg('atrl_p','petrol')=0;
 tempagg('atrl_p','diesel')=0;
 tempagg('atrl_p','other')=0;

 tempagg('imp','petrol')=ebval('imp','petrol')/(ebval('imp','petrol')+ebval('imp','diesel')+sum(lfuelo,ebval('imp',lfuelo)));
 tempagg('imp','diesel')=ebval('imp','diesel')/(ebval('imp','petrol')+ebval('imp','diesel')+sum(lfuelo,ebval('imp',lfuelo)));
 tempagg('imp','other ')=sum(lfuelo,ebval('imp',lfuelo))/(ebval('imp','petrol')+ebval('imp','diesel')+sum(lfuelo,ebval('imp',lfuelo)));

 tempagg('exp','petrol')=ebval('exp','petrol')/(ebval('exp','petrol')+ebval('exp','diesel')+sum(lfuelo,ebval('exp',lfuelo)));
 tempagg('exp','diesel')=ebval('exp','diesel')/(ebval('exp','petrol')+ebval('exp','diesel')+sum(lfuelo,ebval('exp',lfuelo)));
 tempagg('exp','other ')=sum(lfuelo,ebval('exp',lfuelo))/(ebval('exp','petrol')+ebval('exp','diesel')+sum(lfuelo,ebval('exp',lfuelo)));

*Used later
 tempagg2('atrl_f','petrol')=ebval('atrl_f','petrol')/(ebval('atrl_f','petrol')+ebval('atrl_f','diesel'));
 tempagg2('atrl_p','petrol')=ebval('atrl_p','petrol')/(ebval('atrl_p','petrol')+ebval('atrl_p','diesel'));

$ontext
 tempagg('imp','petrol')=(eimp('petrol')*PFUEL('petrol'))
                   /(eimp('petrol')*PFUEL('petrol')+eimp('diesel')*PFUEL('diesel')+eimp('lpg')*PFUEL('lpg')+eimp('hfo')*PFUEL('hfo')+eimp('jet_par')*PFUEL('jet_par'));
 tempagg('imp','diesel')=(eimp('diesel')*PFUEL('diesel'))
                  /(eimp('petrol')*PFUEL('petrol')+eimp('diesel')*PFUEL('diesel')+eimp('lpg')*PFUEL('lpg')+eimp('hfo')*PFUEL('hfo')+eimp('jet_par')*PFUEL('jet_par'));
 tempagg('imp','other') =(eimp('lpg')*PFUEL('lpg')+eimp('hfo')*PFUEL('hfo')+eimp('jet_par')*PFUEL('jet_par'))
                 /(eimp('petrol')*PFUEL('petrol')+eimp('diesel')*PFUEL('diesel')+eimp('lpg')*PFUEL('lpg')+eimp('hfo')*PFUEL('hfo')+eimp('jet_par')*PFUEL('jet_par'));

 tempagg('exp','petrol')=(eexp('petrol')*PFUEL('petrol'))
                   /(eexp('petrol')*PFUEL('petrol')+eexp('diesel')*PFUEL('diesel')+eexp('lpg')*PFUEL('lpg')+eexp('hfo')*PFUEL('hfo')+eexp('jet_par')*PFUEL('jet_par'));
 tempagg('exp','diesel')=(eexp('diesel')*PFUEL('diesel'))
                  /(eexp('petrol')*PFUEL('petrol')+eexp('diesel')*PFUEL('diesel')+eexp('lpg')*PFUEL('lpg')+eexp('hfo')*PFUEL('hfo')+eexp('jet_par')*PFUEL('jet_par'));
 tempagg('exp','other') =(eexp('lpg')*PFUEL('lpg')+eexp('hfo')*PFUEL('hfo')+eexp('jet_par')*PFUEL('jet_par'))
                 /(eexp('petrol')*PFUEL('petrol')+eexp('diesel')*PFUEL('diesel')+eexp('lpg')*PFUEL('lpg')+eexp('hfo')*PFUEL('hfo')+eexp('jet_par')*PFUEL('jet_par'));
$offtext

 ASAM('cref_p',AGGAC) = ASAM('cref',AGGAC)*SUM(EBA$MECAGGAC(EBA,AGGAC),tempagg(eba,'petrol'));
 ASAM('cref_d',AGGAC) = ASAM('cref',AGGAC)*SUM(EBA$MECAGGAC(EBA,AGGAC),tempagg(eba,'diesel'));
 ASAM('cref_o',AGGAC) = ASAM('cref',AGGAC)*SUM(EBA$MECAGGAC(EBA,AGGAC),tempagg(eba,'other'));

 ASAM('cref_p','atrl')= ASAM('cref','atrl')*tempagg('atrl_f','petrol');
 ASAM('cref_d','atrl')= ASAM('cref','atrl')*tempagg('atrl_f','diesel');
 ASAM('cref_o','atrl')= ASAM('cref','atrl')*tempagg('atrl_f','other');

*households
*can't use code below as doesn't match to SAM household group consumption
* ASAM('cref_p',HAGG)=ASAM('cref',HAGG)*(SUM(EBA$MECAGGAC(EBA,HAGG),tempagg(eba,'petrol')));
* ASAM('cref_d',HAGG)=ASAM('cref',HAGG)*(SUM(EBA$MECAGGAC(EBA,HAGG),tempagg(eba,'diesel')));
* ASAM('cref_o',HAGG)=ASAM('cref',HAGG)*(SUM(EBA$MECAGGAC(EBA,HAGG),tempagg(eba,'other')));

*exports
*use actual ebvals as was scaled down before
* ASAM('cref_p','row')=ASAM('cref','row')*tempagg('exp','petrol');
* ASAM('cref_d','row')=ASAM('cref','row')*tempagg('exp','diesel');
* ASAM('cref_o','row')=ASAM('cref','row')*tempagg('exp','other');

 ASAM('cref_p','row')= ebval('exp','petrol');
 ASAM('cref_d','row')= ebval('exp','diesel');
 ASAM('cref_o','row')= (sum(fuel,ebval('exp',fuel))-ebval('exp','diesel')-ebval('exp','petrol'));

*not valid in aggregate form due to shift above
*investment split according to aoin
 ASAM('cref_p','s-i')
         = ASAM('cref','s-i')*(ASAM('cref_p','aoin')/ASAM('cref','aoin'));

 ASAM('cref_d','s-i')
         = ASAM('cref','s-i')*(ASAM('cref_d','aoin')/ASAM('cref','aoin'));

 ASAM('cref_o','s-i')
         = ASAM('cref','s-i')*(ASAM('cref_o','aoin')/ASAM('cref','aoin'));

*handling the consumption side (columns)
 ASAM('mtax','cref_p') = ASAM('mtax' ,'cref')*tempagg('imp','petrol');
 ASAM('mtax','cref_d') = ASAM('mtax' ,'cref')*tempagg('imp','diesel');
 ASAM('mtax','cref_o') = ASAM('mtax' ,'cref')*tempagg('imp','other');

 ASAM('row','cref_p')  = ASAM('row' ,'cref')*tempagg('imp','petrol');
 ASAM('row','cref_d')  = ASAM('row' ,'cref')*tempagg('imp','diesel');
 ASAM('row','cref_o')  = ASAM('row' ,'cref')*tempagg('imp','other');

 ASAM('stax','cref_p') = sum(AGGACNT,ASAM('cref_p',AGGACNT))*(ASAM('stax','cref')/sum(AGGACNT,ASAM('cref',AGGACNT)));
 ASAM('stax','cref_d') = sum(AGGACNT,ASAM('cref_d',AGGACNT))*(ASAM('stax','cref')/sum(AGGACNT,ASAM('cref',AGGACNT)));
 ASAM('stax','cref_o') = sum(AGGACNT,ASAM('cref_o',AGGACNT))*(ASAM('stax','cref')/sum(AGGACNT,ASAM('cref',AGGACNT)));

 ASAM('trc','cref_p') = sum(AGGACNT,ASAM('cref_p',AGGACNT))*(ASAM('trc','cref')/sum(AGGACNT,ASAM('cref',AGGACNT)));
 ASAM('trc','cref_d') = sum(AGGACNT,ASAM('cref_d',AGGACNT))*(ASAM('trc','cref')/sum(AGGACNT,ASAM('cref',AGGACNT)));
 ASAM('trc','cref_o') = sum(AGGACNT,ASAM('cref_o',AGGACNT))*(ASAM('trc','cref')/sum(AGGACNT,ASAM('cref',AGGACNT)));

 ASAM('aref','cref_p') = SUM(AGGACNT,ASAM('cref_p',AGGACNT))-(ASAM('row','cref_p')
         +ASAM('mtax','cref_p')+ASAM('stax','cref_p')+ASAM('trc','cref_p'));

 ASAM('aref','cref_d') = SUM(AGGACNT,ASAM('cref_d',AGGACNT))-(ASAM('row','cref_d')
         +ASAM('mtax','cref_d')+ASAM('stax','cref_d')+ASAM('trc','cref_d'));

 ASAM('aref','cref_o') = SUM(AGGACNT,ASAM('cref_o',AGGACNT))-(ASAM('row','cref_o')
         +ASAM('mtax','cref_o')+ASAM('stax','cref_o')+ASAM('trc','cref_o'));

 ASAM('cref',AGGAC)= 0;
 ASAM(AGGAC,'cref')= 0;

 SAMBALCHK2(AGGACNT)=SUM(AGGACNTP,ASAM(AGGACNT,AGGACNTP))-SUM(AGGACNTP,ASAM(AGGACNTP,AGGACNT));
 DISPLAY SAMBALCHK2;

*--------------------------------------------------------------------------------------------
*5. Calculating SAM implied energy prices
*--------------------------------------------------------------------------------------------
Parameter
 IPFUEL(AGGAC,CAGG)               Implied fuel prices
 IPFUEL2(CAGG)                    Implied fuel prices - economy-wide average
;

*electricity price = R/kWh
 IPFUEL(AGGAC,'CELC')$SUM(EBA$MECAGGAC(EBA,AGGAC),EDEM(EBA,'ELECTRICITY'))
         =(ASAM('CELC',AGGAC)/SUM(EBA$MECAGGAC(EBA,AGGAC),EDEM(EBA,'ELECTRICITY')))/0.2778;

 IPFUEL2('celc')=((SUM(AGG,ASAM('CELC',AGG))+ASAM('CELC','h1'))/SUM(EBA,EDEM(EBA,'ELECTRICITY')))/0.2778;

*refinery price = R/PJ
 IPFUEL(AGGAC,'cref_d')$SUM(EBA$MECAGGAC(EBA,AGGAC),EDEM(EBA,'diesel'))
         =(ASAM('cref_d',AGGAC)/SUM(EBA$MECAGGAC(EBA,AGGAC),EDEM(EBA,'diesel')))*1000000;

 IPFUEL(AGGAC,'cref_p')$SUM(EBA$MECAGGAC(EBA,AGGAC),EDEM(EBA,'petrol'))
         =(ASAM('cref_p',AGGAC)/SUM(EBA$MECAGGAC(EBA,AGGAC),EDEM(EBA,'petrol')))*1000000;

 IPFUEL(AGGAC,'cref_o')$SUM(EBA$MECAGGAC(EBA,AGGAC),sum(LFUELO,EDEM(EBA,LFUELO)))
         =(ASAM('cref_o',AGGAC)/SUM(EBA$MECAGGAC(EBA,AGGAC),sum(LFUELO,EDEM(EBA,LFUELO))))*1000000;

 IPFUEL2('cref_d')$SUM(EBA,EDEM(EBA,'diesel'))
         =((sum(AGG,ASAM('cref_d',AGG))+ASAM('cref_d','h1')+ASAM('cref_d','h2')+ASAM('cref_d','h3')))/SUM(EBA,EDEM(EBA,'diesel'))*1000000;

 IPFUEL2('cref_p')$SUM(EBA,EDEM(EBA,'petrol'))
         =((sum(AGG,ASAM('cref_p',AGG))+ASAM('cref_p','h1')+ASAM('cref_p','h2')+ASAM('cref_p','h3')))/SUM(EBA,EDEM(EBA,'petrol'))*1000000;

 IPFUEL2('cref_o')$sum((EBA,LFUELO),EDEM(EBA,LFUELO))
         =((sum(AGG,ASAM('cref_o',AGG))+ASAM('cref_o','h1')+ASAM('cref_o','h2')+ASAM('cref_o','h3')))/sum((EBA,LFUELO),EDEM(EBA,LFUELO))*1000000;
$ontext
*Splitting ASAM to get SAM - can't do this:
*1. subtracting labour and vehicle purchases - can't isolate vehicles as in other industry
Parameter
 SAM_AGG(aggac,aggac)
 SAM_SHR(ac,ac)
 SAM_NEW(ac,ac)

 test(aggac,ac)
 test2(ac,ac)
 test3(ac,ac)
 test4(ac,ac)
 test5(ac,aggac)
 test6(aggac,aggac)
 test7(ac,ac)
;

set
 CREF(CAGG) /cref_p, cref_d, cref_o/
 CPETR(C) /cpetr_p, cpetr_d, cpetr_o/
;

Alias (cref,crefp);

 MAGGAC('cpetr_p','cref_p')=YES;
 MAGGAC('cpetr_d','cref_d')=YES;
 MAGGAC('cpetr_o','cref_o')=YES;

 test(aggacnt,ac)=sum(aggacp$maggac(ac,aggacp),ASAM(aggacnt,aggacp));
 test2(ac,acnt)=sum(aggacp$maggac(ac,aggacp),test(aggacp,acnt))*1000;

 test5(ac,aggac)= sum(acp$maggac(acp,aggac),SAM(ac,acp));

 SAM_AGG(aggac,aggacp)=sum((ac,acp)$(maggac(acp,aggacp) and maggac(ac,aggac)),SAM(ac,acp));
 SAM_SHR(ac,acp)$sum((aggac,aggacp)$(maggac(ac,aggac)and maggac(acp,aggacp)),SAM_AGG(aggac,aggacp))
                      =SAM(ac,acp)/sum((aggac,aggacp)$(maggac(ac,aggac)and maggac(acp,aggacp)),SAM_AGG(aggac,aggacp));

 test6(aggac,cref)$sum(crefp,ASAM(aggac,crefp))=ASAM(aggac,cref)/sum(crefp,ASAM(aggac,crefp));

 test7(cpetr,ac)
          = SAM_SHR('cpetr',AC)*sum((cref,aggac)$(MAGGAC(cpetr,cref) and MAGGAC(ac,aggac)),(ASAM(cref,aggac)/sum(crefp,ASAM(crefp,aggac))));
* test7(ac,cpetr)=sum((cref,aggac)$(MAGGAC(cpetr,cref) and MAGGAC(ac,aggac)),(ASAM(cref,aggac)/sum(crefp,ASAM(crefp,aggac))));

 SAM_NEW(ac,acp)= SAM_SHR(ac,acp)*(sum((aggac,aggacp)$(maggac(ac,aggac)and maggac(acp,aggacp)),ASAM(aggac,aggacp)))*1000;
$offtext

*--------------------------------------------------------------------------------------------
*6. Disaggregate SAM - transport values
*--------------------------------------------------------------------------------------------
*Calculate values to be subtracted from disaggregated SAM
Parameter
 trshr2(ac)                        land transport sector shares
 trvac(ac,a)                       values to be extracted from other sectors
 trvshr(a)                         share for splitting liquid fuels from aggregated SAM - activities
 trvhshr(h)                        share for splitting liquid fuels from aggregated SAM - households
 trvh(ac,h)                        values to be extracted from households
 scalar4 /0.01/
;

*Calculating consumption shares of land transport sector
* trshr2(acnt)=SAM(acnt,"altrp")/sum(acntp,SAM(acntp,"altrp"));
 trshr2(acnt)=0;
 trshr2('cpetr') =SAM('cpetr' ,'altrp')/sum(acntp,SAM(acntp,'altrp'));
 trshr2('cvehi') =SAM('cvehi' ,'altrp')/sum(acntp,SAM(acntp,'altrp'));
 trshr2('flab-p')=SAM('flab-p','altrp')/sum(acntp,SAM(acntp,'altrp'));
 trshr2('flab-m')=SAM('flab-m','altrp')/sum(acntp,SAM(acntp,'altrp'));
 trshr2('flab-s')=SAM('flab-s','altrp')/sum(acntp,SAM(acntp,'altrp'));
 trshr2('flab-t')=SAM('flab-t','altrp')/sum(acntp,SAM(acntp,'altrp'));

*relative to trshr
 trshr2(acnt)= trshr2(acnt)/trshr2('cpetr');
*dampened to avoid negative values in SAM (smaller than before due to bchm, ochm, bsrv)
 trshr2('flab-p')=trshr2('flab-p')*scalar4;
 trshr2('flab-m')=trshr2('flab-m')*scalar4;
 trshr2('flab-s')=trshr2('flab-s')*scalar4;
 trshr2('flab-t')=trshr2('flab-t')*scalar4;
 trshr2('cpetr')=1;

 trvshr(a)$sum(agg$MAGG(a,agg),sum(ap$MAGG(ap,agg),SAM('cpetr',ap)))=SAM('cpetr',a)/sum(agg$MAGG(a,agg),sum(ap$MAGG(ap,agg),SAM('cpetr',ap)));
 trvac('cpetr',a)=(sum(agg$MAGG(a,agg),trvaggac('cref',agg))*trvshr(a))*1000;
*FH to check this again
* trvac('cpetr','atrps')=SAM('cpetr','atrps');

 trvac(ac,a)$SAM(ac,a)= trvac('cpetr',a)*trshr2(ac);
*not necessary as values already 0
 trvac(ac,'altrp')=0;
 trvac(ac,'awtrp')=0;
 trvac(ac,'aatrp')=0;

 trvac('cvehi',a)$(trvac('cvehi',a) gt SAM('cvehi',a))=SAM('cvehi',a);

*For households only remove petroleum and motor vehicle purchases. Expenditure on
*tyres and sale,maintenance and repair of motor vehicles as activity does not have its own commodity
*set to zero for transport work
* trvhshr(h)=SAM('cpetr',h)/sum(hp,SAM('cpetr',hp));
* trvh('cpetr',h)=(trvaggh('cref','h1')*1000)*trvhshr(h);
* trvh('cvehi',h)=SAM('cvehi',h);
 trvh(ac,h)=0;

*Removing petrol related values from SAM and adding to transport sector
 SAM(ac,a)=SAM(ac,a)-trvac(ac,a);
 SAM(ac,h)=SAM(ac,h)-trvh(ac,h);

 SAM(ac,'altrp')=SAM(ac,'altrp')+ sum(a,trvac(ac,a))+sum(h,trvh(ac,h));

*Replacing petrol related values of sectors with increased transport service use
 SAM('cftrp',a)=SAM('cftrp',a)+sum(ac,trvac(ac,a));
 SAM('cptrp',h)=SAM('cptrp',h)+sum(ac,trvh(ac,h));

*Increasing production of land transport
 SAM('altrp','cftrp')=SAM('altrp','cftrp')+sum((ac,a),trvac(ac,a));
 SAM('altrp','cptrp')=SAM('altrp','cptrp')+sum((ac,h),trvh(ac,h));
*-------------------------------------------------------------------------------
*this code may not be needed in other versions - need to check first
*replacing mining, food&bev and elec to match eb consumption
*can't share equally across mining as freight use by amore becomes negative
set
mine(a) /acoal, agold, amore, amine/
fbev(a) /afood, abevt/;

alias (mine,minep), (fbev,fbevp);

parameter
 enerval(ac,ac)
;

 enerval('cpetr',fbev) = (SAM('cpetr',fbev)/sum(fbevp,SAM('cpetr',fbevp)))*sum(aggac$MAGGAC(fbev,aggac),(ASAM('cref_d','afab')+ASAM('cref_p','afab')+ASAM('cref_o','afab'))*1000);
 enerval('cpetr','aelec') = ((ASAM('cref_d','aelc')+ASAM('cref_p','aelc')+ASAM('cref_o','aelc'))*1000);

 SAM('cftrp',fbev)=SAM('cftrp',fbev)-(enerval('cpetr',fbev)-SAM('cpetr',fbev));

 SAM('cftrp','aelec')=SAM('cftrp','aelec')-(enerval('cpetr','aelec')-SAM('cpetr','aelec'));

 SAM('altrp','cftrp')=SAM('altrp','cftrp')
                     - sum(fbev,(enerval('cpetr',fbev)-SAM('cpetr',fbev)))
                     - (enerval('cpetr','aelec')-SAM('cpetr','aelec'));

 SAM('cpetr','altrp')=SAM('cpetr','altrp')
                     - sum(fbev,(enerval('cpetr',fbev)-SAM('cpetr',fbev)))
                     - (enerval('cpetr','aelec')-SAM('cpetr','aelec'));

 SAM('cpetr',fbev)   = enerval('cpetr',fbev)   ;
 SAM('cpetr','aelec')= enerval('cpetr','aelec');

* do the same for household liquid fuel consumption due to SAM/eb discrepencies
* use household demand for passenger transport as the balancing item
 enerval('cpetr',h)=(SAM('cpetr',h)/sum(hagg$MHAGG(h,hagg),sum(hp$MHAGG(hp,hagg),SAM('cpetr',hp))))
                   *sum(hagg$MAGGAC(h,hagg),(ASAM('cref_d',hagg)+ASAM('cref_p',hagg)+ASAM('cref_o',hagg))*1000);

 SAM('cptrp',h)=SAM('cptrp',h)-(enerval('cpetr',h)-SAM('cpetr',h));
 SAM('altrp','cptrp')=SAM('altrp','cptrp')-sum(h,(enerval('cpetr',h)-SAM('cpetr',h)));
 SAM('cpetr','altrp')=SAM('cpetr','altrp')-sum(h,(enerval('cpetr',h)-SAM('cpetr',h)));
 SAM('cpetr',h)= enerval('cpetr',h);
*-------------------------------------------------------------------------------
 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
 DISPLAY SAMBALCHK1;

*FH to chat with Bruno
*Shift all other industry consumption into construction. The ERC energy balance
*does not provide a split for this. The DoE energy balance only reports for
*construction and no other sector.
Parameter
Temp2(c,a);

 Temp2('cpetr',a)=SAM('cpetr',a);
 Temp2('ccons',a)=SAM('ccons',a);

 Temp2('cpetr','acons')=sum(agg$MAGG('acons',agg),sum(ap$MAGG(ap,agg),SAM('cpetr',ap)));
 SAM('acons','ccons')=SAM('acons','ccons')+(Temp2('cpetr','acons')-SAM('cpetr','acons'));

 SAM('cpetr',a)$(MAGG(a,'aoin'))=0;
 SAM('cpetr','acons')=Temp2('cpetr','acons');

 SAM('ccons',a)$(MAGG(a,'aoin'))=SAM('ccons',a)+Temp2('cpetr',a);
 SAM('ccons','acons')=Temp2('ccons','acons');

*move stocks of cpetr to exports which are lower than ebval suggests it should be
 SAM('cpetr','row')=SAM('cpetr','row')+SAM('cpetr','dstk');
 SAM('s-i','row')=SAM('s-i','row')-SAM('cpetr','dstk');
 SAM('dstk','s-i')=SAM('dstk','s-i')-SAM('cpetr','dstk');
 SAM('cpetr','dstk')=0;
 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

*move stocks of other energy fuels as well as EB doesn't have stocks - remove from imports
*EB suggest SAM value is too high
 SAM('row','celec')=SAM('row','celec')-SAM('celec','dstk');
 SAM('s-i','row')=SAM('s-i','row')-SAM('celec','dstk');
 SAM('dstk','s-i')=SAM('dstk','s-i')-SAM('celec','dstk');
 SAM('celec','dstk')=0;

 SAM('row','ccoal')=SAM('row','ccoal')-SAM('ccoal','dstk');
 SAM('s-i','row')=SAM('s-i','row')-SAM('ccoal','dstk');
 SAM('dstk','s-i')=SAM('dstk','s-i')-SAM('ccoal','dstk');
 SAM('ccoal','dstk')=0;

*Only atrps can produce ctrp
 SAM('atrps','ctrps')=SAM('atrps','ctrps')+SAM('altrp','ctrps')+SAM('awtrp','ctrps')+SAM('aatrp','ctrps');
 SAM('cftrp','atrps')=SAM('cftrp','atrps')+SAM('altrp','ctrps')+SAM('awtrp','ctrps')+SAM('aatrp','ctrps');

 SAM('altrp','cftrp')=SAM('altrp','cftrp')+SAM('altrp','ctrps');
 SAM('awtrp','cftrp')=SAM('awtrp','cftrp')+SAM('awtrp','ctrps');
 SAM('aatrp','cftrp')=SAM('aatrp','cftrp')+SAM('aatrp','ctrps');

 SAM('altrp','ctrps')=0;
 SAM('awtrp','ctrps')=0;
 SAM('aatrp','ctrps')=0;

 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
 DISPLAY SAMBALCHK1;

*incleude three refinery products (diesel, petrol and other) handling the consumption side (rows)
*activities
Parameter
* temp(eba,*)
 temp(aggac,*)
;

 temp(aggac,'petrol')$(ASAM('cref_p',aggac)+ASAM('cref_d',aggac)+ASAM('cref_o',aggac))
                         =ASAM('cref_p',aggac)/(ASAM('cref_p',aggac)+ASAM('cref_d',aggac)+ASAM('cref_o',aggac));
 temp('s-i','petrol')=temp('aoin','petrol');

 temp(aggac,'diesel')$(ASAM('cref_p',aggac)+ASAM('cref_d',aggac)+ASAM('cref_o',aggac))
                         =ASAM('cref_d',aggac)/(ASAM('cref_p',aggac)+ASAM('cref_d',aggac)+ASAM('cref_o',aggac));
 temp('s-i','diesel')=temp('aoin','diesel');

 temp(aggac,'other')$(ASAM('cref_p',aggac)+ASAM('cref_d',aggac)+ASAM('cref_o',aggac))
                         =ASAM('cref_o',aggac)/(ASAM('cref_p',aggac)+ASAM('cref_d',aggac)+ASAM('cref_o',aggac));
 temp('s-i','other')=temp('aoin','other');

 SAM('cpetr_p',ac) = SAM('cpetr',ac)*sum(aggac$MAGGAC(ac,aggac),temp(aggac,'petrol'));
 SAM('cpetr_d',ac) = SAM('cpetr',ac)*sum(aggac$MAGGAC(ac,aggac),temp(aggac,'diesel'));
 SAM('cpetr_o',ac) = SAM('cpetr',ac)*sum(aggac$MAGGAC(ac,aggac),temp(aggac,'other'));

*handling the production side (columns)
*imports and associated taxes are based on shares of estimated energy balance values of imports
 SAM('row','cpetr_p')  = (ASAM('row','cref_p')/(ASAM('row','cref_p')+ASAM('row','cref_d')+ASAM('row','cref_o')))*SAM('row','cpetr');
 SAM('row','cpetr_d')  = (ASAM('row','cref_d')/(ASAM('row','cref_p')+ASAM('row','cref_d')+ASAM('row','cref_o')))*SAM('row','cpetr');
 SAM('row','cpetr_o')  = (ASAM('row','cref_o')/(ASAM('row','cref_p')+ASAM('row','cref_d')+ASAM('row','cref_o')))*SAM('row','cpetr');

 SAM('mtax','cpetr_p') = (ASAM('mtax','cref_p')/(ASAM('mtax','cref_p')+ASAM('mtax','cref_d')+ASAM('mtax','cref_o')))*SAM('mtax','cpetr');
 SAM('mtax','cpetr_d') = (ASAM('mtax','cref_d')/(ASAM('mtax','cref_p')+ASAM('mtax','cref_d')+ASAM('mtax','cref_o')))*SAM('mtax','cpetr');
 SAM('mtax','cpetr_o') = (ASAM('mtax','cref_o')/(ASAM('mtax','cref_p')+ASAM('mtax','cref_d')+ASAM('mtax','cref_o')))*SAM('mtax','cpetr');

 SAM('stax','cpetr_p') = (ASAM('stax','cref_p')/(ASAM('stax','cref_p')+ASAM('stax','cref_d')+ASAM('stax','cref_o')))*SAM('stax','cpetr');
 SAM('stax','cpetr_d') = (ASAM('stax','cref_d')/(ASAM('stax','cref_p')+ASAM('stax','cref_d')+ASAM('stax','cref_o')))*SAM('stax','cpetr');
 SAM('stax','cpetr_o') = (ASAM('stax','cref_o')/(ASAM('stax','cref_p')+ASAM('stax','cref_d')+ASAM('stax','cref_o')))*SAM('stax','cpetr');

 SAM('trc','cpetr_p') = (ASAM('trc','cref_p')/(ASAM('trc','cref_p')+ASAM('trc','cref_d')+ASAM('trc','cref_o')))*SAM('trc','cpetr');
 SAM('trc','cpetr_d') = (ASAM('trc','cref_d')/(ASAM('trc','cref_p')+ASAM('trc','cref_d')+ASAM('trc','cref_o')))*SAM('trc','cpetr');
 SAM('trc','cpetr_o') = (ASAM('trc','cref_o')/(ASAM('trc','cref_p')+ASAM('trc','cref_d')+ASAM('trc','cref_o')))*SAM('trc','cpetr');

$ontext
 temp(eba,'petrol')$(edem(eba,'petrol')*IPFUEL2('cref_p')+edem(eba,'diesel')*IPFUEL2('cref_d')+sum(LFUELO,edem(eba,LFUELO))*IPFUEL2('cref_o'))
         =(edem(eba,'petrol')*IPFUEL2('cref_p'))/(edem(eba,'petrol')*IPFUEL2('cref_p')+edem(eba,'diesel')*IPFUEL2('cref_d')+sum(LFUELO,edem(eba,LFUELO))*IPFUEL2('cref_o'));
 temp(eba,'diesel')$(edem(eba,'petrol')*IPFUEL2('cref_p')+edem(eba,'diesel')*IPFUEL2('cref_d')+sum(LFUELO,edem(eba,LFUELO))*IPFUEL2('cref_o'))
         =(edem(eba,'diesel')*IPFUEL2('cref_d'))/(edem(eba,'petrol')*IPFUEL2('cref_p')+edem(eba,'diesel')*IPFUEL2('cref_d')+sum(LFUELO,edem(eba,LFUELO))*IPFUEL2('cref_o'));
 temp(eba,'other' )$(edem(eba,'petrol')*IPFUEL2('cref_p')+edem(eba,'diesel')*IPFUEL2('cref_d')+sum(LFUELO,edem(eba,LFUELO))*IPFUEL2('cref_o'))
         =(sum(LFUELO,edem(eba,LFUELO))*IPFUEL2('cref_o'))/(edem(eba,'petrol')*IPFUEL2('cref_p')+edem(eba,'diesel')*IPFUEL2('cref_d')+sum(LFUELO,edem(eba,LFUELO))*IPFUEL2('cref_o'));

 temp('atrl_f','petrol')=((edem('atrl_f','petrol')+edem('atrl_p','petrol'))*IPFUEL2('cref_p'))
                 /((edem('atrl_f','petrol')+edem('atrl_p','petrol'))*IPFUEL2('cref_p')
                 +(edem('atrl_f','diesel')+edem('atrl_p','diesel'))*IPFUEL2('cref_d')
                 +sum(LFUELO,(edem('atrl_f',LFUELO)+edem('atrl_p',LFUELO)))*IPFUEL2('cref_o'));

 temp('atrl_f','diesel')=((edem('atrl_f','diesel')+edem('atrl_p','diesel'))*IPFUEL2('cref_d'))
                 /((edem('atrl_f','petrol')+edem('atrl_p','petrol'))*IPFUEL2('cref_p')
                 +(edem('atrl_f','diesel')+edem('atrl_p','diesel'))*IPFUEL2('cref_d')
                 +sum(LFUELO,(edem('atrl_f',LFUELO)+edem('atrl_p',LFUELO)))*IPFUEL2('cref_o'));

 temp('atrl_f','other')=(sum(LFUELO,(edem('atrl_f',LFUELO)+edem('atrl_p',LFUELO)))*IPFUEL2('cref_o'))
                 /((edem('atrl_f','petrol')+edem('atrl_p','petrol'))*IPFUEL2('cref_p')
                 +(edem('atrl_f','diesel')+edem('atrl_p','diesel'))*IPFUEL2('cref_d')
                 +sum(LFUELO,(edem('atrl_f',LFUELO)+edem('atrl_p',LFUELO)))*IPFUEL2('cref_o'));

 temp('atrl_p','petrol')=0;
 temp('atrl_p','diesel')=0;
 temp('atrl_p','other' )=0;

 temp('imp','petrol')=(eimp('petrol')*IPFUEL2('cref_p'))/(eimp('petrol')*IPFUEL2('cref_p')+eimp('diesel')*IPFUEL2('cref_d')+sum(LFUELO,eimp(LFUELO))*IPFUEL2('cref_o'));
 temp('imp','diesel')=(eimp('diesel')*IPFUEL2('cref_d'))/(eimp('petrol')*IPFUEL2('cref_p')+eimp('diesel')*IPFUEL2('cref_d')+sum(LFUELO,eimp(LFUELO))*IPFUEL2('cref_o'));
 temp('imp','other') =(sum(LFUELO,eimp(LFUELO))*IPFUEL2('cref_o'))/(eimp('petrol')*IPFUEL2('cref_p')+eimp('diesel')*IPFUEL2('cref_d')+sum(LFUELO,eimp(LFUELO))*IPFUEL2('cref_o'));

 temp('exp','petrol')=(eexp('petrol')*IPFUEL2('cref_p'))/(eexp('petrol')*IPFUEL2('cref_p')+eexp('diesel')*IPFUEL2('cref_d')+sum(LFUELO,eexp(LFUELO))*IPFUEL2('cref_o'));
 temp('exp','diesel')=(eexp('diesel')*IPFUEL2('cref_d'))/(eexp('petrol')*IPFUEL2('cref_p')+eexp('diesel')*IPFUEL2('cref_d')+sum(LFUELO,eexp(LFUELO))*IPFUEL2('cref_o'));
 temp('exp','other') =(sum(LFUELO,eexp(LFUELO))*IPFUEL2('cref_o'))/(eexp('petrol')*IPFUEL2('cref_p')+eexp('diesel')*IPFUEL2('cref_d')+sum(LFUELO,eexp(LFUELO))*IPFUEL2('cref_o'));

 SAM('cpetr_p',A)=SAM('cpetr',A)*sum(agg$MAGG(a,agg),(SUM(EBA$MECAGGAC(EBA,AGG),temp(eba,'petrol'))));
 SAM('cpetr_d',A)=SAM('cpetr',A)*sum(agg$MAGG(a,agg),(SUM(EBA$MECAGGAC(EBA,AGG),temp(eba,'diesel'))));
 SAM('cpetr_o',A)=SAM('cpetr',A)*sum(agg$MAGG(a,agg),(SUM(EBA$MECAGGAC(EBA,AGG),temp(eba,'other'))));

*atrl_f includes atrl_p
 SAM('cpetr_p','altrp')=SAM('cpetr','altrp')*(temp('atrl_f','petrol'));
 SAM('cpetr_d','altrp')=SAM('cpetr','altrp')*(temp('atrl_f','diesel'));
 SAM('cpetr_o','altrp')=SAM('cpetr','altrp')*(temp('atrl_f','other') );

*households
*share calculation uses economy-wide price estimated in aggregate section to get volume shares right
 SAM('cpetr_p',H)=SAM('cpetr',H)*SUM(HAGG$MAGGAC(H,HAGG),(SUM(EBA$MECAGGAC(EBA,HAGG),temp(eba,'petrol'))));
 SAM('cpetr_d',H)=SAM('cpetr',H)*SUM(HAGG$MAGGAC(H,HAGG),(SUM(EBA$MECAGGAC(EBA,HAGG),temp(eba,'diesel'))));
 SAM('cpetr_o',H)=SAM('cpetr',H)*SUM(HAGG$MAGGAC(H,HAGG),(SUM(EBA$MECAGGAC(EBA,HAGG),temp(eba,'other'))));

*exports
 SAM('cpetr_p','row')=SAM('cpetr','row')*temp('exp','petrol');
 SAM('cpetr_d','row')=SAM('cpetr','row')*temp('exp','diesel');
 SAM('cpetr_o','row')=SAM('cpetr','row')*temp('exp','other');

*investment split according to construction
 SAM('cpetr_p','s-i') $ (SAM('cpetr','s-i'))
         = SAM('cpetr','s-i')*(SAM('cpetr_p','acons')/SAM('cpetr','acons'));

 SAM('cpetr_d','s-i') $ (SAM('cpetr','s-i'))
         = SAM('cpetr','s-i')*(SAM('cpetr_d','acons')/SAM('cpetr','acons'));

 SAM('cpetr_o','s-i') $ (SAM('cpetr','s-i'))
         = SAM('cpetr','s-i')*(SAM('cpetr_o','acons')/SAM('cpetr','acons'));

*handling the production side (columns)
*imports and associated taxes are based on shares of estimated energy balance values of imports
 SAM('row','cpetr_p') = SAM('row' ,'cpetr')*temp('imp','petrol');
 SAM('row','cpetr_d') = SAM('row' ,'cpetr')*temp('imp','diesel');
 SAM('row','cpetr_o') = SAM('row' ,'cpetr')*temp('imp','other');

 SAM('mtax','cpetr_p') = SAM('mtax' ,'cpetr')*temp('imp','petrol');
 SAM('mtax','cpetr_d') = SAM('mtax' ,'cpetr')*temp('imp','diesel');
 SAM('mtax','cpetr_o') = SAM('mtax' ,'cpetr')*temp('imp','other');

*apply effective rate
 SAM('stax','cpetr_p')= sum(ACNT,SAM('cpetr_p',ACNT))*(SAM('stax','cpetr')/sum(ACNT,SAM('cpetr',ACNT)));
 SAM('stax','cpetr_d')= sum(ACNT,SAM('cpetr_d',ACNT))*(SAM('stax','cpetr')/sum(ACNT,SAM('cpetr',ACNT)));
 SAM('stax','cpetr_o')= sum(ACNT,SAM('cpetr_o',ACNT))*(SAM('stax','cpetr')/sum(ACNT,SAM('cpetr',ACNT)));

 SAM('trc','cpetr_p') = sum(ACNT,SAM('cpetr_p',ACNT))*(SAM('trc','cpetr')/sum(ACNT,SAM('cpetr',ACNT)));
 SAM('trc','cpetr_d') = sum(ACNT,SAM('cpetr_d',ACNT))*(SAM('trc','cpetr')/sum(ACNT,SAM('cpetr',ACNT)));
 SAM('trc','cpetr_o') = sum(ACNT,SAM('cpetr_o',ACNT))*(SAM('trc','cpetr')/sum(ACNT,SAM('cpetr',ACNT)));
$offtext

*calculating production of each liquid fuel commodity
 SAM('apetr','cpetr_p') = SUM(ACNT,SAM('cpetr_p',ACNT))-(SAM('row','cpetr_p')
         +SAM('mtax','cpetr_p')+SAM('stax','cpetr_p')+SAM('trc','cpetr_p'));

 SAM('apetr','cpetr_d') = SUM(ACNT,SAM('cpetr_d',ACNT))-(SAM('row','cpetr_d')
         +SAM('mtax','cpetr_d')+SAM('stax','cpetr_d')+SAM('trc','cpetr_d'));

 SAM('apetr','cpetr_o') = SUM(ACNT,SAM('cpetr_o',ACNT))-(SAM('row','cpetr_o')
         +SAM('mtax','cpetr_o')+SAM('stax','cpetr_o')+SAM('trc','cpetr_o'));

 SAM('cpetr',AC)= 0;
 SAM(AC,'cpetr')= 0;

 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
 DISPLAY SAMBALCHK1;

*Land transport survey (statssa) and energy balance fuel volumes suggest that production of passenger transport
*is ~10% of the sum of passenger + freight. the sut suggests ~40%. the sam is therefore adjusted such that no sector
*consumes passenger transport which takes us closer to the 10%.

 SAM('cftrp',a)          =SAM('cftrp',a)+SAM('cptrp',a);
 SAM('altrp','cftrp')    =SAM('altrp','cftrp')+sum(a,SAM('cptrp',a));
 SAM('altrp','cptrp')    =SAM('altrp','cptrp')-sum(a,SAM('cptrp',a));
 SAM('cptrp',a)=0;

 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
 DISPLAY SAMBALCHK1;

*Single sector/commodity transport

 SAM('total',AC)=0;
 SAM(AC,'total')=0;

set
 acna(ac);

 acna(ac)=no;
 acna('stax')=yes;
 acna('mtax')=yes;
 acna('trc') =yes;
 acna('row') =yes;

 SAM('altrp-p','cptrp-l')=SAM('altrp','cptrp');
 SAM('altrp-f','cftrp-l')=SAM('altrp','cftrp');

 SAM('awtrp','cptrp-o')=SAM('awtrp','cptrp');
 SAM('awtrp','cftrp-o')=SAM('awtrp','cftrp');
 SAM('aatrp','cptrp-o')=SAM('aatrp','cptrp');
 SAM('aatrp','cftrp-o')=SAM('aatrp','cftrp');

 SAM(ac,'altrp-p')=SAM(ac,'altrp')*(SAM('altrp','cptrp')/(SAM('altrp','cptrp')+SAM('altrp','cftrp')));
 SAM(ac,'altrp-f')=SAM(ac,'altrp')*(SAM('altrp','cftrp')/(SAM('altrp','cptrp')+SAM('altrp','cftrp')));

* SAM(ac,'awtrp-p')=SAM(ac,'awtrp')*(SAM('awtrp','cptrp')/(SAM('awtrp','cptrp')+SAM('awtrp','cftrp')));
* SAM(ac,'awtrp-f')=SAM(ac,'awtrp')*(SAM('awtrp','cftrp')/(SAM('awtrp','cptrp')+SAM('awtrp','cftrp')));
* SAM(ac,'aatrp-p')=SAM(ac,'aatrp')*(SAM('aatrp','cptrp')/(SAM('aatrp','cptrp')+SAM('aatrp','cftrp')));
* SAM(ac,'aatrp-f')=SAM(ac,'aatrp')*(SAM('aatrp','cftrp')/(SAM('aatrp','cptrp')+SAM('aatrp','cftrp')));

 SAM(acna,'cptrp-l')=SAM(acna,'cptrp')*(SAM('altrp-p','cptrp-l')/(SAM('altrp-p','cptrp-l')+SAM('awtrp-p','cptrp-o')+SAM('awtrp-p','cptrp-o')));
 SAM(acna,'cptrp-o')=SAM(acna,'cptrp')-SAM(acna,'cptrp-l');

 SAM(acna,'cftrp-l')=SAM(acna,'cftrp')*(SAM('altrp-f','cftrp-l')/(SAM('altrp-f','cftrp-l')+SAM('awtrp-f','cftrp-o')+SAM('awtrp-f','cftrp-o')));
 SAM(acna,'cftrp-o')=SAM(acna,'cftrp')-SAM(acna,'cftrp-l');

 SAM('altrp',ac)=0;
 SAM(ac,'altrp')=0;
* SAM('awtrp',ac)=0;
* SAM(ac,'awtrp')=0;
* SAM('aatrp',ac)=0;
* SAM(ac,'aatrp')=0;

 SAM('cptrp-l',ac)=(SAM('cptrp',ac)/sum(acp,SAM('cptrp',acp)))*sum(acnt,SAM(acnt,'cptrp-l'));
 SAM('cptrp-o',ac)=(SAM('cptrp',ac)/sum(acp,SAM('cptrp',acp)))*sum(acnt,SAM(acnt,'cptrp-o'));

 SAM('cftrp-l',ac)=(SAM('cftrp',ac)/sum(acp,SAM('cftrp',acp)))*sum(acnt,SAM(acnt,'cftrp-l'));
 SAM('cftrp-o',ac)=(SAM('cftrp',ac)/sum(acp,SAM('cftrp',acp)))*sum(acnt,SAM(acnt,'cftrp-o'));

 SAM(ac,'cptrp')=0;
 SAM(ac,'cftrp')=0;
 SAM('cptrp',ac)=0;
 SAM('cftrp',ac)=0;

parameter
 store(ac);

 store('altrp-p') = SAM('cpetr_p','altrp-p')+SAM('cpetr_d','altrp-p');
 store('altrp-f') = SAM('cpetr_p','altrp-f')+SAM('cpetr_d','altrp-f');


 SAM('cpetr_p','altrp-p')=tempagg2('atrl_p','petrol')*store('altrp-p');
 SAM('cpetr_d','altrp-p')=(1-tempagg2('atrl_p','petrol'))*store('altrp-p');

 SAM('cpetr_p','altrp-f')=tempagg2('atrl_f','petrol')*store('altrp-f');
 SAM('cpetr_d','altrp-f')=(1-tempagg2('atrl_f','petrol'))*store('altrp-f');

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));

 SAM('apetr','cpetr_p')=SAM('apetr','cpetr_p')+SAMBALCHK1('cpetr_p');
 SAM('apetr','cpetr_d')=SAM('apetr','cpetr_d')+SAMBALCHK1('cpetr_d');

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));

$ontext
*Create single production sectors for each type of transport
Parameter
 trnshr(c)       transport shares for splitting imports and sales taxes
 htrnshr(c,ac)   shares for splitting consumption
;

 trnshr('cptrp')=(SAM('cptrp','altrp')/(SAM('cptrp','altrp')+SAM('cptrp','awtrp')+SAM('cptrp','aatrp-p')));
 trnshr('cftrp')=(SAM('cftrp','altrp')/(SAM('cftrp','altrp')+SAM('cftrp','awtrp')+SAM('cftrp','aatrp-f')));

 SAM('altrp-p','cptrp')=SAM('altrp','cptrp');
 SAM('altrp-f','cftrp')=SAM('altrp','cftrp');

 SAM(ac,'altrp-p')=SAM(ac,'altrp')*(SAM('altrp','cptrp')/(SAM('altrp','cptrp')+SAM('altrp','cftrp')));
 SAM(ac,'altrp-f')=SAM(ac,'altrp')*(SAM('altrp','cftrp')/(SAM('altrp','cptrp')+SAM('altrp','cftrp')));

* SAM('cpetr_p','altrp-f')=(edem('atrl_f','petrol')*ipfuel2('cref_p'))/1000;
* SAM('cpetr_d','altrp-f')=(edem('atrl_f','diesel')*ipfuel2('cref_d'))/1000;

 SAM('cpetr_p','altrp-p')=(edem('atrl_p','petrol')*ipfuel2('cref_p'))/1000;
 SAM('cpetr_d','altrp-p')=(edem('atrl_p','diesel')*ipfuel2('cref_d'))/1000;

* SAM('cpetr_p','altrp-p')=SAM('cpetr_p','altrp')-SAM('cpetr_p','altrp-f');
* SAM('cpetr_d','altrp-p')=SAM('cpetr_d','altrp')-SAM('cpetr_d','altrp-f');

 SAM('cpetr_p','altrp-f')=SAM('cpetr_p','altrp')-SAM('cpetr_p','altrp-p');
 SAM('cpetr_d','altrp-f')=SAM('cpetr_d','altrp')-SAM('cpetr_d','altrp-p');

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
*$exit
*FH 270219 matching freight fuel use to eb
*NB: Need to generalise this if conditions are different. Need to think about how to do this
 if((SAMBALCHK1('altrp-p') lt 0) and ((SAM('cptrp','altrp-p')+SAM('cftrp','altrp-p')) lt abs(SAMBALCHK1('altrp-p'))),
 SAM('cptrp','altrp-f')=SAM('cptrp','altrp-f')+SAM('cptrp','altrp-p');
 SAM('cftrp','altrp-f')=SAM('cftrp','altrp-f')+SAM('cftrp','altrp-p');

 SAM('cvehi','altrp-f')=SAM('cvehi','altrp-f')+(abs(SAMBALCHK1('altrp-p'))-SAM('cptrp','altrp-p')-SAM('cftrp','altrp-p'));
 SAM('cvehi','altrp-p')=SAM('cvehi','altrp-p')-(abs(SAMBALCHK1('altrp-p'))-SAM('cptrp','altrp-p')-SAM('cftrp','altrp-p'));

 SAM('cptrp','altrp-p')=0;
 SAM('cftrp','altrp-p')=0;
);

* SAM(ac,'awtrp-p')=SAM(ac,'awtrp')*(SAM('awtrp','cptrp')/(SAM('awtrp','cptrp')+SAM('awtrp','cftrp')));
* SAM(ac,'awtrp-f')=SAM(ac,'awtrp')*(SAM('awtrp','cftrp')/(SAM('awtrp','cptrp')+SAM('awtrp','cftrp')));

* SAM(ac,'aatrp-p')=SAM(ac,'aatrp')*(SAM('aatrp','cptrp')/(SAM('aatrp','cptrp')+SAM('aatrp','cftrp')));
* SAM(ac,'aatrp-f')=SAM(ac,'aatrp')*(SAM('aatrp','cftrp')/(SAM('aatrp','cptrp')+SAM('aatrp','cftrp')));

 SAM(ac,'altrp')=0;
* SAM(ac,'awtrp')=0;
* SAM(ac,'aatrp')=0;

 SAM('altrp',ac)=0;
* SAM('awtrp',ac)=0;
* SAM('aatrp',ac)=0;

 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));

 htrnshr('cptrp',acnt)=SAM('cptrp',acnt)/sum(acntp,SAM('cptrp',acntp));
 htrnshr('cftrp',acnt)=SAM('cftrp',acnt)/sum(acntp,SAM('cftrp',acntp));

* Split transport sector into single product producing sectors
 SAM('altrp-p','cptrp-l')=SAM('altrp-p','cptrp');
 SAM('altrp-f','cftrp-l')=SAM('altrp-f','cftrp');

 SAM('awtrp','cptrp-o')=SAM('awtrp','cptrp');
 SAM('awtrp','cftrp-o')=SAM('awtrp','cftrp');

 SAM('aatrp','cptrp-o')=SAM('aatrp','cptrp');
 SAM('aatrp','cftrp-o')=SAM('aatrp','cftrp');

* SAM('awtrp-p','cptrp-o')=SAM('awtrp-p','cptrp');
* SAM('awtrp-f','cftrp-o')=SAM('awtrp-f','cftrp');

* SAM('aatrp-p','cptrp-o')=SAM('aatrp-p','cptrp');
* SAM('aatrp-f','cftrp-o')=SAM('aatrp-f','cftrp');

*split column values for transport commodity
 SAM('row','cptrp-l')=SAM('row','cptrp')*trnshr('cptrp');
 SAM('row','cptrp-o')=SAM('row','cptrp')*(1-trnshr('cptrp'));

 SAM('row','cftrp-l')=SAM('row','cftrp')*trnshr('cftrp');
 SAM('row','cftrp-o')=SAM('row','cftrp')*(1-trnshr('cftrp'));

 SAM('stax','cptrp-l')=SAM('stax','cptrp')*trnshr('cptrp');
 SAM('stax','cptrp-o')=SAM('stax','cptrp')*(1-trnshr('cptrp'));

 SAM('stax','cftrp-l')=SAM('stax','cftrp')*trnshr('cftrp');
 SAM('stax','cftrp-o')=SAM('stax','cftrp')*(1-trnshr('cftrp'));

 SAM('TOTAL',AC)=SUM(ACNTP,SAM(ACNTP,AC));

 SAM('cptrp-l',ac)=SAM('total','cptrp-l')*htrnshr('cptrp',ac);
 SAM('cptrp-o',ac)=SAM('total','cptrp-o')*htrnshr('cptrp',ac);
 SAM('cftrp-l',ac)=SAM('total','cftrp-l')*htrnshr('cftrp',ac);
 SAM('cftrp-o',ac)=SAM('total','cftrp-o')*htrnshr('cftrp',ac);

 SAM(ac,'altrp')=0;
* SAM(ac,'awtrp')=0;
* SAM(ac,'aatrp')=0;

 SAM('altrp',ac)=0;
* SAM('awtrp',ac)=0;
* SAM('aatrp',ac)=0;

 SAM(ac,'cftrp')=0;
 SAM(ac,'cptrp')=0;

 SAM('cftrp',ac)=0;
 SAM('cptrp',ac)=0;

 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));
$offtext
*FH 10/05/2019
*Shift electricity sector's coal transport costs to the electricity sector only by reducing trc on ccoal.
*Target value is R5.45 billion. We assume that there is no transport coal transport for Sasol.
Parameter
 target_add
;

 target_add = (5.45*1000)-SAM('cftrp-l','aelec');

 SAM('trc','ccoal')=SAM('trc','ccoal')-target_add;
 SAM('cftrp-l','trc')=SAM('cftrp-l','trc')-target_add;

 SAM('cftrp-l','aelec')= SAM('cftrp-l','aelec')+target_add;
 SAM('ccoal','aelec')=SAM('ccoal','aelec')-target_add;

 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));

*--------------------------------------------------------------------------------------------
*7. Removing activity electricity - not in EB. keep other transport's consumption. Not worth
*the effort of removing, also present in DoE EB.
*--------------------------------------------------------------------------------------------
 SAM('aelec','celec')=SAM('aelec','celec')-SAM('celec','aelec');

 SAM('celec','aelec')=0;

 SAM(AC,'TOTAL')=SUM(ACNTP,SAM(ACNTP,AC));
 SAM('TOTAL',AC)=SUM(ACNTP,SAM(AC,ACNTP));

 SAMBALCHK1(ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP))-SUM(ACNTP,SAM(ACNTP,ACNT));


*!!!! Check production price ancd also compare to import and export prices
Parameter
 LFPRICE(c,*)
 LFPRICE2(c,*)
;

*Liquid Fuels
 LFPRICE('cpetr_p','prod')=(SAM('apetr','cpetr_p')+SAM('apetr','cpetr_d')+SAM('apetr','cpetr_o'))
                         /(eprod('petrol')+eprod('diesel')+sum(lfuelo,eprod(lfuelo)));
*!incude export maret and others in cacuation
 LFPRICE('cpetr_p','dem')=(sum(ACNT,SAM('cpetr_p',ACNT))-SAM('cpetr_p','aelec')-SAM('cpetr_p','row'))
                         /(sum(eba,edem(eba,'petrol'))-sum(eelec,edem(eelec,'petrol')));

 LFPRICE('cpetr_d','dem')=(sum(ACNT,SAM('cpetr_d',ACNT))-SAM('cpetr_d','aelec')-SAM('cpetr_d','row'))
                         /(sum(eba,edem(eba,'diesel'))-sum(eelec,edem(eelec,'diesel')));

 LFPRICE('cpetr_o','dem')=(sum(ACNT,SAM('cpetr_o',ACNT))-SAM('cpetr_o','aelec')-SAM('cpetr_o','row'))
                         /(sum((eba,lfuelo),edem(eba,lfuelo))-sum((eelec,lfuelo),edem(eelec,lfuelo)));

 LFPRICE('cpetr_p','elec')$sum(eelec,edem(eelec,'petrol'))=SAM('cpetr_p','aelec')/sum(eelec,edem(eelec,'petrol'));
 LFPRICE('cpetr_d','elec')$sum(eelec,edem(eelec,'diesel'))=SAM('cpetr_d','aelec')/sum(eelec,edem(eelec,'diesel'));
 LFPRICE('cpetr_o','elec')$sum((eelec,lfuelo),edem(eelec,lfuelo))
         =SAM('cpetr_o','aelec')/sum((eelec,lfuelo),edem(eelec,lfuelo));

 LFPRICE('cpetr_p','exp')=SAM('cpetr_p','row')/eexp('petrol');
 LFPRICE('cpetr_d','exp')=SAM('cpetr_d','row')/eexp('diesel');
 LFPRICE('cpetr_o','exp')=SAM('cpetr_o','row')/(sum(lfuelo,eexp(lfuelo)));

* LFPRICE('cpetr_p','imp')=SAM('row','cpetr_p')/eimp('petrol');
 LFPRICE('cpetr_d','imp')=SAM('row','cpetr_d')/eimp('diesel');
 LFPRICE('cpetr_o','imp')=SAM('row','cpetr_o')/(sum(lfuelo,eimp(lfuelo)));

*Electricity
 LFPRICE('celec','prod')=SAM('aelec','celec')/eprod('electricity');
 LFPRICE('celec','dem') =(sum(ACNT,SAM('celec',ACNT))-SAM('celec','apetr')-SAM('celec','aelec')-SAM('celec','row'))
                         /(sum(eba,edem(eba,'electricity'))-sum(eelec,edem(eelec,'electricity'))-sum(epetr,edem(epetr,'electricity')));
 LFPRICE('celec','ref') =SAM('celec','apetr')/sum(epetr,edem(epetr,'electricity'));
 LFPRICE('celec','exp') =SAM('celec','row')/eexp('electricity');
 LFPRICE('celec','imp') =SAM('row','celec')/eimp('electricity');

*Coal
 LFPRICE('ccoal','prod')=SAM('acoal','ccoal')/eprod('coal');
 LFPRICE('ccoal','marg')=(SAM('trc','ccoal')+SAM('stax','ccoal')+SAM('mtax','ccoal'))/eprod('coal');
 LFPRICE('ccoal','dem')=((sum(A,SAM('ccoal',A))-SAM('ccoal','apetr')-SAM('ccoal','aelec'))+sum(H,SAM('ccoal',H)))
                         /(sum(eba,edem(eba,'coal'))-sum(eelec,edem(eelec,'coal'))-sum(epetr,edem(epetr,'coal')));
* LFPRICE('ccoal','dem') =(sum(ACNT,SAM('ccoal',ACNT))-SAM('ccoal','apetr')-SAM('ccoal','aelec')-SAM('ccoal','row'))
*                         /(sum(eba,edem(eba,'coal'))-sum(eelec,edem(eelec,'coal'))-sum(epetr,edem(epetr,'coal')));
 LFPRICE('ccoal','ref') =SAM('ccoal','apetr')/sum(epetr,edem(epetr,'coal'));
 LFPRICE('ccoal','elec')=SAM('ccoal','aelec')/sum(eelec,edem(eelec,'coal'));
 LFPRICE('ccoal','exp') =SAM('ccoal','row')/eexp('coal');
 LFPRICE('ccoal','imp') =SAM('row','ccoal')/eimp('coal');

 LFPRICE2('cpetr_p','prod')=SAM('apetr','cpetr_p')/eprod('petrol');
 LFPRICE2('cpetr_d','prod')=SAM('apetr','cpetr_d')/eprod('diesel');
 LFPRICE2('cpetr_o','prod')=SAM('apetr','cpetr_o')/sum(lfuelo,eprod(lfuelo));

*Energy table to go to *rsaenergy.xlsx
Parameter
 ETABLE(*,EBA,FUEL)
;

 ETABLE('Production','extract',FUEL)=EPROD(FUEL);
 ETABLE('Production','extract','Coal')=EPROD('Coal');
 ETABLE('Production','extract','Petrol')=sum(LFUELT,EPROD(LFUELT))
                                                 +sum(LFUELO,EPROD(LFUELO));
 ETABLE('Production','extract','Diesel')=0;
 ETABLE('Production','extract','LPG')=0;
 ETABLE('Production','extract','HFO')=0;
 ETABLE('Production','extract','Jet_Par')=0;

 ETABLE('Imports','imp',FUEL)=EIMP(FUEL);
 ETABLE('Imports','imp','Petrol')=sum(LFUELT,EIMP(LFUELT))
                                         +sum(LFUELO,EIMP(LFUELO));
 ETABLE('Imports','imp','Diesel')=0;
 ETABLE('Imports','imp','LPG')=0;
 ETABLE('Imports','imp','HFO')=0;
 ETABLE('Imports','imp','Jet_Par')=0;

 ETABLE('Exports','exp',FUEL)=EEXP(FUEL);
 ETABLE('Exports','exp','Petrol')=sum(LFUELT,EEXP(LFUELT))
                                         +sum(LFUELO,EEXP(LFUELO));
 ETABLE('Imports','imp','Crude oil')=ETABLE('Imports','imp','Crude oil')
                                         -ETABLE('Exports','exp','Crude oil');
 ETABLE('Exports','exp','Crude oil')=0;
 ETABLE('Exports','exp','Diesel')=0;
 ETABLE('Exports','exp','LPG')=0;
 ETABLE('Exports','exp','HFO')=0;
 ETABLE('Exports','exp','Jet_Par')=0;


 ETABLE('Demand',EBA,FUEL)=EDEM(EBA,FUEL);
 ETABLE('Demand',EBA,'Coal')=EDEM(EBA,'Coal');
 ETABLE('Demand',EBA,'Petrol')=sum(LFUELT,EDEM(EBA,LFUELT))
                                         +sum(LFUELO,EDEM(EBA,LFUELO));
 ETABLE('Demand',EBA,'Diesel')=0;
 ETABLE('Demand',EBA,'LPG')=0;
 ETABLE('Demand',EBA,'HFO')=0;
 ETABLE('Demand',EBA,'Jet_Par')=0;

 ETABLE('Demand','aelc_coal',FUEL)=ETABLE('Demand','aelc_coal',FUEL)
         +ETABLE('Demand','aelc_gas',FUEL)+ETABLE('Demand','aelc_bio',FUEL);
 ETABLE('Demand','aelc_gas',FUEL)=0;
 ETABLE('Demand','aelc_bio',FUEL)=0;

 ETABLE('Demand','aref_oil',FUEL)=ETABLE('Demand','aref_oil',FUEL)
         +ETABLE('Demand','aref_ctl',FUEL)+ETABLE('Demand','aref_gtl',FUEL);
 ETABLE('Demand','aref_ctl',FUEL)=0;
 ETABLE('Demand','aref_gtl',FUEL)=0;

*Petroleum volumes (PJ)
Parameter
 EFUEL(*,*);

 EFUEL(EBA,'PETROL')=EDEM(EBA,'PETROL');
 EFUEL(EBA,'DIESEL')=EDEM(EBA,'DIESEL');
 EFUEL(EBA,'OTHER')=SUM(LFUELO,EDEM(EBA,LFUELO));
 EFUEL('EXP','PETROL')=EEXP('PETROL');
 EFUEL('EXP','DIESEL')=EEXP('DIESEL');
 EFUEL('EXP','OTHER')=SUM(LFUELO,EEXP(LFUELO));
 EFUEL('IMP','PETROL')=EIMP('PETROL');
 EFUEL('IMP','DIESEL')=EIMP('DIESEL');
 EFUEL('IMP','OTHER')=SUM(LFUELO,EIMP(LFUELO));
 EFUEL('PROD','PETROL')=EPROD('PETROL');
 EFUEL('PROD','DIESEL')=EPROD('DIESEL');
 EFUEL('PROD','OTHER')=SUM(LFUELO,EPROD(LFUELO));


*unload SAM into excel sheets for eSAM split
execute_unload "energy2.gdx" SAM ETABLE EBAL LFPRICE LFPRICE2 EFUEL
execute 'xlstalk.exe -m %energy2%';
 XLTEST = ERRORLEVEL;
IF(XLTEST = 1,
execute 'xlstalk.exe -c %energy2%';
);
IF(XLTEST = 2,
execute 'xlstalk.exe -s %energy2%';
);
execute 'gdxxrw.exe i=energy2.gdx o=%energy2% index=index!a2';
*$offtext
