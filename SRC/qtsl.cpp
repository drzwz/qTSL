// qwind.cpp : 定义 DLL 应用程序的导出函数。
#include "stdafx.h"
#include <winsock2.h>
#include "k.h"

using   namespace   std;
#pragma comment(lib, "q.lib")
#pragma comment(lib, "pubkrnl.lib") 
#pragma comment(lib, "tslkrnl.lib") 
#pragma comment(lib, "TSLClient.lib") 
#pragma comment(lib, "TT_RUNLOCALTSL.lib") 
#pragma comment(lib, "CommKrnl.lib") 
#define TSL_TINT	0
#define TSL_TNUMBER	1
#define TSL_TSZSTRING 2
#define TSL_TUSERDATA	3
#define TSL_TREF		4
#define TSL_TTABLE	5
#define TSL_TSTRING	6

extern "C" {
	__declspec(dllimport) void TSL_Free(void* P);
	__declspec(dllimport) int RunTSLViaString(bool xml, bool RunClear, char* envIn, char* Content, char** sOut);
	__declspec(dllimport) int ScriptGo(void* L, char* Content, void* sOut);

	__declspec(dllimport) int tslLoginServer(char* UserName, char* Password, char* ErrBuf, int ErrBufLen);
	__declspec(dllimport) void SendExecuteAndWait(int L, char* ExecStr, int SysParam, int oResult, int o, int errobj, bool Online);
	__declspec(dllimport) void tslSetSocketInfo(char* Address, int Port, void* pProxyInfo);
	__declspec(dllimport) int tslConnectSocket();
	__declspec(dllimport) void tslDisconnectSocket();
	__declspec(dllimport) bool tslGetSocketConnected();
	__declspec(dllimport) bool tslGetLogined();

	__declspec(dllimport) void* GetGlobalL();
	__declspec(dllimport) void* TSL_NewObject();
	__declspec(dllimport) void TSL_FreeObject(void* v);
	__declspec(dllimport) double tslObjAsReal(void *v);
	__declspec(dllimport) char* tslObjAsString(void *v);
	__declspec(dllimport) int ScriptGo(void* L, char* Content, void* sOut);
	__declspec(dllimport) int TSL_HashGetN(void *v);
	__declspec(dllimport) void* TSL_HashGetInt(void* v, int n);
	__declspec(dllimport) void* TSL_HashGetSZString(void* L, void* v, char* s);
	__declspec(dllimport) void* TT_GetHash(void* o);
	__declspec(dllimport) int TT_GetStringHashCount(void *o);
	__declspec(dllimport) void* TT_GetStringHashObj(void *o, int n);
	__declspec(dllimport) int TT_GetObjectType(void* o);

	__declspec(dllimport) void*  TT_GetIntHashObj(void* o, int n);

}

#define KXAPI(f) extern "C" __declspec(dllexport) K __cdecl f(K x)
#define CheckX(m) if (x->t != 0) R kj(-1);if (x->n < m ) R kj(-1)

//==============================================数据接口============================================
KXAPI(start){
	//if (run) R knk(3, kj(-1), ks(ss("已登录过服务器！")), ks("不会重复登录"));
	if (!tslGetSocketConnected())
	{
		//输入相应的服务器地址
		tslSetSocketInfo(kK(x)[0]->s, kK(x)[1]->i, 0);
		if (tslConnectSocket() != 0)
		{
			R knk(3, kj(-2), ks(ss("登录服务器失败:无法创建socket连接!")), ks(ss("error")));
		}
	}
	else{
		R knk(3, kj(-1), ks(ss("已登录过服务器！")), ks("不会重复登录"));
	}
	char err[256];
	if (!tslGetLogined())
	{
		//修改为正确的登录名称和密码
		if (tslLoginServer(kK(x)[2]->s, kK(x)[3]->s, err, 256) != 0)
		{
			R knk(3, kj(-2), ks(ss("登录服务器失败！")), ks(err));
		}
		else
			R knk(3, kj(0), ks(ss("登录服务器成功！")), kj(0));
	}
	else{
		R knk(3, kj(-1), ks(ss("已登录过服务器！")), ks("不会重复登录"));
	}
}
KXAPI(stop) {
	//if (!tslGetLogined()) R knk(3, kj(-9999), ks(ss("未登录服务器！")), kj(0));
	tslDisconnectSocket();
	R knk(3, kj(0), ks(ss("登出服务器成功!")), kj(0));
}
KXAPI(runtsl){
	if (x->t != -KS) R knk(3, kj(-1), ks(ss("参数错误！")), kj(0));
	////if (!tslGetLogined()) R knk(3, kj(-9999), ks(ss("未登录服务器！")), kj(0));
	//S func = "setsysparam(pn_stock(),'SZ000002'); \r\n return nday(10,'time',datetostr(sp_time()),'stock_name',stockname('SZ000002'),'close',close());";
	//S func = "return select Drange(1000 to 1005)* from tradetable datekey inttodate(20150505) to inttodate(20150506) of 'SZ000001' end;";
	void * oResult = TSL_NewObject();
	void * o = TSL_NewObject();
	void * sysparam = TSL_NewObject();
	void * errresult = TSL_NewObject();
	void * L = GetGlobalL();
	K res = ktn(0, 0);  //empty list
	SendExecuteAndWait((int)L, x->s,(int) sysparam, (int)oResult,(int) o,(int) errresult, true);
	if (tslObjAsReal(oResult) == -1){
		jk(&res,ks(tslObjAsString(errresult)));
		TSL_FreeObject(oResult);
		TSL_FreeObject(o);
		TSL_FreeObject(errresult);
		R knk(3, kj(-1), ks(ss("error")), res);
	}
	int otype = TT_GetObjectType(o);
	if (otype == TSL_TINT || otype==TSL_TNUMBER)
	{
		jk(&res, ke((E)tslObjAsReal(o)));
		TSL_FreeObject(oResult);
		TSL_FreeObject(o);
		TSL_FreeObject(errresult);
		R knk(3, kj(0), ks(ss("ok. F returned.")), res);
	}
	else if (otype == TSL_TSZSTRING)
	{
		jk(&res, ks(tslObjAsString(o)));
		TSL_FreeObject(oResult);
		TSL_FreeObject(o);
		TSL_FreeObject(errresult);
		R knk(3, kj(0), ks(ss("ok. S returned.")), res);
	}
	else if (otype == TSL_TTABLE)
	{
		void * h = TT_GetHash(o); //获得数组的哈希地址
		int row = TSL_HashGetN(h); //获取h 指向数据的长度row
		void * pFileds = TSL_HashGetInt(h, 0); //获取 数组第0行的哈希地址，如果是多维数组，那么pfields的类型与o是一样的
		if (TT_GetObjectType(pFileds) != TSL_TTABLE)
		{
			if (TT_GetObjectType(pFileds) == TSL_TINT || TT_GetObjectType(pFileds) == TSL_TNUMBER)
			{
				for (int i = 0; i < row; i++) {
					void* element = TSL_HashGetInt(h, i); //获得h指向的数字下标数组的第i个元素
					int bb = TT_GetObjectType(element);
					if (bb == TSL_TSZSTRING)
					{
						jk(&res, ks(tslObjAsString(element)));
					}
					else if (bb == TSL_TINT || bb == TSL_TNUMBER)
					{
						double cc = tslObjAsReal(element);
						jk(&res, ke((E)cc));
					}
				}
				//jk(&res, ke((E)tslObjAsReal(pFileds)));
				TSL_FreeObject(oResult);
				TSL_FreeObject(o);
				TSL_FreeObject(errresult);
				R knk(3, kj(0), ks(ss("ok. F returned.")), res);
			}
			else if (TT_GetObjectType(pFileds) == TSL_TSZSTRING)
			{
				//void* h2 = TT_GetHash(pFileds);
				//int len2 = TT_GetStringHashCount(pFileds);
				//for (int i = 0; i < len2; i++) {
				//	void* field = TT_GetStringHashObj(pFileds, i);
				//	char* fieldname = tslObjAsString(field);
				//	void*  element = TSL_HashGetSZString(L, h2, fieldname);
				////	void*  element = TT_GetStringHashObj(o, i);
				//	int bb = TT_GetObjectType(element);
				//	if (bb == TSL_TSZSTRING)
				//	{
				//		jk(&res, ks(tslObjAsString(element)));
				//	}
				//	else if (bb == TSL_TINT || bb == TSL_TNUMBER)
				//	{
				//		double cc = tslObjAsReal(element);
				//		jk(&res, ke((E)cc));
				//	}
				//}
				jk(&res, ks(tslObjAsString(pFileds)));
				jk(&res, ks(ss("该功能未实现")));
				TSL_FreeObject(oResult);
				TSL_FreeObject(o);
				TSL_FreeObject(errresult);
				R knk(3, kj(0), ks(ss("ok. S returned.")), res);
			}
			jk(&res, ks(ss("not table!")));
			TSL_FreeObject(oResult);
			TSL_FreeObject(o);
			TSL_FreeObject(errresult);
			R knk(3, kj(-1), ks(ss("error")), res);
		}
		//*****************************************
		//本示例代码同时转【列名】为字符串、数字下标（可以是数字列名、字符串列名或数字+字符串列名）
		//*****************************************
		//以下代码先转字符串【列名】
		int col = TT_GetStringHashCount(pFileds);  //获取一维字符串数组下标；
		int num_col = TSL_HashGetN(TT_GetHash(pFileds));//获取一维数字数组下标
		jk(&res, ki(row + 1)); jk(&res, ki(col + num_col));
		for (int n = 0; n < col; n++)
		{
			void* field = TT_GetStringHashObj(pFileds, n);
			if (TT_GetObjectType(field) == TSL_TSTRING)
			{
				jk(&res, ks(tslObjAsString(field)));
			}
		}
		//*****************************************
		//以下代码再转数字【列名】
		//*****************************************
		for (int k = 0; k < num_col; k++)
		{
			void* field = TT_GetIntHashObj(pFileds, k);
			if (field != 0 && TT_GetObjectType(field) == TSL_TINT)
			{//数字列名
				jk(&res, ke((E)tslObjAsReal(field)));
			}
		}
		//*****************************************
		//以下代码转每一行数据
		//*****************************************
		for (int i = 0; i < row; i++)
		{
			void* pO = TSL_HashGetInt(h, i); //获取h的第i行的哈希地址
			//字符串【列名】
			for (int j = 0; j < col; j++)
			{
				void* field = TT_GetStringHashObj(pFileds, j);
				char* fieldname = tslObjAsString(field);
				void* obj = TSL_HashGetSZString(L, TT_GetHash(pO), fieldname);
				int bb = TT_GetObjectType(obj);
				if (bb == TSL_TSZSTRING)
				{
					jk(&res, ks(tslObjAsString(obj)));
				}
				else if (bb == TSL_TINT || bb == TSL_TNUMBER)
				{
					double cc = tslObjAsReal(obj);
					jk(&res, ke((E)cc));
				}
			}

			//数字下标【列名】
			for (int k = 0; k < num_col; k++)
			{
				void*  field = TT_GetIntHashObj(pFileds, k); //从第pField(0)行取列下标
				if (field != 0 && TT_GetObjectType(field) == TSL_TINT)
				{//数字列名
					void*  obj = TSL_HashGetInt(TT_GetHash(pO), k);
					int bb = TT_GetObjectType(obj);
					if (bb == TSL_TSZSTRING)
					{
						jk(&res, ks(tslObjAsString(obj)));
					}
					else if (bb == TSL_TINT || bb == TSL_TNUMBER)
					{
						double cc = tslObjAsReal(obj);
						jk(&res, ke((E)cc));
					}
				}
			}
		}
		TSL_FreeObject(oResult);
		TSL_FreeObject(o);
		TSL_FreeObject(errresult);
		R knk(3, kj(0), ks(ss("ok. Table returned")), res);
	}
	else
	{
		jk(&res, ks(ss("object type not supported! type id is ")));
		jk(&res, ki(otype));
		TSL_FreeObject(oResult);
		TSL_FreeObject(o);
		TSL_FreeObject(errresult);
		R knk(3, kj(-1), ks(ss("error")), res);
	}

}
KXAPI(runtsl_sym){
	if (x->t != -KS) R knk(3, kj(-1), ks(ss("参数错误！")), kj(0));
	//if (!tslGetLogined()) R knk(3, kj(-9999), ks(ss("未登录服务器！")), kj(0));
	char* S = x->s;
	char* V;
	K res;
	if (RunTSLViaString(false, true, NULL, S, &V) == 0)
	{
		res = knk(3, kj(0), ks(ss("ok！")), ks(V));
	}
	else
	{
		res = knk(3, kj(-1), ks(ss("error")), ks(V));
	}
	TSL_Free(V);
	R res;
}
KXAPI(runtsl_xml){
	if (x->t != -KS) R knk(3, kj(-1), ks(ss("参数错误！")), kj(0));
	//if (!tslGetLogined()) R knk(3, kj(-9999), ks(ss("未登录服务器！")), kj(0));
	char* S = x->s;
	char* V;
	if (RunTSLViaString(true, true, NULL, S, &V) == 0)
	{
		TSL_Free(V);
		R knk(3, kj(0), ks(ss("ok！")), ks(V));
	}
	else
	{
		TSL_Free(V);
		R knk(3, kj(-1), ks(ss("error")), ks(V));
	}
}
KXAPI(islogined){
	R kb(tslGetLogined());
}
KXAPI(isconnected){
	R kb(tslGetSocketConnected());
}