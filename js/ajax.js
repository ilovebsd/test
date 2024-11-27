var debugEngine = false;
function Engine(){
	this.xmlhttp = false;
	this.type = null;
	this.src = null;
	this.param = null;
	this.exec = null;
	this.ifrcnt = 0;
	this.iswait = false;
	//this.iswait = true;
	this.sync = true;
	//12.11 sync 변수추가

	this.execute = function(type, src, param, exec, sync){
		//alert('type : '+type+' src : '+ src+' param : '+param + ' exec : '+ exec + ' sync : ' + sync);
		this.type = type;
		this.src = src;
		this.param = param;
		this.exec = exec;
		this.sync = sync;
		//this.iswait = true;
		this.getXmlHttpRequest();
		this.iswait = true;
		try	{
			return this._execute();
		}catch (e){
			this.errorHandle('실행하는데 실패하였습니다.');
		}
	}

	this.getXmlHttpRequest = function(){
		//this.iswait = true;
		if(this.iswait == true){
			setTimeout("engine.getXmlHttpRequest();",200);
			return;
		}else{
			if(window.ActiveXObject) {
				// Win e4,e5,e6
				try{
					this.xmlhttp=new ActiveXObject("Msxml2.XMLHTTP");
				}
				catch (e){
					try	{
						this.xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
					}
					catch (e2){
						this.xmlhttp=null;
					}
				}
			}else if(window.XMLHttpRequest) {
				// Win Mac Linix m1,f1,o9 Mac s1 Linux K3
				this.xmlhttp=new XMLHttpRequest();
			}else{
				this.xmlhttp=null;
			}
		}
	}

	this._ActiveXObject = function (axarray){
		var returnValue;
		for (var i = 0; i < axarray.length; i++){
			try{
				returnValue = new ActiveXObject(axarray[i]);
				break;
			}catch (ex){

			}
		}

		return returnValue;
	}

	// Browser Check
	var a,ua=navigator.userAgent;
	this.browser={
		safari : ((a=ua.split('AppleWebKit/')[1])?a.split('(')[0]:0)>=124,
		moz : ((a=ua.split('Gecko/')[1])?a.split(" ")[0]:0) >= 20011128,
		opera : (!!window.opera) && ((typeof XMLHttpRequest)=='function')
	} // end browser
	this._execute = function(){
		if(this.type == 'GET') this.xmlhttp.open("GET",this.src, this.sync);
		else if(this.type == 'POST') this.xmlhttp.open("POST",this.src, this.sync);
		this.xmlhttp.setRequestHeader ("Content-type", this.type == 'POST' ? "application/x-www-form-urlencoded" : "text/html");
		this.xmlhttp.setRequestHeader ("Cache-Control", "no-cache");
		this.xmlhttp.setRequestHeader ("Pragma", "no-cache");
		this.xmlhttp.setRequestHeader ("Referer", this.src);

		if(this.browser.opera || this.browser.safari || this.browser.moz) {
			this.xmlhttp.onload=function() {
				var result = engine.xmlhttp.responseText;
				result = result.replace(/\\\\/g,"\\")
				result = result.replace(/\\\n/g,"\n")
				engine.debugPrint(result);

				if(engine.exec){
					eval(engine.exec +'(result);');
				}
				
				engine.iswait = false;
			}
		}else{
		this.xmlhttp.onreadystatechange = function(){
			if(engine.xmlhttp.readyState == 4 && engine.xmlhttp.status == 200){

				var result = engine.xmlhttp.responseText;
				result = result.replace(/\\\\/g,"\\")
				result = result.replace(/\\\n/g,"\n")
				engine.debugPrint(result);

				if(engine.exec){
					eval(engine.exec +'(result);');
				}
				
				engine.iswait = false;
			}
		}

}
		if(this.type == 'GET') this.xmlhttp.send(null);
		else if(this.type == 'POST') this.xmlhttp.send(this.param);
	}

	this.errorHandle = function(code){
		alert(code);
	}

	this.debugPrint = function(value){
		if(debugEngine == 'div'){

		}else if(debugEngine == 'alert')	{
			alert(value);
		}else return;
	}

	this.Docode =  function(str){
		var varname = 'var_'+Math.ceil(Math.random()*10);
		str=str?str:this;
		eval(varname+'='+str);
		return window[varname];
	}
}
engine = new Engine();
engine2 = new Engine();
engine3 = new Engine();


function MakeDiv(id, pos, bgCor, zidx, ptop, pleft, swd, shei){
	var oDiv = document.createElement("div");
	(id != "") ? oDiv.id = id : '';
	(pos != "") ? oDiv.style.position = pos : '';
	(bgCor != "") ? oDiv.style.backgroundColor = bgCor : '';
	(zidx != "") ? oDiv.style.zindex = zidx : '';
	(ptop != "") ? oDiv.style.top = ptop : '';
	(pleft != "") ? oDiv.style.left = pleft : '';
	(swd != "") ? oDiv.style.width=swd : '';
	(shei != "") ? oDiv.style.height=shei : '';
	document.body.appendChild(oDiv);
}


function GetHttp(){
	var xmlHttp = null;
	if(window.ActiveXObject){
		xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
	}else if(window.XMLHttpRequest){
		xmlHttp = new XMLHttpRequest();
	}

	return xmlHttp;
}

function GetParam(formObj)
{
	fm = formObj;
	var para = "";
	for( var i=0 ; i < fm.elements.length; i++){
			if(i>0){ para += "&"; }
			if ( fm.elements[i].type == "checkbox" || fm.elements[i].type == "radio" ){
					if ( fm.elements[i].checked == true ){
							para +=  fm.elements[i].name  + "="
									+  encodeURIComponent(fm.elements[i].value) ;
					}
			}else{
					para +=  fm.elements[i].name  + "="
							+  encodeURIComponent(fm.elements[i].value) ;
			}
	}
	
	return para;
}

function pause(numberMillis){
	var now = new Date();
	var exitTime = now.getTime() + numberMillis;
	while(true){
		now = new Date();
		if(now.getTime() > exitTime)
			return;
	}
}

function viewLoadImg(id, adCode){

	document.getElementById(id).innerHTML = "로딩중입니다";
}

function addDiv(id, zIndex, bgc, adCode){
	setShadowDivVisible(true); //배경 layer

	if(document.getElementById(id)){
		eraserDiv(id);
	}

	var cDiv = document.createElement("div");
	cDiv.id = id;
	cDiv.style.position = "absolute";
	cDiv.style.zIndex = zIndex;
	cDiv.style.backgroundColor = bgc;
	document.body.appendChild(cDiv);
	viewLoadImg(id, adCode);
	moveToCenter(id);
}

function eraserDiv(id){
	var Dobj = document.getElementById(id);
	if(Dobj && Dobj.parentNode){
		Dobj.parentNode.removeChild(Dobj);
	}

	setShadowDivVisible(false); //배경 layer
}

function moveToCenter(id){
	var scrollTop = Math.max(document.documentElement.scrollTop, document.body.scrollTop);
	var gDiv = document.getElementById(id);
	cw=screen.availWidth; // 화면 너비
	ch=screen.availHeight; // 화면 높이
	sw=parseInt(gDiv.offsetWidth);// 띄울 창의 너비
	sh=parseInt(gDiv.offsetHeight);// 띄울 창의 높이
	ml=(cw - sw)/2;// 가운데 띄우기위한 창의 x위치
	mt=(ch - sh)/2;// 가운데 띄우기위한 창의 y위치

	gDiv.style.top = mt + scrollTop;
	gDiv.style.left = ml;
}

function toggleSel(obj, name){
	var status = obj.checked;
	var tObj = document.getElementsByName(name);
	var cnt = tObj.length;
	for(var i=0; i<cnt; i++){
		tObj[i].checked = status;
	}
}

