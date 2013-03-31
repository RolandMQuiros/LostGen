package lostgen.fighter;
import lostgen.Battle;
import lostgen.Fighter;

/**
 * ...
 * @author Roland M. Quiros
 */

class PlayerFighter extends Fighter {
    public var target: Fighter;
    
    public function new(name: String) {
        super(name);
    }
    
    override public function step(battle:Battle):Bool {
        if (target == null) {
            return false;
        }
        
        // Link to friendly targets
        if (team.isFriendly(target.team)) {
            if (linkCount() == 0) {
                link(target);
            } else {
                support(target);
            }
        } else {
            attack(target);
        }
        target = null;
        
        return true;
    }
}