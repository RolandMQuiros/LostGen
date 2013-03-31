package lostgen.fighter.enemy;
import lostgen.Battle;
import lostgen.Fighter;

/**
 * ...
 * @author Roland M. Quiros
 */

class BasicEnemyFighter extends Fighter{
    public function new(name: String) {
        super(name);
    }
    
    override public function step(battle:Battle):Bool {
        var maxHealth: Int = -1;
        var target: Fighter = null;
        
        for (f in battle.fighters) {
            if (!team.isFriendly(f.team) && f.stats.health > maxHealth) {
                maxHealth = f.stats.health;
                target = f;
            }
        }
        
        if (target != null) {
            attack(target);
        }
        
        return true;
    }
}