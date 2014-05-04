package common.managers {
    /**
     * 所有Loop使用的唯一key
     * @author Zhangziran
     * @date 14-2-11.
     */
    public class OnlyKeyCreater {
        private static var _key:int;
        public static function get key():int {
            _key += 1;
            return _key;
        }
    }
}
