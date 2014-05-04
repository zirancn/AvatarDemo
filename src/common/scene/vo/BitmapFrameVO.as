package common.scene.vo {
    import flash.display.BitmapData;

    /**
     * BitmapData封装
     * @author Zhangziran
     * @date 14-2-18.
     */
    public class BitmapFrameVO {
        public var data:BitmapData;
        public var offsetX:int;
        public var offsetY:int;
        public var hold:int;
        public function unload():void{
            data.dispose();
            data = null;
        }
    }
}
