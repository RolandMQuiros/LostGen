package lostgen.pawn;
import lostgen.Combatant;
import lostgen.Dungeon;
import lostgen.Entity;
import lostgen.Pawn;
import lostgen.Point;
import nme.Vector;

/**
 * ...
 * @author Roland M. Quiros
 */

class HunterCombatant extends Combatant {
    static inline var PATH_RECALC_TURNS: Int = 10;
    var m_targetPoint: Point;
    var m_pathTurns: Int;
    var m_path: Array<Point>;
    
    public function new(dungeon: Dungeon, x: Int, y:Int, direction: Int = Pawn.SOUTH) {
        super(dungeon, x, y, direction);
        m_pathTurns = 0;
    }
    
    public function onChangeTarget(target: Point): Void {
        m_targetPoint = target;
    }
    
    override public function preStep():Void {
        super.preStep();
        
        m_pathTurns--;
        if (m_targetPoint != null && m_pathTurns <= 0) {
            m_path = m_dungeon.getPath(position, m_targetPoint);
            m_pathTurns = PATH_RECALC_TURNS;
        }
    }
    
    override public function step():Bool {
        if (m_targetPoint == null || m_path == null || m_path.length == 0 || super.step()) {
            return true;
        }
        
        var point: Point = m_path[m_path.length - 1];
        point.x -= x;
        point.y -= y;
        
        var moved: Bool = false;
        if (point.x > 0) {
            direction = Pawn.EAST;
        } else if (point.x < 0) {
            direction = Pawn.WEST;
        } else if (point.y < 0) {
            direction = Pawn.NORTH;
        } else {
            direction = Pawn.SOUTH;
        }
        
        if (position.equals(point) || move(point.x, point.y)) {
            m_path.pop();
        }
        
        return true;
    }
}