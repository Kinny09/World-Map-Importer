# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Manipulatable Camera class
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## A camera that the user can manipulate, it implements zooming and panning through middle mouse click or arrow keys.
class_name OldManipulatableCamera extends Camera2D

# ---------------------------------------------------------------------------------------------------------------------------------------
# Signalling
# ---------------------------------------------------------------------------------------------------------------------------------------
signal ZOOM_LEVEL_CHANGED()

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------
var LeftKeyPressed: bool
var RightKeyPressed: bool
var UpKeyPressed: bool
var DownKeyPressed: bool
var MiddleClickPressed: bool
var MiddleClickStartPosition: Vector2
const MaxZoom: int = 30
var ZoomLevel: int = 1
const MOVE_SPEED: float = 500.0

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	self.limit_left = -3500
	self.limit_right = 3500
	self.limit_top = -1600
	self.limit_bottom = 1600
	self.zoom = Vector2(0.25, 0.25)

func _input(inputEvent: InputEvent) -> void:
	# Handling zooming in and out
	if inputEvent is InputEventMouseButton && inputEvent.pressed == true:
		if inputEvent.button_index == MOUSE_BUTTON_WHEEL_UP && ZoomLevel < MaxZoom:
			ZoomLevel += 1
		if inputEvent.button_index == MOUSE_BUTTON_WHEEL_DOWN && ZoomLevel > 1:
			ZoomLevel -= 1
		ZOOM_LEVEL_CHANGED.emit()
		self.zoom = Vector2(ZoomLevel * 0.25, ZoomLevel * 0.25)
		self.zoom = self.zoom.clamp(Vector2(0.25, 0.25), Vector2(20.0, 20.0))
		
		# I think, ideally, the map should be split up into squares(?) perhaps, and each square should control stuff like this, not the camera
		# The camera should only be handling camera manipulation
		#if ZoomLevel > 16:
			#%WorldMapVisualiser.get_node("BuiltUpArea").visible = true
		#else:
			#%WorldMapVisualiser.get_node("BuiltUpArea").visible = false
		
	# Handling arrow key panning
	if inputEvent is InputEventKey:
		if inputEvent.keycode == KEY_LEFT:
			LeftKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_RIGHT:
			RightKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_UP:
			UpKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_DOWN:
			DownKeyPressed = inputEvent.pressed
			
	# Handling middle click panning
	if inputEvent is InputEventMouseButton:
		if inputEvent.button_index == MOUSE_BUTTON_MIDDLE:
			if inputEvent.pressed:
				MiddleClickStartPosition = get_local_mouse_position()
				MiddleClickPressed = inputEvent.pressed
			else:
				MiddleClickPressed = inputEvent.pressed
			
	elif inputEvent is InputEventMouseMotion and MiddleClickPressed:
		var viewportMultiplier = Input.get_last_mouse_velocity() * get_viewport_transform()
		print(viewportMultiplier)
		
		self.position -= viewportMultiplier

# Keyboard panning, done in process to keep it smooth
func _process(delta: float) -> void:
	if LeftKeyPressed:
		self.position.x -= MOVE_SPEED * delta
	if RightKeyPressed:
		self.position.x += MOVE_SPEED * delta
	if UpKeyPressed:
		self.position.y -= MOVE_SPEED * delta
	if DownKeyPressed:
		self.position.y += MOVE_SPEED * delta
