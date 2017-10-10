//=============================kdb+天软接口=============================
// 功能：在kdb+中调用天软TSL，天软必须安装32位版本！！！
// 依赖：q/tsl.q, qtsl.dll（保存在天软根目录下而不是w32下） ,   q/w32/msvcp120.dll, q/w32/msvcr120.dll  q/w32/zlibwapi.dll
// 用法：1.第一次使用前，把qtsl.dll复制到天软安装目录（TSExpert.exe所在目录）!!!
//       2.加载本脚本文件： \l tsl.q
//       3. 连接天软服务器: start[`$":d:/tr";`user;`password] ,参数分别为天软所在目录`$":d:/tr"、用户名user、密码password;
//       4. 下载tick数据并保存到(fe)\hdb\数据库：tsl2cftaq[(2015.05.01;2015.05.15); `IF`RB],第一个参数为日期list,表示将下载该日期区间内的数据(若某日数据已下载，则不再下载该日数据），第二个参数为品种或合约代码，支持如：(1) `IF   (2)`IF1505  (3) `IF1505`RB  (4) `IF`RB
//       5. 断开连接：stop[]，使用结束后要断开连接！！！
//       6. 根据需要使用其它函数，如 1）执行tsl语句：runtsl `$"..."  ，2）其它（见以下代码），如: getcfsyms,getcftaq
//====================================================================================
.tsl.apifuncs:`start`stop`isconnected`islogined`runtsl_sym`runtsl_xml`runtsl;
start:{[tslpath;user;password]if[not all (3#-11h)=type each (tslpath;user;password);:`errid`errmsg`data!(-1j;`arg_type_err;0j)];
     .tsl.qtslpath:` sv tslpath,`qtsl; if[-11h<>type key `$(string .tsl.qtslpath),".dll";:`errid`errmsg`data!(-1j;`qtsl.dll_not_in_tsl_folder;0j)];
    .tsl.apifuncs {.tsl[x] : .tsl.qtslpath 2:(x;y);}' (count .tsl.apifuncs)#1;
    r:`errid`errmsg`data!.tsl.start[(`tsl.tinysoft.com.cn;443i;user;password;::)];0N!(.z.T;r);:r;}; /连接服务器  
stop:{[]r:`errid`errmsg`data!.tsl.stop[];0N!(.z.T;r);:r;}; /断开服务器连接
isconnected:{.tsl.isconnected[]};islogined:{.tsl.islogined[]};
/运行tsl,返回多种类型
runtsl:{[tsl]if[-11h<>type tsl;:`errid`errmsg`data!(-1j;`arg_type_err;0j)];
  :{[r] if[r[`errid]<>0;:r];if[4>count r[`data];:r]; if[(2+(r[`data][0])*r[`data][1])<>count r[`data];:r]; mycolsname:lower`$/:string (r[`data][1])#2_ r[`data]; 
  :`errid`errmsg`data!(r[`errid];r[`errmsg];flip mycolsname!flip (r[`data][0]-1i;r[`data][1]) # (2+r[`data][1])_ r[`data]);} `errid`errmsg`data!.tsl.runtsl[tsl]; };
/返回symbol
runtsl_sym:{[tsl]if[-11h<>type tsl;:`errid`errmsg`data!(-1j;`arg_type_err;0j)];r:`errid`errmsg`data!.tsl.runtsl_sym[tsl];:r;};
/返回xml
runtsl_xml:{[tsl]if[-11h<>type tsl;:`errid`errmsg`data!(-1j;`arg_type_err;0j)];r:`errid`errmsg`data!.tsl.runtsl_xml[tsl];:r;};
/[中文要特别小心：如果用\l加载本脚本，直接输入中文其实际编码取决于脚本文件的编码，对于GBK文字，使用以下直接编码！！]
CFEstr:"\326\320\271\372\275\360\310\332\306\332\273\365\275\273\322\327\313\371";
SHFstr:"\311\317\272\243\306\332\273\365\275\273\322\327\313\371";
DCEstr:"\264\363\301\254\311\314\306\267\275\273\322\327\313\371";
CZCstr:"\326\243\326\335\311\314\306\267\275\273\322\327\313\371";
/读期货合约列表
getcfsyms:{r:{[r]:$[r[`errid]<>0;r;
               `errid`errmsg`data!(r[`errid];r[`errmsg];update sym:?[ex like "\326\320\271\372\275\360\310\332*";`$/:(string sym),\:".CFE";?[ex like "\311\317\272\243*";`$/:(string sym),\:".SHF";?[ex like "\264\363\301\254*";`$/:(string sym),\:".DCE";?[ex like "\326\243\326\335*";`$/:(string sym),\:".CZC";sym]]]] from 
                    update sym:upper exsym, ("D"$/:string `int$`float$firstdate),("D"$/:string `int$`float$lastdate),`$string ex from r[`data])
                ]}runtsl`$"return select ['stockid'] as 'exsym',['\261\344\266\257\310\325'] as 'firstdate',['\327\356\272\363\275\273\322\327\310\325'] as 'lastdate',['\311\317\312\320\265\330'] as 'ex' from infotable 703 of getbk('",CFEstr,";",SHFstr,";",DCEstr,";",CZCstr,"') end;";
          .tsl.cfsyms : $[r[`errid]=0;r[`data];([]exsym:`$();firstdate:`date$();lastdate:`date$();ex:`$();sym:`$())]; :r};     /        getcfsyms[]           
sym2tslsym:{[mysym]if[0>type mysym;mysym:enlist mysym];mysymstr:string mysym;r:?[mysym like "*.S[HZ]";`$/:(-2#/:mysymstr),'(-3_/:mysymstr);?[mysym like "*.???";`$/:(-4_/:mysymstr);mysym]];:$[1=count r;first r;r];};   /  sym2tslsym `000001.SZ`000002.SH`IF1505.CFE`SZ000002
tslsym2sym:{[mysym]mysym:upper mysym;if[0>type mysym;mysym:enlist mysym];mysymstr:string mysym;r:?[mysym like "S[HZ]*";`$/:(2_/:mysymstr),'".",/:(2#/:mysymstr);[if[not `cfsyms in key `.tsl;getcfsyms[]];mysym^((upper .tsl.cfsyms[`exsym])!.tsl.cfsyms[`sym])[mysym] ]];:$[1=count r;first r;r];};     /   tslsym2sym `SZ000001`SH600036`CF0411`if1505`if1234

/读股票带盘口的tick数据   sym_array_str 为能够生成证券数组的tsl字符串，如："'SZ000001'" 或 "array('SZ000001','SZ000002)"或 "getbk('A股;上证ETF;深证ETF')"(注意中文GBK编码）
/   r: getcstaq[2015.05.08;"'SZ000001'"]        r: getcstaq[2015.05.08;"array('SZ000001','SH600036')"]                  r`errid   meta   r`data
getcstaq:{[mydate;sym_array_str]if[-14h<>type mydate;'`mydate_error];  mydatestr:(string mydate)_/4 6;
    abstr:" , ['buy1'] as 'bid',['bc1'] as 'bsize',['sale1'] as 'ask',['sc1'] as 'asize' ",raze{xx:string x;:",['buy",xx,"'] as 'bid",xx,"',","['bc",xx,"'] as 'bsize",xx,"',","['sale",xx,"'] as 'ask",xx,"',","['sc",xx,"'] as 'asize",xx,"'"}each 2+til 4;
    :{[r]:$[r[`errid]=0;`errid`errmsg`data!(r[`errid];r[`errmsg];update "D"$/:string date,"T"$/:string time,tslsym2sym sym from r[`data]);r];}runtsl `$"return select DateToStr(dateof(['date'])) as 'date',TimeToStr(timeof(['date'])) as 'time',['stockid'] as 'sym',['sectional_yclose'] as 'prevclose',['sectional_open'] as 'open',['sectional_high'] as 'high',['sectional_low'] as 'low',['price'] as 'close',['sectional_vol'] as 'volume',['sectional_amount'] as 'openint'"
    ,abstr,"  from tradetable datekey inttodate(",mydatestr,") to inttodate(",mydatestr,")+0.999 of ",sym_array_str,"  end;";  };
/读期货带盘口的tick数据   product 形式如: 1) `IF   2)`IF1505  3) `IF1505`RB  4) `IF`RB          r: getcftaq[2015.05.08;`IF1505]     r: getcftaq[mydate:.z.D;product:`IF1505]      r: getcftaq[mydate:.z.D;product:`]                r`errid   meta   r`data
getcftaq:{[mydate;product]if[-14h<>type mydate;'`mydate_error];  mydatestr:(string mydate)_/4 6;
    productstr:$[-11h=type product;$[product=`;"";" where (thisrow like '^",(string product),"')"];11h=type product;" where (thisrow like '^",(string product[0]),"')",raze{" or (thisrow like '^",(string x),"')"}each 1_product;'`product_error]; 
    mysymstr:"(sselect thisrow from getbk('",CFEstr,";",SHFstr,";",DCEstr,";",CZCstr,"') ",productstr,"  end)";
    abstr:" , ['buy1'] as 'bid',['bc1'] as 'bsize',['sale1'] as 'ask',['sc1'] as 'asize' ",raze{xx:string x;:",['buy",xx,"'] as 'bid",xx,"',","['bc",xx,"'] as 'bsize",xx,"',","['sale",xx,"'] as 'ask",xx,"',","['sc",xx,"'] as 'asize",xx,"'"}each 2+til 4;
    :{[r]:$[r[`errid]=0;`errid`errmsg`data!(r[`errid];r[`errmsg];update "D"$/:string date,"T"$/:string time,tslsym2sym sym from r[`data]);r];}runtsl `$"return select DateToStr(dateof(['date'])) as 'date',TimeToStr(timeof(['date'])) as 'time',['stockid'] as 'sym',['sectional_yclose'] as 'prevclose',['sectional_open'] as 'open',['sectional_high'] as 'high',['sectional_low'] as 'low',['price'] as 'close',['sectional_vol'] as 'volume',['cjbs'] as 'openint'"
    ,abstr,"  from tradetable datekey inttodate(",mydatestr,") to inttodate(",mydatestr,")+0.999 of ",mysymstr,"  end;";  };

/一些工具函数
hdbpathstr:{:ssr[ssr[getenv[`qhome];"\\q";""];"\\";"/"],"/hdb/"};               // path for saving the data,              ended with "/" !!             hdbpathstr[]
hdbpath:{:hsym `$hdbpathstr[];};        / hdbpath[]
getcstaqdates:{:@[get;(` sv hdbpath[],`cstaq_dates);()];}; /  getcstaqdates[]
setcstaqdates:{:$[14h=abs type x;(` sv hdbpath[],`cstaq_dates) set asc distinct getcstaqdates[],x;`para_must_be_date_or_datelist]};  /  setcstaqdates[ .z.D-1 ]
removecstaqdates:{:$[14h=abs type x;(` sv hdbpath[],`cstaq_dates) set asc distinct (getcstaqdates[] except x);`para_must_be_date_or_datelist]};  / removecstaqdates[.z.D-1]
resetcstaqdates:{:$[14h=type x;(` sv hdbpath[],`cstaq_dates) set x;`para_must_be_date_list]}; 
getcftaqdates:{:@[get;(` sv hdbpath[],`cftaq_dates);()];}; /  getcftaqdates[]
setcftaqdates:{:$[14h=abs type x;(` sv hdbpath[],`cftaq_dates) set asc distinct getcftaqdates[],x;`para_must_be_date_or_datelist]};  /  setcftaqdates[ .z.D-1 ]
removecftaqdates:{:$[14h=abs type x;(` sv hdbpath[],`cftaq_dates) set asc distinct (getcftaqdates[] except x);`para_must_be_date_or_datelist]};  / removecftaqdates[.z.D-1]
resetcftaqdates:{:$[14h=type x;(` sv hdbpath[],`cftaq_dates) set x;`para_must_be_date_list]}; 

gethdbdates:{[t]:@[get;(` sv hdbpath[],`$(string t),"_dates");()];}; /  gethdbdates[`csbar0]
sethdbdates:{[t;x]:$[14h=abs type x;(` sv hdbpath[],`$(string t),"_dates") set asc distinct gethdbdates[t],x;`para_must_be_date_or_datelist]};  /  sethdbdates[`csbar0;.z.D ]
removehdbdates:{[t;x]:$[14h=abs type x;(` sv hdbpath[],`$(string t),"_dates") set asc distinct (gethdbdates[t] except x);`para_must_be_date_or_datelist]};  / removehdbdates[`csbar0;.z.D]
resethdbdates:{[t;x]:$[14h=type x;(` sv hdbpath[],`$(string t),"_dates") set x;`para_must_be_date_list]}; 

/下载股票taq数据并保存到hdb
tsl2cstaq:{[mydaterange;mysymlist]  "usage: mydaterange 形式如(.z.D-1;.z.D) ; ";             / mydaterange:(.z.D-1;.z.D)
    /mysymlist:`SZ000001`SH600036;    //根据需要修改,tsl格式 
    if[14h<>type mydaterange;:`error_mydaterange_type];if[11h<>abs type mysymlist;:`error_mysymlist_type];
    $[-11h=type mysymlist;mysymlist:enlist mysymlist];
    r:runtsl`$"begt:=inttodate(20100101);endt:=now();return spec(specdate(nday3(tradedays(begt,endt),sp_time()),endt),'SH000001');"; if[ r[`errid]<>0;:`error_tradedates]; tradedates:`date$/:`float$/:r[`data]-36526e;    /交易日
    mydates:tradedates[where tradedates within mydaterange]; /指定日期区间内的交易日
    mydates:mydates except getcstaqdates[]; /计算实际需要下载数据的日期
    /下载数据并保存到hdb
    ii:0;do[count mydates;mydate:mydates[ii]; cstaqpath:hsym`$hdbpathstr[],(string mydate),"/cstaq/";
            cc:0;do[count mysymlist;mysym:mysymlist[cc]; mysymstr:"'",(string mysym),"'";if[not isconnected[];0N!(.z.T;`disconnected);:()];
                    r:{[r]if[r[`errid]<>0;:r];:`errid`errmsg`data!(r[`errid];r[`errmsg];update bid6:0e,bsize6:0e,ask6:0e,asize6:0e,bid7:0e,bsize7:0e,ask7:0e,asize7:0e,bid8:0e,bsize8:0e,ask8:0e,asize8:0e,bid9:0e,bsize9:0e,ask9:0e,asize9:0e,bid10:0e,bsize10:0e,ask10:0e,asize10:0e 
                    from delete date from r[`data]);}getcstaq[mydate;mysymstr];0N!(.z.T;`tsl2cstaq;mydate;mysym); 
                $[r[`errid]=0;  $[cc=0; (cstaqpath;17;2;6) set .Q.en[hdbpath[]]  delete date from r[`data];cstaqpath upsert .Q.en[hdbpath[]] delete date from r[`data] ];[0N!(.z.T;`error_getcstaq_stopped;mydate;mysym;r);:()]];
                cc+:1]; @[cstaqpath;`sym;`p#];
         setcstaqdates[mydate];ii+:1];
      .Q.chk[hdbpath[]];
    };

/下载期货taq数据并保存到hdb
tsl2cftaq:{[mydaterange;mysymlist]  "usage: mydaterange 形式如(.z.D-1;.z.D) ;  mysymlist 形式如: 1) `IF   2)`IF1505  3) `IF1505`RB  4) `IF`RB";
    if[not islogined[];:`error_pls_start_it_firstly];
    /交易日
    r:runtsl`$"begt:=inttodate(20100101);endt:=now();return spec(specdate(nday3(tradedays(begt,endt),sp_time()),endt),'SH000001');"; if[ r[`errid]<>0;:`error_tradedates];
    tradedates:`date$/:`float$/:r[`data]-36526e;
    /指定日期区间内的交易日
    mydates:tradedates[where tradedates within mydaterange];
    /计算实际需要下载数据的日期
    mydates:mydates except getcftaqdates[];
    /期货合约代码列表,这里只用于代码格式转换   [中文要特别小心：如果用\l加载本脚本，要注意中文的编码！！]
    if[(r:getcfsyms[])[`errid]<>0;:`error_getcfsyms_fails];
    /下载数据并保存到hdb
    ii:0;do[count mydates;mydate:mydates[ii]; 0N!(.z.T;`getcftaq;mydate;`of;mydaterange);if[not isconnected[];0N!(.z.T;`disconnected);:()]; r:getcftaq[mydate;mysymlist];
         $[r[`errid]=0; [(hsym`$hdbpathstr[],(string mydate),"/cftaq/";17;2;6) set .Q.en[hdbpath[]] @[;`sym;`p#] `sym xasc update tslsym2sym sym from delete date from r[`data]; setcftaqdates[mydate] ];
             [0N!(.z.T;mydate;`error_getcftaq_stopped;r[`errmsg]);:()]];
         ii+:1];
     .Q.chk[hdbpath[]];
    stop[];
    };

\
/  \l tsl.q
start[`:d:/tr;`uid;`pwd];
tsl2cftaq[(2015.05.05;2015.05.11);`IF];
tsl2cstaq[(2015.05.05;2015.05.06)];
stop[];
\
islogined[]
r:runtsl[`$"data:=( GETBK('深证A股') );data:=`data;renamefield(data,0,'sym');   return data;"];r`data
r:runtsl[`$"data:=( GETBK('深证A股') );return select thisrow as 'sym' from data end;"];r`data
r:runtsl[`$"return `array('代码':GETBK('深证A股'));"];r`data
getcftaqdates[]   removecftaqdates[.z.D-1]
\l d:/fe/hdb
meta select   from cftaq where date=2015.05.04
