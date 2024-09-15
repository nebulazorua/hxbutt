package buttplug;

import buttplug.GenericAttribute.ActuatorType;
import haxe.Json;

// Scalar sub-command
// Used for things like vibration and inflation
class Scalar
{
	public var index:Int = 0;
	public var scalar(null, set):Float = 0;

	inline function set_scalar(val:Float)
		return scalar = val < 0 ? 0 : val > 1 ? 1 : val;

	public var actuatorType:ActuatorType = "";

	public function new(index:Int, scalar:Float, actuatorType:ActuatorType)
	{
		this.index = index;
		this.scalar = scalar;
		this.actuatorType = actuatorType;
	}

	public function serialize()
	{
		return {
			"Index": index,
			"Scalar": scalar,
			"ActuatorType": actuatorType
		}
	}
}
