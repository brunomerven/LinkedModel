*This batch file runs the SATMGE model. The file can be used to run the SATIM
*only, CGE only and linked model. The model run is controlled through the MCSIM file.
*The file includes the TIMES model, the simulation files of the CGE model and the CGE
*model results files. To run the batch file for the CGE only or linked model the
*restart file should be set as follows: r=cge\model.

*1.Set directories*-------------------------------------------------------------
$SETGLOBAL workingfolder C:\SATIMGE_02\
$SETGLOBAL Rworkingfolder C:/SATIMGE_02/
* TIMES GDX output folder
*$SETGLOBAL TIMESfolder Gams_WrkTI-PAMS
$SETGLOBAL TIMESfolder Gams_WrkTI-IFPRI
$SETGLOBAL gdxfolder %workingfolder%SATM\%TIMESfolder%\Gamssave\
* Subset of TIMES GDX output folder
$SETGLOBAL GDXoutfolder %workingfolder%GDXout\
$SETGLOBAL GDXoutfolder2 %workingfolder%GDXCGEout\
*$SETGLOBAL referencerun REFU-BU2
$SETGLOBAL referencerun CIPP_REF0_5Y
*$SETGLOBAL referencerun PAMS_BFUEL
$SETGLOBAL outputworkbook outputworkbook_v08.xlsx

*-------------------------------------------------------------------------------

*2.Defining sets and parameters used in Batch file------------------------------
SETS
* Overall sets
  RUN                            simulations
*/1*5/
  TIMESCASE                      simulation TIMES run
  MRUNCASE(RUN,TIMESCASE)        Mapping RUN to TIMES CASE
* SATIM sets
  REG                            TIMES regions    /REGION1/
  ALLYEAR                        All Years
  T(ALLYEAR)                     Time periods
  V(ALLYEAR)                     Vintage
  NMY1(ALLYEAR)                  All milestone years except for the first year (demand)
  S                              TIMES timeslices
  PRC                            TIMES Processes
  P(PRC)                         Processes
  COM                            TIMES Commodities
  COM_GRP                        Demand item groupings in TIMES
  DEM                            TIMES Demand Commodities
  DEM1(COM)                      TIMES Demand Commodities for REGION1
  ITEM                           Everything
  XPWR(PRC)                      power sector fuels
  TTCH(PRC)                      SATIM technology options
  TOUT                           SATIM fuel types

* Fuel processes
  FUELP(PRC)                     TIMES Fuel Processes
  FUELPC(PRC)                    TIMES coal processes
  FUELPCPWR(PRC)                 TIMES coal for power
  FUELPCPWR_CB(PRC)              TIMES coal for power central basin
  FUELPCPWR_A(PRC)               TIMES coal for power waterberg
  FUELPG(PRC)                    TIMES gas processes
  FUELPO(PRC)                    TIMES oil liquid fuel processes

* Power Plant processes
  TECHS                          TIMES power plant subsets
  TECHN(P)                       New TIMES power plant subset for LCOE
  TECHC(PRC)                     TIMES power plants whose cost are MC simulated
  TECHP(PRC)                     TIMES power plants whose contribution to peak are MC simulated
  ETC(PRC)                       TIMES Coal Plants
  ETCA(PRC)                      TIMES Coal Plants waterberg
  ETG(PRC)                       TIMES Gas Plants
  ETGIH(PRC)                     TIMES Gas Plants Shale
  ETN(PRC)                       TIMES Nuclear Plants
  ERH(PRC)                       TIMES Hydro Plants
  ERSOLP(PRC)                    TIMES PV techs Central
  ERSOLPC(PRC)                   TIMES PV techs Central
  ERSOLPR(PRC)                   TIMES PV techs Rooftop
  ERSOLT(PRC)                    TIMES CSP techs
  ERW(PRC)                       TIMES Wind Plants
  ERB(PRC)                       TIMES Biomass Plants
  FS                             TIMES economic sectors

* Emissions sets
  CO2SET(COM)                    Sectoral emissions

* MC sim specific sets
  FS_L(FS)                       Linked subsectors ie excl com agr ele
  COEF                           Oil Price coefficient / a, b/

* Results
  mFuels                         Map for Fuels set
  mFuels2                        Map for Fuels set more details
  mExt                           Map for Externalities set
  mRoadFreight                   Map for demands and techs for road freight
  mRoadPassenger                 Map for demands and techs for road passenger

* Groups
* PRC groups

* COM Groups
  Fuels                          Fuels
  Fuels2                         Fuels more details
  Externalities                  Externalities
  FuelPrices(COM)                Fuels whose prices are kept
  UXLE_AB(P)                     Waterberg to CB processes
  PassengerRoad(COM)             Passenger Road for tracking occupency and pkm from vehkm data
  PassengerModes(COM)            Passenger transport modes
  FreightRoad(COM)               Freight Road for tracking load and pkm from vehkm data
  FreightModes(COM)              Freight transport modes

* Regulated Commodity Price Sets
  MINCLPWR(PRC)                  Coal mines dedicated to power sector
  MINCLDUAL(PRC)                 Coal mines dual production
  MINCLDUAL_A(PRC)               Coal mines dual production-Waterberg
  MFUELPWR(PRC,COM)              Mapping of fuels and techs
  SUPGIC(PRC)                    Coastal gas supply technologies
  PamsSector                     PAMS sectors

* Other
  XXX                            Needed for obj    / CUR, LEVCOST, INV /
;

ALIAS (ALLYEAR,AY), (ALLYEAR,AYP);

Sets
  MILESTONYR(ALLYEAR)            TIMES Milestone years


* sets used in interpolation function (for linked model)
  DATAYEAR(AY)                   Years for which user data is provided
  DM_YEAR(AY)                    TIMES Demand Milestones
  RTP(REG,AY,PRC)                Technology valid years
  UNCD7(*,*,*,*,*,*,*)           Non-domain-controlled set of 7-tuples
;

PARAMETERS
*Overall Parameters
  XRATE(RUN,AY)                  Real Exchange Rate R per $

* Parameters imported from a base CGE run

* Parameters imported from a base TIMES run
* From TIMES
  F_IN(REG,AY,AY,PRC,COM,S)      Flow parameter (level of flow variable) [PJ]
  F_OUT(REG,AY,AY,PRC,COM,S)     Flow parameter (level of flow variable)[PJ]
  VARACT(REG,AY,PRC)             Activity level [PJ except for demand techs where unit will be aligned to particular demand e.g. VKM for road vehicles]
  PRC_CAPACT(REG,PRC)            Factor going from capacity to activity
  PRC_RESID(REG,AY,PRC)          Existing Capacity
  PAR_CAPL(REG,AY,PRC)           Capacity excluding existing capacity
  PAR_NCAPL(REG,AY,PRC)          New Capacity
  PAR_COMBALEM(REG,AY,COM,S)     Commodity marginal
  PAR_NCAPR(REG,AY,P,ITEM)       Levelised Cost
  NCAP_ILED(REG,AY,PRC)          TIMES lead time
  CST_INVC(REG,V,AY,PRC,XXX)     TIMES calculated annual investment costs
  CST_ACTC(REG,V,AY,PRC)         TIMES calculated annual activity costs
  CST_FIXC(REG,V,AY,PRC)         TIMES calculated annual fixed costs

  OB_ICOST(REG,PRC,XXX,AY)       Interpolated investment cost from TIMES run
  OBICOST(REG,AY,PRC)            TIMES investment cost restructured for interpolation

* Monte Carlo Simulation parameters drawn in from Excel
* Main Drivers
  SIM_GDP_Y(RUN,AY)              GDP growth
  SIM_COM_S(RUN,AY)              Share of commerce in GDP
  SIM_POP(RUN,AY)                Population

* Data from Demand Model (spreadsheet-based at this stage)
  SIM_DEMX(COM,AY)               Demand extracted from excel

* Fuel Price Combined Data
  SIM_FUELP(PRC,RUN,AY)          Combined Fuel Price data

* Technology Cost Combined Data
  SIM_TECHC(PRC,RUN,AY)          Combined Tech overnight Cost data

* Coal Mining Costs
  COAL_CV(PRC)                   Coal calorific value
* Coal to Power Plants Central Basin
  SIM_CLE1(RUN,AY)               Coal from Existing Mines in Central Basin Type 1 (conveyor)
  SIM_CLE2(RUN,AY)               Coal from Existing Mines in Central Basin Type 2 (rail-truck)
  SIM_CLN(RUN,AY)                Coal from New Mines in Central Basin

* Coal to Power Plants in Waterberg
  SIM_CLE_A(RUN,AY)              Coal from Existing Mines in Waterberg
  SIM_CLN_A(RUN,AY)              Coal from new Mines in Waterberg
  SIM_CLNU_A(RUN,AY)             Coal from new Mines in Waterberg - underground mines

* Coal to Synthetic Fuels
  SIM_CLS(RUN,AY)                Coal from Existing Mines in Central Basin to synthetic fuels
  SIM_CLS_A(RUN,AY)              Coal from New Mines in the Waterberg to synthetic fuels

* Metallurgical Coal existing
  SIM_COA(RUN,AY)                Coal from Existing Mines supplying other industries

* Global Commodity Prices
  SIM_GCOAL(RUN,AY)              Global Price for Coal in 2015 $ per ton
  SIM_GGAS(RUN,AY)               Global Price for Gas in 2015 $ per Mbtu
  SIM_GOIL(RUN,AY)               Global Price for Oil in 2015 $ per barrel

* Oil products
  OCRFAC(FUELPO,COEF)            Coefficients for mapping from oil to product prices

* Natural Gas
  SIM_GIH(RUN,AY)                Shale Gas Production Cost $ per Mbtu

* Solar PV
  SIM_PV_Module(RUN,AY)          PV Module Prices in 2015 $ per W
  SIM_PV_BOS(RUN,AY)             PV Balance of System Cost in 2010 $ per W
  PV_CRATIO(PRC)                 Ratio of BOS cost for other PV systems to Central Fixed system

* Solar CSP
  SIM_CSP(RUN,AY)                CSP Cost in 2015 $ per W
  CSP_CRATIO(PRC)                Ratio of reference CSP cost to other CSP techs

* Nuclear Costs
  SIM_NUCLEAR(RUN,AY)            Overnight Nuclear Cost $ per kW

* Other Nuclear Parameters
  SIM_NUCLEARCF(RUN)             Nuclear Capacity Factor
  SIM_NUCLEARLT(RUN)             Nuclear Lead Time

* Other Uncertain Parameters
  SIM_HYDIMP(RUN)                Hydro Import capacity
  SIM_SOLTPKNT(RUN)              Contribution to peak of solar Thermal techs

  SIM_TRAMOD(RUN)                Transport mode scenario - currently just set to 0 or 1 with the intention of making this a scaling factor later
  SIM_CO2CUMUL(RUN)              Cumulative CO2 Constraint
* Intermediate parameters

  GDP(RUN,AY)                    Overall GDP
  GDP_FS(FS,RUN,AY)              Sector GDP
  GDP_FSX(FS,AY)                 Sector GDP for simulation X
  GDP_FS_S(FS,RUN,AY)            Sector GDP shares
  GDP_FS_L(FS)                   Base year shares of non agr and com sectors

  POP_X(AY)                      Population for simulation X

*FH
  PAMS(PAMSSECTOR)               Active PAMS

  SIM_ERSOLP(RUN,ERSOLP,AY)      PV costs going to SATIM
  SIM_ERSOLT(RUN,ERSOLT,AY)      CSP costs going to SATIM

  SIM_FUELPX(FUELP,AY)           Fuel prices for a particular run
  SIM_TECHCX(TECHC,AY)           Tech costs for a particular run
  SIM_NUCLEARCFX                 Nuclear CF for a particular run
  SIM_NUCLEARLTX                 Nuclear Lead time for a particular run
  SIM_SOLTPKNTX                  Solar thermal capacity credit for a particular run
  SIM_HYDIMPX                    Hydro import capacity for a particular run

* TIMES Results Initial Aggregation
  VAR_ACT(ALLYEAR,PRC)           Activity [PJ except for demand techs where unit will be aligned to particular demand e.g. VKM for road vehicles]
  CAPACT(PRC)                    Capacity to activity

  FLO_IN(ALLYEAR,PRC,COM)        Aggregated level of process commodity flow in
  FLO_OUT(ALLYEAR,PRC,COM)       Aggregated level of process commodity flow out

  FLO_IN_S(ALLYEAR,PRC,COM,S,RUN) aggregated level of process commodity flow in with timeslice detail
  FLO_OUT_S(ALLYEAR,PRC,COM,S,RUN) aggregated level of process commodity flow out with timeslice detail

  CAP(ALLYEAR,PRC)               Process capacity
  NCAP(ALLYEAR,PRC)              New Process capacity
  SCAP(ALLYEAR,PRC)              Scaled Capacity by CAPACT

  COMBALEM(ALLYEAR,FuelPrices,RUN) aggregate marginals [2015 R per GJ]
  T_COMBALEM(REG,AY,COM)         Commodity marginals from TIMES-SATIM

  CST_INV(ALLYEAR,PRC)           Annual investment costs
  CST_ACT(ALLYEAR,PRC)           Annual activity costs
  CST_FIX(ALLYEAR,PRC)           Annual fixed costs

* Commodity Levels
  COMBAL(ALLYEAR,C,RUN)          Commodity level
  COMBALExt(ALLYEAR,Externalities,RUN) Emissions level
  FuelCOMBAL(ALLYEAR,C,RUN)      Fuels marginals

* Coal specific activities
  VARACTC(ALLYEAR,PRC,RUN)       Coal production from all coal mines
  VARACTUXLE_AB(ALLYEAR,RUN)     Tranfer of coal from WB to CB
  AvgCoalPriceCB(ALLYEAR,RUN)    Average coal price for power in CB
  AvgCoalPriceA(ALLYEAR,RUN)     Average coal price for power in WB

* Flow_out Externalities
  COUTPXSums(ALLYEAR,COM,RUN)    Externalities sums [kton]
  COUTPExtSums(ALLYEAR,Externalities,RUN) Check sum [kton]
  COUTPExtCumulSums(Externalities,RUN) Cumulative sum [kton]

*  Costs
* Regulated Commodity price calc
* Elc price calc parameters
  TCST_ELE(RUN,AY)               Power plant costs excluding fuel
  TCST_PWRCL(AY)                 Dedicated mines costs
  TCST_PWRDUAL(AY)               Dual mines costs central basin
  TCST_PWRDUAL_A(AY)             Dual mines costs waterberg
  TCST_PWRCLT(RUN,AY)            Total coal costs to power sector
  TCST_PWROTH(RUN,AY)            Other fuel costs to power sector

* Other useful results
  PKDEM(ALLYEAR,RUN)             Peak demand on electricity grid
  PassengerOccupancy(T,COM,RUN)  Occupancy of passenger road transport
  Passengerkm(COM,ALLYEAR)       Pkm for passenger transport
  PassengerkmALL(T,P,RUN)        Pkm for passenger logged for each RUN
  FreightLoad(T,COM,RUN)         Average load per mode
  Tonkm(COM,ALLYEAR)             Tonkm for Freight transport
  TonkmALL(T,P,RUN)              Tonkm for Freight transport logged for each RUN

* Other Parameters
* Interpolation parameters - using function developed for TIMES
  DFUNC                          ???
  MY_FIL2(ALLYEAR)               ???
  MY_ARRAY(ALLYEAR)              ???
  LAST_VAL                       ???
  FIRST_VAL
  FINT                           first value?
  Z                              last value?
  MY_F                           ???
  YEARVALT(ALLYEAR)              value of each year for CGE years
  MY_FYEAR                       last year of TIMES model
  B(ALLYEAR)                     begining of period
  E(ALLYEAR)                     end of period
  TGAP(ALLYEAR)                  period lengths
  MYGAP(ALLYEAR)                 period lengths
  POBjz(RUN)                     Objective function
  REG_OBJ(REG)                   Objective function from TIMES

* Set Allocation
  AvgCoalPrice(ALLYEAR,RUN)      Average Marginal for power plant coal
  TotalFinal(ALLYEAR,RUN)
  CoalFinal(ALLYEAR,RUN)
  CoalShareFinal(ALLYEAR,RUN)
  GasFinal(ALLYEAR,RUN)
  GasShareFinal(ALLYEAR,RUN)
  FossilShareFinal(ALLYEAR,RUN)

  INCLRUN(RUN)                   whether to include or not RUN in batch run
  SIM_CGE(RUN)                   whether to run linked model or not
  Test_SIM_CGE                   to check if there are any runs that require linked model
  SIM_CO2PRICE(RUN,AY)           CO2 PRICE
  SIM_PAMS(RUN,PamsSector)       activated pams for each run
  ERPRICE(AY,RUN)                regulated electricity price
  GDP_SIMPLE(FS,AY,RUN)          GDP for shorter runs
;
*-------------------------------------------------------------------------------

*3 File declarations------------------------------------------------------------
*INCLUDE NOTES!!!What are these files for?
 FILE SIM_COMCOST_FILE /".\satm\%TIMESfolder%\sim_comprice+REGION1.dds"/;
 FILE SIM_PRCCOST_FILE /".\satm\%TIMESfolder%\sim_prccost+REGION1.dds"/;
 FILE SIM_DEM_FILE /".\satm\%TIMESfolder%\sim_dem+REGION1.dds"/;
 FILE SIM_OTHPAR_FILE /".\satm\%TIMESfolder%\sim_othpar+REGION1.dds"/;
 FILE RUNTIMES2 /".\satm\%TIMESfolder%\RUNTIMES2.CMD"/;
 FILE ShowRunNumber /".\satm\%TIMESfolder%\ShowRunNumber.CMD"/;
 FILE SATIM_Scen;
 FILE CGE_Scen;
 FILE RProcessGDX /".\RProcessGDX.CMD"/;
*-------------------------------------------------------------------------------

*4 Import sets and parameters from Base TIMES run-------------------------------
$gdxin  %GDXfolder%%referencerun%.gdx
$load PRC P COM DEM ALLYEAR S V ITEM OB_ICOST
$load DATAYEAR DM_YEAR MILESTONYR RTP B E
$load MY_FYEAR MY_FIL2

*uncomment below to update spreadsheet, if PRCs and COMs have changed in the TIMES model
*execute_unload "SATMR.gdx" PRC COM
*execute 'gdxxrw.exe i=SATMR.gdx o=.\links\0forecast.xlsx index=index_G2E!a6';
*$exit




Alias (MILESTONYR,MY), (P,PP); ;

 YEARVALT(ALLYEAR) = 1849+ORD(ALLYEAR);
 TGAP(MILESTONYR) = E(MILESTONYR) - B(MILESTONYR)+1;

* Base year demand not needed if demand workbook is linked and up to date
 DEM1(COM) = DEM('REGION1',COM);
*-------------------------------------------------------------------------------

*5 Import MC parameters and data from spreadsheet-------------------------------
$call   "gdxxrw i=MCSim.xlsm o=mcsim index=index!a6 checkdate"
$gdxin  mcsim.gdx
$loaddc RUN FUELP FUELPO FUELPC FUELPCPWR FUELPCPWR_CB FUELPCPWR_A FUELPG TECHS TECHN TECHC TECHP ETC ETCA ETG ETGIH ETN ERH ERSOLP ERSOLPC ERSOLPR ERSOLT ERW ERB CO2SET FS FuelPrices UXLE_AB TIMESCASE INCLRUN
$load MRUNCASE PamsSector GDP_FS_L SIM_POP SIM_GDP_Y SIM_COM_S SIM_GCOAL SIM_GGAS SIM_GOIL OCRFAC COAL_CV SIM_CLE1 SIM_CLE2 SIM_CLN SIM_CLE_A SIM_CLN_A SIM_CLNU_A SIM_GIH PV_CRATIO SIM_PV_MODULE SIM_PV_BOS CSP_CRATIO
$load SIM_CSP SIM_NUCLEAR SIM_NUCLEARCF SIM_NUCLEARLT SIM_HYDIMP SIM_SOLTPKNT SIM_TRAMOD SIM_CO2CUMUL SIM_CGE SIM_CO2PRICE SIM_PAMS
*-------------------------------------------------------------------------------

*6 Assign exchange rate value---------------------------------------------------
*Exchange rate for Jan 2015 based on IRP 2016
 XRATE(RUN,AY)=11.55;
*-------------------------------------------------------------------------------

*7 CGE: Parameter and set declaration-------------------------------------------
$batinclude cge\includes\2simulation.inc 1
$batinclude cge\includes\3report_init.inc
*fh
$batinclude cge\includes\SATIMViz_init.inc
*-------------------------------------------------------------------------------

*8 Linking SATIM and CGE sub-sectors--------------------------------------------
* Preparation of cge input data
  FS_L(FS) = YES;
  FS_L('agr') = no;
  FS_L('com') = no;

*Count gap between TIMES years
 Sets
 MYA(ALLYEAR)            TIMES years /2012*2050/
 MY1(ALLYEAR)            First TIMES year
 ;

 MY1(MY)$(ORD(MY) EQ 1) = YES;
 NMY1(AY) = MY(AY);
 NMY1('2012') = No;

* Set inital and following years' shares equal to shares in cge run
* Calculate GDP shares for all simulations
 GDP(RUN,'2012') = 1;

 Loop(MYA$(NOT MY1(MYA)),
     GDP(RUN,MYA) = GDP(RUN,MYA-1)*((1+SIM_GDP_Y(RUN,MYA)));
     );

* set gdp shares
* agriculture set to 2.4% constant
 GDP_FS_S('agr',RUN,MY)  = 0.024;
* set 'com' shares equal to that of sim
 GDP_FS_S('com',RUN,MY)  = SIM_COM_S(RUN,MY);

 GDP_FS_S(FS_L,RUN,MY)   = (1-GDP_FS_S('agr',RUN,MY)-GDP_FS_S('com',RUN,MY))*GDP_FS_L(FS_L);

* calculate sector GDP
 GDP_FS(FS,RUN,MY)       = GDP_FS_S(FS,RUN,MY)*GDP(RUN,MY);

*-------------------------------------------------------------------------------

*9 Set Fuel Prices/Costs--------------------------------------------------------
* Coal mining/exports (x/0.8+35 is washing costs and yield effect - 35 comes
*from the 40 in Eskom slides adjusted for inflation)
* 0.95 on exports assumes a 5% royalty
 SIM_FUELP('MINCLE1',RUN,MY)  = SIM_CLE1(RUN,MY);
 SIM_FUELP('MINCLE2',RUN,MY)  = SIM_CLE2(RUN,MY);
 SIM_FUELP('MINCLE3',RUN,MY)  = SIM_CLE2(RUN,MY)/0.8+35;
 SIM_FUELP('MINCLN',RUN,MY)   = SIM_CLN(RUN,MY);
 SIM_FUELP('MINCLE-A',RUN,MY) = SIM_CLE_A(RUN,MY);
 SIM_FUELP('MINCLN-A',RUN,MY) = SIM_CLN_A(RUN,MY);
 SIM_FUELP('MINCLNU-A',RUN,MY)= SIM_CLNU_A(RUN,MY);
 SIM_FUELP('MINCLS',RUN,MY)   = SIM_CLE1(RUN,MY);
 SIM_FUELP('MINCLS-A',RUN,MY) = SIM_CLN_A(RUN,MY);
 SIM_FUELP('MINCOA',RUN,MY)   = SIM_FUELP('MINCLE3',RUN,MY)/0.8+35;

* Exports
 SIM_FUELP('PEXCME',RUN,MY)   = SIM_GCOAL(RUN,MY)* 0.95 * XRATE(RUN,MY) * (-1);

* Convert coal prices from 2013 R/ton to 2015 R/GJ (used to be 1.172 for 2010)
 SIM_FUELP(FUELPC,RUN,MY)     = SIM_FUELP(FUELPC,RUN,MY)/COAL_CV(FUELPC) / 1.172*1.309;

* Oil and derivatives prices
 SIM_FUELP(FUELPO,RUN,MY)     = SIM_GOIL(RUN,MY) * XRATE(RUN,MY) * OCRFAC(FUELPO,'a') + OCRFAC(FUELPO,'b');

* Natural Gas Techs, +1, +0.5 for GWL and GRL are the transport costs
* the 0.95 for the export price is a royalty fee
* shale: converting from 2012 $ to 2015 $ - 1.039
 SIM_FUELP('MINGIH',RUN,MY)   = SIM_GIH(RUN,MY) * XRATE(RUN,MY)*1.05 / 1.055;
 SIM_FUELP('IMPGWL',RUN,MY)   = (SIM_GGAS(RUN,MY)+1) * XRATE(RUN,MY) / 1.055;
 SIM_FUELP('IMPGRL',RUN,MY)   = (SIM_GGAS(RUN,MY)+0.5) * XRATE(RUN,MY) / 1.055;
 SIM_FUELP('PEXGAS',RUN,MY)   = SIM_GGAS(RUN,MY)*0.95 * XRATE(RUN,MY) / 1.055 * (-1);

* Calculate Solar costs based on 2010 ratios and smpled data, assuming ratios stay the same
* and converting to R/kW as needed by SATIM
 SIM_TECHC(ERSOLP,RUN,MY)     = (PV_CRATIO(ERSOLP) * SIM_PV_BOS(RUN,MY) + SIM_PV_MODULE(RUN,MY)) * 1000 * XRATE(RUN,MY);
 SIM_TECHC(ERSOLT,RUN,MY)     = CSP_CRATIO(ERSOLT) * SIM_CSP(RUN,MY) * 1000 * XRATE(RUN,MY);

* * .93956 because it's a fleet rather than a single unit, * 1.1 to add the ODC costs
 SIM_TECHC(ETN,RUN,MY) = SIM_NUCLEAR(RUN,MY) * XRATE(RUN,MY)*0.93956*1.1;
*-------------------------------------------------------------------------------

*10 Preparation for stored output-----------------------------------------------
$call    "gdxxrw i=%outputworkbook% o=SATMR2 index=index_E2G!a6 checkdate"
$gdxin   SATMR2.gdx
$loaddc Fuels Fuels2 Externalities PassengerRoad PassengerModes FreightRoad FreightModes
$load mFuels mFuels2 mExt MFUELPWR

 Scalars
 EFVAL                 temporary values stored here
 XLTEST
 TRAMOD                transport mode parameter
;
*-------------------------------------------------------------------------------

*11 Loop: Model solve-----------------------------------------------------------
LOOP(RUN$INCLRUN(RUN),
* Fuel Price DDS file
 PUT  SIM_COMCOST_FILE;
 SIM_COMCOST_FILE.pc = 2;
 SIM_COMCOST_FILE.nd = 5;
 SIM_COMCOST_FILE.ap = 0;

 PUT 'PARAMETER AACT_COST /' /;

 LOOP((FUELP,MY),
  EFVAL = SIM_FUELP(FUELP,RUN,MY);
  if(EFVAL,
 PUT "REGION1.", FUELP.TL, ".", MY.TL, EFVAL /;
  );
);
 PUTCLOSE "/;";

* Tech Cost DDS File
 PUT  SIM_PRCCOST_FILE;
 SIM_PRCCOST_FILE.pc = 2;
 SIM_PRCCOST_FILE.nd = 5;
 SIM_PRCCOST_FILE.ap = 0;

 PUT 'PARAMETER ANCAP_COST /' /;

LOOP((TECHC,MY),
  EFVAL = SIM_TECHC(TECHC,RUN,MY);
  if(EFVAL,
    PUT "REGION1.", TECHC.TL, ".", MY.TL, EFVAL /;
  );
);
 PUTCLOSE "/;";

 PUT  SIM_OTHPAR_FILE;
 SIM_PRCCOST_FILE.pc = 2;
 SIM_PRCCOST_FILE.nd = 5;
 SIM_PRCCOST_FILE.ap = 0;

 PUT 'PARAMETER ANCAP_AFA /' /;
  EFVAL = SIM_NUCLEARCF(RUN);
  if(EFVAL,
    PUT "REGION1.ETNUC-N.'UP'.2012", EFVAL /;
  );
 PUT "/;"/;

 PUT 'PARAMETER ANCAP_ILED /' /;
  EFVAL = SIM_NUCLEARLT(RUN)*(-1);
  if(EFVAL,
    PUT "REGION1.ETNUC-N.2012", EFVAL /;
  );
 PUT "/;"/;

 PUT 'PARAMETER ANCAPPKCNT /' /;
  EFVAL = SIM_SOLTPKNT(RUN);

LOOP(TECHP,
  if(EFVAL,
    PUT "REGION1.", TECHP.TL, ".'ANNUAL'.2012", EFVAL /;
  );
 );
 PUT "/;"/;

 PUT 'PARAMETER AUC_RHSRT /' /;
  EFVAL = SIM_HYDIMP(RUN);
  if(EFVAL,
    PUT "REGION1.UCCAP-IMPHYD.'UP'.2012", EFVAL /;
  );
 PUT "/;"/;

 PUT 'PARAMETER ACOMCUMNET /' /;
  EFVAL = SIM_CO2CUMUL(RUN)*1000000;
  if(EFVAL,
    PUT "REGION1.CO2EQS.2020.2050.'UP'  ", EFVAL /;
  );

$ontext
 PUT "/;"/;

 PUT 'PARAMETER ACOMCSTNET /' /;
Loop(MY,
  EFVAL = SIM_CO2PRICE(RUN,MY)/1000;
  if(EFVAL,
    PUT "REGION1.CO2S.'ANNUAL'.", MY.TL, EFVAL /;
  );
);
$offtext

PUTCLOSE "/;";

*FH: Included PAMS link
 PAMS(PAMSSECTOR) =  SIM_PAMS(RUN,PAMSSECTOR);

if(SIM_CGE(RUN) eq 1,
$batinclude cge\includes\2simulation_loop.inc
$batinclude cge\includes\3report_loop.inc
*TC uncommentted
ERPRICE(TC,RUN) = EPRICE(TC,'2050');
GDP_SIMPLE(FS,TC,RUN) = SFORE(FS,'base',TC);

*FH: include electricity price and investment profile *TC
$batinclude cge\includes\SATIMViz_loop.inc
;

ELSE

* Calculate Sectoral GDP

  GDP_FSX(FS,MY) = GDP_FS(FS,RUN,MY);
  POPSX(MY) = SIM_POP(RUN,MY);
  TRAMOD = SIM_TRAMOD(RUN);

*  execute_unload "MCDem.gdx" POPSX GDP_FSX TRAMOD;
*  execute 'gdxxrw.exe i=MCDem.gdx o=.\SATM\DMD_PRJ.xlsx index=index_G2E!a6';
    execute_unload "MCDem.gdx" PAMS
    execute 'gdxxrw.exe i=MCDem.gdx o=SATM\DMD_PRJ.xlsx index=index_G2E!a6';

  execute 'gdxxrw.exe i=.\SATM\DMD_PRJ.xlsx o=mcdem2.gdx index=index_E2G!a6 checkdate';
  execute_load "mcdem2.gdx" SIM_DEMX Passengerkm Tonkm;

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

  PUT  ShowRunNumber;
  RUNTIMES2.pc = 2;
  RUNTIMES2.nd = 5;
  RUNTIMES2.ap = 0;
  PUTCLOSE "";

* Write executable for running SATIM with specified path and run-name

* Run TIMES model
*  execute ".\satm\gams_wrkti-PAMS\ShowRunNumber.CMD"
*  execute ".\satm\gams_wrkti-PAMS\RUNTIMES2.CMD"
*);
*);
*$exit

TT1(TT)$(ORD(TT) EQ 1) = YES;

loop(XC,
loop(TT$TT1(TT),
$include cge\includes\2runTIMES.inc
ERPRICE(TC,RUN) = ETPRICE(TC)/1000;
*ELECINVCOST(TC,RUN) = EINVCOST(XC,TC,TT);
);
);




);
*end of If statement
$ontext
* this (below) now runs inside 2runTIMES
* Extract Results from TIMES run
  loop(MRUNCASE(RUN,TIMESCASE), put_utilities SATIM_Scen 'gdxin' / "%GDXfolder%",TIMESCASE.TL:20);
  execute_load F_IN F_OUT VARACT PRC_CAPACT PRC_RESID PAR_CAPL PAR_NCAPL PAR_COMBALEM PAR_NCAPR REG_OBJ CST_INVC CST_ACTC CST_FIXC;

  SIM_FUELPX(FUELP,MY)   = SIM_FUELP(FUELP,RUN,MY);
  SIM_TECHCX(TECHC,MY)   = SIM_TECHC(TECHC,RUN,MY);
  SIM_NUCLEARCFX         = SIM_NUCLEARCF(RUN);
  SIM_NUCLEARLTX         = SIM_NUCLEARLT(RUN);
  SIM_SOLTPKNTX          = SIM_SOLTPKNT(RUN);
  SIM_HYDIMPX            = SIM_HYDIMP(RUN);

  put_utilities SATIM_Scen 'gdxout' / "%GDXoutfolder%",RUN.TL:20;
*inputs
  execute_unload MRUNCASE Passengerkm Tonkm GDP_FSX POPSX SIM_DEMX SIM_FUELPX SIM_TECHCX SIM_NUCLEARCFX SIM_NUCLEARLTX SIM_SOLTPKNTX SIM_HYDIMPX F_IN F_OUT VARACT PRC_CAPACT PRC_RESID PAR_CAPL PAR_NCAPL PAR_COMBALEM PAR_NCAPR REG_OBJ CST_INVC CST_ACTC CST_FIXC ERPRICE INVCOST;
$offtext

);
*end RUN loop
*-------------------------------------------------------------------------------

*12 Post-processing: Results loop-----------------------------------------------
LOOP(RUN$INCLRUN(RUN),
  PUT RProcessGDX;
  RProcessGDX.pc = 2;
  RProcessGDX.nd = 5;
  RProcessGDX.ap = 0;
  PUT "RScript %Rworkingfolder%satimviz/processing/processGDXs_gams.R ", RUN.TL:40;
  PUTCLOSE "";
  execute "%workingfolder%RProcessGDX.CMD"
);
*-------------------------------------------------------------------------------

*END OF BATCHRUN FILE
*$offtext
