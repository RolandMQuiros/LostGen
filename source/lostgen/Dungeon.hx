package lostgen;
import de.polygonal.ds.Hashable;
import de.polygonal.ds.HashSet;
import de.polygonal.ds.HashTable;
import de.polygonal.ds.Itr;
import de.polygonal.ds.LinkedQueue;

import hxs.Signal1;
import hxs.Signal3;

/**
 * ...
 * @author Roland M. Quiros
 */
enum Terrain {
    WALL;
    FLOOR;
    LAVA;
} 

class Dungeon {
    public var sigEntityAdded(default, null): Signal1<Entity>;
    public var sigEntityRemoved(default, null): Signal1<Entity>;
    public var sigEntityMoved(default, null): Signal3<Entity, Point, Point>;
    
    public var grid  (default, null):Array<Int>;
    public var width (default, null):Int;
    public var height(default, null):Int;
    
    var m_entities:HashSet<Entity>;
    var m_entityIter:Itr<Entity>;
    var m_entity:Entity;
    var m_entityTable:IntHash<Array<Entity>>;
    var m_addedEntities:LinkedQueue<Entity>;
    var m_removedEntities:LinkedQueue<Entity>;
    var m_pathfinder:Pathfinder;
    
    public function new():Void {
        sigEntityAdded = new Signal1<Entity>(this);
        sigEntityRemoved = new Signal1<Entity>(this);
        sigEntityMoved = new Signal3<Entity, Point, Point>(this);
        
        m_entities = new HashSet<Entity>(64);
        m_entityTable = new IntHash<Array<Entity>>();
        m_addedEntities = new LinkedQueue<Entity>();
        m_removedEntities = new LinkedQueue<Entity>();
        
        m_entityIter = null;
        m_entity = null;
        
        // Test world
        grid = [
            0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0,
            0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
        ];
        width  = 20;
        height = 15;
        
        m_pathfinder = new Pathfinder(grid, width);
    }
    
    public function loadMap(mapData:Dynamic):Void {
        // Load from XML file
    }
    
    public function getEntities(point:Point):Array<Entity> {
        var entities:Array<Entity> = new Array<Entity>();
        if (m_entityTable.exists(point.key)) {
            entities = m_entityTable.get(point.key);
        }
        return entities;
    }
    
    public function addEntity(entity:Entity):Void {
        m_addedEntities.enqueue(entity);
        sigEntityAdded.dispatch(entity);
        //if (m_entities.set(entity)) {
            //if (!m_entityTable.set(entity.position, entity)) {
                //m_entities.remove(entity);
                //return false;
            //}
        //}
        //return true;
    }
    
    public function removeEntity(entity:Entity):Void {
        m_removedEntities.enqueue(entity);
        sigEntityRemoved.dispatch(entity);
    }
    
    public function moveEntity(entity:Entity, start:Point, end:Point):Bool {
        if (start.equals(end)) {
            return false;
        }
        
        // Add an array for new positions
        if (!m_entityTable.exists(start.key)) {
            m_entityTable.set(start.key, new Array<Entity>());
        }
        
        var entitiesAt:Array<Entity> = m_entityTable.get(start.key);
        
        // Remove entity from table
        if (entitiesAt.remove(entity)) {
            // Move entity, then add it back into the table
            entity.position.set(end);
            
            if (m_entityTable.exists(end.key)) {
                entitiesAt = m_entityTable.get(end.key);
            } else {
                entitiesAt = new Array<Entity>();
                m_entityTable.set(end.key, entitiesAt);
            }
            
            entitiesAt.push(entity);
            
            // Notify listeners that an entity has moved
            sigEntityMoved.dispatch(entity, start, end);
            
            // Move successful
            return true;
        }
        
        return false;
    }
    
    public function inBounds(point:Point):Bool {
        return inBounds2(point.x, point.y);
    }
    
    public function inBounds2(x:Int, y:Int):Bool {
        return x >= 0 && x < width && y >= 0 && y <= height;
    }
    
    public function isWall(point:Point):Bool {
        return isWall2(point.x, point.y);
    }
    
    public function isWall2(x:Int, y:Int):Bool {
        if (inBounds2(x, y)) {
            var index:Int = y * width + x;
            return grid[index] == Type.enumIndex(WALL);
        }
        return true;
    }
    
    public function getPath(start:Point, end:Point):Array<Point> {
        return m_pathfinder.createPath(start, end);
    }
    
    public function getPath2(startX:Int, startY:Int, endX:Int, endY:Int):Array<Point> {
        return m_pathfinder.createPath(new Point(startX, startY), new Point(endX, endY));
    }
    
    /**
     * Runs a single step
     * Each call to step runs a single entity's turn.  While there are still entities
     * on the field with turns, this method returns false.
     * @return
     */
    public function step(): Bool {        
        // Add entities to the field
        while (!m_addedEntities.isEmpty()) {
            var toAdd:Entity = m_addedEntities.dequeue();
            if (m_entities.set(toAdd)) {
                var entsAt: Array<Entity>;
                if (m_entityTable.exists(toAdd.position.key)) {
                    entsAt = m_entityTable.get(toAdd.position.key);
                } else {
                    entsAt = new Array<Entity>();
                    m_entityTable.set(toAdd.position.key, entsAt);
                }
                
                entsAt.push(toAdd);
            }
        }
        
        // Clean up any flagged entities
        while (!m_removedEntities.isEmpty()) {
            var toRemove:Entity = m_removedEntities.dequeue();
            if (m_entities.remove(toRemove)) {
                var entsAt: Array<Entity>;
                if (m_entityTable.exists(toRemove.position.key)) {
                    entsAt = m_entityTable.get(toRemove.position.key);
                    entsAt.remove(toRemove);
                }
            }
        }
        
        // If there are no entities to process, end cycle
        if (m_entities.isEmpty()) {
            return true;
        }
        
        // Grab the first entity
        if (m_entity == null) {
            if (m_entityIter != null && m_entityIter.hasNext()) {
                m_entity = m_entityIter.next();
                m_entity.preStep();
            } else {
                m_entityIter = m_entities.iterator();
            }
        }
        
        // Run the entity's turn
        if (m_entity != null && m_entity.step()) {
            m_entity.postStep();
            m_entity = null;
            return true;
        }
        
        return false;
    }
    
}