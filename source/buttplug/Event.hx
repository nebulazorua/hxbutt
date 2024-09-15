package buttplug;

import haxe.Rest;

class Event<T:haxe.Constraints.Function>
{
	var _listeners:Array<T> = [];

	public function new() {}

	public function add(listener:T)
		_listeners.push(listener);

	public function remove(listener:T)
		_listeners.remove(listener);

	public function dispatch(args:Rest<Dynamic>)
	{
		var params = args.toArray();

		var index:Int = 0;
		while (index < _listeners.length)
		{
			if (_listeners[index] == null)
			{
				_listeners.splice(index, 1);
				continue;
			}
			Reflect.callMethod(null, _listeners[index], params);
			index++;
		}
	}
}
