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
String originalFileName = "";    // �����ϸ�
String s = "";

File      tempFile         = null;  // �ӽ� ���� ��ü

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

                    while (tempFile.exists()) {                 // ��������
%>
    <script>
        alert("���ϸ��� �̹� �����մϴ�. �ٸ��̸����� ���ε��Ͽ� �ֽñ� �ٶ��ϴ�.");
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
            		// Ʈ����� ����
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
    					
    					// table_featureservice ���
    					if (cnt == 0){
    						maxId2 	= dao.getMaxID(stmt, strE164);
    	                	sql = " insert into table_featureservice(e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) "; 
    		    			sql = sql + "  values('" + strE164 + "', '5031', "+ (maxId2 + 1) +", '" + originalFileName + "', 2, 1, 0, 2, '"+authGroupid+"')";
    		    			count += stmt.executeUpdate(sql);
    		    			//if (nResult < 0){	throw new Exception(l.x("[��ȭ����� ���] '","[Auth Properties Error] '")+l.x("'��ȭ����� ����� �����Ͽ����ϴ�.","' Phone Authentication Properties registration failed. Phone Insertion failed."));	}
    	        			
    		    			System.out.println("�ϰ� ��ȭ����� ���� ����");
    	                }else{
    	        			System.out.println("�ϰ� ��ȭ����� ������ E164�� �����ϴ�.");
    	                }
    					
    					// ############### LogHistory ó��  #############
//     					logHistory.LogHistoryGetIpSave(userID+"|83|��ȭ����� ("+strE164+" ��)|1|");
    					// ##############################################
            		}
            		
            		if (stmt != null)
						stmt.endTransaction(true);
            		count = 1;
            }
        } catch (Exception e) {
        	stmt.endTransaction(false);		// rollback ó��
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
