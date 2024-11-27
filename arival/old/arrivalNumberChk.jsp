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
String 	blockType	= new String(Str.CheckNullString(request.getParameter("hiBlockType1")).getBytes("8859_1"), "euc-kr");	// 발신제한 유형
String 	blockType2	= new String(Str.CheckNullString(request.getParameter("hiBlockType2")).getBytes("8859_1"), "euc-kr");	// 지정 발신번호 유형
String 	blockNumber	= new String(Str.CheckNullString(request.getParameter("hiBlockNumber")).getBytes("8859_1"), "euc-kr");	// 발신제한 번호
String 	description	= new String(Str.CheckNullString(request.getParameter("hiDescription")).getBytes("8859_1"), "euc-kr");	// 발신제한 번호 설명

try{
	boolean returnVal 		= false;
	//발신 제한 시작번호 중복 체크
    AddServiceList addServiceList = new AddServiceList();
    int count = addServiceList.getBlockPrefixChk(blockNumber);					// 발신 제한 시작번호 중복 여부

    if(count > 0){
%>
	<script>
        alert("이미 등록된 발신 제한 번호 입니다!");
        //parent.hiddenAdCodeDiv();
    </script>
<%
    }else{
    	returnVal = addServiceList.arrivalNumberSave(blockNumber, description, blockType, blockType2);
		if (returnVal) {
			System.out.println(" 발신 제한 E164 등록 성공 .......");
%>
			<script>
			parent.location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceList.jsp";
			</script>
<%			
		}else{
			System.out.println(" 발신 제한 E164 등록 실패 .......");
%>
			<script>
			alert("저장 중 오류가 발생하였습니다.");
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