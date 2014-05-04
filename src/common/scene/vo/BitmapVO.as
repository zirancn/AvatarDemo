package common.scene.vo {
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.geom.Matrix;
    import flash.system.ApplicationDomain;
    import flash.utils.Dictionary;

    /**
     * Bitmap封装
     * @author Zhangziran
     * @date 14-2-18.
     */
    public class BitmapVO {
        public var url:String;
        public var domain:ApplicationDomain;
        public var isComplete:Boolean;

        private var _bmds:Dictionary;
        private var _source:MovieClip;

        public function set source(mc:MovieClip):void {
            if (mc != null) {
                _source = mc;
                _bmds = new Dictionary();
            }
        }

        public function get source():MovieClip {
            return _source;
        }

        public function getLength(act:String):int {
            if (_source && _source.hasOwnProperty(act + '_l')) {
                return _source[act + '_l'];
            }
            if (act == "defult" && _source && _source.hasOwnProperty("default_l")) {
                return _source["default_l"];
            }
            return 0;
        }

        public function getActHeight(act:String, dir:int = 0):int {
            var elementVO:BitmapFrameVO;
            for (var i:int = 0; i < 5; i++) {
                elementVO = getFrame(act + "_d" + i + "_0")
                if (elementVO && elementVO.data) {
                    return -elementVO.offsetY;
                }
            }
            return 120;
        }

        public function getFrame(value:String):BitmapFrameVO {
            if (_bmds && _bmds.hasOwnProperty(value)) {
                return _bmds[value];
            } else {
                var b:BitmapFrameVO = new BitmapFrameVO();
                var cls:Class;
                try { //忽略左边
                    cls = Class(domain.getDefinition(value));
                    b.data = new cls(0, 0);
                    b.offsetX = _source[value.concat('_x')];
                    b.offsetY = _source[value.concat('_y')];
                    b.hold = _source[value.concat('_h')];
                    _bmds[value] = b;
                } catch (error:Error) {
                }
                return b;
            }
        }

        private static function flipHorizontal(bt:BitmapData):BitmapData {
            var bmd:BitmapData = new BitmapData(bt.width, bt.height, true, 0x00000000);
            var mat:Matrix = new Matrix();
            mat.scale(-1, 1);
            mat.tx += bt.width
            bmd.draw(bt, mat);
            return bmd;
        }

        public function dispose():void {
            for each (var f:BitmapFrameVO in _bmds) {
                f.data.dispose();
            }
            _bmds = null;
        }

        public function get bmds():Dictionary {
            return _bmds;
        }

        public function set bmds(value:Dictionary):void {
            _bmds = value;
        }
    }
}
