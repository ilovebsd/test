function onlyNumber(formName,fieldName) 
{ 	
	var strValue = eval("document." + formName + "." + fieldName + ".value");
	if (isNaN(strValue)) 
	{ 
		alert("숫자만 입력하세요."); 
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
		alert("반드시 입력해야 하는 항목입니다.");
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
		alert("반드시 " + checkNum + "자리로 입력해야 합니다.");
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
