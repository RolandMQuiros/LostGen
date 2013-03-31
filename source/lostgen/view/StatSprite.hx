package lostgen.view;
import org.flixel.FlxText;

/**
 * ...
 * @author Roland M. Quiros
 */

class StatSprite extends FlxText {
    public var name: String;
    public var hp: Int;
    public var maxHP: Int;
    public var mp: Int;
    public var maxMP: Int;
    
    public var sprite: FlxText;
    
    public function new(x: Float, y: Float, width:Int) {
        super(x, y, width);
        name = "";
    }
    
    public function updateString(): Void {
        text = name +
               "\nHP: " + hp + "/" + maxHP +
               "\nMP: " + mp + "/" + maxMP + "\n";
    }
}