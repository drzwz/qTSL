# qTSL
kdb+/q interface for TinySoft


*kdb+读取天软TSL(http://www.tinysoft.com.cn)数据，天软已提供ODBC接口，建议采用ODBC接口读取，例子见 qTSLODBC 目录。*





#  ==================================================================================

#  以下为旧版，不推荐使用。

#  ==================================================================================

# 旧版功能

    在kdb+中调用天软TSL(http://www.tinysoft.com.cn)，天软必须安装32位版本！！！

# 旧版依赖

	q/tsl.q
	
	qtsl.dll（保存在天软根目录下而不是w32下）
	
	q/w32/msvcp120.dll, q/w32/msvcr120.dll  q/w32/zlibwapi.dll

# 旧版用法

1.第一次使用前，把qtsl.dll复制到天软安装目录（TSExpert.exe所在目录）!!!

2.加载本脚本文件： \l tsl.q

3. 连接天软服务器: start[\`$":d:/tr";\`user;\`password] ,参数分别为天软所在目录\`$":d:/tr"、用户名user、密码password;

4. 下载tick数据并保存到(fe)\hdb\数据库：tsl2cftaq[(2015.05.01;2015.05.15); \`IF\`RB],第一个参数为日期list,表示将下载该日期区间内的数据(若某日数据已下载，则不再下载该日数据），第二个参数为品种或合约代码，支持如：(1) \`IF   (2)\`IF1505  (3) \`IF1505\`RB  (4) \`IF\`RB

5. 断开连接：stop[]，使用结束后要断开连接！！！

6. 根据需要使用其它函数，如 1）执行tsl语句：runtsl \`$"..."  ，2）其它（见tsl.q代码），如: getcfsyms,getcftaq


**不维护，源码见SRC**
