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

String 	groupid		= new String(request.getParameter("hiGroupID").getBytes("8859_1"), "euc-kr");		// ������ �׷�ID
String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr");		// ������
String 	zoneCode	= new String(request.getParameter("hiZoneCode").getBytes("8859_1"), "euc-kr");		// ������
String 	prefixID	= new String(request.getParameter("hiPrefixID").getBytes("8859_1"), "euc-kr");		// ��ȣ��å
//String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// SIP �ܸ�ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// ��ü ��ȭ��ȣ
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr");		// ������ȣ
String 	areacode	= new String(request.getParameter("hiAreaCode").getBytes("8859_1"), "euc-kr");		// ������ȣ
String	e164Route2	= new String(request.getParameter("hiE164Route2").getBytes("8859_1"), "euc-kr");	// ������ȣ ������ ��ȭ��ȣ
String 	numberType	= new String(request.getParameter("hiNumberType").getBytes("8859_1"), "euc-kr");	// ������ȣ ����(1:�����ȣ, 2:�����ȣ)
String 	scCompany	= new String(request.getParameter("hiScCompany").getBytes("8859_1"), "utf-8");		// �����ȳ� �׷��

System.out.println("������ȣ ������ ��ȭ��ȣ2 : "+e164Route2);

IpcsIvrDTO ipcsDTO = new IpcsIvrDTO();

try{
	//String 	endPointID = "ACRO_MS_";
	String 	endPointID = ei64;			// �ӽ� �׽�Ʈ������ E164 ���� ó���� (090212)
	
	// NASA_TRUNK_SET ���̺�
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
	// E164 ���̺�	
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
	ipcsDTO.setEndpointRelationType(2);		// �ܸ��� ��� ����		*************************************
	ipcsDTO.setStartFlag(1);				// ���� ����		*************************************
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
	ipcsDTO.setMultiEndpoint(0);			// �ش� EndpointID �� ���� �ܸ��� ��� ���ɿ���		*************************************
	ipcsDTO.setDtmfType(0);					// *************************************
	ipcsDTO.setOptions(0);
	
	ipcsDTO.setNumberType(numberType);
	
	IpcsIvrDAO ipcsDao = new IpcsIvrDAO();
	returnVal = ipcsDao.ipcsIvrInsert(ipcsDTO);
	
	if(returnVal){
		System.out.println("���强��------^^");
		out.clear();
		out.print("OK");
	}else{
		System.out.println("�������------�̤�");
		out.clear();
		out.print("NO");
	}	
	
}catch(Exception ex){
	System.out.println(ex);
}finally{

} 

%>
