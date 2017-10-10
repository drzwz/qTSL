\l tsl.q
r:start[`:d:/tr;`user;`password];     
if[r[`errid]<>0;stop[];'`error_start];
/ gethdbdates[`cftaq]   removehdbdates[`cftaq;2015.05.05]
tsl2cftaq[(2015.05.05;2015.05.05);`IF`RB];
/退出!
stop[];

\
get `:d:/fe/hdb/2015.05.05/cftaq
sym ~  get`:d:/fe/hdb/sym

