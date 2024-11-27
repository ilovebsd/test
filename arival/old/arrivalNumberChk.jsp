<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="useconfig.AddServiceList"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String 	e164  		= Str.CheckNullString(scDTO.getPhoneNum()).trim();
String 	blockType	= new String(Str.CheckNullString(request.getParameter("hiBlockType1")).getBytes("8859_1"), "euc-kr");	// �߽����� ����
String 	blockType2	= new String(Str.CheckNullString(request.getParameter("hiBlockType2")).getBytes("8859_1"), "euc-kr");	// ���� �߽Ź�ȣ ����
String 	blockNumber	= new String(Str.CheckNullString(request.getParameter("hiBlockNumber")).getBytes("8859_1"), "euc-kr");	// �߽����� ��ȣ
String 	description	= new String(Str.CheckNullString(request.getParameter("hiDescription")).getBytes("8859_1"), "euc-kr");	// �߽����� ��ȣ ����

try{
	boolean returnVal 		= false;
	//�߽� ���� ���۹�ȣ �ߺ� üũ
    AddServiceList addServiceList = new AddServiceList();
    int count = addServiceList.getBlockPrefixChk(blockNumber);					// �߽� ���� ���۹�ȣ �ߺ� ����

    if(count > 0){
%>
	<script>
        alert("�̹� ��ϵ� �߽� ���� ��ȣ �Դϴ�!");
        //parent.hiddenAdCodeDiv();
    </script>
<%
    }else{
    	returnVal = addServiceList.arrivalNumberSave(blockNumber, description, blockType, blockType2);
		if (returnVal) {
			System.out.println(" �߽� ���� E164 ��� ���� .......");
%>
			<script>
			parent.location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceList.jsp";
			</script>
<%			
		}else{
			System.out.println(" �߽� ���� E164 ��� ���� .......");
%>
			<script>
			alert("���� �� ������ �߻��Ͽ����ϴ�.");
			</script>
<%
		}			    	
%>
	<!--
    <script>
        parent.goSave();
    </script>
    -->
<%
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
}	
%>