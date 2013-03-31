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

enum RelativePosition {
    FRONT;
    RIGHT;
    BACK;
    LEFT;
    COUNT;
}

class Combatant extends Pawn {
    public static inline var MAX_FIGHTERS: Int = 4;
    
    public var fighters (default, null): Array<Fighter>;
    public var adjacent (default, null): Array<Combatant>;
    public var team     (default, null): Team;
    public var isEngaged(default, setEngaged): Bool;
    
    public var sigBattleJoined(default, null): Signal1<Battle>;
    public var sigFighterSet(default, null): Signal1<Fighter>;
    public var sigFighterKilled(default, null): Signal1<Fighter>;
    public var sigFighterRevived(default, null): Signal1<Fighter>;
    
    var m_battle: Battle;
    var m_target: Combatant;
    var m_fighterRoot: Int;
    
    public function new(dungeon:Dungeon, x:Int, y:Int, direction:Int=Pawn.SOUTH) {
        super(dungeon, x, y, direction);
        solid = true;
        
        fighters = [ null, null, null, null ];
        adjacent = [ null, null, null, null ];
        team = new Team();
        isEngaged = false;
        
        sigBattleJoined = new Signal1<Battle>(this);
        sigFighterSet = new Signal1<Fighter>(this);
        sigFighterKilled = new Signal1<Fighter>(this);
        sigFighterRevived = new Signal1<Fighter>(this);
        
        m_fighterRoot = 0;
    }
    
    override public function initialize():Void {
        adjustFighters();
    }
    
    override public function interact(other:Pawn):Void {
        if (Std.is(other, Combatant)) {
            var otherCombatant:Combatant = cast(other, Combatant);
            
            // If interacting with an enemy
            if (!team.isFriendly(otherCombatant.team)) {
                isEngaged = true;
                
                // Join the enemy's battle, or create a new one
                if (otherCombatant.m_battle == null) {
                    m_battle = new Battle();
                } else {
                    m_battle = otherCombatant.m_battle;
                }
                m_battle.addCombatant(this);
                m_battle.sigEnded.add(function(): Void {
                    m_battle = null;
                    isEngaged = false;
                });
                
                // Notify everyone that shit just got real
                sigBattleJoined.dispatch(m_battle);
            }
        }
    }
    
    override public function step():Bool {
        if (isEngaged) {
            return true;
        }
        
        return false;
    }
    
    public function setEngaged(engaged:Bool):Bool {
        isEngaged = engaged;
        for (f in fighters) {
            if (f != null) {
                f.isEngaged = engaged;
            }
        }
        
        return isEngaged;
    }
    
    public function setFighter(fighter: Fighter, formation: BattleFormation):Void {
        fighter.formation = formation;
        fighter.team.bits = team.bits;
        fighter.team.friendlyBits = team.friendlyBits;
        
        fighters[Type.enumIndex(formation)] = fighter;
        
        fighter.sigKilled.addAdvanced(function(info: Info): Void {
            sigFighterKilled.dispatch(info.signal.target);
        });
        
        fighter.sigRevived.addAdvanced(function(health: Int, info: Info): Void {
            sigFighterRevived.dispatch(info.signal.target);
        });
        
        sigFighterSet.dispatch(fighter);
    }
    
    public function isAlive(): Bool {
        for (f in fighters) {
            if (f.isAlive()) {
                return true;
            }
        }
        
        return false;
    }
    
    public function isAdjacent(other: Combatant): Bool {
        for (c in adjacent) {
            if (other == c) {
                return true;
            }
        }
        
        return false;
    }
    
    public function getFront(): Combatant {
        return adjacent[Type.enumIndex(FRONT)];
    }
    
    public function getRight(): Combatant {
        return adjacent[Type.enumIndex(RIGHT)];
    }
    
    public function getBack(): Combatant {
        return adjacent[Type.enumIndex(BACK)];
    }
    
    public function getLeft(): Combatant {
        return adjacent[Type.enumIndex(LEFT)];
    }
    
    override private function setDirection(d: Int): Int {
        var ret: Int = super.setDirection(d);
        adjustFighters();
        
        return ret;
    }
    
    /**
     * Rotates the position of the fighters depending on the direction faced.
     * Fighters are ordered clockwise, starting from the front-left.
     */
    function adjustFighters(): Void {
        var left: Int = x * 4;
        var top : Int = y * 4;
        
        var posX: Array<Int> = [left, left + 1, left + 1, left];
        var posY: Array<Int> = [top, top, top + 1, top + 1];
        
        switch (direction) {
            case Pawn.NORTH: m_fighterRoot = 0;
            case Pawn.EAST : m_fighterRoot = 1;
            case Pawn.SOUTH: m_fighterRoot = 2;
            case Pawn.WEST : m_fighterRoot = 3;
        }
        
        for (i in 0...fighters.length) {
            if (fighters[i] != null) {
                var idx: Int = (m_fighterRoot + i) % Pawn.DIRECTIONCOUNT;
                fighters[i].position.x = posX[idx];
                fighters[i].position.y = posY[idx];
            }
        }
    }
}