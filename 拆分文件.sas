proc sort data=sashelp.class out=test_1 nodupkey;by sex;run;  /*去重(nodupkey);sort共有多种，例如nodup,以及排序*/


data _null_;       /*赋值宏变量*/
        set test_1 end=last;
        call symput(compress("f_name"||(_n_)),strip(sex));
        if last then call symput("sum",strip(_n_));
run;

%put &sum.;
 %put &f_name2.;

%let sum=1;
%put &sum.;

%macro freq_one();    /*宏调用（实际功能：文件的拆分*/
    %do i=1 %to &sum.;
      data  t_&i.;
           set  sashelp.class;
           if sex="&&f_name&i.." then output t_&i.;
      run;

    %end;
%mend;

%freq_one();
