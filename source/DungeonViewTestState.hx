package ;
import hxs.Signal2;
import lostgen.Battle;
import lostgen.BattleFormation;
import lostgen.Combatant;
import lostgen.Dungeon;
import lostgen.Entity;
import lostgen.Fighter;
import lostgen.Pawn;
import lostgen.fighter.enemy.BasicEnemyFighter;
import lostgen.fighter.PlayerFighter;
import lostgen.pawn.HunterCombatant;
import lostgen.pawn.PlayerCombatant;
import lostgen.Point;
import lostgen.view.BattleViewController;
import lostgen.view.CombatantView;
import lostgen.view.MapView;
import org.flixel.FlxGroup;
import org.flixel.FlxState;
import org.flixel.FlxG;

/**
 * ...
 * @author Roland M. Quiros
 */

class DungeonViewTestState extends FlxState {
    static inline var INPUT_DELAY: Float = 0.125;
    
    var m_dungeon: Dungeon;
    var m_mapView: MapView;
    var m_battleView: BattleViewController;
    var m_combatantViews: FlxGroup;
    
    var m_player: Combatant;
    
    var m_sigPlayerInput: Signal2<Int, Bool>;
    var m_inputDelayCounter: Float;
    
    override public function create():Void {
        super.create();
        FlxG.mouse.show();
        
        m_dungeon = new Dungeon();
        m_mapView = new MapView();
        m_combatantViews = new FlxGroup();
        
        m_sigPlayerInput = new Signal2<Int, Bool>(this);
        m_inputDelayCounter = 0.0;
        
        // Dungeon layers
        add(m_mapView);
        add(m_combatantViews);
        
        setup();
    }
    
    function setup(): Void {
        m_mapView.create(m_dungeon.grid, m_dungeon.width);
        
        // Test entities
        m_player = testPlayerCombatant();
        m_player.x = 2;
        m_player.y = 13;
        m_dungeon.addEntity(m_player);
        
        var playerView: CombatantView = new CombatantView();
        playerView.attach(m_player);
        m_combatantViews.add(playerView);
        
        var enemy: Combatant = testEnemyCombatant();
        enemy.x = 14;
        enemy.y = 13;
        m_dungeon.addEntity(enemy);
        
        var enemyView: CombatantView = new CombatantView();
        enemyView.attach(enemy);
        m_combatantViews.add(enemyView);
    }
    
    function createBattleView(battle: Battle): Void {
        if (m_battleView == null) {
            m_battleView = new BattleViewController(battle);
            
            FlxG.addCamera(m_battleView.camera);
            add(m_battleView);
        }
    }
    
    function testPlayerCombatant(): Combatant {
        var combatant: PlayerCombatant = new PlayerCombatant(m_dungeon, 0, 0);
        m_sigPlayerInput.add(combatant.onPlayerMove);
        combatant.sigBattleJoined.add(createBattleView);
        combatant.team.bits = 1;
        
        var fighter: PlayerFighter;
        var fighters: Array<PlayerFighter> = new Array<PlayerFighter>();
        for (i in 0...4) {
            fighter = new PlayerFighter("playa" + i);
            fighter.stats.maxHealth = 10;
            fighter.stats.health = 10;
            fighter.stats.agility = 5;
            fighter.stats.attack = 2;
            fighter.stats.magic = 6;
            fighter.team.bits = 1;
            fighter.position.x = 0;
            fighter.position.y = 0;
            fighters.push(fighter);
        }
        combatant.setFighter(fighters[0], BattleFormation.FRONT_LEFT);
        combatant.setFighter(fighters[1], BattleFormation.FRONT_RIGHT);
        combatant.setFighter(fighters[2], BattleFormation.BACK_RIGHT);
        combatant.setFighter(fighters[3], BattleFormation.BACK_LEFT);
        
        return combatant;
    }
    
    function testEnemyCombatant(): Combatant {
        var enemyCombatant: HunterCombatant = new HunterCombatant(m_dungeon, 0, 0);
        m_player.sigMoved.add(function(from: Point, to: Point): Void {
            enemyCombatant.onChangeTarget(to);
        });
        enemyCombatant.team.bits = 2;
        
        var enemy: Fighter;
        var enemies: Array<Fighter> = new Array<Fighter>();
        for (i in 0...4) {
            enemy = new BasicEnemyFighter("bads" + i);
            enemy.stats.maxHealth = 10;
            enemy.stats.health = 10;
            enemy.stats.agility = 5;
            enemy.stats.attack = 2;
            enemy.stats.magic = 2;
            enemy.team.bits = 1;
            enemy.position.x = 0;
            enemy.position.y = 0;
            enemies.push(enemy);
        }
        enemyCombatant.setFighter(enemies[0], BattleFormation.FRONT_LEFT);
        enemyCombatant.setFighter(enemies[1], BattleFormation.FRONT_RIGHT);
        enemyCombatant.setFighter(enemies[2], BattleFormation.BACK_RIGHT);
        enemyCombatant.setFighter(enemies[3], BattleFormation.BACK_LEFT);
        
        return enemyCombatant;
    }
    
    override public function update(): Void {
        super.update();
        
        m_inputDelayCounter += FlxG.elapsed;
        if (m_inputDelayCounter > INPUT_DELAY) {
            if (FlxG.keys.UP) {
                m_sigPlayerInput.dispatch(Pawn.NORTH, FlxG.keys.SHIFT);
                m_inputDelayCounter = 0.0;
            } else if (FlxG.keys.DOWN) {
                m_sigPlayerInput.dispatch(Pawn.SOUTH, FlxG.keys.SHIFT);
                m_inputDelayCounter = 0.0;
            } else if (FlxG.keys.LEFT) {
                m_sigPlayerInput.dispatch(Pawn.WEST, FlxG.keys.SHIFT);
                m_inputDelayCounter = 0.0;
            } else if (FlxG.keys.RIGHT) {
                m_sigPlayerInput.dispatch(Pawn.EAST, FlxG.keys.SHIFT);
                m_inputDelayCounter = 0.0;
            }
        }
        
        m_dungeon.step();
        
        if (m_battleView != null) {
            m_battleView.update();
        }
    }
}