package lostgen;

import de.polygonal.ds.Hashable;
import de.polygonal.ds.HashKey;
import org.flixel.FlxBasic;

/**
 * Base class for anything in the DungeonState.
 * An Entity is a thing that's updated once every turn, such as enemies, the
 * player, a battle sequence, etc.
 * <p>
 * The DungeonState works in a loose MVC-type pattern, where changes in the
 * Model are buffered by changes in the view.  For example, damage isn't
 * calculated until the attack animation is over.
 * <p>
 * Entities consist of three virtual methods: <code>preStep()</code>,
 * <code>step()</code>, and <code>postStep()</code>. <code>pre</code> and
 * <code>postStep()</code> handle <code>preStep()</code> should contain
 * the actual changes to the Model, whereas <code>step()</code> contains
 * changes to the View.
 * <p>
 * <code>step()</code> is called continuously until it returns true, so
 * we can manage the animation states from there.
 * 
 * @author Roland M. Quiros
 * @see DungeonState
 */
class Entity implements Hashable {
    static var ms_counter: Int = 0;
    
    /** This entity's unique ID number */
    public var id(default, null): Int;
    /** Whether or not this Entity's step methods are called.  A false value
        typically means this Entity died */
    public var isActive:Bool;
    /** Tells the DungeonState to remove this Entity once its steps are
        finished. */
    public var removeMe:Bool;
    /** Position in the dungeon grid.  This is measured in tiles, not
        pixels! */
    public var position(default, null):Point;
    /** X-position in dungeon grid.  Refers back to position.x */
    public var x (getX, setX):Int;
    /** Y-position in dungeon grid.  Refers back to position.y */
    public var y (getY, setY):Int;
    /** Hash key. */
    public var key:Int;
    
    
    /**
     * Creates a new Entity.
     * This just sets the variables to some default values.
     * @param x x-position
     * @param y y-position
     */
    public function new(x:Int = 0, y:Int = 0) {
        id = ms_counter++;
        
        isActive = true;
        removeMe = false;
        position = new Point(x, y);
        
        key = HashKey.next();
    }
    
    public function initialize(): Void { }
    
    /**
     * Readies this Entity for the garbage collector.
     * Override this to null out any references this might have.
     */
    public function dispose():Void { }
    
    public function preStep(): Void { }
    public function step(): Bool { return false; }
    public function postStep(): Void { }

    function getX():Int {
        return position.x;
    }
    
    function setX(nx:Int):Int {
        position.x = nx;
        return position.x;
    }
    
    function getY():Int {
        return position.y;
    }
    
    function setY(ny:Int):Int {
        position.y = ny;
        return position.y;
    }
}