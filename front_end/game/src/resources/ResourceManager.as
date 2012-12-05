package resources {
import flash.display.Loader;
import flash.events.EventDispatcher;
import flash.system.ApplicationDomain;

public class ResourceManager extends EventDispatcher{
        public function ResourceManager() {
        }

        private static var _instance:ResourceManager;
        public static function instance():ResourceManager {
            if(_instance == null) _instance = new ResourceManager();
            return _instance;
        }


        private var loadQueue:Vector.<ResourceLoaderContainer> = new Vector.<ResourceLoaderContainer>;
        private var requests:Vector.<ResourceRequest> = new Vector.<ResourceRequest>;

        private var _resourceCache:Object = new Object();

        public function loadResource(libName:String, className:String, callbac:Function):void {
            var request:ResourceRequest = new ResourceRequest(libName, className, callbac);
            requests.push(request);

            if(_resourceCache[libName] && _resourceCache[libName].loaded){
                onResourceLoadSuccess(_resourceCache[libName].data, _resourceCache[libName].libName)
            } else {
                var resourceCacheObj:ResourceCacheObject = new ResourceCacheObject(libName, className);
                _resourceCache[libName] = resourceCacheObj;
            }

            if( !libInProgress(libName) ){
                var loadContainer:ResourceLoaderContainer = new ResourceLoaderContainer(libName, "", onResourceLoadSuccess, onResourceLoadError)
                loadQueue.push(loadContainer);
            }
        }

        private function libInProgress(libName:String):Boolean {
            for each (var resourceLoaderContainer:ResourceLoaderContainer in loadQueue) {
                if(resourceLoaderContainer.libName == libName){
                    return true;
                }
            }
            return false
        }

        private function removeFromLoadQueue(libName:String):void {
            for each (var resourceLoaderContainer:ResourceLoaderContainer in loadQueue) {
                if(resourceLoaderContainer.libName == libName) {
                    loadQueue.splice(loadQueue.indexOf(resourceLoaderContainer),1);
                    return;
                }
            }
        }

        private function removeResourceRequest(libName:String):void {
            for each (var resourceRequest:ResourceRequest in requests) {
                if(resourceRequest.libName == libName) {
                    requests.splice(requests.indexOf(resourceRequest),1);
                    return;
                }
            }
        }

        private function getLoadContainer(libName:String):ResourceLoaderContainer {
            for each (var resourceLoaderContainer:ResourceLoaderContainer in loadQueue) {
                if(resourceLoaderContainer.libName == libName) return resourceLoaderContainer;
            }
            return null;
        }

        private function getResourceRequest(libName:String):ResourceRequest {
            for each (var resourceRequest:ResourceRequest in requests) {
                if(resourceRequest.libName == libName) return resourceRequest;
            }
            return null;
        }

        private function processRequest(request:ResourceRequest, cache:ResourceCacheObject):void{
            var ad:ApplicationDomain = cache.data.loaderInfo.applicationDomain;
            var instClass:Class;
            if(ad.hasDefinition(request.className)){
                instClass = ad.getDefinition(request.className) as Class;
                var img:* = new instClass();
                request.callBack(img);
            } else {
                throw new Error(this+" lib: "+cache.libName+" Has no "+request.className);
            }
        }

        private function onResourceLoadSuccess(data:Object, libName:String):void {
            var cached:ResourceCacheObject = _resourceCache[libName] as ResourceCacheObject;
            cached.data = data;
            cached.loaded = true;
            getLoadContainer(libName);
            removeFromLoadQueue(libName);

            var request:ResourceRequest;
            while(request = getResourceRequest(libName)){
                processRequest(request, cached);
                removeResourceRequest(libName);
            }

        }
        private function onResourceLoadError(data:Object, libName:String):void {
            for each (var resourceLoaderContainer:ResourceLoaderContainer in loadQueue) {
                if(resourceLoaderContainer.libName == libName){
                    loadQueue.splice(0,loadQueue.indexOf(resourceLoaderContainer));
                    return;
                }
            }
        }
    }
}

import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

class ResourceRequest{
    public var libName:String, className:String,callBack:Function;
    public var loaded:Boolean;

    public function ResourceRequest(libName:String, className:String,callBack:Function):void {
        this.libName    = libName;
        this.className  = className;
        this.callBack   = callBack;
    }
}

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
        _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSuccess);
        _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);

        dispatchEvent(new Event(Event.COMPLETE));
    }

    /** destructor*/
    public function destroy():void{
        _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onSuccess);
        _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        _loader     = null;
        _url        = null;
        data        = null;
        err_data    = null;
    }
}

class ResourceLoaderContainer{
    public var resourceLoader:ResourceLoader, _success:Function, _error:Function;
    public var libName:String;

    public function ResourceLoaderContainer(libName:String, url:String, success:Function, error:Function):void {
        this.libName = libName;
        _success    = success;
        _error      = error;
        ( this.resourceLoader = new ResourceLoader(url + libName) ).addEventListener(Event.COMPLETE, onComplete);
    }

    private function onComplete(event:Event):void {
        this.resourceLoader.removeEventListener(Event.COMPLETE, onComplete);
        if(resourceLoader.err_data){
            _error(resourceLoader.err_data, this.libName);
        } else {
            _success(resourceLoader.data, this.libName);
        }
    }
}

class ResourceCacheObject{
    public var libName          : String;
    public var className        : String;

    public var data             : Object;
    public var loaded           : Boolean;

    public function ResourceCacheObject(libName: String, className: String):void {
        this.libName    = libName;
        this.className  = className;
    }
}