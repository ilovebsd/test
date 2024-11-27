<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="UTF-8"%>
<%@ page import="framework.Shell.LinuxShell"%>
<%@ page import="system.SystemConfigSet"%>

<%
	try{
		String 		forwardingIp 	= request.getParameter("forwardingIp");
		String 		forwardingPort 	= request.getParameter("forwardingPort");
		
		String[]	tempStr 		= forwardingIp.split("[.]");
		String 		ip01			= tempStr[0];
		String 		ip02			= tempStr[3];
		int			tmpPort			= Integer.parseInt(ip01)*Integer.parseInt(ip02);
		String		forwardingPort2 = Integer.toString(tmpPort);						// IP 첫번째, 네번째 곱해서 Port로 사용
		
		SystemConfigSet systemConfig 	= new SystemConfigSet();
		LinuxShell 		linuxShell 		= new LinuxShell();
		String 			osType 			= "";
		
		System.out.println("########### forwardingIp : "+forwardingIp);
		System.out.println("########### forwardingPort : "+forwardingPort);
		System.out.println("########### ip01 : "+ip01);
		System.out.println("########### ip02 : "+ip02);
		System.out.println("########### forwardingPort2 : "+forwardingPort2);

		try{
        	// 유닉스 장비이면 실행
        	osType = systemConfig.osChk();
        	if("uix".equals(osType)){ 
        		//String tmpCommand01 = "echo 'rdr on wan proto tcp from any to any port 9000 -> ";
        		//String tmpCommand02 = "  port ";
        		//String tmpCommand03 = "' | pfctl -a port-forward -f -";
        		//String strCommand 	= tmpCommand01+forwardingIp+tmpCommand02+forwardingPort+tmpCommand03;
        		
        		//System.out.println("########### tmpCommand01 : "+tmpCommand01);
        		//System.out.println("########### tmpCommand02 : "+tmpCommand02);
        		//System.out.println("########### tmpCommand03 : "+tmpCommand03);
        		//System.out.println("########### strCommand : "+strCommand);

        		// 2012.05.03 포드포워드 명령어 수정 ===========================================================================
        		//String tmpCommand01 = "pfctl -a port-forward -F nat | echo 'rdr on wan proto tcp from any to any port ";
        		String tmpCommand01 = "pfctl -a phone_forward -F nat | echo 'rdr on wan proto tcp from any to any port ";
        		String tmpCommand02 = " -> ";
        		String tmpCommand03 = "  port ";
        		//String tmpCommand04 = "' | pfctl -a port-forward -f -";
        		String tmpCommand04 = "' | pfctl -a phone_forward -f -";
        		// =======================================================================================================
        		String strCommand 	= tmpCommand01+forwardingPort2+tmpCommand02+forwardingIp+tmpCommand03+forwardingPort+tmpCommand04;
        		
        		System.out.println("########### tmpCommand01 : "+tmpCommand01);
        		System.out.println("########### tmpCommand02 : "+tmpCommand02);
        		System.out.println("########### tmpCommand03 : "+tmpCommand03);
        		System.out.println("########### tmpCommand04 : "+tmpCommand04);
        		System.out.println("########### strCommand : "+strCommand);

        		//String strCommand = "echo 'rdr on wan proto tcp from any to any port 9000 -> "+forwardingIp+"  port "+forwardingPort+"' | pfctl -a port-forward -f -";
        		//linuxShell.runShell("echo 'rdr on wan proto tcp from any to any port 9000 -> "+forwardingIp+"  port "+forwardingPort+"' | pfctl -a port-forward -f –");
        		linuxShell.runShell(strCommand);
        		
        		System.out.println("########### unix Forwarding : "+strCommand);
        		
        		out.clear();
    			out.print("OK");
        	}else{
				out.clear();
				out.print("NO");
        	}
		}catch(Exception se){
			System.out.println("error-->" +se );
			out.clear();
			out.print("NO");
		}finally{
			try{

			}catch(Exception e){
				System.out.println("DB Connection Exception : "+e);
			}			
		}	
	}catch(Exception ex){
		System.out.println(ex);
	}finally{
	} 
%>
