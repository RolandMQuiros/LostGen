package lostgen.pawn;
import lostgen.Combatant;
import lostgen.Dungeon;
import lostgen.Pawn;
import org.flixel.FlxG;

/**
 * ...
 * @author Roland M. Quiros
 */

class PlayerCombatant extends Combatant {
    var m_lockDirection: Bool;
    var m_moveDirection: Int;
    var m_willMove: Bool;
    
    public function new(dungeon: Dungeon, x: Int, y:Int, direction: Int = Pawn.SOUTH) {
        super(dungeon, x, y, direction);
        
        m_lockDirection = false;
        m_moveDirection = -1;
        m_willMove = false;
    }
    
    public function onPlayerMove(direction: Int, lock: Bool = false): Void {
        if (direction >= 0 && direction < Pawn.DIRECTIONCOUNT) {
            m_lockDirection = lock;
            m_moveDirection = direction;
            m_willMove = true;
        }
    }
    
    override public function step():Bool {
        if (super.step()) {
            return true;
        }
        
        if (!m_willMove) {
            return false;
        }
        
        var moved: Bool = false;
        
        if (m_lockDirection) {
            switch (m_moveDirection) {
                case Pawn.NORTH: moved = move(0, -1);
                case Pawn.SOUTH: moved = move(0, 1);
                case Pawn.EAST:  moved = move(1, 0);
                case Pawn.WEST:  moved = move(-1, 0);
            }
        } else {
            switch (m_moveDirection) {
                case Pawn.NORTH: moved = moveNorth();
                case Pawn.SOUTH: moved = moveSouth();
                case Pawn.EAST:  moved = moveEast();
                case Pawn.WEST:  moved = moveWest();
            }
        }
        m_willMove = false;
       
        return moved;
    }
    
}