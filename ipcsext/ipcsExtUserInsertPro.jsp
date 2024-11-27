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

String 	groupid		= new String(request.getParameter("hiGroupID").getBytes("8859_1"), "euc-kr").trim();		// 가입자 그룹ID
String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr").trim();		// 도메인
String 	zoneCode	= new String(request.getParameter("hiZoneCode").getBytes("8859_1"), "euc-kr").trim();		// 망관리
String 	prefixID	= new String(request.getParameter("hiPrefixID").getBytes("8859_1"), "euc-kr").trim();		// 번호정책
String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr").trim();	// SIP 단말ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr").trim();			// 전체 전화번호
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr").trim();		// 내선번호
String 	areacode	= new String(request.getParameter("hiAreaCode").getBytes("8859_1"), "euc-kr").trim();		// 지역번호
String	e164Route2	= new String(request.getParameter("hiE164Route2").getBytes("8859_1"), "euc-kr").trim();	// 지역번호 제외한 전화번호
String 	numberType	= new String(request.getParameter("hiNumberType").getBytes("8859_1"), "euc-kr").trim();	// 내선번호 유형(1:직통번호, 2:단축번호)
String 	pwd			= new String(request.getParameter("hiPwd").getBytes("8859_1"), "euc-kr").trim();			// 비밀번호
String 	name		= request.getParameter("hiName").trim();													// 이름
String 	position	= request.getParameter("hiPosition").trim();												// 직급

String 	tempDept	= new String(request.getParameter("hiDept").getBytes("8859_1"), "euc-kr").trim();			// 부서ID|ParentID
String 	mobile		= new String(request.getParameter("hiMobile").getBytes("8859_1"), "euc-kr").trim();		// 휴대폰
String 	homeNumber	= new String(request.getParameter("hiHomeNumber").getBytes("8859_1"), "euc-kr").trim();	// 집전화
String 	Mail		= new String(request.getParameter("hiMail").getBytes("8859_1"), "euc-kr").trim();			// 메일

String 	authE164	= new String(request.getParameter("hiAuthE164").getBytes("8859_1"), "euc-kr").trim();		// 전화번호 인증 여부
String 	authIPChk	= new String(request.getParameter("hiAuthIPChk").getBytes("8859_1"), "euc-kr").trim();		// IP인증 여부
String 	authIP		= new String(request.getParameter("hiAuthIP").getBytes("8859_1"), "euc-kr").trim();		// IP인증
String 	authPortChk	= new String(request.getParameter("hiAuthPortChk").getBytes("8859_1"), "euc-kr").trim();	// Port인증 여부
String 	authPort	= new String(request.getParameter("hiAuthPort").getBytes("8859_1"), "euc-kr").trim();		// Port인증
String 	authMd5		= new String(request.getParameter("hiAuthMd5").getBytes("8859_1"), "euc-kr").trim();		// MD5 인증 여부
String 	authRegister= new String(request.getParameter("hiAuthRegister").getBytes("8859_1"), "euc-kr").trim();	// Register 유형
String 	authStale	= new String(request.getParameter("hiAuthStale").getBytes("8859_1"), "euc-kr").trim();		// Stale 여부
String 	authInvite	= new String(request.getParameter("hiAuthInvite").getBytes("8859_1"), "euc-kr").trim();	// Invite 여부
String 	authID		= new String(request.getParameter("hiAuthID").getBytes("8859_1"), "euc-kr").trim();		// 인증ID
String 	authPass	= new String(request.getParameter("hiAuthPass").getBytes("8859_1"), "euc-kr").trim();		// 비밀번호

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

//String 	userID		= new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr").trim();		// 로그인 ID

//String 	hash_Chk 	= new String(request.getParameter("hiHash_Chk").getBytes("8859_1"), "euc-kr").trim();		// MD5 Hash (IMS용) 사용 (0: 미사용, 1: 사용) (2012.1.31)

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

//System.out.println("New 사용자 이름 ############ : "+name);
//System.out.println("New 사용자 직위 ############ : "+position);
//System.out.println("한글처리부분 1  ############ : "+macDisplay);
//System.out.println("한글처리부분 2  ############ : "+macDisplay2);

IpcsUserDTO ipcsDTO = new IpcsUserDTO();
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);
try{
//ipcs 내선번호 중복 체크 처리부분
IpcsList 	ipcsList = new IpcsList();
//********** ipcsList **********//
int extension_cnt = 0;//ipcsList.getCount(stmt, extension);
ResultSet rs 	= null;
String sql = "SELECT count(*) FROM table_e164 "; 
sql = sql + "\n WHERE extensionnumber = '"+extension+"' AND checkgroupid = '"+checkgroupid+"'";
String groupExtCode = "" ;

try {
    if (stmt != null) {
//    	System.out.println("################ 내선번호 체크 SQL 1 : "+sql);
        rs = stmt.executeQuery(sql);
        if (rs.next()) extension_cnt = rs.getInt(1); 
        rs.close();
        
    	sql = "select extensionGroupNum from table_SubscriberGroup WHERE checkgroupid = '"+checkgroupid+"' ";
    	rs = stmt.executeQuery(sql);
//        System.out.println("################ 내선번호 체크 SQL 2 : "+sql2);
        if (rs.next()) groupExtCode = rs.getString(1); 
        rs.close();

        if(extension_cnt==0){
            sql = "SELECT count(*) FROM table_localprefix where prefixtype = 2 and startprefix = '"+groupExtCode+extension+"' ";// +" AND checkgroupid = '"+checkgroupid+"'";
            rs = stmt.executeQuery(sql);
//            System.out.println("################ 내선번호 체크 SQL 2 : "+sql2);
            if (rs.next()) extension_cnt = rs.getInt(1); 
            rs.close();
        }
    } else            
        System.out.println("데이터베이스에 연결할 수 없습니다.");            
} catch (Exception e) {
    System.out.println(e.getMessage());
} finally {
    try {
        if (rs != null)
            rs.close();
    } catch (Exception e) {}
}

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
	    	numberType			= ipcsDTO.getNumberType().trim();		// NumberType(1:직통번호, 2:단축번호)
	    	System.out.println("numberType:"+numberType);
	    	// SIPEndPoint 테이블
	    	String 	domainId			= ipcsDTO.getDomainId().trim();			// 도메인 
	    	zoneCode			= ipcsDTO.getZoneCode().trim();			// Nat Zone Code
	    	int 	endPointClass		= ipcsDTO.getEndPointClass();			// 
	    	int 	dynamicFlag			= ipcsDTO.getDynamicFlag();				// 
	    	int 	multiEndpoint		= ipcsDTO.getMultiEndpoint();			// 해당 EndpointID 를 여러 단말이 사용 가능여부
	    	int 	dtmfType			= ipcsDTO.getDtmfType();				// SIP 단말의 DTMF 처리방식
	    	int 	options				= ipcsDTO.getOptions();					// 
	    	// E164 테이블
	    	String 	e164				= ipcsDTO.getE164().trim();				// E164
	    	String 	areaCode			= ipcsDTO.getAreaCode().trim();			// 지역번호
	    	int 	isGroup				= ipcsDTO.getIsGroup();					// 가입자 구분(개인/회사)
	    	String 	groupId				= ipcsDTO.getGroupId().trim();			// 소속그룹
//	    	String	subId				= ipcsDTO.getSubId().trim();			// 하위그룹(Pick Up그룹)
	    	String	subId				= checkgroupid;							// 하위그룹(Pick Up그룹)
	    	String 	extensionNum		= ipcsDTO.getExtensionNum().trim();		// 내선번호
	    	String 	callerService		= ipcsDTO.getCallerService().trim();	// 부가서비스 Caller 서비스
	    	String 	answerService		= ipcsDTO.getAnswerService().trim();	// 부가서비스 Caller 서비스
	    	String 	commonService		= ipcsDTO.getCommonService().trim();	// 부가서비스 Caller 서비스
	    	int 	chargeType			= ipcsDTO.getChargeType();				// 과금타입
	    	int 	endpointRelationType= ipcsDTO.getEndpointRelationType();	// 단말정보 등록여부
	    	int 	startFlag			= ipcsDTO.getStartFlag();				// 개통여부
	    	String 	mailBox				= ipcsDTO.getMailBox().trim();			// 메일박스ID
	    	// E164Route 테이블
	    	String 	routingNumber		= ipcsDTO.getRoutingNumber().trim();	// Route 할때 비교되는 번호
	    	String 	endpointID			= ipcsDTO.getEndpointID().trim();		// 연결된 단말기 ID
	    	int 	protocol			= ipcsDTO.getProtocol();				// 프로토콜 타입
	    	int 	routingNumberType	= ipcsDTO.getRoutingNumberType();		// Route 유형
	    	int 	priority			= ipcsDTO.getPriority();
	    	e164Route2			= ipcsDTO.getE164Route2().trim();		// Route 할때 비교되는 번호
	    	// Subscriber 테이블
	    		pwd					= ipcsDTO.getPwd();						// 비밀번호
	    		name				= ipcsDTO.getName();					// 이름
	    		position			= ipcsDTO.getPosition();				// 직급
	    	int 	department			= ipcsDTO.getDepartment();				// 부서
	    		mobile				= ipcsDTO.getMobile();					// 핸드폰
	    	String 	homenumber			= ipcsDTO.getHomeNumber();				// 집전화
	    	String 	mailaddress			= ipcsDTO.getMailaddress();				// 메일주소
	    	// Auth 테이블
	    	int 	authMode			= ipcsDTO.getAuthMode();				// 인증 Mode
	    	 	authIP				= ipcsDTO.getIpAddress();				// 인증 IP
	    	int 	nAuthPort			= ipcsDTO.getIpPort();					// 인증 Port
	    		authID				= ipcsDTO.getUserName();				// 인증 ID
	    		authPass			= ipcsDTO.getPassWord();				// 인증 비밀번호	    	
	    	// table_provision 테이블
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
	    	
	    	//System.out.println("비밀번호 로그 $$$$$$$$$$$$$$$ : "+pwd);
	    	//System.out.println("사용자 이름 $$$$$$$$$$$$$$$ : "+name);
	    	//System.out.println("사용자 직위 $$$$$$$$$$$$$$$ : "+position);
	    	
	    	endpointID = endpointID + "@" + domainId + ":5060";
	    	
	    	sql 		= "";//String			sql 		= "";
	    	rs 			= null;//ResultSet 		rs 			= null;
	    	// 서버로부터 DataStatement 객체를 할당
	    	//String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	    	statement 	= ConnectionManager.allocStatement("SSW", sesSysGroupID);
	    	statement.stxTransaction();
	    	
	    	/***** table_SIPENDPOINT 에 단말 ID 저장 ********/
	    	sql = "INSERT INTO table_SIPENDPOINT(EndpointID, EndpointClass, DomainID, DynamicFlag, ZoneCode, MultiEndpoint, DtmfType, Options, checkgroupid) VALUES( ";
	    	sql +=	"'" + endpointID +"',"+ "33" +", '" + domainId + "',0, '" + zoneCode + "',  " + multiEndpoint + "," + dtmfType + ", " + options + ", '"+checkgroupid+"')";
	        int nResult = 0;
	        System.out.println("0:"+sql);
	        nResult = statement.executeUpdate(sql);
	        if (nResult < 1){
	        	throw new Exception(l.x("[단말ID 오류] '","[Phone ID Error] '") +endpointID+ l.x("' 단말 ID 등록이 실패하였습니다.","' Phone ID Insertion failed."));	
	        }
	    
	    	System.out.println("numberType:"+numberType);
	        /***** TABLE_E164 에 저장 ********/
	        if(numberType.equals("1")){			// NumberType(1:직통번호, 2:단축번호)
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
	        	// 단축번호인 경우 내선번호에 E164를 입력함.
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
			if (nResult < 1){	throw new Exception(l.x("[전화번호 오류] 단말에 ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" 전화번호 할당이 실패하였습니다."," join failed."));	}
			
            /***** table_E164Route 에서 해당 전화번호가 다른 단말에 등록된 전화번호인지 확인 ********/
	        sql = "SELECT COUNT(*) FROM table_E164Route WHERE E164 = '"+ e164 +"' AND checkgroupid='"+checkgroupid+"'";
            rs = statement.executeQuery(sql);
            if(rs.next()) count = rs.getInt(1);
            System.out.println("table_E164Route 검색번호 : "+e164);
            System.out.println("table_E164Route 검색결과 : "+count);
            rs.close();
	        
            System.out.println("NumberType(1:직통번호, 2:단축번호) : "+numberType);
            if(numberType.equals("1")){			// NumberType(1:직통번호, 2:단축번호)
	            /***** 지역번호포함E164 등록********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol , EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + e164  + "','" + e164  + "', 2,'" + endpointID + "',1, 1, '"+checkgroupid+"') ";
	            System.out.println("1:"+sql);
	            nResult = statement.executeUpdate(sql);
	            if (nResult < 1){	throw new Exception(l.x("[전화번호 오류] 단말에 ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" 전화번호 할당이 실패하였습니다."," join failed."));	}
	
	            /***** 지역번호없는E164 등록********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol , EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + e164Route2 + "','" + e164  + "', 2,'" + endpointID + "',2, 1, '"+checkgroupid+"') ";
	            System.out.println("2:"+sql);
	            nResult = statement.executeUpdate(sql);
	            if (nResult < 1){	throw new Exception(l.x("[전화번호 오류] 단말에 ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" 전화번호 할당이 실패하였습니다."," join failed."));	}
            
                /***** 그룹번호포함 내선번호 등록********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol, EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + groupExtCode + extensionNum + "','" + e164  + "', 2,'" + endpointID + "',5, 1, '"+checkgroupid+"') ";
                System.out.println("4:"+sql);
                nResult = statement.executeUpdate(sql);
                if (nResult < 1){	throw new Exception(l.x("[내선 그룹번호 오류] 단말에 ","[Extension Group Number Error] In the Phone, the Number")+endpointID+ l.x(" 전화번호 할당이 실패하였습니다."," join failed."));	}	            
            }else{
	            /***** 지역번호포함E164 등록********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol , EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            sql +=	"  VALUES ('" + e164  + "','" + e164  + "', 2,'" + endpointID + "',1, 1, '"+checkgroupid+"') ";
	            System.out.println("1:"+sql);
	            nResult = statement.executeUpdate(sql);
	            if (nResult < 1){	throw new Exception(l.x("[전화번호 오류] 단말에 ","[Phone Number Error]  In the Phone, the Number")+endpointID+ l.x(" 전화번호 할당이 실패하였습니다."," join failed."));	}

            	/***** 그룹번호포함 단축 내선번호 등록********/
	            sql = "INSERT INTO table_E164Route ";
	            sql += "(RoutingNumber, E164, protocol, EndpointID, RoutingNumberType, Priority, checkgroupid) ";
	            //sql +=	"  VALUES ('" + groupExtCode + e164 + "','" + e164 + "', 2,'" + endpointID + "',5, 1) ";
	            sql +=	"  VALUES ('" + groupExtCode + extensionNum + "','" + e164 + "', 2,'" + endpointID + "',5, 1, '"+checkgroupid+"') ";
	            System.out.println("4:"+sql);
                nResult = statement.executeUpdate(sql);
                if (nResult < 1){	throw new Exception(l.x("[내선 그룹번호 오류] 단말에 ","[Extension Group Number Error] In the Phone, the Number")+endpointID+ l.x(" 전화번호 할당이 실패하였습니다."," join failed."));	}            	
            }

            // Auto CallBack Service 추가 2009.08.22
            sql   = "INSERT INTO table_featureservice(E164, ServiceNo, Priority, checkgroupid) VALUES('" + e164  + "', 5282, 5282, '"+checkgroupid+"')";            
            System.out.println("9-1:"+sql);
            nResult = statement.executeUpdate(sql);
            if (nResult < 1){	throw new Exception(l.x("[FeatureService정보 오류] '","[FeatureService Properties Error] '")+e164+l.x("'는 FeatureService 정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
            
            
            // Default 통화 대기음 추가 2011.04.18
        	sql = " insert into table_featureservice(e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) "; 
			sql = sql + "  values('" + e164 + "', 5031, 5031 , 'default_moh.wav', 2, 1, 0, 2, '"+checkgroupid+"')";
			System.out.println("9-2:"+sql);
			nResult = statement.executeUpdate(sql);
			if (nResult < 1){	throw new Exception(l.x("[FeatureService정보 오류] '","[FeatureService Properties Error] '")+e164+l.x("'는 FeatureService 정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

			//hc-add : 161103 : Virtual CID
        	sql = " insert into table_featureservice(e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) "; 
			sql = sql + "  values('" + e164 + "', 5431, 5431 , '3,"+ e164 +",', 2, 1, 0, 2, '"+checkgroupid+"')";
			System.out.println("9-3:"+sql);
			nResult = statement.executeUpdate(sql);
			if (nResult < 1){	throw new Exception(l.x("[FeatureService정보 오류] '","[FeatureService Properties Error] '")+e164+l.x("'는 FeatureService 정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

			
            /***** 인증테이블 등록********/
            sql = "SELECT COUNT(*) FROM table_Auth WHERE  Protocol = 2 AND EndpointID = '" + endpointID +"' AND checkgroupid='"+checkgroupid+"'";
            rs = statement.executeQuery(sql);
            if(rs.next()==true)	count = rs.getInt(1);
            rs.close();
            if (count > 0){	throw new Exception(l.x("[인증정보 오류] '","[Auth Properties Error] '")+e164+l.x("'는 인증정보가 있습니다. 등록이 실패하였습니다.","' have Auth Properties. Insertion failed."));	}

            
            /***** IMS 관련 추가(IMS 장비이면 username 값이 authID + @ + 도메인, Descriptor 항목 추가) 20121101 ********/
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
            if (nResult < 1){	throw new Exception(l.x("[인증정보 오류] '","[Auth Properties Error] '")+e164+l.x("'는 단말 인증정보등록이 실패하였습니다. 단말 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}

            
            /***** 사용자테이블(table_subscriber) 등록********/
            sql = "SELECT COUNT(*) FROM table_subscriber WHERE id = '" + endpointID +"' ";
            rs = statement.executeQuery(sql);
            if(rs.next()==true)	count = rs.getInt(1);
            rs.close();
            if (count > 0){	throw new Exception(l.x("[사용자 등록 오류] '","[Auth Properties Error] '")+endpointID+l.x("'는 사용자 정보가 있습니다. 등록이 실패하였습니다.","' have Auth Properties. Insertion failed."));	}

            sql = "INSERT INTO table_subscriber(id, loginlevel , pwd, phonenum, name, position, department, mobile, homenumber, extension, mailaddress, checkgroupid) ";
            sql = sql + " VALUES ('" + endpointID  + "', 1, '" + pwd  + "', '" + e164  + "', '" + name  + "', '" + position  + "', " + department  + ", ";
            sql = sql + " '" + mobile  + "', '" + homenumber  + "', '" + extensionNum  + "', '" + mailaddress  + "', '"+checkgroupid+"')";
            System.out.println("11:"+sql);
            nResult = statement.executeUpdate(sql);
            if (nResult < 1){	throw new Exception(l.x("[사용자 등록 오류] '","[Auth Properties Error] '")+endpointID+l.x("'는 사용자 정보등록이 실패하였습니다. 사용자 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}            

            
            System.out.println("결과값1 :"+returnVal);
            
            statement.endTransaction(true);			// commit 처리
	        returnVal = true;
	        System.out.println("결과값2 :"+returnVal);
        } catch (Exception e) {
        	statement.endTransaction(false);		// rollback 처리
            e.printStackTrace();
            returnVal = false;
            System.out.println("결과값3 :"+returnVal);
        } finally {
            //할당받은 DataStatement 객체는 반납
            if (statement != null ) ConnectionManager.freeStatement(statement);
        }
    	
	if(returnVal){
		// ############### LogHistory 처리  ###############
// 		String		strIp		= request.getRemoteAddr();
// 		LogHistory	logHistory 	= new LogHistory();
// 		int int_result = logHistory.LogHistorySave(userID+"|82|개인내선번호/단말관리 ("+ei64+" 번)|1|"+strIp);
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
        
		System.out.println("저장성공------^^");
		out.clear();
		out.print("OK:"+jsArray.toString());
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
