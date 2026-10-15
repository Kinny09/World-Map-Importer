# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Manipulatable Camera Class
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## A camera that the user can manipulate, it implements zooming and panning through middle mouse click or arrow keys.
class_name ManipulatableCamera extends Camera2D

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
# Exported Member Variables
@export var ZoomSlerpSpeed: float = 10;
@export var PanSpeed: float = 1000;
@export var MaxZoom: int = 30
@export var CameraPanLimits: Dictionary[String, int] = {
	LeftLimit = 0,
	RightLimit = 0,
	TopLimit = 0,
	BottomLimit = 0,
}

# Member Variables
var ZoomLevel: int = 1
var PanStartMousePosition: Vector2 = Vector2.ZERO
var PanStartCameraPosition: Vector2 = Vector2.ZERO
var IsPanning: bool = false

# ---------------------------------------------------------------------------------------------------------------------------------------
# Signalling
# ---------------------------------------------------------------------------------------------------------------------------------------
signal ZOOM_LEVEL_CHANGED()

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	# Setting the default zoom on camera initalization
	self.zoom = Vector2(0.25, 0.25) * ZoomLevel
	
## Runs all the camera controls every frame
func _process(delta: float) -> void:
	zoom_camera(delta)
	pan_camera(delta)
	click_and_drag_camera()
	clamp_camera_position()
	
## Handles the zooming of the camera
func zoom_camera(delta):
	if Input.is_action_just_pressed("CAMERA_ZOOM_IN") && ZoomLevel < MaxZoom:
		ZoomLevel += 1
		ZOOM_LEVEL_CHANGED.emit()
	
	if Input.is_action_just_pressed("CAMERA_ZOOM_OUT") && ZoomLevel > 1:
		ZoomLevel -= 1
		ZOOM_LEVEL_CHANGED.emit()
		
	self.zoom = self.zoom.slerp(Vector2(0.25, 0.25) * ZoomLevel, ZoomSlerpSpeed * delta)
		
## Handles the keyboard based panning of the camera
func pan_camera(delta):
	var moveAmount = Vector2.ZERO
	if Input.is_action_pressed("CAMERA_MOVE_RIGHT"):
		moveAmount.x += 1
		
	if Input.is_action_pressed("CAMERA_MOVE_LEFT"):
		moveAmount.x -= 1
	
	if Input.is_action_pressed("CAMERA_MOVE_UP"):
		moveAmount.y -= 1
		
	if Input.is_action_pressed("CAMERA_MOVE_DOWN"):
		moveAmount.y += 1
		
	self.position += moveAmount.normalized() * delta * PanSpeed * (1/zoom.x)

## Handles the middle mouse click based panning of the camera
func click_and_drag_camera():
	if !IsPanning and Input.is_action_just_pressed("CAMERA_PAN"):
		PanStartMousePosition = get_viewport().get_mouse_position()
		PanStartCameraPosition = self.position
		IsPanning = true
		
	if IsPanning and Input.is_action_just_released("CAMERA_PAN"):
		IsPanning = false
		
	if IsPanning:
		var moveVector = get_viewport().get_mouse_position() - PanStartMousePosition
		self.position = PanStartCameraPosition - moveVector * 1/self.zoom.x
		
func clamp_camera_position():
	var cameraSizehalved: Vector2 = (get_viewport().get_visible_rect().size / self.zoom) / 2

	self.position.x = clamp(self.position.x, CameraPanLimits["LeftLimit"] + cameraSizehalved.x, CameraPanLimits["RightLimit"] - cameraSizehalved.x)
	self.position.y = clamp(self.position.y, CameraPanLimits["TopLimit"] + cameraSizehalved.y, CameraPanLimits["BottomLimit"] - cameraSizehalved.y)
