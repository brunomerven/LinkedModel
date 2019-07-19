* Model to construct coal supply curves for detailed coal model
Sets
  REG                            TIMES regions    /REGION1/
  ALLYEAR                        All Years
  T(ALLYEAR)                     Time periods
  V(ALLYEAR)                     Vintage
  S                              TIMES timeslices
  PRC                            TIMES Processes
  P(PRC)                         Processes
  COM                            TIMES Commodities
  COM_GRP                        Demand item groupings in TIMES
  ITEM                           Everything
  ETC(PRC)                       TIMES Coal Plants
  XXX                            Needed for obj    / CUR, LEVCOST, INV, Cost, Vol /
  IO                             / IN, OUT/
  TOP(REG,PRC,COM,IO)            top in_out
  TS                             Timeslices
  BD                             Bound type

;

ALIAS (ALLYEAR,AY);


Parameters
  PRC_RESID(REG,AY,PRC)          Existing Capacity
  PAR_CAPL(REG,AY,PRC)           Capacity excluding existing capacity

  ACT_BND(REG,AY,PRC,TS,BD)      Bound on Activity of process

  CST_ACTC(REG,V,AY,PRC)         TIMES calculated annual activity costs
  CST_FIXC(REG,V,AY,PRC)         TIMES calculated annual fixed costs
  CST_INVC(REG,V,AY,PRC,XXX)     TIMES calculated annual investment costs
  CST_INV(AY,PRC)                Simplified annual investment costs

  OB_ICOST(REG,PRC,XXX,AY)       investment unit cost from TIMES run
  OB_ACT(REG,PRC,XXX,AY)         activity unit cost from TIMES run
  OB_FOM(REG,PRC,XXX,AY)         fixed o&m unit cost from TIMES run

  VARACT(REG,AY,PRC)             Activity results from TIMES


  CAPFAC(PRC,AY)
;



$gdxin ALTIRP18_ASC.gdx
$load PRC P COM ALLYEAR S V ITEM TOP TS BD
$load OB_ICOST OB_ACT OB_FOM ACT_BND

*$gdxin CSMA_RO3-UCE.gdx
$gdxin CSMA_RO3_S9-5.gdx
$load PRC_RESID PAR_CAPL CST_INVC CST_FIXC CST_ACTC VARACT

$Include Coal_Techs.inc

Set
  MCOALMLTMP(PRC, PRC, COM)               tmp Mapping for Coal Mines to links and plants
  MCOALML(PRC,PRC)                       Mapping for Coal Mines to links and plants

  MCOALLPTMP(PRC, PRC, COM)               tmp Mapping for links to plants
  MCOALLP(PRC, PRC)                       Mapping for links to plants

  MCOAL(PRC, PRC, PRC)               Mapping for Coal Mines to links to plants
  HISTYEARS(AY)                                       Historical Years / 2012*2017 /
  FUTUREYEARS(AY)                                     Other years
  LINKS_COAL_F(PRC)                                   Links future !!! this needs to come out
;

LINKS_COAL_F(LINKS_COAL) = YES;
LINKS_COAL_F(LINKS_COAL_E) = NO;

CST_INV(AY,PRC)$PAR_CAPL('REGION1',AY,PRC) = SUM(V,CST_INVC('REGION1',V,AY,PRC,'INV'))/PAR_CAPL('REGION1',AY,PRC);

MCOALMLTMP(MINES_COAL, LINKS_COAL, COM)$(TOP('REGION1',MINES_COAL,COM,'OUT') and TOP('REGION1',LINKS_COAL,COM,'IN')) = YES;
MCOALML(MINES_COAL,LINKS_COAL) = SUM(COM,MCOALMLTMP(MINES_COAL, LINKS_COAL, COM));

MCOALLPTMP(LINKS_COAL, PWR_COAL, COM)$(TOP('REGION1',LINKS_COAL,COM,'OUT') and TOP('REGION1',PWR_COAL,COM,'IN')) = YES;
MCOALLP(LINKS_COAL, PWR_COAL) = SUM(COM,MCOALLPTMP(LINKS_COAL, PWR_COAL, COM));

MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL)$(MCOALML(MINES_COAL,LINKS_COAL) and MCOALLP(LINKS_COAL, PWR_COAL)) = YES;


Parameters
  VOM(PWR_COAL,LINKS_COAL,MINES_COAL,AY)           Variable costs
  FOM(PWR_COAL,LINKS_COAL,MINES_COAL,AY)           Fixed costs
  INV(PWR_COAL,LINKS_COAL,MINES_COAL,AY)           Investment costs
  MINECAPACITY(MINES_COAL,AY)                          Coal Mine Capacity
  FLOWLIMITS(PRC,PRC,PRC,AY)        Flow Limits
  SUPCURV(PRC,PRC,PRC,AY,XXX)       Cost and Capacity
  HISTFLOWS(PRC,PRC,PRC,AY)         Historical Flows
  FUTURECAP(PRC,PRC,PRC,AY)       Future Capacity

  Coal_Costs_Mining(AY)           Expenditure on coal mining
  Coal_Costs_Transport(AY)        Expenditure on coal transport
  Coal_Costs_Total(AY)            Total expenditure on coal
;

T(AY) = Yes;
T('0') = No;
FUTUREYEARS(T) = YES;
FUTUREYEARS(HISTYEARS) = NO;

Loop(PWR_COAL,
  VOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = OB_ACT('REGION1',LINKS_COAL,'CUR',T)+OB_ACT('REGION1',MINES_COAL,'CUR',T);
  FOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = OB_FOM('REGION1',LINKS_COAL,'CUR',T)+OB_FOM('REGION1',MINES_COAL,'CUR',T);
*  INV(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = OB_ICOST('REGION1',LINKS_COAL,'CUR',T)+OB_ICOST('REGION1',MINES_COAL,'CUR',T);
  INV(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = CST_INV(T,LINKS_COAL)+CST_INV(T,MINES_COAL);


  MINECAPACITY(MINES_COAL,T) = PRC_RESID('REGION1',T,MINES_COAL)+PAR_CAPL('REGION1',T,MINES_COAL);

  MINECAPACITY('MINCSKRI-E','2019') = 0;
  MINECAPACITY('MINCSHFG-E','2015') = 0;

  FLOWLIMITS(PWR_COAL,LINKS_COAL,MINES_COAL,T)$(MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) and ACT_BND('REGION1',T,LINKS_COAL,'ANNUAL','FX')) = ACT_BND('REGION1',T,LINKS_COAL,'ANNUAL','FX');

  HISTFLOWS(PWR_COAL,LINKS_COAL_E,MINES_COAL,HISTYEARS)$(MCOAL(MINES_COAL, LINKS_COAL_E, PWR_COAL) and MINECAPACITY(MINES_COAL,HISTYEARS)) = VARACT('REGION1',HISTYEARS,LINKS_COAL_E);
  HISTFLOWS(PWR_COAL,LINKS_COAL_F,MINES_COAL,HISTYEARS)$(MCOAL(MINES_COAL, LINKS_COAL_F, PWR_COAL) and MINECAPACITY(MINES_COAL,HISTYEARS)) = VARACT('REGION1',HISTYEARS,LINKS_COAL_F);

  FUTURECAP(PWR_COAL,LINKS_COAL_E,MINES_COAL,FUTUREYEARS)$(MCOAL(MINES_COAL,LINKS_COAL_E,PWR_COAL) and MINECAPACITY(MINES_COAL,FUTUREYEARS)) = MINECAPACITY(MINES_COAL,FUTUREYEARS);


  SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,HISTYEARS,'Vol') = HISTFLOWS(PWR_COAL,LINKS_COAL,MINES_COAL,HISTYEARS);
  SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,FUTUREYEARS,'Vol') = FUTURECAP(PWR_COAL,LINKS_COAL,MINES_COAL,FUTUREYEARS);

  SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,T,'Cost')$(MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) and SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,T,'Vol')) = VOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)+FOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)+INV(PWR_COAL,LINKS_COAL,MINES_COAL,T);
);


Coal_Costs_Mining(T) = sum((MINES_COAL,V), CST_ACTC('REGION1',V,T,MINES_COAL)+CST_FIXC('REGION1',V,T,MINES_COAL)+CST_INVC('REGION1',V,T,MINES_COAL,'INV'));
Coal_Costs_Transport(T) = sum((LINKS_COAL,V), CST_ACTC('REGION1',V,T,LINKS_COAL)+CST_FIXC('REGION1',V,T,LINKS_COAL)+CST_INVC('REGION1',V,T,LINKS_COAL,'INV'));

Coal_Costs_Total(T) = Coal_Costs_Mining(T)+Coal_Costs_Transport(T);


CAPFAC(MINES_COAL,T)$(MINECAPACITY(MINES_COAL,T) gt 0.0001) = VARACT('REGION1',T,MINES_COAL)/MINECAPACITY(MINES_COAL,T);