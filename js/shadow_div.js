// Modal Dialog Box
// copyright 8th July 2006 by Stephen Chapman
// permission to use this Javascript on your web page is granted
// provided that all of the code in this script (including these
// comments) is used without any alteration

function pageWidth() {
    return window.innerWidth != null? window.innerWidth: document.documentElement && document.documentElement.clientWidth ? document.documentElement.clientWidth:document.body != null? document.body.clientWidth:null;
}
function pageHeight() {
    return window.innerHeight != null? window.innerHeight: document.documentElement && document.documentElement.clientHeight ? document.documentElement.clientHeight:document.body != null? document.body.clientHeight:null;
}
function posLeft() {
    return typeof window.pageXOffset != 'undefined' ? window.pageXOffset:document.documentElement && document.documentElement.scrollLeft? document.documentElement.scrollLeft:document.body.scrollLeft? document.body.scrollLeft:0;
}
function posTop() {
    return typeof window.pageYOffset != 'undefined' ? window.pageYOffset:document.documentElement && document.documentElement.scrollTop? document.documentElement.scrollTop: document.body.scrollTop?document.body.scrollTop:0;
}
function $(x){
    return document.getElementById(x);
}
function scrollFix(){
		var obol=$('ol');
		obol.style.top=posTop()+'px';
		obol.style.left=posLeft()+'px';
}
function sizeFix(){
    var obol=$('ol');
    obol.style.height=pageHeight()+'px';
    obol.style.width=pageWidth()+'px';
}
function inf(h){
    tag=document.getElementsByTagName('select');
    for(i=tag.length-1;i>=0;i--)tag[i].style.visibility=h;
//    tag=document.getElementsByTagName('iframe');
//    for(i=tag.length-1;i>=0;i--)tag[i].style.visibility=h;
//    tag=document.getElementsByTagName('object');
//    for(i=tag.length-1;i>=0;i--)tag[i].style.visibility=h;

	try{
		var obj = document.getElementsByTagName("div");
		var divLen = obj.length;
		var tmpZindex = $('ol').style.zIndex;
		
		for(var j=0; j<divLen; j++){
				if(obj[j].style.zIndex > tmpZindex){
			
					var tObj = obj[j].lastChild;
					var tSel = tObj.getElementsByTagName('select');
					var tSelLen = tSel.length;

					for(i=tSelLen-1;i>=0;i--){
						if(va)
							h = 'hidden';
						else
							h = 'visible';
						tSel[i].style.visibility=h;
					}
					
				}
		}
	}catch(e){
	}

}


function setShadowDivVisible(va){
    if(va == true) {
        sm();
    } else {
        hm();
    }
}

function sm(){
	initmb();

    var h='hidden';
    var b='block';
    var p='px';
    var obol=$('ol'); 
    obol.style.height=pageHeight()+p;
    obol.style.width=pageWidth()+p;
    obol.style.top=posTop()+p;
    obol.style.left=posLeft()+p;
    obol.style.display=b;
	if(window.browser.msie && window.browser.version < 7.0){
//		inf(h);
	}

    return false;
}
function hm(){
    var v='visible';
    var n='none';
		try{
		    $('ol').style.display=n;
				$('ol').parentNode.removeChild($('ol'));
    }
		catch(e){}
		if(window.browser.msie && window.browser.version < 7.0){
//			inf(v);
		}
		
		window.onscroll = null;
    window.onresize = null;

    document.onkeypress=''
		return;
}
function initmb(){
    var ab='absolute';
    var n='none';
    var obody=document.getElementsByTagName('body')[0];
    var frag=document.createDocumentFragment();
    var obol=document.createElement('div');
    obol.setAttribute('id','ol');
    obol.style.filter = 'alpha(opacity=40)';
    obol.style.display=n;
    obol.style.position=ab;
    obol.style.top=0;
    obol.style.left=0;
    obol.style.zIndex=998;
    obol.style.width='100%';
   // obol.style.background='url(/overlay.png)';
    obol.style.backgroundColor='#333333';
    frag.appendChild(obol);
    obody.insertBefore(frag,obody.firstChild);
    window.onscroll = scrollFix; 
    window.onresize = sizeFix;
	
}
//window.onload = initmb;

// ������ ���� üũ
var userAgent = navigator.userAgent.toLowerCase();

window.browser = {
	version: (userAgent.match( /.+(?:rv|it|ra|ie)[\/: ]([\d.]+)/ ) || [])[1],
	safari: /webkit/.test( userAgent ),
	opera: /opera/.test( userAgent ),
	msie: /msie/.test( userAgent ) && !/opera/.test( userAgent ),
	mozilla: /mozilla/.test( userAgent ) && !/(compatible|webkit)/.test( userAgent )
};

