package common.scene.avatar {
    import common.scene.vo.SkinVO;

    import flash.display.BlendMode;
    import flash.display.DisplayObject;

    public class AvatarUtil {
        ///////////动作
        public static const ACT_ATTACK:String = 'attack';
        public static const ACT_DEFAULT:String = 'defualt';
        public static const ACT_DIE:String = 'die';
        public static const ACT_HURT:String = 'hurt';
        public static const ACT_SIT:String = 'sit';
        public static const ACT_STAND:String = 'stand';
        public static const ACT_WALK:String = 'walk';

        /////////////////方向
        public static const DIR_UP:int = 0;
        public static const DIR_RIGHT_UP:int = 1;
        public static const DIR_RIGHT:int = 2;
        public static const DIR_RIGHT_DOWN:int = 3;
        public static const DIR_DOWN:int = 4;
        public static const DIR_LEFT_DOWN:int = 5;
        public static const DIR_LEFT:int = 6;
        public static const DIR_LEFT_UP:int = 7;

        ///////////////////身体部件
        public static const BODY:int = 0;
        public static const WEAPON:int = 1;

        public static function isEqual(a:SkinVO, b:SkinVO):Boolean {
            if (a == null && b != null) {
                return false;
            }
            if (a != null && b == null) {
                return false;
            }
            if (a.body != b.body) {
                return false;
            }
            if (a.weapon != b.weapon) {
                return false;
            }
            return true;
        }

        //临时用的变量
        private static var body_url:String;
        private static var weapon_url:String;

        public static function createActUrl(skin:SkinVO, part:int, act:String, sex:int):String {
            switch (part) {
                case BODY:
                    body_url = skin.body + "";
                    switch (act) {
                        case ACT_STAND:
                            return "unit/role/" + body_url + "_stand.swf";
                        case ACT_WALK:
                            return "unit/role/" + body_url + "_walk.swf";
                        case ACT_ATTACK:
                            return "unit/role/" + body_url + "_attack.swf";
                        case ACT_HURT:
                            return "unit/role/" + body_url + "_hurt.swf";
                        case ACT_DIE:
                            return "unit/role/" + body_url + "_die.swf";
                        case ACT_SIT:
                            return "unit/role/" + body_url + "_sit.swf";
                        default:
                            return null;
                    }
                    break;
                case WEAPON:
                    weapon_url = skin.weapon + "";
                    switch (act) {
                        case ACT_STAND:
                            return "unit/role/" + weapon_url + "_stand.swf";
                        case ACT_WALK:
                            return "unit/role/" + weapon_url + "_walk.swf";
                        case ACT_ATTACK:
                            return "unit/role/" + weapon_url + "_attack.swf";
                        case ACT_HURT:
                            return "unit/role/" + weapon_url + "_hurt.swf";
                        case ACT_DIE:
                            return null;
                        default:
                            return null;
                    }
                    break;
                default:
                    return null;
                    break;
            }
            return null;
        }
    }
}