
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
	function goLeftSelectBoxMenu(thisURL,thisTarget) {
		if (thisURL == "" || thisURL == null || thisURL == "separator") return;
		var nowTarget = "_blank";
		if (thisTarget != null && thisTarget != "" ) nowTarget = thisTarget;
		window.open(thisURL, nowTarget, "");
	}
/***********************************************************************************
**** tab menu ******************************************************
**** Start *************************************************************************
************************************************************************************/	
function DisplayMenu(index) {
        for (i=1; i<=4; i++)
        if (index == i) {
        thisMenu = eval("menu" + index + ".style");
        thisMenu.display = "";
        } 
        else {
        otherMenu = eval("menu" + i + ".style"); 
        otherMenu.display = "none"; 
        }
        }
function DisplayMenu2(index) {
        for (i=1; i<=2; i++)
        if (index == i) {
        thisMenu = eval("menu" + index + ".style");
        thisMenu.display = "";
        } 
        else {
        otherMenu = eval("menu" + i + ".style"); 
        otherMenu.display = "none"; 
        }
        }
/***********************************************************************************
**** tab menu ******************************************************
**** end *************************************************************************
************************************************************************************/	

/***********************************************************************************
**** Left MENU ******************************************************
**** Start *************************************************************************
************************************************************************************/
var remember = true; //Remember menu states, and restore them on next visit.
    var contractall_default= false; //Should all submenus be contracted by default? (true or false)

    var menu, titles, submenus, arrows, bypixels;
    var heights = new Array();

    var n = navigator.userAgent;
    if(/Opera/.test(n)) bypixels = 2;
    else if(/Firefox/.test(n)) bypixels = 3;
    else if(/MSIE/.test(n)) bypixels = 2;

    /////DD added expandall() and contractall() functions/////

    function slash_expandall(){
    if (typeof menu!="undefined"){
        for(i=0; i<Math.max(titles.length, submenus.length); i++){
            titles[i].className="title";
            //arrows[i].src = "http://www.blueb.co.kr/SRC/javascript/image5/expanded.gif";

            submenus[i].style.display="";
            submenus[i].style.height = heights[i]+"px";
        }
    }
    }
<!---->
    function slash_contractall(){
    if (typeof menu!="undefined"){
        for(i=0; i<Math.max(titles.length, submenus.length); i++){
            titles[i].className="titlehidden";
            //arrows[i].src = "http://www.blueb.co.kr/SRC/javascript/image5/collapsed.gif";
            submenus[i].style.display="none";
            submenus[i].style.height = 0;
        }
    }
    }

    function hidemenu(sm) {
        var nr = submenus[sm].getElementsByTagName("a").length*bypixels;
        submenus[sm].style.height = (parseInt(submenus[sm].style.height)-nr)+"px";
        var to = setTimeout("hidemenu("+sm+")", 30);
        if(parseInt(submenus[sm].style.height) <= nr) {
            clearTimeout(to);
            submenus[sm].style.display = "none";
            submenus[sm].style.height = "0px";
            //arrows[sm].src = "http://www.blueb.co.kr/SRC/javascript/image5/collapsed.gif";
            titles[sm].className = "titlehidden";
        }
    }
	
   function restore() {
        if(getcookie("menu") != null) {
            var hidden = getcookie("menu").split(",");
            for(var i in hidden) {
                titles[hidden[i]].className = "titlehidden";
                submenus[hidden[i]].style.height = "0px";
                submenus[hidden[i]].style.display = "none";
                //arrows[hidden[i]].src = "http://www.blueb.co.kr/SRC/javascript/image5/collapsed.gif";
            }
        }
    }	

    /////End DD added functions///////////////////////////////


    function init(){
        menu = getElementsByClassName("sdmenu", "div", document)[0];
        titles = getElementsByClassName("title", "span", menu);
        submenus = getElementsByClassName("submenu", "div", menu);
        arrows = getElementsByClassName("arrow", "img", menu);
        for(i=0; i<Math.max(titles.length, submenus.length); i++) {
            titles[i].onclick = gomenu;
            heights[i] = submenus[i].offsetHeight;
            submenus[i].style.height = submenus[i].offsetHeight+"px";
        }
        if(remember)
                    restore()
            else if (contractall_default) //DD added code
                    slash_contractall() //DD added code
    
    	//slash_contractall();		// 전체축소
    }

 

    function gomenu(e) {
        if (!e)
            var e = window.event;
        var ce = (e.target) ? e.target : e.srcElement;
        var sm;
        for(var i in titles) {
            if(titles[i] == ce || arrows[i] == ce)
                sm = i;
        }
        if(parseInt(submenus[sm].style.height) > parseInt(heights[sm])-2) {
            hidemenu(sm);
        } else if(parseInt(submenus[sm].style.height) < 2) {
            titles[sm].className = "title";
            showmenu(sm);
        }
    }


    function showmenu(sm) {
        var nr = submenus[sm].getElementsByTagName("a").length*bypixels;
        submenus[sm].style.display = "";
        submenus[sm].style.height = (parseInt(submenus[sm].style.height)+nr)+"px";
        var to = setTimeout("showmenu("+sm+")", 30);
        if(parseInt(submenus[sm].style.height) > (parseInt(heights[sm])-nr)) {
            clearTimeout(to);
            submenus[sm].style.height = heights[sm]+"px";
            //arrows[sm].src = "http://www.blueb.co.kr/SRC/javascript/image5/expanded.gif";

        }
            
            
    }

    function store() {
        var hidden = new Array();
        for(var i in titles) {
            if(titles[i].className == "titlehidden")
                hidden.push(i);
        }
        putcookie("menu", hidden.join(","), 30);
    }

    function getElementsByClassName(strClassName, strTagName, oElm){
        var arrElements = (strTagName == "*" && document.all)? document.all : oElm.getElementsByTagName(strTagName);
        var arrReturnElements = new Array();
        strClassName = strClassName.replace(/\-/g, "\\-");
        var oRegExp = new RegExp("(^|\\s)" + strClassName + "(\\s|$)");
        var oElement;
        for(var i=0; i<arrElements.length; i++){
            oElement = arrElements[i];      
            if(oRegExp.test(oElement.className)){
                arrReturnElements.push(oElement);
            }   
        }
        return (arrReturnElements)
    }

    function putcookie(c_name,value,expiredays) {
        var exdate=new Date();
        exdate.setDate(exdate.getDate()+expiredays);
        document.cookie = c_name + "=" + escape(value) + ((expiredays==null) ? "" : ";expires="+exdate);
    }

    function getcookie(c_name) {
        if(document.cookie.length > 0) {
            var c_start = document.cookie.indexOf(c_name + "=");
            if(c_start != -1) {
                c_start = c_start + c_name.length + 1;
                var c_end = document.cookie.indexOf(";",c_start);
                if(c_end == -1)
                    c_end = document.cookie.length;
                return unescape(document.cookie.substring(c_start, c_end));
            }
        }
        return null;
    }
/*
    window.onload = init;
    if(remember) window.onunload = store;
<!--클릭이미지 인식▼-->
var path = 'imgs/';
function fncClick01(obj)
{
    if( obj.src.indexOf('menu_id_normal_btn')>0 )
        obj.src = path+'menu_id_select_btn.gif';
    else
        obj.src = path+'menu_id_normal_btn.gif';
}

function fncClick02(obj)
{
    if( obj.src.indexOf('menu_group_normal_btn')>0 )
        obj.src = path+'menu_group_select_btn.gif';
    else
        obj.src = path+'menu_group_normal_btn.gif';
}

function fncClick03(obj)
{
    if( obj.src.indexOf('menu_publiclist_normal_btn')>0 )
        obj.src = path+'menu_publiclist_select_btn.gif';
    else
        obj.src = path+'menu_publiclist_normal_btn.gif';
}

function fncClick04(obj)
{
    if( obj.src.indexOf('menu_calllist_normal_btn')>0 )
        obj.src = path+'menu_calllist_select_btn.gif';
    else
        obj.src = path+'menu_calllist_normal_btn.gif';
}

function fncClick05(obj)
{
    if( obj.src.indexOf('menu_voiceinform_normal_btn')>0 )
        obj.src = path+'menu_voiceinform_select_btn.gif';
    else
        obj.src = path+'menu_voiceinform_normal_btn.gif';
}

function fncClick06(obj)
{
    if( obj.src.indexOf('menu_premium_normal_btn')>0 )
        obj.src = path+'menu_premium_select_btn.gif';
    else
        obj.src = path+'menu_premium_normal_btn.gif';
}

function fncClick07(obj)
{
    if( obj.src.indexOf('menu_setup_normal_btn')>0 )
        obj.src = path+'menu_setup_select_btn.gif';
    else
        obj.src = path+'menu_setup_normal_btn.gif';
}

function fncClick08(obj)
{
    if( obj.src.indexOf('menu_system_normal_btn')>0 )
        obj.src = path+'menu_system_select_btn.gif';
    else
        obj.src = path+'menu_system_normal_btn.gif';
}
*/
function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}

}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

/***********************************************************************************
**** Left MENU ******************************************************
**** End *************************************************************************
************************************************************************************/