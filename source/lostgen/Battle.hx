package lostgen;
import hxs.core.Info;
import hxs.Signal;
import hxs.Signal1;
import hxs.Signal2;
import hxs.Signal3;
import hxs.Signal4;

/**
 * ...
 * @author Roland M. Quiros
 */
enum BattleSlot {
    CENTER;
    FRONT;
    RIGHT;
    BACK;
    LEFT;
}

class Battle {
    static var ms_counter: Int = 0;
    
    public var sigCombatantJoined(default, null): Signal1<Combatant>;
    public var sigFighterAdded(default, null): Signal1<Fighter>;
    public var sigFighterTurn(default, null): Signal1<Fighter>;
    public var sigFighterAttack(default, null): Signal3<Fighter, Fighter, Int>;
    public var sigFighterLink(default, null): Signal2<Fighter, Fighter>;
    public var sigFighterUnlink(default, null): Signal2<Fighter, Fighter>;
    public var sigFighterHit(default, null): Signal3<Fighter, Fighter, Int>;
    public var sigFighterDamaged(default, null): Signal2<Fighter, Int>;
    public var sigFighterHealed(default, null): Signal2<Fighter, Int>;
    public var sigFighterSupport(default, null): Signal4<Fighter, Fighter, SupportElement, Int>;
    public var sigFighterKilled(default, null): Signal1<Fighter>;
    public var sigFighterRevived(default, null): Signal2<Fighter, Int>;
    public var sigEnded(default, null): Signal;
    
    public var id(default, null): Int;
    public var combatants(default, null): Array<Combatant>;
    public var fighters(default, null): Array<Fighter>;
    
    var m_combatants: IntHash<Combatant>;
    var m_turnQueue: Array<Fighter>;
    var m_curFighter: Fighter;
    
    public function new() {        
        sigCombatantJoined = new Signal1<Combatant>(this);
        sigFighterAdded = new Signal1<Fighter>(this);    
        sigFighterTurn = new Signal1<Fighter>(this);
        sigFighterAttack = new Signal3<Fighter, Fighter, Int>(this);
        sigFighterLink = new Signal2<Fighter, Fighter>(this);
        sigFighterUnlink = new Signal2<Fighter, Fighter>(this);
        sigFighterHit = new Signal3<Fighter, Fighter, Int>(this);
        sigFighterDamaged = new Signal2<Fighter, Int>(this);
        sigFighterHealed = new Signal2<Fighter, Int>(this);
        sigFighterSupport = new Signal4<Fighter, Fighter, SupportElement, Int>(this);
        sigFighterKilled = new Signal1<Fighter>(this);
        sigFighterRevived = new Signal2<Fighter, Int>(this);
        sigEnded = new Signal(this);
        
        id = ms_counter++;
        combatants = new Array<Combatant>();
        fighters = new Array<Fighter>();
        m_combatants = new IntHash<Combatant>();
        m_turnQueue = new Array<Fighter>();
    }
    
    public function step(fighter: Fighter = null): Bool {
        // Check battle conditions
        if (checkEnd()) {
            sigEnded.dispatch();
            return false;
        }
        
        // Fill the turn queue and sort it by speed
        if (m_turnQueue.length == 0) {
            m_turnQueue = fighters.copy();
            if (m_turnQueue.length == 0) {
                return true;
            }
            m_turnQueue.sort(compareAgilities);
        }
        
        // Assign first fighter
        if (m_curFighter == null) {            
            m_curFighter = m_turnQueue.shift();            
            m_curFighter.preStep();
        } else if (!m_curFighter.isAlive() || m_curFighter.step(this)) {
            m_curFighter = null;
        }
        
        fighter = m_curFighter;
        
        return false;
    }
    
    public function addFighter(fighter: Fighter): Void {
        fighters.push(fighter);
        sigFighterAdded.dispatch(fighter);
        
        // Attach signals
        fighter.sigTurnStart.addAdvanced(function(info: Info) {
            sigFighterTurn.dispatch(info.signal.target);
        });
        
        fighter.sigAttack.addAdvanced(function(target: Fighter, damage: Int, info: Info) {
            sigFighterAttack.dispatch(info.signal.target, target, damage);
        });
        
        fighter.sigLink.addAdvanced(function(target: Fighter, info: Info) {
            sigFighterLink.dispatch(info.signal.target, target);
        });
        
        fighter.sigUnlink.addAdvanced(function(target: Fighter, info: Info) {
            sigFighterUnlink.dispatch(info.signal.target, target);
        });
        
        fighter.sigWasHit.addAdvanced(function(by: Fighter, damage: Int, info: Info) {
            sigFighterHit.dispatch(by, info.signal.target, damage);
        });
        
        fighter.sigDamaged.addAdvanced(function(damage: Int, info: Info) {
            sigFighterDamaged.dispatch(info.signal.target, damage);
        });
        
        fighter.sigHealed.addAdvanced(function(health: Int, info: Info) {
            sigFighterHealed.dispatch(info.signal.target, health);
        });
        
        fighter.sigSupport.addAdvanced(function(target: Fighter, element: SupportElement, amount: Int, info: Info) {
            sigFighterSupport.dispatch(info.signal.target, target, element, amount);
        });
        
        fighter.sigKilled.addAdvanced(function(info: Info) {
            sigFighterKilled.dispatch(info.signal.target);
        });
        
        fighter.sigRevived.addAdvanced(function(health: Int, info: Info) {
            sigFighterRevived.dispatch(info.signal.target, health);
        });
    }
    
    public function hasFighter(fighter: Fighter): Bool {
        for (f in fighters) {
            if (fighter == f) {
                return true;
            }
        }
        
        return false;
    }
    
    public function addCombatant(combatant: Combatant): Bool {
        if (!m_combatants.exists(combatant.id)) {
            combatants.push(combatant);
            m_combatants.set(combatant.id, combatant);
            for (f in combatant.fighters) {
                addFighter(f);
            }
            sigCombatantJoined.dispatch(combatant);
            
            return true;
        }
        
        return false;
    }
    
    function checkEnd(): Bool {
        // If there exists two opposing teams with living fighters, the
        // battle continues
        if (combatants.length == 0) {
            return true;
        }
        
        var opposition: Bool = true;
        
        for (c in combatants) {
            for (o in combatants) {
                if (c.isAlive() && o.isAlive() && !c.team.isFriendly(o.team)) {
                    opposition = false;
                    break;
                }
            }
        }
        
        return opposition;
    }
    
    function compareAgilities(a: Fighter, b: Fighter): Int {
        if (a.stats.agility < b.stats.agility) { return -1; } 
        else if (a.stats.agility == b.stats.agility) { return 0; }
        return 1;
    }   
}