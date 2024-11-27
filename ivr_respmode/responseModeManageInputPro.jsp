
<%@page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
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

<%!
	public int insertResponseModeVoiceReg(DataStatement stmt, ResultSet rs, String strWKind, String strWSendFile, String strWIndex, String strNwuDefinition){
		int nRtn = -1;
		String sql = "INSERT INTO nasa_wave_use(nwu_idx, w_index, nwu_type, nwu_filename, nwu_definition) ";
// 		sql += " values(nextval('nasa_wave_use_nwu_idx_seq')";
// 		sql += " VALUES( (SELECT (max(nwu_idx)+1) as nextidx FROM nasa_wave_use)";
		sql += " VALUES( (SELECT (CASE WHEN max(nwu_idx)>0 THEN (max(nwu_idx)+1) ELSE 1 END) as nextidx FROM nasa_wave_use)";
		sql += ", %s, %s, %s, %s) ";
		sql = String.format(sql
				, strWIndex
				, "'"+ strWKind +"'"
				, "'"+ strWSendFile +"'"
				, "'"+ strNwuDefinition +"'"
				);
		try{
			System.out.print("sql : \n"+sql);
			nRtn = stmt.executeUpdate(sql);
			if(nRtn > 0) {
				nRtn = 1;
				sql = "UPDATE nasa_systemupdate SET su_check = 'Y' ";
				System.out.print("sql : \n"+sql);
				stmt.executeUpdate(sql);
			}	
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			try{
				if(rs!=null) rs.close();
			}catch(Exception e){}
		}
		return nRtn;
	}
	public int updateAcceptDate(DataStatement stmt, ResultSet rs, String strWIndex){
		int nRtn = -1;
		String sql = "UPDATE NASA_WAV SET ";
		sql += " w_acceptdate = to_char(now(),'YYYY-MM-DD hh24:mi:ss') ";
		sql += " WHERE w_index = %s ";
		sql = String.format(sql
				, strWIndex
				);
		try{
			System.out.print("sql : \n"+sql);
			nRtn = stmt.executeUpdate(sql);
			if(nRtn > 0) {
				nRtn = 1;
				sql = "UPDATE nasa_systemupdate SET su_check = 'Y' ";
				System.out.print("sql : \n"+sql);
				stmt.executeUpdate(sql);
			}	
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			try{
				if(rs!=null) rs.close();
			}catch(Exception e){}
		}
		return nRtn;
	}
	public int deleteResponseMode(DataStatement stmt, ResultSet rs, String strScCode, String checkgroupid){
		int nRtn = -1;
		String sql = "select count(*) from nasa_answer_time where at_sc_code = "+strScCode+" ";
// 		sql += "AND checkgroupid = '"+ checkgroupid +"' ";
		try{
			System.out.print("sql : \n"+sql);
			rs = stmt.executeQuery(sql);
			if(rs.next()) {
				if(rs.getInt(1) == 0) {
					sql = "DELETE FROM nasa_callprocessor ";
					sql += " WHERE at_sc_code = "+strScCode+" ";
// 					sql += "AND checkgroupid = '"+ checkgroupid +"' ";
					System.out.print("sql : \n"+sql);
					nRtn = stmt.executeUpdate(sql);
				} else {
					nRtn = 2;
				}
			}	
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			try{
				if(rs!=null) rs.close();
			}catch(Exception e){}
		}
		return nRtn;
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
	    
		String strSaveFolder = IpivrConfig.getInstance().strIpcsFilePath + "/fileupwav" ;
		int maxSize = IpivrConfig.getInstance().maxUploadSize * 1024 * 1024;  // 10 MB
	}
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	if(1==1){
		request.setCharacterEncoding("euc-kr");
		
		String strScName = request.getParameter("scName").trim();
		String strScHour = request.getParameter("scHour").trim();
		String strScMakeCallTime = request.getParameter("scMakeCallTime").trim();
		String strScLang = request.getParameter("scLang");

		String strScLogCheck = request.getParameter("scLogCheck");
		if(strScLogCheck == null)
			strScLogCheck = "N";

		String strScAgain = request.getParameter("scAgain").trim();

		String strScKeyTo = request.getParameter("keyto");
		String strWordTo = request.getParameter("wordto").trim();
		strScKeyTo += strWordTo;

		String strScKey0 = request.getParameter("key0");
		String strWord0 = request.getParameter("word0").trim();
		strScKey0 += strWord0;

		String strScKey1 = request.getParameter("key1");
		String strWord1 = request.getParameter("word1").trim();
		strScKey1 += strWord1;

		String strScKey2 = request.getParameter("key2");
		String strWord2 = request.getParameter("word2").trim();
		strScKey2 += strWord2;

		String strScKey3 = request.getParameter("key3");
		String strWord3 = request.getParameter("word3").trim();
		strScKey3 += strWord3;

		String strScKey4 = request.getParameter("key4");
		String strWord4 = request.getParameter("word4").trim();
		strScKey4 += strWord4;

		String strScKey5 = request.getParameter("key5");
		String strWord5 = request.getParameter("word5").trim();
		strScKey5 += strWord5;

		String strScKey6 = request.getParameter("key6");
		String strWord6 = request.getParameter("word6").trim();
		strScKey6 += strWord6;

		String strScKey7 = request.getParameter("key7");
		String strWord7 = request.getParameter("word7").trim();
		strScKey7 += strWord7;

		String strScKey8 = request.getParameter("key8");
		String strWord8 = request.getParameter("word8").trim();
		strScKey8 += strWord8;

		String strScKey9 = request.getParameter("key9");
		String strWord9 = request.getParameter("word9").trim();
		strScKey9 += strWord9;


		String strScKeyA = request.getParameter("keya");
		String strWordA = request.getParameter("worda").trim();
		strScKeyA += strWordA;

		String strScKeyB = request.getParameter("keyb");
		String strWordB = request.getParameter("wordb").trim();
		strScKeyB += strWordB;

		String strScKeyC = request.getParameter("keyc");
		String strWordC = request.getParameter("wordc").trim();
		strScKeyC += strWordC;

		String strScKeyD = request.getParameter("keyd");
		String strWordD = request.getParameter("wordd").trim();
		strScKeyD += strWordD;

		String strScKeyAs = request.getParameter("keyas");
		String strWordAs = request.getParameter("wordas").trim();
		strScKeyAs += strWordAs;

		String strScKeySh = request.getParameter("keysh");
		String strWordSh = request.getParameter("wordsh").trim();
		strScKeySh += strWordSh;

		String strDgCheck = request.getParameter("dgCheck");
		if(strDgCheck == null)
			strDgCheck = "N";

		String strWFile = request.getParameter("wfile").trim();
		String strWIndex = request.getParameter("wcode").trim();

		String strWaveFileFormat = ".wav";
		String strScVoiceFile = "Ancd";

		String strScCidRoute = request.getParameter("scCidRoute");
		if(strScCidRoute == null)
			strScCidRoute = "N";

		ResponseModeDTO responseModeDTO = new ResponseModeDTO();

		responseModeDTO.setScName(strScName);
		responseModeDTO.setScHour(strScHour);
		responseModeDTO.setScMakeCallTime(strScMakeCallTime);
		responseModeDTO.setScLang(strScLang);
		responseModeDTO.setScLogCheck(strScLogCheck);
		responseModeDTO.setScAgain(strScAgain);
		responseModeDTO.setScKeyTo(strScKeyTo);
		responseModeDTO.setScKey0(strScKey0);
		responseModeDTO.setScKey1(strScKey1);
		responseModeDTO.setScKey2(strScKey2);
		responseModeDTO.setScKey3(strScKey3);
		responseModeDTO.setScKey4(strScKey4);
		responseModeDTO.setScKey5(strScKey5);
		responseModeDTO.setScKey6(strScKey6);
		responseModeDTO.setScKey7(strScKey7);
		responseModeDTO.setScKey8(strScKey8);
		responseModeDTO.setScKey9(strScKey9);
		responseModeDTO.setScKeyAs(strScKeyAs);
		responseModeDTO.setScKeySh(strScKeySh);
		responseModeDTO.setScKeyA(strScKeyA);
		responseModeDTO.setScKeyB(strScKeyB);
		responseModeDTO.setScKeyC(strScKeyC);
		responseModeDTO.setScKeyD(strScKeyD);
		responseModeDTO.setScVoiceFile(strScVoiceFile);
		responseModeDTO.setDgCheck(strDgCheck);
		responseModeDTO.setScCidRoute(strScCidRoute);
		responseModeDTO.setScType("I");
		responseModeDTO.setScUse("Y");
		
		if(1==1){
			//iRtn = voiceDAO.insertVoice(voiceDTO);
			stmt.stxTransaction();
			try{
				synchronized(this) {
					sql = "INSERT INTO nasa_callprocessor(sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time,           ";
					sql += "sc_lang, sc_logcheck, sc_again, sc_keyto, sc_key0, sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6,      ";
					sql += "sc_key7, sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc, sc_keyd, sc_key_etc, sc_voicefile,  ";
					sql += "dg_check, sc_file_change, sc_cid_route, sc_type, sc_use                                                      ";
	// 				sql += ", checkgroupid ";
	// 				sql += ") VALUES ( nextval('nasa_callprocessor_sc_code_seq')";
// 					sql += ") VALUES ( (SELECT (max(sc_code)+1) as nextidx FROM nasa_callprocessor)";
					sql += ") VALUES ( (SELECT (CASE WHEN max(sc_code)>0 THEN (max(sc_code)+1) ELSE 1 END) as nextidx FROM nasa_callprocessor)";
					sql += ",%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s ";
	// 				sql += ",%s ";
					sql += ") ";
					sql = String.format(sql
							, "'"+ responseModeDTO.getScName() +"'"
							, "'"+ responseModeDTO.getScSponsor() +"'"
							, "'"+ responseModeDTO.getScNextBox() +"'"
							, ""+ Integer.parseInt(responseModeDTO.getScHour())
							, ""+ Integer.parseInt(responseModeDTO.getScMakeCallTime())
							, "'"+ responseModeDTO.getScLang() +"'"
							, "'"+ responseModeDTO.getScLogCheck() +"'"
							, ""+ Integer.parseInt(responseModeDTO.getScAgain())
							, "'"+ responseModeDTO.getScKeyTo() +"'"
							, "'"+ responseModeDTO.getScKey0() +"'"
							, "'"+ responseModeDTO.getScKey1() +"'"
							, "'"+ responseModeDTO.getScKey2() +"'"
							, "'"+ responseModeDTO.getScKey3() +"'"
							, "'"+ responseModeDTO.getScKey4() +"'"
							, "'"+ responseModeDTO.getScKey5() +"'"
							, "'"+ responseModeDTO.getScKey6() +"'"
							, "'"+ responseModeDTO.getScKey7() +"'"
							, "'"+ responseModeDTO.getScKey8() +"'"
							, "'"+ responseModeDTO.getScKey9() +"'"
							, "'"+ responseModeDTO.getScKeyAs() +"'"
							, "'"+ responseModeDTO.getScKeySh() +"'"
							, "'"+ responseModeDTO.getScKeyA() +"'"
							, "'"+ responseModeDTO.getScKeyB() +"'"
							, "'"+ responseModeDTO.getScKeyC() +"'"
							, "'"+ responseModeDTO.getScKeyD() +"'"
							, "'"+ responseModeDTO.getScKeyEtc() +"'"
							, "'"+ responseModeDTO.getScVoiceFile() +"'"
							, "'"+ responseModeDTO.getDgCheck() +"'"
							, "'"+ responseModeDTO.getScFileChange() +"'"
							, "'"+ responseModeDTO.getScCidRoute() +"'"
							, "'"+ responseModeDTO.getScType() +"'"
							, "'"+ responseModeDTO.getScUse() +"'"
	// 						, "'"+ authGroupid +"'"
							);
	
					System.out.print("\nSQL : "+ sql);
					iRtn = stmt.executeUpdate(sql);
	
					//sql = "select last_value from nasa_callprocessor_sc_code_seq";
					sql = "select max(sc_code) from nasa_callprocessor ";
					System.out.print("\nSQL : "+ sql);
					rs = stmt.executeQuery(sql);
					if(rs.next())
						if(iRtn > 0) iRtn = rs.getInt(1);
				}//sync
				
				switch(iRtn){
					case -1:
						
						break;
					default :{
						int kRtn = -1;
						strScVoiceFile = strScVoiceFile + iRtn + strWaveFileFormat;
						
						sql = "UPDATE nasa_callprocessor SET \n";
						sql += "sc_voicefile = %s \n";
						sql += "WHERE sc_code = %s ";
// 						sql += "AND checkgroupid = '"+ authGroupid +"' ";
						sql = String.format(sql
								, "'"+strScVoiceFile+"'"
								, ""+iRtn
								);
						
						System.out.print("\nSQL : "+ sql);
						kRtn = stmt.executeUpdate(sql);
						
						if(kRtn >0){
							int jRtn = -1;

							if(!strWFile.equals(""))
								jRtn = FileUtil.copy(StringUtil.null2Str(request.getSession(false).getAttribute("login.strIpcsFilePath"), "") + "/fileupwav/" + strWFile
										, StringUtil.null2Str(request.getSession(false).getAttribute("login.strIpcsFilePath"), "") + "/fileup/" + strScVoiceFile);
							else
								jRtn = 2;
							
							switch(jRtn) {
							    case 1:// strWfile copy ok~
// 		                            VoiceDAO voiceDAO = VoiceDAO.getInstance();
									int lRtn = -1;
									lRtn = FileUtil.copy(StringUtil.null2Str(request.getSession(false).getAttribute("login.strIpcsFilePath"), "") + "/fileup/" + strScVoiceFile
											, StringUtil.null2Str(request.getSession(false).getAttribute("login.strAnCodePath"), "") + "/kor/" + strScVoiceFile);
	
									if(lRtn == 1) {
									    //request.setAttribute("msg", "?????? ????????.");
									    iRtn = 1;
										insertResponseModeVoiceReg(stmt, rs, "A",strScVoiceFile,strWIndex, strScName);
										updateAcceptDate(stmt, rs, strWIndex);
									} else {
										iRtn = -1;
									    //request.setAttribute("msg", "?????? ????? ???????.");
										deleteResponseMode(stmt, rs, String.valueOf(iRtn), authGroupid);
									}
									break;
								case 2:// strWfile is empty
									//request.setAttribute("msg", "[IPIVR ?????? ????????.]");
									iRtn = 1;
									break;
								case -1:// source file (strWfile) path err!
									iRtn = -1;
									//request.setAttribute("msg", "???????? ?????? ?? ??????.");
									deleteResponseMode(stmt, rs, String.valueOf(iRtn), authGroupid);
									break;
								case -2:// target file (strScVoiceFile) path err!
									iRtn = -1;
// 									request.setAttribute("msg", "?????????? ?????? ?? ??????.");
									deleteResponseMode(stmt, rs, String.valueOf(iRtn), authGroupid);
									break;
								case -3:// file copy err!
									iRtn = -1;
// 									request.setAttribute("msg", "?????????? ???? ?? ??????.");
									deleteResponseMode(stmt, rs, String.valueOf(iRtn), authGroupid);
									break;
							}
							
						}//if(kRtn)
						else {// ???????? ??????? ????
							iRtn = -1;
							//request.setAttribute("msg", "???????? ???????????.");
							deleteResponseMode(stmt, rs, String.valueOf(iRtn), authGroupid);
						}
					}break;
				}
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
        alert("등록에 실패하였습니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%					
					//commit 처리
					if (stmt != null ) stmt.endTransaction(false);
					break;
				default :// ok
					//request.setAttribute("msg", "??????????.");
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
        alert("등록되었습니다.");
        //parent.goInsertDone(<%=jsArray.toString()%>);
        parent.goRefresh();
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
        alert("등록에 실패하였습니다.");
        //alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%	
} finally {
  	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>