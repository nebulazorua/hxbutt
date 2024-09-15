package buttplug;

enum abstract ActuatorType(String) from String to String
{
	var UNKNOWN = "Unknown";
	var VIBRATE = "Vibrate";
	var INFLATE = "Inflate";
	var ROTATE = "Rotate";
	var OSCILLATE = "Oscillate";
	var CONSTRICT = "Constrict";
	var POSITION = "Position";
}

@:structInit
class GenericAttribute
{
	public var index:Int = 0;

	public var actuatorType:ActuatorType = UNKNOWN;
	public var featureDescriptor:String = "";
	public var stepCount:Int = 20;

	public inline static function construct(data:Map<String, Dynamic>):GenericAttribute
		return {
			actuatorType: data.get("ActuatorType"),
			featureDescriptor: data.get("FeatureDescriptor"),
			stepCount: data.get("StepCount")
		};
}
