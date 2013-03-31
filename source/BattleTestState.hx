package ;
import lostgen.Battle;
import lostgen.Combatant;
import lostgen.Dungeon;
import lostgen.Fighter;
import lostgen.fighter.PlayerFighter;
import lostgen.Pawn;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

/**
 * ...
 * @author Roland M. Quiros
 */

class BattleTestState extends FlxState {
    var m_display: FlxText;
    var m_text: StringBuf;
    var m_textQueue: Array<String>;
    
    var m_battle: Battle;
    
    var playerCombatant: Combatant;
    var enemyCombatant: Combatant;
    
    override public function create():Void {
        m_display = new FlxText(0, 0, 640);
        add(m_display);
        
        m_text = new StringBuf();
        m_battle = new Battle();
        m_textQueue = new Array<String>();
        
        var dummyDungeon: Dungeon = new Dungeon();
        playerCombatant = new Combatant(dummyDungeon, 0, 0);
        enemyCombatant = new Combatant(dummyDungeon, 0, 1);
        
        var fighter: Fighter;
        var playerFighters: Array<Fighter> = [];
        for (i in 0...4) {
            fighter = new PlayerFighter("player " + (i + 1));
            fighter.baseStats.health = 10;
            fighter.baseStats.attack = 1;
            fighter.baseStats.magic = 1;
            fighter.baseStats.agility = 5;
            fighter.team.bits = 0x0001;
            playerFighters.push(fighter);
        }
        playerCombatant.setFighter(playerFighters[0], BattleFormation.FRONT_LEFT);
        playerCombatant.setFighter(playerFighters[1], BattleFormation.FRONT_RIGHT);
        playerCombatant.setFighter(playerFighters[2], BattleFormation.BACK_RIGHT);
        playerCombatant.setFighter(playerFighters[3], BattleFormation.BACK_LEFT);
        
        var enemyFighters: Array<Fighter> = [];
        for (i in 0...4) {
            fighter = new Fighter("enemy " + (i + 1));
            fighter.baseStats.health = 10;
            fighter.baseStats.attack = 1;
            fighter.baseStats.magic = 1;
            fighter.baseStats.agility = 5;
            fighter.team.bits = 0x0002;
            enemyFighters.push(fighter);
        }
        
        enemyCombatant.setFighter(enemyFighters[0], BattleFormation.FRONT_LEFT);
        enemyCombatant.setFighter(enemyFighters[1], BattleFormation.FRONT_RIGHT);
        enemyCombatant.setFighter(enemyFighters[2], BattleFormation.BACK_RIGHT);
        enemyCombatant.setFighter(enemyFighters[3], BattleFormation.BACK_LEFT);
        
        playerCombatant.initialize();
        enemyCombatant.initialize();
        
        for (f in playerCombatant.fighters) {
            m_battle.addFighter(f);
        }
        
        for (f in enemyCombatant.fighters) {
            m_battle.addFighter(f);
        }
        
        m_battle.sigFighterTurn.add(onsigFighterTurn);
        m_battle.sigFighterAttack.add(onFighterAttack);
        m_battle.sigFighterDamaged.add(onsigFighterDamaged);
        m_battle.sigFighterHealed.add(onsigFighterHealed);
        m_battle.sigFighterKilled.add(onsigFighterKilled);
        m_battle.sigFighterLink.add(onFighterLink);
    }
    
    override public function update():Void {
        super.update();
        
        var step: Bool = FlxG.keys.justPressed("SPACE");
        
        if (FlxG.keys.justPressed("RIGHT")) {
            playerCombatant.direction = (playerCombatant.direction + 1) % Pawn.DIRECTIONCOUNT;
            step = true;
            playerCombatant.step();
        }
        
        if (FlxG.keys.justPressed("LEFT")) {
            playerCombatant.direction = (playerCombatant.direction - 1) % Pawn.DIRECTIONCOUNT;
            step = true;
            playerCombatant.step();
        }
        
        var nums: Array<String> = ["ONE", "TWO", "THREE", "FOUR"];
        var target: Int = 0;
        for (n in nums) {
            if (FlxG.keys.justPressed(n)) {
                var playerFighter: PlayerFighter = cast(playerCombatant.fighters[target], PlayerFighter);
                playerFighter.target = enemyCombatant.fighters[target];
            }
            target++;
        }
        
        var lnums: Array<String> = ["FIVE", "SIX", "SEVEN", "EIGHT"];
        target = 0;
        for (n in lnums) {
            if (FlxG.keys.justPressed(n)) {
                var playerFighter: PlayerFighter = cast(playerCombatant.fighters[target], PlayerFighter);
                playerFighter.target = playerFighter;
            }
            target++;
        }
        
        if (step) {
            m_battle.step();
            
            m_text = new StringBuf();
            m_text.add(playerCombatant.direction + "\n");
            for (f in playerCombatant.fighters) {
                m_text.add(f.name + "(" + f.position.x + ", " + f.position.y + ")\n" +
                    "HP: " + f.stats.health + "\n");
            }
            m_text.add("\n");
            
            for (f in enemyCombatant.fighters) {
                m_text.add(f.name + "(" + f.position.x + ", " + f.position.y + ")\n" +
                    "HP: " + f.stats.health + "\n");
            }
            m_text.add("\n");
            
            for (s in m_textQueue) {
                m_text.add(s);
            }
            
            m_display.setText(m_text.toString());
        }
    }
    
    function onsigFighterTurn(fighter: Fighter): Void {
        m_textQueue.push(fighter.name + "'s turn\n");
        if (m_textQueue.length > 10) {
            m_textQueue.shift();
        }
    }
    
    function onFighterAttack(attacker: Fighter, target: Fighter, damage: Int): Void {
        m_textQueue.push("\t" + attacker.name + " attacked " + target.name + "\n");
        if (m_textQueue.length > 10) {
            m_textQueue.shift();
        }
    }
    
    function onsigFighterDamaged(fighter: Fighter, damage: Int): Void {
        m_textQueue.push("\t" + fighter.name + " took " + damage + " damage\n");
        if (m_textQueue.length > 10) {
            m_textQueue.shift();
        }
    }
    
    function onsigFighterHealed(fighter: Fighter, health: Int): Void {
        m_textQueue.push("\t" + fighter.name + " replenished " + health + " health\n");
        if (m_textQueue.length > 10) {
            m_textQueue.shift();
        }
    }
    
    function onsigFighterKilled(fighter: Fighter): Void {
        m_textQueue.push(fighter.name + " died!\n");
        if (m_textQueue.length > 10) {
            m_textQueue.shift();
        }
    }
    
    function onFighterLink(linker: Fighter, linkee: Fighter): Void {
        m_textQueue.push("\t" + linker.name + " linked with " + linkee.name + "\n");
        if (m_textQueue.length > 10) {
            m_textQueue.shift();
        }
    }
}