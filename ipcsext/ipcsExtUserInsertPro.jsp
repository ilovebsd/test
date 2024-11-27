<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.StringUtil"%>
<%@ page import="dto.ipcs.IpcsUserDTO" %>
<%@ page import="dao.ipcs.IpcsUserDAO" %>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="acromate.common.util.WebUtil"%>

<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="business.ipcs.IpcsList, business.LogHistory, acromate.*"%>

<%@ page import="system.SystemConfigSet, system.SystemConfigFileMake"%>

<!--meta http-equiv='Content-type' content='text/html; charset=euc-kr'-->

<%
//request.setCharacterEncoding("euc-kr");
request.setCharacterEncoding("UTF-8");
HttpSession ses = request.getSession() ;
String checkgroupid = (String) ses.getAttribute("login.name") ;
String userID = (String) ses.getAttribute("login.user") ;

boolean returnVal 	= false;

String 	groupid		= new String(request.getParameter("hiGroupID").getBytes("8859_1"), "euc-kr").trim();		// ������ �׷�ID
String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr").trim();		// ������
String 	zoneCode	= new String(request.getParameter("hiZoneCode").getBytes("8859_1"), "euc-kr").trim();		// ������
String 	prefixID	= new String(request.getParameter("hiPrefixID").getBytes("8859_1"), "euc-kr").trim();		// ��ȣ��å
String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr").trim();	// SIP �ܸ�ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr").trim();			// ��ü ��ȭ��ȣ
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr").trim();		// ������ȣ
String 	areacode	= new String(request.getParameter("hiAreaCode").getBytes("8859_1"), "euc-kr").trim();		// ������ȣ
String	e164Route2	= new String(request.getParameter("hiE164Route2").getBytes("8859_1"), "euc-kr").trim();	// ������ȣ ������ ��ȭ��ȣ
String 	numberType	= new String(request.getParameter("hiNumberType").getBytes("8859_1"), "euc-kr").trim();	// ������ȣ ����(1:�����ȣ, 2:�����ȣ)
String 	pwd			= new String(request.getParameter("hiPwd").getBytes("8859_1"), "euc-kr").trim();			// ��й�ȣ
String 	name		= request.getParameter("hiName").trim();													// �̸�
String 	position	= request.getParameter("hiPosition").trim();												// ����

String 	tempDept	= new String(request.getParameter("hiDept").getBytes("8859_1"), "euc-kr").trim();			// �μ�ID|ParentID
String 	mobile		= new String(request.getParameter("hiMobile").getBytes("8859_1"), "euc-kr").trim();		// �޴���
String 	homeNumber	= new String(request.getParameter("hiHomeNumber").getBytes("8859_1"), "euc-kr").trim();	// ����ȭ
String 	Mail		= new String(request.getParameter("hiMail").getBytes("8859_1"), "euc-kr").trim();			// ����

String 	authE164	= new String(request.getParameter("hiAuthE164").getBytes("8859_1"), "euc-kr").trim();		// ��ȭ��ȣ ���� ����
String 	authIPChk	= new String(request.getParameter("hiAuthIPChk").getBytes("8859_1"), "euc-kr").trim();		// IP���� ����
String 	authIP		= new String(request.getParameter("hiAuthIP").getBytes("8859_1"), "euc-kr").trim();		// IP����
String 	authPortChk	= new String(request.getParameter("hiAuthPortChk").getBytes("8859_1"), "euc-kr").trim();	// Port���� ����
String 	authPort	= new String(request.getParameter("hiAuthPort").getBytes("8859_1"), "euc-kr").trim();		// Port����
String 	authMd5		= new String(request.getParameter("hiAuthMd5").getBytes("8859_1"), "euc-kr").trim();		// MD5 ���� ����
String 	authRegister= new String(request.getParameter("hiAuthRegister").getBytes("8859_1"), "euc-kr").trim();	// Register ����
String 	authStale	= new String(request.getParameter("hiAuthStale").getBytes("8859_1"), "euc-kr").trim();		// Stale ����
String 	authInvite	= new String(request.getParameter("hiAuthInvite").getBytes("8859_1"), "euc-kr").trim();	// Invite ����
String 	authID		= new String(request.getParameter("hiAuthID").getBytes("8859_1"), "euc-kr").trim();		// ����ID
String 	authPass	= new String(request.getParameter("hiAuthPass").getBytes("8859_1"), "euc-kr").trim();		// ��й�ȣ

String 	mac			= new String(request.getParameter("hiMac").getBytes("8859_1"), "euc-kr").trim();			// Mac
String 	macAuthId	= new String(request.getParameter("hiMacAuthId").getBytes("8859_1"), "euc-kr").trim();		// 
String 	macAuthPass	= new String(request.getParameter("hiMacAuthPass").getBytes("8859_1"), "euc-kr").trim();	// 
//String 	macDisplay	= new String(request.getParameter("hiMacDisplay").getBytes("8859_1"), "euc-kr").trim();			// 
//String 	macDisplay	= new String(request.getParameter("hiMacDisplay").getBytes("8859_1"), "utf-8").trim();
String 	macDisplay	= request.getParameter("hiMacDisplay").trim();			//
String 	macWanIp	= new String(request.getParameter("hiMacIp").getBytes("8859_1"), "euc-kr").trim();			// 
String 	macAuto		= new String(request.getParameter("hiMacAuto").getBytes("8859_1"), "euc-kr").trim();		// 
String 	macAutoNo	= new String(request.getParameter("hiMacAutoNo").getBytes("8859_1"), "euc-kr").trim();		// 
String 	macAddrType	= new String(request.getParameter("hiMacAddrType").getBytes("8859_1"), "euc-kr").trim();		//

//String 	userID		= new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr").trim();		// �α��� ID

//String 	hash_Chk 	= new String(request.getParameter("hiHash_Chk").getBytes("8859_1"), "euc-kr").trim();		// MD5 Hash (IMS��) ��� (0: �̻��, 1: ���) (2012.1.31)

pwd = authPass;

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
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);
try{
//ipcs ������ȣ �ߺ� üũ ó���κ�
IpcsList 	ipcsList = new IpcsList();
//********** ipcsList **********//
int extension_cnt = 0;//ipcsList.getCount(stmt, extension);
ResultSet rs 	= null;
String sql = "SELECT count(*) FROM table_e164 "; 
sql = sql + "\n WHERE extensionnumber = '"+extension+"' AND checkgroupid = '"+checkgroupid+"'";
String groupExtCode = "" ;

try {
    if (stmt != null) {
//    	System.out.println("################ ������ȣ üũ SQL 1 : "+sql);
        rs = stmt.executeQuery(sql);
        if (rs.next()) extension_cnt = rs.getInt(1); 
        rs.close();
        
    	sql = "select extensionGroupNum from table_SubscriberGroup WHERE checkgroupid = '"+checkgroupid+"' ";
    	rs = stmt.executeQuery(sql);
//        System.out.println("################ ������ȣ üũ SQL 2 : "+sql2);
        if (rs.next()) groupExtCode = rs.getString(1); 
        rs.close();

        if(extension_cnt==0){
            sql = "SELECT count(*) FROM table_localprefix where prefixtype = 2 and startprefix = '"+groupExtCode+extension+"' ";// +" AND checkgroupid = '"+checkgroupid+"'";
            rs = stmt.executeQuery(sql);
//            System.out.println("################ ������ȣ üũ SQL 2 : "+sql2);
            if (rs.next()) extension_cnt = rs.getInt(1); 
            rs.close();
        }
    } else            
        System.out.println("�����ͺ��̽��� ������ �� �����ϴ�.");            
} catch (Exception e) {
    System.out.println(e.getMessage());
} finally {
    try {
        if (rs != null)
            rs.close();
    } catch (Exception e) {}
}

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
	
	ipcsDTO.setNumberType("1");
	
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
	//returnVal = ipcsDao.ipcsUserInsert(ipcsDTO, goodsName_Type, beforeAuthPass);
	returnVal = false;
    	DataStatement 	statement = null;
    	try {
	    	int 	count 				= 0;
	    	numberType			= ipcsDTO.getNumberType().trim();		// NumberType(1:�����ȣ, 2:�����ȣ)
	    	System.out.println("numberType:"+numberType);
	    	// SIPEndPoint ���̺�
	    	String 	domainId			= ipcsDTO.getDomainId().trim();			// ������ 
	    	zoneCode			= ipcsDTO.getZoneCode().trim();			// Nat Zone Code
	    	int 	endPointClass		= ipcsDTO.getEndPointClass();			// 
	    	int 	dynamicFlag			= ipcsDTO.getDynamicFlag();				// 
	    	int 	multiEndpoint		= ipcsDTO.getMultiEndpoint();			// �ش� EndpointID �� ���� �ܸ��� ��� ���ɿ���
	    	int 	dtmfType			= ipcsDTO.getDtmfType();				// SIP �ܸ��� DTMF ó�����
	    	int 	options				= ipcsDTO.getOptions();					// 
	    	// E164 ���̺�
	    	String 	e164				= ipcsDTO.getE164().trim();				// E164
	    	String 	areaCode			= ipcsDTO.getAreaCode().trim();			// ������ȣ
	    	int 	isGroup				= ipcsDTO.getIsGroup();					// ������ ����(����/ȸ��)
	    	String 	groupId				= ipcsDTO.getGroupId().trim();			// �Ҽӱ׷�
//	    	String	subId				= ipcsDTO.getSubId().trim();			// �����׷�(Pick Up�׷�)
	    	String	subId				= checkgroupid;							// �����׷�(Pick Up�׷�)
	    	String 	extensionNum		= ipcsDTO.getExtensionNum().trim();		// ������ȣ
	    	String 	callerService		= ipcsDTO.getCallerService().trim();	// �ΰ����� Caller ����
	    	String 	answerService		= ipcsDTO.getAnswerService().trim();	// �ΰ����� Caller ����
	    	String 	commonService		= ipcsDTO.getCommonService().trim();	// �ΰ����� Caller ����
	    	int 	chargeType			= ipcsDTO.getChargeType();				// ����Ÿ��
	    	int 	endpointRelationType= ipcsDTO.getEndpointRelationType();	// �ܸ����� ��Ͽ���
	    	int 	startFlag			= ipcsDTO.getStartFlag();				// ���뿩��
	    	String 	mailBox				= ipcsDTO.getMailBox().trim();			// ���Ϲڽ�ID
	    	// E164Route ���̺�
	    	String 	routingNumber		= ipcsDTO.getRoutingNumber().trim();	// Route �Ҷ� �񱳵Ǵ� ��ȣ
	    	String 	endpointID			= ipcsDTO.getEndpointID().trim();		// ����� �ܸ��� ID
	    	int 	protocol			= ipcsDTO.getProtocol();				// �������� Ÿ��
	    	int 	routingNumberType	= ipcsDTO.getRoutingNumberType();		// Route ����
	    	int 	priority			= ipcsDTO.getPriority();
	    	e164Route2			= ipcsDTO.getE164Route2().trim();		// Route �Ҷ� �񱳵Ǵ� ��ȣ
	    	// Subscriber ���̺�
	    		pwd					= ipcsDTO.getPwd();						// ��й�ȣ
	    		name				= ipcsDTO.getName();					// �̸�
	    		position			= ipcsDTO.getPosition();				// ����
	    	int 	department			= ipcsDTO.getDepartment();				// �μ�
	    		mobile				= ipcsDTO.getMobile();					// �ڵ���
	    	String 	homenumber			= ipcsDTO.getHomeNumber();				// ����ȭ
	    	String 	mailaddress			= ipcsDTO.getMailaddress();				// �����ּ�
	    	// Auth ���̺�
	    	int 	authMode			= ipcsDTO.getAuthMode();				// ���� Mode
	    	 	authIP				= ipcsDTO.getIpAddress();				// ���� IP
	    	int 	nAuthPort			= ipcsDTO.getIpPort();					// ���� Port
	    		authID				= ipcsDTO.getUserName();				// ���� ID
	    		authPass			= ipcsDTO.getPassWord();				// ���� ��й�ȣ	    	
	    	// table_provision ���̺�
	    		mac					= ipcsDTO.getMac();						// Mac
	    	String	macType				= "";
	    	if(!"".equals(mac)){
		    	String	strMac				= mac.substring(0,8);		    	
		    	if("00:11:a9".equals(strMac)){
		    		macType	= "MOIMSTONE";
		    	}else if("00:1a:0b".equals(strMac)){
		    		macType	= "JUNGWOO";
		   		}else if("00:1c:e0".equals(strMac)){
		   			macType	= "DASAN";
		    	}
	    	}
	    	
	    	//System.out.println("��й�ȣ �α� $$$$$$$$$$$$$$$ : "+pwd);
	    	//System.out.println("����� �̸� $$$$$$$$$$$$$$$ : "+name);
	    	//System.out.println("����� ���� $$$$$$$$$$$$$$$ : "+position);
	    	
	    	endpointID = endpointID + "@" + domainId + ":5060";
	    	
	    	sql 		= "";//String			sql 		= "";
	    	rs 			= null;//ResultSet 		rs 			= null;
	    	// �����κ��� DataStatement ��ü�� �Ҵ�
	    	//String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	    	statement 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
	    	statement.stxTransaction();
	    	
	    	/***** table_SIPENDPOINT �� �ܸ� ID ���� ********/
	    	sql = "INSERT INTO table_SIPENDPOINT(EndpointID, EndpointClass, DomainID, DynamicFlag, ZoneCode, MultiEndpoint, DtmfType, Options, checkgroupid) VALUES( ";
	    	sql +=	"'" + endpointID +"',"+ "33" +", '" + domainId + "',0, '" + zoneCode + "',  " + multiEndpoint + "," + dtmfType + ", " + options + ", '"+checkgroupid+"')";
	        int nResult = 0;
	        System.out.println("0:"+sql);
	        nResult = statement.executeUpdate(sql);
	        if (nResult < 1){
	        	throw new Exception(l.x("[�ܸ�ID ����] '","[Phone ID Error] '") +endpointID+ l.x("' �ܸ� ID ����� �����Ͽ����ϴ�.","' Phone ID Insertion failed."));	
	        }
	    
	    	System.out.println("numberType:"+numberType);
	        /***** TABLE_E164 �� ���� ********/
	        if(numberType.equals("1")){			// NumberType(1:�����ȣ, 2:�����ȣ)
		        sql = "INSERT INTO TABLE_E164 " +
	            "(E164, VIRTUALCID, AREACODE, ISGROUP, GROUPID, EXTENSIONNUMBER, PREFIXTABLEID, STARTFLAG, CHARGETYPE, ENDPOINTRELATIONTYPE, " +
	            " callerService, answerService, commonService, SubID,MailBox, checkgroupid) "
	            + "VALUES ('"
	            + e164 + "','"
	            + e164 + "','"
	            + areaCode + "',"
	            + isGroup + ",'"
	            + groupId + "','"
	            + extensionNum + "','"
	            //+ e164Bean.getPrefixtableid() + "',"
	            + "',"
	            //+ e164Bean.getStartflag() + ","
	            + startFlag + ","
	            + chargeType + ","
	            + endpointRelationType + ",'"
	            + callerService + "','"
	            + answerService + "','"
	            + commonService + "','"
	            + subId +"','"
	            + mailBox +"','"
	            + checkgroupid +"')";
	        }else{
	        	// �����ȣ�� ��� ������ȣ�� E164�� �Է���.
	        	sql = "INSERT INTO TABLE_E164 " +
	            "(E164, AREACODE, ISGROUP, GROUPID, EXTENSIONNUMBER, PREFIXTABLEID, STARTFLAG, CHARGETYPE, ENDPOINTRELATIONTYPE, " +
	            " callerService, answerService, commonService, SubID,MailBox, checkgroupid) "
	            + "VALUES ('"
	            + e164 + "','"
	            + areaCode + "',"
	            + isGroup + ",'"
	            + groupId + "','"
	            //+ e164 + "','"
	            + extensionNum + "','"
	            //+ e164Bean.getPrefixtableid() + "',"
	            + "',"
	            //+ e164Bean.getStartflag() + ","
	            + startFlag + ","
	            + chargeType + ","
	            + endpointRelationType + ",'"
	            + callerService + "','"
	            + answerService + "','"
	            + commonService + "','"
	            + subId +"','"
	            + mailBox +"','"
	            + checkgroupid +"')";	        	
	        }
			System.out.println(sql);
			nResult = statement.executeUpdate(sql);
			if (nResult < 1){	throw new Exception(l.x("[��ȭ��ȣ ����] �ܸ��� ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" ��ȭ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}
			
            /***** table_E164Route ���� �ش� ��ȭ��ȣ�� �ٸ� �ܸ��� ��ϵ� ��ȭ��ȣ���� Ȯ�� ********/
	        sql = "SELECT COUNT(*) FROM table_E164Route WHERE E164 = '"+ e164 +"' AND checkgroupid='"+checkgroupid+"'";
            rs = statement.executeQuery(sql);
            if(rs.next()) count = rs.getInt(1);
            System.out.println("table_E164Route �˻���ȣ : "+e164);
            System.out.println("table_E164Route �˻���� : "+count);
            rs.close();
	        
            System.out.println("NumberType(1:�����ȣ, 2:�����ȣ) : "+numberType);
            if(numberType.equals("1")){			// NumberType(1:�����ȣ, 2:�����ȣ)
	            /***** ������ȣ����E164 ���********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol , EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + e164  + "','" + e164  + "', 2,'" + endpointID + "',1, 1, '"+checkgroupid+"') ";
	            System.out.println("1:"+sql);
	            nResult = statement.executeUpdate(sql);
	            if (nResult < 1){	throw new Exception(l.x("[��ȭ��ȣ ����] �ܸ��� ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" ��ȭ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}
	
	            /***** ������ȣ����E164 ���********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol , EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + e164Route2 + "','" + e164  + "', 2,'" + endpointID + "',2, 1, '"+checkgroupid+"') ";
	            System.out.println("2:"+sql);
	            nResult = statement.executeUpdate(sql);
	            if (nResult < 1){	throw new Exception(l.x("[��ȭ��ȣ ����] �ܸ��� ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" ��ȭ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}
            
                /***** �׷��ȣ���� ������ȣ ���********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol, EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + groupExtCode + extensionNum + "','" + e164  + "', 2,'" + endpointID + "',5, 1, '"+checkgroupid+"') ";
                System.out.println("4:"+sql);
                nResult = statement.executeUpdate(sql);
                if (nResult < 1){	throw new Exception(l.x("[���� �׷��ȣ ����] �ܸ��� ","[Extension Group Number Error] In the Phone, the Number")+endpointID+ l.x(" ��ȭ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}	            
            }else{
	            /***** ������ȣ����E164 ���********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol , EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + e164  + "','" + e164  + "', 2,'" + endpointID + "',1, 1, '"+checkgroupid+"') ";
	            System.out.println("1:"+sql);
	            nResult = statement.executeUpdate(sql);
	            if (nResult < 1){	throw new Exception(l.x("[��ȭ��ȣ ����] �ܸ��� ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" ��ȭ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}

            	/***** �׷��ȣ���� ���� ������ȣ ���********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol, EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            //sql +=	"  VALUES ('" + groupExtCode + e164 + "','" + e164 + "', 2,'" + endpointID + "',5, 1) ";
	            sql +=	"  VALUES ('" + groupExtCode + extensionNum + "','" + e164 + "', 2,'" + endpointID + "',5, 1, '"+checkgroupid+"') ";
	            System.out.println("4:"+sql);
                nResult = statement.executeUpdate(sql);
                if (nResult < 1){	throw new Exception(l.x("[���� �׷��ȣ ����] �ܸ��� ","[Extension Group Number Error] In the Phone, the Number")+endpointID+ l.x(" ��ȭ��ȣ �Ҵ��� �����Ͽ����ϴ�."," join failed."));	}            	
            }

            // Auto CallBack Service �߰� 2009.08.22
            sql   = "INSERT INTO table_featureservice(E164, ServiceNo, Priority, checkgroupid) VALUES('" + e164  + "', 5282, 5282, '"+checkgroupid+"')";            
            System.out.println("9-1:"+sql);
            nResult = statement.executeUpdate(sql);
            if (nResult < 1){	throw new Exception(l.x("[FeatureService���� ����] '","[FeatureService Properties Error] '")+e164+l.x("'�� FeatureService ��������� �����Ͽ����ϴ�. �ܸ� ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
            
            
            // Default ��ȭ ����� �߰� 2011.04.18
        	sql = " insert into table_featureservice(e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) "; 
			sql = sql + "  values('" + e164 + "', 5031, 5031 , 'default_moh.wav', 2, 1, 0, 2, '"+checkgroupid+"')";
			System.out.println("9-2:"+sql);
			nResult = statement.executeUpdate(sql);
			if (nResult < 1){	throw new Exception(l.x("[FeatureService���� ����] '","[FeatureService Properties Error] '")+e164+l.x("'�� FeatureService ��������� �����Ͽ����ϴ�. �ܸ� ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

			//hc-add : 161103 : Virtual CID
        	sql = " insert into table_featureservice(e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) "; 
			sql = sql + "  values('" + e164 + "', 5431, 5431 , '3,"+ e164 +",', 2, 1, 0, 2, '"+checkgroupid+"')";
			System.out.println("9-3:"+sql);
			nResult = statement.executeUpdate(sql);
			if (nResult < 1){	throw new Exception(l.x("[FeatureService���� ����] '","[FeatureService Properties Error] '")+e164+l.x("'�� FeatureService ��������� �����Ͽ����ϴ�. �ܸ� ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

			
            /***** �������̺� ���********/
            sql = "SELECT COUNT(*) FROM table_Auth WHERE  Protocol = 2 AND EndpointID = '" + endpointID +"' AND checkgroupid='"+checkgroupid+"'";
            rs = statement.executeQuery(sql);
            if(rs.next()==true)	count = rs.getInt(1);
            rs.close();
            if (count > 0){	throw new Exception(l.x("[�������� ����] '","[Auth Properties Error] '")+e164+l.x("'�� ���������� �ֽ��ϴ�. ����� �����Ͽ����ϴ�.","' have Auth Properties. Insertion failed."));	}

            
            /***** IMS ���� �߰�(IMS ����̸� username ���� authID + @ + ������, Descriptor �׸� �߰�) 20121101 ********/
			String authUserName = "";
            if("ACRO-CBS-IMS".equals(goodsName_Type)||"ACRO-HCBS-IMS".equals(goodsName_Type)){
            	authUserName = authID + "@" + domainId;
			}else{
				authUserName = authID;
			}
            //sql   = "INSERT INTO table_Auth(E164, protocol , EndpointID, password, Authmode, username, IPAddress, IPPort) ";
            //sql += " VALUES ('0',2,'" + endpointID  + "', '" + authPass + "', " + authMode + ", '" + authUserName  + "', '" + authIP  + "', " + nAuthPort + ")";
            sql   = "INSERT INTO table_Auth(E164, protocol , EndpointID, password, Authmode, username, IPAddress, IPPort, Descriptor, checkgroupid) ";
            sql += " VALUES ('0',2,'" + endpointID  + "', '" + authPass + "', " + authMode + ", '" + authUserName  + "', '" + authIP  + "', " + nAuthPort + ", '"+beforeAuthPass+"', '"+checkgroupid+"')";
            System.out.println("10:"+sql);
            nResult = statement.executeUpdate(sql);
            if (nResult < 1){	throw new Exception(l.x("[�������� ����] '","[Auth Properties Error] '")+e164+l.x("'�� �ܸ� ������������� �����Ͽ����ϴ�. �ܸ� ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

            
            /***** ��������̺�(table_subscriber) ���********/
            sql = "SELECT COUNT(*) FROM table_subscriber WHERE id = '" + endpointID +"' ";
            rs = statement.executeQuery(sql);
            if(rs.next()==true)	count = rs.getInt(1);
            rs.close();
            if (count > 0){	throw new Exception(l.x("[����� ��� ����] '","[Auth Properties Error] '")+endpointID+l.x("'�� ����� ������ �ֽ��ϴ�. ����� �����Ͽ����ϴ�.","' have Auth Properties. Insertion failed."));	}

            sql = "INSERT INTO table_subscriber(id, loginlevel , pwd, phonenum, name, position, department, mobile, homenumber, extension, mailaddress, checkgroupid) ";
            sql = sql + " VALUES ('" + endpointID  + "', 1, '" + pwd  + "', '" + e164  + "', '" + name  + "', '" + position  + "', " + department  + ", ";
            sql = sql + " '" + mobile  + "', '" + homenumber  + "', '" + extensionNum  + "', '" + mailaddress  + "', '"+checkgroupid+"')";
            System.out.println("11:"+sql);
            nResult = statement.executeUpdate(sql);
            if (nResult < 1){	throw new Exception(l.x("[����� ��� ����] '","[Auth Properties Error] '")+endpointID+l.x("'�� ����� ��������� �����Ͽ����ϴ�. ����� ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            

            
            System.out.println("�����1 :"+returnVal);
            
            statement.endTransaction(true);			// commit ó��
	        returnVal = true;
	        System.out.println("�����2 :"+returnVal);
        } catch (Exception e) {
        	statement.endTransaction(false);		// rollback ó��
            e.printStackTrace();
            returnVal = false;
            System.out.println("�����3 :"+returnVal);
        } finally {
            //�Ҵ���� DataStatement ��ü�� �ݳ�
            if (statement != null ) ConnectionManager.freeStatement(statement);
        }
    	
	if(returnVal){
		// ############### LogHistory ó��  ###############
// 		String		strIp		= request.getRemoteAddr();
// 		LogHistory	logHistory 	= new LogHistory();
// 		int int_result = logHistory.LogHistorySave(userID+"|82|���γ�����ȣ/�ܸ����� ("+ei64+" ��)|1|"+strIp);
		// ##############################################
		
		String[] e164s = StringUtil.getParser(ei64, "");
		StringBuffer jsArray = new StringBuffer();
		for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\""+endPointID+"\",\""+extension+"\",\""+ipcsDTO.getIpAddress()+"\",\""+ipcsDTO.getMac()+"\",\""+ipcsDTO.getAnswerService().substring(3, 4)+"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
        //out.print("<script>parent.goInsertDone("+jsArray.toString()+");</script>");
        
		System.out.println("���强��------^^");
		out.clear();
		out.print("OK:"+jsArray.toString());
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
