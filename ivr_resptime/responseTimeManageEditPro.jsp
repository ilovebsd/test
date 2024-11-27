

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
<%@page import="dao.system.CommonDAO"%>
<%@page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bizportal.nasacti.ipivr.dto.ScheduleDTO"%>

<%!
	public int insertSchedule(DataStatement stmt, String strAmIndex, ScheduleDTO scheduleDTO, String checkgroupid){
		int iRtn = -1;
		String sql = "INSERT INTO nasa_answer_time(at_index, am_index, at_start_time, at_sc_code, at_sc_name, at_description \n";
// 		sql += ", checkgroupid ";
// 		sql += ") VALUES (nextval('nasa_answer_time_at_index_seq')";
// 		sql += ") VALUES ( (SELECT (max(at_index)+1) as nextidx FROM nasa_answer_time)";
		sql += ") VALUES ( (SELECT (CASE WHEN max(at_index)>0 THEN (max(at_index)+1) ELSE 1 END) as nextidx FROM nasa_answer_time)";
		sql += ",%s,%s,%s,%s,%s ";
// 		sql += ",%s \n";
		sql += ") \n";
		sql = String.format(sql
				, strAmIndex
				, "'"+scheduleDTO.getAtStartTime()+"'"
				, scheduleDTO.getAtScode()
				, "'"+scheduleDTO.getAtScName()+"'"
				, "'"+scheduleDTO.getAtDescription()+"'"
// 				, "'"+checkgroupid+"'"
				);
		System.out.print("sql : \n"+ sql);
		iRtn = stmt.executeUpdate(sql);
		
		if(iRtn > 0) {
			iRtn = 1;
			
			sql = "UPDATE nasa_systemupdate SET su_check = 'Y'";
			System.out.println("sql : "+ sql);
			stmt.executeUpdate(sql);
		}
		return iRtn;
	}
	public int updateSchedule(DataStatement stmt, ScheduleDTO scheduleDTO){
		int iRtn = -1;
		String sql = "UPDATE nasa_answer_time SET    \n";
		sql += "at_start_time = %s    	\n";
		sql += ", at_sc_code = %s    	\n";
		sql += ", at_sc_name = %s    	\n";
		sql += ", at_description = %s   \n";
		sql += "WHERE at_index = %s    	\n";
		sql = String.format(sql
				, "'"+scheduleDTO.getAtStartTime()+"'"
				, scheduleDTO.getAtScode()
				, "'"+scheduleDTO.getAtScName()+"'"
				, "'"+scheduleDTO.getAtDescription()+"'"
				, scheduleDTO.getAtIndex()
				);
		System.out.print("sql : \n"+ sql);
		iRtn = stmt.executeUpdate(sql);
		
		if(iRtn > 0) {
			iRtn = 1;
			
			sql = "UPDATE nasa_systemupdate SET su_check = 'Y'";
			System.out.println("sql : "+ sql);
			stmt.executeUpdate(sql);
		}
		return iRtn;
	}
	public int deleteSchedule(DataStatement stmt, String strAtIndex){
		int iRtn = -1;
		String sql = "DELETE FROM nasa_answer_time    \n";
		sql += "WHERE at_index = %s    \n";
		sql = String.format(sql
				, strAtIndex
				);
		System.out.print("sql : \n"+ sql);
		iRtn = stmt.executeUpdate(sql);
		
		if(iRtn > 0) {
			iRtn = 1;
			
			sql = "UPDATE nasa_systemupdate SET su_check = 'Y'";
			System.out.println("sql : "+ sql);
			stmt.executeUpdate(sql);
		}
		return iRtn;
	}
%>
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
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try {
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	if(1==1){
		request.setCharacterEncoding("euc-kr");
		
		String strAmIndex = request.getParameter("amIndex");
		String strAmModeName = request.getParameter("amModeName").trim(); 
		String strAmMemo = request.getParameter("amMemo").trim(); 
		
		String tdHidden1[] = request.getParameterValues("tdHidden1");
		String tdHidden2[] = request.getParameterValues("tdHidden2");
		String tdHidden3[] = request.getParameterValues("tdHidden3");
		String tdHidden4[] = request.getParameterValues("tdHidden4");				//(scCode)
		String tdHidden5[] = request.getParameterValues("tdHidden5");				//(I),(E),(D),(O)
		String tdHidden6[] = request.getParameterValues("tdHidden6");				//(at_index)
		
		if(1==1) {
			//iRtn = voiceDAO.insertVoice(voiceDTO);
			stmt.stxTransaction();
			try{
				
				sql = "\n SELECT COUNT(*) FROM nasa_answer_mode ";
				sql += "\n WHERE am_mode_name = %s AND am_index <> %s ";
// 				sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
				sql = String.format(sql
						, "'"+ strAmModeName +"'"
						, strAmIndex
						);
				System.out.print("sql \n"+ sql);
				rs = stmt.executeQuery(sql);
				if(rs.next()){
					if( rs.getInt(1)==0 ){
						iRtn = 1;
					}else {
						iRtn = 2;   // already exist 
					}
				}
				if(rs!=null) rs.close();
				
				if(iRtn == 1){
					//					
					sql = "\n UPDATE nasa_answer_dateday SET ";
					sql += "\n am_mode_name = %s ";
// 					sql += "\n , am_memo = %s ";// primary key ??
					sql += "\n WHERE am_index = %s ";
// 					sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
					sql = String.format(sql
							, "'"+ strAmModeName +"'"
// 							, "'"+ strAmMemo +"'"
							, strAmIndex
							);
					System.out.print("sql \n"+ sql);
					stmt.executeUpdate(sql);
					
					iRtn = 1;
					
					//
					sql = "\n UPDATE nasa_systemupdate SET su_check = 'Y' ";
					System.out.print("sql \n"+ sql);
					stmt.executeUpdate(sql);
					
				}//if(iRtn == 1)
				
			}catch(Exception ex){
				iRtn = -1;
			}finally{
				if(rs!=null) rs.close();
				//if(stmt!=null) ConnectionManager.freeStatement(stmt);
			}
			
			switch(iRtn) {
				case -1:// exception
					//request.setAttribute("msg", "저장이 실패하였습니다.");
%>
	<script>
        alert("수정에 실패하였습니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%					
					//commit 처리
					if (stmt != null ) stmt.endTransaction(false);
					break;
				case 2:// already exist
					//request.setAttribute("msg", "저장이 실패하였습니다.");
%>
	<script>
        alert("이미 존재하는 응답시간 설정입니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%					
					//commit 처리
					if (stmt != null ) stmt.endTransaction(false);
					break;
				case 1:// ok
					//request.setAttribute("msg", "??????????.");
					for(int i=0; i < tdHidden5.length; i++) {
						if(tdHidden5[i].equals("I")) {
							ScheduleDTO scheduleDTO = new ScheduleDTO();
							scheduleDTO.setAtIndex(tdHidden6[i]);
							scheduleDTO.setAmIndex(strAmIndex);
							scheduleDTO.setAtStartTime(tdHidden1[i] + ":" + tdHidden2[i]);
							scheduleDTO.setAtScode(tdHidden4[i]);
							scheduleDTO.setAtScName(tdHidden3[i]);
							insertSchedule(stmt, strAmIndex, scheduleDTO, authGroupid);
						} else if(tdHidden5[i].equals("E")) {
							ScheduleDTO scheduleDTO = new ScheduleDTO();
							scheduleDTO.setAtIndex(tdHidden6[i]);
							scheduleDTO.setAmIndex(strAmIndex);
							scheduleDTO.setAtStartTime(tdHidden1[i] + ":" + tdHidden2[i]);
							scheduleDTO.setAtScode(tdHidden4[i]);
							scheduleDTO.setAtScName(tdHidden3[i]);
							updateSchedule(stmt, scheduleDTO);
						} else if(tdHidden5[i].equals("D")) {
							deleteSchedule(stmt, tdHidden6[i]);
						}
					}//for
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
						
// 		                jsArray.setLength(0);
// 		                jsArray.append("[{params:");
// 		                jsArray.append("[\""+voiceDTO.getWIndex()+"\"");
// 		                jsArray.append(",\""+strWName+"\"");
// 		                jsArray.append(",\""+(strOriginalFileName.length()==0?strLastWFile:strOriginalFileName)+"\"");
// 		                jsArray.append(",\""+voiceDTO.getWRegDate().substring(0, 10)+"\"]}");
// 		                jsArray.append("]");
		        	}
%>
    <script>
        alert("수정되었습니다.");
        parent.goEditDone(<%=jsArray.toString()%>);
        //parent.goRefresh();
        parent.hiddenAdCodeDiv();
    </script>
<%				
					//commit 처리
					if(stmt!=null) stmt.endTransaction(true);
					break;
			}
		}//if 
	}//if
} catch(Exception e) {
	e.printStackTrace();
	if(iRtn < 1){
		// commit 처리
		if (stmt != null ) stmt.endTransaction(false);
	}
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