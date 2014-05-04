package common.scene {
    import common.loaders.MassLoader;
    import common.managers.LoopManager;
    import common.scene.vo.BitmapFrameVO;
    import common.scene.vo.BitmapFrameVO;
    import common.scene.vo.BitmapVO;

    import flash.display.Bitmap;

    import flash.display.MovieClip;
    import flash.system.ApplicationDomain;

    import flash.utils.Dictionary;

    /**
     * 场景驱动
     * @author Zhangziran
     * @date 14-2-11.
     */
    public class SceneEngine {
        //场景心跳
        private static var _loopFuns:Dictionary = new Dictionary();
        //场景资源管理
        private static var _cache:Dictionary = new Dictionary();
        private static var _loadComFuns:Array = [];

        [Embed("../../assets/egg.png")]
        private static var _eggClass:Class;
        private static var _eggFrame:BitmapFrameVO;

        public static function init():void {
            LoopManager.addToFrame("SceneEngine", loop);
        }

        public static function addToLoop(id:String, f:Function):void {
            if (_loopFuns.hasOwnProperty(id) == false) {
                _loopFuns[id] = f;
            }
        }

        public static function removeFromLoop(id:String):void {
            if (_loopFuns.hasOwnProperty(id)) {
                _loopFuns[id] = null;
                delete _loopFuns[id];
            }
        }

        private static function loop():void {
            for each(var f:Function in _loopFuns) {
                f.call();
            }
        }

        //------------------------------------------------------
        //场景资源管理
        //------------------------------------------------------
        public static function get eggFrame():BitmapFrameVO {
            if (_eggFrame == null) {
                _eggFrame = new BitmapFrameVO();
                _eggFrame.offsetX = -23;
                _eggFrame.offsetY = -90;
                var b:Bitmap = new _eggClass() as Bitmap;
                _eggFrame.data = b.bitmapData;
            }
            return _eggFrame;
        }

        public static function get cache():Dictionary {
            return _cache;
        }

        private static function has(url:String):Boolean {
            return _cache[url] != undefined;
        }

        public static function hasComplete(url:String):Boolean {
            if (cache[url] == null || cache[url].isComplete == false) {
                return false;
            }
            return true;
        }

        public static function getResource(url:String):BitmapVO {
            return cache[url];
        }

        public static function load(url:String, level:int = 2):void {
            if (has(url) == false) {
                var v:BitmapVO = new BitmapVO();
                v.url = url;
                _cache[url] = v;
                MassLoader.add(url, onLoaderComplete, null, level, false);
            }
        }

        private static function onLoaderComplete(obj:Object):void {
            var v:BitmapVO = _cache[obj.url];
            if (v == null) {
                v = new BitmapVO();
                v.url = obj.url
            }
            v.domain = obj.applicationDomain;
            v.source = obj.content;
            v.isComplete = true;
            cache[obj.url] = v;

            var len:int = _loadComFuns.length;
            for (var i:int = 0; i < len; i++) {
                if (_loadComFuns[i] != null) {
                    _loadComFuns[i](obj.url);
                }
                if (_loadComFuns.length < len) {
                    i--;
                    len--;
                }
            }
        }

        public static function addCompleteHandler(fun:Function):void {
            if (_loadComFuns.indexOf(fun) == -1) {
                _loadComFuns.push(fun);
            }
        }

        public static function removeCompleteHandler(fun:Function):void {
            var index:int = _loadComFuns.indexOf(fun);
            if (index != -1) {
                _loadComFuns.splice(index, 1);
            }
        }
    }
}
