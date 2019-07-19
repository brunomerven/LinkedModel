*=============================================================================*
* INITMTY.MOD has all the EMPTY declarations for system & user data           *
* %1..%6 - File extensions of code extensions to be included                  *
*=============================================================================*
*=============================================================================*
* All the EMPTY declarations for user data                                    *
*=============================================================================*
*GaG Questions/Comments:
*   - all but LOCAL (in single BATINCLUDE and its immediate lower routines)
*   - consider changes PRC_MAP(PRC_GRP,PRC_SUBGRP,PRC) where PRC_SUBGRP =
*     PRC_RSOURC + any other user provided sub-groupings
*   - SOW/COM/PRC/CUR master sets (merged) == entire list, that is not REG
*   - lists (eg, DEM_SECT) for _MAP sets not REG (but individual mappings are)
*   - HAVE THE USER *.SET/DD files OMIT the declarations to ease maintenance changes
*-----------------------------------------------------------------------------
* Version control
$IF NOT FUNTYPE IfThen $ABORT TIMES Version 3.1.1 and above Requires GAMS 21.3 or above!
$IF FUNTYPE gamsversion
$IF gamsversion 149 $SETGLOBAL G226 YES
$IF %G226%==YES
$IF gamsversion 230 $SETGLOBAL OBMAC YES

*-----------------------------------------------------------------------------
* SET SECTION
*-----------------------------------------------------------------------------
* Note: the *-out user SETs are declared in INITSYS.MOD

* commodities
*  SET COM_GRP                       'All CGs and each individal commodity';
*  SET COM(COM_GRP)                  'All Commodities'                      / EMPTY /;
  SET COM_DESC(REG,COM)              'Region-based commodity descriptions'  / EMPTY.EMPTY /;
*  SET COM_TYPE(COM_GRP)             'Primary grouping of commodities'      / EMPTY /;
  SET COM_GMAP(REG,COM_GRP,COM)      'User groups of individual commodities' / EMPTY.EMPTY.EMPTY /;
  SET COM_LIM(REG,COM,LIM)           'List of equation type for balance'    / EMPTY.EMPTY.EMPTY /;
  SET COM_OFF(REG,COM,*,*)           'Periods for which a commodity is unavailable' / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET COM_TMAP(REG,COM_TYPE,COM)     'Primary grouping of commodities'      / EMPTY.EMPTY.EMPTY /;
  SET COM_TS(REG,COM,ALL_TS)         'List of commodity timeslices'         / EMPTY.EMPTY.EMPTY /;
  SET COM_TSL(REG,COM,TSLVL)         'Level at which a commodity tracked'   / EMPTY.EMPTY.EMPTY /;
  SET COM_UNIT(REG,COM,UNITS_COM)    'Units associated with each commodity' / EMPTY.EMPTY.EMPTY /;

* currency
*  SET CUR                           'Currencies (c$)'            / EMPTY /;
  SET CUR_MAP(REG,CUR_GRP,CUR)       'Grouping of the currenies'  / EMPTY.EMPTY.EMPTY /;

* demands
  SET DEM_SMAP(REG,DEM_SECT,COM)     'Grouping of DMs (commodities) to their sector' / EMPTY.EMPTY.EMPTY /;

* emissions
  SET ENV_MAP(REG,ENV_GRP,COM)       'Grouping of ENVs (commodities) to their emissions group' / EMPTY.EMPTY.EMPTY /;

* financial flows
  SET FIN_MAP(REG,FIN_GRP,COM)       'Grouping of FINs (commodities) to their financial group' / EMPTY.EMPTY.EMPTY /;

* materials
  SET MAT_GMAP(REG,MAT_GRP,COM)      'Grouping of materials'             / EMPTY.EMPTY.EMPTY /;
  SET MAT_TMAP(REG,MAT_TYPE,COM)     'Material by type'                  / EMPTY.EMPTY.EMPTY /;
  SET MAT_VOL(REG,COM)               'Material accounted for by volume'  / EMPTY.EMPTY /;
  SET MAT_WT(REG,COM)                'Material accounted for by weight'  / EMPTY.EMPTY /;

* energy
  SET NRG_FMAP(REG,NRG_FORM,COM)     'Grouping of NRG by Solid/Liquid/Gas' / EMPTY.EMPTY.EMPTY /;
  SET NRG_GMAP(REG,NRG_GRID,COM)     'Association with energy carriers to grids' / EMPTY.EMPTY.EMPTY /;
  SET NRG_TMAP(REG,NRG_TYPE,COM)     'Grouping of energy carriers by type' / EMPTY.EMPTY.EMPTY /;

* process
  SET PRC                              'List of all processes'           / EMPTY /;
  SET PRC_AOFF(REG,PRC,*,*)            'Periods for which activity is unavailable'  / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET PRC_ACTUNT(REG,PRC,COM_GRP,UNITS_ACT)  'Primary commodity (or group) & activity unit'  / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET PRC_CAPUNT(REG,PRC,COM_GRP,UNITS_CAP)  'Unit of capacity'          / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET PRC_CG(R,PRC,COM_GRP)            'Commodity groups for a process'  / EMPTY.EMPTY.EMPTY /;
  SET PRC_DESC(R,P)                    'Process descriptions by region'  / EMPTY.EMPTY /;
  SET PRC_FOFF(REG,PRC,COM,ALL_TS,*,*) 'Periods/timeslices for which flow is not possible' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;
  SET PRC_MAP(REG,PRC_GRP,PRC)         'Grouping of processes to nature' / EMPTY.EMPTY.EMPTY /;
  SET PRC_NOFF(REG,PRC,*,*)            'Periods for which new capacity can NOT be built' / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET PRC_RMAP(REG,PRC_RSOURC,PRC)     'Grouping of XTRACT processes'    / EMPTY.EMPTY.EMPTY /;
  SET PRC_SPG(REG,PRC,COM_GRP)         'Shadow Primary Group'            / EMPTY.EMPTY.EMPTY /;
  SET PRC_TS(ALL_REG,PRC,ALL_TS)       'Timeslices for a process'        / EMPTY.EMPTY.EMPTY /;
  SET PRC_TSL(REG,PRC,TSLVL)           'Timeslice level for a process'   / EMPTY.EMPTY.EMPTY /;
  SET PRC_VINT(REG,PRC)                'Process is to be vintaged'       / EMPTY.EMPTY /;
  SET PRC_RCAP(REG,PRC)                'Process with early retirement';
  SET PRC_SIMV(REG,PRC)                'Process is to be vintage-simulated';


* region
*V0.5a 980814 - introduce ALL_REG
*  SET REG                         'List of Regions'          / EMPTY /;
  SET REG_GRP                     'List of regional groups'  / EMPTY /;
  SET REG_RMAP(REG_GRP,ALL_REG)   'Grouping of regions in/out of area of study' / EMPTY.EMPTY /;

* time
  SET MILESTONYR(ALLYEAR)             'Projection years for which model to be run' / EMPTY /;
      ALIAS(MILESTONYR,T);
      ALIAS(MILESTONYR,TT);
*  SET TS(ALL_TS)                      'Time slices of the year               / EMPTY /;
      ALIAS(ALL_TS,TS);
      ALIAS(ALL_TS,S);
  SET TS_GROUP(ALL_REG,TSLVL,ALL_TS)  'Timeslice Level assignment'           / EMPTY.EMPTY.EMPTY /;
  SET TS_MAP(ALL_REG,ALL_TS,ALL_TS)   'Timeslice hierarchy tree: node+below' / EMPTY.EMPTY.EMPTY /;
  SET RS_BELOW(ALL_REG,ALL_TS,ALL_TS) 'Timeslices stictly below a node'      / EMPTY.EMPTY.EMPTY /;

* topology
*V0.5a 980814 - introduce ALL_REG
  SET TOP(REG,PRC,COM,IO)                'Topology for all process'  / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET TOP_IRE(ALL_REG,COM,ALL_REG,COM,PRC) 'Trade within area of study' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;

* user constraints
  SET UC_N                       'List of names of all manual constraints'   /EMPTY/;

* miscellaneous
*  SET SOW                        'Stochastic State-of-the-World'  / EMPTY /;
  SET G_UAMAT(U)                 'Unit for activity of material process'  / EMPTY /;
  SET G_UANRG(U)                 'Unit for activity of energy process'    / EMPTY /;
  SET G_UCMAT(U)                 'Unit for capacity of material process'  / EMPTY /;
  SET G_UCNRG(U)                 'Unit for capacity of energy process'    / EMPTY /;
  SET G_UMONY(U)                 'Monetary unit'                          / EMPTY /;
  SET G_RCUR(REG,CUR)            'Main currency unit by region'     / EMPTY.EMPTY /;

*-----------------------------------------------------------------------------
* PARAMETERS SECTION
*-----------------------------------------------------------------------------

* Activity
  PARAMETER ACT_BND(REG,ALLYEAR,PRC,TS,BD)      'Bound on activity of a process'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER ACT_COST(REG,ALLYEAR,PRC,CUR)       'Variable costs associate with activity of a process'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER ACT_CUM(REG,PRC,ITEM,ITEM,LIM)      'Bound on cumulative activity' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* New Capacity
  PARAMETER NCAP_AF(REG,ALLYEAR,PRC,TS,BD)      'Availability of capacity' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_AFA(REG,ALLYEAR,PRC,BD)        'Annual Availability of capacity' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_AFS(REG,ALLYEAR,PRC,TS,BD)     'Seasonal Availability of capacity' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_AFX(R,ALLYEAR,P)               'Change in capacity availability'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_AFM(R,ALLYEAR,P)               'Pointer to availity change multiplier' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_BND(REG,ALLYEAR,PRC,LIM)       'Bound on overall capacity in a period' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_BPME(REG,ALLYEAR,PRC)          'Back pressure mode eff (or max gross eff)' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_CEFF(REG,ALLYEAR,PRC,CG,CG)    'Condensing mode efficiency' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_CHPR(REG,ALLYEAR,PRC,BD)       'Combined heat:power ratio' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_CLED(REG,ALLYEAR,PRC,COM)      'Leadtime of a commodity before new capacity ready' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_CLAG(REG,ALLYEAR,PRC,COM,IO)   'Lagtime of a commodity after new capacity ready' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_COM(REG,ALLYEAR,PRC,COM,IO)    'Use (but +) of commodity based upon capacity' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_COST(REG,ALLYEAR,PRC,CUR)      'Investment cost for new capacity' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_DRATE(REG,ALLYEAR,PRC)         'Process specific discount (hurdle) rate' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_ELIFE(REG,ALLYEAR,PRC)         'Economic (payback) lifetime' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FOM(REG,ALLYEAR,PRC,CUR)       'Fixed O&M' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FOMX(REG,ALLYEAR,PRC)          'Change in fixed O&M' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FOMM(REG,ALLYEAR,PRC)          'Pointer to fixed O&M change multiplier'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FSUB(REG,ALLYEAR,PRC,CUR)      'Fixed tax on installed capacity'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FSUBX(REG,ALLYEAR,PRC)         'Change in fixed tax'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FSUBM(REG,ALLYEAR,PRC)         'Pointer to fixed subsidy change multiplier'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FTAX(REG,ALLYEAR,PRC,CUR)      'Fixed tax on installed capacity'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FTAXX(REG,ALLYEAR,PRC)         'Change in fixed tax'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_FTAXM(REG,ALLYEAR,PRC)         'Pointer to fixed tax change multiplier'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_ICOM(REG,ALLYEAR,PRC,COM)      'Input of commodity for install of new capacity'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_ILED(REG,ALLYEAR,PRC)          'Lead-time required for building a new capacity' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_ISUB(REG,ALLYEAR,PRC,CUR)      'Subsidy for a new investment in capacity'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_ITAX(REG,ALLYEAR,PRC,CUR)      'Tax on a new investment in capacity'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_LCOST(REG,ALLYEAR,PRC)         '% labor cost of new investment'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_LFOM(REG,ALLYEAR,PRC)          '% labor cost of fixed O&M'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_PASTI(REG,ALLYEAR,PRC)         'Capacity install prior to study years'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_PASTY(REG,ALLYEAR,PRC)         'Buildup years for past investments'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_TLIFE(REG,ALLYEAR,PRC)         'Technical lifetime of a process'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_OLIFE(REG,ALLYEAR,PRC)         'Operating lifetime of a process';
  PARAMETER RCAP_BLK(REG,ALLYEAR,PRC)           'Retirement block size' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER RCAP_BND(REG,ALLYEAR,PRC,LIM)       'Retirement bounds';

* decommissioning of Capacity

  PARAMETER NCAP_DCOST(REG,ALLYEAR,PRC,CUR)     'Cost of decomissioning'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_DLAG(REG,ALLYEAR,PRC)          'Delay to begin decomissioning'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_DLAGC(REG,ALLYEAR,PRC,CUR)     'Cost of decomissioning delay'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_DELIF(REG,ALLYEAR,PRC)         'Economic lifetime to pay for decomissioning'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_DLIFE(REG,ALLYEAR,PRC)         'Time for the actual decomissioning'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_OCOM(REG,ALLYEAR,PRC,COM)      'Commodity release during decomissioning'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_SALV(REG,ALLYEAR,PRC,COM,CUR)  'Salvage value for commodity still imbedded at end of time horizon'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_VALU(REG,ALLYEAR,PRC,COM,CUR)  'Value of material released during decomissioning'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* capacity installed
  PARAMETER NCAP_START(REG,PRC)                 'Start year for new investments' / EMPTY.EMPTY 0 /;
  PARAMETER CAP_BND(REG,ALLYEAR,PRC,BD)         'Bound on total installed capacity in a period' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* general commodities
  PARAMETER COM_BNDNET(REG,ALLYEAR,COM,TS,LIM)           'Net bound on commodity (e.g., emissions)'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_BNDPRD(REG,ALLYEAR,COM,TS,LIM)           'Limit on production of a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_CUMNET(REG,BOHYEAR,EOHYEAR,COM,LIM)      'Cumulative net bound on commodity (e.g., emissions)'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_CUMPRD(REG,BOHYEAR,EOHYEAR,COM,LIM)      'Cumulative limit on production of a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_CSTNET(REG,ALLYEAR,COM,TS,CUR)           'Cost on Net of commodity (e.g., emissions tax)'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_CSTPRD(REG,ALLYEAR,COM,TS,CUR)           'Cost on production of a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_FR(REG,ALLYEAR,COM,TS)                   'Seasonal distribution of a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_IE(REG,ALLYEAR,COM,TS)                   'Seasonal efficiency of commodity'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_SUBNET(REG,ALLYEAR,COM,TS,CUR)           'Subsidy on a commodity net'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_SUBPRD(REG,ALLYEAR,COM,TS,CUR)           'Subsidy on production of a commodity net'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_TAXNET(REG,ALLYEAR,COM,TS,CUR)           'Tax on a commodity net'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_TAXPRD(REG,ALLYEAR,COM,TS,CUR)           'Tax on production of a commodity net'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* demands
  PARAMETER COM_BPRICE(REG,ALLYEAR,COM,TS,CUR)           'Base price of elastic demands'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_BQTY(REG,COM,TS)                         'Base quantity for elastic demands'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_ELAST(REG,ALLYEAR,COM,TS,BD)             'Easticity of demand'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_ELASTX(REG,ALLYEAR,COM,BD)               'Easticity shape of demand'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_PROJ(REG,ALLYEAR,COM)                    'Demand baseline projection'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_STEP(REG,COM,BD)                         'Step size for elastic demand'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_VOC(REG,ALLYEAR,COM,BD)                  'Variance of elastic demand'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* aggregation of commodities
  PARAMETER COM_AGG(REG,ALLYEAR,COM,COM)                 'Commodity aggregation parameter' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* flow of commodities through processes
  PARAMETER FLO_BND(REG,ALLYEAR,PRC,CG,TS,BD)            'Bound on the flow variable'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_COST(REG,ALLYEAR,PRC,COM,TS,CUR)         'Added variable O&M of using a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_DELIV(REG,ALLYEAR,PRC,COM,TS,CUR)        'Delivery cost for using a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_FEQ(REG,ALLYEAR,PRC,COM)                 'Fossil equivalent of a commodity in a process'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_FR(REG,ALLYEAR,PRC,COM,TS,LIM)           'Load-curve of availability of commodity to a process'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_FUNC(REG,ALLYEAR,PRC,CG,CG,TS)           'Relationship between 2 (group of) flows'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_FUNCX(REG,ALLYEAR,PRC,CG,CG)             'Change in FLO_FUNC/FLO_SUM by age'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_SHAR(REG,ALLYEAR,PRC,C,CG,TS,BD)         'Relationship between members of the same flow group'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_SUB(REG,ALLYEAR,PRC,COM,TS,CUR)          'Subsidy for the production/use of a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_SUM(REG,ALLYEAR,PRC,CG,C,CG,TS)          'Multipier for commodity in cg1 where each is summed into cg2'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_TAX(REG,ALLYEAR,PRC,COM,TS,CUR)          'Tax on the production/use of a commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_CUM(REG,PRC,COM,ITEM,ITEM,LIM)           'Bound on cumulative flow' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_MARK(REG,ALLYEAR,PRC,COM,BD)             'Process-wise market share in total commodity production'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER PRC_MARK(REG,ALLYEAR,PRC,ITEM,C,LIM)         'Process group-wise market share' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* globals
  PARAMETER G_CHNGMONY(REG,ALLYEAR,CUR)                  'Exchange rate for currency'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER G_DRATE(REG,ALLYEAR,CUR)                     'Discount rate for a currency'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER G_YRFR(ALL_REG,TS)                           'Seasonal fraction of the year'  / EMPTY.EMPTY 0 /;
  PARAMETER G_OFFTHD(ALLYEAR)                            'Threshold for OFF ranges';
  PARAMETER G_OVERLAP                                    'Overlap of stepped solutions (in years)' / 0 /;
  PARAMETER G_CUREX(CUR,CUR)                             'Global currency conversions';
  PARAMETER R_CUREX(ALL_REG,CUR,CUR)                     'Regional currency conversions';

* trade of commodities
  PARAMETER IRE_BND(ALL_R,ALLYEAR,COM,TS,ALL_REG,IE,BD)  'Limit on inter-reg exchange of commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER IRE_FLO(ALL_R,ALLYEAR,PRC,COM,ALL_R,COM,TS)  'Efficiency of exchange for inter-regional transder'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER IRE_FLOSUM(REG,ALLYEAR,PRC,COM,TS,IE,COM,IO) 'Aux. consumption/emissions from inter-regional transder'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER IRE_PRICE(REG,ALLYEAR,PRC,COM,TS,ALL_R,IE,CUR) 'Price of import/export'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER IRE_XBND(ALL_REG,ALLYEAR,COM,TS,IE,BD)       'Limit on all (external and inter-regional) exchange of commodity'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER IRE_CCVT(ALL_REG,COM,ALL_REG,COM)            'Commodity unit conversion factor between regions'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER IRE_TSCVT(ALL_REG,ALL_TS,ALL_REG,ALL_TS)     'Identification and TS-conversion factor between regions'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* Shape and Multi
  PARAMETER SHAPE(J,AGE)                                 'Shaping table'       / EMPTY.EMPTY 0 /;
  PARAMETER MULTI(J,ALLYEAR)                             'Multiplier table'    / EMPTY.EMPTY 0 /;

* Units
  PARAMETER PRC_ACTFLO(REG,ALLYEAR,PRC,CG)               'Convert from process activity to particular commodity flow'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER PRC_CAPACT(REG,PRC)                          'Factor for going from capacity to activity'  / EMPTY.EMPTY 0 /;

*-----------------------------------------------------------------------------
* SYSTEM (Internal) Declarations
*-----------------------------------------------------------------------------
* SET SECTION
*-----------------------------------------------------------------------------

* commodities
  SET RC(R,C)                       'Commodities in each region';
  SET RCJ(R,C,J,BD)                 '# of steps for elastic demands';
  SET RTC_CUMNET(R,ALLYEAR,C)       'VAR_COMNETs within CUM constraint range';
  SET RTC_CUMPRD(R,ALLYEAR,C)       'VAR_COMPRDs within CUM constraint range';
  SET RHS_COMBAL(R,ALLYEAR,C,S)     'VAR_COMNET needed on balance';
  SET RHS_COMPRD(R,ALLYEAR,C,S)     'VAR_COMPRD needed on production';
  SET RCS_COMBAL(R,ALLYEAR,C,S,LIM) 'TS for balance given RHS requirements';
  SET RCS_COMPRD(R,ALLYEAR,C,S,LIM) 'TS for production given RHS requirements';
  SET RCS_COMTS(R,C,ALL_TS)         'All timeslices at/above the COM_TSL';

* currency
  SET RDCUR(REG,CUR)                'Main currencies by region';

* commodity types (basic)
  SET DEM(REG,COM)  'Demand commodities' / EMPTY.EMPTY /;
  SET ENV(REG,COM)  'Environmental indicator commodities' / EMPTY.EMPTY /;
  SET FIN(REG,COM)  'Financial flow commodities' / EMPTY.EMPTY /;
  SET MAT(REG,COM)  'Material commodities' / EMPTY.EMPTY /;
  SET NRG(REG,COM)  'Energy carrier commodities' / EMPTY.EMPTY /;

* OBJ function yearly values established in COEF_OBJ and used in OBJ_*
  PARAMETER OBJ_PVT(R,T,CUR)               'Present value of period'  / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_CRF(R,ALLYEAR,P,CUR)       'Capital recovery factor'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_CRFD(R,ALLYEAR,P,CUR)      'Capital recovery factor for Decommissioning' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_DISC(R,ALLYEAR,CUR)        'Discounting factor'       / EMPTY.EMPTY.EMPTY 0 /;
$IF %OBMAC%==YES $GOTO RESTOBJ
  PARAMETER OBJ_ICOST(R,ALLYEAR,P,CUR)     'NCAP_COST for each year'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_ISUB(R,ALLYEAR,P,CUR)      'NCAP_ISUB for each year'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_ITAX(R,ALLYEAR,P,CUR)      'NCAP_ITAX for each year'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_FOM(R,ALLYEAR,P,CUR)       'NCAP_FOM for each year'   / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_FSB(R,ALLYEAR,P,CUR)       'NCAP_FSUB for each year'  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_FTX(R,ALLYEAR,P,CUR)       'NCAP_FTX for each year'   / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_DCOST(R,ALLYEAR,P,CUR)     'NCAP_DCOST for each year' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_DLAGC(R,ALLYEAR,P,CUR)     'NCAP_DLAGC for each year' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_ACOST(R,ALLYEAR,P,CUR)     'ACT_COST for each year'   / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_FCOST(R,ALLYEAR,P,C,S,CUR) 'FLO_COST for each year'   / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_FDELV(R,ALLYEAR,P,C,S,CUR) 'FLO_DELIV for each year'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_FTAX(R,ALLYEAR,P,C,S,CUR)  'FLO_TAX for each year'    / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
$LABEL RESTOBJ
  PARAMETER OBJ_FSUB(R,ALLYEAR,P,C,S,CUR)  'FLO_SUB for each year'    / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_COMNT(R,ALLYEAR,C,S,COSTYPE,CUR) 'COM_CNET for each year' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_COMPD(R,ALLYEAR,C,S,COSTYPE,CUR) 'COM_CPRD for each year' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER OBJ_IPRIC(R,ALLYEAR,P,C,S,ALL_REG,IE,CUR) 'IRE_PRICE for each year' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* process
  SET RP(R,P)                   'Processes in each region'               / EMPTY.EMPTY /;
  SET RP_FLO(R,P)               'Processes with VAR_FLOs (not IRE)'      / EMPTY.EMPTY /;
  SET RP_STD(R,P)               'Standard processes with VAR_FLOs'       / EMPTY.EMPTY /;
  SET RP_STG(R,P)               'Storage processes'                      / EMPTY.EMPTY /
  SET RP_IRE(ALL_REG,P)         'Processes involved in inter-regional trade' / EMPTY.EMPTY /;
  SET RP_INOUT(R,P,IO)          'Indicator if process input/output normalized (according to PRC_ACTUNTcg side)'  / EMPTY.EMPTY.EMPTY /;
  SET RP_MAT(R,P)               'Processes for whick PRC_ACTUNTcg is a material' / EMPTY.EMPTY /;
  SET RP_NRG(R,P)               'Processes for whick PRC_ACTUNTcg is an energy carrier' / EMPTY.EMPTY /;
  SET RP_PG(R,P,CG)             'Primary commodity group'                / EMPTY.EMPTY.EMPTY /;
  SET RP_PGTYPE(R,P,COM_TYPE)   'Group type of the primary group'        / EMPTY.EMPTY.EMPTY /;
  SET RP_SPG(R,P,CG)            'Shadow Primary commodity group'         / EMPTY.EMPTY.EMPTY /;
  SET RPC(R,P,C)                'Commodities in/out of a processes'      / EMPTY.EMPTY.EMPTY /;
  SET RPC_CAPFLO(R,ALLYEAR,P,C) 'Commodities involved in capacity'       / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RPC_CONLY(R,ALLYEAR,P,C)  'Commodities ONLY involved in capacity'  / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RPC_NOFLO(R,P,C)          'Commodities ONLY involved in capacity'  / EMPTY.EMPTY.EMPTY /;
  SET RPC_IRE(ALL_REG,P,C,IE)   'Process/commodities involved in inter-regional trade' / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RPC_PG(R,P,C)             'Commodities in the primary group'       / EMPTY.EMPTY.EMPTY /;
  SET RPC_SPG(R,P,C)            'Commodities in the shadow primary group' / EMPTY.EMPTY.EMPTY /;
  SET RPCS_VAR(R,P,C,ALL_TS)    'The timeslices at which VAR_FLOs are to be created' / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RPS_S1(R,P,ALL_TS)        'All timeslices at the PRC_TSL/COM_TSLspg = PTRANSs1' / EMPTY.EMPTY.EMPTY /;
  SET RPS_S2(R,P,ALL_TS)        'All timeslices at/above the PRC_TSL/COM_TSLspg = PTRANSs2' / EMPTY.EMPTY.EMPTY /;
  SET RPS_PRCTS(R,P,ALL_TS)     'All timeslices at/above the PRC_TSL'    / EMPTY.EMPTY.EMPTY /;
  SET RTC(R,ALLYEAR,C)          'Commodity/time'                         / EMPTY.EMPTY.EMPTY /;
  SET RTCS_VARC(R,ALLYEAR,C,ALL_TS) 'The VAR_COMNET/PRDs control set'    / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RTP(R,ALLYEAR,P)          'Process/time'                           / EMPTY.EMPTY.EMPTY /;
  SET RTPC(R,ALLYEAR,P,C)       'Commodities of process in period'       / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RTP_CPTYR(R,ALLYEAR,ALLYEAR,P)  'Capcity transfer v/t years'       / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RTP_OFF(R,ALLYEAR,P)      'Periods for which VAR_NCAP.UP = 0'      / EMPTY.EMPTY.EMPTY /;
  SET RTPCS_VARF(ALL_REG,ALLYEAR,P,C,ALL_TS) 'The VAR_FLOs control set'  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RTP_VARA(R,ALLYEAR,P)     'The VAR_ACT control set'                / EMPTY.EMPTY.EMPTY /;
  SET RTP_VINTYR(ALL_REG,ALLYEAR,ALLYEAR,PRC)  'v/t years when vintaging involved' / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RVP(R,ALLYEAR,P)          'ALIAS(RTP) for Process/time'            / EMPTY.EMPTY.EMPTY /;
  SET RTP_CAPYR(R,ALLYEAR,ALLYEAR,P) / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET CG_GRP(REG,PRC,CG,CG)     / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET FSCK(REG,PRC,CG,C,CG)     / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;
  SET FSCKS(REG,PRC,CG,C,CG,S)  / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;
  SET RPC_IREIO(R,P,C,IE,IO)    / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;
* cumulatives
  SET RC_CUMCOM(REG,COM_VAR,ALLYEAR,ALLYEAR,COM) 'Cumulative commodity PRD/NET';
  SET RPC_CUMFLO(REG,PRC,COM,ALLYEAR,ALLYEAR)    'Cumulative process flows';

* Split of timeslice based upon level and commodity profile
  PARAMETER RS_FR(R,S,S)       / EMPTY.EMPTY.EMPTY 0 /;
* PARAMETER RTCS_FR(R,T,C,S,S) / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER RTCS_TSFR(R,ALLYEAR,C,S,S) / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* region
  SET RREG(ALL_REG,ALL_REG) 'The set of paired regions'                  / EMPTY.EMPTY /;

* time
  SET DATAYEAR(ALLYEAR)     'Years for which user data is provided'      / EMPTY /;
  SET EACHYEAR(ALLYEAR)     'Each year from 1st NCAP_PASTI-Y to last MILESTONYR + DUR_MAX' / EMPTY /;
  SET EOHYEARS(ALLYEAR)     'Each year from 1st NCAP_PASTI-Y to last MILESTONYR' / EMPTY /;
  SET MODLYEAR(ALLYEAR)     'Years for which the model is to be run (MILESTONYR+PASTYEAR)' / EMPTY /;
      ALIAS(MODLYEAR,V);
  SET PASTYEAR(ALLYEAR)     'The years before 1st MILESTONYR for which PASTI needs to be handled'  / EMPTY /;
      ALIAS(PASTYEAR,PYR);
* identifiers for beginning/end of model horizon
  SET MIYR_1(ALLYEAR);
  SET MIYR_L(ALLYEAR) / EMPTY /;

  SCALARS MIYR_V1 /0/, MIYR_VL /0/, PYR_V1 /0/;

* maximum NCAP_ILED+NCAP_TLIFE+NCAP_DLAG+NCAP_DLIFE+NCAP_DELIF
  SCALAR  DUR_MAX / 0 /;

* miscellaneous
  SET RP_PRC(R,P);
  SET RP_CCG(REG,PRC,C,CG);
  SET TRACKC(R,C) / EMPTY.EMPTY /;
  SET TRACKP(R,P) / EMPTY.EMPTY /;
  SET TRACKPC(R,P,C) / EMPTY.EMPTY.EMPTY /;
  PARAMETER RS_STG(R,ALL_TS) 'Lead from previous storage timeslice';
  PARAMETER RS_UCS(R,S,SIDE) 'Lead for TS-dynamic UC';
  PARAMETER RS_STGAV(R,ALL_TS) 'Average residence time for storage activity';
  PARAMETER RS_TSLVL(R,ALL_TS) 'Timeslice levels';

* --------------------------------------------------------------------------------------------------------------------
* PARAMETERS SECTION
* --------------------------------------------------------------------------------------------------------------------
* time
  PARAMETER B(ALLYEAR)      'Beginning year of each model period'
  PARAMETER E(ALLYEAR)      'Ending year of each model period'
  PARAMETER M(ALLYEAR)      'Middle year of each Period'
  PARAMETER D(ALLYEAR)      'Length of each period'

* integrated parameters (created in PREPPM.mod)
  PARAMETER UC_COM(UC_N,COM_VAR,SIDE,REG,ALLYEAR,COM,S,UC_GRPTYPE) 'Multiplier of VAR_COM variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_CUM(REG,COM_VAR,ALLYEAR,ALLYEAR,COM,LIM) 'Cumulative bound on commodity' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

* derived coefficient components (created in COEF*.MOD)
  PARAMETER COEF_AF(R,ALLYEAR,T,PRC,S,BD)      'Capacity/Activity relationship'         / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COEF_CPT(R,ALLYEAR,T,PRC)          'Fraction of capacity available'         / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COEF_ICOM(R,ALLYEAR,T,PRC,C)       'Commodity flow at investment time'      / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COEF_OCOM(R,ALLYEAR,T,PRC,C)       'Commodity flow at decommissioning time' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COEF_PTRAN(REG,ALLYEAR,PRC,CG,C,CG,S) 'Multiplier for EQ_PTRANS'            / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COEF_RPTI(R,ALLYEAR,P)             'Repeated investment cycles'             / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COEF_ILED(R,ALLYEAR,P)             'Investment lead time'                   / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COEF_PVT(R,T)                      'Present value of time in periods'       / EMPTY.EMPTY 0 /;
  PARAMETER COEF_CAP(R,ALLYEAR,LL,P)           'Generic re-usable work parameter';
  PARAMETER COEF_RTP(R,ALLYEAR,P)              'Generic re-usable work parameter';
  PARAMETER NCAP_AFSX(R,ALLYEAR,P) / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER NCAP_AFSM(R,ALLYEAR,P) / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER PRC_YMIN(REG,PRC) / EMPTY.EMPTY 0 /;
  PARAMETER PRC_YMAX(REG,PRC) / EMPTY.EMPTY 0 /;

* --------------------------------------------------------------------------------------------------------------------
* Additions
* --------------------------------------------------------------------------------------------------------------------
* peak
  SET COM_PEAK(REG,COM_GRP)          'Peaking required flag'                / EMPTY.EMPTY /;
  SET COM_PKTS(REG,COM_GRP,TS)       'Peaking time-slices'                  / EMPTY.EMPTY.EMPTY /;
  SET PRC_PKNO(ALL_REG,PRC)          'Processes which cannot be involved in peaking' /EMPTY.EMPTY/;
  SET PRC_PKAF(ALL_REG,PRC)          'Flag for default value of NCAP_PKCNT' /EMPTY.EMPTY/;
* storage
  SET PRC_NSTTS(REG,PRC,ALL_TS)      'Night storage process and time-slice for storaging'   / EMPTY.EMPTY.EMPTY /;
  SET PRC_STGTSS(REG,PRC,COM)        'Storage process and stored commodity for time-slice storage'   / EMPTY.EMPTY.EMPTY /;
  SET PRC_STGIPS(REG,PRC,COM)        'Storage process and stored commodity for inter-period storage' / EMPTY.EMPTY.EMPTY /;

* user constraints
  SET UC_NAME                                     'Allowed parameter names' / EMPTY /;
  SET UC_GMAP_C(REG,UC_N,COM_VAR,COM,UC_GRPTYPE)  'Assigning commodities to UC_GRP' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;
  SET UC_GMAP_P(REG,UC_N,UC_GRPTYPE,PRC)          'Assigning processes to UC_GRP'   / EMPTY.EMPTY.EMPTY.EMPTY /;
  SET UC_ATTR(ALL_R,UC_N,SIDE,UC_GRPTYPE,UC_NAME) 'Mapping of parameter names to groups' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY /;
  SET UC_T_SUCC(ALL_R,UC_N,ALLYEAR)               'Specification of periods, if UC_DYN=SUCC' /EMPTY.EMPTY.EMPTY/;
  SET UC_T_SUM(ALL_R,UC_N,ALLYEAR)                'Specification of periods, if UC_DYN=SEVERAL' /EMPTY.EMPTY.EMPTY /;
  SET UC_T_EACH(ALL_R,UC_N,ALLYEAR)               'Specification of periods, if UC_DYN=EACH' / EMPTY.EMPTY.EMPTY /;
  SET UC_R_SUM(ALL_REG,UC_N)                      'Specification of regions, if UC_REG=SUM'  / EMPTY.EMPTY /;
  SET UC_R_EACH(ALL_REG,UC_N)                     'Specification of regions, if UC_REG=EACH' / EMPTY.EMPTY /;
  SET UC_TS_SUM(ALL_R,UC_N,ALL_TS)                'Specification of time-slices, if UC_TS=SUM' / EMPTY.EMPTY.EMPTY /;
  SET UC_TS_EACH(ALL_R,UC_N,ALL_TS)               'Specification of time-slices, if UC_TS=EACH' /EMPTY.EMPTY.EMPTY /;
  SET UC_TSL(R,UC_N,SIDE,TSLVL)                   'UC timeslice level' / EMPTY.EMPTY.EMPTY.EMPTY /;

* peak
  PARAMETER NCAP_PKCNT(REG,ALLYEAR,PRC,ALL_TS)    'Fraction of capacity contributing to peaking in time-slice TS' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_PKRSV(REG,ALLYEAR,COM)            'Peaking reserve margin'           / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER COM_PKFLX(REG,ALLYEAR,COM,TS)         'Peaking flux ratio'               / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER FLO_PKCOI(REG,ALLYEAR,PRC,COM,ALL_TS) 'Factor increasing the average demand' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
* Storage
  PARAMETER STG_EFF(REG,ALLYEAR,PRC)              'Storage efficiency'       / EMPTY.EMPTY.EMPTY 0/;
  PARAMETER STG_LOSS(REG,ALLYEAR,PRC,S)           'Annual energy loss from a storage technology' / EMPTY.EMPTY.EMPTY.EMPTY 0/;
  PARAMETER STG_CHRG(REG,ALLYEAR,PRC,S)           'Exogeneous charging of a storage technology ' / EMPTY.EMPTY.EMPTY.EMPTY 0/;
  PARAMETER STGOUT_BND(REG,ALLYEAR,PRC,C,S,BD)    'Bound on output-flow of storage process'      / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0/;
  PARAMETER STGIN_BND(REG,ALLYEAR,PRC,C,S,BD)     'Bound on output-flow of storage process'      / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0/;
* Regional Cost bounds
  PARAMETER REG_BNDCST(REG,ALLYEAR,COSTAGG,CUR,BD) 'Bound on regional costs by type'            / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER REG_CUMCST(REG,ALLYEAR,ALLYEAR,COSTAGG,CUR,BD) 'Cumulative bound on regional costs' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

** User Constraints

  PARAMETER UC_RHS(UC_N,LIM)                       'Constant in user constraint '          / EMPTY.EMPTY 0 /;
  PARAMETER UC_RHST(UC_N,ALLYEAR,LIM)              'Constant in user constraint '          / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_RHSR(ALL_REG,UC_N,LIM)              'Constant in user constraint '          / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_RHSS(UC_N,TS,LIM)                   'Constant in user constraint '          / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_RHSRT(ALL_REG,UC_N,ALLYEAR,LIM)     'Constant in user constraint '          / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_RHSRS(ALL_REG,UC_N,TS,LIM)          'Constant in user constraint '          / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_RHSRTS(ALL_REG,UC_N,ALLYEAR,TS,LIM) 'Constant in user constraint '          / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_RHSTS(UC_N,ALLYEAR,TS,LIM)          'Constant in user constraint '          / EMPTY.EMPTY.EMPTY.EMPTY 0 /;

  PARAMETER UC_FLO(UC_N,SIDE,ALL_REG,ALLYEAR,PRC,COM,ALL_TS) 'Multiplier of flow variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_ACT(UC_N,SIDE,ALL_REG,ALLYEAR,PRC,ALL_TS) 'Multiplier of activity variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_CAP(UC_N,SIDE,ALL_REG,ALLYEAR,PRC)        'Multiplier of capacity variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_NCAP(UC_N,SIDE,ALL_REG,ALLYEAR,PRC)       'Multiplier of VAR_NCAP variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_COMCON(UC_N,SIDE,ALL_REG,ALLYEAR,COM,TS)  'Multiplier of VAR_COMCON variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_COMPRD(UC_N,SIDE,ALL_REG,ALLYEAR,COM,TS)  'Multiplier of VAR_COMPRD variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_COMNET(UC_N,SIDE,ALL_REG,ALLYEAR,COM,TS)  'Multiplier of VAR_COMNET variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_IRE(UC_N,SIDE,ALL_REG,ALLYEAR,PRC,COM,ALL_TS,IMPEXP) 'Multiplier of inter-regional exchange variables' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_CUMACT(UC_N,ALL_REG,PRC,ITEM,ITEM) 'Multiplier of cumulative process activity variable' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_CUMFLO(UC_N,ALL_REG,PRC,COM,ITEM,ITEM) 'Multiplier of cumulative process flow variable' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_CUMCOM(UC_N,ALL_REG,COM_VAR,COM,ITEM,ITEM) 'Multiplier of cumulative commodity variable' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER UC_TIME(UC_N,ALL_REG,ALLYEAR) 'Multiplier of time in model periods (years)' / EMPTY.EMPTY.EMPTY 0 /;


* -------------------------------------------------------------------------------------------------
*GG* V07_2 Initializations for BLENDing
* -------------------------------------------------------------------------------------------------
* user provided Sets & Scalars
         SET BLE(COM)       / EMPTY /;
         SET OPR(COM)       / EMPTY /;
         SET SPE            / EMPTY /;
         SET REF(R,PRC)     / EMPTY.EMPTY /;
*         SET BL_NST(COM)   / EMPTY /;

         SET BL_OFF(R,ALLYEAR,BLE,SPE)  / EMPTY.EMPTY.EMPTY.EMPTY /;

         PARAMETER REFUNIT(R)    / EMPTY 0 /;

* internal Sets
         SET CVT                                / DENS, WCV, VCV, SLF /;

* user provided Parameters
         PARAMETER CONVERT(OPR,CVT)              / EMPTY.EMPTY 0 /;
*         PARAMETER SEP_FEQ(SRC,COM,P,YEAR)      / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_START(R,COM,SPE)           / EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_UNIT(R,COM,SPE)            / EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_TYPE(R,COM,SPE)            / EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_SPEC(R,COM,SPE)            / EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER TBL_SPEC(COM,SPE,YEAR)       / EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_COM(R,COM,OPR,SPE)         / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER TBL_COM(COM,SPE,OPR,YEAR)    / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_INP(R,COM,COM)             / EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER TBL_INP(COM,SPE,COM,YEAR)    / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_VAROM(R,COM)               / EMPTY.EMPTY 0 /;
         PARAMETER BL_VAROMC(R,COM,CUR)          / EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER TBL_VAROM(COM,SPE,YEAR)      / EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_DELIV(R,COM,COM)           / EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER BL_DELIVC(R,COM,COM,CUR)      / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER TBL_DELIV(COM,SPE,COM,YEAR)  / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER ENV_BL(R,COM,COM,OPR,ALLYEAR) / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER PEAKDA_BL(R,COM,ALLYEAR)      / EMPTY.EMPTY.EMPTY 0 /;

* internal Parameters
*         PARAMETER ANNC_BLE(BLE,OPR,YEAR)       / EMPTY.EMPTY 0 /;
*         PARAMETER PRICE_BLE(YEAR,BLE,OPR)      / EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER BAL_BLE(YEAR,COM,COM)        / EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER EPK_BLE(YEAR,BLE,ELC,Z)      / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER RU_CVT(R,BLE,SPE,OPR)         / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
         PARAMETER RU_FEQ(R,COM,ALLYEAR)         / EMPTY.EMPTY.EMPTY 0 /;
*         PARAMETER BALE_BLE(YEAR,COM,ELC,Z,Y)   / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

  PARAMETER OBJ_BLNDV(R,ALLYEAR,C,C,CUR)  'annual variable costs for blending' / EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0 /;

*-----------------------------------------------------------------------------
* damages and climate
*-----------------------------------------------------------------------------
* Input parameters
  PARAMETER DAM_COST(REG,ALLYEAR,COM,CUR) 'Marginal damage cost of emissions';
  PARAMETER DAM_BQTY(REG,COM)             'Base quantity of emissions' / EMPTY.EMPTY 0 /;
  PARAMETER DAM_ELAST(REG,COM,LIM)        'Elasticity of damage cost';
  PARAMETER DAM_STEP(REG,COM,LIM)         'Step number for emissions up to base' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER DAM_VOC(REG,COM,LIM)          'Variance of emissions' / EMPTY.EMPTY.EMPTY 0 /;
* Experimental parameters
  PARAMETER DAM_TQTY(REG,ALLYEAR,COM)     'Base quantity of emissions by year' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER DAM_TVOC(REG,ALLYEAR,COM,LIM) 'Variance of emissions by year' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER DAM_COEF(REG,ALLYEAR,COM,S)   'Coefficient between commodity and damage' / EMPTY.EMPTY.EMPTY.EMPTY 0 /;
* Reporting parameters
  PARAMETER CST_DAM(REG,T,COM)            'Damage costs' / EMPTY.EMPTY.EMPTY 0 /;
  PARAMETER CM_RESULT(ITEM,ALLYEAR)       'Climate module results' / EMPTY.EMPTY 0 /;
  PARAMETER CM_MAXC_M(ITEM,ALLYEAR)       'Shadow price of climate constraint' / EMPTY.EMPTY 0 /;
  PARAMETER TM_RESULT(ITEM,R,ALLYEAR)      MACRO results / EMPTY.EMPTY.EMPTY 0 /;
*-----------------------------------------------------------------------------
* Initialization interpolation/extrapolation
*-----------------------------------------------------------------------------
  SET        FIL(ALLYEAR);
  SET        MY_FIL(ALLYEAR)  /EMPTY/
  SET        VNT(ALLYEAR,ALLYEAR);
  SET        YK1(ALLYEAR,ALLYEAR);
  PARAMETER  FIL2(ALLYEAR);
  PARAMETER  MY_FIL2(ALLYEAR) /EMPTY 0/;
  PARAMETER  MY_ARRAY(ALLYEAR)/EMPTY 0/;
  PARAMETER  YKVAL(ALLYEAR,ALLYEAR);
  SCALAR     MY_F /0/, F /0/, Z /0/, CNT /0/;

* first and last given data value to be extrapolated
  SCALAR FIRST_VAL / 0 /, LAST_VAL / 0 /, MY_FYEAR /0/;
  SCALAR DFUNC / 0 /, DONE / 0 /;

* flag used in backward extrapolation
  SCALAR F1ST_FOUND;
  SET BACKWARD(ALLYEAR) /EMPTY/;
  SET FORWARD(ALLYEAR)  /EMPTY/;
* DM_YEAR is the union of the sets MODLYEAR and DATAYEAR (used in IE routines)
  SET DM_YEAR(ALLYEAR) /EMPTY/;

* Interpolation defaults
  SET INT_DEFAULT(*) /EMPTY/;
  PARAMETER IE_DEFAULT(*) /EMPTY 0/;
* Placeholder for interpolation control option
$ SETGLOBAL DFLBL '0'
  YEARVAL('%DFLBL%') = 0;
  SET LASTLL(ALLYEAR); LASTLL('%DFLBL%')=YES; Z=SUM(LASTLL(LL),ORD(LL)); ABORT$(Z NE CARD(LL)) 'FATAL';

*------------------------------------------------------------------------------
* Declarations needed by some recent modifications
*------------------------------------------------------------------------------
* One predefined CG and COM: ACT
$IF NOT SET PGPRIM $SETGLOBAL PGPRIM "'ACT'"
  SET COM_GRP / %PGPRIM% /;
  SET COM     / %PGPRIM% /;
* Label lengths exceeding default
  PARAMETER LABL(ITEM);
$IF NOT SETGLOBAL G226 $SETGLOBAL RL 'R.TL:(12+LABL(R))' SETGLOBAL PL 'P.TL:(12+LABL(P))' SETGLOBAL CL 'C.TL:(12+LABL(C))'
$IF SETGLOBAL G226 $SETGLOBAL RL 'R.TL:MAX(12,R.LEN)' SETGLOBAL PL 'P.TL:MAX(12,P.LEN)' SETGLOBAL CL 'C.TL:MAX(12,C.LEN)'
*-----------------------------------------------------------------------------
*--- Internal Sets:
 SETS
   PASTMILE(ALLYEAR) 'PAST years that are not MILESYONYR' / EMPTY /
   RS_TREE(ALL_REG,ALL_TS,ALL_TS) 'Timeslice subtree' / EMPTY.EMPTY.EMPTY /
   FINEST(R,ALL_TS) 'Set of the finest (highest) timeslices in use' / EMPTY.EMPTY /
   RS_BELOW1(ALL_R,ALL_TS,ALL_TS) 'Timeslices strictly one level below' / EMPTY.EMPTY.EMPTY /
   MY_TS(ALL_TS) 'Temporary set for timeslices' / EMPTY /
   COM_AGP(REG,COM,LIM) 'Commodity aggregation of production' / EMPTY.EMPTY.EMPTY /
   RTP_VARP(R,T,P) 'RTPs that have a VAR_CAP' / EMPTY.EMPTY.EMPTY /
   R_UC(R,UC_N) / EMPTY.EMPTY /
   RXX(ALL_R,*,*) 'General triples related to a region'
   UNCD1(*) 'Non-domain-controlled set'
   UNCD7(*,*,*,*,*,*,*) 'Non-domain-controlled set of 7-tuples';
*--- Internal Parameters:
 PARAMETERS
   TS_ARRAY(ALL_TS) 'Array for leveling parameter values across timeslices'
   STOA(ALL_TS) 'ORD Lag from each timeslice to ANNUAL'
   STOAL(R,S) 'ORD Lag from the LVL of each timeslice to ANNUAL'
   RS_STGPRD(R,ALL_TS) 'Number of storage periods for each timeslice';
*--- Aliases:
 ALIAS (SL,ALL_TS);
 ALIAS (ALLYEAR,ALLY);
 ALIAS (LIFE,AGE);

*------------------------------------------------------------------------------
* Sets and parameters used in reduction algorithm
*------------------------------------------------------------------------------
SET    NO_CAP(R,P)                    'Process not requiring capacity variable'             /EMPTY.EMPTY/;
SET    NO_ACT(R,P)                    'Process not requiring activity variable'             /EMPTY.EMPTY/;
SET    RP_PGACT(R,P)                  'Process with PCG consisting of 1 commodity'          /EMPTY.EMPTY/;
SET    RPC_ACT(REG,PRC,CG)            'PG commodity of Process with PCG consisting of 1'    /EMPTY.EMPTY.EMPTY/;
SET    RPC_AIRE(ALL_REG,PRC,COM)      'Exchange process with only one commodity exchanged'  /EMPTY.EMPTY.EMPTY/;
SET    RPC_EMIS(R,P,COM_GRP)          'Process with emission COM_GRP'                       /EMPTY.EMPTY.EMPTY/;
SET    FS_EMIS(R,P,COM_GRP,C,COM)     'Indicator for emission related FLO_SUM'              /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY/;
SET    RC_IOP(R,C,IO,P)               'Processes associated with commodity'                 /EMPTY.EMPTY.EMPTY.EMPTY/;
SET    RTCS_SING(R,T,C,S,IO)          'Commodity not being consumed'                        /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY/;
SET    RTPS_OFF(R,T,P,S)              'Process being turned off'                            /EMPTY.EMPTY.EMPTY.EMPTY/;
SET    RTP_QACT(R,T,P,S)              'Indicator for direct ACT_BNDs'                       /EMPTY.EMPTY.EMPTY.EMPTY/;
SET    RPC_FFUNC(REG,PRC,COM)         'RPC_ACT Commodity in FFUNC'                          /EMPTY.EMPTY.EMPTY/;
SET    RPCC_FFUNC(REG,PRC,CG,CG)      'Pair of FFUNC commodities with RPC_ACT commodity'    /EMPTY.EMPTY.EMPTY.EMPTY/;
SET    PRC_CAP(REG,PRC)               'Process requiring capacity variable'                 /EMPTY.EMPTY/;
SET    PRC_ACT(REG,PRC)               'Process requiring activity equation'                 /EMPTY.EMPTY/;
SET    PRC_TS2(REG,PRC,TS)            'Alias for PRC_TS of processes with RPC_ACT'          /EMPTY.EMPTY.EMPTY/;

ALIAS(CG3,COM_GRP);
ALIAS(CG4,COM_GRP);
ALIAS (S2,ALL_TS);

*------------------------------------------------------------------------------
* Parameters used in report routine
*------------------------------------------------------------------------------
PARAMETER PAR_FLO(R,ALLYEAR,ALLYEAR,P,C,S)              'Flow parameter'                                         /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY       0/;
PARAMETER PAR_FLOM(R,ALLYEAR,ALLYEAR,P,C,S)             'Reduced cost of flow variable'                          /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY       0/;
PARAMETER PAR_IRE(R,ALLYEAR,ALLYEAR,P,C,S,IMPEXP)       'Parameter for im/export flow'                           /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0/;
PARAMETER PAR_IREM(R,ALLYEAR,ALLYEAR,P,C,S,IMPEXP)      'Reduced cost of import/export flow'                     /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0/;

PARAMETER PAR_OBJINV(R,ALLYEAR,ALLYEAR,P,CUR)           'Annual discounted investment costs'                     /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY             0/;
PARAMETER PAR_OBJDEC(R,ALLYEAR,ALLYEAR,P,CUR)           'Annual discounted decommissioning costs'                /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY             0/;
PARAMETER PAR_OBJFIX(R,ALLYEAR,ALLYEAR,P,CUR)           'Annual discounted FOM cost'                             /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY             0/;
PARAMETER PAR_OBJSAL(R,ALLYEAR,P,CUR)                   'Annual discounted salvage value'                        /EMPTY.EMPTY.EMPTY.EMPTY                   0/;
PARAMETER PAR_OBJLAT(R,ALLYEAR,P,CUR)                   'Annual discounted late costs'                           /EMPTY.EMPTY.EMPTY.EMPTY                   0/;
PARAMETER PAR_OBJACT(R,ALLYEAR,ALLYEAR,P,TS,CUR)        'Annual discounted variable costs'                       /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY       0/;
PARAMETER PAR_OBJFLO(R,ALLYEAR,ALLYEAR,P,COM,TS,CUR)    'Annual discounted flow costs'                           /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY.EMPTY 0/;
PARAMETER PAR_OBJCOM(R,ALLYEAR,COM,TS,CUR)              'Annual discounted commodity costs (incl import/export)' /EMPTY.EMPTY.EMPTY.EMPTY.EMPTY             0/;
PARAMETER PAR_OBJBLE(R,ALLYEAR,COM,CUR)                 'Annual discounted blending costs'                       /EMPTY.EMPTY.EMPTY.EMPTY                   0/;
PARAMETER PAR_OBJELS(R,ALLYEAR,COM,CUR)                 'Annual discounted elastic demand cost term'             /EMPTY.EMPTY.EMPTY.EMPTY                   0/;

*------------------------------------------------------------------------------
$ SETGLOBAL GDXPATH ''
$ IFI EXIST gamssave\nul $SETGLOBAL GDXPATH 'gamssave\'
$ SETGLOBAL SYSPREFIX ''
*------------------------------------------------------------------------------
* Alternative objective controls
SCALAR ALTOBJ / 1 /;
$IFI %OBJ%==STD ALTOBJ=0;
$IFI %OBJ%==ALT ALTOBJ=2;
$IFI %OBJ%==LIN ALTOBJ=3;
$IFI %MACRO%==YES IF(ALTOBJ>1, ABORT 'MACRO Cannot be used with Alternative Objective'; ELSE ALTOBJ=0);
$IFI %VALIDATE%==YES IF(ALTOBJ>1, ABORT 'VALIDATE Cannot be used with Alternative Objective'; ELSE ALTOBJ=0);
$SETGLOBAL CTST ''
$IFI %OBJ%==MOD $SETGLOBAL OBLONG YES
$IFI %OBJ%==ALT $SETGLOBAL CTST **EPS
$IFI %OBLONG%==YES $SETGLOBAL CTST **0
$IFI %OBJ%==LIN $SETGLOBAL CTST **EPS
$IFI '%OBLONG%%OBJ%'==YESALT $SETGLOBAL VARCOST LIN
$IFI '%OBLONG%%OBJ%'==YESALT ALTOBJ = -2;
*------------------------------------------------------------------------------
* Stochastic extension
$IFI %SENSIS%==YES $SETLOCAL STAGES yes
$IFI %SPINES%==YES $SETLOCAL STAGES YES
$IFI %STAGES%==YES $BATINCLUDE initmty.stc
*------------------------------------------------------------------------------
* Stepped extensions etc.
SET UNCD1(*) / "%FIXBOH%", "%TIMESTEP%", "%SPOINT%" /;
$SETGLOBAL RPOINT NO
$IF SET SPOINT IF((NOT J('%SPOINT%'))$(NOT SAMEAS('%SPOINT%','YES')), ABORT 'Invalid Control: SPOINT');
$IF SET TIMESTEP IF(NOT AGE('%TIMESTEP%'), ABORT 'Invalid Control: TIMESTEP');
$IF SET FIXBOH IF(NOT ALLYEAR('%FIXBOH%'), ABORT 'Invalid Control: FIXBOH');
$IF SET FIXBOH
$IF NOT SET TIMESTEP $SETGLOBAL TIMESTEP 999
$IF SET TIMESTEP $SETGLOBAL VAR_UC YES
$IF SET TIMESTEP SET RVT(R,ALLYEAR,T); SET RTPX(R,T,P);
  PARAMETER REG_FIXT(ALL_R);
  PARAMETER NO_RT(ALL_R,T) / EMPTY.EMPTY 0 /;
  SET RT_PP(R,T) / EMPTY.EMPTY /;
$IF %SYSTEM.LICENSELEVEL%==2 $SETGLOBAL VAR_UC YES
*------------------------------------------------------------------------------
* OTHER EXTENSIONS TO TIMES CODE
*------------------------------------------------------------------------------
* [AL] Learning declarations Now done only if ETL is defined
* Auto-activation of discrete capacity extensions
$IFI %DSCAUTO%==YES $SETGLOBAL DSC 'YES' SETGLOBAL RETIRE 'YES' KILL RCAP_BLK

* Initialize list of standard extensions to be loaded:
$SETGLOBAL EXTEND ''

* Add some recognized extensions if defined:
$IFI '%MACRO%'==CSA $SETGLOBAL EXTEND '%EXTEND% MSA'
$IFI '%MACRO%'==MSA $SETGLOBAL EXTEND '%EXTEND% MSA'
$IFI '%ETL%' == YES $SETGLOBAL EXTEND '%EXTEND% ETL'
$IFI '%CLI%' == YES $SETGLOBAL EXTEND '%EXTEND% CLI'
$IFI '%DSC%' == YES $SETGLOBAL EXTEND '%EXTEND% DSC'
$IFI '%VDA%' == YES $SETGLOBAL EXTEND '%EXTEND% VDA'

* Finally, add parameters %1...%6 to list of extensions:
$SETGLOBAL EXTEND %EXTEND% %1 %2 %3 %4 %5 %6

* Load all extension declarations
$IF NOT '%EXTEND%' == '' $BATINCLUDE main_ext.mod initmty %EXTEND%

$BATINCLUDE err_stat.mod '$IF NOT ERRORFREE' ABORT 'Errors in Compile' '' ': initmty.mod'
$BATINCLUDE err_stat.mod '$IF NOT ERRORFREE' ABORT 'Errors in Compile' 'VARIABLE OBJz' ': Required _TIMES.g00 Restart File Missing'

*------------------------------------------------------------------------------
* Call MACRO initmty.tm
*------------------------------------------------------------------------------
$IF NOT SET MACRO $SETGLOBAL MACRO N
$IF %MACRO% == YES $BATINCLUDE initmty.tm
$IF %MACRO% == YES $SETGLOBAL SPOINT 3
* As in original IER implementation, disable warm start in MACRO
* This may be overridden in the RUN file after the INITMTY call
$IF %MACRO% == YES OPTION BRATIO=1;
