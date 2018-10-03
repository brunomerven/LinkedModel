
FinalDemand('SATIM',FS,C,TC,XC) = FLOW_IN_FSFuels(FS,C,TC,TT);
FinalDemand('eSAGE',FS,C,TC,XC)$UCONV_C_T2C(C) = SUM(A$MFSA(FS,A),QINTX(C,A,XC,TC,TT))/UCONV_C_T2C(C);
FinalDemand('eSAGE','petr',C,TC,XC)$UCONV_C_T2C(C) = QINTX(C,'apetr',XC,TC,TT)/UCONV_C_T2C(C);

*FinalDemand('SATIM',FH,C,TC,XC) = FLOW_IN_FHAllFuels(FH,C,TC);
*FinalDemand('eSAGE',FH,C,TC,XC)$UCONV_C_T2C(C) = SUM(H$MFHHT(FH,H,TC),QHX(C,H,XC,TC,TT))/UCONV_C_T2C(C);

EIntensity('SATIM',FS,C,TC,XC)$SFORE_X(FS,TC) = FinalDemand('SATIM',FS,C,TC,XC)/SFORE_X(FS,TC);
EIntensity('eSAGE',FS,C,TC,XC)$SFORE_X(FS,TC) = FinalDemand('eSAGE',FS,C,TC,XC)/SFORE_X(FS,TC);
*EIntensity('SATIM',FH,C,TC,XC)$TFHPOP_X(FH,TC) = FinalDemand('SATIM',FH,C,TC,XC)/TFHPOP_X(FH,TC);
*EIntensity('eSAGE',FH,C,TC,XC)$TFHPOP_X(FH,TC) = FinalDemand('eSAGE',FH,C,TC,XC)/TFHPOP_X(FH,TC);
