package lostgen;
import de.polygonal.ds.Heapable;
import de.polygonal.ds.Heap;
import de.polygonal.ds.Itr;
import de.polygonal.ds.HashTable;

class Node implements Heapable<Node> {
    public var point(default, null):Point;
    public var position:Int;
    public var cost:Int;
    public var pathCost:Int;
    public var parent:Node;
    
    public function new(point:Point) {
        this.point = point.clone();
        cost = 0;
        pathCost = 0;
        parent = null;
    }
    
    public function compare(other:Node):Int {
        if (cost == other.cost || point.equals(other.point)) {
            return 0;
        } else if (cost < other.cost) {
            return 1;
        } else {
            return -1;
        }
    }
}

/**
 * Simple A* implementation
 * @author Roland M. Quiros
 */
class Pathfinder {
    static inline var OFFS_HORZ:Array<Int> = [ 1, 0, -1, 0];
    static inline var OFFS_VERT:Array<Int> = [ 0, 1, 0, -1];
    static inline var NUM_NEIGHBORS:Int = 4;
    
    var m_domain:Array<Int>;
    var m_domainWidth:Int;
    var m_domainHeight:Int;
    
    public function new(domain:Array<Int>, domainWidth:Int) {
        m_domain = domain;
        m_domainWidth = domainWidth;
        m_domainHeight = Std.int(m_domain.length / m_domainWidth);
    }
    
    public function destroy():Void {
        m_domain = null;
    }
    
    public function createPath(start:Point, end:Point):Array<Point> {
        if (!inBounds(start) || !inBounds(end)) {
            return null;
        }
        
        var open:Heap<Node> = new Heap<Node>();
        var closed:HashTable<Point, Node> = new HashTable<Point, Node>(32);
        
        var startNode:Node = new Node(start);
        open.add(startNode);
        
        while (!open.isEmpty() && !end.equals(open.top().point)) {
            var current:Node = open.pop();
            closed.set(current.point, current);
            
            var neighbors:Array<Point> = getNeighbors(current.point);
            
            for (n in neighbors) {
                var neighbor:Node = new Node(n);
                neighbor.parent = current;
                neighbor.pathCost = pathCost(neighbor);
                
                var closedNode:Node = closed.get(n);
                var inClosed:Bool = (closedNode != null);
                if (inClosed) {
                    continue;
                }
                
                var inOpen:Bool = false;
                var openIter:Itr<Node> = open.iterator();
                var openNode:Node = null;
                while (openIter.hasNext()) {
                    openNode = openIter.next();
                    if (openNode.point.equals(n)) {
                        inOpen = true;
                        break;
                    }
                }
                
                if (inOpen && neighbor.pathCost < openNode.pathCost) {
                    open.remove(openNode);
                    inOpen = false;
                }
                
                if (inClosed && neighbor.pathCost < closedNode.pathCost) {
                    closed.remove(closedNode);
                    inClosed = false;
                }
                
                if (!inOpen && !inClosed) {
                    neighbor.cost = neighbor.pathCost + heuristic(n, end);
                    open.add(neighbor);
                }
            }
        }
        
        if (open.isEmpty()) {
            return null;    
        }
        
        var pathNode:Node = open.pop();
        var path:Array<Point> = new Array<Point>();
        while (pathNode.parent != null) {
            path.push(pathNode.point);
            pathNode = pathNode.parent;
        }
        
        return path;
    }
    
    function getNeighbors(point:Point):Array<Point> {
        var neighbors:Array<Point> = new Array<Point>();
        if (inBounds(point)) {
            for (i in 0...NUM_NEIGHBORS) {
                var neighbor:Point = point.clone();
                neighbor.x += OFFS_HORZ[i];
                neighbor.y += OFFS_VERT[i];
                
                var idx:Int = neighbor.y * m_domainWidth + neighbor.x;
                if (m_domain[idx] != 0 && inBounds(neighbor)) {
                    neighbors.push(neighbor);
                }
            }
        }
        
        return neighbors;
    }
    
    function pathCost(node:Node):Int {
        var iter:Node = node;
        var cost:Int = 0;
        
        while (iter != null) {
            cost += iter.cost;
            iter = iter.parent;
        }
        
        return cost;
    }
    
    function heuristic(from:Point, to:Point):Int {
        return Std.int(Math.abs(to.x - from.x + to.y - from.y));
    }
    
    function inBounds(point:Point):Bool {
        return point.x >= 0 && point.x < m_domainWidth && point.y >= 0 && point.y < m_domainHeight;
    }
}
