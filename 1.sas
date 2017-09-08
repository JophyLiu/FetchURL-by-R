%let path=E:\Temptask_Jandy\_通用的导入程序;

filename flist pipe "dir   &path.\* /B";

data flist;
length filename $126;
infile flist dlm="|";
input filename ;
file_path="&path.\"||filename;
if index(filename,"SAS代码_导入文件"）=0；
if index(lowcase(filename),'.sas')=0;
if index(lowcase(filename),'.csv') or index(lowcase(filename),'.txt');
run;
filename flist clear;

data all;
LENGTH varl-var50 $124;
set flist;
infile in filevar=file_path dsd dlm=",|" missover firstobs=1 obs=100 end=NO_more LRECL=32767；
do while (NO_more=0);
input var1-var50;
output;
end;
run;

proc sort data=all   ;
by FILENAME;
run;

PROC TRANSPOSE DATA=ALL_TR;
BY FILENAME;
VAR _ALL_;
RUN;

data ALL_TR1;
set ALL_TR；
miss=cmiss(of col1-col100);
if miss=100 then delete;
if UPCASE(_NAME_)="FILENAME" THEN DELETE;
array col col2-col100;
do over col;
len=length(col);
if mod(len,2)=1 then len=len+1;
leng=max(len,leng);
end;
if leng<=2 then leng=124;
col1=ksubstr(col1,1,32);
leng_n=compress(put(leng,$16.));
DROP COL2-COL100 LEN MISS;
run;

DATA _null_;
set flist;
call symput("Filename"||strip(_n_),strip(filename));
call symput("filecode"||strip(_n_),strip(scan(filename,1,'.')));
call symput("totl"strip(_n_));
run;
%PUT &filecode1.;

%macro loop();
%do i=1 %to &totl ;
proc sql noprint;
select strip(_NAME_)||'   $'||leng_n into :name_len%left(&i.) separate by '   ' from ALL_TR1 where filename="&&filename&i..";
select strip(_NAME_)||"='"||strip(COL1)||"'" into :%nrquote(name_label%left (&i.)) separate by '   ' from ALL_TR1 where filename="&&file
name&i..";
select strip(_NAME_) into :name_input%left(&i.) separate by '   ' from ALL_TR1 where filename="&&filename&i..";
run;
quit;

%put &&name_len&i..;
%put &&name_label&i..;
%put &&name_input&i..;

data file1;
start="data  raw _&i."||'(label='||'"'||"&&filecode&i.."||'");';
len="length  "||"&&name_len&i..;";
lbel-"label &&name_label&i..;";
infle="infile  "||'"'||"&path.\&&filename&i.."||'"'||" dsd dlm=',|' missover firstobs=2 end=NO_more LRECL=32767 ;";
iput="input  &&name_input&i.. ;";
f_name="filename"||'="'||"&&filename&i.."||'";';
end="run;";
run;

data _null_;
file "&path.\SAS代码_导入文件&&filecode&i..txt" lrecl=32767;
set file1;
put start /len /lbel /infle /input/ f_name /end;
run;

%include "&path.\SAS代码_导入文件&&filename&i...txt" /lrecl=32767;
%end;

%mend:

%loop();





OPTION NOXWAIT;
OPTION COMPRESS=BINARY;
OPTION SOURCE;
OPTION SOURCE2;
OPTION NOTES;
OPTION ERRORS=0;

proc contents data = Creditcard out = dsn noprint;run;
proc sort data = Creditcard;by CustID;run;
%let path = F:\逻辑回归\emlib\新建文件夹     ;/*输出数据集存放路径*/
libname rank "&path.";

/*非连续变量*/
%let keep_norminal=%str(
AMBalance
CustIncome
TmWBank
TmAtAddress
UtilRate
);



/*连续变量以10月份的区间*/
/*对于连续型变量rank分组分成10组*/

proc printto log=" F:\逻辑回归\emlib\新建文件.log";
run;



libname rank "F:\逻辑回归\emlib\新建文件夹\rank";

%macro interval_rank(brand=jk,brand_name=);

data _null_;
set interval_var end=last;
call symput ("var"||strip(_n_),strip(varname));
if last then call symput("totl",strip(_n_));
run;

%put &var1. &totl.;

%do y=1 %to %totl.;
proc rank data=kd.Jk_model_201510(keep=mobile_no)   &&var&y..  ) out=rank.&&var&y.._rk_&brand_name.  ties=low  group=20;
var &&var&y..;
ranks &&var&y.._r;
run;

proc sort data=rank.&&var&y.._rk_&brand_name. out=&&var&y.._out;
by &&var&y.._r  &&var&y..;
run;


data   &&var&y.._out_1;
set    &&var&y.._out;
by &&var&y.._r &&var&y..;
if first.&&var&y.._r then do;flag_sort=1; output;end;
if last.&&var&y.._r then do;flag_sort=2; output;end;
run;

proc transpose data=&&var&y.._out_1 out&&var&y.._out_trsp prefix=s_;
ID flag_sort;
by &&var&y.._r;
var &&var&y..;
run;

data rank.&&var&y.._grp_&brand_name.;/*改部结果数据集过程，重命名，原为_rank_group*/
set &&var&y.._out _trsp;
lg=lag(s_2);
if _n_=1 then do; first=s_1;end=s_2;end;
else do; first =mean(s_1,lg);end=s_2;end;
range=compress("["||first||","||end||")");
label first="下区间"
end="上区间"
;
run;

proc sort data=rank.&&var&y.._rk_&brand_name. out=&&var&y.._rk_&brand_name. noudpkey;
by mobile_no;
run;

%end;

data rank=interval_all_&brand_name.;
merge %do y=1 %to &totl.;
&&var&y.._rk_&brand_name. (keep=mobile_no &&var&y.._r)
%end;
;
by mobile_no;
run;

/*step2. 组的上下限  区间合并*/
%do y=1 %to totl.;

proc sort data=rank.&&var&y.._grp_&brand_name.  out=&&var&y.._&brand_name._s;
by descending &&var&y.._r;
run;

data cs;
retain first end;
set &&var&y.._&brand_name._s;
ebd=lag(first);
run;

proc sort data=cs out=&&var&y.._&brand_name._ss;
by &&var&y.._r;


data &&var&y.._&brand_name._ss;
set &&var&y.._&brand_name._ss;
range=compress("["||first||","||end||")");
label first="下区间"
end="上区间"
;
run;

%end;

data rank.interval_all_grp_&brand_name._n;
length _name_ $32
set
%do y=1 %to &totl.;
&&var&y.._&brand_name._ss(keep=_NAME_ &&var&y.._r range rename=(&&var&y.._r=vargroup));
%end;
;
if vargroup=. then vargroup=-1;
vargroup_n=put(vargroup,$32.);
rename _name_=VARNAME
range=express;
vargroup_n=vargroup;
drop vargroup;
run;
%mend;

%interval_rank(brand=1,brand_name=kd);
proc printto;
run;

 /*连续变量以10月份的区间*/
/*对于连续变量rank分组分成20组*/

/*data budget;   */
/* sleeptime='01mar2013:08:00'dt-'01mar2013:00:00:00'dt;  */
/* time_calc=sleep(sleeptime,1);*/
/**/
/* put 'Calculation of sleep time:';*/
/*put sleeptime=' seconds'; */
/*run;*/



proc printto  log="E:\Temtask_jandy\_家宽模型\其他月份连续型变量rank_分组标签.log";
run;

%macro loop_month(brand_name=, dtime=);

data Conten ts_nmric;
set rank.interval_all_grp_&brand_name._n;
start=input(scan(substr(express,2,length(express)-2),1,',').best12.);
end=input(scan(substr(exoress,2,length(express)-2),2,','),best12.);
group=input(compress(vargroup),best12.);
run;

proc sort data=Contents_nmric our=Contents_nmric_s;
by VARNAME group;
run;

data _null_ ;
set Contents_nmric_s;
by VARNAME group ;
if first.VARNAME then do;n=0;d+1;end;
n+1;
call symput=("nname"||strip(d），strip(VARNAME));
call symput=("start"||strip(d)||"_"||strip(n),strip(start));
call symput=("end"||strip(d)||"_"||strip(n),strip(end));
call symput=("cg"||strip(d)||"_"||strip(n),strip(group));
if last.VARNAME then call symput("ntotl"||strip(d),strip(n));
run;


%put &&name1. &start1_1.  &&cg1_1.  &&end1_1.  &ntotl1.;


/*变量个数*/
proc sort data=Contents_nmric_s  out=varname_numbers nodupkey;
by VARNAME;
run;

data _null_;
set varname_numbers end=last;
call symput("nvar"||strip(_n_),strip(VARNAME));
if lst then call symput("ntotl",strip(_n_));
run;

%put &nvar1.  &ntotl.  &&nname&ntotl..  &&nvar&ntotl..;

/*变量分组替换*/

data kd.Jk_model_&dtime._r;
set kd.Jk_model_&dtime.;
/*区间型*/
%do i=1 %to &ntotl. ;
if upcase("&&nvar&i..")=upcase("&&nname&i..") then do;
%do j=1 %to &&ntotl&i..;
if j.=1 then do;
%put &&nvar&i..  &&end&i._&j..  woe_&&nvar&i.. &&cg&i._&j..;
/*if 0<=&&nvar&i..< &&end&i._&j..    then &&nvar&i..=&&nwoe&i._&j..;   */
if &&nvar&i..< &&end&i._&j..  then &&nvar&i..= &&cg&i._&j..;
end;
else if &j.<&&ntotl&i..   then do;
%put  &&nvar&i..  woe_&&nvar&i..   &&cg&i._&j..;
if   &&start&i._&j..<=&&nvar&i..< &&end&i._&j..   then &&nvar&i.._r= &&cg&i._&j..;
end;
else do;                                                       ;
%put &&nvar&i..  woe_&&nvar&i..   &&cg&i._&j.. ;
if &&nvar&i..>=&&start&i._&j..   then &&nvar&i.._r= &&cg&i._&j..;
end;
%end;
end;
%end;
run;

%mend;

%loop_month(brand_name=kd,dtime=201507);

proc printto;
run;
