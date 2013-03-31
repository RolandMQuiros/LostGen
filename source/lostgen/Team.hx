package lostgen;

/**
 * ...
 * @author Roland M. Quiros
 */

class Team {
    /** Bit signature of this team */
    public var bits: Int;
    /** Bit signatures of allied teams */
    public var friendlyBits: Int;
    
    public function new() { }
    
    public function isFriendly(other: Team): Bool {
        return other != null &&
               (bits == other.bits) ||
               (other.bits & friendlyBits != 0);
    }
    
    public function is(other: Team): Bool {
        return other != null && bits == other.bits;
    }
}