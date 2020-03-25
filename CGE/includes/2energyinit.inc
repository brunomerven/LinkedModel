*---------------------------------------------------------------
*INITIALIZATION FILE FOR LINKING TIMES AND CGE MODEL -----------
*---------------------------------------------------------------
*$SETGLOBAL referencerun CGERUNF01
*$SETGLOBAL referencerun REFC
*$SETGLOBAL referencerun RUN_01_CT_1
*$SETGLOBAL GDXoutfolder C:\SATMGE_1.5\GDXout\

scalar SATIMODE 0 = supply sector mode - 1 = full sector mode;
SATIMODE = 1;

SETS
*Forecasting sets
 TIEPG(TC)               Years for which an electricity price forecast exists
 FSXEP(FS)               sector groupings in SATIM to be used in ica growth mapping controlled below
 CXEP(C)                 commodities that get include3d in the ica adjustment
 EU                      end uses
*Mappings
 MFHH(FH,H)              mapping SAGE and SATIM households
 MFHFH(FH,FH)            mapping between household with and without electricity
 MFSA(FS,A)              mapping SAGE and SATIM sectors
 MPRCATYPE(PRC,A,TECHTYPE)       mapping SATIM PRCs to SAGE activities with Energy Tech Type detail
 MPRCA(PRC,A)            mapping SATIM PRCs to SAGE activities
 MPRCFS(PRC,FS)          mapping SATIM PRCs to SATIM sectors (temporarily until sectors are reaggregated in the same way in both models)
 MPRCFS2(PRC,FS)          mapping SATIM PRCs to SATIM sectors (used to pass CGE aggregates to SATIM sectors)
 MPRCFH(PRC,FH)          mapping SATIM PRCs to SATIM household income groups
 MPRCFT(PRC,FT)          mapping SATIM PRCs to SATIM passenger (private-public) transport categories
 MPRCCOM(PRC,COM)        mapping of fuels and techs
 mCOMC(COM,C)            mapping SAGE and SATIM fuels
 mCOMF(COM,F)            mapping SAGE factors and SATIM factor commodities

* Linked Supply Sectors
 ALS(A)                  SATIM-eSAGE linked sectors /AELEC,APETR/


* sets used in detailed elc price calculation
 SUPELE(PRC)     power sector technologies
 SUPCLE(PRC)  coal supply technologies
 SUPGAS(PRC)  gas supply technologies
 SUPOIL(PRC)  oil supply technologies

 PWR(COM) fuels to power
 XELC(PRC) transmission and distribution technologies
 COALSUP(PRC) detailed coal supply techs

 CCOAL(C)              coal commodities in eSAGE / ccoal-low, ccoal-hgh /

* sets used for reverse mapping of households
*FH*----------------------------------------------------------------------------
 MFHHT(FH,H,AY) reverse mapping (TIMES to CGE) for households

* bm sets for adjusting budget share weightings
 CLN(H,HP,T)         Closest Lower Neighbour
 CUN(H,HP,T)         Closets Upper Neighbour

* bm sets for adjusting budget share weightings of energy goods
 CHouseholds(C) Commodities consumed by households
 CHEnergy(C) Energy Commodities consumed by households / ccoal-hgh, celec, cpetr_o, cptrp-l , cprtr /

* Transport Demands
 TPPR(COM) Private Passenger Demand Commodities /TPPRCAR, TPPRMOT, TPPRSUV/



* leaving cptrp-o out for now, as it doesn't directly link to mode switching questions, this could be treated separately when looking at air travel questions.

 CHNonEnergy(C) Non-Energy Commodities consumed by households
;


;

Parameters
* parameters used for reverse mapping of households
*FH*----------------------------------------------------------------------------
 popval(H,X,AY)     bounds for reverse mapping
 popvalfact(H,X,AY) parameter required for top 10% split


* bm parameters used for updating ica for household consumption of energy services e.g. private transport
 EHIntensity(C,A,AY) energy intensity for household consumed energy services

* bm parameters used for adjusting budget share weightings
 BudShare(C,H,T)  budget share of marketed commodity c by household h

 BudShare0(C,H,T)  budget share of marketed commodity c by household h used as template


 DistanceMatrix(H,HP,T) distance to all

 TmpMin(H,T) minimum of row
 TmpLowerNeighbour(H,HP,T) lower neighbour
 TmpUpperNeighbour(H,HP,T) upper neighbour

 TotalDistance(H,T) sum of distances
 DistLower(H,T) distance to lower
 DistUpper(H,T) distance to upper
 WeightLower(H,T) weighting of lower
 WeightUpper(H,T) weighting of upper

* bm parameters to do budget reallocations of energy goods
 PQest(C,T)         price estimate for commodity based on ica change
 Rebound(T) rebound factor
 BudShareNoRebound(C,H,T)  assuming no Rebound
 BudShareFullRebound(C,H,T) assuming full Rebound
 BudShareNonEnergy(H,T) buget share of non-energy good for re-allocation calculations

;

* Identifying Energy goods consumed by households
CHouseholds(C)$sum(H,BUDSHR(C,H)) = YES;
CHNonEnergy(CHouseholds) = YES;
CHNonEnergy(CHEnergy) = NO;

*initialise rebound parameter (should be made a scenario parameter later)
Rebound(T) = 0;
PQX('celec','base','2012',TT) = PQ0('celec');
YIX(H,'base','2012',TT) = YI0(H);
QHX('cprtr',H,'base','2012',TT) = QH0('cprtr',H);
* mapping of households
*FH*----------------------------------------------------------------------------
 popvalfact(H,X,TC)=1;






ALIAS (EU,EUP,EUPP), (FH,FHP);


* remove those two lines when TC goes to 2050
set LYTC(AY) last year of TC /2040/;
set MYPTC(AY) milestone years post TC /2045, 2050/;

$call    "gdxxrw i=.\links\0forecast.xlsx o=forecast index=index!a6"
$gdxin   forecast.gdx


$load TIEPG FH FT XELC COALSUP


* set sectors that are linked with the main ica calc approach
FSXEP(FS) = Yes;
*FSXEP('COM') = No;
*FSXEP('AGR') = No;
*FSXEP('mi') = No;
*FSXEP('fb') = No;
*FSXEP('ot') = No;
*FSXEP('pp') = No;
*FSXEP('cp') = No;
*FSXEP('nm') = No;
*FSXEP('is') = No;
*FSXEP('nf') = No;
*FSXEP('elec') = No;
*FSXEP('tran') = No;
*FSXEP('petr') = No;


* set commodities that get set using the main ica calc approach
CXEP(C) = Yes;
*CXEP('celec') = No;
*CXEP('cngas') = No;

* the fuels to be done in a different way
*b SETS
*b  MFUELP(FUELP,AC,*)      mapping fuel price fuels

*b ;

$load MFHH MFSA MPRCATYPE MPRCA MPRCCOM MPRCFS MPRCFS2 MPRCFH MPRCFT mCOMC mCOMF MINCLPWR MINCLDUAL MINCLDUAL_A SUPGIC


PARAMETER
*Forecasts based on CGE results
 SFORE(FS,X,AY)           loaded: sectoral growth forecast for SATIM
 SFORE_X(FS,AY)           GDP by SATIM sector for sim XC
 TFHPOP_X(FH,AY)          Population by SATIM income group for sim XC
 PKMFH(FT,FH,AY)             Passenger km demand share by income group
 sumSFORE                sum of SFORE in base year
* GDP_FSX(FS,AY)           alias to SFORE - for export to demand workbook
 POPSX(AY)                 population projection for SATIM
 HFORE(FH,X,AY)           loaded: household income forecast for SATIM
 YHE(AY)                  income of higher income group for SATIM
 PFORE(FH,X,AY)           loaded: household population forecast for SATIM
 IFORE(AY,AC)             loaded: initial electricity demand forecast
 IEPGFORE(AY,AC)          loaded: initial electricity price growth forecast
 BFORE(AY,TECHTYPE)             loaded: historical electricity build
*Residential
 FHMMB(FH,*,AY)

 FHMM(FH,*)              loaded: base year min max and mean for each cluster
 FHMEAN(FH,AY)            result: mean household income value in TIMES units
 FHFACT(FH,AY)            result: adjustment factor
 FHMOVE(FH,FHP,AY)        result: population movement between clusters
 FHPOP(FH,AY)             result: final cluster populations after reallocations
 ELECRATE(FH,AY)          loaded: household electriification rates
 TFHPOP(FH,X,AY)            result: population kept before elc split for transport
 TFHPOPMY(FH,AY)           result: population for TIMES milestone years
*Electricity Demand
 ELCDEM(X,AY,TT)          result: electricity demand
*Exporting from CGE to TIMES

* SIM_DEMX(COM,T)          Demand extracted from excel DMD_PRJ file
* PKMFH(FT,FH,T)             Passenger km demand share by income group
* Passengerkm(COM,T)        pkm for passenger transport
* Tonkm(COM,T)                Tonkm for Freight transport





 EFVAL                   output: temporary storage for putting values
 COMBUILD(PRC,AY)    trnsfr: past committed build plan
 COUNT              counting parameter

* TIMES parameters used
* PAR_NCAPL(REG,T,PRC)  TIMES new capacity
* PAR_NCAPR(REG,T,PRC,XXX)  TIMES Levelised Cost
* PRC_RESID(REG,T,PRC)  TIMES existing capacity
* PRC_CAPACT(REG,PRC) Factor going from capacity to activity
* REG_OBJ(REG)              Objective function from TIMES
* PAR_CAPL(REG,T,PRC)   TIMES cumulative new capacity
* F_IN(REG,V,T,PRC,COM,S) Flow parameter (level of flow variable) [PJ]
* F_OUT(REG,V,T,PRC,COM,S) Flow parameter (level of flow variable)[PJ]
* VARACT(REG,T,PRC) Activity level [PJ except for demand techs where unit will be aligned to particular demand e.g. VKM for road vehicles]
* PAR_ACTL(REG,V,T,PRC,S) TIMES activity
* NCAP_ILED(REG,T,PRC)  TIMES lead time
* OB_ICOST(REG,PRC,XXX,T) TIMES investment cost
* OBICOST(REG,T,PRC) TIMES investment cost restructured for interpolation
* PAR_COMBALEM(REG,T,COM,S) TIMES marginals
* CST_INVC(REG,V,T,PRC,XXX) TIMES calculated annual investment costs
* CST_ACTC(REG,V,T,PRC) TIMES calculated annual activity costs
* CST_FIXC(REG,V,T,PRC) TIMES calculated annual fixed costs

 TCST_INVC(REG,AY,PRC) TIMES calculated annual investment costs
 TCST_ACTC(REG,AY,PRC) TIMES calculated annual activity costs
 TCST_FIXC(REG,AY,PRC) TIMES calculated annual fixed costs
 TCST_ELE_I(RUN,AY) ELC total inv costs (Gx)
 TCST_ELE_A(RUN,AY) ELC total act costs (Gx)
 TCST_ELE_F(RUN,AY) ELC total F costs   (Gx)
 TCST_ELE_X(RUN,AY) ELC total TDX costs (Tx + Dx)
 TCST_ELE_INV(RUN,AY) Elc total inv cost (Gx + Tx + Dx)

 TCST_COALSUP(RUN,AY) Total costs from detailed coal supply model

 ELC_FLOW(RUN,AY) Electricity flows used as denominator in elc price calculation
 ELC_FLOW2(RUN,AY) Electricity flows used as denominator in elc price calculation

 OIL_FLOW(RUN,AY) Oil product flows used as denominator in ica calc for petroleum
 COAL_FLOW(RUN,AY,C) Coal flows used for theta calcs

 ELC_IMP(RUN,AY) Electricity Imports
 OIL_IMP(RUN,AY) Oil product imports

* CO2 in power sector
TPWRCLE(AY) TIMES calculated annual coal use in power sector (PJ)
TPWRCLETAX(AY) TIMES calculated CO2 tax


*Exporting from TIMES to CGE
 TVNCAP(AY,PRC)   New Capacity
 TVCAP(AY,PRC)    Total Capacity
 TVACT(AY,PRC)    Activity (output)
 TVFLOWIN(COM,AY,PRC) flow in (input)
 TVFLOWOUT(COM,AY,PRC) flow out (output)

 UCONV_C_T2C(C)            Unit conversion from TIMES-SATIM (PJ) to ESAGE (e.g. TWh)
 UCONV_A_T2C(A)            Unit conversion from TIMES-SATIM (PG) to ESAGE (e.g. tons)

 BPINV(X,AY,TCP,PRC)       Annual expenditure on construction by PRC for each new Cap year
 EINVCOST(X,AY,TT)        Total annual expenditure on construction
 INVCOST(RUN,AY,TT,PRC)     Annual expenditure on construction by PRC

*Fuel prices
 AACT_COST_BASE(FUELP)   Activity cost for harmonizing price of global commodities in the base year
 AACT_COST(FUELP,AY)      Activity cost for harmonizing price of global commodities
 FUELPPROJ(FUELP,AY)      global commidity price indexed
*Electricity price from TIMES
 TVCOMBAL(AY,COM)         Fuel Marginals from TIMES
 ETPRICE(AY)              Regulated Elc Price Calculated in SATIM
 ETPRICEGR(AY)            SATIM Elc Price growth

 EPRICE(AY,TT)            Elc Price in CGE units

*Exogenous world commodity prices from times
 PWEPROJ(C,RW,AY)     export price projections from TIMES (supersedes CGE specified growth in pwegr)
 PWMPROJ(C,RW,AY)     import price projections from TIMES (supersedes CGE specified growth in pwmgr)

 MAYR            Number of years for moving average  / 3 /
*Sectoral, household and population forecast data (used in forecast code)
 SBASE(FS,X,AY,TT)   Moving average growth rate used for future sectoral growth projections
 HBASE(FH,X,AY,TT)   Moving average growth rate used for future household 'income' growth projections
 PBASE(FH,X,AY,TT)   Moving average growth rate used for future population growth projections
 SGROW(FS,X,AY,TT)   Moving average growth rate used for future sectoral growth projections
 HGROW(FH,X,AY,TT)   Moving average growth rate used for future household 'income' growth projections
 PGROW(FH,X,AY,TT)   Moving average growth rate used for future population growth projections
*Electricity forecast data (export to TIMES)
 EFORE(X,AY,TT)      CGE variable used to forecast electricity demand (e.g. GDP)
 EGROW(X,AY,TT)      Moving average growth rate used for future electricity projections
 EPROJ(A,X,AY,TT)   Electricity demand projection
 EPROJGR(A,AY)      Electricity demand projection growth used for extrapolation
 EELAS           / 0.6 /
*Supply and investment data (results from TIMES)
 TFLOW(A,TECHTYPE,RUN,AY,TT) Raw energy supply results from TIMES (production aggregated to SAM activities)

 EFLOW(TECHTYPE,X,AY,TT)   Electricity supply vector for production (results from TIMES)
 PFLOW(TECHTYPE,X,AY,TT)   Petroleum (fuels) supply vector for production (results from TIMES)

 TCAP(A,RUN,AY,TT) Raw energy supply results from TIMES (Capacity aggregated to SAM activities)
 ECAP(X,AY,TT)    Electricity supply vector for capacity (results from TIMES)
 ENCAP(PRC,X,AY,TT)  Electricity supply vector for new capacity
 PCAP(X,AY,TT)    Petroleum (fuels) supply vector for capacity (results from TIMES)
*BM+FH 201218: SETTING STARTING POINT FOR HYDROGEN
 HCAP(X,AY,TT)       Hydrogen (fuels) supply vector for capacity (results from TIMES)
 CCAP(AY,TT)       Coal supply vector for capacity (results from TIMES)
 COALMINCAP(TC) coal mining capacity (sum of consumption and exports-imports)



 FLOW_IN_A(A,COM,AY) Consumption of SATIM commodity COM for CGE activity A
 FLOW_IN_AFuels(A,C,AY,TT) Consumption of CGE commodity C for CGE activity A

 FLOW_IN_FS(FS,COM,AY) Consumption of SATIM commodity COM for SATIM sector FS
 FLOW_IN_FSFuels(FS,C,AY,TT) Consumption of CGE commodity C for SATIM sector FS

 FLOW_OUT_FS(FS,COM,AY) Production of SATIM commodity COM for SATIM sector FS
 FLOW_OUT_FSFuels(FS,C,AY,TT) Production of CGE commodity C for SATIM sector FS
 FLOW_OUT_FSFactors(FS,F,AY,TT) Production of CGE Factor F for SATIM sector FS

 FLOW_IN_FH(FH,COM,AY) Consumption of SATIM commodity COM for household sector FH
 FLOW_IN_FHFuels(FH,C,AY) Consumption of CGE commodity C for household sector FH

 FLOW_IN_FHFuelsGR(FH,C,AY) Change-Growth in Consumption of CGE commodity C for household sector FH

 FLOW_IN_FT(FT,COM,AY) Consumption of SATIM commodity COM for transport activity FT
 FLOW_IN_FTFuels(FT,C,AY) Consumption of CGE commodity C for transport activity FT

 FLOW_IN_FTFHFuels(FH,C,AY) Consumption of transport commodity by SATIM households

 FLOW_IN_FHAllFuels(FH,C,AY) consumption of all energy commodities by household FH

 EIntensity_FH(FH,C,AY)    Energy Intensity of SATIM households
 EIntensity_FS(FS,C,AY)    Energy Intensity of SATIM sectors
 FIntensity_FS(FS,F,AY)    Factor Intensity of SATIM sectors

* Elc price calc parameters
* TCST_ELE(T) power plant costs excluding fuel

* TCST_PWRCL(T) dedicated mines costs
* TCST_PWRDUAL(T) dual mines costs central basin
* TCST_PWRDUAL_A(T) dual mines costs waterberg
* TCST_PWRCLT(T) total coal costs to power sector
* TCST_PWROTH(T) other fuel costs to power sector

* TCST_SUPGIC(T) coastal gas costs
* GICM(T) coastal gas marginal test

* ICA change/growth parameters
 ICAFSGR(C,FS,AY,TT) change in ICA for SATIM sectors
 IFAFSGR(F,FS,AY,TT) change in IFA for SATIM sectors

 ICAGR(C,A,AY) change in ICA
 IFAGR(F,A,AY) change in IFA

 QFEGY_GR(RUN,AY) Growth in capital supply (Electricity)

*FH gammam growth parameters
 gammamgr(C,H,AY,TT)    growth in electricity consumption (from TIMES)

* Transport Mode Scenario
 TRAMOD        Transport mode scenario

;
* set Transport Mode scenario to default
TRAMOD = 0;


* to exclude the base year from the timeseries

$loaddc FHMM MFHFH
$loaddc IFORE IEPGFORE BFORE
$load UCONV_C_T2C UCONV_A_T2C
* $load PWEPROJ PWMPROJ

*Initially assume external forecast for current simulation
 EPROJ(A,XC,TC,TT)    = IFORE(TC,A);
 SFORE(FS,XC,TC) = SUM((A,RD)$MFSA(FS,A), PVA0(A,RD)*QVA0(A,RD));
 HFORE(FH,XC,TC)$SUM(H$MFHH(FH,H), HPOP0(H)) = SUM(H$MFHH(FH,H), YI0(H)/HPOP0(H))/CPI0;
 PFORE(FH,XC,TC) = SUM(H$MFHH(FH,H), HPOP0(H))/1000;



*Declare text (dds) files for TIMES-CGE linking
* FILE EFFILE /"..\satm\Gams_WrkTI\cge_eforecast+REGION1.dds"/;
* FILE COMFILE /"..\satm\gams_wrkti-PAMS\cge_combuild+REGION1.dds"/;
* FILE PRCFILE /"..\satm\gams_wrkti\cge_fuel+REGION1.dds"/;


*Initialize electricity subsector supply growth rates to historical growth rates
*b ECAPGR(RD,XC,AY,TT)$BFORE(T-1,RD) = BFORE(T,RD)/BFORE(T-1,RD)-1;

*b Initialise electricity price growth to historical growth rates
 ETPRICEGR(TIEPG) = IEPGFORE(TIEPG,'aelec');

*Initialize committed builds to be sent to TIMES (used to fixed past investments)
*  Zero because historical committed builds already inside TIMES calibration
 COMBUILD(PRC,TC) = 0;

*---------------------------------------------------

*Initialize values of linking variables
* EFLOW('IMP',XC,TC,TT) = QM0('CELEC','REST');
* PFLOW('IMP',XC,TC,TT) = QM0('CPETR','REST');

 ETPRICE(TC) = PQ0('CELEC');

*fh: TEMP EXCLUSION 1702
* PFLOW('IMP',XC,TC,TT) = QM0('CPETR','REST');
* AFLOW_INFuels('APETR','CCOIL',TC,TT) = QINT0('CCOIL','APETR');






* define subsets used by both models
SUPELE(PRC)$sum(TECHTYPE,MPRCATYPE(PRC,'aelec',TECHTYPE)) = YES;
SUPOIL(PRC)$sum(TECHTYPE,MPRCATYPE(PRC,'apetr',TECHTYPE)) = YES;
SUPCLE(PRC)$sum(TECHTYPE,MPRCATYPE(PRC,'acoal',TECHTYPE)) = YES;
SUPGAS(PRC)$sum(TECHTYPE,MPRCATYPE(PRC,'angas',TECHTYPE)) = YES;

XPWR(PRC)$sum(COM,MPRCCOM(PRC,COM)) = YES;
PWR(COM)$sum(PRC,MPRCCOM(PRC,COM)) = YES;
