package lostgen.view;
import lostgen.BattleFormation;
import lostgen.Combatant;
import lostgen.Fighter;
import lostgen.Point;
import lostgen.Pawn;
import org.flixel.FlxGroup;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Roland M. Quiros
 */

class CombatantView extends FlxGroup {
    public static inline var TILE_WIDTH: Int = 32;
    public static inline var TILE_HEIGHT: Int = 32;
    
    public var tileWidth(getTileWidth, setTileWidth): Int;
    public var tileHeight(getTileHeight, setTileHeight): Int;
    public var position(default, null): FlxPoint;
    
    var m_tileWidth: Int;
    var m_tileHeight: Int;
    
    var m_offsetsX: Array<Int>;
    var m_offsetsY: Array<Int>;
    
    var m_combatant: Combatant;
    var m_fighterSprites: Array<FlxSprite>;
    var m_fighterPoints: Array<FlxPoint>;
    var m_fighterAlive: Array<Bool>;
    var m_fighterRoot: Int;
    
    public function new() {
        super();
        
        tileWidth = TILE_WIDTH;
        tileHeight = TILE_HEIGHT;
        position = new FlxPoint();
        
        m_fighterSprites = new Array<FlxSprite>();
        m_fighterPoints = new Array<FlxPoint>();
        m_fighterAlive = new Array<Bool>();
    }
    
    public function attach(combatant: Combatant): Void {
        if (combatant == null) {
            throw "Combatant being attached is null!  That's stupid!  You're stupid!";
        }
        
        m_combatant = combatant;
        m_combatant.sigMoved.add(onMoved);
        m_combatant.sigDirectionChange.add(onDirectionChange);
        m_combatant.sigFighterSet.add(setFighter);
        m_combatant.sigFighterKilled.add(onsigFighterKilled);
        m_combatant.sigFighterRevived.add(onsigFighterRevived);
        
        for (f in m_combatant.fighters) {
            setFighter(f);
            if (!f.isAlive()) {
                onsigFighterKilled(f);
            }
        }
    }
    
    public function setFighter(fighter: Fighter): Void {
        // Get sprite from database
        var sprite: FlxSprite = new FlxSprite();
        
        sprite.loadGraphic("assets/sprites/sprCombatantTest.png", true, false, 16, 16);
        sprite.addAnimation("south", [0, 1], 4);
        sprite.addAnimation("east",  [2, 3], 4);
        sprite.addAnimation("north", [4, 5], 4);
        sprite.addAnimation("west",  [6, 7], 4);
        sprite.addAnimation("dead",  [8, 9], 1);
        sprite.solid = false;
        
        var index: Int = Type.enumIndex(fighter.formation);
        m_fighterSprites[index] = sprite;
        m_fighterPoints[index] = new FlxPoint();
        m_fighterAlive[index] = fighter.isAlive();
        add(sprite);
    }
    
    public function onsigFighterKilled(fighter: Fighter): Void {
        var index: Int = Type.enumIndex(fighter.formation);
        m_fighterAlive[index] = false;
    }
    
    public function onsigFighterRevived(fighter: Fighter): Void {
        var index: Int = Type.enumIndex(fighter.formation);
        m_fighterAlive[index] = true;
    }
    
    public function onDirectionChange(from: Int, to: Int): Void {
        switch (to) {
            case Pawn.NORTH: m_fighterRoot = 0;
            case Pawn.EAST : m_fighterRoot = 1;
            case Pawn.SOUTH: m_fighterRoot = 2;
            case Pawn.WEST : m_fighterRoot = 3;
        }
    }
    
    public function onMoved(from: Point, to: Point): Void {
        position.x = (to.x * tileWidth) + (tileWidth / 2.0);
        position.y = (to.y * tileHeight) + (tileHeight / 2.0);
        
        var dx: Float = to.x - from.x;
        var dy: Float = to.y - from.y;
        var animation: String = "south";
        
        if (dx > 0) {
            animation = "east";
        } else if (dx < 0) {
            animation = "west";
        } else if (dy < 0) {
            animation = "north";
        }
        
        for (i in 0...m_fighterPoints.length) {            
            var sprite: FlxSprite = m_fighterSprites[i];
            
            var idx: Int = (m_fighterRoot + i) % Pawn.DIRECTIONCOUNT;
            m_fighterPoints[i].x = position.x + m_offsetsX[idx] - (sprite.width / 2.0);
            m_fighterPoints[i].y = position.y + m_offsetsY[idx] - (sprite.height / 2.0);
            
            if (!m_fighterAlive[i]) {
                sprite.play("dead");
            } else {
                sprite.play(animation);
            }
        }
    }
    
    override public function update(): Void {
        super.update();
        
        if (m_fighterPoints.length != m_fighterSprites.length) {
            throw "Mismatch in number of fighter sprites and fighter sprite destinations.  Crazy.";
        }
        
        for (i in 0...m_fighterSprites.length) {
            var sprite: FlxSprite = m_fighterSprites[i];
            var point: FlxPoint = m_fighterPoints[i];
            sprite.velocity.x = (point.x - sprite.x) * 5;
            sprite.velocity.y = (point.y - sprite.y) * 5;
        }
    }
    
    function getTileWidth(): Int {
        return m_tileWidth;
    }
    
    function setTileWidth(tw: Int): Int {
        m_tileWidth = tw;
        
        var ox: Int = Math.floor(m_tileWidth / 4);
        m_offsetsX = [ -ox, ox, ox, -ox];
        
        return m_tileWidth;
    }
    
    function getTileHeight(): Int {
        return m_tileHeight;
    }
    
    function setTileHeight(th: Int): Int {
        m_tileHeight = th;
        
        var oy: Int = Math.floor(m_tileHeight / 4);
        m_offsetsY = [ -oy, -oy, oy, oy];
        
        return m_tileHeight;
    }
}
