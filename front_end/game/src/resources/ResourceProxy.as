package resources {
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;

public class ResourceProxy extends EventDispatcher{

    public static const SQUARE_SYMBOL:String    = "square_symbol";
    public static const BTN_SYMBOL:String       = "btn_symbol"   ;

    public static const BASE_LIB:String         = "base_lib"        + ".swf";

    public var content:DisplayObject;

    public function ResourceProxy() {
    }

    public function callBack(data:*):void{
        if(data !=null){
            if( data is DisplayObject ){
                this.content = data;
                dispatchEvent(new Event(Event.COMPLETE));
            } else {
                throw new Error( this + "callBack("+ typeof(data)+") Получен объект не правильного типа!")
            }
        } else {
            throw new Error( this + "callBack("+arguments+") Получен пустой объект!")
        }
    }
}
}
