package lostgen;

import hxs.Signal1;
import hxs.Signal2;

/**
 * ...
 * @author Roland M. Quiros
 */
class Pawn extends Entity {
    public static inline var EAST :Int = 0;
    public static inline var SOUTH:Int = 1;
    public static inline var WEST :Int = 2;
    public static inline var NORTH:Int = 3;
    public static inline var DIRECTIONCOUNT:Int = 4;
    
    public var sigMoved: Signal2<Point, Point>;
    public var sigDirectionChange: Signal2<Int, Int>;
    
    public var direction(getDirection, setDirection):Int;
    public var solid:Bool;
    
    var m_direction: Int;
    var m_dungeon:Dungeon;
    
    public function new(dungeon:Dungeon, x:Int, y:Int, direction:Int=SOUTH) {
        super(x, y);
        sigMoved = new Signal2<Point, Point>(this);
        sigDirectionChange = new Signal2<Int, Int>(this);
        
        solid = false;
        
        m_direction = direction;
        m_dungeon = dungeon;
    }
    
    override public function dispose():Void {
        super.dispose();
        m_dungeon = null;
    }
    
    public function interact(other:Pawn):Void { }
    
    public function turnLeft():Int {
        direction = (direction - 1) % DIRECTIONCOUNT;
        return direction;
    }
    
    public function turnRight():Int {
        direction = (direction + 1) % DIRECTIONCOUNT;
        return direction;
    }
    
    function move(dx:Int, dy:Int):Bool {
        // Check if the new position has a wall
        if (m_dungeon.isWall(position.offset2(dx, dy))) {
            return false;
        }
        
        // Check for other entities in the new position
        var ents:Array<Entity> = m_dungeon.getEntities(position.offset2(dx, dy));
        for (ent in ents) {
            if (ent == this) {
                continue;
            }
            
            // Dirty casting
            if (Std.is(ent, Pawn)) {
                var other:Pawn = cast(ent, Pawn);
                other.interact(this);
                interact(other);
                
                // Can't move if we're both solid
                if (solid && other.solid) {
                    dx = dy = 0;
                }
            }
        }
        
        // Move our filthy selves
        if (dx != 0 || dy != 0) {
            var offset: Point = position.offset2(dx, dy);
            sigMoved.dispatch(position, offset); 
            return m_dungeon.moveEntity(this, position, offset);
        }
        
        return false;
    }
    
    public function moveForward():Bool {
        var dx:Int = 0;
        var dy:Int = 0;
        
        switch (direction) {
            case EAST:  dx =  1;
            case SOUTH: dy =  1;
            case WEST:  dx = -1;
            case NORTH: dy = -1;
        }
        
        return move(dx, dy);
    }
    
    public function moveBackward():Bool {
        var dx:Int = 0;
        var dy:Int = 0;
        
        switch (direction) {
            case EAST:  dx = -1;
            case SOUTH: dy = -1;
            case WEST:  dx =  1;
            case NORTH: dy =  1;
        }
        
        return move(dx, dy);
    }
    
    public function moveEast():Bool {
        direction = EAST;
        return moveForward();
    }
    
    public function moveSouth():Bool {
        direction = SOUTH;
        return moveForward();
    }
    
    public function moveWest():Bool {
        direction = WEST;
        return moveForward();
    }
    
    public function moveNorth():Bool {
        direction = NORTH;
        return moveForward();
    }
    
    public function isWallEast():Bool {
        return m_dungeon.isWall2(x + 1, y);
    }
    
    public function isWallSouth():Bool {
        return m_dungeon.isWall2(x, y + 1);
    }
    
    public function isWallWest():Bool {
        return m_dungeon.isWall2(x - 1, y);
    }
    
    public function isWallNorth():Bool {
        return m_dungeon.isWall2(x, y - 1);
    }
    
    function getDirection(): Int {
        return m_direction;
    }
    
    function setDirection(d: Int): Int {
        if (d >= 0 && d < DIRECTIONCOUNT) {
            sigDirectionChange.dispatch(m_direction, d);
            m_direction = d;
        }
        
        return m_direction;
    }
}
