package buttplug;

import haxe.format.JsonParser;

class JSONMapParser extends JsonParser
{
	static public inline function parse(str:String):Dynamic
	{
		return new JSONMapParser(str).doParse();
	}

	override function parseRec():Dynamic
	{
		while (true)
		{
			var c = nextChar();
			switch (c)
			{
				case ' '.code, '\r'.code, '\n'.code, '\t'.code:
				// loop
				case '{'.code:
					var obj = new Map<String, Dynamic>(),
						field = null,
						comma:Null<Bool> = null;
					while (true)
					{
						var c = nextChar();
						switch (c)
						{
							case ' '.code, '\r'.code, '\n'.code, '\t'.code:
							// loop
							case '}'.code:
								if (field != null || comma == false)
									invalidChar();
								return obj;
							case ':'.code:
								if (field == null)
									invalidChar();
								// Reflect.setField(obj, field, parseRec());
								obj.set(field, parseRec());
								field = null;
								comma = true;
							case ','.code:
								if (comma) comma = false else invalidChar();
							case '"'.code:
								if (field != null || comma)
									invalidChar();
								field = parseString();
							default:
								invalidChar();
						}
					}
				case '['.code:
					var arr = [], comma:Null<Bool> = null;
					while (true)
					{
						var c = nextChar();
						switch (c)
						{
							case ' '.code, '\r'.code, '\n'.code, '\t'.code:
							// loop
							case ']'.code:
								if (comma == false)
									invalidChar();
								return arr;
							case ','.code:
								if (comma) comma = false else invalidChar();
							default:
								if (comma)
									invalidChar();
								pos--;
								arr.push(parseRec());
								comma = true;
						}
					}
				case 't'.code:
					var save = pos;
					if (nextChar() != 'r'.code || nextChar() != 'u'.code || nextChar() != 'e'.code)
					{
						pos = save;
						invalidChar();
					}
					return true;
				case 'f'.code:
					var save = pos;
					if (nextChar() != 'a'.code || nextChar() != 'l'.code || nextChar() != 's'.code || nextChar() != 'e'.code)
					{
						pos = save;
						invalidChar();
					}
					return false;
				case 'n'.code:
					var save = pos;
					if (nextChar() != 'u'.code || nextChar() != 'l'.code || nextChar() != 'l'.code)
					{
						pos = save;
						invalidChar();
					}
					return null;
				case '"'.code:
					return parseString();
				case '0'.code, '1'.code, '2'.code, '3'.code, '4'.code, '5'.code, '6'.code, '7'.code, '8'.code, '9'.code, '-'.code:
					return parseNumber(c);
				default:
					invalidChar();
			}
		}
	}
}
