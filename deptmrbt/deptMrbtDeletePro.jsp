<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.ResultSet, business.LogHistory, java.util.Vector, java.io.File"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;
//String 	userID	  = new String(request.getParameter("hiUserID").getBytes("8859_1"), "euc-kr");		// �α��� ID

String userWavPath = StringUtil.null2Str(request.getSession(false).getAttribute("login.strUserWavPath"), "");
			
String e164      = StringUtil.null2Str(request.getParameter("e164"),"");
String[] e164s = StringUtil.getParser(e164, "");//e164.indexOf("|") > -1 ? e164.split("\\|") : new String[]{e164};
StringBuffer jsArray = new StringBuffer();

// �����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //���� ó���κ�
    AddServiceDAO dao 	= new AddServiceDAO();
    int count = 0 ;
 	// ############### LogHistory ó��  ###############
	//returnVal = dao.deptNewMRBTDelete(deleteStr);
 	int cnt=0, nResult=0;
    String sql="", fileName = "";
    ResultSet rs=null;
    Vector 	  	vecTmp 	  	= new Vector();
    File tempFile = null;
    try {
            if (stmt != null){
        		// Ʈ����� ����
				stmt.stxTransaction();

            	for(String strE164 : e164s){
            		strE164 = strE164.trim();
            		
            		int strValue = dao.getHuntConstraint(stmt, strE164);
					if(strValue>4){
						strValue = strValue - strValue % 8 + 0 + strValue % 4 ;
					}else{
						strValue = 0;
					}
                	sql = " Update table_keynumberid Set sound = '', huntconstraint = "+ strValue +" ";  
	    			sql = sql + "\n  Where keynumberid = '" + strE164 + "' ";
	    			System.out.println("SQL :\n"+sql);
	    			stmt.executeUpdate(sql);
                	
                    // addmrbt, ��ȭ ������ ���� ����			                    
	            	sql  = " SELECT sound FROM table_addmrbt WHERE e164 = '" + strE164 +"' ";
	            	System.out.println("SQL :\n"+sql);
                    rs = stmt.executeQuery(sql);
                    vecTmp.clear();
                    while(rs.next()){
    	            	vecTmp.add(WebUtil.CheckNullString(rs.getString(1)));            	
    	            }	                        
                    rs.close();
                    
                    int cnt3	= vecTmp.size();	                    
	                if (cnt3 > 0){
                    	sql = " Delete From table_addmrbt WHERE e164 = '" + strE164 +"' ";
                    	System.out.println("SQL :\n"+sql);
                    	stmt.executeUpdate(sql);
                    	
                        for(int j=0; j < cnt3; j++){
                        	fileName = (String)vecTmp.get(j);
                        	
		                    int nameChk = dao.wavFileChk(stmt, fileName);
		                	if(nameChk==0){
		                		int mrbtChk = dao.wavMRBTFileChk(stmt, fileName);
		                		if(mrbtChk==0){
			                		tempFile = new File(userWavPath.length()>0?userWavPath:StaticString.userWavPath +"/"+ fileName);
			                    	tempFile.delete();
		                		}
		                	}
                        }
                    }
						
						// ############### LogHistory ó��  #############
// 						LogHistory	logHistory 	= new LogHistory();
// 						int int_result = logHistory.LogHistorySave(userID+"|83|��ǥ��ȭ ������ ("+strE164+" ��)|2|"+strIp);
						// ##############################################
            	}//for
            	// commit ó��
				stmt.endTransaction(true);
				count = nResult = 1;
            }//if
    } catch (Exception e) {
    	stmt.endTransaction(false);		// rollback ó��
    	e.printStackTrace();
    	count = nResult = 0;
    } finally {
        try {
            if (rs != null) rs.close();                
        } catch (Exception e) {}
    }
        
	if(1!=1) count += dao.deptNewMRBTDelete(e164, request.getRemoteAddr(), userID)? 1:0;
	// ##############################################
    for(String strE164 : e164s)
    	if( (strE164 = strE164.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		jsArray.append("[\""+strE164+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    
    if(/* count >= e164s.length */ count > 0){
%>
    <script>
        alert("�����Ǿ����ϴ�.");
        //parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        //parent.location.href="./alarmTimeList.jsp";
        parent.location.href = parent.location.href;
    </script>
<%
    }else{
%>
    <script>
        alert("���� �� ������ �߻��Ͽ����ϴ�.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
    	for(String strE164 : e164s)
	       	if( (strE164 = strE164.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strE164+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");

 %>
    <script>
    	alert("�����Ǿ����ϴ�.");
        //parent.goDeleteDone(<%=jsArray.toString()%>);
        //parent.hiddenAdCodeDiv();
        parent.location.href = parent.location.href;
    </script>
<%
	}
} finally {
    //�Ҵ���� DataStatement ��ü�� �ݳ�
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>