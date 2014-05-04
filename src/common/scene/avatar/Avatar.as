package common.scene.avatar {
    import common.scene.SceneEngine;
    import common.scene.vo.BitmapVO;
    import common.scene.vo.SkinVO;

    import flash.display.Bitmap;

    import flash.display.Sprite;
    import flash.events.Event;

    /**
     * 换装单元
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class Avatar extends IAvatar {
        public static var keyCreater:int;
        private var _key:String;

        private var _act:String; //动作
        private var _dir:int; //方向
        private var _skin:SkinVO;
        private var _sex:int;
        private var _weaponUrl:String;//武器
        private var _bodyUrl:String;//身体
        private var _standUrl:String;//站立的URL，默认用

        private var _partsUrl:Array;//各层URL

        private var _layer:Sprite;//基本容器
        private var _parts:Array;//各层

        public function Avatar() {
            super();
            init();
        }

        //-------------------------------------------------
        //外部接口
        //-------------------------------------------------
        override public function resetSkin(skin:SkinVO, sex:int):void {
            if (AvatarUtil.isEqual(_skin, skin) == false || _sex != sex) {
                _sex = sex;
                _skin = skin;
                _standUrl = AvatarUtil.createActUrl(_skin, AvatarUtil.BODY, AvatarUtil.ACT_STAND, _sex);
                change();
            }
        }

        //播放动作
        override public function play(act:String, dir:int):void {
            if (_skin == null || (act == _act && dir == _dir)) {
                return;
            }
            if(act == AvatarUtil.ACT_SIT){
                dir = AvatarUtil.DIR_DOWN;
            }
            _dir = dir;
            _act = act;
            change();
        }

        //-------------------------------------------------
        //内部函数
        //-------------------------------------------------
        private function change():void {
            _bodyUrl = AvatarUtil.createActUrl(_skin, AvatarUtil.BODY, _act, _sex);
            _weaponUrl = AvatarUtil.createActUrl(_skin, AvatarUtil.WEAPON, _act, _sex);

            sortUrls();

            resetPartNum();

            resetPartsAct();

            checkHeightChange(_bodyUrl, _act, _dir);
        }

        private function sortUrls():void {
            _partsUrl.length = 0;
            if (_bodyUrl) {
                _partsUrl.push(_bodyUrl);
            }
            if (_weaponUrl) {
                _partsUrl.push(_weaponUrl);
            }
        }

        //重置层数和设置URL
        private function resetPartNum():void {
            var len:int = parts.length > _partsUrl.length ? parts.length : _partsUrl.length;
            for (var i:int = 0; i < len; i++) {
                if (_partsUrl[i] != null) {
                    if (parts[i] == null) {
                        parts[i] = AvatarPart.getOne();
                    }
                    if (parts[i].parent == null) {
                        _layer.addChild(parts[i]);
                    }
                    parts[i].resetUrl(_partsUrl[i]);
                    parts[i].resetStandUrl(_standUrl);
                    parts[i].isBody = _partsUrl[i] == _bodyUrl;
                } else {
                    if (parts[parts.length - 1] != null) {
                        parts[parts.length - 1].unload();
                        parts.pop();
                    }
                }
            }
        }

        //重置各层动作
        private function resetPartsAct():void {
            var temDir:int = _dir < 5 ? _dir : 8 - _dir; //把左边的换成右边
            var len:int = parts.length;
            for (var i:int = 0; i < len; i++) {
                parts[i].resetAction(_act, temDir);
            }
        }

        //检查形象高度变化
        override protected function checkHeightChange(url:String, act:String, dir:int):void {
            if (SceneEngine.hasComplete(url)) {
                var h:int = SceneEngine.getResource(url).getActHeight(act, dir);
                if (heightChangeHandler != null) {
                    heightChangeHandler(h);
                }
            }
        }

        private function init():void {
            if (_key == null) {
                keyCreater += 1;

                _key = "avatar" + keyCreater;
                _parts = [];
                _partsUrl = [];
                _layer = new Sprite();
                _act = AvatarUtil.ACT_STAND;
                _dir = AvatarUtil.DIR_RIGHT_DOWN;
                addChild(_layer);

                this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
                this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
            }
        }

        private function onAddToStage(event:Event):void {
            SceneEngine.addCompleteHandler(onLoadComplete);
            SceneEngine.addToLoop(_key, loop);
        }

        private function onRemoveFromStage(event:Event):void {
            SceneEngine.removeCompleteHandler(onLoadComplete);
            SceneEngine.removeFromLoop(_key);
        }

        private function loop():void {
            for (var i:int = parts.length - 1; i >= 0; i--) {
                parts[i].loop()
            }
            if (_dir < 5) {
                if (this.scaleX != 1) {
                    this.scaleX = 1;
                }
            } else {
                if (this.scaleX != -1) {
                    this.scaleX = -1;
                }
            }
        }

        private function onLoadComplete(url:String):void {
            if (_partsUrl.indexOf(url) != -1) {
                resetPartsAct();
                if (url == _bodyUrl) {
                    checkHeightChange(url, _act, _dir);
                }
            }
        }

        //-------------------------------------------------
        //getter and setter
        //-------------------------------------------------
        public function get parts():Array {
            return _parts;
        }

        override public function unload():void {
            SceneEngine.removeFromLoop(_key);
            _skin = null;
        }
    }
}
