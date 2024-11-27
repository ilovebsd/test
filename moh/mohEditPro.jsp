<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="java.io.*,java.util.*,java.security.*,sun.misc.*,java.io.File"%>
<%@ page import="java.sql.ResultSet, business.LogHistory"%>

<% 
String originalFileName = "";    // 원파일명
String s = "";

File      tempFile         = null;  // 임시 파일 객체

String e164   		= "";
String dbfile    	= "";

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

String userWavPath = StringUtil.null2Str(request.getSession(false).getAttribute("login.strUserWavPath"), "");
		
e164 			= null;//new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr");
String[] e164s  = null;//StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

//서버로부터 DataStatement 객체를 할당
DataStatement stmt = null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try {
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	boolean isMultipart = FileUpload.isMultipartContent(request);

    DiskFileUpload dfu = new DiskFileUpload();
    
    dfu.setSizeThreshold(100*1024);         // 업로드 할당 메모리 크기   (100 KB)
    dfu.setSizeMax(30 * 1024 * 1024);        // 업로드 파일의 최대 크기   (5 M)
    dfu.setRepositoryPath(userWavPath.length()>0?userWavPath:StaticString.userWavPath);   // 파일업로드 템프 폴더 루트 (WAS)
  	
    if(isMultipart){    // multipart/form-data 일 경우
    	// request parsing..
        List fileItemList = dfu.parseRequest(request);

        Iterator iter = fileItemList.iterator();

        while (iter.hasNext()) {
            FileItem item = (FileItem) iter.next();

            if (item.isFormField()) {                           // 파일을 제외한 폼필드
            	//System.out.println("############## 1 : "+item.getFieldName());

            	if("hiEi64_03".equals(item.getFieldName())){
            		e164 = item.getString();
            		e164s  = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
            	}else if("uploadfilename_03".equals(item.getFieldName())){
                	dbfile = item.getString();
            	}                	

            }else{
            	String fileName = item.getName();
            	//System.out.println("############## 2 : "+fileName);
                if(!fileName.equals("")){
                    if(item.getSize() >= (1024 * 1024 * 5)){
%>
    <script>
        alert("파일크기는 5Mbyte이내여야합니다.");
    </script>
<%
                        return;
                    }
                    originalFileName = Str.CheckNullString(fileName.substring(fileName.lastIndexOf("\\")+1)); //원파일명 

                    for (int i=0; i< originalFileName.length(); i++) {
                        if((int)originalFileName.charAt(i) > 127) {	// 한글인 경우.
%>
    <script>
        alert("파일명에 한글이 들어갈 수 없습니다.");
    </script>
<%
                            return;
                        }
                    }

                    tempFile = new File(dfu.getRepositoryPath()+"/"+originalFileName);

                    while (tempFile.exists()) {                 // 파일존재
%>
    <script>
        alert("파일명이 이미 존재합니다. 다른이름으로 업로드하여 주시기 바랍니다.");
    </script>
<%
                        return;
                    }
                    
                    item.write(tempFile);
                }
            }
        }

        if("".equals(originalFileName)){
            originalFileName = dbfile;
        }

        String strUserParm	= e164;//"3,9, ";
        AddServiceDAO dao 	= new AddServiceDAO();
        int count = 0, cnt = 0, maxId2 	= 0;
        //count = dao.setNewUserMOH(stmt, strUserParm, originalFileName, userID, authGroupid);
        String sql="";
        ResultSet rs=null;
        try {            
            if (stmt != null){
            		// 트랜잭션 시작
    				stmt.stxTransaction();
//     				LogHistory	logHistory 	= new LogHistory();
            		for(String strE164 : e164s){
                		sql  = " SELECT count(*) FROM table_featureservice " ;
                		sql += "  WHERE serviceno = 5031 And e164 = '" + strE164 + "' ";
                        rs = stmt.executeQuery(sql);
                        cnt=-1;
    					if (rs.next()){ 
    						cnt = rs.getInt(1);
    					}
    					rs.close();
    					
    					// table_featureservice 등록
    					if (cnt == 0){
    						maxId2 	= dao.getMaxID(stmt, strE164);
    	                	sql = " insert into table_featureservice(e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) "; 
    		    			sql = sql + "  values('" + strE164 + "', '5031', "+ (maxId2 + 1) +", '" + originalFileName + "', 2, 1, 0, 2, '"+authGroupid+"')";
    		    			count += stmt.executeUpdate(sql);
    		    			//if (nResult < 0){	throw new Exception(l.x("[통화대기음 등록] '","[Auth Properties Error] '")+l.x("'통화대기음 등록이 실패하였습니다.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
    	        			
    		    			System.out.println("일괄 통화대기음 저장 성공");
    	                }else{
    	        			System.out.println("일괄 통화대기음 저장할 E164가 없습니다.");
    	                }
    					
    					// ############### LogHistory 처리  #############
//     					logHistory.LogHistoryGetIpSave(userID+"|83|통화대기음 ("+strE164+" 번)|1|");
    					// ##############################################
            		}
            		
            		if (stmt != null)
						stmt.endTransaction(true);
            		count = 1;
            }
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback 처리
        	e.printStackTrace();
        	count = 0;
        } finally {
            try {
                if (rs != null) rs.close();                
            } catch (Exception e) {}
        }
        
        if(count > 0){
        	
        	if (e164s.length > 0) {
        		for(String strE164 : e164s)
        	       	if( (strE164 = strE164.trim()).length()>0 ){
        	       		if(jsArray.length()==0)	jsArray.append("[{params:");
        	       		else					jsArray.append(",{params:");
        	       		
        	       		jsArray.append("[\""+strE164+"\",\""+originalFileName+"\"]}");
        	       	}
                if(jsArray.length()>0)	jsArray.append("]");
        	}	
%>
    <script>
        alert("저장되었습니다.");
        //parent.location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceNewMRBTList2.jsp?viewType="+"<%=e164%>";
        //parent.goInsertDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        parent.location.href = parent.location.href;
    </script>
<%
        }else{
%>
    <script>
        alert("저장이 실패하였습니다.");
    </script>
<%
        }
    }else{
%>
    <script>
        alert("형식이 올바르지 않습니다.");
    </script>
<%
    }
} catch(Exception e) {
	e.printStackTrace();
    tempFile.delete(); // Web템프 파일 삭제
} finally {
  	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>
