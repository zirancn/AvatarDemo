package common.scene.avatar {
    import common.scene.SceneEngine;
    import common.scene.vo.BitmapFrameVO;
    import common.scene.vo.BitmapVO;

    import flash.display.Bitmap;

    /**
     * Avatar层
     * @author Zhangziran
     * @date 14-2-17.
     */
    public class AvatarPart extends Bitmap {
        private static var _pool:Vector.<AvatarPart> = new Vector.<AvatarPart>;

        private var _isBody:Boolean;
        private var _url:String;
        private var _standUrl:String;

        private var _useUrl:String;
        private var _frameKey:String;
        private var _bmVO:BitmapVO;
        private var _frameVO:BitmapFrameVO;

        private var _holdCount:int;
        private var _currentFrame:int;
        private var _endFrame:int;

        private var _act:String;
        private var _dir:int;
        private var _hold:int;

        private var _isUrlComplete:Boolean;

        //---------------------------------------------
        //外部接口
        //---------------------------------------------
        public static function getOne():AvatarPart {
            if (_pool.length > 0) {
                return _pool.pop();
            }
            return new AvatarPart();
        }

        public function resetUrl(url:String):void {
            _url = url;
            _isUrlComplete = SceneEngine.hasComplete(_url);
        }

        public function resetStandUrl(url:String):void {
            _standUrl = url;
        }

        //设置动作，方向，间隔
        public function resetAction(act:String, dir:int):void {
            _currentFrame = 0;
            _act = act;
            _dir = dir;
            if (SceneEngine.hasComplete(_url)) {
                _endFrame = SceneEngine.getResource(_url).getLength(_act) - 1;
            } else {
                _endFrame = 0;
            }
        }

        public function loop():void {
            if (_url == null || _act == null) {
                return;
            }
            _useUrl = _url;
            if (_isUrlComplete == false) {
                _isUrlComplete = SceneEngine.hasComplete(_url);
            }
            if (_isUrlComplete == false) {
                if (_isBody) {
                    SceneEngine.load(url);
                    if (SceneEngine.hasComplete(_standUrl)) {
                        _useUrl = _standUrl;
                        _act = AvatarUtil.ACT_STAND;
                        _endFrame = SceneEngine.getResource(_useUrl).getLength(_act) - 1;
                    } else {
                        showEgg();
                        SceneEngine.load(_standUrl); //加载站立的身体
                        return;
                    }
                } else {
                    clear();
                    if (_standUrl != null && SceneEngine.hasComplete(_standUrl) == true) {
                        SceneEngine.load(_url); //加载身体除外的其他部件
                    }
                }
            }
            if (_holdCount >= _hold) {
                if (_currentFrame > _endFrame) { //播放到最后一帧
                    if (isLoop() == false) {
                        return;
                    }
                    _currentFrame = 0;
                }
                _frameKey = _act + "_d" + _dir + '_' + _currentFrame;
                _bmVO = SceneEngine.getResource(_useUrl);
                if (_bmVO) {
                    var f:BitmapFrameVO = _bmVO.getFrame(_frameKey);
                    if (f != _frameVO) {
                        this.bitmapData = f.data;
                        this._hold = f.hold;
                        super.x = f.offsetX;
                        super.y = f.offsetY;
                        _frameVO = f;
                    }
                }
                _currentFrame++;
                _holdCount = 0;
            }
            _holdCount++;
        }

        private function isLoop():Boolean {
            return _act == AvatarUtil.ACT_ATTACK || _act == AvatarUtil.ACT_STAND || _act == AvatarUtil.ACT_WALK || _act == AvatarUtil.ACT_HURT;
        }

        public function showEgg():void {
            var egg:BitmapFrameVO = SceneEngine.eggFrame;
            if (this.bitmapData != egg.data) {
                this.bitmapData = egg.data;
                super.x = egg.offsetX;
                super.y = egg.offsetY;
            }
        }

        public function clear():void {
            if (this.bitmapData != null) {
                this.bitmapData = null;
            }
        }

        public function unload():void {
            isBody = false;
            _url = null;
            _frameVO = null;
            this.bitmapData = null;
            _pool.push(this);
            if (this.parent) {
                this.parent.removeChild(this);
            }
        }

        //---------------------------------------------
        //内部函数
        //---------------------------------------------

        //---------------------------------------------
        //getter and setter
        //---------------------------------------------
        public function get url():String {
            return _url;
        }

        public function get isUrlComplete():Boolean {
            return _isUrlComplete;
        }


        public function get isBody():Boolean {
            return _isBody;
        }

        public function set isBody(value:Boolean):void {
            _isBody = value;
        }
    }
}
