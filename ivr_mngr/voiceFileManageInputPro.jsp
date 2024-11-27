
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
ResultSet rs = null;
String sql = "";
int iRtn = -1;
try {
	if( Str.CheckNullString(System.getProperties().getProperty("os.name")).toLowerCase().indexOf("win")!=-1 ){//Debug code
		//setupIpivrConfigInit();
		ServletConfig svlconfig = getServletConfig(); 
	    //url= svlconfig.getInitParameter("url");
	    ServletContext con = this.getServletContext();
	    IpivrConfig cfg = IpivrConfig.getInstance();
	    IpivrConfig.getInstance().strRealPath = 1==1?"D:/mnt/data_acromate_home/realpath/": con.getRealPath("");
	
	    IpivrConfig.getInstance().maxUploadSize = 1==1?20: Integer.parseInt(svlconfig.getInitParameter("MaxUploadSize-MB"));              // ??? ???ε? ??????
	    IpivrConfig.getInstance().strAnCodePath = 1==1?"D:/mnt/data_acromate_home/acroms_SoundV_Ancode": svlconfig.getInitParameter("AnCodePath");                                      // Ancode ???? ???
	    IpivrConfig.getInstance().strFileMentPath = 1==1?"D:/mnt/data_acromate_home/acroms_SoundV_FileMent": svlconfig.getInitParameter("FileMentPath");                                  // Filement ???? ???
	    IpivrConfig.getInstance().strResponseModeKey = 1==1?"202": svlconfig.getInitParameter("ResponseModeKey");                            // Normal IPCS ??? ?????? ???
	    IpivrConfig.getInstance().strKeyActionVisibleType = 1==1?"1": svlconfig.getInitParameter("KeyActionVisibleType");                  // Normal IPCS?? ?????????? ???? ??? ?????? ?????????? Key Action?? ??????? ?????? ???????.  -  1: ??? ??????(Moniter Transfer, Goto Code, Undefined), 2: ??? ??????
		String strProps = IpivrConfig.getInstance().strRealPath + "/WEB-INF/" + (1==1?"Command.properties": svlconfig.getInitParameter("CommandProperty") );
	}
	String strSaveFolder = StringUtil.null2Str(request.getSession(false).getAttribute("login.strIpcsFilePath"), "") + "/fileupwav" ;
	int maxSize = IpivrConfig.getInstance().maxUploadSize * 1024 * 1024;  // 10 MB
	
	boolean bValidFileName = false;
	
	MultipartRequest multi = null;
	multi = new MultipartRequest(request, strSaveFolder, maxSize, "euc-kr", new DefaultFileRenamePolicy());
	
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	if(1==1){
		String strWName = multi.getParameter("wName");
		String strOriginalFileName = multi.getOriginalFileName("wFile");
		String strSavedFileName = multi.getFilesystemName("wFile");

		if(strOriginalFileName == null)
			strOriginalFileName = "";

		bValidFileName = FileNameChecker.isValidFileName(strOriginalFileName);

		VoiceDAO voiceDAO = VoiceDAO.getInstance();
		VoiceDTO voiceDTO = new VoiceDTO();

		voiceDTO.setWName(strWName);
		voiceDTO.setWFile(strOriginalFileName);
		voiceDTO.setWDiv("U");

		if(bValidFileName == true) {
// 			iRtn = voiceDAO.insertVoice(voiceDTO);
			stmt.stxTransaction();
			try{
		        	sql  = " SELECT COUNT(*) FROM NASA_WAV " ;
		    		sql += "  WHERE w_file = '" + voiceDTO.getWFile() + "' ";
		    		//if(authGroupid!=null) sql += " AND checkgroupid = '" + authGroupid + "' ";
		    		System.out.println("sql: \n"+ sql);
		            rs = stmt.executeQuery(sql);
					if (rs.next()){ 
						if (rs.getInt(1) == 0){
							if(rs!=null) rs.close();
							
							sql = " INSERT INTO NASA_WAV(server_ip, w_name, w_file, w_memo, w_div, w_send, w_kind, w_sendfile, w_regdate, w_acceptdate) "; 
			    			sql = sql + " VALUES('%s','%s','%s','%s','%s','%s','%s','%s',to_char(now(),'YYYY-MM-DD hh24:mi:ss'),'%s') ";
			    			sql = String.format(sql
			    					, voiceDTO.getServerIp()
			    					, voiceDTO.getWName()
			    					, voiceDTO.getWFile()
			    					, voiceDTO.getWMemo()
			    					, voiceDTO.getWDiv()
			    					, voiceDTO.getWSend()
			    					, voiceDTO.getWKind()
			    					, voiceDTO.getWSendFile()
			    					, voiceDTO.getWAcceptDate()
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
			    			
			    			sql  = " SELECT w_index FROM NASA_WAV " ;
				    		sql += "  WHERE w_file = '%s' ";
				    		sql = String.format(sql
			    					, voiceDTO.getWFile()
			    					);
				    		System.out.println("sql: \n"+ sql);
				            rs = stmt.executeQuery(sql);
							if (rs.next()){ 
								voiceDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
							}
						}else{
							iRtn = 2;
						}
					}
					if(rs!=null) rs.close();
					
					// ############### LogHistory 처리  #############
//	 				LogHistory	logHistory 	= new LogHistory();
//	 				logHistory.LogHistoryGetIpSave(userID+"|83|일반통화 연결음 ("+strE164+" 번)|1|");
					// ##############################################
		        
			}catch(Exception ex){
				iRtn = -1;
			}finally{
				if(rs!=null) rs.close();
				//if(stmt!=null) ConnectionManager.freeStatement(stmt);
			}
			
			switch(iRtn) {
				case 1:// ok
					//request.setAttribute("msg", "??????????.");
					if (1==1) {
// 		        		for(String strE164 : e164s)
// 		        	       	if( (strE164 = strE164.trim()).length()>0 ){
// 		        	       		if(jsArray.length()==0)	jsArray.append("[{params:");
// 		        	       		else					jsArray.append(",{params:");
		        	       		
// 		        	       		jsArray.append("[\""+strE164+"\",\""+strOriginalFileName+"\"]}");
// 		        	       	}
// 		                if(jsArray.length()>0)	jsArray.append("]");
		                

						SimpleDateFormat format1 = new SimpleDateFormat("yyyy-MM-dd"/* "yyyy-MM-dd HH:mm:ss" */);
						String date1 = format1.format(Calendar.getInstance().getTime());
						
		                jsArray.setLength(0);
		                jsArray.append("[{params:");
		                jsArray.append("[\""+voiceDTO.getWIndex()+"\",\""+strWName+"\",\""+strOriginalFileName+"\",\""+date1+"\"]}");
		                jsArray.append("]");
		        	}
%>
    <script>
        alert("저장되었습니다.");
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%				
					break;
				case 2:// already exist data
					if(!strOriginalFileName.equals(""))
						FileUtil.delete(strSaveFolder + "/" + strSavedFileName);
					//request.setAttribute("msg", "파일명이 이미 존재합니다. 다른이름으로 업로드하여 주시기 바랍니다.");
%>
    <script>
        alert("파일명이 이미 존재합니다. 다른이름으로 업로드하여 주시기 바랍니다.");
    </script>
<%
					break;
				case -1:// exception
					if(!strOriginalFileName.equals(""))
						FileUtil.delete(strSaveFolder + "/" + strSavedFileName);
					//request.setAttribute("msg", "저장이 실패하였습니다.");
%>
	<script>
        alert("저장이 실패하였습니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%					
					break;
			}
		} else {
			if(!strOriginalFileName.equals(""))
				FileUtil.delete(strSaveFolder + "/" + strSavedFileName);
			//request.setAttribute("msg", "형식이 올바르지 않습니다.");// invalid pattern
			//if((int)originalFileName.charAt(i) > 127){} // 한글인 경우.
%>
	<script>
        alert("형식이 올바르지 않습니다.");
        //alert("파일명에 한글이 들어갈 수 없습니다.");
    </script>
<%			
		}
		
	}
		
} catch(Exception e) {
	e.printStackTrace();
	iRtn = -1;
%>
	<script>
        alert("저장이 실패하였습니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%	
} finally {
	if(iRtn < 1){
		// commit 처리
		if (stmt != null ) stmt.endTransaction(false);
	}else
		if (stmt != null ) stmt.endTransaction(true);

	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>