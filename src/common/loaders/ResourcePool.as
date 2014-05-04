package common.loaders {
    import flash.system.ApplicationDomain;
    import flash.utils.Dictionary;

    /**
     * 资源缓存
     * @author Zhangziran
     * @date 14-2-10.
     */
    public class ResourcePool {
        private static var sources:Dictionary = new Dictionary(true);

        //除地图以外的资源，都添加到缓存
        public static function add(url:String, source:*):void {
            sources[url] = source;
        }

        public static function get(url:String):* {
            return sources[url];
        }

        public static function remove(url:String):* {
            var source:* = get(url);
            delete sources[url];
            return source;
        }

        public static function hasResource(url:String):* {
            return sources[url] != null;
        }

        public static function getClass(url:String, name:String):* {
            var domain:ApplicationDomain = sources[url];
            if (domain && domain.hasDefinition(name)) {
                return domain.getDefinition(name);
            }
            return null;
        }

        public static function dispose():void {
            sources = null;
        }

        public static function getSource():Dictionary {
            return sources;
        }
    }
}
