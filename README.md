# qTSL
kdb+/q interface for TinySoft


# ����

    ��kdb+�е�������TSL(http://www.tinysoft.com.cn)��������밲װ32λ�汾������

# ����

	q/tsl.q
	
	qtsl.dll�������������Ŀ¼�¶�����w32�£�
	
	q/w32/msvcp120.dll, q/w32/msvcr120.dll  q/w32/zlibwapi.dll

# �÷�

1.��һ��ʹ��ǰ����qtsl.dll���Ƶ�����װĿ¼��TSExpert.exe����Ŀ¼��!!!

2.���ر��ű��ļ��� \l tsl.q

3. �������������: start[`$":d:/tr";`user;`password] ,�����ֱ�Ϊ��������Ŀ¼`$":d:/tr"���û���user������password;

4. ����tick���ݲ����浽(fe)\hdb\���ݿ⣺tsl2cftaq[(2015.05.01;2015.05.15); `IF`RB],��һ������Ϊ����list,��ʾ�����ظ����������ڵ�����(��ĳ�����������أ��������ظ������ݣ����ڶ�������ΪƷ�ֻ��Լ���룬֧���磺(1) `IF   (2)`IF1505  (3) `IF1505`RB  (4) `IF`RB

5. �Ͽ����ӣ�stop[]��ʹ�ý�����Ҫ�Ͽ����ӣ�����

6. ������Ҫʹ�������������� 1��ִ��tsl��䣺runtsl `$"..."  ��2����������tsl.q���룩����: getcfsyms,getcftaq


#  ��ά�������£�Դ���SRC