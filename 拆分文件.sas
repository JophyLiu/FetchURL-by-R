proc sort data=sashelp.class out=test_1 nodupkey;by sex;run;  /*ȥ��(nodupkey);sort���ж��֣�����nodup,�Լ�����*/


data _null_;       /*��ֵ�����*/
        set test_1 end=last;
        call symput(compress("f_name"||(_n_)),strip(sex));
        if last then call symput("sum",strip(_n_));
run;

%put &sum.;
 %put &f_name2.;

%let sum=1;
%put &sum.;

%macro freq_one();    /*����ã�ʵ�ʹ��ܣ��ļ��Ĳ��*/
    %do i=1 %to &sum.;
      data  t_&i.;
           set  sashelp.class;
           if sex="&&f_name&i.." then output t_&i.;
      run;

    %end;
%mend;

%freq_one();
