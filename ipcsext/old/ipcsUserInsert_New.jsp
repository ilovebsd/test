<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.StringUtil"%>
<%@ page import="waf.*"%>
<%@ page import="dto.ipcs.IpcsUserDTO" %>
<%@ page import="dao.ipcs.IpcsUserDAO" %>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="acromate.common.util.WebUtil"%>

<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="business.ipcs.IpcsList"%>

<%@ page import="business.LogHistory"%>

<%@ page import="system.SystemConfigSet"%>

<!--meta http-equiv='Content-type' content='text/html; charset=euc-kr'-->

<%
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

//request.setCharacterEncoding("euc-kr");
request.setCharacterEncoding("UTF-8");

boolean returnVal 	= false;

String 	groupid		= new String(request.getParameter("hiGroupID").getBytes("8859_1"), "euc-kr");		// 가입자 그룹ID
String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr");		// 도메인
String 	zoneCode	= new String(request.getParameter("hiZoneCode").getBytes("8859_1"), "euc-kr");		// 망관리
String 	prefixID	= new String(request.getParameter("hiPrefixID").getBytes("8859_1"), "euc-kr");		// 번호정책
String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// SIP 단말ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// 전체 전화번호
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr");		// 내선번호
String 	areacode	= new String(request.getParameter("hiAreaCode").getBytes("8859_1"), "euc-kr");		// 지역번호
String	e164Route2	= new String(request.getParameter("hiE164Route2").getBytes("8859_1"), "euc-kr");	// 지역번호 제외한 전화번호
String 	numberType	= new String(request.getParameter("hiNumberType").getBytes("8859_1"), "euc-kr");	// 내선번호 유형(1:직통번호, 2:단축번호)
String 	pwd			= new String(request.getParameter("hiPwd").getBytes("8859_1"), "euc-kr");			// 비밀번호
String 	name		= request.getParameter("hiName");													// 이름
String 	position	= request.getParameter("hiPosition");												// 직급

String 	tempDept	= new String(request.getParameter("hiDept").getBytes("8859_1"), "euc-kr");			// 부서ID|ParentID
String 	mobile		= new String(request.getParameter("hiMobile").getBytes("8859_1"), "euc-kr");		// 휴대폰
String 	homeNumber	= new String(request.getParameter("hiHomeNumber").getBytes("8859_1"), "euc-kr");	// 집전화
String 	Mail		= new String(request.getParameter("hiMail").getBytes("8859_1"), "euc-kr");			// 메일

String 	authE164	= new String(request.getParameter("hiAuthE164").getBytes("8859_1"), "euc-kr");		// 전화번호 인증 여부
String 	authIPChk	= new String(request.getParameter("hiAuthIPChk").getBytes("8859_1"), "euc-kr");		// IP인증 여부
String 	authIP		= new String(request.getParameter("hiAuthIP").getBytes("8859_1"), "euc-kr");		// IP인증
String 	authPortChk	= new String(request.getParameter("hiAuthPortChk").getBytes("8859_1"), "euc-kr");	// Port인증 여부
String 	authPort	= new String(request.getParameter("hiAuthPort").getBytes("8859_1"), "euc-kr");		// Port인증
String 	authMd5		= new String(request.getParameter("hiAuthMd5").getBytes("8859_1"), "euc-kr");		// MD5 인증 여부
String 	authRegister= new String(request.getParameter("hiAuthRegister").getBytes("8859_1"), "euc-kr");	// Register 유형
String 	authStale	= new String(request.getParameter("hiAuthStale").getBytes("8859_1"), "euc-kr");		// Stale 여부
String 	authInvite	= new String(request.getParameter("hiAuthInvite").getBytes("8859_1"), "euc-kr");	// Invite 여부
String 	authID		= new String(request.getParameter("hiAuthID").getBytes("8859_1"), "euc-kr");		// 인증ID
String 	authPass	= new String(request.getParameter("hiAuthPass").getBytes("8859_1"), "euc-kr");		// 비밀번호

String 	mac			= new String(request.getParameter("hiMac").getBytes("8859_1"), "euc-kr");			// Mac
String 	macAuthId	= new String(request.getParameter("hiMacAuthId").getBytes("8859_1"), "euc-kr");		// 
String 	macAuthPass	= new String(request.getParameter("hiMacAuthPass").getBytes("8859_1"), "euc-kr");	// 
//String 	macDisplay	= new String(request.getParameter("hiMacDisplay").getBytes("8859_1"), "euc-kr");			// 
//String 	macDisplay	= new String(request.getParameter("hiMacDisplay").getBytes("8859_1"), "utf-8");
String 	macDisplay	= request.getParameter("hiMacDisplay");			//
String 	macWanIp	= new String(request.getParameter("hiMacIp").getBytes("8859_1"), "euc-kr");			// 
String 	macAuto		= new String(request.getParameter("hiMacAuto").getBytes("8859_1"), "euc-kr");		// 
String 	macAutoNo	= new String(request.getParameter("hiMacAutoNo").getBytes("8859_1"), "euc-kr");		// 
String 	macAddrType	= new String(request.getParameter("hiMacAddrType").getBytes("8859_1"), "euc-kr");		//

String 	userID		= new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// 로그인 ID

//String 	hash_Chk 	= new String(request.getParameter("hiHash_Chk").getBytes("8859_1"), "euc-kr");		// MD5 Hash (IMS용) 사용 (0: 미사용, 1: 사용) (2012.1.31)

String[]	tempStr = tempDept.split("[|]");
String 		dept		= tempStr[0];
String 		parentID	= tempStr[1];
String		pickUpID	= "";
if(parentID.equals("1")){
	pickUpID = dept;
}else{
	pickUpID = parentID;
}

//System.out.println("New 사용자 이름 ############ : "+name);
//System.out.println("New 사용자 직위 ############ : "+position);
//System.out.println("한글처리부분 1  ############ : "+macDisplay);
//System.out.println("한글처리부분 2  ############ : "+macDisplay2);

IpcsUserDTO ipcsDTO = new IpcsUserDTO();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");

try{
//ipcs 내선번호 중복 체크 처리부분
IpcsList 	ipcsList = new IpcsList();
int extension_cnt = ipcsList.getCount(stmt, extension);

// MD5 Hash (IMS용) 관련 추가 (2012.11.09) ==============
String				beforeAuthPass	= "";
SystemConfigSet 	systemConfig 	= new SystemConfigSet();
String 				goodsName_Type	= systemConfig.getGoodsName();						// 제품명(모델명)
if("ACRO-CBS-IMS".equals(goodsName_Type)||"ACRO-HCBS-IMS".equals(goodsName_Type)){
	beforeAuthPass 	= authPass;
	authPass 		= ipcsList.makeMD5(authPass);
}
// ==================================================
	
if(extension_cnt==0){
	
    // Auth 테이블 	(Auth 인증값 설정)
    int nRetAuthMode = 0;
    if (authE164.equals("1"))		nRetAuthMode += WebUtil.conCheckAuth_Phone_Num_Use;			//전화번호인증(E164) : 2048
    if (authIPChk.equals("1"))		nRetAuthMode += WebUtil.conCheckAuth_IP_Use;				//IP인증 : 2
    if (authPortChk.equals("1"))	nRetAuthMode += WebUtil.conCheckAuth_IP_Port_Use;			//Port 인증 :1
    if (authMd5.equals("1")){
    	nRetAuthMode += WebUtil.conCheckAuth_Passwd_Use;										//비밀번호 인증 :128
    	if (authRegister.equals("1")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Register_IPchange;						//Register관련 : IP변경 시 : 64
    	}else if (authRegister.equals("2")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Register_AnyTime;						//Register관련 : 항상인증 : 0
    	}
    	if (authStale.equals("1"))	nRetAuthMode += WebUtil.conCheckAuth_Passwd_Register_Stale;	//Register관련 : Stele 모드 : 8
    	if (authInvite.equals("1")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_Uncheck;							//Inviter관련 : 인증안함 :0
    	}else if (authInvite.equals("2")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_IPReject;						//Inviter관련 : IP변경시 Reject :32
    	}else if (authInvite.equals("3")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_IPchange;						//Inviter관련 : IP변경시 인증 :48
    	}else if (authInvite.equals("4")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_AnyTime;							//Inviter관련 : 항상 인증 :16
    	}
    }
    ipcsDTO.setAuthMode(nRetAuthMode);
    ipcsDTO.setIpAddress(authIP);
    ipcsDTO.setIpPort(Integer.parseInt(authPort));
    if("".equals(authID)){
    	ipcsDTO.setUserName(" ");
    }else{
    	ipcsDTO.setUserName(authID);
    }
    ipcsDTO.setPassWord(authPass);
    
    
	// E164 테이블	
	ipcsDTO.setE164(ei64);
	ipcsDTO.setAreaCode(areacode);
	ipcsDTO.setIsGroup(2);
	ipcsDTO.setGroupId(groupid);
	ipcsDTO.setSubId(pickUpID);
//	ipcsDTO.setSubId(dept);
	ipcsDTO.setExtensionNum(extension);
	ipcsDTO.setCallerService("0000000000000000000000000000000000000000000000000000000000000000");			// *************************************
	//ipcsDTO.setAnswerService("0000000000000000000000000000000000000000000000000000000000000000");			// *************************************
	ipcsDTO.setAnswerService("0000000000000000000000000000000000000000000000000000000000000000");		// 20090626 포킹부분 "1" 로 ,  20101208 포킹부분 "0" 
	ipcsDTO.setCommonService("01010000000000000000000000000000");			// 20101208 VMS부분 "0" 으로 수정
	ipcsDTO.setChargeType(0);
	ipcsDTO.setEndpointRelationType(2);		// 단말기 등록 여부		*************************************
	ipcsDTO.setStartFlag(1);				// 개통 여부		*************************************
	ipcsDTO.setMailBox("");									// 20101208 VMS 등록 안하게 수정
//	ipcsDTO.setMailBox("0000000000^13");
	// E164Route 테이블
	ipcsDTO.setRoutingNumber("");
	ipcsDTO.setEndpointID(endPointID);
	ipcsDTO.setProtocol(2);
	ipcsDTO.setRoutingNumberType(1);		// Route 유형(1,2,5)		*************************************
	ipcsDTO.setPriority(1);
	ipcsDTO.setE164Route2(e164Route2);		// 지역번호 제외한 전화번호
	// SIPEndPoint 테이블
	ipcsDTO.setDomainId(domainID);
	ipcsDTO.setZoneCode(zoneCode);
	ipcsDTO.setEndPointClass(33);
	ipcsDTO.setDynamicFlag(0);
	ipcsDTO.setMultiEndpoint(0);			// 해당 EndpointID 를 여러 단말이 사용 가능여부		20110103 "1" 에서 "0" 다시 수정 *****************
	//ipcsDTO.setMultiEndpoint(1);			// 20090626 "0" 에서 "1" 수정
	ipcsDTO.setDtmfType(0);					// *************************************
	ipcsDTO.setOptions(0);
	// Subscriber 테이블
	ipcsDTO.setPwd(pwd);
	ipcsDTO.setName(name);
	ipcsDTO.setPosition(position);	
	ipcsDTO.setDepartment(Integer.parseInt((String)dept));
	ipcsDTO.setMobile(mobile);
	ipcsDTO.setHomeNumber(homeNumber);
	ipcsDTO.setMailAddress(Mail);
	
	ipcsDTO.setNumberType(numberType);
	
	ipcsDTO.setMac(mac);
	ipcsDTO.setMacAuthId(macAuthId);
	ipcsDTO.setMacAuthPass(macAuthPass);
	
	String tmpStr;
	tmpStr = new String(macDisplay.getBytes("EUC-KR"),"ISO-8859-1");
	ipcsDTO.setMacDisplay(tmpStr);
	//ipcsDTO.setMacDisplay(macDisplay);
	
	ipcsDTO.setMacWanIp(macWanIp);
	ipcsDTO.setMacAuto(macAuto);
	ipcsDTO.setMacAutoNo(macAutoNo);
	ipcsDTO.setMacAddrType(macAddrType);
	
	IpcsUserDAO ipcsDao = new IpcsUserDAO();
	//returnVal = ipcsDao.ipcsUserInsert(ipcsDTO);
	returnVal = ipcsDao.ipcsUserInsert(ipcsDTO, goodsName_Type, beforeAuthPass);
	if(returnVal){
		// ############### LogHistory 처리  ###############
		String		strIp		= request.getRemoteAddr();
		LogHistory	logHistory 	= new LogHistory();
		int int_result = logHistory.LogHistorySave(userID+"|82|개인내선번호/단말관리 ("+ei64+" 번)|1|"+strIp);
		// ##############################################
		
		System.out.println("저장성공------^^");
		out.clear();
		out.print("OK");
	}else{
		System.out.println("저장실패------ㅜㅜ");
		out.clear();
		out.print("NO");
	}	

}else{
	System.out.println("내선번호 중복 ------ㅜㅜ");
	out.clear();
	out.print("NO2");	
}

}catch(Exception ex){
	System.out.println(ex);
}finally{
	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
} 

%>
