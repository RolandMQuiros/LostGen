package lostgen.view;
import org.flixel.FlxG;
import org.flixel.FlxText;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;
import org.flixel.tweens.motion.LinearMotion;

/**
 * ...
 * @author Roland M. Quiros
 */

class BouncingText extends FlxText {
    public static inline var BOUNCE_HEIGHT: Float = 48.0;
    public static inline var BOUNCE_TIME: Float = 0.5;
    var m_bounceTween: LinearMotion;
    
    public function new(x: Float, y: Float, width: Int, text: String=null, embeddedFont: Bool=true) {
        super(x, y, width, text, embeddedFont);
        exists = false;
        
        m_bounceTween = new LinearMotion(onBounceFinish, FlxTween.PERSIST);
        m_bounceTween.setObject(this);
        
        addTween(m_bounceTween);
    }
    
    override public function revive():Void {
        super.revive();
        
        m_bounceTween.setMotion(x, y, x, y - BOUNCE_HEIGHT, BOUNCE_TIME, Ease.cubeInOut);
        m_bounceTween.start();
    }
    
    override public function update():Void {
        super.update();
    }
    
    function onBounceFinish(): Void {
        exists = false;
    }
}