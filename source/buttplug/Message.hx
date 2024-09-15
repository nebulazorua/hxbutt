package buttplug;

import buttplug.Message.MessageField;
import haxe.Json;

enum abstract MessageField(String) from String to String
{
	var UNKNOWN = "UNKNOWN";
	var ID = "Id";
	var ERROR_MESSAGE = "ErrorMessage";
	var ERROR_CODE = "ErrorCode";
	var CLIENT_NAME = "ClientName";
	var MESSAGE_VERSION = "MessageVersion";
	var SERVER_NAME = "ServerName";
	var MAX_PING_TIME = "MaxPingTime";
	var DEVICES = "Devices";
	var DEVICE_NAME = "DeviceName";
	var DEVICE_INDEX = "DeviceIndex";
	var DEVICE_MESSAGES = "DeviceMessages";
}

enum abstract MessageType(String) from String to String
{
	var UNKNOWN = "UNKNOWN";
	var REQUEST_SERVER_INFO = "RequestServerInfo";
	var REQUEST_DEVICE_LIST = "RequestDeviceList";
	var SERVER_INFO = "ServerInfo";
	var DEVICE_LIST = "DeviceList";
	var START_SCANNING = "StartScanning";
	var STOP_SCANNING = "StopScanning";
	var DEVICE_ADDED = "DeviceAdded";
	var DEVICE_REMOVED = "DeviceRemoved";
	var SCALAR_CMD = "ScalarCmd";
	var STOP_DEVICE = "StopDeviceCmd";
	var STOP_ALL_DEVICES = "StopAllDevices";
	var SCANNING_FINISHED = "ScanningFinished";
}

class Message
{
	public var fields:Map<MessageField, Dynamic> = [];
	public var type:MessageType = UNKNOWN;

	public function new(id:Int = 1)
		fields.set(ID, id);

	public function getId()
		return fields.get(ID);

	public function serialize()
	{
		var map:Map<MessageType, Dynamic> = [];
		map.set(type, fields);
		return map;
	}

	public inline function getData()
		return Json.stringify([serialize()]);

	public static function construct(rawData:Map<String, Dynamic>)
	{
		var data:Map<MessageType, Map<MessageField, Dynamic>> = cast rawData;

		var newMessage = new Message();
		newMessage.type = data.keys().next();
		newMessage.fields = data.get(newMessage.type);
		return newMessage;
	}
}

@:build(buttplug.MessageMacro.build())
abstract ServerInfoMessage(Message) from Message to Message
{
	public var ServerName:String = "";
	public var MaxPingTime:Int = 0;
	public var MessageVersion:Int = 0;
}

@:build(buttplug.MessageMacro.build())
abstract DeviceListMessage(Message) from Message to Message
{
	public var Devices:Array<Dynamic> = [];
}

@:build(buttplug.MessageMacro.build())
abstract DeviceAddedMessage(Message) from Message to Message
{
	public var DeviceName:String = "";
	public var DeviceIndex:Int = 0;
	public var DeviceDisplayName:String = "";
}

@:build(buttplug.MessageMacro.build())
abstract DeviceRemovedMessage(Message) from Message to Message
{
	public var DeviceIndex:Int = 0;
}
