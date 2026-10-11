extends TileMapLayer

@onready var map: TileMapLayer = $"../foreground"

var lighted_tiles: Array[Vector2i] = []

func _ready() -> void:
	if map:
		for pos in map.get_used_cells():
			if pos.y >= 10:
				set_cell(pos, 11, Vector2i(0,0))
			else:
				set_cell(pos, 11, Vector2i(0,0))
#light source
func cast_light(source_global_pos: Vector2, radius: int = 3) -> void:
	if not map:
		return
	for pos in lighted_tiles:
		set_cell(pos, 11, Vector2i(0,0))
	lighted_tiles.clear()
	var source_tile: Vector2i = map.local_to_map(map.to_local(source_global_pos))
	if not map.is_tunnel(source_tile):
		return
	for x in range (-1, 2):
		for y in range(-1, 2):
			var aura_light: Vector2i = source_tile + Vector2i(x,y)
			set_cell(aura_light, 11, Vector2i(0,0),3)
			if not lighted_tiles.has(aura_light):
				lighted_tiles.append(aura_light)
	#only light in tunnels
	var queue: Array = [[source_tile, 0]]
	var visited: Dictionary = {source_tile: true}
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var pos: Vector2i = current[0]
		var dist:int = current[1]
		
		lighted_tiles.append(pos)
		#make darkness transparent
		match dist:
			0:
				erase_cell(pos)
			1:
				set_cell(pos, 11, Vector2i(0,0), 1)
			2: 
				set_cell(pos, 11, Vector2i(0,0), 2)
			3:
				set_cell(pos, 11, Vector2i(0,0), 3)
		#spread light if close to light source
		if dist < radius:
			for dir in directions:
				var neighbor_pos = pos + dir
				#only spread to more tunnels
				if not visited.has(neighbor_pos) and map.is_tunnel(neighbor_pos):
					visited[neighbor_pos] = true
					queue.append([neighbor_pos, dist + 1])
