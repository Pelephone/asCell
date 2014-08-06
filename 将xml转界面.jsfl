var doc = fl.getDocumentDOM();
// 主键不解析的属性名
var ignoreAttrs = ["attrLs","pathStr","clzTag"];
// 库项前缀
var libPrefixLs = ["gui_","reg_"];
// 设值时要转成整型的属性
var numAttr = ["rotation","width","height","scaleX","scaleY","x","y"];
// 属性转换映射
var attrChangeMap = {};
// textFormat属性转换
var formatToMap = {
	align:"alignment"
	,face:"font"
	,color:"fillColor"
	,size:"size"
	,bold:"bold"
	,italic:"italic"
	,letterSpacing:"letterSpacing"
	,target:"target"
	,url:"url"
};

var xMap = {};

run();

		
function run()
{
	var fstr = getImportFile();
	if(!fstr)
		return;
	xMap = {};
	var arr = parseFileStr(fstr);
	parseToStage(arr);
}

// 设置对象宽高等属性
function parseItemMatrix(elm,vars,ignAttr)
{
	var tObj = {width:"scaleX",height:"scaleY"};
	if(vars.hasOwnProperty("name"))
		elm.name = String(vars["name"]);
	for each(var attr in numAttr)
	{
		if(ignAttr && ignAttr.indexOf(attr)>=0)
			continue;
		if(!vars.hasOwnProperty(attr))
		{
			if(attr=="x" || attr=="y")
				elm[attr] = 0;
			continue;
		}
		
		if(elm.elementType!="text" && (attr == "width" || attr == "height"))
		{
			var eAttr = tObj[attr];
			elm[eAttr] = (parseFloat(vars[attr]))/elm[attr];
			continue;
		}
		
		elm[attr] = parseFloat(vars[attr]);
	}
}

// 将解析好的数据处理到舞台
function parseToStage(arr)
{
	for(var key in arr)
	{
		var obj = arr[key];
		var attrLs = obj["attrLs"];
		
		var clzLink = obj["clzTag"];
		
		if(clzLink == "flash.text.TextField")
		{
			var th = obj.hasOwnProperty("height")?parseInt(obj["height"]):22;
			var tw = obj.hasOwnProperty("width")?parseInt(obj["width"]):100;
			doc.addNewText({left:0, top:0, right:tw, bottom:th} , "" );
			document.selectAll()
			var selectItm = doc.selection[0];
			parseObjToText(selectItm,obj);
			continue;
		}
		
		var theItem = getLibItem(clzLink);
		if(!theItem)
			continue;
		
		var tx = parseInt(obj["x"])?parseInt(obj["x"]):0;
		var ty = parseInt(obj["y"])?parseInt(obj["y"]):0;
		tx = tx + theItem.width/2;
		ty = ty + theItem.height/2;
		// matrix
		doc.addItem({x:tx,y:ty}, theItem);
		selectItm = doc.selection[0];
		parseItemMatrix(selectItm,obj,null);
		continue;
		
	}
}

// 将对象数据解析到场景对象
function parseObjToElement(elm,obj)
{
	for(var attrName in obj)
	{
		if(ignoreAttrs.indexOf(attrName)>=0)
			continue;
		try{
			var elmAttr;
			if(attrChangeMap.hasOwnProperty(attrName))
				elmAttr = String(attrChangeMap[attrName]);
			else
				elmAttr = String(attrName);
			
			if(numAttr.indexOf(attrName)>=0)
				elm[elmAttr] = parseFloat(obj[attrName]);
			else
				elm[elmAttr] = String(obj[attrName]);
		}
		catch(error) 
		{
			fl.trace(attrName);
			continue;
		}
	}
}

// 将对象数据解析到场景文本
function parseObjToText(elm,obj)
{
	if(elm.elementType != "text")
		return;
	var ignArr = ["width","height","defaultTextFormat"]
	parseItemMatrix(elm,obj,ignArr);
	
	if(obj.hasOwnProperty("text"))
		elm.setTextString(String(obj["text"]));
	
	var other;
	if(obj.hasOwnProperty("defaultTextFormat"))
	{
		if(String(obj.defaultTextFormat).indexOf("#")>=0)
			var cAttr = String(obj.defaultTextFormat).replace("#","");
		else
			cAttr = String(obj.defaultTextFormat);
		other = xMap[cAttr];
	}
	if(!other)
		return;
	
	for(var attrName in other)
	{
		if(ignoreAttrs.indexOf(attrName)>=0 || ignArr.indexOf(attrName)>=0 || attrName=="name")
			continue;
		
		if(formatToMap.hasOwnProperty(attrName))
			var dAttr = String(formatToMap[attrName]);
		else
			dAttr = attrName;
		doc.setElementTextAttr(dAttr, parseFloat(other[attrName]));
	}
}

// 通过导出名获取库中项
function getLibItem(linkage)
{
	var itemArray = fl.getDocumentDOM().library.items;
	for each(var item in itemArray)
	{
		var lcn = item.linkageClassName;
		if(!lcn || !lcn.length)
			continue;
		if(lcn == linkage)
			return item;
		// 其它前缀
		for each(var str in libPrefixLs)
		{
			if((str + linkage) == lcn)
				return item;
		}
	}
	return null;
}

// 解析xml文件
function parseFileStr(fstr)
{
	var resArr = [];
	var arr1 = fstr.split("/>");
	for each(var itm in arr1)
	{
		itm = itm.replace("<","");
		var arr2 = itm.split(/\s+/);
		var itmObj = {};
		var itmLs = [];
		for each(var itmStr in arr2)
		{
			if(!itmStr || !itmStr.length || itmStr.indexOf("=")<0)
				continue;
			var arr3 = itmStr.split("=");
			if(!arr3 || arr3.length<2)
				continue;
			var attrName = arr3[0];
			var val = arr3[1];
			if(val.indexOf("\"")>=0)
			{
				val = val.replace(/\"/g, "");
			}
			itmObj[attrName] = val;
			itmLs.push(attrName);
			itmLs.push(val);
		}
		if(itmLs.length)
		{
			itmObj["attrLs"] = itmLs;
			resArr.push(itmObj);
			var key = itmObj.hasOwnProperty("pathStr")?String(itmObj.pathStr):"";
			var pstr = (key && key.length)?".":"";
			key = key + pstr +itmObj.name;
			xMap[key] = itmObj;
		}
	}
	return resArr;
}

// 导出文件
function getImportFile()
{
	var fname = fl.browseForFileURL("open", "导入语言包");
//	if(!fname || !confirm("是否确定导入语言包到当前文件: \n" + fname)) return;
	
	var file_str = FLfile.read(fname);
	if(!file_str || !file_str.length)
	{
		altrace("文件读取错误! ");
		return null;
	}
	else
		return file_str;
}

// 警告并输出
function altrace(msg){
	fl.trace(msg);
	alert(msg);
}

// 解码 XML 编码
function decode_xml(str){
	str = str.split("&lt;").join("<");
	str = str.split("&gt;").join(">");
	str = str.split("&amp;;").join("&");
	str = str.split("&apos;").join("'");
	str = str.split("&quot;").join("\"");
	return str;
}