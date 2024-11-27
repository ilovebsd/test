<!--이미지 로드-->

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
<!--끝_이미지로드-->



<!--메뉴 쿠키값 저장-->
var persistmenu="yes" 
var persisttype="sitewide" 

if (document.getElementById){ 
document.write('<style type="text/css">\n')
document.write('.submenu{display: none;}\n')
document.write('</style>\n')
}

function SwitchMenu(obj){
    if(document.getElementById){
    var el = document.getElementById(obj);
    var ar = document.getElementById("masterdiv").getElementsByTagName("span"); 
        if(el.style.display != "block"){ 
            for (var i=0; i<ar.length; i++){
                if (ar[i].className=="submenu") 
                ar[i].style.display = "none";
            }
            el.style.display = "block";
        }else{
            el.style.display = "none";
        }
    }
}

function get_cookie(Name) { 
    var search = Name + "="
    var returnvalue = "";
    if (document.cookie.length > 0) {
        offset = document.cookie.indexOf(search)
    if (offset != -1) { 
        offset += search.length
        end = document.cookie.indexOf(";", offset);
    if (end == -1) end = document.cookie.length;
        returnvalue=unescape(document.cookie.substring(offset, end))
    }
}
return returnvalue;
}

function onloadfunction(){
    if (persistmenu=="yes"){
    var cookiename=(persisttype=="sitewide")? "switchmenu" : window.location.pathname
    var cookievalue=get_cookie(cookiename)
    if (cookievalue!="")
        document.getElementById(cookievalue).style.display="block"
    }
}

function savemenustate(){
    var inc=1, blockid=""
    while (document.getElementById("sub"+inc)){
    if (document.getElementById("sub"+inc).style.display=="block"){
        blockid="sub"+inc
    break
    }
    inc++
}
    var cookiename=(persisttype=="sitewide")? "switchmenu" : window.location.pathname
    var cookievalue=(persisttype=="sitewide")? blockid+";path=/" : blockid
    document.cookie=cookiename+"="+cookievalue
}

if (window.addEventListener)
    window.addEventListener("load", onloadfunction, false)
else if (window.attachEvent)
    window.attachEvent("onload", onloadfunction)
else if (document.getElementById)
    window.onload=onloadfunction

if (persistmenu=="yes" && document.getElementById)
window.onunload=savemenustate