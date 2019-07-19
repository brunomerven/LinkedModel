* Gams Coal model for producing coal supply curves by power plant
$SETGLOBAL DDfolder .\DD_Files\

* this is required when including multiplt declarations of parameters (as done in DD files)
$ONMULTI
$ONEMPTY

* Perform fixed declarations.
$BATINCLUDE %DDfolder%initsys.mod

* Declare the (system/user) empties.
$BATINCLUDE %DDfolder%initmty.mod ier

$INCLUDE %DDfolder%MMINIT.ANS


* Get data from DD files
$INCLUDE %DDfolder%BASE+REGION1.DD
$INCLUDE %DDfolder%TCH_PWR_A2+REGION1.DDS
$INCLUDE %DDfolder%TCH_PWR_WB_A+REGION1.DDS
$INCLUDE %DDfolder%SUP_COAL_MC+REGION1.DDS
$INCLUDE %DDfolder%SIM_COMPRICE+REGION1.DDS
$INCLUDE %DDfolder%COALSUPMODEL+REGION1.DDS
$INCLUDE %DDfolder%COAL_MATLA+REGION1.DDS
$INCLUDE %DDfolder%ESKOM_EFF+REGION1.DDS
$INCLUDE %DDfolder%MINCLE3_COST+REGION1.DDS
$INCLUDE %DDfolder%PWR_FOMS+REGION1.DDS
$INCLUDE %DDfolder%PWR_COAL_CF+REGION1.DDS
$INCLUDE %DDfolder%COAL_CAPSNEW+REGION1.DDS
$INCLUDE %DDfolder%AQM_RETRO_D+REGION1.DDS




