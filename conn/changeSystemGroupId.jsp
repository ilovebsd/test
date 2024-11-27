<%@page import="bizportal.nasacti.ipivr.common.IpivrConfig"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*" %>
<%@ page import="webuser.ServerLogin"%>

<% 

//int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );
HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

String strSysGroupId   = StringUtil.null2Str(request.getParameter("groupId"),"");
String strSysGroupName = StringUtil.null2Str(request.getParameter("groupName"),"");

try{
		if (ServerLogin.isLogin()
				//&& ServerLogin.serverLogin==null 
						 ) {
			if(11==1) 
				ConnectionManager.getInstance().setSysGroupID(strSysGroupName, strSysGroupId);
			
// 			String sysGroupId = ConnectionManager.getInstance().getSysGroupID();
// 			String sysGroupName = ConnectionManager.getInstance().getSysGroupName();
			
			IpivrConfig ipivrConfig = IpivrConfig.getInstance();
			
			String voiceFileBasePath = ipivrConfig.voiceFileBasePath +"/"+strSysGroupName;// /data/webapps/MS/v1xx/.. == host/MS/v1xx/..
			
			String strAnCodePath = voiceFileBasePath+"/SoundV/Ancode"; //config.getInitParameter("AnCodePath");        // Ancode
			String strFileMentPath = voiceFileBasePath+"/SoundV/FileMent"; //config.getInitParameter("FileMentPath");  // Filement
			String strIpcsFilePath = voiceFileBasePath+"/ipcs_files"; //ipivrConfig.strRealPath +"/../ipcs_files";		//hc-add : req.chun

			ses.setAttribute("login.name", null) ;// init Company ID
			
			request.getSession(false).setAttribute("login.sysgroupname", strSysGroupName );
			request.getSession(false).setAttribute("login.sysgroupid", strSysGroupId );
			//String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
			
			/* Setup Voice File */
			request.getSession(false).setAttribute("login.voiceFileBasePath", voiceFileBasePath );
			request.getSession(false).setAttribute("login.strAnCodePath", strAnCodePath );
			request.getSession(false).setAttribute("login.strFileMentPath", strFileMentPath );
			request.getSession(false).setAttribute("login.strIpcsFilePath", strIpcsFilePath );
			
			//StaticString.wavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
			//StaticString.userWavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
			String strWavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
			String strUserWavPath = voiceFileBasePath +"/SoundV/FileMent/kor/";
			request.getSession(false).setAttribute("login.strWavPath", strWavPath );
			request.getSession(false).setAttribute("login.strUserWavPath", strUserWavPath );
	    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
	%>
	   <script>
	       	parent.location.href = parent.location.href;
	   </script>
	<%
}	
%>