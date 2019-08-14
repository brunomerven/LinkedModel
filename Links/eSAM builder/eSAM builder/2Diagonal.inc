*This include file takes the SAM and transforms it into a diagonal SAM.
*The transport sector's output is also disaggregated between land and other.

*Treat mining differently to other collapsing to avoid higher coal consumption
*by sectors than should be

 SAM('acoal','ccoal')=SAM('acoal','ccoal')+SAM('acoal','cbsrv');
 SAM('agold','cmore')=SAM('agold','cmore')+SAM('agold','cbsrv');
 SAM('amore','cmore')=SAM('amore','cmore')+SAM('aosrv','cmore')
                         +SAM('amore','cbsrv');
 SAM('amine','cmine')=SAM('amine','cmine')+SAM('aosrv','cmine')
                         +SAM('amine','cbsrv')+SAM('amine','celec');

 SAM('cosrv','amore')=SAM('cosrv','amore')+SAM('aosrv','cmore');
 SAM('cosrv','amine')=SAM('cosrv','amine')+SAM('aosrv','cmine');

 SAM('aosrv','cosrv')=SAM('aosrv','cosrv')+SAM('aosrv','cmore')
                         +SAM('aosrv','cmine');

 SAM('aosrv','cmore')=0;
 SAM('aosrv','cmine')=0;

 SAM('absrv','cbsrv')=SAM('absrv','cbsrv')+SAM('acoal','cbsrv')
                         +SAM('agold','cbsrv')+SAM('amore','cbsrv')
                         +SAM('amine','cbsrv');

 SAM('ccoal','absrv')=SAM('ccoal','absrv')+SAM('acoal','cbsrv');
 SAM('cmore','absrv')=SAM('cmore','absrv')+SAM('amore','cbsrv')
                         +SAM('agold','cbsrv');
 SAM('cmine','absrv')=SAM('cmine','absrv')+SAM('amine','cbsrv');

 SAM('acoal','cbsrv')= 0;
 SAM('agold','cbsrv')= 0;
 SAM('amore','cbsrv')= 0;
 SAM('amine','cbsrv')= 0;

 SAM('ccoal','amore')= SAM('ccoal','amore')-SAM('amore','ccoal');
 SAM('amore','ccoal')= 0;

 SAM('cmine','aelec')= SAM('cmine','aelec')+SAM('amine','celec');
 SAM('aelec','celec')= SAM('aelec','celec')+SAM('amine','celec');

 SAM('amine','celec')= 0;

*Want to maintain multiple product production by transport
 SAM('altrp','cptrp')=SAM('altrp','cptrp')+SAM('aosrv','cptrp');
 SAM('altrp','cftrp')=SAM('altrp','cftrp')+SAM('aosrv','cftrp');

 SAM('cosrv','altrp')=SAM('cosrv','altrp')+SAM('aosrv','cptrp')+SAM('aosrv','cftrp');

 SAM('aosrv','cosrv')=SAM('aosrv','cosrv')+SAM('aosrv','cptrp')+SAM('aosrv','cftrp');

 SAM('aosrv','cptrp')=0;
 SAM('aosrv','cftrp')=0;

 SAM('absrv','cbsrv')=SAM('absrv','cbsrv')+SAM('altrp','cbsrv')+SAM('awtrp','cbsrv')
                         +SAM('aatrp','cbsrv')+SAM('atrps','cbsrv');

 SAM('cftrp','absrv')=SAM('cftrp','absrv')+SAM('altrp','cbsrv')+SAM('awtrp','cbsrv')
                         +SAM('aatrp','cbsrv');

 SAM('ctrps','absrv')=SAM('ctrps','absrv')+SAM('atrps','cbsrv');

 SAM('altrp','cftrp')=SAM('altrp','cftrp')+SAM('altrp','cbsrv');
 SAM('awtrp','cftrp')=SAM('awtrp','cftrp')+SAM('awtrp','cbsrv');
 SAM('aatrp','cftrp')=SAM('aatrp','cftrp')+SAM('aatrp','cbsrv');

 SAM('atrps','ctrps')=SAM('atrps','ctrps')+SAM('atrps','cbsrv');

 SAM('altrp','cbsrv')=0;
 SAM('awtrp','cbsrv')=0;
 SAM('aatrp','cbsrv')=0;
 SAM('atrps','cbsrv')=0;

 SAM(C,A)$(NOT MAC(A,C)) = SAM(C,A)+ SUM((AP,CP)$(MAC(AP,C) AND MAC(A,CP)), SAM(AP,CP));
 SAM(A,C)$(NOT MAC2(A,C)) = 0;
 SAM(A,C)$(MAC(A,C) AND NOT MAC2(A,C)) = SUM(ACNT, SAM(ACNT,A));

 SAM('TOTAL',ACNT)=SUM(ACNTP,SAM(ACNT,ACNTP));
 SAM(ACNT,'TOTAL')=SUM(ACNTP,SAM(ACNTP,ACNT));
 SAM('TOTAL','TOTAL')=0;
