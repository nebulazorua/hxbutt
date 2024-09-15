package buttplug;

import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr;
import haxe.macro.Type.ClassField;
import haxe.macro.Type;

class MessageMacro
{
	macro public static function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		fields.push({
			name: "Id",
			access: [Access.APublic],
			kind: FieldType.FProp("get", "never", macro :Int),
			pos: Context.currentPos(),
		});
		fields.push({
			name: "get_Id",
			access: [AInline],
			kind: FFun({
				expr: (macro
					{
						return this.fields.get("Id");
					}),
				ret: macro :Int,
				args: []
			}),
			pos: Context.currentPos()
		});
		for (field in fields)
		{
			switch (field.kind)
			{
				case FVar(type, e):
					field.kind = FieldType.FProp("get", "never", type);
					fields.push({
						name: "get_" + field.name,
						access: [AInline],
						kind: FFun({
							expr: (macro
								{
									return this.fields.get($v{field.name});
								}),
							ret: type,
							args: []
						}),
						pos: Context.currentPos()
					});
				default:
					// do nothing
			}
		}
		return fields;
	}
}
