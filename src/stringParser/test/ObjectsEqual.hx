package stringParser.test;

class ObjectsEqual 
{

	public static function equal(value1:Dynamic, value2:Dynamic):Bool
	{
		var type = Type.typeof(value1);
		var type2 = Type.typeof(value2);
		if (!enumEqual(type, type2)) {
			return false;
		}
		
		switch(type) {
			
			case TNull:
				return true;
			case TInt:
				return value1 == value2;
			case TFloat:
				return value1 == value2;
			case TBool:
				return value1 == value2;
			case TFunction:
				return value1 == value2;
			case TEnum( _ ):
				return enumEqual(cast value1, cast value2);
			case TObject:
				return objEqual(value1, value2);
			case TClass( c ):
				if (c == String) {
					return value1 == value2;
				}else{
					return objEqual(value1, value2);
				}
			case TUnknown:
				return false;
		}
	}
	// Type.enumEq doesn't match identical arrays
	public static function enumEqual(enum1:EnumValue, enum2:EnumValue):Bool
	{
		if (Type.enumIndex(enum1) != Type.enumIndex(enum2)) {
			return false;
		}
		var params1 = Type.enumParameters(enum1);
		var params2 = Type.enumParameters(enum2);
		if (params1.length != params2.length) {
			return false;
		}
		for (i in 0...params1.length) {
			if (!equal(params1[i], params2[i])) {
				return false;
			}
		}
		return true;
	}
	public static function objEqual(value1:Dynamic, value2:Dynamic):Bool
	{
		var isArray:Bool = Std.is(value1, Array);
		if (isArray != Std.is(value2, Array)) return false;
		
		if (isArray) {
			var array1:Array<Dynamic> = cast value1;
			var array2:Array<Dynamic> = cast value2;
			
			var length1:Int = array1.length;
			if (length1 != array2.length) return false;
			
			var i:Int = 0;
			while (i < length1) {
				if (!equal(array1[i], array2[i])) {
					return false;
				}
				++i;
			}
		}else{
			var fields1 = Reflect.fields(value1);
			var checked:Map<String, Bool> = new Map();
			
			for (field in fields1) {
				checked.set(field, true);
				
				try{
					if (!equal(Reflect.getProperty(value1, field), Reflect.getProperty(value2, field))) {
						return false;
					}
				}catch (e:Dynamic) {
					return false;
				}
			}
			var fields2 = Reflect.fields(value2);
			for (field in fields1) {
				if (!checked.get(field)) {
					return false;
				}
			}
		}
		return true;
	}
	
}