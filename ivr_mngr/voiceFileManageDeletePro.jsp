
<%@page import="java.text.SimpleDateFormat"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.FeatureServiceDTO" %>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="java.io.*,java.util.*,java.security.*,sun.misc.*,java.io.File"%>
<%@ page import="java.sql.ResultSet, business.LogHistory"%>
<%@page import="bizportal.nasacti.ipivr.common.FileUtil"%>
<%@page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
<%@page import="bizportal.nasacti.ipivr.dao.VoiceDAO"%>
<%@page import="bizportal.nasacti.ipivr.common.FileNameChecker"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="bizportal.nasacti.ipivr.common.IpivrConfig"%>
<%@page import="dao.system.CommonDAO"%>

<% 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

// String[] e164s  = null;//StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

//서버로부터 DataStatement 객체를 할당
DataStatement stmt = null;
String sql = "";
int iRtn = -1;
try {
	if( Str.CheckNullString(System.getProperties().getProperty("os.name")).toLowerCase().indexOf("win")!=-1 ){//Debug code
		//setupIpivrConfigInit();
		ServletConfig svlconfig = getServletConfig(); 
	    //url= svlconfig.getInitParameter("url");
	    ServletContext con = this.getServletContext();
	    IpivrConfig cfg = IpivrConfig.getInstance();
	    cfg.strRealPath = 1==1?"D:/mnt/data_acromate_home/realpath/": con.getRealPath("");
	
	    cfg.maxUploadSize = 1==1?20: Integer.parseInt(svlconfig.getInitParameter("MaxUploadSize-MB"));              
	    cfg.strAnCodePath = 1==1?"D:/mnt/data_acromate_home/acroms_SoundV_Ancode": svlconfig.getInitParameter("AnCodePath");
	    cfg.strFileMentPath = 1==1?"D:/mnt/data_acromate_home/acroms_SoundV_FileMent": svlconfig.getInitParameter("FileMentPath");
	    cfg.strResponseModeKey = 1==1?"202": svlconfig.getInitParameter("ResponseModeKey");
	    cfg.strKeyActionVisibleType = 1==1?"1": svlconfig.getInitParameter("KeyActionVisibleType");
	}
	String strSaveFolder = StringUtil.null2Str(request.getSession(false).getAttribute("login.strIpcsFilePath"), "") + "/fileupwav" ;
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	String strWIndex = request.getParameter("wIndex");
	String strWFile = request.getParameter("wFile");
	
	try{
		sql = " DELETE FROM nasa_wav \n"; 
		sql += " WHERE w_index = %s ";
		sql = String.format(sql
				, strWIndex
				);
		System.out.println("sql: \n"+ sql);
		iRtn = stmt.executeUpdate(sql);
		//if (nResult < 0){	throw new Exception(l.x("[통화연결음 등록] '","[Auth Properties Error] '")+l.x("'통화연결음 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
 		if (iRtn > 0){
			iRtn = 1;
			sql = " UPDATE nasa_systemupdate SET su_check = 'Y' ";
			System.out.println("SQL :\n"+sql);
   			stmt.executeUpdate(sql);
   			//if (nResult < 0){	throw new Exception(l.x("[ADD MRBT 통화연결음 등록] '","[Auth Properties Error] '")+l.x("'ADD MRBT 통화연결음 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
		}
					// ############### LogHistory 처리  #############
//	 				LogHistory	logHistory 	= new LogHistory();
//	 				logHistory.LogHistoryGetIpSave(userID+"|83|일반통화 연결음 ("+strE164+" 번)|1|");
					// ##############################################
		        
	}catch(Exception ex){
		iRtn = -1;
	}finally{
		//if(stmt!=null) ConnectionManager.freeStatement(stmt);
	}
			
			switch(iRtn) {
				case 1:// ok
					//request.setAttribute("msg", "??????????.");
					FileUtil.delete(strSaveFolder + "/" + strWFile);
					if (1==1) {
// 		        		for(String strE164 : e164s)
// 		        	       	if( (strE164 = strE164.trim()).length()>0 ){
// 		        	       		if(jsArray.length()==0)	jsArray.append("[{params:");
// 		        	       		else					jsArray.append(",{params:");
		        	       		
// 		        	       		jsArray.append("[\""+strE164+"\",\""+strOriginalFileName+"\"]}");
// 		        	       	}
// 		                if(jsArray.length()>0)	jsArray.append("]");

						//SimpleDateFormat format1 = new SimpleDateFormat("yyyy-MM-dd"/* "yyyy-MM-dd HH:mm:ss" */);
						//String date1 = format1.format(Calendar.getInstance().getTime());
						
		                jsArray.setLength(0);
		                jsArray.append("[{params:");
		                jsArray.append("[");
		                jsArray.append("\""+strWIndex+"\"]}");
		                jsArray.append("]");
		        	}
%>
    <script>
        alert("삭제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%				
					break;
				case -1:// exception
					//request.setAttribute("msg", "저장이 실패하였습니다.");
%>
	<script>
        alert("삭제가 실패하였습니다.");
    </script>
<%					
					break;
			}
	
	if (stmt != null ) stmt.endTransaction(true);
} catch(Exception e) {
	e.printStackTrace();
	if(iRtn < 1){
		// commit 처리
		if (stmt != null ) stmt.endTransaction(false);
	}
%>
	<script>
        alert("삭제가 실패하였습니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%	
} finally {
  	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}
%>