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

String 	groupid		= new String(request.getParameter("hiGroupID").getBytes("8859_1"), "euc-kr");		// ������ �׷�ID
String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr");		// ������
String 	zoneCode	= new String(request.getParameter("hiZoneCode").getBytes("8859_1"), "euc-kr");		// ������
String 	prefixID	= new String(request.getParameter("hiPrefixID").getBytes("8859_1"), "euc-kr");		// ��ȣ��å
String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// SIP �ܸ�ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// ��ü ��ȭ��ȣ
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr");		// ������ȣ
String 	areacode	= new String(request.getParameter("hiAreaCode").getBytes("8859_1"), "euc-kr");		// ������ȣ
String	e164Route2	= new String(request.getParameter("hiE164Route2").getBytes("8859_1"), "euc-kr");	// ������ȣ ������ ��ȭ��ȣ
String 	numberType	= new String(request.getParameter("hiNumberType").getBytes("8859_1"), "euc-kr");	// ������ȣ ����(1:�����ȣ, 2:�����ȣ)
String 	pwd			= new String(request.getParameter("hiPwd").getBytes("8859_1"), "euc-kr");			// ��й�ȣ
String 	name		= request.getParameter("hiName");													// �̸�
String 	position	= request.getParameter("hiPosition");												// ����

String 	tempDept	= new String(request.getParameter("hiDept").getBytes("8859_1"), "euc-kr");			// �μ�ID|ParentID
String 	mobile		= new String(request.getParameter("hiMobile").getBytes("8859_1"), "euc-kr");		// �޴���
String 	homeNumber	= new String(request.getParameter("hiHomeNumber").getBytes("8859_1"), "euc-kr");	// ����ȭ
String 	Mail		= new String(request.getParameter("hiMail").getBytes("8859_1"), "euc-kr");			// ����

String 	authE164	= new String(request.getParameter("hiAuthE164").getBytes("8859_1"), "euc-kr");		// ��ȭ��ȣ ���� ����
String 	authIPChk	= new String(request.getParameter("hiAuthIPChk").getBytes("8859_1"), "euc-kr");		// IP���� ����
String 	authIP		= new String(request.getParameter("hiAuthIP").getBytes("8859_1"), "euc-kr");		// IP����
String 	authPortChk	= new String(request.getParameter("hiAuthPortChk").getBytes("8859_1"), "euc-kr");	// Port���� ����
String 	authPort	= new String(request.getParameter("hiAuthPort").getBytes("8859_1"), "euc-kr");		// Port����
String 	authMd5		= new String(request.getParameter("hiAuthMd5").getBytes("8859_1"), "euc-kr");		// MD5 ���� ����
String 	authRegister= new String(request.getParameter("hiAuthRegister").getBytes("8859_1"), "euc-kr");	// Register ����
String 	authStale	= new String(request.getParameter("hiAuthStale").getBytes("8859_1"), "euc-kr");		// Stale ����
String 	authInvite	= new String(request.getParameter("hiAuthInvite").getBytes("8859_1"), "euc-kr");	// Invite ����
String 	authID		= new String(request.getParameter("hiAuthID").getBytes("8859_1"), "euc-kr");		// ����ID
String 	authPass	= new String(request.getParameter("hiAuthPass").getBytes("8859_1"), "euc-kr");		// ��й�ȣ

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

String 	userID		= new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// �α��� ID

//String 	hash_Chk 	= new String(request.getParameter("hiHash_Chk").getBytes("8859_1"), "euc-kr");		// MD5 Hash (IMS��) ��� (0: �̻��, 1: ���) (2012.1.31)

String[]	tempStr = tempDept.split("[|]");
String 		dept		= tempStr[0];
String 		parentID	= tempStr[1];
String		pickUpID	= "";
if(parentID.equals("1")){
	pickUpID = dept;
}else{
	pickUpID = parentID;
}

//System.out.println("New ����� �̸� ############ : "+name);
//System.out.println("New ����� ���� ############ : "+position);
//System.out.println("�ѱ�ó���κ� 1  ############ : "+macDisplay);
//System.out.println("�ѱ�ó���κ� 2  ############ : "+macDisplay2);

IpcsUserDTO ipcsDTO = new IpcsUserDTO();

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");

try{
//ipcs ������ȣ �ߺ� üũ ó���κ�
IpcsList 	ipcsList = new IpcsList();
int extension_cnt = ipcsList.getCount(stmt, extension);

// MD5 Hash (IMS��) ���� �߰� (2012.11.09) ==============
String				beforeAuthPass	= "";
SystemConfigSet 	systemConfig 	= new SystemConfigSet();
String 				goodsName_Type	= systemConfig.getGoodsName();						// ��ǰ��(�𵨸�)
if("ACRO-CBS-IMS".equals(goodsName_Type)||"ACRO-HCBS-IMS".equals(goodsName_Type)){
	beforeAuthPass 	= authPass;
	authPass 		= ipcsList.makeMD5(authPass);
}
// ==================================================
	
if(extension_cnt==0){
	
    // Auth ���̺� 	(Auth ������ ����)
    int nRetAuthMode = 0;
    if (authE164.equals("1"))		nRetAuthMode += WebUtil.conCheckAuth_Phone_Num_Use;			//��ȭ��ȣ����(E164) : 2048
    if (authIPChk.equals("1"))		nRetAuthMode += WebUtil.conCheckAuth_IP_Use;				//IP���� : 2
    if (authPortChk.equals("1"))	nRetAuthMode += WebUtil.conCheckAuth_IP_Port_Use;			//Port ���� :1
    if (authMd5.equals("1")){
    	nRetAuthMode += WebUtil.conCheckAuth_Passwd_Use;										//��й�ȣ ���� :128
    	if (authRegister.equals("1")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Register_IPchange;						//Register���� : IP���� �� : 64
    	}else if (authRegister.equals("2")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Register_AnyTime;						//Register���� : �׻����� : 0
    	}
    	if (authStale.equals("1"))	nRetAuthMode += WebUtil.conCheckAuth_Passwd_Register_Stale;	//Register���� : Stele ��� : 8
    	if (authInvite.equals("1")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_Uncheck;							//Inviter���� : �������� :0
    	}else if (authInvite.equals("2")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_IPReject;						//Inviter���� : IP����� Reject :32
    	}else if (authInvite.equals("3")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_IPchange;						//Inviter���� : IP����� ���� :48
    	}else if (authInvite.equals("4")){
    		nRetAuthMode += WebUtil.conCheckAuth_Passwd_Invite_AnyTime;							//Inviter���� : �׻� ���� :16
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
    
    
	// E164 ���̺�	
	ipcsDTO.setE164(ei64);
	ipcsDTO.setAreaCode(areacode);
	ipcsDTO.setIsGroup(2);
	ipcsDTO.setGroupId(groupid);
	ipcsDTO.setSubId(pickUpID);
//	ipcsDTO.setSubId(dept);
	ipcsDTO.setExtensionNum(extension);
	ipcsDTO.setCallerService("0000000000000000000000000000000000000000000000000000000000000000");			// *************************************
	//ipcsDTO.setAnswerService("0000000000000000000000000000000000000000000000000000000000000000");			// *************************************
	ipcsDTO.setAnswerService("0000000000000000000000000000000000000000000000000000000000000000");		// 20090626 ��ŷ�κ� "1" �� ,  20101208 ��ŷ�κ� "0" 
	ipcsDTO.setCommonService("01010000000000000000000000000000");			// 20101208 VMS�κ� "0" ���� ����
	ipcsDTO.setChargeType(0);
	ipcsDTO.setEndpointRelationType(2);		// �ܸ��� ��� ����		*************************************
	ipcsDTO.setStartFlag(1);				// ���� ����		*************************************
	ipcsDTO.setMailBox("");									// 20101208 VMS ��� ���ϰ� ����
//	ipcsDTO.setMailBox("0000000000^13");
	// E164Route ���̺�
	ipcsDTO.setRoutingNumber("");
	ipcsDTO.setEndpointID(endPointID);
	ipcsDTO.setProtocol(2);
	ipcsDTO.setRoutingNumberType(1);		// Route ����(1,2,5)		*************************************
	ipcsDTO.setPriority(1);
	ipcsDTO.setE164Route2(e164Route2);		// ������ȣ ������ ��ȭ��ȣ
	// SIPEndPoint ���̺�
	ipcsDTO.setDomainId(domainID);
	ipcsDTO.setZoneCode(zoneCode);
	ipcsDTO.setEndPointClass(33);
	ipcsDTO.setDynamicFlag(0);
	ipcsDTO.setMultiEndpoint(0);			// �ش� EndpointID �� ���� �ܸ��� ��� ���ɿ���		20110103 "1" ���� "0" �ٽ� ���� *****************
	//ipcsDTO.setMultiEndpoint(1);			// 20090626 "0" ���� "1" ����
	ipcsDTO.setDtmfType(0);					// *************************************
	ipcsDTO.setOptions(0);
	// Subscriber ���̺�
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
		// ############### LogHistory ó��  ###############
		String		strIp		= request.getRemoteAddr();
		LogHistory	logHistory 	= new LogHistory();
		int int_result = logHistory.LogHistorySave(userID+"|82|���γ�����ȣ/�ܸ����� ("+ei64+" ��)|1|"+strIp);
		// ##############################################
		
		System.out.println("���强��------^^");
		out.clear();
		out.print("OK");
	}else{
		System.out.println("�������------�̤�");
		out.clear();
		out.print("NO");
	}	

}else{
	System.out.println("������ȣ �ߺ� ------�̤�");
	out.clear();
	out.print("NO2");	
}

}catch(Exception ex){
	System.out.println(ex);
}finally{
	//�Ҵ���� DataStatement ��ü�� �ݳ�
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
} 

%>
