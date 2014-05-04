package common.scene.unit {
    import common.scene.avatar.Avatar;
    import common.scene.vo.RoleVO;

    import flash.display.Sprite;

    /**
     * 角色单元
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class Role extends Sprite {
        private var _avatar:Avatar;

        public function Role() {
            _avatar = new Avatar();
            addChild(_avatar);
        }

        public function reset(vo:RoleVO):void {
            _avatar.resetSkin(vo.skin, vo.sex);
            this.x = vo.x;
            this.y = vo.y;
        }
    }
}
