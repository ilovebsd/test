<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*" %>

<%
             HttpSession ses = request.getSession(false);
             if(ses != null){
           	  	ses.setAttribute("login.name", null) ;
           	  	ses.setAttribute("login.level", null) ;
           	 	ses.setAttribute("login.user", null) ;
           	 	ses.setAttribute("login.sysgroupid", null);
           	 	ses.setAttribute("login.sysgroupname", null);
           	 	
           	 	ses.setAttribute("login.voiceFileBasePath", null );
     			ses.setAttribute("login.strAnCodePath", null );
     			ses.setAttribute("login.strFileMentPath", null );
     			ses.setAttribute("login.strIpcsFilePath", null );
     			
     			ses.setAttribute("login.strWavPath", null );
     			ses.setAttribute("login.strUserWavPath", null );
           	  	 //ses.invalidate();  //���ǻ���
             }
%>
<script>
        alert("���� �α׾ƿ� �Ǿ����ϴ�.");
        document.location.href="../index.jsp";
</script>
