package common.managers {
    import flash.utils.Dictionary;

    /**
     * 模块间通讯
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class Dispatcher {
        private static var _observers:Dictionary = new Dictionary; //KEY是消息名，值是数组，放函数
        private static var _mapping:Dictionary = new Dictionary; //KEY是函数，值是类名和函数名

        public static function register(type:String, call:Function, module:String = null, method:String = null):void {
            var funcs:Array = _observers[type];
            _mapping[call] = {'module': module, 'method': method};
            if (funcs == null) {
                funcs = [];
                _observers[type] = funcs;
            }
            if (funcs.indexOf(call) == -1) {
                funcs.push(call);
            }
        }

        public static function remove(type:String, call:Function):void {
            var funcs:Array = _observers[type];
            if (funcs) {
                var index:int = funcs.indexOf(call);
                if (index != -1) {
                    funcs.splice(index, 1);
                }
            }
        }

        public static function dispatch(type:String, ...arg):void {
            var funcs:Array = _observers[type];
            for each (var call:Function in funcs) {
                try {
                    if (arg.length == 0 || (arg.length == 1 && arg[0] == null)) {
                        call.apply(null, null);
                    } else {
                        call.apply(null, arg);
                    }
                } catch (e:Error) {
                    var obj:Object = _mapping[call];
                    if (obj != null) {
                        //do sth
                    } else {
                        //do sth
                    }
                }
            }
        }
    }
}