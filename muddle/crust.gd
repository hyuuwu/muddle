extends TileMapLayer

@onready var player: CharacterBody2D = $"../drone"
@onready var mudgrab: Sprite2D = $"../splotch"
@onready var foreground: TileMapLayer = $"../foreground"
@onready var background: TileMapLayer = $"../background"

@export var map_width = 100
@export var map_height = 40
@export var swap_interval: float = 0.5

var holding_mud: bool = false
var last_preview_cell: Vector2i = Vector2i(-1,-1) #where preview is
var swap_state: bool = false
var timer: float = 0.0
var noise = FastNoiseLite.new()

const mud_source_id = 0 #which tile
const mud_atlas_coords = Vector2i(0,0) #position in atlas
const muds_source_id = 1
const muds_atlas_coords = Vector2i(0,0)
const moonstone_source_id = 2
const moonstone_atlas = Vector2i(0,0)
const ocean_source_id = 3
const ocean_atlas = Vector2i(0,0)
const drone_box_source_id = 4
const drone_box_atlas = Vector2i(0,0)

func _ready() -> void:
	generate_world()
	#a random spawn, same height
	var random_x = randi_range(11,map_width - 11)
	var spawn_y = 10
	var spawn_pos = Vector2i(random_x, spawn_y)
	#place diff tile
	set_cell(spawn_pos, 4, Vector2i(0,0))
	#place me
	if player != null:
		player.global_position = map_to_local(spawn_pos)
func generate_world() -> void:
	noise.seed = randi() #random caves every run
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX #smoother caves
	
	noise.frequency = 0.3 #higher means tiny pockets and lower means bigger pockets
	var cave_threshold = 0.07 #higher means less caves
	var mud_cells = []
	var empty_cells = []
	#go through every tile
	#put moonstone where its needed
	for y in range(map_height):
		for x in range(10):
			set_cell(Vector2i(x,y), moonstone_source_id, moonstone_atlas)
		for x in range(map_width - 10, map_width):
			set_cell(Vector2i(x,y), moonstone_source_id, moonstone_atlas)
	#ocean and sea
	for x in range(map_width):
		for y in range(10):
			set_cell(Vector2i(x,y), ocean_source_id, ocean_atlas)
		for y in range (map_height - 10, map_height):
			set_cell(Vector2i(x,y), ocean_source_id, ocean_atlas)
	for x in range(map_width):
		for y in range (map_height):
			#cave gen
			if y < 10 or y >= (map_height - 10) or  x < 10 or x >= (map_width - 10):
				continue
			#store if empty or full
			var noise_val = noise.get_noise_2d(x,y)
			if noise_val > cave_threshold:
				empty_cells.append(Vector2i(x,y))
			else:
				mud_cells.append(Vector2i(x,y))
	#place them
	for cell in mud_cells:
		set_cell(cell, mud_source_id, mud_atlas_coords)
	for cell in empty_cells:
		set_cell(cell, muds_source_id, muds_atlas_coords)
	for cell in empty_cells:
		update_surrounding(cell)
func _input(event: InputEvent) -> void:
	#only when pressing lmb
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#what am I hovering over
		var mouse_pos = get_local_mouse_position()
		var player_tile = foreground.local_to_map(foreground.to_local($"../drone".global_position))
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
func update_tunnel(pos: Vector2i) -> void:
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
func update_surrounding(pos: Vector2i) -> void:
	#update tile and neighbors
	update_tunnel(pos)
	update_tunnel(pos + Vector2i.UP)
	update_tunnel(pos + Vector2i.RIGHT)
	update_tunnel(pos + Vector2i.DOWN)
	update_tunnel(pos + Vector2i.LEFT)
func get_checkerboard_tile():
	for x in range(map_width):
		for y in range(map_height):
			#only water
			if get_cell_source_id(Vector2i(x,y)) == 3:
				#checkerboard
				var is_even = (x + y + (1 if swap_state else 0)) % 2 == 0
				var atlas_coord = Vector2i(0,0) if is_even else Vector2i(1,0)
				
				set_cell(Vector2i(x,y), 3, atlas_coord)
func _process(delta: float) -> void:
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
	var mouse_pos = get_global_mouse_position()
	var current_cell = background.local_to_map(background.to_local(mouse_pos))
	#follow mouse
	mudgrab.global_position = mouse_pos + Vector2(1, 2)
	#only change if moved to new tile
	if current_cell != last_preview_cell:
		#erase preview, then make new
		clear_current_preview()
		#if both layers empty, make preview
		if foreground.get_cell_source_id(current_cell) == 1 and background.get_cell_source_id(current_cell) == -1:
			#transparent mud
			background.set_cell(current_cell, 0, Vector2i(0,0), 1)
			last_preview_cell = current_cell
func is_tunnel(pos: Vector2i) -> bool:
	var id = get_cell_source_id(pos)
	#all tunnels here
	return id == 1 or id == 4
func clear_current_preview() -> void:
	if last_preview_cell != Vector2i(-1,-1):
		#is it preview?
		background.set_cell(last_preview_cell, -1) #if preview, erase
		last_preview_cell = Vector2i(-1,-1)
