extends Sprite2D

@export var digspace: int=35

var image: Image
var imgtexture: ImageTexture

func _ready() -> void:
	if texture == null:
		push_error("No texture here")
		return
	
	if texture is NoiseTexture2D and texture.get_image() == null:
		await texture.changed
	
	image = texture.get_image()
	if image == null:
		push_error("Image is null")
		return
	image.decompress() #make editable in some way, I used google
	
	imgtexture = ImageTexture.create_from_image(image)
	texture = imgtexture

func _unhandled_input(event: InputEvent) -> void:
	#click and drag
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		digdug(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		digdug(event.position)

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
