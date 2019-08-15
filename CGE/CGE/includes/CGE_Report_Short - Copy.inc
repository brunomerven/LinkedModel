*This file generates .csv files for use in SATIMViz
*Results are reported for key variables in 5 year intervals

*-------------------------------------------------------------------------------
*Calculations
*-------------------------------------------------------------------------------
*GDP
 Calc('GDP','Level',IGDP,'all',run,XC,tcr)= sum(TTRN,gdpdx(IGDP,XC,tcr,TTRN));

*GVA
 Calc('GVA','Level','all',ar,run,XC,tcr) = sum(TTRN,gdpx(ar,XC,tcr,TTRN));

*Production
 Calc('Production','Level','all',ar,run,XC,tcr) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),qax(a,XC,tcr,TTRN));

*Intermediate demand
 Calc('IntDem','Level',c,ar,run,XC,tcr) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),qintx(c,a,XC,tcr,TTRN));

*Employment
 Calc('Employment','Level','total',ar,run,xc,tcr) = SUM((flab,A,RD,TTRN)$ACTAGG(A,RD,AR), qfx(flab,a,rd,xc,tcr,TTRN));
 Calc('Employment','Level',flab,ar,run,xc,tcr) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR), qfx(flab,a,rd,xc,tcr,TTRN));

*Capital to Labour ratios
 Calc('capital/labour', 'ratio','all',ar,run,xc,tcr)$SUM((FLAB,A,RD,TTRN)$ACTAGG(A,RD,AR),qfx(flab,a,rd,xc,tcr,TTRN))
   =SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),qfx('fcap',a,rd,xc,tcr,TTRN))/SUM((FLAB,A,RD,TTRN)$ACTAGG(A,RD,AR),qfx(flab,a,rd,xc,tcr,TTRN));

*Factor returns
 Calc('Average factor returns','Level',f,'all',run,xc,tcr) = sum(TTRN,wfx(f,xc,tcr,TTRN));
 Calc('FacRet_SectDiff','level',f,ar,run,xc,tcr) = sum((a,rd,TTRN)$actagg(a,rd,ar),wfdistx(f,a,'nat',xc,tcr,TTRN));

*Trade
 Calc('Exports','Value','all',ar,run,xc,tcr) = sum((a,rd,TTRN)$actagg(a,rd,ar),sum(c$mac(a,c),exr0*qex(c,'rest',xc,tcr,TTRN)*pwe0(c,'rest')));
 Calc('Imports','Value','all',ar,run,xc,tcr) = sum((a,rd,TTRN)$actagg(a,rd,ar),sum(c$mac(a,c),exr0*qmx(c,'rest',xc,tcr,TTRN)*pwm0(c,'rest')));

*Competitiveness
 Calc('Export competitiveness','Index',c,'all',run,'base',tcr)$sum(TTRN,pdsx(c,'base',tcr,TTRN))
   = (sum(TTRN,pex(c,'rest','base',tcr,TTRN))/sum(TTRN,pdsx(c,'base',tcr,TTRN)))*100;

 Calc('Real exchange rate','Index','all','all',run,xc,tcr)=sum(TTRN, exrx(xc,tcr,TTRN));

*Prices
 Calc('ComPrice','level',c,'all',run,xc,tcr) = sum(TTRN,PQX(c,xc,tcr,TTRN));

*Income and consumption
 Calc('Income','level',ins,'all',run,xc,tcr) = sum(TTRN,yix(ins,xc,tcr,TTRN));

 Calc('Consumption','Level','Total',hr,run,xc,tcr)       = sum((c,h,TTRN)$HHDAGG(H,HR),qhx(c,h,xc,tcr,TTRN)*pq0(c));
 Calc('Consumption','Level','Food',hr,run,xc,tcr)        = sum((food,h,TTRN)$HHDAGG(H,HR),qhx(food,h,xc,tcr,TTRN)*pq0(food));
 Calc('Consumption','Level','Energy',hr,run,xc,tcr)      = sum((energy,h,TTRN)$HHDAGG(H,HR),qhx(energy,h,xc,tcr,TTRN)*pq0(energy));
 Calc('Consumption','Level','Transport',hr,run,xc,tcr)   = sum((transport,h, TTRN)$HHDAGG(H,HR),qhx(transport,h,xc,tcr,TTRN)*pq0(transport));
 Calc('Consumption','Level','Other',hr,run,xc,tcr)       = sum((other,h,TTRN)$HHDAGG(H,HR),qhx(other,h,xc,tcr,TTRN)*pq0(other));

*Inequality
 Calc('GINI','level','all','all',run,xc,tcr) = sum(TTRN, GINI(XC,tcr,TTRN));

*Time-varying coefficients
 Calc('ICA','level',c,ar,run,xc,tcr)     = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),icax(c,a,'nat',xc,tcr,TTRN));
 Calc('IVA','level','all',ar,run,xc,tcr) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),ivax(a,'nat',xc,tcr,TTRN));

*Investment
 Calc('ElecInv','level','all','all',run,xc,tcr) = sum(TTRN, einvcost(xc,tcr,TTRN));