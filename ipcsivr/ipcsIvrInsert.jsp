<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.StringUtil"%>
<%@ page import="waf.*"%>
<%@ page import="dto.ipcs.IpcsIvrDTO" %>
<%@ page import="dao.ipcs.IpcsIvrDAO" %>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.acromate.util.Str"%>
<meta http-equiv='Content-type' content='text/html; charset=euc-kr'>

<%
System.out.println("00000");

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

response.setCharacterEncoding("euc-kr"); 

boolean returnVal 	= false;

String 	groupid		= new String(request.getParameter("hiGroupID").getBytes("8859_1"), "euc-kr");		// 가입자 그룹ID
String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr");		// 도메인
String 	zoneCode	= new String(request.getParameter("hiZoneCode").getBytes("8859_1"), "euc-kr");		// 망관리
String 	prefixID	= new String(request.getParameter("hiPrefixID").getBytes("8859_1"), "euc-kr");		// 번호정책
//String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// SIP 단말ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// 전체 전화번호
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr");		// 내선번호
String 	areacode	= new String(request.getParameter("hiAreaCode").getBytes("8859_1"), "euc-kr");		// 지역번호
String	e164Route2	= new String(request.getParameter("hiE164Route2").getBytes("8859_1"), "euc-kr");	// 지역번호 제외한 전화번호
String 	numberType	= new String(request.getParameter("hiNumberType").getBytes("8859_1"), "euc-kr");	// 내선번호 유형(1:직통번호, 2:단축번호)
String 	scCompany	= new String(request.getParameter("hiScCompany").getBytes("8859_1"), "utf-8");		// 음성안내 그룹명

System.out.println("지역번호 제외한 전화번호2 : "+e164Route2);

IpcsIvrDTO ipcsDTO = new IpcsIvrDTO();

try{
	//String 	endPointID = "ACRO_MS_";
	String 	endPointID = ei64;			// 임시 테스트용으로 E164 으로 처리함 (090212)
	
	// NASA_TRUNK_SET 테이블
	ipcsDTO.setSystemIdx(1);
	ipcsDTO.setIvrTel(ei64);
	ipcsDTO.setAuthId(endPointID);
	ipcsDTO.setSswReg("Y");
	ipcsDTO.setSswDomainName(domainID);
	ipcsDTO.setSswLocalPort(5040);
	ipcsDTO.setSswRemotePort(5060);
	ipcsDTO.setSswProtocol("SIP");
	ipcsDTO.setSswProtocolType("U");
	ipcsDTO.setSswExpires(3600);
	ipcsDTO.setScCompany(scCompany);
	ipcsDTO.setUseYN("Y");
	ipcsDTO.setTrunkType("N");
	// E164 테이블	
	ipcsDTO.setE164(ei64);
	ipcsDTO.setAreaCode(areacode);
	ipcsDTO.setIsGroup(2);
	ipcsDTO.setGroupId(groupid);
//	ipcsDTO.setSubId(pickUpID);
//	ipcsDTO.setSubId(dept);
	ipcsDTO.setExtensionNum(extension);
	ipcsDTO.setCallerService("0000000000000000000000000000000000000000000000000000000000000000");			// *************************************
	ipcsDTO.setAnswerService("0000000000000000000000000000000000000000000000000000000000000000");			// *************************************
	ipcsDTO.setCommonService("01010000100000000000000000000000");			// *************************************
	ipcsDTO.setChargeType(0);
	ipcsDTO.setEndpointRelationType(2);		// 단말기 등록 여부		*************************************
	ipcsDTO.setStartFlag(1);				// 개통 여부		*************************************
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
	ipcsDTO.setMultiEndpoint(0);			// 해당 EndpointID 를 여러 단말이 사용 가능여부		*************************************
	ipcsDTO.setDtmfType(0);					// *************************************
	ipcsDTO.setOptions(0);
	
	ipcsDTO.setNumberType(numberType);
	
	IpcsIvrDAO ipcsDao = new IpcsIvrDAO();
	returnVal = ipcsDao.ipcsIvrInsert(ipcsDTO);
	
	if(returnVal){
		System.out.println("저장성공------^^");
		out.clear();
		out.print("OK");
	}else{
		System.out.println("저장실패------ㅜㅜ");
		out.clear();
		out.print("NO");
	}	
	
}catch(Exception ex){
	System.out.println(ex);
}finally{

} 

%>
