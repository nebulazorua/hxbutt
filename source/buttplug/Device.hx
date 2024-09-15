package buttplug;

import buttplug.GenericAttribute;
import buttplug.Message.MessageType;

class Device
{
	public var name:String = 'Unknown';
	public var index:Int = 0;
	public var displayName:String = 'Unknown';
	public var attributes:Map<String, Array<GenericAttribute>> = ["Scalar" => [], "Rotate" => [], "Linear" => []];

	var client:Client;

	public static function construct(client:Client, data:Map<String, Dynamic>)
	{
		var device = new Device(client);
		device.index = data.get("DeviceIndex");
		device.name = data.get("DeviceName");
		device.displayName = data.exists("DeviceDisplayName") ? data.get("DeviceDisplayName") : device.name;
		var messages:Map<String, Dynamic> = data.get("DeviceMessages");

		if (messages.exists("ScalarCmd"))
		{
			var scalarAttributes:Array<Map<String, Dynamic>> = cast messages.get("ScalarCmd");
			var index:Int = 0;
			for (attrib in scalarAttributes)
			{
				var scalar_attribute:GenericAttribute = GenericAttribute.construct(attrib);
				scalar_attribute.index = index;
				index++;
				device.attributes.get("Scalar").push(scalar_attribute);
			}
		}
		if (messages.exists("LinearCmd"))
		{
			var linearAttributes:Array<Map<String, Dynamic>> = cast messages.get("LinearCmd");
			var index:Int = 0;
			for (attrib in linearAttributes)
			{
				var linear_attribute:GenericAttribute = GenericAttribute.construct(attrib);
				linear_attribute.index = index;
				index++;
				device.attributes.get("Linear").push(linear_attribute);
			}
		}
		if (messages.exists("RotateCmd"))
		{
			var rotateAttributes:Array<Map<String, Dynamic>> = cast messages.get("RotateCmd");
			var index:Int = 0;
			for (attrib in rotateAttributes)
			{
				var rotate_attribute:GenericAttribute = GenericAttribute.construct(attrib);
				rotate_attribute.index = index;
				index++;
				device.attributes.get("Rotate").push(rotate_attribute);
			}
		}

		return device;
	}

	public function new(client:Client)
	{
		this.client = client;
	}

	public function sendScalar(type:ActuatorType, speed:Float = 0.5)
	{
		var scalars:Array<Dynamic> = [];
		for (attribute in attributes.get("Scalar"))
		{
			if (attribute.actuatorType == type)
			{
				scalars.push(new Scalar(attribute.index, speed, type).serialize());
			}
		}
		var message = new Message(client.getMessaageId());
		message.type = MessageType.SCALAR_CMD;
		message.fields.set("DeviceIndex", index);
		message.fields.set("Scalars", scalars);
		client.sendMessage(message);
	}

	inline public function vibrate(speed:Float = 0.5)
		sendScalar(VIBRATE, speed);

	public function stop()
	{
		var message = new Message(client.getMessaageId());
		message.type = MessageType.STOP_DEVICE;
		message.fields.set("DeviceIndex", index);
		client.sendMessage(message);
	}

	public function destroy()
		client = null;
}
