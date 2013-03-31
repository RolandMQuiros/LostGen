package lostgen;

import hxs.Signal;
import hxs.Signal1;
import hxs.Signal2;
import hxs.Signal3;

/**
 * ...
 * @author Roland M. Quiros
 */

class Fighter {
    private static var ms_counter: Int = 0;
    public var id(default, null): Int;
    public var name(default, null): String;
    public var stats(default, null): FighterStats;
    public var team(default, null): Team;
    public var position(default, null): Point;
    public var formation: BattleFormation;
    
    public var sigTurnStart(default, null): Signal;
    public var sigAttack(default, null): Signal2<Fighter, Int>;
    public var sigLink(default, null): Signal1<Fighter>;
    public var sigUnlink(default, null): Signal1<Fighter>;
    public var sigWasHit(default, null): Signal2<Fighter, Int>;
    public var sigDamaged(default, null): Signal1<Int>;
    public var sigHealed(default, null): Signal1<Int>;
    public var sigSupport(default, null): Signal3<Fighter, SupportElement, Int>;
    public var sigKilled(default, null): Signal;
    public var sigRevived(default, null): Signal1<Int>;
    public var sigEscaped(default, null): Signal;
    
    public var isEngaged: Bool;
    public var isRanged: Bool;
    public var tryEscaping: Bool;
    
    var m_next: Fighter;
    var m_children: Array<Fighter>;
    var m_statusEffects: Hash<StatusEffect>;
    
    public function new(name: String) {
        id = ms_counter++;
        this.name = name;
        stats = new FighterStats();
        team = new Team();
        position = new Point();
        
        sigTurnStart = new Signal(this);
        sigAttack = new Signal2<Fighter, Int>(this);
        sigLink = new Signal1<Fighter>(this);
        sigUnlink = new Signal1<Fighter>(this);
        sigWasHit = new Signal2<Fighter, Int>(this);
        sigDamaged = new Signal1<Int>(this);
        sigHealed = new Signal1<Int>(this);
        sigSupport = new Signal3<Fighter, SupportElement, Int>(this);
        sigKilled = new Signal(this);
        sigRevived = new Signal1<Int>(this);
        sigEscaped = new Signal(this);
        
        m_children = new Array<Fighter>();
        m_statusEffects = new Hash<StatusEffect>();
    }
    
    public function preStep(): Void {
        if (isAlive()) {
            sigTurnStart.dispatch();
        }
        
        // Apply status effects
        var iter: Iterator<StatusEffect> = m_statusEffects.iterator();
        while (iter.hasNext()) {
            var effect: StatusEffect = iter.next();
            if (effect.step(this)) {
                m_statusEffects.remove(Type.getClassName(Type.getClass(effect)));
                effect.onRemove(this);
            }
        }
    }
    
    public function step(battle: Battle): Bool { return true; }
    
    public function attack(target: Fighter): Void {
        if (!target.isAlive()) {
            return;
        }
        
        // Calculate distance modifiers
        var modifier: Float = 1.0;
        /*if (!isRanged) {
            // Inversely proportional to Manhattan distance
            modifier /= position.manhattan(target.position);
        }*/
        
        // Get damage count
        var damage: Int = stats.attack;
        if (m_next == this) {
            damage += Math.floor(stats.attack / 2);
        }
        
        // Fix this calculation later
        for (f in m_children) {
            if (f != null && f.isAlive()) {
                damage += f.stats.magic;
            }
        }
        
        // Apply modifier
        damage = Math.floor(damage * modifier);
        
        // Unlink
        unlinkAll();
        
        // Notify views
        sigAttack.dispatch(target, damage);
        
        // Hit the bastard
        target.hit(this, damage);
    }
    
    public function getRoot(): Fighter {
        var root: Fighter = this;
        while (root.m_next != null && root.m_next != root ) {
            root = root.m_next;
            if (root == this) {
                break;
            }
        }
        
        return root;
    }
    
    public function link(target: Fighter): Void {
        if (team.isFriendly(target.team)) {
            // Link to root of target's tree
            var root: Fighter = target.getRoot();
            
            // Check if fighters are already linked
            var alreadyLinked: Bool = false;
            for (f in root.m_children) {
                if (this == f) {
                    alreadyLinked = true;
                    break;
                }
            }
            
            // Link the two fighters
            if (!alreadyLinked) {
                m_next = target;
                root.m_children.push(this);
                
                sigLink.dispatch(root);
            }
        }
    }
    
    public function unlink(): Void {
        if (m_next != null) {
            m_next.m_children.remove(this);
            sigUnlink.dispatch(m_next);
            m_next = null;
        }
    }
    
    public function unlinkAll(): Void {
        forEach(function(fighter: Fighter): Void {
            if (fighter.m_next != null) {
                fighter.sigUnlink.dispatch(fighter.m_next);
                fighter.m_next = null;
            }
            
            if (fighter.m_children.length > 0) {
                fighter.m_children = new Array<Fighter>();
            }
        });
    }
    
    public function forEach(func: Fighter->Void): Void {
        var explored: IntHash<Bool> = new IntHash<Bool>();
        forEachInternal(explored, func);
    }
    
    function forEachInternal(explored: IntHash<Bool>, func: Fighter->Void): Void {
        if (explored.exists(id) && explored.get(id)) {
            return;
        }
        
        // Mark this node as explored
        explored.set(id, true);
        
        // Explore children
        for (c in m_children) {
            c.forEachInternal(explored, func);
        }
        
        // Apply function
        func(this);
    }
    
    public function linkCount(): Int {
        return m_children.length;
    }
    
    public function support(target: Fighter): Void {
        if (team.isFriendly(target.team)) {
            // Temporary heal
            var healed: Int = target.heal(1);
            sigSupport.dispatch(target, SupportElement.HEAL, 1);
            
            unlinkAll();
        }
    }
    
    /**
     * Apply damage to this fighter when physically struck by an enemy
     * When hit, damage propogates to all linked allies, whether the
     * connections are incoming or outgoing.  After the hit, the entire
     * link tree is destroyed.
     * 
     * @param by the assailant
     * @param damage the amount of damage the assailant expects to inflict
     * @return the damage actually inflicted
     */
    public function hit(by: Fighter, damage: Int): Void {
        forEach(function(fighter: Fighter): Void {
            // Apply damage
            var inflicted: Int = damage - fighter.stats.defense;
            hurt(inflicted);
            /*if (inflicted > 0) {
                fighter.stats.health -= inflicted;
                fighter.wasHit.dispatch(by, inflicted);
                fighter.damaged.dispatch(inflicted);
                
                if (fighter.stats.health <= 0) {
                    fighter.stats.health = 0;
                    fighter.killed.dispatch();
                }
            }*/
            
            // Destroy all links
            if (fighter.m_next != null) {
                fighter.sigUnlink.dispatch(fighter.m_next);
                fighter.m_next = null;
            }
            
            if (fighter.m_children.length > 0) {
                fighter.m_children = new Array<Fighter>();
            }
        });
    }
    
    public function hurt(damage: Int): Void {
        if (stats.health > 0) {
            stats.health -= damage;
            sigDamaged.dispatch(damage);
            if (stats.health <= 0) {
                stats.health = 0;
                sigKilled.dispatch();
            }
        }
    }
    
    public function heal(health: Int): Int {
        var wasAlive: Bool = isAlive();
        stats.health += health;
        if (stats.health > stats.maxHealth) {
            stats.health = stats.maxHealth;
        }
        sigHealed.dispatch(health);
        
        if (isAlive() && !wasAlive) {
            sigRevived.dispatch(health);
        }
        
        return health;
    }
    
    public function isAlive(): Bool {
        return stats.health > 0;
    }
    
    public function addStatusEffect(effect: StatusEffect): Void {
        if (effect != null) {
            var className: String = Type.getClassName(Type.getClass(effect));
            if (m_statusEffects.exists(className)) {
                m_statusEffects.get(className).stack(effect);
            } else {
                m_statusEffects.set(className, effect);
                effect.onAdd(this);
            }
        }
    }
}