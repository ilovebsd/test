<%@page import="acromate.common.util.StringUtil"%>
<%@page import="com.acromate.data.DataIO"%>
<%@page import="com.acromate.session.EmsServerAgent"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="com.acromate.session.UserSessionClient"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>

				  <% if(nAllowUser==1) {
                	  	//out.println("<input type=\"button\" name=\"btnLogout\" id=\"user_logout\" style=\"height: 18px\" value=\"로그아웃\" onclick=\"func_logoutCommit(1)\">") ;
                  %>
<script>
	function onChangeSystemGroupId(objSelTag){
		var arr = objSelTag.value.split(',');
		
		if(1==1){
			var form = document.createElement('form');
			
			var input = document.createElement("INPUT");
			input.setAttribute("type", "hidden");
			input.setAttribute("name", "groupId");
			input.setAttribute("value", arr[0]);
			form.appendChild(input);
			
			var input = document.createElement("INPUT");
			input.setAttribute("type", "hidden");
			input.setAttribute("name", "groupName");
			input.setAttribute("value", arr[1]);
			form.appendChild(input);
			
			form.setAttribute("target", "procframe");
			form.setAttribute("method", "post");
			form.setAttribute("action", "../conn/changeSystemGroupId.jsp");
			
			document.body.appendChild(form);
			form.submit();
		}else if(11==1){
			var f   = document.frm;
			
		   	f.target = "procframe";
	        f.action = "../conn/changeSystemGroupId.jsp?groupId="+arr[0]+"&groupName="+arr[1];
	        f.method = "post";
	        f.submit();
		}
	}
</script>
                  		<font style="color: blue;vertical-align: bottom;"><%=authGroupid+(userLevel!=2?"":authGroupid.length()==0?userID:"("+userID+")")%></font>
                	 	<input type="button" name="btnLogout" style="height: 18px" value="로그아웃" onclick="func_logoutCommit(1)">
                	 	<!-- <input type="button" style="height: 18px" value="갱신" onclick="document.location.href = 'subsList.jsp'"> -->
                	 	<input type="button" style="height: 18px" value="갱신" onclick="document.location.href = document.location.href;">
                	 	&nbsp;
                	 	<span>시스템 : </span>
                	 	<select onchange="onChangeSystemGroupId(this);">
                	 	<% 
                	 		//String nowGroupId = ConnectionManager.getInstance().getSysGroupID();
                	 		String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
                	 		
                	 		UserSessionClient userSessionClient = ConnectionManager.getInstance().getSessionClient();
                	 		EmsServerAgent svrAgent = userSessionClient.getEmsServerAgent();
                	 		DataIO dto = svrAgent.getGroups().getHead();//GroupSystem
                	 		StringBuilder sb = new StringBuilder();
                	 		String groupId="", groupName="";
                	 		while(dto!=null){
                	 			dto.getParam("groupId", sb.delete(0, sb.length()) ); 	groupId = sb.toString().replace("'", "");
                	 			dto.getParam("groupName", sb.delete(0, sb.length()) ); 	groupName = sb.toString().replace("'", "");
                	 			if(sesSysGroupID.length()==0){
                	 				sesSysGroupID = groupId;
                	 			}
                	 			out.println("<option value='"+groupId+","+groupName+"' "+(groupId.equals(sesSysGroupID)?"selected":"")+">"+groupName+"</option>");
                	 			dto = dto.m_pNext;
                	 		}
                	 		sb=null;
                	 	%>
                	 	</select>
	           	  <% }
                  	else{ 
	           			//out.println("<input type=\"button\" name=\"btnLogin\" style=\"height: 18px\" value=\"로그인\" onclick=\"document.location.href = '.'\">") ;
	           	  %>
                  		<!-- <input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = 'subsList.jsp'"> -->
                  		<input type="button" name="btnLogin" style="height: 18px" value="로그인" onclick="document.location.href = document.location.href;"> 
	           	  <% } %>
