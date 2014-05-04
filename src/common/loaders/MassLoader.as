package common.loaders {
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.Dictionary;

    /**
     * 基础加载器
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class MassLoader {
        public static const LEVEL_0:int = 0;
        public static const LEVEL_1:int = 1;
        public static const LEVEL_2:int = 2;
        public static const LEVEL_3:int = 3;

        private static var _loaderPool:Vector.<CacheURLLoader> = new <CacheURLLoader>[];
        private static var _waitList:Array = [];

        private static var _decoder:CacheLoader;
        private static var _decodingList:Array = [];

        private static var _urlMap:Dictionary = new Dictionary();

        //----------------------------------------------
        // 外部接口
        //----------------------------------------------

        public static function init():void {
            if (_decoder != null) {
                return;
            }
            for (var i:int = 0; i < 8; i++) {
                var loader:CacheURLLoader = new CacheURLLoader();
                loader.dataFormat = URLLoaderDataFormat.BINARY;
                loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
                loader.addEventListener(Event.COMPLETE, onComplete);
                loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                _loaderPool.push(loader);
            }
            _decoder = new CacheLoader();
            _decoder.contentLoaderInfo.addEventListener(Event.COMPLETE, onDecoderComplete);
            _decoder.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onDecoderError);
        }

        public static function add(url:String, complete:Function, progress:Function = null, level:int = 0, cache:Boolean = true):void {
            if (url == null || url == "") {
                return;
            }
            var cacheObj:Object = ResourcePool.get(url);
            if (cacheObj) {
                if (complete != null)
                    complete(cacheObj);
                return;
            }
            init();

            var info:Object = {};
            info.url = url;
            info.loadTime = 1;
            info.progress = progress;
            info.complete = complete;
            info.cache = cache;

            if (_urlMap[info.url]) {
                _urlMap[info.url].push(info);
            } else {
                _urlMap[info.url] = [info];
                _waitList.push(info);
                start();
            }
        }

        //----------------------------------------------
        // 内部函数
        //----------------------------------------------
        private static function start():void {
            if (_loaderPool.length <= 0) {
                return;
            }
            if (_waitList.length <= 0) {
                return;
            }
            var loader:CacheURLLoader = _loaderPool.pop();

            _waitList.sortOn("level", Array.NUMERIC);
            var info:Object = _waitList.shift();
            loader.info = info;
            loader.load(info.url);
        }

        private static function onComplete(event:Event):void {
            var loader:CacheURLLoader = event.target as CacheURLLoader;
            var info:Object = loader.info;
            info.data = loader.data;
            var ext:String = String(info.url).substr(String(info.url).length - 3, 3);
            if (ext == "swf" || ext == "png" || ext == "jpg") {
                _decodingList.push(info);
                decode();
            } else {
                var list:Array = _urlMap[info.url];
                delete _urlMap[info.url];
                if (list) {
                    while (list.length) {
                        var _info:Object = list.shift();
                        _info.data = loader.data;
                        if (_info.cache)
                            ResourcePool.add(_info.url, _info);
                        if (_info.complete != null) {
                            try {
                                _info.complete(_info);
                            } catch (e:Error) {
                                // do sth
                            }
                        }
                    }
                }
            }

            _loaderPool.push(loader);
            start();
        }

        private static function onProgress(event:ProgressEvent):void {
            // do sth;
        }

        //在发生会导致加载操作失败的输入或输出错误时，如网络断开
        private static function onIOError(event:Event):void {
            var _loader:CacheURLLoader = event.target as CacheURLLoader;
            _loaderPool.push(_loader);
            start();
        }

        //沙箱错误，本地加载未受信远程资源（反之亦然）
        private static function onSecurityError(event:SecurityErrorEvent):void {
            var _loader:CacheURLLoader = event.target as CacheURLLoader;
            _loaderPool.push(_loader);
            start();
        }

        private static function decode():void {
            if (_decoder.isWorking || _decodingList.length <= 0) {
                return;
            }

            var decodeInfo:Object = _decodingList.shift();
            try {
                _decoder.info = decodeInfo;
                _decoder.loadBytes(decodeInfo.data);
            } catch (e:Error) {
                //需要强制从远端加载
                trace(e);
            }
        }

        private static function onDecoderComplete(event:Event):void {
            var list:Array = _urlMap[_decoder.info.url];
            delete _urlMap[_decoder.info.url];

            if (list == null) {
                decode();
                return;
            }
            var length:int = list.length;
            for (var i:int = 0; i < length; i++) {
                try {
                    var _info:Object = list.shift();
                    _info.content = _decoder.content;
                    _info.applicationDomain = _decoder.contentLoaderInfo.applicationDomain;
                    if (_info.cache)
                        ResourcePool.add(_info.url, _info);
                    if (_info.complete != null)
                        _info.complete(_info);
                } catch (e:Error) {
                    if (e) {
                        // do sth
                    }
                }
            }
            decode();
        }

        private static function onDecoderError(event:Event):void {
            //由于可能字节序出现问题，导致decode错误，从而中断
            decode();
            start();
        }
    }
}
