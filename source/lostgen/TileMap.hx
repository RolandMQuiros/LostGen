package lostgen;
import org.flixel.FlxTilemap;

/**
 * ...
 * @author Roland M. Quiros
 */

class TileMap extends FlxTilemap{

    public function new() {
        super();
    }
    
    override private function autoTile(Index:Int):Void {
        if (_data[Index] == 0) {
			return;
		}
		
		_data[Index] = 0;
		if((Index-widthInTiles < 0) || (_data[Index-widthInTiles] > 0)) 		//UP
			_data[Index] += 1;
		if((Index%widthInTiles >= widthInTiles-1) || (_data[Index+1] > 0)) 		//RIGHT
			_data[Index] += 2;
		if((Std.int(Index+widthInTiles) >= totalTiles) || (_data[Index+widthInTiles] > 0)) //DOWN
			_data[Index] += 4;
		if((Index%widthInTiles <= 0) || (_data[Index-1] > 0)) 					//LEFT
			_data[Index] += 8;
		if (auto == FlxTilemap.ALT)	{
            if (_data[Index] == 15) {
                if((Index%widthInTiles > 0) && (Std.int(Index+widthInTiles) < totalTiles) && (_data[Index+widthInTiles-1] <= 0))
                    _data[Index] = 15;		//BOTTOM LEFT OPEN
                if((Index%widthInTiles > 0) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles-1] <= 0))
                    _data[Index] = 16;		//TOP LEFT OPEN
                if((Index%widthInTiles < widthInTiles-1) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0))
                    _data[Index] = 17;		//TOP RIGHT OPEN
                if((Index%widthInTiles < widthInTiles-1) && (Std.int(Index+widthInTiles) < totalTiles) && (_data[Index+widthInTiles+1] <= 0))
                    _data[Index] = 18; 		//BOTTOM RIGHT OPEN
            } else {
                _data[Index] = 19;
            }
		}
        
		_data[Index] += 1;
    }
    
}