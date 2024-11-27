<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*"%>
<%@ page import="com.acromate.dao.element.ConditionalReplaceDAO"%>
<%@ page import="com.acromate.dto.element.ConditionalReplaceDTO"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

 // startnum --> areanum, localnum
 // table_featureservice 5282 inouflag
 //
 
String grpid        = StringUtil.null2Str(request.getParameter("groupid"),"").trim();
String loginid      = StringUtil.null2Str(request.getParameter("loginid"),"").trim();
String password     = StringUtil.null2Str(request.getParameter("password"),"").trim();

String domainid     = StringUtil.null2Str(request.getParameter("domainid"),"").trim();
String areanum     = StringUtil.null2Str(request.getParameter("areanum"),"").trim();
String localnum   = StringUtil.null2Str(request.getParameter("localnum"),"").trim();
String extnum           = StringUtil.null2Str(request.getParameter("extnum"),"").trim();
String authpasswd   = StringUtil.null2Str(request.getParameter("authpasswd"),"").trim();
String createcount  = StringUtil.null2Str(request.getParameter("createcount"),"").trim();

String outproxyip   = StringUtil.null2Str(request.getParameter("outproxyip"),"").trim();
String startprefix  = StringUtil.null2Str(request.getParameter("startprefix"),"").trim();
String endprefix    = StringUtil.null2Str(request.getParameter("endprefix"),"").trim();
String mindigit     = StringUtil.null2Str(request.getParameter("mindigit"),"").trim();
String maxdigit     = StringUtil.null2Str(request.getParameter("maxdigit"),"").trim();
if(mindigit.length()==0){
	mindigit = "1";
}
if(maxdigit.length()==0){
	maxdigit = "11";
}
String extensiongroupnum = "99999*";

StringBuffer jsArray = new StringBuffer();
ArrayList               envList = null;
// 서버로부터 DataStatement 객체를 할당
DataStatement   stmt = null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
        stmt                    = ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //처리부분
    CommonDAO dao = new CommonDAO();
    envList = dao.select(stmt, "select extensiongroupnum from Table_subscriberGroup where extensiongroupnum like '%*%' order by extensiongroupnum", new String[]{"extensiongroupnum"} ) ;
    if( envList.size() > 0 ){
        HashMap item = (HashMap)envList.get(0);
        int extgrpnum = Str.CheckNullInt( ((String)item.get("extensiongroupnum")).replace("*", "") );
        //out.print("<script>alert('old-extensiongroupnum="+extgrpnum+"');</script>") ;
        extensiongroupnum = "99999"+(--extgrpnum);
        extensiongroupnum = extensiongroupnum.substring(extensiongroupnum.length()-5)+"*" ;
        //out.print("<script>alert('new-extensiongroupnum="+extensiongroupnum+"');</script>") ;
    }
    
    StringBuffer sql = new StringBuffer();    
    int count = 0 ;
    /** Company ID **/
    sql.append("INSERT INTO Table_subscriberGroup (groupid, groupname, checkgroupid, prefixtableid, extensiongroupnum, callertype, maxextensiondigitcount, outcalleeblock, isgroupcharge, domain) ")
        .append(" VALUES ('"+grpid+"', '"+grpid+"', '"+grpid+"', '"+grpid+"', '"+extensiongroupnum+"', 1, 4, 3, 0, '"+domainid+"') ") ;
    count += dao.insert(stmt, sql.toString()) ;
    
    /** Manager Login **/
    sql.setLength(0) ;
    sql.append("INSERT INTO Table_subscriber (checkgroupid, id, name, position, pwd, loginlevel, phonenum) ")
        .append(" VALUES ('"+grpid+"', '"+loginid+"', '"+loginid+"', '"+loginid+"', '"+password+"', 0, '0000') ") ;
    count += dao.insert(stmt, sql.toString()) ;
    
    /** SubGroup **/
    sql.setLength(0) ;
    sql.append("INSERT INTO table_subgroup (groupid, subid, description, checkgroupid) ") ;
    sql.append(" VALUES ('"+grpid+"', '"+grpid+"', '"+grpid+"', '"+grpid+"') ") ;
    count += dao.insert(stmt, sql.toString()) ;
    
    /** Route Conditional Replace Service**/
	int idxOdrNo = 0;
    ConditionalReplaceDAO conditionalReplaceDAO = new ConditionalReplaceDAO();

    ConditionalReplaceDTO conditionalReplaceDTO = new ConditionalReplaceDTO();
    conditionalReplaceDTO.setEndpointID(grpid);
    conditionalReplaceDTO.setProtocol(2);
    conditionalReplaceDTO.setDirection(1);
    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setStartPosition(0);
    conditionalReplaceDTO.setConditionDigit(extensiongroupnum);
    conditionalReplaceDTO.setUpdateDigit("");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    	//hc-remove : 170327 : req. chun
//     conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
//     conditionalReplaceDTO.setConditionDigit("1");
//     conditionalReplaceDTO.setUpdateDigit(areanum + "1");
//     conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("2");
    conditionalReplaceDTO.setUpdateDigit(areanum + "2");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("3");
    conditionalReplaceDTO.setUpdateDigit(areanum + "3");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("4");
    conditionalReplaceDTO.setUpdateDigit(areanum + "4");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("5");
    conditionalReplaceDTO.setUpdateDigit(areanum + "5");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("6");
    conditionalReplaceDTO.setUpdateDigit(areanum + "6");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("7");
    conditionalReplaceDTO.setUpdateDigit(areanum + "7");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("8");
    conditionalReplaceDTO.setUpdateDigit(areanum + "8");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("9");
    conditionalReplaceDTO.setUpdateDigit(areanum + "9");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit(areanum + "15");
    conditionalReplaceDTO.setUpdateDigit("15");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit(areanum + "16");
    conditionalReplaceDTO.setUpdateDigit("16");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit(areanum + "18");
    conditionalReplaceDTO.setUpdateDigit("18");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("001");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("002");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("00321");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("00345");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("00365");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("005");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("006");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("00700");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("00755");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("00766");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("00770");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    conditionalReplaceDTO.setOrderNumber(idxOdrNo++);
    conditionalReplaceDTO.setConditionDigit("008");
    conditionalReplaceDTO.setUpdateDigit("00727");
    conditionalReplaceDAO.insert(stmt, conditionalReplaceDTO);

    sql.setLength(0) ;
    sql.append(" UPDATE Table_ConditionalReplace SET checkgroupid = '").append(grpid).append("' ") ;
    sql.append(" Where endpointID = '").append(conditionalReplaceDTO.getEndpointID()).append("' ") ;
    sql.append( " AND protocol = " + conditionalReplaceDTO.getProtocol()) ;
    sql.append( " AND direction = " + conditionalReplaceDTO.getDirection()) ;
    count = dao.update(stmt, sql.toString()) ;

	/** Dept **/
    int deptid = 0 ; 
	envList = dao.select(stmt, " SELECT coalesce(max(deptid),0) deptid FROM table_dept", new String[]{"deptid"} ) ;
    if( envList.size() > 0 ) {
        HashMap item = (HashMap)envList.get(0) ;
        deptid = Str.CheckNullInt( ((String)item.get("deptid")) ) ;
    }
    deptid ++ ;
    sql.setLength(0) ;
    sql.append("INSERT INTO table_dept (deptid, deptname, orgchartid, parentid, description, TYPE, usepickup, keynumber, officebox, OPERATION, sortnumber1, sortnumber2, checkgroupid) ") ;
    sql.append(" VALUES ("+deptid+", '"+grpid+"', '0', '1', '', '1', '1', '', '', '1', '2', '0', '"+grpid+"') ") ;
    count += dao.insert(stmt, sql.toString()) ;

	/** Group Block **/
    sql.setLength(0) ;
    sql.append("INSERT INTO table_groupblock (groupid, inoutflag, prefixtype, blockidtype, startprefix, endprefix, description, checkgroupid) ") ;
    sql.append(" VALUES ('"+grpid+"', '3', '2', '5', '"+extensiongroupnum+"','"+extensiongroupnum+"_________________________', '"+grpid+"', '"+grpid+"') ") ;
    count += dao.insert(stmt, sql.toString()) ;

	/** Neighbor Proxy **/
    sql.setLength(0) ;
    sql.append("INSERT INTO table_neighborproxy (endpointid, indomainname, authmode, endpointclass, signaladdress, signalport, password, username, outfromdomainname, outtodomainname, fromnumber, tonumber, messagetype, channelmonitor, inviaaddress, uritype, uriparam, dtmftype, OPTIONS, inviaport, checkgroupid) ") ;
    sql.append(" VALUES ('"+grpid+"', '', '0', '40', '" + outproxyip + "', '5060', '', '', '', '', '', '', '0', '0', '" + outproxyip + "', '0', '', '3', '65538', '5060', '"+grpid+"') " ) ;
    count += dao.insert(stmt, sql.toString()) ;

	/** Position **/
    sql.setLength(0) ;
    sql.append("INSERT INTO table_position (positionid, positionname, ranking, checkgroupid) VALUES ("+deptid+", '"+grpid+"', 2, '"+grpid+"') " ) ;
    count += dao.insert(stmt, sql.toString()) ;
	
    /** RouteService **/
    int inaddibleflag = 0, outaddibleflag = 0;
    
    sql.setLength(0) ;
    sql.append("INSERT INTO table_routeservice (endpointID, protocol, serviceNo, priority, userParam, inoutFlag, checkgroupid ) ");
    sql.append("VALUES ('"+grpid+"', 2, 2451, 2451, '' , 1, '"+grpid+"') " ) ;
    count += dao.insert(stmt, sql.toString()) ;
    inaddibleflag = 1;
    
    sql.setLength(0) ;
    sql.append("INSERT INTO table_routeservice (endpointID, protocol, serviceNo, priority, userParam, inoutFlag, checkgroupid ) ");
    sql.append("VALUES ('"+grpid+"', 2, 2211, 2211, '' , 3, '"+grpid+"') " ) ;
    count += dao.insert(stmt, sql.toString()) ;
    outaddibleflag = 1;
    
    sql.setLength(0) ;
    sql.append("INSERT INTO table_routeservice (endpointID, protocol, serviceNo, priority, userParam, inoutFlag, checkgroupid ) ");
    sql.append("VALUES ('"+grpid+"', 2, 2051, 2051, '' , 1, '"+grpid+"') " ) ;
    count += dao.insert(stmt, sql.toString()) ;
	
    
	/** RouteState **/
    sql.setLength(0) ;
    sql.append("INSERT INTO table_routestate (endpointid, protocol, endpointclass, routecode, groupid, groupattach, stateflag, serviceflag, inmaxcall, outmaxcall, incurrentcall, outcurrentcall, inalarmcall, outalarmcall, blockcount, instartposition," ) ; 
    sql.append("incutprefix, inaddprefix, outstartposition, outcutprefix, outaddprefix, incutcid, inaddcid, outcutcid, outaddcid, maxdetourcount, channellimitmode, totalmaxcall, totalalarmcall, zonecode, routename, OPTIONS, chargenumber, routetype, checkgroupid, ") ;
    sql.append("INCALLEEBLOCK, INCALLERBLOCK, OUTCALLERBLOCK, INREPLACE, OUTREPLACE, inaddibleflag, outaddibleflag ) ") ;
    sql.append("VALUES ('"+grpid+"', '2', '40', '', '"+grpid+"', '3', '1', '1', '1000000000', '1000000000', '0', '0', '0', '0', '0', '0', '0', '', '0', '0', '', '0', '', '0', '', '0', '0', '1000000000', '0', 'Z0000', '', '1', '', '', '"+grpid+"', 0, 0, 0, 0, 1, "+inaddibleflag+", "+outaddibleflag+") ") ;

    count += dao.insert(stmt, sql.toString()) ;

    /** Routing **/
    sql.setLength(0) ;
    sql.append("INSERT INTO Table_prefixtableid (prefixtableid, checkgroupid, description, tabletype) ") ;
    sql.append(" VALUES ('"+grpid+"', '"+grpid+"', '"+grpid+"', 1) ") ;
    count += dao.insert(stmt, sql.toString()) ;
    
    endprefix = endprefix + "_______________________________" ;
    endprefix = endprefix.substring(0,32) ;
    
    sql.setLength(0) ;
    sql.append("INSERT INTO table_prefixtable (prefixtableid, startprefix, endprefix, calltype, routeselectrule, protocol, routeid, chargetype, description, mindigitcount, maxdigitcount, routingendpointtype, checkgroupid) ") ;
    //sql.append(" VALUES ('"+grpid+"', '"+startprefix+"', '"+endprefix+"', 2, 1, 2, '"+grpid+"', 1, '', 1, 11, 1, '"+grpid+"') ") ;
    sql.append(" VALUES ('"+grpid+"', '"+startprefix+"', '"+endprefix+"', 2, 1, 2, '"+grpid+"', 1, '', "+mindigit+", "+maxdigit+", 1, '"+grpid+"') ") ;
    count += dao.insert(stmt, sql.toString()) ;
    
    //hc-add : 170327 : req. chun
    sql.setLength(0) ;
    sql.append("INSERT INTO table_prefixtable (prefixtableid, startprefix, endprefix, calltype, routeselectrule, protocol, routeid, chargetype, description, mindigitcount, maxdigitcount, routingendpointtype, checkgroupid) ") ;
    sql.append(" VALUES ('"+grpid+"', '0000000000', '0000000000______________________', 2, 1, 2, 'MS', 0, 'MS Service Code', 10, 12, 1, '"+grpid+"') ") ;
    count += dao.insert(stmt, sql.toString()) ;
    

    /** Phone-Number **/
    String number = "1" + extnum ;
    int extnumLength = extnum.length() ;
    int nPlus = Str.CheckNullInt( number ) ;
    int nCount = Str.CheckNullInt( createcount ) + nPlus;
    String tailDomain = domainid.length()>0 ? "@"+domainid+":5060" : "@vpbx.callbox.kt.com:5060" ;
    while(nPlus < nCount){
    	extnum = String.valueOf(nPlus).substring(1) ;
        String phoneNumber = areanum + localnum + extnum ;
    	String endpointID = phoneNumber+tailDomain;//"@vpbx.callbox.kt.com:5060" ;
 
        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164 (e164, VirtualCID, areacode, isgroup, groupid, extensionnumber, prefixtableid, startflag, chargetype, endpointrelationtype, callerservice, answerservice, commonservice, subid,mailbox, checkgroupid) ") ;
        sql.append("VALUES ('"+phoneNumber+"', '"+phoneNumber+"', '"+areanum+"', 2, '"+grpid+"', '"+extnum+"', '', 1, 0, 2, '0000000000000000000000000000000000000000000000000000000000000000', '0000000000000000000000000000000000000000000000000000000000000000', '01010000000000000000000000000000', '"+grpid+"', '', '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164route (routingnumber, e164, protocol, endpointid, routingnumbertype, priority, checkgroupid) ") ;
        sql.append("VALUES ('"+phoneNumber+"', '"+phoneNumber+"', 2, '"+endpointID+"', 1, 1, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164route (routingnumber, e164, protocol, endpointid, routingnumbertype, priority, checkgroupid) ") ;
        sql.append("VALUES ('"+ localnum + extnum +"', '"+phoneNumber+"', 2, '"+endpointID+"', 2, 1, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_e164route (routingnumber, e164, protocol, endpointid, routingnumbertype, priority, checkgroupid) ") ;
        sql.append("VALUES ('"+ extensiongroupnum + extnum +"', '"+phoneNumber+"', 2, '"+endpointID+"', 5, 1, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;

        /* Endpoint ID */
        sql.setLength(0) ;
        sql.append("INSERT INTO table_SIPENDPOINT(EndpointID, EndpointClass, DomainID, DynamicFlag, ZoneCode, MultiEndpoint, DtmfType, OPTIONS, checkgroupid) ") ;
        sql.append("VALUES ('"+endpointID+"', 33, '"+domainid+"', 0, '', 0, 0, 0, '"+grpid+"')") ;
        count += dao.insert(stmt, sql.toString()) ;
        
        sql.setLength(0) ;
        sql.append("INSERT INTO table_auth (e164, protocol, endpointid, password, authmode, username, ipaddress, ipport, DESCRIPTOR, checkgroupid) ") ; 
        sql.append(" VALUES ('0', 2, '"+endpointID+"', '"+authpasswd+"', 128, '"+phoneNumber+"', '', 0, '', '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;
        
        sql.setLength(0) ;
        sql.append("INSERT INTO table_subscriber (id, loginlevel, pwd, phonenum, name, POSITION, department, mobile, homenumber, extension, mailaddress, checkgroupid) ") ; 
        sql.append(" VALUES ('"+endpointID+"', 1, '"+authpasswd+"', '"+phoneNumber+"', '"+phoneNumber+"', '"+grpid+"', 3, '', '', '"+extnum+"', '', '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;
//ok
        sql.setLength(0) ;
        sql.append("INSERT INTO table_featureservice (e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) ") ; 
        sql.append("VALUES ('"+phoneNumber+"', 5282, 5282, '', 2, 1, 0, 2, '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("INSERT INTO table_featureservice (e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) ") ; 
        sql.append("VALUES ('"+phoneNumber+"', 5031, 5031, 'default_moh.wav', 2, 1, 0, 2, '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;

        sql.setLength(0) ;//hc-add : 161103 : Virtual CID
        sql.append("INSERT INTO table_featureservice (e164, serviceno, priority, userparam, inoutflag, servicetype, errorcontrol, protocol, checkgroupid) ") ; 
        sql.append("VALUES ('"+phoneNumber+"', 5431, 5431, '3,"+phoneNumber+",', 2, 1, 0, 2, '"+grpid+"') ") ;
        count += dao.insert(stmt, sql.toString()) ;
        
        nPlus++;
    }
    
    if( count > 0 ){
        jsArray.append("[{params:").append("[\""+grpid+"\",\""+extensiongroupnum+"\"]}");
//         jsArray.append(",{params:").append("[\"extensiongroupnum\",\""+extensiongroupnum+"\"]}");
        jsArray.append("]");
%>
    <script>
        alert("등록되었습니다.");
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./subsList.jsp";
    </script>
<%
    } else {
%>
    <script>
        alert("등록 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
    if(nModeDebug==1){
        extensiongroupnum = "99999*";
        jsArray.append("[{params:").append("[\""+grpid+"\",\""+extensiongroupnum+"\"]}");
//         jsArray.append(",{params:").append("[\"extensiongroupnum\",\""+extensiongroupnum+"\"]}");
        jsArray.append("]"); 
 %>
    <script>
        alert("등록되었습니다.");
        parent.goInsertDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
        }
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}
%>
