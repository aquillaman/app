package resources {
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

    public class ResourceManager extends EventDispatcher{
        public function ResourceManager() {
        }

        private static var _instance:ResourceManager;
        public static function instance():ResourceManager {
            if(_instance == null) _instance = new ResourceManager();
            return _instance;
        }


        public var loadQueue:Vector.<ResourceLoaderContainer> = new Vector.<ResourceLoaderContainer>;

        private var _resourceCache:Dictionary = new Dictionary();

        public function loadResource(libPath:String, libName:String, className:String):void {
            if(_resourceCache[libName] == null){
                _resourceCache[libName] = new ResourceCacheObject(libPath, libName, className);
            }


        }

        private function onResourceLoadSuccess(data:Object):void {

        }
        private function onResourceLoadError(data:Object):void {

        }
    }
}

import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

class ResourceLoader extends EventDispatcher{
    private var _loader     : Loader;

    private var _url        : String;

    public var data         : Object;
    public var err_data     : Object;

    public function ResourceLoader(url:String) {
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSuccess);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        _loader.load( new URLRequest( _url=url ) );
    }

    private function onSuccess(event:Event):void {
        data = _loader.content;
        complete();
    }
    private function onError(event:IOErrorEvent):void {
        err_data = event.text;
        complete()
    }

    private function complete():void{
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSuccess);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);

        dispatchEvent(new Event(Event.COMPLETE));
    }

    /** destructor*/
    public function destroy():void{

        _loader     = null;
        _url        = null;
        data        = null;
        err_data    = null;
    }
}

class ResourceLoaderContainer{
    public var resourceLoader   : ResourceLoader;
    private var _success        : Function;
    private var _error          : Function;

    public function ResourceLoaderContainer(url:String, success:Function, error:Function):void {
        _success    = success;
        _error      = error;
        ( this.resourceLoader = new ResourceLoader(url) ).addEventListener(Event.COMPLETE, onComplete);
    }

    private function onComplete(event:Event):void {
        this.resourceLoader.removeEventListener(Event.COMPLETE, onComplete);
        if(resourceLoader.err_data){
            _error(resourceLoader.err_data);
        } else {
            _success(resourceLoader.data);
        }
    }
}

class ResourceCacheObject{
    public var path             : String;
    public var libName          : String;
    public var className        : String;

    public var data             : Object;
    public var loaded           : Boolean;

    public function ResourceCacheObject(path: String, libName: String, className: String):void {
        this.path       = path;
        this.libName    = libName;
        this.className  = className;
    }
}