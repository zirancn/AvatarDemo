package common.managers {
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    /**
     * 场景中的循环管理 ,有三种循环：桢频，80毫秒，1秒
     * @author linxuyang
     *
     */
    public class LoopManager {
        private static var _isInited:Boolean; //是否已经初始化完毕
        private static var _currentFrame:int; //当前第几帧
        public static var currentTime:int = getTimer(); //当前时间
        private static var lastTime:int; //用于计算帧频
        private static var frameRates:Array = []; //存放帧频
        private static var _realFrameRate:Number = 30; //实际帧频
        private static var frameLoopDic:Dictionary; //放循环函数
        //////////////////////////////////
        private static var timer:Timer; //80毫秒
        private static var timeoutDic:Dictionary; //放setTimeout函数
        private static var timeLoopDic:Dictionary; //放定时器执行函数
        private static var delayIDKey:int; //键值
        /////////////////////////////////
        private static var secondTimer:Timer; //1秒
        private static var SecondLoopDic:Dictionary; //放定时器执行函数
        private static var stage:Stage;

        public static function init($stage:Stage):void {
            if (_isInited == false) {
                frameLoopDic = new Dictionary; //放循环函数
                timeoutDic = new Dictionary; //放setTimeout函数
                timeLoopDic = new Dictionary; //放定时器执行函数	Rmap
                SecondLoopDic = new Dictionary; //放秒循环函数
                stage = $stage;
                stage.addEventListener(Event.ENTER_FRAME, frameLoop);
                timer = new Timer(80);
                timer.addEventListener(TimerEvent.TIMER, timerLoop);
                timer.start();
                secondTimer = new Timer(1000);
                secondTimer.addEventListener(TimerEvent.TIMER, secondLoop);
                secondTimer.start();
                _isInited = true;
            }
        }


        /**
         * 帧频循环
         * @param e
         *
         */
        private static function frameLoop(e:Event):void {
            for (var s:Object in frameLoopDic) {
                var f:Function = frameLoopDic[s];
                try {
                    f.call();
                } catch (e:Error) {
//						SystemModule.getInstance().postError(e, "enter Frame:" + s.toString());
                }
            }
            doFrameRate(); //计算帧频
        }

        /**
         * 时间循环
         * @param e
         *
         */
        private static function timerLoop(e:TimerEvent):void {
            for each (var obj:Object in timeoutDic) {
                if ((getTimer() - obj.startTime) >= obj.count) { //时间到了，执行
                    obj.handler.apply(null, obj.arg);
                    timeoutDic[obj.key] = null;
                    delete timeoutDic[obj.key];
                }
            }

            for (var s:Object in timeLoopDic) {
                var f:Function = timeLoopDic[s];
                try {
                    f.call();
                } catch (e:Error) {
//						SystemModule.getInstance().postError(e, "timer loop:" + s.toString());
                }
            }
        }

        /**
         * 秒循环
         * @param e
         *
         */
        private static function secondLoop(e:TimerEvent):void {
            for (var s:Object in SecondLoopDic) {
                var f:Function = SecondLoopDic[s];
                try {
                    f.call();
                } catch (e:Error) {
//						SystemModule.getInstance().postError(e, "second loop:" + s.toString());
                }
            }
        }

        /**
         * 加入到桢循环
         * @param key
         * @param fun
         *
         */
        public static function addToFrame(key:Object, fun:Function):void {
            if (frameLoopDic[key] == null) {
                frameLoopDic[key] = fun;
            }
        }

        /**
         * 移除出桢循环
         * @param key
         *
         */
        public static function removeFromFrame(key:Object):void {
            if (frameLoopDic[key]) {
                frameLoopDic[key] = null;
                delete frameLoopDic[key];
            }
        }


        public static function hasFrame(key:Object):Boolean {
            if (frameLoopDic[key]) {
                return true;
            }
            return false;
        }

        public static function hasKey(key:Object):Boolean {
            if (SecondLoopDic[key]) {
                return true;
            } else {
                return false;
            }
        }

        public static function hasTimer(key:Object):Boolean {
            if (timeLoopDic[key]) {
                return true;
            } else {
                return false;
            }
        }

        public static function addToTimer(key:Object, fun:Function):void {
            if (timeLoopDic[key] == null) {
                timeLoopDic[key] = fun;
            }
        }

        public static function removeFromTimer(key:Object):void {
            if (timeLoopDic[key]) {
                timeLoopDic[key] = null;
                delete timeLoopDic[key];
            }
        }

        /**
         * 加入到秒循环
         * @param key
         * @param fun
         *
         */
        public static function addToSecond(key:Object, fun:Function):void {
            if (SecondLoopDic[key] == null) {
                SecondLoopDic[key] = fun;
            }
        }

        /**
         * 移除秒循环
         * @param key
         *
         */
        public static function removeFromSceond(key:Object):void {
            if (SecondLoopDic[key]) {
                SecondLoopDic[key] = null;
                delete SecondLoopDic[key];
            }
        }

        /**
         * 代替了setTimeOut
         * @param delay
         * @param fun
         * @param args
         * @return
         *
         */
        public static function setTimeout(fun:Function, delay:int, args:Array = null):int {
            if (delay == 0) {
                fun.apply(null, args);
                return 0;
            }
            delayIDKey++;
            var obj:Object = {key: delayIDKey, startTime: getTimer(), count: delay, handler: fun, arg: args};
            if (timeoutDic[delayIDKey] == null) {
                timeoutDic[delayIDKey] = obj;
            }
            return delayIDKey;
        }

        /**
         * 清除setTimeout
         * @param id
         *
         */
        public static function clearTimeout(id:int):void {
            if (timeoutDic[id]) {
                timeoutDic[id] = null;
                delete timeoutDic[id];
            }
        }

        public static function hasTimeout(id:int):Boolean {
            return timeoutDic[id] != null
        }

        //当前瞬时帧频
        public static function get realRate():int {
            return _realFrameRate;
        }

        private static var _frameHold:int = 30; //当前帧保持的毫秒数

        //当前帧持续时间（毫秒）
        public static function get frameHold():int {
            return _frameHold;
        }

        private static var secFrames:int; //一秒内运行过的帧数
        private static var frameTime:int;

        private static function doFrameRate():void {
            _currentFrame++;
            var t:int = getTimer();
            _frameHold = t - lastTime;
            lastTime = t;
            secFrames++;
            if ((t - frameTime) >= 1000) {
                _realFrameRate = secFrames;
                frameTime = t;
                secFrames = 0;
            }
        }

        public static function get currentFrame():int {
            return _currentFrame;
        }

        public static function frameToTime(frame:int):int {
            return frame * (1000 / stage.frameRate);
        }

        /**
         * 获取time秒有多少帧
         */
        public static function timeToFrame(time:Number):int {
            return time * stage.frameRate;
        }

        //毫秒级别
        public static function timeToFrame2(time:Number):int {
            return time / 1000 * stage.frameRate;
        }
    }
}
