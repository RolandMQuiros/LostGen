package lostgen.view;
import lostgen.TileMap;
import org.flixel.FlxGroup;
import org.flixel.FlxTilemap;

/**
 * ...
 * @author Roland M. Quiros
 */

class MapView extends FlxGroup {
    public static inline var TILE_WIDTH: Int = 16;
    public static inline var TILE_HEIGHT: Int = 16;
    public static inline var WALL_SHEET: String = "assets/tilesets/tsTestWallAutoAlt.png";
    public static inline var FLOOR_SHEET: String = "assets/tilesets/tsTestFloorAuto.png";
    
    public var tileWidth: Int;
    public var tileHeight: Int;
    public var floorSheetPath: String;
    public var wallSheetPath: String;
    
    var m_floorTiles: FlxTilemap;
    var m_wallTiles: FlxTilemap;
    
    public function new() {
        super();
        
        tileWidth = TILE_WIDTH;
        tileHeight = TILE_HEIGHT;
        wallSheetPath = WALL_SHEET;
        floorSheetPath = FLOOR_SHEET;
        
        m_floorTiles = new FlxTilemap();
        m_wallTiles = new FlxTilemap();
    }
    
    public function create(data: Array<Int>, width:Int): Void {
        if (data == null) {
            throw "Provided data grid is null.  What the hell, man?";
        }
        
        var height: Int = Math.floor(data.length / width);
        
        //remove(m_floorTiles);
        remove(m_wallTiles);
        
        // Doubles the data array so we can use Flixel's ALT tiling
        // without wierd artifacts.
        // Figure out an alternative for later versions.
        var expanded: Array<Int> = new Array<Int>();
        var t: Int;
        var t2: Int;
        for (i in 0...width) {
            for (j in 0...height) {
                t = j * width + i;
                t2 = (j * width * 4) + (2 * i);
                expanded[t2] = data[t];
                expanded[t2 + 1] = data[t];
                expanded[t2 + (width * 2)] = data[t];
                expanded[t2 + (width * 2) + 1] = data[t];
            }
        }
        
        //var floorData: String = FlxTilemap.arrayToCSV(data, width);
        var wallData: String = FlxTilemap.arrayToCSV(expanded, width * 2, true);
        
        //m_floorTiles.loadMap(wallData, floorSheetPath, tileWidth, tileHeight, 1);
        m_wallTiles.loadMap(wallData, wallSheetPath, tileWidth, tileHeight, FlxTilemap.ALT);
        
        //add(m_floorTiles);
        add(m_wallTiles);
    }
}