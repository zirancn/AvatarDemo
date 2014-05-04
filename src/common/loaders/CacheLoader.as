package common.loaders {
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    /**
     * Loader的事件封装类
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class CacheLoader extends EventDispatcher {
        private var _info:Object;
        private var _bytesLoaded:int;//在侦听器处理事件时加载的项数或字节数。
        private var _bytesTotal:int;//如果加载过程成功，将加载的总项数或总字节数。

        private var _loader:Loader;
        private var _request:URLRequest;
        private var _loadUrl:String;

        private const RETRY_TIME:int = 3;
        private var _retryTime:int;

        private var _isWorking:Boolean;

        public function CacheLoader() {
            _loader = new Loader();
            addListeners();
        }

        //----------------------------------------------
        //外部接口
        //----------------------------------------------
        public function loadBytes(bytes:ByteArray):void {
            _isWorking = true;
            _loader.loadBytes(bytes);
        }

        public function load(url:String):void {
            _isWorking = true;
            _request ||= new URLRequest();
            _request.url = url;
            _loadUrl = url;
            _loader.load(_request);
        }

        public function get contentLoaderInfo():LoaderInfo {
            return _loader.contentLoaderInfo;
        }

        public function get content():DisplayObject{
            return _loader.content;
        }

        public function unload():void {
            _loader.unload();
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
            return _bytesLoaded;
        }

        public function get bytesTotal():int {
            return _bytesTotal;
        }

        public function get bytesPercent():int {
            if (_bytesTotal == 0) {
                return 0;
            }
            return Math.floor(_bytesLoaded / _bytesTotal * 100);
        }

        //----------------------------------------------
        // 内部函数
        //----------------------------------------------

        private function addListeners():void {
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
            _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
            _loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
        }

        private function removeListeners():void {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
            _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
            _loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
            _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        }

        private function onComplete(event:Event):void {
            _isWorking = false;
            dispatchEvent(event.clone());
        }

        private function onProgress(event:ProgressEvent):void {
            _bytesLoaded = event.bytesLoaded;
            _bytesTotal = event.bytesTotal;
            dispatchEvent(event.clone());
        }

        //在发生会导致加载操作失败的输入或输出错误时，如网络断开
        private function onIoError(event:Event):void {
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

        public function get isWorking():Boolean {
            return _isWorking;
        }

        public function get info():Object {
            return _info;
        }

        public function set info(value:Object):void {
            _info = value;
        }
    }
}
