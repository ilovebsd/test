function onlyNumber(formName,fieldName) 
{ 	
	var strValue = eval("document." + formName + "." + fieldName + ".value");
	if (isNaN(strValue)) 
	{ 
		alert("���ڸ� �Է��ϼ���."); 
		eval("document." + formName + "." + fieldName + ".focus();");
		return false; 
	} 
	return true; 
} 



function blankValue(formName,fieldName) 
{ 
	var strValue = eval("document." + formName + "." + fieldName + ".value");
	if (strValue == "") 
	{ 
		alert("�ݵ�� �Է��ؾ� �ϴ� �׸��Դϴ�.");
		eval("document." + formName + "." + fieldName + ".focus();");
		return false; 
	} 
	return true; 
}



function blankValueMsg(formName,fieldName,viewStr) 
{ 
	var strValue = eval("document." + formName + "." + fieldName + ".value");
	if (strValue == "") 
	{ 
		alert(viewStr);
		eval("document." + formName + "." + fieldName + ".focus();");
		return false; 
	} 
	return true; 
}



function lengthCheck(formName,fieldName,checkNum) 
{ 
	if (!onlyNumber(formName,fieldName))
	{
		return false;
	}

	var strValue = eval("document." + formName + "." + fieldName + ".value.length;");
	if (strValue != checkNum) 
	{ 
		alert("�ݵ�� " + checkNum + "�ڸ��� �Է��ؾ� �մϴ�.");
		eval("document." + formName + "." + fieldName + ".focus();");
		return false; 
	} 
	return true; 
}


function lengthCheckOnly(formName,fieldName,checkNum,altstr) 
{ 
	var strValue = eval("document." + formName + "." + fieldName + ".value.length;");
	if (strValue != checkNum) 
	{ 
		alert(altstr);
		eval("document." + formName + "." + fieldName + ".focus();");
		return false; 
	} 
	return true; 
}
