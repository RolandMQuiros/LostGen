package ;
import lostgen.Battle;
import lostgen.BattleFormation;
import lostgen.Combatant;
import lostgen.Dungeon;
import lostgen.Fighter;
import lostgen.Pawn;
import lostgen.fighter.enemy.BasicEnemyFighter;
import lostgen.fighter.PlayerFighter;
import lostgen.view.BattleViewController;
import lostgen.view.MapView;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;

/**
 * ...
 * @author Roland M. Quiros
 */

class BattleViewTestState extends FlxState {
    var m_battle: Battle;
    var m_view: BattleViewController;
    var m_playerCombatant: Combatant;
    var m_enemyCombatant: Combatant;
    
    var m_mapView: MapView;
    
    override public function create():Void {
        super.create();
        FlxG.bgColor = FlxG.WHITE;
        FlxG.mouse.show();
        
        m_battle = new Battle();
        m_view = new BattleViewController(m_battle);
        add(m_view);
        
        //FlxG.addCamera(m_view.camera);
        
        var dummy: Dungeon = new Dungeon();
        var fighter: PlayerFighter;
        var fighters: Array<PlayerFighter> = new Array<PlayerFighter>();
        var combatant: Combatant = new Combatant(dummy, 0, 0);
        for (i in 0...4) {
            fighter = new PlayerFighter("playa");
            fighter.stats.maxHealth = 10;
            fighter.stats.health = 10;
            fighter.stats.agility = 5;
            fighter.stats.attack = 2;
            fighter.stats.magic = 6;
            fighter.team.bits = 1;
            fighter.position.x = 0;
            fighter.position.y = 0;
            fighter.team.bits = 1;
            fighters.push(fighter);
        }
        combatant.setFighter(fighters[0], BattleFormation.FRONT_LEFT);
        combatant.setFighter(fighters[1], BattleFormation.FRONT_RIGHT);
        combatant.setFighter(fighters[2], BattleFormation.BACK_RIGHT);
        combatant.setFighter(fighters[3], BattleFormation.BACK_LEFT);
        m_playerCombatant = combatant;
        m_playerCombatant.direction = Pawn.EAST;
        
        var enemy: Fighter;
        var enemies: Array<Fighter> = new Array<Fighter>();
        var enemyCombatant: Combatant = new Combatant(dummy, 1, 0);
        for (i in 0...4) {
            enemy = new BasicEnemyFighter("bads");
            enemy.stats.maxHealth = 10;
            enemy.stats.health = 10;
            enemy.stats.agility = 5;
            enemy.stats.attack = 2;
            enemy.stats.magic = 2;
            enemy.team.bits = 1;
            enemy.position.x = 0;
            enemy.position.y = 0;
            enemy.team.bits = 2;
            enemies.push(enemy);
        }
        enemyCombatant.setFighter(enemies[0], BattleFormation.FRONT_LEFT);
        enemyCombatant.setFighter(enemies[1], BattleFormation.FRONT_RIGHT);
        enemyCombatant.setFighter(enemies[2], BattleFormation.BACK_RIGHT);
        enemyCombatant.setFighter(enemies[3], BattleFormation.BACK_LEFT);
        m_enemyCombatant = enemyCombatant;
        
        m_battle.addCombatant(combatant);
        m_battle.addCombatant(enemyCombatant);
        
        
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
    
    override public function update():Void {
        super.update();
        
        // Camera control
        var horz: Int = (FlxG.keys.RIGHT ? 1 : 0) - (FlxG.keys.LEFT ? 1 : 0);
        var vert: Int = (FlxG.keys.DOWN ? 1 : 0) - (FlxG.keys.UP ? 1 : 0);
        FlxG.camera.scroll.x += horz * 100.0 * FlxG.elapsed;
        FlxG.camera.scroll.y += vert * 100.0 * FlxG.elapsed;
        
        var nums: Array<String> = ["ONE", "TWO", "THREE", "FOUR"];
        var target: Int = 0;
        for (n in nums) {
            if (FlxG.keys.justPressed(n)) {
                var playerFighter: PlayerFighter = cast(m_playerCombatant.fighters[target], PlayerFighter);
                playerFighter.target = m_enemyCombatant.fighters[target];
            }
            target++;
        }
        
        if (FlxG.keys.justPressed("SPACE")) {
            m_battle.step();
        }
    }
}