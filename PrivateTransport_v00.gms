* code to translate budget share algorithm from spreadsheet: PrivateTransport_SATIMGE_Prototype.xlsx


Sets
H              Households  / hhd-1 /
C              Commodities / cfood, celec, cpetr, cprtr, cother /
T              Time Period / 2012, 2013 /
A              Activities / aprtr /
;

* creating H-prime
Alias (H,HP);

sets
CHouseholds(C) Commodities consumed by households
CHEnergy(C) Energy Commodities consumed by households /celec, cprtr/
CHNonEnergy(C) Non-Energy Commodities consumed by households
;


Parameters
YI(H,T)           Household Income
QH(C,H,T)        quantity consumed of marketed commodity c by household h
PDD(C,T)         demand price for commodity produced and sold domestically
PQ(C)         price for composite commodity C
BudShare(C,H,T)  budget share of marketed commodity c by household h
ica(C,A,T) intermediate input c per unit of intermediate

BudShareNonEnergy(H,T) budget share of non-energy goods
PDDest(C,T)         demand price estimate for commodity produced and sold domestically based on ica change

UnitConsumption(C,H,T) QH per unit of income (where income = average income * number of households)
Rebound(T) rebound factor

QHNoRebound(C,H,T) Volumes assuming no Rebound
QHFullRebound(C,H,T) Volumes assuming full Rebound
QHActual(C,H,T) Actual Volumes - endogenous to SATIMGE based on budget shares

;

* Base year setup
YI('hhd-1','2012') = 13.3;

ica('cpetr','aprtr','2012') = 1;
ica('celec','aprtr','2012') = 0;

PQ('cpetr') = 2;
PQ('celec') = 1;

BudShare('cprtr','hhd-1','2012') = 0.15;
BudShare('celec','hhd-1','2012') = 0.1;
BudShare('cfood','hhd-1','2012') = 0.5;
BudShare('cother','hhd-1','2012') = 0.25;

CHouseholds(C)$sum(H,BudShare(C,H,'2012')) = YES;
CHNonEnergy(CHouseholds) = YES;
CHNonEnergy(CHEnergy) = NO;

PDD(CHouseholds,T) = 1;
PDD('cprtr','2012') = sum(C,ica(C,'aprtr','2012')*PQ(C));

QH(CHouseholds,H,'2012') = BudShare(CHouseholds,H,'2012')*YI(H,'2012')/PDD(CHouseholds,'2012');
UnitConsumption(CHEnergy,'hhd-1','2012') = QH(CHEnergy,'hhd-1','2012')/YI('hhd-1','2012');

* Change

YI('hhd-1','2013') = 15;
ica('cpetr','aprtr','2013') = 0.5;
ica('celec','aprtr','2013') = 0.3;

PDDest(CHouseholds,'2013') = PDD(CHouseholds,'2013');
PDDest('cprtr','2013') = sum(C,ica(C,'aprtr','2013')*PQ(C));

Rebound('2013') = 0.4;
QHNoRebound(CHEnergy,H,'2013') = UnitConsumption(CHEnergy,H,'2012')*YI('hhd-1','2013');
QHFullRebound(CHEnergy,H,'2013') = BudShare(CHEnergy,H,'2012')*YI(H,'2013')/PDDest(CHEnergy,'2013');
QHActual(CHEnergy,H,'2013') = Rebound('2013') * QHFullRebound(CHEnergy,H,'2013') + (1 - Rebound('2013')) * QHNoRebound(CHEnergy,H,'2013');

BudShare(CHEnergy,H,'2013') = QHActual(CHEnergy,H,'2013') * PDDest(CHEnergy,'2013') / YI(H,'2013');

BudShareNonEnergy(H,'2013') =  sum(CHNonEnergy,BudShare(CHNonEnergy,H,'2012'));

BudShare(CHNonEnergy,H,'2013') = BudShare(CHNonEnergy,H,'2012')/BudShareNonEnergy(H,'2013') * (1 - sum(CHEnergy,BudShare(CHEnergy,H,'2013')));
QH(CHouseholds,H,'2013') = BudShare(CHouseholds,H,'2013')*YI(H,'2013')/PDDest(CHouseholds,'2013');