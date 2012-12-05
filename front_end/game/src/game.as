package {

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;

import resources.ResourceManager;

import resources.ResourceProxy;

public class game extends Sprite {

    private var resource:ResourceProxy;

    public function game() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);

        resource = new ResourceProxy();
        resource.addEventListener(Event.COMPLETE, onSourceLoaded);

        var rm:ResourceManager = new ResourceManager();
        rm.loadResource(ResourceProxy.BASE_LIB, ResourceProxy.BTN_SYMBOL, resource.callBack);
    }

    private function onSourceLoaded(event:Event):void {
        stage.addChild(resource.content);
    }
}
}
