extends Sprite2D

@export var digspace: int=35
@onready var static_body: StaticBody2D = $StaticBody2D

var image: Image
var imgtexture: ImageTexture
var needs_collision_update: bool = false

func _ready() -> void:
	if texture is NoiseTexture2D and texture.get_image() == null:
		await texture.changed
	
	image = texture.get_image()
	image.decompress() #make editable in some way, I used google
	
	imgtexture = ImageTexture.create_from_image(image)
	texture = imgtexture

func _unhandled_input(event: InputEvent) -> void:
	#click and drag
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		digdug(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		digdug(event.position)
		if needs_collision_update:
			update_collision()
			needs_collision_update = false

func digdug(global_mouse_pos: Vector2) -> void:
	#figure out sprite coords from mouse pos
	var local_pos: Vector2 = to_local(global_mouse_pos)
	
	if centered:
		local_pos += texture.get_size() / 2.0
	
	var center_x: int = int(local_pos.x)
	var center_y: int = int(local_pos.y)
	#dig where mouse is
	var image_width: int = image.get_width()
	var image_height: int = image.get_height()
	var erased_any: bool = false
	
	var border_thickness: int = 4
	var border_color: Color = Color(0.4, 0.7, 0.2, 1.0)
	var outer_radius: int = digspace + border_thickness
	
	for x in range(center_x - outer_radius, center_x + outer_radius):
		for y in range(center_y - outer_radius, center_y + outer_radius):
			if x >= 0 and x < image_width and y >= 0 and y < image_height:
				var dist: float = Vector2(x - center_x, y - center_y).length()
				if dist <= outer_radius and dist > digspace:
					if image.get_pixel(x,y).a > 0.0:
						image.set_pixel(x, y, border_color)
	
	for x in range(center_x - digspace, center_x + digspace):
		for y in range(center_y - digspace, center_y + digspace):
			#Bounds check (idk what that means)
			if x >= 0 and x < image_width and y >= 0 and y < image_height:
				#circle not square, make unable to go past certain radius
				if Vector2(x - center_x, y - center_y).length() <= digspace:
					#make transparent
					image.set_pixel(x,y, Color(0, 0, 0, 0))
					erased_any = true
	if erased_any:
		imgtexture.update(image)
		needs_collision_update = true
#right now this is useless and makes character disappear
func update_collision() -> void:
	if not static_body:
		return
	#make map based on transparency
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image, 0.1)
	var rect := Rect2i(Vector2i.ZERO, image.get_size())
	var polygons := bitmap.opaque_to_polygons(rect, 4.0)
	#calculate offset if centered property exists (Ill do that)
	var offset := -texture.get_size() / 2.0 if centered else Vector2.ZERO
	#manually making a polygon collision box
	for poly in polygons:
		if centered:
			var offset_poly := PackedVector2Array()
			for point in poly:
				offset_poly.append(point + offset)
			poly = offset_poly
		var col_poly := CollisionPolygon2D.new()
		col_poly.polygon = poly
		static_body.add_child(col_poly)
