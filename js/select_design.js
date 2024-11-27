/***********************************************************************************
**** Select Box Design Script ******************************************************
**** Start *************************************************************************
************************************************************************************/
var nowOpenedSelectBox = "";
var mousePosition = "";

function selectThisValue(thisId,thisIndex,thisValue,thisString) {
	var objId = thisId;
	var nowIndex = thisIndex;
	var valueString = thisString;
	var sourceObj = document.getElementById(objId);
	var nowSelectedValue = document.getElementById(objId+"SelectBoxOptionValue"+nowIndex).value;
	hideOptionLayer(objId);
	if (sourceObj) sourceObj.value = nowSelectedValue;
	settingValue(objId,valueString);
	selectBoxFocus(objId);
	if (sourceObj.onchange) sourceObj.onchange();
}

function selectThisValueMyMenu(thisId,thisIndex,thisValue,thisString, className) {
	var objId = thisId;
	var nowIndex = thisIndex;
	var valueString = thisString;
	var sourceObj = document.getElementById(objId);
	var nowSelectedValue = document.getElementById(objId+"SelectBoxOptionValue"+nowIndex).value;
	hideOptionLayer(objId);
	if (sourceObj) sourceObj.value = nowSelectedValue;
	settingValue(objId,valueString);
	selectBoxFocusMyMenu(objId, className);
	if (sourceObj.onchange) sourceObj.onchange();
}

function settingValue(thisId,thisString) {
	var objId = thisId;
	var valueString = thisString;
	var selectedArea = document.getElementById(objId+"selectBoxSelectedValue");
	if (selectedArea) selectedArea.innerHTML = valueString.replace("&","&");
}

function viewOptionLayer(thisId) {
	var objId = thisId;
	var optionLayer = document.getElementById(objId+"selectBoxOptionLayer");
	if (optionLayer) optionLayer.style.display = "";
	nowOpenedSelectBox = objId;
	setMousePosition("inBox");
}

function hideOptionLayer(thisId) {
	var objId = thisId;
	var optionLayer = document.getElementById(objId+"selectBoxOptionLayer");
	if (optionLayer) optionLayer.style.display = "none";
}

function setMousePosition(thisValue) {
	var positionValue = thisValue;
	mousePosition = positionValue;
}

function clickMouse() {
	if (mousePosition == "out") hideOptionLayer(nowOpenedSelectBox);
}

function selectBoxFocus(thisId) {
	var objId = thisId;
	var obj = document.getElementById(objId + "selectBoxSelectedValue");
	obj.className = "selectBoxSelectedAreaFocus";
	obj.focus();
}

function selectBoxFocusMyMenu(thisId, classNameFocus) { //MyMeny
	var objId = thisId;
	var obj = document.getElementById(objId + "selectBoxSelectedValue");
	obj.className = classNameFocus;
	obj.focus();
}

function selectBoxBlurMyMenu(thisId, classNameFocus) {
	var objId = thisId;
	var obj = document.getElementById(objId + "selectBoxSelectedValue");
	obj.className = classNameFocus;
}

function selectBoxBlur(thisId) {
	var objId = thisId;
	var obj = document.getElementById(objId + "selectBoxSelectedValue");
	obj.className = "selectBoxSelectedArea";
}


function makeSelectBoxGlobal(thisId, selectBoxSelectedArea, lineColor, downArrowSrcPath, selectBoxOption, selectBoxSelectedAreaFocus, selectBoxOptionOver) {
	var downArrowSrc = downArrowSrcPath; //rightArrow
	var downArrowSrcWidth = 17;	//rightQrrow Image width
	var optionHeight = 19; // option heigh
	var optionMaxNum = 6; // option Maxnum
	var optionInnerLayerHeight = "";
	var objId = thisId;
	var obj = document.getElementById(objId);
	var selectBoxWidth = parseInt(obj.style.width);
	var selectBoxHeight = parseInt(obj.style.height);
	if (obj.options.length > optionMaxNum) optionInnerLayerHeight = "height:"+ (optionHeight * optionMaxNum) + "px";
	newSelect  = "<table id='" + objId + "selectBoxOptionLayer' cellpadding='0' cellspacing='0' border='0' style='position:absolute;z-index:100;display:none;' onMouseOver=\"viewOptionLayer('"+ objId + "')\" onMouseOut=\"setMousePosition('out')\">";
	newSelect += "	<tr>";
	newSelect += "		<td height='" + (selectBoxHeight - 1) + "' style='cursor:hand;' onClick=\"hideOptionLayer('"+ objId + "')\" onMouseOut=\"hideOptionLayer('"+ objId + "')\"></td>";
	newSelect += "	</tr>";
	newSelect += "	<tr>";
	newSelect += "		<td bgcolor='"+lineColor+"' style='padding:0px 1px 1px 1px'>";
	newSelect += "		<table cellpadding='0' cellspacing='0' border='0' width='100%'>";
	newSelect += "			<tr>";
	newSelect += "				<td height='3' bgcolor='#f5f5f5'></td>";
	newSelect += "			</tr>";
	newSelect += "		</table>";
	newSelect += "		<div id='"+ objId + "SelectBoxOptionArea' class='selectBoxOptionInnerLayer' style='width:" + (selectBoxWidth-2) + "px;" + optionInnerLayerHeight + "' onMouseOut=\"hideOptionLayer('"+ objId + "')\">";
	newSelect += "		<table cellpadding='0' cellspacing='0' border='0' width='100%' style='table-layout:fixed;word-break:break-all;'>";
	for (var i=0 ; i < obj.options.length ; i++) {
		var nowValue = obj.options[i].value;
		var nowText = obj.options[i].text;
		if (nowValue != null && nowValue != "") { // value.
			newSelect += "			<tr>";
			newSelect += "				<td height='" + optionHeight + "' class='"+selectBoxOption+"' onMouseOver=\"this.className='"+selectBoxOptionOver+"'\" onMouseOut=\"this.className='"+selectBoxOption+"'\" onClick=\"selectThisValueMyMenu('"+ objId + "'," + i + ",'" + nowValue + "','" + nowText + "','"+selectBoxSelectedAreaFocus+"')\" style='cursor:hand;'>" + nowText + "</td>";
			newSelect += "				<input type='hidden' id='"+ objId + "SelectBoxOptionValue" + i + "' value='" + nowValue + "'>";
			newSelect += "			</tr>";
		}
	}
	newSelect += "		</table>";
	newSelect += "		</div>";
	newSelect += "		<table cellpadding='0' cellspacing='0' border='0' width='100%'>";
	newSelect += "			<tr>";
	newSelect += "				<td height='4' bgcolor='#f5f5f5'></td>";
	newSelect += "			</tr>";
	newSelect += "		</table>";
	newSelect += "		</td>";
	newSelect += "	</tr>";
	newSelect += "</table>";
	newSelect += "<table cellpadding='0' cellspacing='1' border='0' bgcolor='"+lineColor+"' onClick=\"viewOptionLayer('"+ objId + "')\" style='cursor:hand;' onMouseOut=\"setMousePosition('out')\">";
	newSelect += "	<tr>";
	newSelect += "		<td bgcolor='#ffffff'>";
	newSelect += "		<table cellpadding='0' cellspacing='0' border='0'>";
	newSelect += "			<tr>";
	newSelect += "				<td><div id='" + objId + "selectBoxSelectedValue' class='"+selectBoxSelectedArea+"' style='width:" + (selectBoxWidth - downArrowSrcWidth - 2) + "px;height:" + (selectBoxHeight - 2) + "px;overflow:hidden;' onBlur=\"selectBoxBlurMyMenu('" + objId + "', '"+selectBoxSelectedAreaFocus+"')\"></div></td>";
	newSelect += "				<td><img src='" + downArrowSrc + "' width='" + downArrowSrcWidth + "' border='0'></td>";
	newSelect += "			</tr>";
	newSelect += "		</table>";
	newSelect += "		</td>";
	newSelect += "	</tr>";
	newSelect += "</table>";
	document.write(newSelect);
	
	var haveSelectedValue = false;
	for (var i=0 ; i < obj.options.length ; i++) {
		if (obj.options[i].selected == true) {
			haveSelectedValue = true;
			settingValue(objId,obj.options[i].text);
		}
	}
	if (!haveSelectedValue) settingValue(objId,obj.options[0].text);
}
/***********************************************************************************
**** Select Box Design Script ******************************************************
**** End ***************************************************************************
************************************************************************************/
