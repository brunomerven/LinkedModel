*Results for Tableau
*August 2019
$SETGLOBAL workingfolder C:\SATIMGE_02\
$SETGLOBAL outputgdx NewCoalSAM
$SETGLOBAL map MAPPRC.xlsx
$SETGLOBAL out "0tableau.xlsx"

Set
 AR
 A
 F
 C
 RD
 X
 T
 TC(T)
 TT(T)
 HR
 AY(*)
 RUN
 PRC
 FSATIM
 TechD
 S
 SS
 SSS
;

Parameter
 TVACT(AY,PRC)
 TVCAP(AY,PRC)
 EINVCOST(X,AY,TT)
 CALC(*,*,*,*,*,*,*)
;

$gdxin %workingfolder%%outputgdx%.gdx
$loaddc A AR X RD F C T TC TT HR AY PRC FSATIM TVACT TVCAP EINVCOST CALC
* RUN

Set
 MPRC(PRC,S,SS)
 RUN   /Base_NB-UCE-L/
;

$call "gdxxrw i=%map% o=map.gdx index=index!a12 checkdate"
$gdxin map.gdx
$load S SS SSS
$loaddc MPRC

SET
 TUSE(T)         /2012, 2015, 2020, 2025, 2030, 2035, 2040, 2045, 2050/
 AYUSE(AY)       /2012, 2015, 2020, 2025, 2030, 2035, 2040, 2045, 2050/
 YEAR(*)
 SECTOR(*)
;

$ontext
 YEAR(TUSE)=YES;
 YEAR(AYUSE)=YES;

 SECTOR(AR)=YES;
 SECTOR(A)=YES;
 SECTOR(SS)=YES;
$offtext
Parameter
 EProd(AYUSE,PRC,S,SS)
 ECap(AYUSE,PRC,S,SS)
 TABLEAUTAB(*,*,*,*,*,*,*,*)
;

 EProd(AYUSE,PRC,S,SS)$MPRC(PRC,S,SS)=TVACT(AYUSE,PRC);
 ECap(AYUSE,PRC,S,SS)$MPRC(PRC,S,SS)=TVCAP(AYUSE,PRC);

 TABLEAUTAB('EProd','Level','all',S,SS,PRC,RUN,AYUSE)
                 =EProd(AYUSE,PRC,S,SS);

 TABLEAUTAB('ECap','Level','all',S,SS,PRC,RUN,AYUSE)
                 =ECap(AYUSE,PRC,S,SS);

 TABLEAUTAB('GVA','Level','all','all',AR,'all',RUN,TUSE)
                 = Calc('GVA','Level','all',ar,RUN,'base',TUSE);

 TABLEAUTAB('IntDem','Level',c,AR,'all','all',RUN,TUSE)
                 = Calc('IntDem','Level',c,ar,RUN,'base',TUSE);

 TABLEAUTAB('Employment','Level','total',AR,'all','all',RUN,TUSE)
                 =  Calc('Employment','Level','total',ar,RUN,'base',TUSE);

 TABLEAUTAB('Exports','Value','all',AR,'all','all',RUN,TUSE)
                 =  Calc('Exports','Value','all',ar,RUN,'base',TUSE);

 TABLEAUTAB('Imports','Value','all',AR,'all','all',RUN,TUSE)
                 =  Calc('Imports','Value','all',ar,RUN,'base',TUSE);

 TABLEAUTAB('Real exchange rate','Index','all','all','all','all',RUN,TUSE)
                 = Calc('Real exchange rate','Index','all','all',RUN,'base',TUSE);

 TABLEAUTAB('ComPrice','level',c,'all','all','all',RUN,TUSE)
                 = Calc('ComPrice','level',c,'all',RUN,'base',TUSE);

 TABLEAUTAB('Consumption','Level','Total',hr,'all','all',RUN,TUSE)
                 = Calc('Consumption','Level','Total',hr,RUN,'base',TUSE);

Parameter XLTEST;

execute_unload "out.gdx" TABLEAUTAB
execute 'xlstalk.exe -m %out%';
 XLTEST = ERRORLEVEL;
IF(XLTEST = 1,
execute 'xlstalk.exe -c %out%';
);
IF(XLTEST = 2,
execute 'xlstalk.exe -s %out%';
);
execute 'gdxxrw.exe i=out.gdx o=%out% index=index!a2';
execute 'xlstalk.exe -o %out%';