extends TileMapLayer

@onready var player: CharacterBody2D = $"../drone"
@onready var mudgrab: Sprite2D = $"../splotch"
@onready var foreground: TileMapLayer = $"../foreground"
@onready var background: TileMapLayer = $"../background"
@onready var darkness: TileMapLayer = $"../darkness"

@export var map_width = 100
@export var map_height = 40
@export var swap_interval: float = 0.5

var holding_mud: bool = false
var last_preview_cell: Vector2i = Vector2i(-1,-1) #where preview is
var swap_state: bool = false
var timer: float = 0.0

const mud_source_id = 0
const muds_source_id = 1
const moonstone_source_id = 2
const ocean_source_id = 3
const drone_box_source_id = 4
const clay_source_id = 6
const sand_source_id = 7
const general_atlas = Vector2i(0,0) #position in atlas

#world gen
func _ready() -> void:
	generate_world()
	#a random spawn, same height
	var random_x = randi_range(11,map_width - 11)
	var spawn_y = 10
	var spawn_pos = Vector2i(random_x, spawn_y)
	#place diff tile
	set_cell(spawn_pos, 4, general_atlas)
	set_cell(spawn_pos + Vector2i(0,1), 9, general_atlas)
	update_surrounding(spawn_pos)
	update_surrounding(spawn_pos + Vector2i(0,1))
	#place me
	if player != null:
		player.global_position = map_to_local(spawn_pos)
func generate_world() -> void:
	var cave_noise = FastNoiseLite.new()
	cave_noise.seed = randi()
	cave_noise.frequency = 0.6
	
	var clay_noise = FastNoiseLite.new()
	clay_noise.seed = randi() + 1000 #literally any number it doesnt matter, just different from others
	clay_noise.frequency = 0.15 #medium chunks
	
	var sand_noise = FastNoiseLite.new()
	sand_noise.seed = randi() + 6767
	sand_noise.frequency = 0.8 #bigger chunks
	
	var chunk_rules = [
		{
			"name": "clay",
			"source_id": clay_source_id,
			"coords": general_atlas,
			"threshold": 0.40,
			"min_y": 11,
			"max_y": 30,
			"noise_machine": clay_noise
		},
		{
			"name": "sand",
			"source_id": sand_source_id,
			"coords": general_atlas,
			"threshold": 0.35, #lower threshold, larger patches
			"min_y": map_height - 30,
			"max_y": map_height - 10,
			"noise_machine": sand_noise
		},
	]
	for x in range(map_width):
		for y in range(map_height):
			var chosen_source = mud_source_id
			var chosen_coords = general_atlas #these two shits exist because basic variables cant run through whats down there
			var cell = Vector2i(x,y)
			for chunks in chunk_rules:
				if y < chunks.min_y or y > chunks.max_y:
					continue
				var noise_val = chunks.noise_machine.get_noise_2d(x,y)
				if noise_val > chunks.threshold:
					chosen_source = chunks.source_id
					chosen_coords = chunks.coords
					break
			set_cell(cell, chosen_source, chosen_coords)
	for x in range(map_width):
		for y in range(map_height):
			if y < 10 or y >= map_height - 10 or x < 10 or x >= map_width - 10:
				continue
			var cell = Vector2i(x,y)
			if cave_noise.get_noise_2d(x,y) > 0.0: #change for caverns or tunnels
				var current_source = get_cell_source_id(cell)
				#if undiggable, dont cave
				if current_source == clay_source_id or current_source == sand_source_id:
					continue
				set_cell(cell, muds_source_id, general_atlas)
				update_surrounding(cell)
	
	#put moonstone where its needed
	for y in range(map_height):
		for x in range(10):
			set_cell(Vector2i(x,y), moonstone_source_id, general_atlas)
		for x in range(map_width - 10, map_width):
			set_cell(Vector2i(x,y), moonstone_source_id, general_atlas)
	#ocean and sea
	for x in range(map_width):
		for y in range(10):
			set_cell(Vector2i(x,y), ocean_source_id, general_atlas)
		for y in range (map_height - 10, map_height):
			set_cell(Vector2i(x,y), ocean_source_id, general_atlas)

#digging
func _input(event: InputEvent) -> void:
	#only when pressing lmb
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#what am I hovering over
		var mouse_pos = get_local_mouse_position()
		var player_tile = foreground.local_to_map(foreground.to_local(player.global_position))
		var target_tile = foreground.local_to_map(foreground.to_local(mouse_pos)) #what your mouse is looking at
		var tile_pos = target_tile
		#what is this tile
		var grid_dist_x = abs(player_tile.x - target_tile.x)
		var grid_dist_y = abs(player_tile.y - target_tile.y)
		var grid_dist = grid_dist_x + grid_dist_y
		var current_id = foreground.get_cell_source_id(tile_pos)
		#only 1 tile away may pick up
		if grid_dist == 1:
			#pick up if its 0
			if current_id == 0 and not holding_mud:
				#turn it into 1-0,0
				foreground.set_cell(tile_pos, 1,Vector2i(0,0))
				update_surrounding(tile_pos)
				holding_mud = true
			#put it down
			elif current_id == 1 and holding_mud:
				#turn it to 0
				foreground.set_cell(tile_pos, 0, Vector2i(0,0))
				update_surrounding(tile_pos)
				holding_mud = false
				darkness.set_cell(tile_pos, 11, Vector2i(0,0))
func update_tunnel(pos: Vector2i) -> void: #can be combined with next 2
	var original_id = get_cell_source_id(pos)
	#check if whole block
	if not is_tunnel(pos):
		return
	
	if original_id == 4:
		return
	#check surrounding tiles
	var up = 1 if is_tunnel(pos + Vector2i.UP) else 0
	var right = 1 if is_tunnel(pos + Vector2i.RIGHT) else 0
	var down = 1 if is_tunnel(pos + Vector2i.DOWN) else 0
	var left = 1 if is_tunnel(pos + Vector2i.LEFT) else 0
	#make binary (0 to 15)
	var score = (up * 1) + (right * 2) + (down * 4) + (left * 8)
	#convert binary to x,y for atlas
	var atlas_coord = Vector2i(score % 4, int(score/4.0))
	#tile shape depending on score
	set_cell(pos, original_id, atlas_coord)
func is_tunnel(pos: Vector2i) -> bool: #change these when adding new digging tiles
	var id = get_cell_source_id(pos)
	#all tunnels here
	return id == 1 or id == 4
func update_surrounding(pos: Vector2i) -> void:
	#update tile and neighbors
	update_tunnel(pos)
	update_tunnel(pos + Vector2i.UP)
	update_tunnel(pos + Vector2i.RIGHT)
	update_tunnel(pos + Vector2i.DOWN)
	update_tunnel(pos + Vector2i.LEFT)
func _process(delta: float) -> void: #what happens when youre holding a block (and checker??)
	timer += delta
	if timer >= swap_interval:
		timer = 0.0
		swap_state = !swap_state
		get_checkerboard_tile()
	#mudgrabbing
	mudgrab.visible = holding_mud
	#if its not holding mud, dont check anything at all
	if not holding_mud:
		clear_current_preview()
		return
	var current_cell = background.local_to_map(background.to_local(get_global_mouse_position()))
	#follow mouse
	mudgrab.global_position = get_global_mouse_position() + Vector2(0, 2)
	#only change if moved to new tile
	if current_cell != last_preview_cell:
		#erase preview, then make new
		clear_current_preview()
		#if both layers empty, make preview
		if foreground.get_cell_source_id(current_cell) == 1 and background.get_cell_source_id(current_cell) == -1:
			#transparent mud
			background.set_cell(current_cell, 0, Vector2i(0,0), 1)
			last_preview_cell = current_cell
func get_checkerboard_tile(): #in function _process for some reason, for water
	for x in range(map_width):
		for y in range(map_height):
			#only water
			if get_cell_source_id(Vector2i(x,y)) == 3:
				#checkerboard
				var is_even = (x + y + (1 if swap_state else 0)) % 2 == 0
				var atlas_coord = Vector2i(0,0) if is_even else Vector2i(1,0)
				
				set_cell(Vector2i(x,y), 3, atlas_coord)
func clear_current_preview() -> void:
	if last_preview_cell != Vector2i(-1,-1):
		#is it preview?
		background.set_cell(last_preview_cell, -1) #if preview, erase
		last_preview_cell = Vector2i(-1,-1)
