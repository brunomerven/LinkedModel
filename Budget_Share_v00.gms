* code to translate budget share algorithm from spreadsheet: ConsumptionShares_concept.xlsx
* originally developed by Bruno Merven with Faaiqa Hartley and Sherman Robinson in November 2018 in DC


Sets
H              Households  / hhd-1, hhd-2, hhd-3 /
C              Commodities / cfood, celec, cpetr /
T              Time Period / 2012, 2013 /

;

* creating H-prime
Alias (H,HP);

sets
CLN(H,HP)         Closest Lower Neighbour
CUN(H,HP)         Closets Upper Neighbour
;


Parameters
YI0(H)          Household Income Base Year
YI(H)           Household Income other years
QH0(C,H)        quantity consumed of marketed commodity c by household h in base year
PDD(C)         demand price for commodity produced and sold domestically
BudShare(C,H,T)  budget share of marketed commodity c by household h

DistanceMatrix(H,HP) distance to all

TmpMin(H) minimum of row
TmpLowerNeighbour(H,HP) lower neighbour
TmpUpperNeighbour(H,HP) upper neighbour

TotalDistance(H) sum of distances
DistLower(H) distance to lower
DistUpper(H) distance to upper
WeightLower(H) weighting of lower
WeightUpper(H) weighting of upper

;

YI0('hhd-1') = 1;
YI0('hhd-2') = 3;
YI0('hhd-3') = 8;

BudShare('cfood','hhd-1','2012') = 0.4;
BudShare('celec','hhd-1','2012') = 0.4;
BudShare('cpetr','hhd-1','2012') = 0.2;

BudShare('cfood','hhd-2','2012') = 0.3;
BudShare('celec','hhd-2','2012') = 0.3;
BudShare('cpetr','hhd-2','2012') = 0.4;

BudShare('cfood','hhd-3','2012') = 0.2;
BudShare('celec','hhd-3','2012') = 0.2;
BudShare('cpetr','hhd-3','2012') = 0.6;

YI('hhd-1') = 1.5;
YI('hhd-2') = 5;
YI('hhd-3') = 8.1;

LOOP(HP,
    DistanceMatrix(H,HP) = YI(H) - YI0(HP);
);

TmpLowerNeighbour(H,HP)$(DistanceMatrix(H,HP) GE 0) = DistanceMatrix(H,HP);
TmpLowerNeighbour(H,HP)$(DistanceMatrix(H,HP) LT 0) = 9999;

TmpUpperNeighbour(H,HP)$(DistanceMatrix(H,HP) LE 0) = -1 * DistanceMatrix(H,HP);
TmpUpperNeighbour(H,HP)$(DistanceMatrix(H,HP) GT 0) = 9999;


LOOP(H,
    TmpMin(H) = smin(HP, TmpLowerNeighbour(H,HP));
    CLN(H,HP)$(tmpMin(H) eq TmpLowerNeighbour(H,HP)) = yes;
    DistLower(H) = sum(HP$CLN(H,HP), TmpLowerNeighbour(H,HP));

    TmpMin(H) = smin(HP, TmpUpperNeighbour(H,HP));
    CUN(H,HP)$(tmpMin(H) eq TmpUpperNeighbour(H,HP)) = yes;
    DistUpper(H) = sum(HP$CUN(H,HP), TmpUpperNeighbour(H,HP));

    TotalDistance(H) = DistLower(H) + DistUpper(H);
    WeightLower(H) = 1 - DistLower(H)/TotalDistance(H);
    WeightUpper(H) = 1 - DistUpper(H)/TotalDistance(H);

    BudShare(C,H,'2013') = WeightLower(H) * sum(HP$CLN(H,HP), BudShare(C,HP,'2012')) + WeightUpper(H) * sum(HP$CUN(H,HP), BudShare(C,HP,'2012'));


);

