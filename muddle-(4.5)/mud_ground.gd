extends Sprite2D
@export var brush_radius: int = 20
var image: Image
var textura: ImageTexture #texture was taken

# Called when the node enters the scene tree for the first time.
func _ready():
	#get image
	image = texture.get_image()
	image.convert(Image.FORMAT_RGBA8)
	#turn image into texture
	textura = ImageTexture.create_from_image(image)
	texture = textura
func _unhandled_input(event):
	#just fucking read it
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var local_pos = to_local(event.position)
		erase_at_position(local_pos)

func erase_at_position(local_pos: Vector2):
	var image_width = image.get_width()
	var image_height = image.get_height()
	
	var center_x = int(local_pos.x + image_width / 2.0)
	var center_y = int(local_pos.y + image_width / 2.0)
	
	var modified = false
	
	for x in range(center_x - brush_radius, center_x + brush_radius):
		for y in range(center_y - brush_radius, center_y + brush_radius):
			if x >= 0 and x < image_width and y >= 0 and y < image_height:
				if Vector2(x,y).distance_to(Vector2(center_x, center_y)) <= brush_radius:
					image.set_pixel(x,y,Color(0,0,0,0))
					modified=true
	if modified:
		textura.update(image)
