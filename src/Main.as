package {
    import common.loaders.MassLoader;
    import common.managers.LoopManager;
    import common.scene.SceneEngine;
    import common.scene.avatar.Avatar;
    import common.scene.avatar.AvatarUtil;
    import common.scene.vo.RoleVO;
    import common.scene.vo.SkinVO;
    import common.utils.UIEditor;

    import flash.display.Bitmap;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;
    import flash.system.Security;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.ui.Mouse;

    [SWF(backgroundColor="0x000000", frameRate="30")]
    public class Main extends Sprite {
        public function Main() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");

            init();
        }

        private function init():void {
            GameParameters.getInstance().init();
            LoopManager.init(this.stage);
            SceneEngine.init();
            UIEditor.getInstance().register(this.stage, this.stage);
            enterGame();
        }

        private function enterGame():void {
            roleEnter()

            initTest();
        }

        private var _role:Avatar;
        private var _dir:int = 3;
        private var _act:String;

        private function roleEnter():void {
            _role = new Avatar();
            _role.x = 500;
            _role.y = 500;

            var s:SkinVO = new SkinVO();
            s.body = 1001;
            s.weapon = 10000001;
            _role.resetSkin(s, 1);

            addChild(_role);
        }

        private var ts:Array;
        private const TS_TEXT:Array = ["左", "右", "站立", "跑", "攻击", "受伤", "死亡", "坐下"];

        private function initTest():void {
            ts = [];
            for (var i:int = 0; i < 8; i++) {
                var t:TextField = new TextField();
                t.text = TS_TEXT[i];
                t.autoSize = TextFieldAutoSize.LEFT;
                t.textColor = 0x00ff00;
                t.mouseEnabled = true;
                t.selectable = false;
                t.x = 600;
                t.y = 100 + 40 * i;
                addChild(t);
                ts.push(t);
                t.addEventListener(MouseEvent.CLICK, onClick)
            }
        }

        private function onClick(event:MouseEvent):void {
            switch (event.currentTarget) {
                case ts[0]:
                    _dir++;
                    if (_dir > 7)_dir = 0;
                    break;
                case ts[1]:
                    _dir--;
                    if (_dir < 0)_dir = 7;
                    break;
                case ts[2]:
                    _act = AvatarUtil.ACT_STAND
                    break;
                case ts[3]:
                    _act = AvatarUtil.ACT_WALK
                    break;
                case ts[4]:
                    _act = AvatarUtil.ACT_ATTACK
                    break;
                case ts[5]:
                    _act = AvatarUtil.ACT_HURT
                    break;
                case ts[6]:
                    _act = AvatarUtil.ACT_DIE
                    break;
                case ts[7]:
                    _act = AvatarUtil.ACT_SIT
                    break;
            }
            _role.play(_act, _dir);
        }
    }
}
