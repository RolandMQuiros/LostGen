package lostgen;

/**
 * ...
 * @author Roland M. Quiros
 */

class FighterStats {
    public var health : Int;
    public var maxHealth: Int;
    public var mana   : Int;
    public var maxMana: Int;
    public var attack : Int;
    public var defense: Int;
    public var magic  : Int;
    public var magDef : Int;
    public var agility: Int;
    
    var m_affinities: Array<Affinity>;

    public function new(other: FighterStats = null) {
        m_affinities = new Array<Affinity>();
        if (other == null) {
            for (i in 0...Type.enumIndex(Element.COUNT)) {
                m_affinities.push(Affinity.NONE);
            }
        } else {
            health  = other.health;
            maxHealth = other.maxHealth;
            mana    = other.mana;
            maxMana = other.maxMana;
            attack  = other.attack;
            defense = other.defense;
            magic   = other.magic;
            magDef  = other.magDef;
            agility = other.agility;
            
            for (a in other.m_affinities) {
                m_affinities.push(a);
            }
        }
    }
    
    public function copy(other: FighterStats) {
        health  = other.health;
        maxHealth = other.maxHealth;
        mana    = other.mana;
        maxMana = other.maxMana;
        attack  = other.attack;
        defense = other.defense;
        magic   = other.magic;
        magDef  = other.magDef;
        agility = other.agility;
        
        for (i in 0...other.m_affinities.length) {
            m_affinities[i] = other.m_affinities[i];
        }
    }
    
    public function getAffinity(element: Element): Affinity {
        return m_affinities[Type.enumIndex(element)];
    }
}