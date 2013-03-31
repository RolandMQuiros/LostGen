package lostgen.view;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.motion.LinearMotion;
import org.flixel.tweens.util.Ease;

/**
 * ...
 * @author Roland M. Quiros
 */
private enum FighterSpriteState {
    IDLE;
    CHARGE;
    RETREAT;
    LINK;
    ATTACK;
    HURT;
}

class FighterSprite extends FlxSprite {
    public static inline var HURT_TIME: Float = 0.5;
    public static inline var CHARGE_TIME: Float = 0.25;
    public var standingPoint(default, null): FlxPoint;
    
    var m_chargeTween: LinearMotion;
    var m_retreatTween: LinearMotion;
    
    var m_state: FighterSpriteState;
    var m_postChargeState: FighterSpriteState;
    var m_hurtTempState: FighterSpriteState;
    
    var m_target: FlxPoint;
    var m_targetPoints: Array<FlxPoint>;
    
    var m_attackFinish: Void->Void;
    var m_attackFinishers: Array < Void->Void > ;
    var m_attackDamages: IntHash<Int>;
    
    var m_hurtTimer: Float;
    
    public function new() {
        super();
        standingPoint = new FlxPoint();
        
        m_chargeTween = new LinearMotion(onChargeFinish, FlxTween.PERSIST);
        m_chargeTween.setObject(this);
        m_retreatTween = new LinearMotion(onRetreatFinish, FlxTween.PERSIST);
        m_retreatTween.setObject(this);
        
        m_state = IDLE;
        m_postChargeState = IDLE;
        m_hurtTempState = IDLE;
        
        m_target = null;
        m_targetPoints = new Array<FlxPoint>();
        m_attackFinishers = new Array < Void->Void > ();
        m_attackDamages = new IntHash<Int>();
        m_hurtTimer = 0.0;
    }
    
    public function setGraphic(path: String, frameWidth: Int, frameHeight: Int): Void {
        loadGraphic(path, true, true, frameWidth, frameHeight);
        addAnimation("idle", [0, 1, 2, 1], 8);
        addAnimation("run", [8, 1, 9, 1]);
        addAnimation("attack", [10, 1, 11, 1, 10, 1, 11, 1]);
        addAnimation("junction", [16, 1, 17, 1]);
    }
    
    public function initialize(): Void {
        play("idle");
    }
    
    public function addDamage(id: Int, damage: Int): Void {
        m_attackDamages.set(id, damage);
    }
    
    public function getDamage(id: Int): Int {
        var ret: Int = -1;
        if (m_attackDamages.exists(id)) {
            ret = m_attackDamages.get(id);
            m_attackDamages.remove(id);
        }
        
        return ret;
    }
    
    public function attack(point: FlxPoint, finish: Void->Void = null): Void {
        m_targetPoints.push(point);
        m_attackFinishers.push(finish);
        
        m_postChargeState = ATTACK;
    }
    
    public function link(point: FlxPoint): Void {
        m_targetPoints.push(point);
        m_attackFinishers.push(null);
        
        m_postChargeState = LINK;
    }
    
    public function unlink(): Void {
        retreat();
        m_state = RETREAT;
    }
    
    public function damage(): Void {
        // Pause tweens
        m_chargeTween.active = false;
        m_retreatTween.active = false;
        m_hurtTimer = 0.0;
        
        // Make sure we don't stack hurt states, or else we'll end up in a loop!
        if (m_state != HURT) {
            m_hurtTempState = m_state;
        }
        
        m_state = HURT;
    }
    
    override public function update():Void {
        super.update();
        
        switch (m_state) {
            case IDLE:    m_state = idleState();
            case CHARGE:  m_state = chargeState();
            case ATTACK:  m_state = attackState();
            case LINK:    m_state = linkState();
            case RETREAT: m_state = retreatState();
            case HURT:    m_state = hurtState();
        }
    }
    
    function charge(point: FlxPoint): Void {
        m_chargeTween.setMotion(standingPoint.x, standingPoint.y, point.x, point.y, CHARGE_TIME, Ease.quadIn);
        addTween(m_chargeTween, true);
        play("run");
    }
    
    function retreat(): Void {
        m_retreatTween.setMotion(x, y, standingPoint.x, standingPoint.y, CHARGE_TIME, Ease.quadIn);
        addTween(m_retreatTween, true);
    }
    
    function idleState(): FighterSpriteState {
        if (m_targetPoints.length > 0) {
            m_target = m_targetPoints.shift();
            m_attackFinish = m_attackFinishers.shift();
            
            charge(m_target);
            
            return CHARGE;
        }
        
        return IDLE;
    }
    
    function chargeState(): FighterSpriteState {
        return CHARGE;
    }
    
    function attackState(): FighterSpriteState {
        if (finished) {
            play("run");
            retreat();
            
            // Run post-attack callback.  This is when the numbers pop up.
            if (m_attackFinish != null) {
                m_attackFinish();
            }
            m_attackFinish = null;
            
            return RETREAT;
        }
        
        return ATTACK;
    }
    
    function linkState(): FighterSpriteState {
        return LINK;
    }
    
    function retreatState(): FighterSpriteState {
        return RETREAT;
    }
    
    function hurtState(): FighterSpriteState {
        color = 0xFFFF0000;
        m_hurtTimer += FlxG.elapsed;
        if (m_hurtTimer > HURT_TIME) {
            m_chargeTween.active = true;
            m_retreatTween.active = true;
            
            if (m_hurtTempState == LINK) {
                m_hurtTempState = IDLE;
                retreat();
            }
            
            color = 0xFFFFFFFF;
            return m_hurtTempState;
        }
        
        return HURT;
    }
    
    function onChargeFinish(): Void {
        removeTween(m_chargeTween);
        if (m_postChargeState == ATTACK) {
            play("attack");
        }
        
        m_state = m_postChargeState;
    }
    
    function onRetreatFinish(): Void {
        removeTween(m_retreatTween);
        x = standingPoint.x;
        y = standingPoint.y;
        play("idle");
        
        m_state = IDLE;
    }
}
