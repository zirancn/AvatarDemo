package {
    /**
     * 模块说明
     * @author Zhangziran
     * @date 14-2-18.
     */
    public class GameParameters {
        public var resourceHost:String;

        public function GameParameters() {
        }

        private static var _instance:GameParameters;

        public static function getInstance():GameParameters {
            return _instance ||= new GameParameters();
        }

        public function init():void{
            resourceHost = "assets/";
        }
    }
}
