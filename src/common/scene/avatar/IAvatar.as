package common.scene.avatar {
    import common.scene.vo.SkinVO;

    import flash.display.Sprite;

    /**
     * 模块说明
     * @author Zhangziran
     * @date 14-2-11.
     */
    public class IAvatar extends Sprite {
        public var heightChangeHandler:Function;

        public function resetSkin(skin:SkinVO, sex:int):void {}

        public function play(act:String, dir:int):void {}

        //检查形象高度变化
        protected function checkHeightChange($url:String, $act:String, $dir:int):void { }

        public function unload():void {}
    }
}
