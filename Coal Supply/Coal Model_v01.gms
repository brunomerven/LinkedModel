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

;



$gdxin  ALTIRP18_ASC.gdx
$load PRC P COM ALLYEAR S V ITEM TOP TS BD
$load OB_ICOST OB_ACT OB_FOM PRC_RESID PAR_CAPL CST_INVC ACT_BND

$Include Coal_Techs.inc

Set
  MCOALMLTMP(MINES_COAL, LINKS_COAL, COM)               tmp Mapping for Coal Mines to links and plants
  MCOALML(MINES_COAL,LINKS_COAL)                       Mapping for Coal Mines to links and plants

  MCOALLPTMP(LINKS_COAL, PWR_COAL, COM)               tmp Mapping for links to plants
  MCOALLP(LINKS_COAL, PWR_COAL)                       Mapping for links to plants

  MCOAL(MINES_COAL,LINKS_COAL,PWR_COAL)                       Mapping for Coal Mines to links to plants

;

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

  SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,AY,XXX)       Cost and Capacity

;

T(AY) = Yes;
T('0') = No;

Loop(PWR_COAL,
  VOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = OB_ACT('REGION1',LINKS_COAL,'CUR',T)+OB_ACT('REGION1',MINES_COAL,'CUR',T);
  FOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = OB_FOM('REGION1',LINKS_COAL,'CUR',T)+OB_FOM('REGION1',MINES_COAL,'CUR',T);
*  INV(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = OB_ICOST('REGION1',LINKS_COAL,'CUR',T)+OB_ICOST('REGION1',MINES_COAL,'CUR',T);
  INV(PWR_COAL,LINKS_COAL,MINES_COAL,T)$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = CST_INV(T,LINKS_COAL)+CST_INV(T,MINES_COAL);

  SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,T,'Vol')$MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) = PRC_RESID('REGION1',T,MINES_COAL)+PAR_CAPL('REGION1',T,MINES_COAL);
  SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,T,'Cost')$(MCOAL(MINES_COAL, LINKS_COAL, PWR_COAL) and SUPCURV(PWR_COAL,LINKS_COAL,MINES_COAL,T,'Vol')) = VOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)+FOM(PWR_COAL,LINKS_COAL,MINES_COAL,T)+INV(PWR_COAL,LINKS_COAL,MINES_COAL,T);
);

