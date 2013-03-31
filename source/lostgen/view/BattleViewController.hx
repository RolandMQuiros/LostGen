package lostgen.view;
import lostgen.Battle;
import lostgen.Fighter;
import lostgen.fighter.PlayerFighter;
import lostgen.Point;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Roland M. Quiros
 */

private class BattleAction {    
    public var start: Void->Void;
    public var update: Void->Bool;
    public var end: Void->Void;
    public var wait: Bool;
    
    public function new() {
        start = function(): Void { };
        update = function(): Bool { return true; };
        end = function(): Void { };
        wait = false;
    }
}

class BattleViewController extends FlxGroup {
    public static inline var TERRAIN_WIDTH: Float = 128;
    public static inline var TERRAIN_HEIGHT: Float = 64;
    
    public static inline var TURN_DELAY: Float = 0.25;
    
    public var camera: FlxCamera;
    
    var m_battle: Battle;
    
    var m_fighterGroup: FlxGroup;
    var m_uiGroup: FlxGroup;
    var m_buttonGroup: FlxGroup;
    var m_bounceGroup: FlxGroup;
    
    var m_fighters: IntHash<Fighter>;
    var m_combatantPositions: IntHash<FlxPoint>;
    var m_fighterSprites: IntHash<FighterSprite>;
    var m_statSprites: IntHash<StatSprite>;
    var m_buttons: IntHash<FlxSprite>;
    
    var m_cameras: Array<FlxCamera>;
    var m_centroid: FlxPoint;
    
    var m_currentAction: BattleAction;
    var m_parallelActions: Array<BattleAction>;
    var m_actionQueue: Array<BattleAction>;
    var m_actionRemoveList: Array<BattleAction>;

    public function new(battle: Battle) {
        super();
        camera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 0);
        camera.bgColor = 0;
        
        m_battle = battle;
        
        m_fighterGroup = new FlxGroup();
        m_uiGroup = new FlxGroup();
        m_buttonGroup = new FlxGroup();
        m_bounceGroup = new FlxGroup(16);
        for (i in 0...16) {
            m_bounceGroup.add(new BouncingText(0, 0, 128));
        }
        
        add(m_fighterGroup);
        add(m_uiGroup);
        add(m_buttonGroup);
        add(m_bounceGroup);
        
        m_fighters = new IntHash<Fighter>();
        m_combatantPositions = new IntHash<FlxPoint>();
        m_fighterSprites = new IntHash<FighterSprite>();
        m_statSprites = new IntHash<StatSprite>();
        m_buttons = new IntHash<FlxSprite>();
        
        m_cameras = [camera];
        m_centroid = new FlxPoint();
        cameras = m_cameras;
        
        m_parallelActions = new Array<BattleAction>();
        m_actionQueue = new Array<BattleAction>();
        m_actionRemoveList = new Array<BattleAction>();
        
        // Attach signals
        m_battle.sigCombatantJoined.add(addCombatant);
        m_battle.sigFighterTurn.add(onsigFighterTurn);
        m_battle.sigFighterAttack.add(onFighterAttack);
        m_battle.sigFighterLink.add(onsigFighterLink);
        m_battle.sigFighterUnlink.add(onsigFighterUnlink);
        m_battle.sigFighterDamaged.add(onsigFighterDamaged);
        m_battle.sigFighterKilled.add(onsigFighterKilled);
        m_battle.sigEnded.add(onEnd);
        
        // Add pre-existing combatants
        for (c in m_battle.combatants) {
            addCombatant(c);
        }
    }
    
    override public function update():Void {
        super.update();
        camera.fill(0x0, false);
        
        // Run parallel actions
        for (p in m_parallelActions) {
            if (p.update()) {
                p.end();
                m_actionRemoveList.push(p);
            }
        }
        
        // Remove finished parallel actions
        while (m_actionRemoveList.length > 0) {
            var toRemove: BattleAction = m_actionRemoveList.shift();
            m_parallelActions.remove(toRemove);
        }
        
        // If the first element in the queue is a waiting action, update it.
        // Otherwise, pop it and put it in the parallel action list.
        if (m_currentAction == null && m_actionQueue.length > 0) {
            m_currentAction = m_actionQueue.shift();
            m_currentAction.start();
        }
        
        // Update front of queue
        if (m_currentAction != null && m_currentAction.update()) {
            m_currentAction.end();
            
            // Push subsequent nonwaiting actions into the parallel list
            while (m_actionQueue.length > 0 && !m_actionQueue[0].wait) {
                var pAct: BattleAction = m_actionQueue.shift();
                pAct.start();
                
                m_parallelActions.push(pAct);
            }
            
            m_currentAction = null;
        }
        
        // Once the action queue is empty, we tell the battle to progress,
        // filling the queue up again.
        if (m_actionQueue.length == 0) {
            m_battle.step();
        }
    }
    
    public function addCombatant(combatant: Combatant): Void {        
        // Calculate the combatant's position in our isometric view
        var centerPoint: FlxPoint = fieldToViewCoordinates(combatant.position);
        
        // Add to the combatant position table and calculate centroid
        m_combatantPositions.set(combatant.id, centerPoint);
        m_centroid = getCentroid();
        
        // TEMPORARY: Center the camera on the centroid
        camera.scroll.x = m_centroid.x - (FlxG.width / 2.0);
        camera.scroll.y = m_centroid.y - (FlxG.height / 2.0);
        
        var dx: Float = TERRAIN_WIDTH / 4.0;
        var dy: Float = TERRAIN_HEIGHT / 4.0;
        
        /*
        switch (slot) {
            case FRONT:
                centerPoint.x -= dx;
                centerPoint.y -= dy;
            case RIGHT:
                centerPoint.x += dx;
                centerPoint.y -= dy;
            case BACK:
                centerPoint.x += dx;
                centerPoint.y += dy;
            case LEFT:
                centerPoint.x -= dx;
                centerPoint.y -= dy;
            default:
        }
        
        dx /= 2.0;
        dy /= 2.0;*/
        
        // Fighter offsets based on the combatant's position
        var hOffs: Array<Float> = [ -dx, 0, dx, 0];
        var vOffs: Array<Float> = [ 0, -dy, 0, dy];
        var root: Int = 0;
        
        switch (combatant.direction) {
            case Pawn.NORTH: root = 0;
            case Pawn.EAST : root = 1;
            case Pawn.SOUTH: root = 2;
            case Pawn.WEST : root = 3;
        }
        
        for (i in 0...combatant.fighters.length) {
            if (combatant.fighters[i] != null) {
                var idx: Int = (root + i) % Pawn.DIRECTIONCOUNT;
                var position: FlxPoint = new FlxPoint(centerPoint.x + hOffs[idx], centerPoint.y + vOffs[idx]);
                addFighter(combatant.fighters[i], position);
            }
        }
    }
    
    public function addFighter(fighter: Fighter, position: FlxPoint): Void {
        var sprite: FighterSprite = new FighterSprite();
        
        m_fighters.set(fighter.id, fighter);
        
        // Add sprite
        sprite.setGraphic("assets/sprites/sprTempFighter.png", 16, 32);
        sprite.cameras = m_cameras;
        sprite.x = sprite.standingPoint.x = position.x;
        sprite.y = sprite.standingPoint.y = position.y;
        sprite.initialize();
        m_fighterSprites.set(fighter.id, sprite);
        m_fighterGroup.add(sprite);
        
        // If the fighter is a player, add its stats window
        if (Std.is(fighter, PlayerFighter)) {
            var statSprite: StatSprite = new StatSprite(0, 0, 64);
            statSprite.name = fighter.name;
            statSprite.hp = fighter.stats.health;
            statSprite.maxHP = fighter.stats.maxHealth;
            statSprite.mp = fighter.stats.mana;
            statSprite.maxMP = fighter.stats.maxMana;
            statSprite.x = FlxG.camera.scroll.x;
            statSprite.y = FlxG.camera.scroll.y;
            statSprite.updateString();
            
            m_statSprites.set(fighter.id, statSprite);
            m_uiGroup.add(statSprite);
        }
        
        // Add button
        var button: FlxSprite = new FlxSprite(position.x, position.y);
        button.width = button.height = 32;
        button.loadGraphic("assets/sprites/sprTempTap.png");
        m_buttons.set(fighter.id, button);
        m_buttonGroup.add(button);
    }
    
    function fieldToViewCoordinates(point: Point): FlxPoint {
        var pt: FlxPoint = new FlxPoint(TERRAIN_WIDTH * point.x, TERRAIN_WIDTH * point.y);
        var ret: FlxPoint = new FlxPoint();
        
        ret.x = pt.x * 0.707 + pt.y * 0.707;
        ret.y = (pt.x * -0.707 + pt.y * 0.707) / 2.0;
        
        return ret;
    }
    
    function getCentroid(): FlxPoint {
        var centroid: FlxPoint = new FlxPoint();
        var count: Int = 0;
        
        var iter: Iterator<FlxPoint> = m_combatantPositions.iterator();
        while (iter.hasNext()) {
            var point: FlxPoint = iter.next();
            centroid.x += point.x;
            centroid.y += point.y;
            count++;
        }
        
        centroid.x /= count;
        centroid.y /= count;
        
        return centroid;
    }
    
    function onsigFighterTurn(fighter: Fighter): Void {
        if (!m_fighters.exists(fighter.id) || !fighter.isAlive()) {
            return;
        }
        
        if (Std.is(fighter, PlayerFighter)) {
            var player: PlayerFighter = cast(fighter, PlayerFighter);
            var action: BattleAction = new BattleAction();
            
            // Turn on all buttons
            action.start = function(): Void {
                m_buttonGroup.exists = true;
                FlxG.log(player.name + "'s turn");
            }
            
            // Wait for player input
            action.update = function(): Bool {
                if (m_buttonGroup.exists && FlxG.mouse.justReleased()) {
                    var iter: Iterator<Int> = m_buttons.keys();
                    var selected: Bool = false;
                    
                    // Check if a button is overlapped
                    while (iter.hasNext()) {
                        var id: Int = iter.next();
                        var button: FlxSprite = m_buttons.get(id);
                        if (button.exists && button.overlapsPoint(FlxG.mouse.getWorldPosition(camera), false, camera)) {
                            player.target = m_fighters.get(id);
                            selected = true;
                            break;
                        }
                    }
                    
                    return selected;
                }
                
                return false;
            }
            
            // Hide buttons
            action.end = function(): Void {
                m_buttonGroup.exists = false;
            }
            
            // Don't pursue the next Battle Action until this one is finished
            action.wait = true;
            
            // Enqueue the action
            m_actionQueue.push(action);
        }
    }
    
    function onFighterAttack(attacker: Fighter, target: Fighter, damage: Int): Void {
        if (m_fighterSprites.exists(attacker.id) && m_fighterSprites.exists(target.id)) {
            var attackerSprite: FighterSprite = m_fighterSprites.get(attacker.id);
            var targetSprite: FighterSprite = m_fighterSprites.get(target.id);
            
            var action: BattleAction = new BattleAction();
            var finished: Bool = false;
            
            // Tell the attacker's sprite to charge the target's position
            action.start = function(): Void {
                var targetPoint: FlxPoint = new FlxPoint(targetSprite.x, targetSprite.y);
                attackerSprite.attack(targetPoint, function(): Void {
                    finished = true;
                });
                
                FlxG.log(attacker.name + " attacked " + target.name);
            }
            
            action.update = function(): Bool {
                return finished;
            }
            
            // Action ends once the attacking animation ends
            action.wait = true;
            
            m_actionQueue.push(action);
        }
    }
    
    function onsigFighterLink(linker: Fighter, target: Fighter): Void {
        if (m_fighterSprites.exists(linker.id) && m_fighterSprites.exists(target.id)) {
            var linkerSprite: FighterSprite = m_fighterSprites.get(linker.id);
            var targetSprite: FighterSprite = m_fighterSprites.get(target.id);
            
            var action: BattleAction = new BattleAction();
            var targetPoint: FlxPoint = new FlxPoint(targetSprite.x, targetSprite.y);
            
            action.start = function(): Void {
                linkerSprite.link(targetPoint);
                FlxG.log(linker.name + " linked to " + target.name);
            }
            
            m_actionQueue.push(action);
        }
    }
    
    function onsigFighterKilled(fighter: Fighter): Void {
        if (m_buttons.exists(fighter.id)) {
            m_buttons.get(fighter.id).exists = false;
        }
    }
    
    function onsigFighterUnlink(linker: Fighter, target: Fighter): Void {
        if (m_fighterSprites.exists(linker.id)) {
            var linkerSprite: FighterSprite = m_fighterSprites.get(linker.id);
            
            var action: BattleAction = new BattleAction();
            action.start = function(): Void {
                linkerSprite.unlink();
                FlxG.log(linker.name + " unlinked with " + target.name);
            }
            
            m_actionQueue.push(action);
        }
    }
    
    function onsigFighterDamaged(fighter: Fighter, damage: Int): Void {
        if (m_fighterSprites.exists(fighter.id)) {
            var fighterSprite: FighterSprite = m_fighterSprites.get(fighter.id);
            
            var statSprite: StatSprite = null;
            if (m_statSprites.exists(fighter.id)) {
                statSprite = m_statSprites.get(fighter.id);
            }
            
            var action: BattleAction = new BattleAction();
            action.start = function(): Void {
                if (statSprite != null) {
                    statSprite.health -= damage;
                    statSprite.updateString();
                }
                fighterSprite.damage();
                bounceText(fighterSprite.x, fighterSprite.y, "-" + damage);
                
                FlxG.log(fighter.name + " took " + damage + " damage");
            }
            
            m_actionQueue.push(action);
        }
    }
    
    function onEnd(): Void {
        exists = false;
    }
    
    function bounceText(x: Float, y: Float, text: String): Void {
        var bounce: BouncingText = cast(m_bounceGroup.recycle(BouncingText), BouncingText);
        
        bounce.cameras = m_cameras;
        bounce.x = x;
        bounce.y = y;
        bounce.text = text;
        bounce.revive();
    }
}