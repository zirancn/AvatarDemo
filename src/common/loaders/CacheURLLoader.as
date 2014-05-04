package common.loaders {
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    /**
     * URLLoader的事件封装类
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class CacheURLLoader extends EventDispatcher {
        private var _info:Object;
        private var _loader:URLLoader;
        private var _request:URLRequest;
        private var _loadUrl:String;

        private var _isWorking:Boolean;

        private const RETRY_TIME:int = 3;
        private var _retryTime:int;

        public function CacheURLLoader() {
            _loader = new URLLoader();
            addListeners();
        }

        //----------------------------------------------
        //外部接口
        //----------------------------------------------

        public function load(url:String):void {
            _isWorking = true;

            url = GameParameters.getInstance().resourceHost + url;
            _request ||= new URLRequest();
            _request.url = url;
            _loadUrl = url;
            _loader.load(_request);
        }

        public function get isWorking():Boolean {
            return _isWorking;
        }

        public function set dataFormat(data:String):void {
            _loader.dataFormat = data;
        }

        public function get data():ByteArray {
            return _loader.data as ByteArray;
        }

        public function close():void {
            _loader.close();
        }

        public function reset():void {
            _retryTime = 0;
        }

        public function dispose():void {
            removeListeners();
        }

        public function get bytesLoaded():int {
            return _loader.bytesLoaded;
        }

        public function get bytesTotal():int {
            return _loader.bytesTotal;
        }

        public function get bytesPercent():int {
            if (_loader.bytesTotal == 0) {
                return 0;
            }
            return Math.floor(_loader.bytesLoaded / _loader.bytesTotal * 100);
        }

        //----------------------------------------------
        // 内部函数
        //----------------------------------------------

        private function addListeners():void {
            _loader.addEventListener(Event.COMPLETE, onComplete);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }

        private function removeListeners():void {
            _loader.removeEventListener(Event.COMPLETE, onComplete);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        }

        private function onComplete(event:Event):void {
            _isWorking = false;
            dispatchEvent(event.clone());
        }

        private function onProgress(event:ProgressEvent):void {
            dispatchEvent(event.clone());
        }

        //在发生会导致加载操作失败的输入或输出错误时，如网络断开
        private function onIOError(event:Event):void {
            if (_retryTime >= RETRY_TIME) {
                _isWorking = false;
                dispatchEvent(event.clone());
            } else {
                _retryTime++;
                _loader.load(new URLRequest(_loadUrl));
            }
        }

        //沙箱错误，本地加载未受信远程资源（反之亦然）
        private function onSecurityError(event:SecurityErrorEvent):void {
            if (_retryTime >= RETRY_TIME) {
                _isWorking = false;
                dispatchEvent(event.clone());
            } else {
                _retryTime++;
                _loader.load(new URLRequest(_loadUrl));
            }
        }

        //----------------------------------------------
        // getter and setter
        //----------------------------------------------
        public function set info(value:Object):void {
            _info = value;
        }

        public function get info():Object {
            return _info;
        }
    }
}
