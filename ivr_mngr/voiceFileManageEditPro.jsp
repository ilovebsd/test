
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

//�����κ��� DataStatement ��ü�� �Ҵ�
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
	
	    IpivrConfig.getInstance().maxUploadSize = 1==1?20: Integer.parseInt(svlconfig.getInitParameter("MaxUploadSize-MB"));
	    IpivrConfig.getInstance().strAnCodePath = 1==1?"D:/mnt/data_acromate_home/acroms_SoundV_Ancode": svlconfig.getInitParameter("AnCodePath");// Ancode
	    IpivrConfig.getInstance().strFileMentPath = 1==1?"D:/mnt/data_acromate_home/acroms_SoundV_FileMent": svlconfig.getInitParameter("FileMentPath");// Filement
	    IpivrConfig.getInstance().strResponseModeKey = 1==1?"202": svlconfig.getInitParameter("ResponseModeKey");                            // Normal IPCS
	    IpivrConfig.getInstance().strKeyActionVisibleType = 1==1?"1": svlconfig.getInitParameter("KeyActionVisibleType");                  // Normal IPCS / Key Action - 1: (Moniter Transfer, Goto Code, Undefined), 2: 
		String strProps = IpivrConfig.getInstance().strRealPath + "/WEB-INF/" + (1==1?"Command.properties": svlconfig.getInitParameter("CommandProperty") );
	}
	String strSaveFolder = StringUtil.null2Str(request.getSession(false).getAttribute("login.strIpcsFilePath"), "") + "/fileupwav" ;
	int maxSize = IpivrConfig.getInstance().maxUploadSize * 1024 * 1024;  // 10 MB
	
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	boolean bValidFileName = false;
	MultipartRequest multi = null;
	multi = new MultipartRequest(request, strSaveFolder, maxSize, "euc-kr", new DefaultFileRenamePolicy());
	
	if(1==1){
		String strWIndex = multi.getParameter("wIndex");
		String strWName = multi.getParameter("wName");
		String strOriginalFileName = multi.getOriginalFileName("wFile");
		String strSavedFileName = multi.getFilesystemName("wFile");

		String strLastWFile = "";
		
		if(strOriginalFileName == null)
			strOriginalFileName = "";

		bValidFileName = FileNameChecker.isValidFileName(strOriginalFileName);
		
// 		VoiceDAO voiceDAO = VoiceDAO.getInstance();
		VoiceDTO voiceDTO = new VoiceDTO();
		
		sql = "SELECT w_index, COALESCE(server_ip, '') as server_ip, COALESCE(w_name, '') as w_name, COALESCE(w_file, '') as w_file,          \n";
		sql += "COALESCE(w_memo, '') as w_memo, COALESCE(w_div, '') as w_div, COALESCE(w_send, '') as w_send, COALESCE(w_kind, '') as w_kind,  \n";
		sql += "COALESCE(w_sendfile, '') as w_sendfile, COALESCE(w_regdate, '') AS w_regdate, COALESCE(w_acceptdate, '') AS w_acceptdate       \n";
		sql += "FROM NASA_WAV WHERE w_index = %s ";
		sql = String.format(sql, strWIndex);
		rs = stmt.executeQuery(sql);
		if (rs.next()){ 
			voiceDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
			voiceDTO.setServerIp(rs.getString("server_ip"));
			voiceDTO.setWName(rs.getString("w_name"));
			voiceDTO.setWFile(rs.getString("w_file"));
			voiceDTO.setWMemo(rs.getString("w_memo"));
			voiceDTO.setWDiv(rs.getString("w_div"));
			voiceDTO.setWSend(rs.getString("w_send"));
			voiceDTO.setWKind(rs.getString("w_kind"));
			voiceDTO.setWSendFile(rs.getString("w_sendfile"));
			voiceDTO.setWRegDate(rs.getString("w_regdate"));
			voiceDTO.setWAcceptDate(rs.getString("w_acceptdate"));
		}
		if(rs!=null) rs.close();
		strLastWFile = voiceDTO.getWFile();
		
// 		voiceDTO.setWName(strWName);
// 		voiceDTO.setWFile(strOriginalFileName);
// 		voiceDTO.setWDiv("U");

		if(bValidFileName == true) {
			//iRtn = voiceDAO.insertVoice(voiceDTO);
			stmt.stxTransaction();
			try{
		        	sql  = " SELECT COUNT(*) FROM NASA_WAV " ;
		    		sql += "  WHERE w_index <> %s AND w_file = '%s' ";
		    		//if(authGroupid!=null) sql += " AND checkgroupid = '" + authGroupid + "' ";
		    		sql = String.format(sql
			    					, strWIndex
			    					, strOriginalFileName
			    					);
		    		System.out.println("sql: \n"+ sql);
		            rs = stmt.executeQuery(sql);
					if (rs.next()){ 
						if (rs.getInt(1) == 0){
							if(rs!=null) rs.close();
							
							sql = " UPDATE NASA_WAV SET \n"; 
			    			sql += " w_name = '%s', \n";
			    			sql += strOriginalFileName.length()==0?"": " w_file = '%s', \n";
			    			sql += " w_send = '' \n";
			    			sql += " WHERE w_index = %s ";
			    			sql = strOriginalFileName.length()==0
			    				? String.format(sql
				    					, strWName
				    					, strWIndex
				    					)
			    				: String.format(sql
			    					, strWName
			    					, strOriginalFileName
			    					, strWIndex
			    					);
			    			System.out.println("sql: \n"+ sql);
			    			iRtn = stmt.executeUpdate(sql);
			    			//if (nResult < 0){	throw new Exception(l.x("[��ȭ������ ���] '","[Auth Properties Error] '")+l.x("'��ȭ������ ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
			    			if (iRtn > 0){
								iRtn = 1;
								sql = " UPDATE nasa_systemupdate SET su_check = 'Y' ";
								System.out.println("SQL :\n"+sql);
				    			stmt.executeUpdate(sql);
				    			//if (nResult < 0){	throw new Exception(l.x("[ADD MRBT ��ȭ������ ���] '","[Auth Properties Error] '")+l.x("'ADD MRBT ��ȭ������ ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
							}
						}else{
							iRtn = 2;
						}
					}
					if(rs!=null) rs.close();
					
					// ############### LogHistory ó��  #############
//	 				LogHistory	logHistory 	= new LogHistory();
//	 				logHistory.LogHistoryGetIpSave(userID+"|83|�Ϲ���ȭ ������ ("+strE164+" ��)|1|");
					// ##############################################
		        
		     	// commit ó��
				if(stmt!=null) stmt.endTransaction(true);
			}catch(Exception ex){
				iRtn = -1;
				// commit ó��
				if(stmt!=null) stmt.endTransaction(false);
			}finally{
				if(rs!=null) rs.close();
				//if(stmt!=null) ConnectionManager.freeStatement(stmt);
			}
			
			switch(iRtn) {
				case 1:// ok
					//request.setAttribute("msg", "??????????.");
					if(strOriginalFileName != "") {
						if(!strOriginalFileName.equals(strSavedFileName)) {
							FileUtil.copy(strSaveFolder + "/" + strSavedFileName, strSaveFolder + "/" + strOriginalFileName);
							FileUtil.delete(strSaveFolder + "/" + strSavedFileName);
						}

						if(!strLastWFile.equals(strOriginalFileName)) {
							FileUtil.delete(strSaveFolder + "/" + strLastWFile);
						}
					}
					
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
		                jsArray.append("[\""+voiceDTO.getWIndex()+"\"");
		                jsArray.append(",\""+strWName+"\"");
		                jsArray.append(",\""+(strOriginalFileName.length()==0?strLastWFile:strOriginalFileName)+"\"");
		                jsArray.append(",\""+voiceDTO.getWRegDate().substring(0, 10)+"\"]}");
		                jsArray.append("]");
		        	}
%>
    <script>
        alert("�����Ǿ����ϴ�.");
        parent.goEditDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%				
					break;
				case 2:// already exist data
					if(!strOriginalFileName.equals(""))
						FileUtil.delete(strSaveFolder + "/" + strSavedFileName);
					//request.setAttribute("msg", "���ϸ��� �̹� �����մϴ�. �ٸ��̸����� ���ε��Ͽ� �ֽñ� �ٶ��ϴ�.");
%>
    <script>
        alert("���ϸ��� �̹� �����մϴ�. �ٸ��̸����� ���ε��Ͽ� �ֽñ� �ٶ��ϴ�.");
    </script>
<%
					break;
				case -1:// exception
					if(!strOriginalFileName.equals(""))
						FileUtil.delete(strSaveFolder + "/" + strSavedFileName);
					//request.setAttribute("msg", "������ �����Ͽ����ϴ�.");
%>
	<script>
        alert("������ �����Ͽ����ϴ�.");
        //alert("����ũ��� 5Mbyte�̳������մϴ�.");
    </script>
<%					
					break;
			}
		} else {
			if(!strOriginalFileName.equals(""))
				FileUtil.delete(strSaveFolder + "/" + strSavedFileName);
			//request.setAttribute("msg", "������ �ùٸ��� �ʽ��ϴ�.");// invalid pattern
			//if((int)originalFileName.charAt(i) > 127){} // �ѱ��� ���.
%>
	<script>
        alert("������ �ùٸ��� �ʽ��ϴ�.");
        //alert("���ϸ� �ѱ��� �� �� �����ϴ�.");
    </script>
<%			
		}
		
	}
} catch(Exception e) {
	e.printStackTrace();
	if(iRtn < 1){
		// commit ó��
		if (stmt != null ) stmt.endTransaction(false);
	}
%>
	<script>
        alert("������ �����Ͽ����ϴ�.");
        //alert("����ũ��� 5Mbyte�̳������մϴ�.");
    </script>
<%	
} finally {
  	//�Ҵ���� DataStatement ��ü�� �ݳ�
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>