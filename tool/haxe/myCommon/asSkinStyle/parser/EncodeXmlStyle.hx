package asSkinStyle.parser;

import asSkinStyle.data.StyleModel;
import asSkinStyle.data.StyleTag;
import asSkinStyle.data.StyleVars;
import flash.errors.Error;

/**
 * 将xml数据解析成样式数据
 * @author Pelephone
 */
class EncodeXmlStyle
{
	public function new(styleModel:StyleModel = null)
	{
		model = styleModel;
		if(model == null)
		model = new StyleModel();
		keyAttrs = [StyleTag.CLASS, StyleTag.ID, StyleTag.PATH, StyleTag.REFERENCE];
	}
	
	/**
	 * 将数据解析建立结构
	 * @param dat
	 */
	public function encodeBuilder(dat:Xml):Void
	{
		makeSkinCom(dat,null,1);
	}
	
	/**
	 * 将数据解析成样式结构
	 * @param dat
	 */
	public function encodeStyle(dat:Xml):Void
	{
		makeSkinCom(dat,null,0);
	}
	
	/**
	 * 样式数据
	 */
	private var model:StyleModel;
	
	/**
	 * 关键词的属性名
	 */
	private var keyAttrs:Array<String>;
	
	/**
	 * 通过xml递归子项生成皮肤
	 * @param skinXML
	 * @param rootXml
	 * @param idName
	 * @param mapType 0是set样式标记，1是builder样式标记
	 * @return 
	 */
	private function makeSkinCom(skinXML:Xml,parentVars:StyleVars=null,mapType:Int=0):StyleVars
	{
		if (skinXML == null)
		return null;
		var cssPath:String = null;
		var vid:String = null;
		
		if(skinXML.exists(StyleTag.ID))
		vid = skinXML.get(StyleTag.ID);
		
		if(skinXML.exists(StyleTag.PATH))
		cssPath = skinXML.get(StyleTag.PATH);
		
		var parentPath:String = null;
		var vpath:String;
		
		if(parentVars == null)
			vpath = StyleTag.ROOT;
		else if(cssPath != null && cssPath.length > 0)
		{
			parentPath = cssPath;
			parentVars = getVarsByType(parentPath,mapType);
			vpath = StyleTag.ROOT + StyleTag.JOIN_STR + cssPath + StyleTag.JOIN_STR + vid;
		}
		else
		{
			parentPath = parentVars.path;
			if(parentPath != null)
				vpath = parentPath + StyleTag.JOIN_STR + vid;
			else
				vpath = vid;
		}
		
		//skinXML.nodeName
		var nodeTag:String = skinXML.nodeName;
		
		if(mapType == 1 && nodeTag != StyleTag.TAG_NEW && nodeTag != StyleTag.BEAN && parentVars!=null)
		return null;
		
		var s1:String = StringTools.replace(vpath,"root.","");
		var v:StyleVars = getVarsByType(s1,mapType);
		if(v == null)
		{
			v = new StyleVars();
			v.id = vid;
			v.path = vpath;
//				else if(v.path != StyleTag.ROOT && !model.getRootVars().getVars(vid))
//					model.getRootVars().childs.push(v);
			
			if(parentVars != null)
				parentVars.childs.push(v);
			
			setVarsByType(v,mapType);
		}
		
		v.tag = nodeTag;
		v.clzTag = skinXML.get(StyleTag.CLASS);
		var constr:String = skinXML.get(StyleTag.CONSTRUCT);
		if(constr!=null && constr.length > 0)
		{
			v.constructLs = constr.split(",");
		}
		v.reference = skinXML.get(StyleTag.REFERENCE);
		xmlCreateObject(skinXML,v,keyAttrs,mapType);
		
/*		if(v.reference && v.reference.length>0)
		{
			var refObj:StyleVars = getVarsByType(v.reference,mapType);
			if(refObj)
			{
				copyVars(v,refObj,mapType);
			}
		}*/
		
		if(parentPath!=null && parentPath.length>1000)
			throw new Error("引用递归有死循环!");
		
		for (childXML in skinXML.elements()) 
		{
			var childCom:StyleVars = makeSkinCom(childXML,v,mapType);
		}
		return v;
	}
	
	/**
	 * 复杂项信息
	 * @param v
	 * @param tar
	 * @param mapType
	 */
	private function copyVars(v:StyleVars,tar:StyleVars,mapType:Int=0):Void
	{
		for (attr in tar.varsMap.keys() ) 
		{
			v.setVars(attr,tar.getValue(attr));
		}
		v.clzTag = tar.clzTag;
		for (itm in tar.childs) 
		{
			var itmPath:String = v.path + StyleTag.JOIN_STR + itm.id;
			var reItm:StyleVars = getVarsByType(itmPath,mapType);
			if(reItm != null)
			{
				reItm = new StyleVars();
				reItm.id = itm.id;
				reItm.path = itmPath;
				reItm.clzTag = itm.clzTag;
				reItm.tag = itm.tag;
				setVarsByType(reItm,mapType);
				
				v.childs.push(reItm);
//					if(!v.getVars(reItm.id))
//						v.childs.push(reItm);
			}
			copyVars(reItm,itm);
		}
	}
	
	/**
	 * 获取样式数据
	 * @param mapType 0是set样式标记，1是builder样式标记
	 */
	private function getVarsByType(idPath:String,mapType:Int=0):StyleVars
	{
		if(mapType == 0)
		return model.getStyleVars(idPath);
		else
		return model.getBuildVars(idPath);
	}
	
	/**
	 * 设置样式数据
	 * @param idPath
	 * @param mapType
	 */
	private function setVarsByType(vars:StyleVars,mapType:Int=0):Void
	{
		if(mapType == 0)
		model.setStyleVars(vars);
		else
		model.setBuildVars(vars);
	}
	
	/**
	 * 通过xml或xmlList节点对象生成动态对象
	 * @param xml
	 * @param filterAttrs
	 * @return 不生成的属性名
	 */
	private function xmlCreateObject(xml:Xml,toVars:StyleVars,filterAttrs:Array<String>=null,mapType:Int=0):StyleVars
	{
		//if (xml != null)
		//xml = xml.firstElement();		// 调整到子结点
		if (xml == null)
		return null;
		for (attrName in xml.attributes()) 
		{
			var child:String = xml.get(attrName);
			if(attrName == StyleTag.REFERENCE)
			{
				var ref:String = child;
				if (ref == null || ref.length <= 0)
				continue;
				
				var refObj:StyleVars = getVarsByType(ref,mapType);
				if (refObj == null)
				continue;
				
				copyVars(toVars,refObj,mapType);
				continue;
			}
			if (filterAttrs!=null && indexOf(filterAttrs, attrName) >= 0)
			continue;
			
			toVars.setVars(attrName, child);
		}
		return toVars;
	}
	
	/** 
	 * 是否是数值字符串;
	 */
	private function getVal(o:Dynamic,val:String):Dynamic
	{
		switch( Type.typeof(o) )
		{
			case TNull:
				return null;
			case TInt:
				return Std.parseInt(val);
			case TFloat:
				return Std.parseFloat(val);
			case TBool:
				return (val == "1")?true:false;
			default:
				return val;
		}
		return val;
	}
	
	/**
	 * 通过路径获取xml对象
	 * @param path
	 
	private function getXmlByPath(pathArr:Array,nodel:Object,pIndex:Int=0):Object
	{
		var nStr:String = pathArr[pIndex];
		var cxml:Object = nodel.children().(@name == nStr);
		if(!cxml || !String(cxml))
			return null;
		if(pIndex == (pathArr.length - 1))
			return cxml;
		else
			return getXmlByPath(pathArr,cxml,(pIndex + 1));
	}*/
	
	
	static function indexOf(list:Array<Dynamic>, value:Dynamic):Int
	{
		if (list == null || list.length <= 0)
		return -1;
		
		for (i in 0...list.length)
		{
			if (list[i] && list[i] == value)
			return i;
		}
		return -1;
	}
}