package {

import flash.display.Sprite;
import flash.text.TextField;

public class game extends Sprite {
    public function game() {
        var textField:TextField = new TextField();
        textField.text = "Hello, World";
        addChild(textField);
    }
}
}
