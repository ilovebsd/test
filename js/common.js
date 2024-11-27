	function ShowEmbedObject(ELEMENT_ID) {
		document.write(ELEMENT_ID.innerHTML);
		ELEMENT_ID.id = ""; 
	}

	function removeDash(sData) {
		sCha='(./-,)';
		sRet = "";
		 for (i=0;i<sData.length;i++) {
				ch = sData.charAt(i);
				if (sCha.indexOf(ch) < 0) {
					sRet = sRet + ch;
				}
			}
		return sRet;
	}

	function checkNumeric(sData) {
		sNum='0123456789';
		for (i=0;i<sData.length;i++) {
				ch = sData.charAt(i);
				if (sNum.indexOf(ch) < 0) {
					return false;
				}
		}
		return true;
	}

	function trim(st) {
		while(st && st.indexOf(" ")==0) st = st.substring(1)
		while(st && st.lastIndexOf(" ")==st.length-1) st = st.substring(0, st.length-1)
		return st
	}

	function checkValidDate(sDate) {
		var	iYear =	0;
		var	iMonth = 0;
		var	iDay = 0;
		var	iLastday = 0;
		
		var days=[0,31,28,31,30,31,30,31,31,30,31,30,31];

		sDate =removeDash(trim(sDate));

		if (sDate.length != 8) {
			return false;
		}
		if (!checkNumeric(sDate)) {
			return false;
		}
		iYear  = sDate.substring(0,4);
		iMonth = sDate.substring(4,6);
		iDay   = sDate.substring(6,8);
		if (iMonth.substring(0,1) == 0 )
			iMonth = iMonth.substring(1,2)
		if (iDay.substring(0,1) == 0 )
			iDay = iDay.substring(1,2)

		if ( iYear < 1900) {
			return false;
		}

		if ( iMonth	< 1	|| iMonth >	12){ 
			return false;
		}

		if (iMonth == 2)  {
			if((iYear%4	== 0) && (iYear%100!=0)	|| (iYear%400 ==0))
				iLastday = 29;
			else
				iLastday = 28;
		} else {
			iLastday = days[iMonth];
		}

		if ( iDay <	1 || iDay >	iLastday) {
			return false;
		}
		return true;
	}

	function goPage(curPage) { 
		var form = document.frm;
		form.PAGE_NUM.value = curPage;
		form.target='_self';
		form.submit();
	}

function ov(_o,_tf) {
  if(_tf)_o.className="header2";
  else _o.className="header1";
}
function stripHTML(_str)
{
  if(!_str)return;

  var _str2;
  var _reg=/<.*?>/gi;
  while(_str.match(_reg)!=null)
  {
    _str=_str.replace(_reg,"");
  }
  return _str;
}
function bubbleSort(_a,c,_ud,_isNumber)
{
  for(var i=0;i<_a.length;i++)
  {
    for(var j=i;j<_a.length;j++)
    {
      var _left=stripHTML(_a[i][c]);
      var _right=stripHTML(_a[j][c]);
      var _sign=_ud?">":"<";
      var _yes=false;
      if(_isNumber)
      {
         if(_ud && (parseInt(_left)-parseInt(_right)>0))_yes=true;
         if(!_ud && (parseInt(_left)-parseInt(_right)<0))_yes=true;
      }
      else
      {
        if(_ud && _left.toLowerCase() > _right.toLowerCase())_yes=true;
        if(!_ud && _left.toLowerCase() < _right.toLowerCase())_yes=true;
      }
      if(_yes)
      {
        /* swap rows */
        for(var x=0;x<_a[i].length;x++)
        {
          var _t=_a[i][x];
          _a[i][x]=_a[j][x];
          _a[j][x]=_t;
        }
      }
    }
  }
  return _a;
}
var lastSort=null;
function sortNow(_c,_isNumber)
{
  var _a=new Array();
  var _o=null;
  var _i=0;
  while(_o=document.getElementById("g"+_i))
  {
    _a[_i]=new Array();
    var _j=0;
    while(_p=document.getElementById("h"+_i+"_"+_j))
    {
      _a[_i][_j]=_p.innerHTML;
      _j++;
    }
    _i++;
  }
  _a=bubbleSort(_a,_c,lastSort!=_c,_isNumber);
  for(var b=0;b<_a.length;b++)
  {
    for(var c=0;c<_a[b].length;c++)
    {
      document.getElementById("h"+b+"_"+c).innerHTML=_a[b][c];
    }
  }
  if(lastSort!=_c)
    lastSort=_c;
  else
    lastSort=null;
}


function fncOverOut(obj,img)
{
    //obj.src = path+imgs;
    obj.src = img;
}


/****************************** ��ư�̹��� ���� ******************************/
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
/****************************** ��ư�̹��� ���� ******************************/








