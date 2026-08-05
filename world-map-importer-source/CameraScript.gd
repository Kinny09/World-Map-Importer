extends Camera2D

var LeftKeyPressed: bool
var RightKeyPressed: bool
var UpKeyPressed: bool
var DownKeyPressed: bool
const MaxZoom: int = 30
var ZoomLevel: int = 1
const MOVE_SPEED: float = 500.0

func _ready() -> void:
	self.limit_left = -3500
	self.limit_right = 3600
	self.limit_top = -1650
	self.limit_bottom = 1600
	self.zoom = Vector2(0.25, 0.25)

func _input(inputEvent: InputEvent) -> void:	
	# Handling zooming in and out
	if inputEvent is InputEventMouseButton && inputEvent.pressed == true:
		if inputEvent.button_index == MOUSE_BUTTON_WHEEL_UP && ZoomLevel < MaxZoom:
			ZoomLevel += 1
		if inputEvent.button_index == MOUSE_BUTTON_WHEEL_DOWN && ZoomLevel > 1:
			ZoomLevel -= 1
		update_map_scales()
		print(ZoomLevel)
		self.zoom = Vector2(ZoomLevel * 0.25, ZoomLevel * 0.25)
		self.zoom = self.zoom.clamp(Vector2(0.25, 0.25), Vector2(20.0, 20.0))
		
	if inputEvent is InputEventKey:
		if inputEvent.keycode == KEY_LEFT:
			LeftKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_RIGHT:
			RightKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_UP:
			UpKeyPressed = inputEvent.pressed
		if inputEvent.keycode == KEY_DOWN:
			DownKeyPressed = inputEvent.pressed

func _process(delta: float) -> void:
	if LeftKeyPressed:
		self.position.x -= MOVE_SPEED * delta
	if RightKeyPressed:
		self.position.x += MOVE_SPEED * delta
	if UpKeyPressed:
		self.position.y -= MOVE_SPEED * delta
	if DownKeyPressed:
		self.position.y += MOVE_SPEED * delta
		
func update_map_scales():
	# Updates the country labels
	if ZoomLevel < 16:
		%WorldMapVisualiser.get_node("CountryLabels").visible = true
		for countryLabel: Label in %WorldMapVisualiser.get_node("CountryLabels").get_children():
			countryLabel.add_theme_font_size_override("font_size", 60 / ZoomLevel)
	else:
		%WorldMapVisualiser.get_node("CountryLabels").visible = false

# Update it with visibleonscreennotifier's perhaps, to track what labels are on screen and if they should be updated or not
	
	if ZoomLevel > 16:
		%WorldMapVisualiser.get_node("BuiltUpArea").visible = true
		%WorldMapVisualiser.get_node("SettlementLabels").visible = true
		for countryLabel: Label in %WorldMapVisualiser.get_node("SettlementLabels").get_children():
			countryLabel.add_theme_font_size_override("font_size", 60 / ZoomLevel)
	else:
		%WorldMapVisualiser.get_node("BuiltUpArea").visible = false
		%WorldMapVisualiser.get_node("SettlementLabels").visible = false

	
	
	
	
	
	
	
	
	
	
	
	
