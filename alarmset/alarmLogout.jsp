<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dao.addition.AlarmServiceDAO"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*" %>

<%
             HttpSession ses = request.getSession(false);
             if(ses != null){
            	 ses.setAttribute("login.user", null) ;
           	  	 ses.setAttribute("login.name", null) ;
           	  	 ses.setAttribute("login.level", null) ;
           	  	 ses.setAttribute("login.sysgroupid", null) ;
           	  	 //ses.invalidate();  //세션삭제
             }
%>
<script>
        alert("정상 로그아웃 되었습니다.");
        /* document.location.href="./alarmTimeList.jsp"; */
        parent.location.href = parent.location.href;
</script>
