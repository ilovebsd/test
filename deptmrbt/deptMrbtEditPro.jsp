<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
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

<% 
String originalFileName = "";    // �����ϸ�
String s = "";

File      tempFile         = null;  // �ӽ� ���� ��ü

String e164   		= "";
String startTime 	= "";
String endTime   	= "";
String dayValue 	= "";
String dbfile    	= "";

//String userID    	= "";

/* SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
} */

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

String userWavPath = StringUtil.null2Str(request.getSession(false).getAttribute("login.strUserWavPath"), "");
		
e164 			= null;//new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr");
String[] e164s  = null;//StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

//�����κ��� DataStatement ��ü�� �Ҵ�
DataStatement stmt = null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try {
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	boolean isMultipart = FileUpload.isMultipartContent(request);

    DiskFileUpload dfu = new DiskFileUpload();
    
    dfu.setSizeThreshold(100*1024);         // ���ε� �Ҵ� �޸� ũ��   (100 KB)
    dfu.setSizeMax(30 * 1024 * 1024);        // ���ε� ������ �ִ� ũ��   (5 M)
    dfu.setRepositoryPath(userWavPath.length()>0?userWavPath:StaticString.userWavPath);   // ���Ͼ��ε� ���� ���� ��Ʈ (WAS)
  	
    if(isMultipart){    // multipart/form-data �� ���
    	// request parsing..
        List fileItemList = dfu.parseRequest(request);

        Iterator iter = fileItemList.iterator();

        while (iter.hasNext()) {
            FileItem item = (FileItem) iter.next();

            if (item.isFormField()) {                           // ������ ������ ���ʵ�
            	//System.out.println("############## 1 : "+item.getFieldName());

            	if("hiEi64_03".equals(item.getFieldName())){
            		e164 = item.getString();
            		e164s  = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
            	}else if("hiStartTime_03".equals(item.getFieldName())){
            		startTime = item.getString();
            	}else if("hiEndTime_03".equals(item.getFieldName())){
            		endTime = item.getString();
            	}else if("hiDayValue_03".equals(item.getFieldName())){
            		dayValue = item.getString();                
            	
            	}else if("uploadfilename_03".equals(item.getFieldName())){
                	dbfile = item.getString();
                
            	}/* else if("hiUserID".equals(item.getFieldName())){
            		userID = item.getString();
                
            	} */                	

            }else{
            	String fileName = item.getName();
            	//System.out.println("############## 2 : "+fileName);
                if(!fileName.equals("")){
                    if(item.getSize() >= (1024 * 1024 * 5)){
%>
    <script>
        alert("����ũ��� 5Mbyte�̳������մϴ�.");
    </script>
<%
                        return;
                    }
                    originalFileName = Str.CheckNullString(fileName.substring(fileName.lastIndexOf("\\")+1)); //�����ϸ� 

                    for (int i=0; i< originalFileName.length(); i++) {
                        if((int)originalFileName.charAt(i) > 127) {	// �ѱ��� ���.
%>
    <script>
        alert("���ϸ� �ѱ��� �� �� �����ϴ�.");
    </script>
<%
                            return;
                        }
                    }

                    tempFile = new File(dfu.getRepositoryPath()+"/"+originalFileName);

                    if (tempFile.exists()) {                 // ��������

                    	int flag = 0;
                    	//���ȵǴ� ���� ���� ����
            			if( 1==1 ){
            				AddServiceDAO dao 	= new AddServiceDAO();
            				
                            int nameChk = dao.wavFileChk(stmt, originalFileName);
                           	if(nameChk==0){
                           		int mrbtChk = dao.wavMRBTFileChk(stmt, originalFileName);
                           		if(mrbtChk==0){
                           			System.out.println("DELETE old wav FILE : "+originalFileName);
                           			File oldFile = new File(userWavPath.length()>0?userWavPath:StaticString.userWavPath+"/"+originalFileName);
           	                		oldFile.delete();
           	                    	flag = 1;
                           		}
                           	}
                    	}//if
            			
            			if(flag==0){
%>
    <script>
        alert("���ϸ��� �̹� �����մϴ�. �ٸ��̸����� ���ε��Ͽ� �ֽñ� �ٶ��ϴ�.");
    </script>
<%
                     	   return;
            			}
                    }//while
                    
                    item.write(tempFile);
                }
            }
        }

        if("".equals(originalFileName)){
            originalFileName = dbfile;
        }

        FeatureServiceDTO dto = new FeatureServiceDTO();
                                    
//        dto.setE164(e164);
//        dto.setServiceNo(5011);
//        dto.setUserParam("3,9, ");
		Vector 	  	vecTmp 	  	= new Vector();
        String strUserParm	= "3,9, ", fileName = "";
        AddServiceDAO dao 	= new AddServiceDAO();
        
        //int count = dao.setAddUserMRBT(stmt, strUserParm, e164, startTime, endTime, dayValue, originalFileName);
        //int count = dao.setAddUserMRBT(stmt, strUserParm, e164, startTime, endTime, dayValue, originalFileName, userID);
        int cnt=0, nResult=0, count = 0 ;//dao.setNewDeptMRBT(stmt, strUserParm, e164, startTime, endTime, dayValue, originalFileName, userID, authGroupid);
        String sql="";
        ResultSet rs=null;
        try {
            if (stmt != null){
        		// Ʈ����� ����
				stmt.stxTransaction();

            	for(String strE164 : e164s){
            		strE164 = strE164.trim();
            		
            		sql  = " Select count(b.KEYNUMBERID) "; 
            		sql += " FROM  table_localprefix a LEFT OUTER JOIN table_KeyNumberID b  ON a.endpointid = b.KEYNUMBERID "; 
            		sql += " Where 1 = 1 and a.prefixtype = 4 ";
            		sql += "   and b.KEYNUMBERID = '" + strE164 + "' ";
            		if(authGroupid!=null) sql += " AND a.checkgroupid = '" + authGroupid + "' ";
            		
            		System.out.println("SQL :\n"+sql);
                    rs = stmt.executeQuery(sql);
                    cnt = -1;
					if (rs.next()){ 
						cnt = rs.getInt(1);
					}
					rs.close();
					
					// table_featureservice ���
					if (cnt >= 1){
						int strValue = dao.getHuntConstraint(stmt, strE164);
						//strValue = strValue + 4;
						strValue = strValue - strValue % 8 + 4 + strValue % 4 ;

						sql = " Update table_keynumberid ";
						sql = sql + "\n Set sound = '3,9, ', huntconstraint = "+ strValue +" ";
		    			sql = sql + "\n Where keynumberid = '" + strE164 + "' ";
		    			//if(authGroupid!=null) sql += " AND checkgroupid = '" + authGroupid + "' ";
		    			System.out.println("SQL :\n"+sql);
		    			nResult = stmt.executeUpdate(sql);
		    			//if (nResult < 0){	throw new Exception(l.x("[��ǥ ��ȭ������ ���] '","[Auth Properties Error] '")+l.x("'��ǥ ��ȭ������ ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
					
	                	sql  = " SELECT count(*) FROM table_addmrbt " ;
	            		sql += "\n  WHERE e164 = '" + strE164 + "' And dayvalue = '" + dayValue + "' ";
	            		sql += "\n  And starttime = '" + startTime + "' And endtime = '" + endTime + "' ";
	            		System.out.println("SQL :\n"+sql);
	                    rs = stmt.executeQuery(sql);
	                    cnt = -1;
						if (rs.next()){ 
							cnt = rs.getInt(1);
						}
						rs.close();
	            		
						// table_addmrbt ���
						if (cnt == 0){
							
							sql  = " SELECT sound FROM table_addmrbt WHERE e164 = '" + strE164 +"' ";
			            	System.out.println("SQL :\n"+sql);
		                    rs = stmt.executeQuery(sql);
		                    //vecTmp.clear();
		                    while(rs.next()){
		    	            	vecTmp.add(WebUtil.CheckNullString(rs.getString(1)));
		    	            }	                        
		                    rs.close();
		                    
		                	sql = " insert into table_addmrbt(e164, dayvalue, starttime, endtime, sound) "; 
			    			sql = sql + "\n  values('" + strE164 + "', '" + dayValue + "', '" + startTime + "', '" + endTime + "', '" + originalFileName + "')";
			    			System.out.println("SQL :\n"+sql);
			    			nResult = stmt.executeUpdate(sql);
			    			//if (nResult < 0){	throw new Exception(l.x("[ADD MRBT ��ȭ������ ���] '","[Auth Properties Error] '")+l.x("'ADD MRBT ��ȭ������ ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
						}
						
						// ############### LogHistory ó��  #############
// 						LogHistory	logHistory 	= new LogHistory();
// 						logHistory.LogHistoryGetIpSave(userID+"|83|��ǥ��ȭ ������ ("+strE164+" ��)|1|");
						// ##############################################
					}
					
            	}//for
            	
            	// commit ó��
				stmt.endTransaction(true);
				count = nResult = 1;
				
				//���ȵǴ� ���� ���� ����
				if( 1!=1 && vecTmp.size() > 0 ){
                    for(int j=0; j < vecTmp.size(); j++){
                    	fileName = (String)vecTmp.get(j);
                    	
	                    int nameChk = dao.wavFileChk(stmt, fileName);
	                	if(nameChk==0){
	                		int mrbtChk = dao.wavMRBTFileChk(stmt, fileName);
	                		if(mrbtChk==0){
		                		tempFile = new File(userWavPath.length()>0?userWavPath:StaticString.userWavPath+"/"+fileName);
		                    	tempFile.delete();
	                		}
	                	}
                    }//for
            	}//if

            }
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback ó��
        	e.printStackTrace();
        	count = nResult = 0;
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
        alert("����Ǿ����ϴ�.");
        //parent.location.href="<%=StaticString.ContextRoot%>/useconfig/addServiceNewMRBTList2.jsp?viewType="+"<%=e164%>";
        //parent.goInsertDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        parent.location.href = parent.location.href;
    </script>
<%
        }else{
%>
    <script>
        alert("������ �����Ͽ����ϴ�.");
    </script>
<%
        }
    }else{
%>
    <script>
        alert("������ �ùٸ��� �ʽ��ϴ�.");
    </script>
<%
    }
} catch(Exception e) {
	e.printStackTrace();
    tempFile.delete(); // Web���� ���� ����
} finally {
  	//�Ҵ���� DataStatement ��ü�� �ݳ�
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}

%>
