
<%@page import="bizportal.nasacti.ipivr.dto.UsedVoiceDTO"%>
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
String os = Str.CheckNullString(System.getProperties().getProperty("os.name"));
System.out.println(os);
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
	
	String strNwuIdx = request.getParameter("nwuIdx");
	String strWIndex = request.getParameter("wIndex");
	
	if(1==1){
// 		VoiceDAO voiceDAO = VoiceDAO.getInstance();
		UsedVoiceDTO usedVoiceDTO = new UsedVoiceDTO();
		
		sql = "SELECT nwu_idx, w_index, nwu_type, nwu_filename, nwu_definition, ns_idx \n";
		sql += "FROM nasa_wave_use \n";
		sql += "WHERE nwu_idx = %s ";
		sql = String.format(sql, strNwuIdx);
		System.out.println("sql: \n"+ sql);
		rs = stmt.executeQuery(sql);
		if (rs.next()){ 
			usedVoiceDTO.setNwuIdx(String.valueOf(rs.getInt("nwu_idx")));
			usedVoiceDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
			usedVoiceDTO.setNwuType(rs.getString("nwu_type"));
			usedVoiceDTO.setNwuFileName(rs.getString("nwu_filename"));
			usedVoiceDTO.setNwuDefinition(rs.getString("nwu_definition"));
			usedVoiceDTO.setNsIdx(String.valueOf(rs.getInt("ns_idx")));
		}
		if(rs!=null) rs.close();
		
		if(usedVoiceDTO.getNwuType().equals("F")) {
			iRtn = FileUtil.delete(StringUtil.null2Str(request.getSession(false).getAttribute("login.strFileMentPath"), "") + "/kor/" + usedVoiceDTO.getNwuFileName());
			System.out.println("\n Del FileMent :"+ iRtn);
		} else if(usedVoiceDTO.getNwuType().equals("A") || usedVoiceDTO.getNwuType().equals("S")) {
			iRtn = FileUtil.delete(StringUtil.null2Str(request.getSession(false).getAttribute("login.strAnCodePath"), "") + "/kor/" + usedVoiceDTO.getNwuFileName());
			System.out.println("\n Del AnCode :"+ iRtn);
		}
		if(iRtn == 1){
			stmt.stxTransaction();
			
            //voiceDAO.deleteUsedVoice(strNwuIdx);
			sql = "\n DELETE FROM nasa_wave_use "; 
			sql += "\n WHERE nwu_idx = %s ";
			sql = String.format(sql
					, strNwuIdx
					);
			System.out.println("sql: "+ sql);
			iRtn = stmt.executeUpdate(sql);
			//if (nResult < 0){	throw new Exception(l.x("[통화연결음 등록] '","[Auth Properties Error] '")+l.x("'통화연결음 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
	 		if (iRtn > 0){
				iRtn = 1;
				sql = " UPDATE nasa_systemupdate SET su_check = 'Y' ";
				System.out.println("SQL :\n"+sql);
	   			stmt.executeUpdate(sql);
	   			//if (nResult < 0){	throw new Exception(l.x("[ADD MRBT 통화연결음 등록] '","[Auth Properties Error] '")+l.x("'ADD MRBT 통화연결음 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
	   			if(stmt!=null) stmt.endTransaction(true);
			}else
				if(stmt!=null) stmt.endTransaction(false);
		}else{
		    //request.setAttribute("msg", "");
		}
	}//if
	
	switch(iRtn) {
		case 1:// ok
        	jsArray.setLength(0);
            jsArray.append("[{params:");
            jsArray.append("[");
            jsArray.append("\""+strWIndex+"\"]}");
            jsArray.append("]");
            
            out.clear();
%>
<script>
alert("해재되었습니다.");
parent.goEditDone(<%=jsArray.toString()%>);
parent.hiddenAdCodeDiv();
</script>
<%				
			break;
		case -1:// exception
			out.clear();
%>
<script>
alert("수정에 실패하였습니다.");
//alert("파일크기는 5Mbyte이내여야합니다.");
</script>
<%					
			break;
	}//switch
////////////////////////////////////////////////////////////
		
} catch(Exception e) {
	e.printStackTrace();
	if(iRtn < 1){
		// commit 처리
		if (stmt != null ) stmt.endTransaction(false);
	}
	out.clear();
%>
	<script>
        alert("수정에 실패하였습니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%	
} finally {
  	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>