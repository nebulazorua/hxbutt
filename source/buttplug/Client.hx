package buttplug;

import buttplug.Message.DeviceAddedMessage;
import buttplug.Message.DeviceListMessage;
import buttplug.Message.DeviceRemovedMessage;
import buttplug.Message.MessageField;
import buttplug.Message.MessageType as BMessageType;
import buttplug.Message.ServerInfoMessage;
import flixel.FlxG;
import haxe.Exception;
import haxe.Json;
import haxe.ds.StringMap;
import hx.ws.Log;
import hx.ws.Types;
import hx.ws.WebSocket;

class Client
{
	static final MESSAGE_SPEC:Int = 3;

	public var CLIENT_NAME = "hxButt";

	public var onError:String->Void;
	public var onClose:Void->Void;
	public var scannedDevices:Map<Int, Device> = [];
	public var deviceAdded:Event<Device->Void> = new Event<Device->Void>();
	public var deviceRemoved:Event<Device->Void> = new Event<Device->Void>();

	var messageHandlers:Map<BMessageType, (Message) -> Void> = [];
	var websocket:WebSocket;
	var responseQueue:Map<Int, Message->Void> = [];

	var currentMessageId:Int = 1;

	inline public function getMessaageId()
		return (currentMessageId++);

	public function new()
	{
		messageHandlers.set(BMessageType.DEVICE_ADDED, (m:DeviceAddedMessage) ->
		{
			if (scannedDevices.get(m.DeviceIndex) != null)
				return;

			var message:Message = cast m;
			var newDevice:Device = Device.construct(this, message.fields);
			scannedDevices.set(newDevice.index, newDevice);
			deviceAdded.dispatch(newDevice);
		});

		messageHandlers.set(BMessageType.DEVICE_REMOVED, (m:DeviceRemovedMessage) ->
		{
			var index:Int = m.DeviceIndex;
			var device:Device = scannedDevices.get(index);
			if (device != null)
				deviceRemoved.dispatch(device);

			scannedDevices.remove(index);
			device.destroy();
		});

		messageHandlers.set(BMessageType.SERVER_INFO, (m:ServerInfoMessage) ->
		{
			// TODO: handle Max Ping Time
			if (m.MessageVersion < MESSAGE_SPEC)
			{
				throw "Server Message Version is below current specification!\nA newer server with message spec of "
					+ MESSAGE_SPEC
					+ " or higher is required!";
				return;
			}

			startScanning();

			// Send a request for Buttplug.io devices
			requestDeviceList((m:Message) ->
			{
				if (m.type != DEVICE_LIST)
					throw "Unexpected response to request device list";

				var msg:DeviceListMessage = m;

				for (device in msg.Devices)
				{
					var newDevice:Device = Device.construct(this, device);
					if (scannedDevices.get(newDevice.index) != null)
						continue;

					scannedDevices.set(newDevice.index, newDevice);
					deviceAdded.dispatch(newDevice);
				}
			});
		});
	}

	public function sendMessage(message:Message, ?responseCallback:Message->Void) // wish I could just return the response lol
	{
		if (responseCallback != null)
			responseQueue.set(message.getId(), responseCallback);

		websocket.send(message.getData());
	}

	public function connect(?ip:String = "localhost:12345")
	{
		try
		{
			websocket = new WebSocket('ws://$ip', false);
			websocket.onopen = function()
			{
				var requestServerInfo = new Message(getMessaageId());
				requestServerInfo.type = BMessageType.REQUEST_SERVER_INFO;
				requestServerInfo.fields.set(MessageField.CLIENT_NAME, CLIENT_NAME);
				requestServerInfo.fields.set(MessageField.MESSAGE_VERSION, MESSAGE_SPEC);
				sendMessage(requestServerInfo);
			}

			websocket.onclose = function()
			{
				trace("websocket was closed");
				if (onClose != null)
					onClose();
			}
			websocket.onerror = function(err)
			{
				trace("websocket errored " + err);
				if (onError != null)
					onError(err);
			}
			websocket.onmessage = function(message:Dynamic)
			{
				switch (message)
				{
					case StrMessage(content):
						parseMessage(content);
					case BytesMessage(content):
						trace("Binary? We dont n eed binary bitch!");
				}
			}

			websocket.open();
		}
		catch (e:Exception)
		{
			FlxG.log.warn('Couldn\'t connect to Buttplug server at "${ip}" for some reason or another. Are you sure one is running?');
		}

		return this;
	}

	public function parseMessage(content:String)
	{
		var parsedData:Array<Map<String, Dynamic>> = JSONMapParser.parse(content);
		for (rawMessage in parsedData)
		{
			var message = Message.construct(rawMessage);
			var responseCallback = responseQueue.get(message.getId());
			if (responseCallback != null)
			{
				responseQueue.remove(message.getId());
				responseCallback(message);
			}

			if (messageHandlers.exists(message.type))
				messageHandlers.get(message.type)(message);
		}
	}

	public function startScanning()
	{
		var message = new Message(getMessaageId());
		message.type = BMessageType.START_SCANNING;
		sendMessage(message);
	}

	public function stopScanning()
	{
		var message = new Message(getMessaageId());
		message.type = BMessageType.STOP_SCANNING;
		sendMessage(message);
	}

	public function stopAllDevices()
	{
		var message = new Message(getMessaageId());
		message.type = BMessageType.STOP_ALL_DEVICES;
		sendMessage(message);
	}

	function requestDeviceList(?callback:Message->Void)
	{
		var message = new Message(getMessaageId());
		message.type = BMessageType.REQUEST_DEVICE_LIST;
		sendMessage(message, callback);
	}
}
