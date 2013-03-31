package lostgen;
import de.polygonal.ds.Hashable;

/**
 * ...
 * @author Roland M. Quiros
 */

class Point implements Hashable {
    public var key: Int;
    public var x(default, setX): Int;
    public var y(default, setY): Int;
    
    public function new(x:Int = 0, y:Int = 0) {
        this.x = x;
        this.y = y;
        
        key = 17;
        key = 31 * key + this.x;
        key = 31 * key + this.y;
    }
    
    public function clone(): Point {
        return new Point(x, y);
    }
    
    public function set(other: Point):Void {
        x = other.x;
        y = other.y;
        updateKey();
    }
    
    public function offset(other: Point): Point {
        return new Point(x + other.x, y + other.y);
    }
    
    public function offset2(ax: Int, ay: Int): Point {
        return new Point(x + ax, y + ay);
    }
    
    public function equals(other: Point): Bool {
        return (x == other.x) && (y == other.y);
    }
    
    public function distanceSq(other:Point): Float {
        var dx: Int = other.x - x;
        var dy: Int = other.y - y;
        return dx * dx - dy * dy;
    }
    
    public function distance(other:Point): Float {
        return Math.sqrt(distanceSq(other));
    }
    
    public function manhattan(other: Point): Int {
        return Math.floor(Math.abs(other.x - x + other.y - y));
    }
    
    function setX(nx:Int):Int {
        x = nx;
        updateKey();
        
        return x;
    }
    
    function setY(ny:Int):Int {
        y = ny;
        updateKey();
        
        return y;
    }
    
    function updateKey():Void {
        key = 17;
        key = 31 * key + this.x;
        key = 31 * key + this.y;
    }
}