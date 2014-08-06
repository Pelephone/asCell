package asSkinStyle.parser
{
	import asSkinStyle.data.StyleModel;
	import asSkinStyle.data.StyleTag;
	import asSkinStyle.data.StyleVars;

	/**
	 * 将xml数据解析成样式数据
	 * @author Pelephone
	 */
	public class EncodeXmlStyle
	{
		public function EncodeXmlStyle(styleModel:StyleModel = null)
		{
			model = styleModel || new StyleModel();
		}
		
		/**
		 * 将数据解析建立结构
		 * @param dat
		 */
		public function encodeBuilder(dat:Object):void
		{
			makeSkinCom(dat,null,1);
		}
		
		/**
		 * 将数据解析成样式结构
		 * @param dat
		 */
		public function encodeStyle(dat:Object):void
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
		private var keyAttrs:Array = [StyleTag.CLASS,StyleTag.ID,StyleTag.PATH,StyleTag.REFERENCE];
		
		/**
		 * 通过xml递归子项生成皮肤
		 * @param skinXML
		 * @param rootXml
		 * @param idName
		 * @param mapType 0是set样式标记，1是builder样式标记
		 * @return 
		 */
		private function makeSkinCom(skinXML:Object,parentVars:StyleVars=null,mapType:int=0):StyleVars
		{
			if(!skinXML) return null;
			
			var vid:String = skinXML.attribute(StyleTag.ID);
			var cssPath:String = skinXML.attribute(StyleTag.PATH);
			var parentPath:String;
			
			if(parentVars == null)
				vpath = StyleTag.ROOT;
			else if(cssPath && cssPath.length)
			{
				parentPath = cssPath;
				parentVars = getVarsByType(parentPath,mapType);
				var vpath:String = StyleTag.ROOT + StyleTag.JOIN_STR + cssPath + StyleTag.JOIN_STR + vid;
			}
			else
			{
				parentPath = parentVars.path;
				if(parentPath)
					vpath = parentPath + StyleTag.JOIN_STR + vid;
				else
					vpath = vid;
			}
			
			var nodeTag:String = skinXML.localName();
			
			if(mapType == 1 && nodeTag != StyleTag.TAG_NEW && nodeTag != StyleTag.BEAN && parentVars!=null)
				return null;
			
			var v:StyleVars = getVarsByType(vpath.replace("root.",""),mapType);
			if(!v)
			{
				v = new StyleVars();
				v.id = vid;
				v.path = vpath;
//				else if(v.path != StyleTag.ROOT && !model.getRootVars().getVars(vid))
//					model.getRootVars().childs.push(v);
				
				if(parentVars)
					parentVars.childs.push(v);
				
				setVarsByType(v,mapType);
			}
			
			v.tag = nodeTag;
			v.clzTag = skinXML.attribute(StyleTag.CLASS);
			var constr:String = String(skinXML.attribute(StyleTag.CONSTRUCT));
			if(constr.length)
			{
				v.constructLs = constr.split(",");
			}
			v.reference = skinXML.attribute(StyleTag.REFERENCE);
			xmlCreateObject(skinXML,v,keyAttrs,mapType);
			
/*			if(v.reference && v.reference.length>0)
			{
				var refObj:StyleVars = getVarsByType(v.reference,mapType);
				if(refObj)
				{
					copyVars(v,refObj,mapType);
				}
			}*/
			
			if(parentPath && parentPath.length>1000)
				throw new Error("引用递归有死循环!");
			
			for each (var childXML:Object in skinXML.children()) 
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
		private function copyVars(v:StyleVars,tar:StyleVars,mapType:int=0):void
		{
			for each (var attr:String in tar.attrLs) 
			{
				v.setVars(attr,tar.getValue(attr));
			}
			v.clzTag = tar.clzTag;
			for each (var itm:StyleVars in tar.childs) 
			{
				var itmPath:String = v.path + StyleTag.JOIN_STR + itm.id;
				var reItm:StyleVars = getVarsByType(itmPath,mapType);
				if(!reItm)
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
		private function getVarsByType(idPath:String,mapType:int=0):StyleVars
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
		private function setVarsByType(vars:StyleVars,mapType:int=0):void
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
		private function xmlCreateObject(xml:Object,toVars:StyleVars,filterAttrs:Array=null,mapType:int=0):StyleVars
		{
			if(xml) xml = xml[0];		// 调整到子结点
			if(xml==null || !XML(xml).length()) return null;
			for each (var child:Object in xml.attributes()) 
			{
				var attrName:String = child.localName();
				if(attrName == StyleTag.REFERENCE)
				{
					var ref:String = String(child);
					if(!ref || ref.length<=0)
						continue;
					var refObj:StyleVars = getVarsByType(ref,mapType);
					if(!refObj)
						continue;
					copyVars(toVars,refObj,mapType);
					continue;
				}
				if(filterAttrs && filterAttrs.indexOf(attrName)>=0)
					continue;
				if(isNumber(child.toString()))
					toVars.setVars(attrName,Number(child));
				else
					toVars.setVars(child.localName(),String(child));
			}
			return toVars;
		}
		
		/** 
		 * 是否是数值字符串;
		 */
		private function isNumber(char:String):Boolean
		{
			if (char == null)
			{
				return false;
			}
			return !isNaN(Number(char))
		}
		
		/**
		 * 通过路径获取xml对象
		 * @param path
		 */
		private function getXmlByPath(pathArr:Array,nodel:Object,pIndex:int=0):Object
		{
			var nStr:String = pathArr[pIndex];
			var cxml:Object = nodel.children().(@name == nStr);
			if(!cxml || !String(cxml))
				return null;
			if(pIndex == (pathArr.length - 1))
				return cxml;
			else
				return getXmlByPath(pathArr,cxml,(pIndex + 1));
		}
	}
}