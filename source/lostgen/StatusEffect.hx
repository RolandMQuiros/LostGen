package lostgen;

/**
 * ...
 * @author Roland M. Quiros
 */

class StatusEffect {
    public var duration: Int;

    public function new() {
        
    }
    
    public function stack(other: StatusEffect): Void { }
    public function onAdd(fighter: Fighter): Void { }
    public function onRemove(fighter: Fighter): Void { }
    public function step(fighter: Fighter): Bool { return true;  }
}