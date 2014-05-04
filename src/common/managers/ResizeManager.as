package common.managers {
    import flash.display.Stage;
    import flash.events.Event;

    /**
     * 如题
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class ResizeManager {
        public static const minHeight:int = 500;
        public static const minWidth:int = 1060;

        public static var stage:Stage;

        public static var w:int;
        public static var h:int;

        public static function init($stage:Stage):void{
            stage = $stage;

            stage.addEventListener(Event.ACTIVATE, activateHandler);
            stage.addEventListener(Event.RESIZE, resizeHandler);

            w = stage.stageWidth;
            h = stage.stageHeight;
        }

        private static function resizeHandler(event:Event):void{
            w = Math.max(stage.stageWidth,minWidth);
            h = Math.max(stage.stageHeight,minHeight);
        }

        private static function activateHandler(event:Event):void{

        }
    }
}
