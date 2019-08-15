*This file generates .csv files for use in SATIMViz
*Results are reported for key variables in 5 year intervals
*Sets are defined in 2simulation.inc as sets cannot be defined inside a loop

*GDP
 Calc('GDP','Level',IGDP,'all',RUN,XC,TC)= sum(TTRN,gdpdx(IGDP,XC,TC,TTRN));

*GVA
 Calc('GVA','Level','all',ar,RUN,XC,TC) = sum(TTRN,gdpx(ar,XC,TC,TTRN));

*Production
 Calc('Production','Level','all',ar,RUN,XC,TC) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),qax(a,XC,TC,TTRN));

*Intermediate demand
 Calc('IntDem','Level',c,ar,RUN,XC,TC) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),qintx(c,a,XC,TC,TTRN));

*Employment
 Calc('Employment','Level','total',ar,RUN,XC,TC) = SUM((flab,A,RD,TTRN)$ACTAGG(A,RD,AR), qfx(flab,a,rd,XC,TC,TTRN));
 Calc('Employment','Level',flab,ar,RUN,XC,TC) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR), qfx(flab,a,rd,XC,TC,TTRN));

*Capital to Labour ratios
 Calc('capital/labour', 'ratio','all',ar,RUN,XC,TC)$SUM((FLAB,A,RD,TTRN)$ACTAGG(A,RD,AR),qfx(flab,a,rd,XC,TC,TTRN))
   =SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),qfx('fcap',a,rd,XC,TC,TTRN))/SUM((FLAB,A,RD,TTRN)$ACTAGG(A,RD,AR),qfx(flab,a,rd,XC,TC,TTRN));

*Factor returns
 Calc('Average factor returns','Level',f,'all',RUN,XC,TC) = sum(TTRN,wfx(f,XC,TC,TTRN));
 Calc('FacRet_SectDiff','level',f,ar,RUN,XC,TC) = sum((a,rd,TTRN)$actagg(a,rd,ar),wfdistx(f,a,'nat',XC,TC,TTRN));

*Trade
 Calc('Exports','Level',c,'all',RUN,XC,TC) = sum(ttrn,qex(c,'rest',XC,TC,TTRN));
 Calc('Exports','Value','all',ar,RUN,XC,TC) = sum((a,rd,TTRN)$actagg(a,rd,ar),sum(c$mac(a,c),exr0*qex(c,'rest',XC,TC,TTRN)*pwe0(c,'rest')));
 Calc('Imports','Value','all',ar,RUN,XC,TC) = sum((a,rd,TTRN)$actagg(a,rd,ar),sum(c$mac(a,c),exr0*qmx(c,'rest',XC,TC,TTRN)*pwm0(c,'rest')));

*Competitiveness
 Calc('Export competitiveness','Index',c,'all',RUN,'base',TC)$sum(TTRN,pdsx(c,'base',TC,TTRN))
   = (sum(TTRN,pex(c,'rest','base',TC,TTRN))/sum(TTRN,pdsx(c,'base',TC,TTRN)))*100;

 Calc('Real exchange rate','Index','all','all',RUN,XC,TC)=sum(TTRN, exrx(XC,TC,TTRN));

*Prices
 Calc('ComPrice','level',c,'all',RUN,XC,TC) = sum(TTRN,PQX(c,XC,TC,TTRN));

*Income and consumption
 Calc('Income','level',ins,'all',RUN,XC,TC) = sum(TTRN,yix(ins,XC,TC,TTRN));

 Calc('Consumption','Level','Total',hr,RUN,XC,TC)       = sum((c,h,TTRN)$HHDAGG(H,HR),qhx(c,h,XC,TC,TTRN)*pq0(c));
 Calc('Consumption','Level','Food',hr,RUN,XC,TC)        = sum((food,h,TTRN)$HHDAGG(H,HR),qhx(food,h,XC,TC,TTRN)*pq0(food));
 Calc('Consumption','Level','Energy',hr,RUN,XC,TC)      = sum((energy,h,TTRN)$HHDAGG(H,HR),qhx(energy,h,XC,TC,TTRN)*pq0(energy));
 Calc('Consumption','Level','Transport',hr,RUN,XC,TC)   = sum((transport,h, TTRN)$HHDAGG(H,HR),qhx(transport,h,XC,TC,TTRN)*pq0(transport));
 Calc('Consumption','Level','Other',hr,RUN,XC,TC)       = sum((other,h,TTRN)$HHDAGG(H,HR),qhx(other,h,XC,TC,TTRN)*pq0(other));

*Inequality
 Calc('GINI','level','all','all',RUN,XC,TC) = sum(TTRN, GINI(XC,TC,TTRN));

*Time-varying coefficients
 Calc('ICA','level',c,ar,RUN,XC,TC)     = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),icax(c,a,'nat',XC,TC,TTRN));
 Calc('IVA','level','all',ar,RUN,XC,TC) = SUM((A,RD,TTRN)$ACTAGG(A,RD,AR),ivax(a,'nat',XC,TC,TTRN));

*Investment
 Calc('ElecInv','level','all','all',RUN,XC,TC) = sum(TTRN, einvcost(XC,TC,TTRN));

*-------------------------------------------------------------------------------

 GDP_MP(GDPMP_L1,GDPMP_L1D,GDPMP_L2,GDPMP_L2D,RUN,XC,TC)
         $YMAP (GDPMP_L1,GDPMP_L1D,GDPMP_L2,GDPMP_L2D)
                 = CALC('GDP','Level',GDPMP_L2,'ALL',RUN,XC,TC);

 GDP_FC(GVA_L1,GVA_L1D,GVA_L2,GVA_L2D,GVA_L3,GVA_L3D,GVA_L4,GVA_L4D,RUN,XC,TC)
         $AMAP (GVA_L1,GVA_L1D,GVA_L2,GVA_L2D,GVA_L3,GVA_L3D,GVA_L4,GVA_L4D)
                 = CALC('GVA','Level','all',GVA_L4,RUN,XC,TC);

 EMPLOYMENT(SKILL,Skill_D,GVA_L1,GVA_L1D,GVA_L2,GVA_L2D,GVA_L3,GVA_L3D,GVA_L4,GVA_L4D,RUN,XC,TC)
         $(AMAP(GVA_L1,GVA_L1D,GVA_L2,GVA_L2D,GVA_L3,GVA_L3D,GVA_L4,GVA_L4D) and SMAP(Skill, Skill_D))
                 = CALC('EMPLOYMENT','Level',SKILL,GVA_L4,RUN,XC,TC);

 CALC('INCOME','Level','xALLHHD','ALL',RUN,XC,TC) = SUM(H4P,CALC('INCOME','Level',H4P,'ALL',RUN,XC,TC));
 CALC('INCOME','Level','xPOOR','ALL',RUN,XC,TC)   = CALC('INCOME','Level','hhd-0','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-1','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-2','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-3','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-4','ALL',RUN,XC,TC);
 CALC('INCOME','Level','xxhhd-9','ALL',RUN,XC,TC) = CALC('INCOME','Level','hhd-91','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-92','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-93','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-94','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-95','ALL',RUN,XC,TC);
 CALC('INCOME','Level','xNPOOR','ALL',RUN,XC,TC)  = CALC('INCOME','Level','hhd-5','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-6','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-7','ALL',RUN,XC,TC)+CALC('INCOME','Level','hhd-8','ALL',RUN,XC,TC)+CALC('INCOME','Level','xxhhd-9','ALL',RUN,XC,TC);

 HH_INCOME(H_L1,H_L1D,H_L2,H_L2D,H_L3,H_L3D,H_L4,H_L4D,DESCRIPTION,RUN,XC,TC)
         $HMAP(H_L1,H_L1D,H_L2,H_L2D,H_L3,H_L3D,H_L4,H_L4D)
                 = SUM(H4P$(HMAP3(H_L4,H4P)),CALC('INCOME','Level',H4P,'ALL',RUN,XC,TC));

 HH_CONSUMPTION(COMMODITY,Commodity_D,H_L1,H_L1D,H_L2,H_L2D,H_L3,H_L3D,H_L4,H_L4D,RUN,XC,TC)
         $(HMAP(H_L1,H_L1D,H_L2,H_L2D,H_L3,H_L3D,H_L4,H_L4D) and CMAP(Commodity,Commodity_D))
                 = CALC('CONSUMPTION','Level',COMMODITY,H_L4,RUN,XC,TC);

*Combine klratio and inequality into one csv
 KLRATIOS(GVA_L1,GVA_L1D,GVA_L2,GVA_L2D,GVA_L3,GVA_L3D,GVA_L4,GVA_L4D,RUN,XC,TC)
         $AMAP (GVA_L1,GVA_L1D,GVA_L2,GVA_L2D,GVA_L3,GVA_L3D,GVA_L4,GVA_L4D)
                 = CALC('CAPITAL/LABOUR','Ratio','ALL',GVA_L4,RUN,XC,TC);

 INEQUALITY(RUN,XC,TC)
                 = CALC('GINI','Level','ALL','ALL',RUN,XC,TC);


*WRITE OUT FILES
 execute_unload "test.gdx"  GDP_MP GDP_FC EMPLOYMENT HH_INCOME HH_CONSUMPTION KLRATIOS INEQUALITY;

 execute 'gdxdump test format=CSV output=C:\SATIMGE_02\CGE_databases/GDP-Expenditure.csv symb=GDP_MP'
 execute 'gdxdump test format=CSV output=C:\SATIMGE_02\CGE_databases/GDP-Production.csv symb=GDP_FC'
 execute 'gdxdump test format=CSV output=C:\SATIMGE_02\CGE_databases/Employment.csv symb=employment'
 execute 'gdxdump test format=CSV output=C:\SATIMGE_02\CGE_databases/Income.csv symb=hh_income'
 execute 'gdxdump test format=CSV output=C:\SATIMGE_02\CGE_databases/Consumption.csv symb=hh_consumption'
 execute 'gdxdump test format=CSV output=C:\SATIMGE_02\CGE_databases/KLRATIOS.csv symb=klratios'
 execute 'gdxdump test format=CSV output=C:\SATIMGE_02\CGE_databases/INEQUALITY.csv symb=inequality'
