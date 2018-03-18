//=============================kdb+天软接口=============================
// 功能：在kdb+中调用天软ODBC下载数据。若q为32位，天软odbc也必须是32位；若q为64位，则天软odbc也必须是64位
// 依赖：q/odbc.k, q/w32/odbc.dll,q/w32/snappy.dll；
// 用法：1.按照天软说明书配置好天软ODBC：http://www.tinysoft.com.cn/tsdn/helpdoc/display.tsl?id=15297
//       2.创建一个名为 tsl 的ODBC数据源
//       3.修改tsl2csbar1m.bat里的path，把天软TinyODBC.dll文件所在的路径加入PATH环境变量（否则找不到）
//       4.修改下面的配置信息，运行本脚本文件

mydaterange:(2010.01.01;.z.D);         //要下载数据的日期区间
dsn_user_password:`tsl`username`password;    //DSN名称；天软用户名；密码    `tsl`username`password

//=============================HDB=============================
//hdb相关路径、已保存日期等
system "d .zz";
hdbpathstr:{:ssr[getenv[`qhome];"\\";"/"],"/../hdb/"};              /  .zz.hdbpathstr[]  ended with "/" !!
hdbpath:{:hsym `$hdbpathstr[];};        / .zz.hdbpath[]
getpvpn:{if[()~.Q.pt;:`no_pt];{if[not x=`;.Q.cn `.[x]];}each {key[x] where value[x]~\:()}.Q.pn;(flip enlist[.Q.pf]!enlist .Q.pv),'flip .Q.pn}; //从分区读取各表的记录数。
gethdbdates:{[t]:asc @[get;(`$":",(-2_getenv[`qhome]),"\\data\\hdbinfo\\",string[t],"_dates");()];}; /  .zz.gethdbdates[`csbar0]
gethdbdatestbl:{[t]flip enlist[`dates]!enlist .zz.gethdbdates t};    //gethdbdatestbl`csbar0
sethdbdates:{[t;x]:$[14h=abs type x;(`$ssr[;"\\";"/"]":",(-2_getenv[`qhome]),"\\data\\hdbinfo\\",string[t],"_dates") set asc distinct gethdbdates[t],x;`para_must_be_date_or_datelist]};  /  sethdbdates[`csbar0;.z.D ]
delhdbdates:{[t;x]:$[14h=abs type x;(`$ssr[;"\\";"/"]":",(-2_getenv[`qhome]),"\\data\\hdbinfo\\",string[t],"_dates") set asc distinct (gethdbdates[t] except x);`para_must_be_date_or_datelist]};  / delhdbdates[`csbar0;.z.D]
//删除指定日期区间datarange的表tablename :       .zz.delhdbtable[(2016.01.01;2016.03.07) ;`etftaq]
delhdbtable:{[datarange;tablename]if[not `date in key `.;system "l ",hdbpathstr[]];
  mydates:.Q.pv where .Q.pv within datarange;
  {[dt;tblname]@[{hdel each x .Q.dd' key x;hdel x;}; ` sv (hdbpath[];`$string dt;tblname); `];}[;tablename] each mydates;
    };  
system "d .";
//代码转换	
sym2tslsym:{[mysym]if[0>type mysym;mysym:enlist mysym];mysymstr:string mysym;r:?[mysym like "*.S[HZ]";`$/:(-2#/:mysymstr),'(-3_/:mysymstr);?[mysym like "*.???";`$/:(-4_/:mysymstr);mysym]];:$[1=count r;first r;r];};   /  sym2tslsym `000001.SZ`000002.SH`IF1505.CFE`SZ000002
tslsym2sym:{[mysym]mysym:upper mysym;if[0>type mysym;mysym:enlist mysym];mysymstr:string mysym;:`$/:(2_/:mysymstr),'".",/:(2#/:mysymstr)};     /   tslsym2sym `SZ000001`SH600036`CF0411`if1505`if1234


/下载股票1分钟数据并保存到hdb
0N!(.z.T;`start...); 
system "l odbc.k";
//如果.odbc.open出错，可能是：tsl数据源没有建立或配置错误或版本错误
h:.odbc.open dsn_user_password;
//mysymlist:exec Expr1 from update `$Expr1 from .odbc.eval[h]"return getbk('A\271\311');";   // A\271\311 = A股 ，中文须为GBK编码
tradedates:exec Expr1 from .odbc.eval[h]"begt:=inttodate(20100101);endt:=now();return spec(specdate(nday3(tradedays(begt,endt),sp_time()),endt),'SH000001');"; 
tradedates:`date$/:`float$/:tradedates-36526e;
mydates:tradedates[where tradedates within mydaterange]; /指定日期区间内的交易日
mydates:desc mydates except .zz.gethdbdates[`csbar1m] /计算实际需要下载数据的日期
ii:0;
do[count mydates;mydate:mydates[ii]; filepath:hsym`$.zz.hdbpathstr[],(string mydate),"/csbar1m/";MYTBL:();0N!(.z.T;`csbar1m;mydate);
	r:@[.odbc.eval[h];"Setsysparam(pn_cycle(),cy_1m());return select TimeToStr(timeof(['date'])) as 'time',['stockid'] as 'sym',['open'] as 'open',['high'] as 'high',['low'] as 'low',['price'] as 'close',['vol'] as 'volume',['amount'] as 'openint' from markettable datekey inttodate(",ssr[string mydate;".";""],") to inttodate(",ssr[string mydate;".";""],")+0.999 of getbk('A\271\311')  end;";`];
	if[98h=type r;(filepath;17;3;0) set .Q.en[.zz.hdbpath[]] update `p#sym from `sym`time xasc select ("T"$/:time)-00:01,tslsym2sym`$sym,`real$open,`real$high,`real$low,`real$close,`real$volume,`real$openint from r;.zz.sethdbdates[`csbar1m;mydate]];
 ii+:1];
.Q.chk[.zz.hdbpath[]];
@[.odbc.close;h;`];
0N!(.z.T;`finished);