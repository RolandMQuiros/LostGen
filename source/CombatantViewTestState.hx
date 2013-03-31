package ;
import hxs.Signal2;
import lostgen.BattleFormation;
import lostgen.Fighter;
import lostgen.Point;
import lostgen.view.CombatantView;
import lostgen.view.MapView;
import org.flixel.FlxG;
import org.flixel.FlxState;

/**
 * ...
 * @author Roland M. Quiros
 */

class CombatantViewTestState extends FlxState {
    var m_point: Point;
    var m_combatant: CombatantView;
    var m_move: Signal2<Point, Point>;
    var m_mapView: MapView;
    
    override public function create():Void {
        super.create();
        
        m_point = new Point();
        m_combatant = new CombatantView();
        m_move = new Signal2<Point, Point>(this);
        
        m_move.add(m_combatant.onMoved);
        
        var fighter: Fighter = new Fighter("mans1");
        fighter.formation = BattleFormation.FRONT_LEFT;
        fighter.stats.health = fighter.stats.maxHealth = 10;
        m_combatant.setFighter(fighter);
        
        fighter = new Fighter("mans2");
        fighter.formation = BattleFormation.FRONT_RIGHT;
        fighter.stats.health = fighter.stats.maxHealth = 10;
        m_combatant.setFighter(fighter);
        
        fighter = new Fighter("mans3");
        fighter.formation = BattleFormation.BACK_RIGHT;
        fighter.stats.health = fighter.stats.maxHealth = 10;
        m_combatant.setFighter(fighter);
        
        fighter = new Fighter("mans4");
        fighter.formation = BattleFormation.BACK_LEFT;
        fighter.stats.health = fighter.stats.maxHealth = 10;
        m_combatant.setFighter(fighter);
        
        add(m_combatant);
        
        var map: Array<Int> = [
            0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
        ];
        
        m_mapView = new MapView();
        m_mapView.create(map, 20);
        
        add(m_mapView);
    }
    
    override public function update(): Void {
        super.update();
        
        var from: Point = m_point.clone();
        if (FlxG.keys.justPressed("UP")) {
            m_point.y--;
            m_move.dispatch(from, m_point);
        } else if (FlxG.keys.justPressed("DOWN")) {
            m_point.y++;
            m_move.dispatch(from, m_point);
        } else if (FlxG.keys.justPressed("LEFT")) {
            m_point.x--;
            m_move.dispatch(from, m_point);
        } else if (FlxG.keys.justPressed("RIGHT")) {
            m_point.x++;
            m_move.dispatch(from, m_point);
        }
        
        if (FlxG.keys.justPressed("ONE")) {
            m_combatant.onsigFighterKilled(BattleFormation.FRONT_LEFT);
        }
        if (FlxG.keys.justPressed("TWO")) {
            m_combatant.onsigFighterKilled(BattleFormation.FRONT_RIGHT);
        }
        if (FlxG.keys.justPressed("THREE")) {
            m_combatant.onsigFighterKilled(BattleFormation.BACK_RIGHT);
        }
        if (FlxG.keys.justPressed("FOUR")) {
            m_combatant.onsigFighterKilled(BattleFormation.BACK_LEFT);
        }
    }
}