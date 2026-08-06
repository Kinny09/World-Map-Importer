# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Scalable Label Class
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## A label that automatically scales with the zoom level of the viewport it's in. Only acts when on screen. It automatically gets information from the viewport its in
class_name ScalableLabel extends Label

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
# Exported Member Variables
@export var BaseScale: int = 60
@export var ZoomLevelVisibleRange: Vector2i = Vector2i(1, 16)
# Standard Member Variables
var OnScreenNotifier: VisibleOnScreenNotifier2D = VisibleOnScreenNotifier2D.new()

# ---------------------------------------------------------------------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------------------------------------------------------------------
@onready var Camera = get_viewport().get_camera_2d()
@onready var ZoomLevel: int = Camera["ZoomLevel"]

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
func _init(_BaseScale: int = 60, _ZoomLevelVisibleRange = Vector2i(1, 16)):
	BaseScale = _BaseScale
	ZoomLevelVisibleRange = _ZoomLevelVisibleRange

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	OnScreenNotifier.rect = Rect2(0,0,self.size.x, self.size.y)
	self.add_child(OnScreenNotifier)
	OnScreenNotifier.screen_entered.connect(func():
		update_label()
		Camera.ZOOM_LEVEL_CHANGED.connect(update_label)
	)
	OnScreenNotifier.screen_exited.connect(func():
		Camera.ZOOM_LEVEL_CHANGED.disconnect(update_label)
	)

## Updates the label's visiblity and scale depending on the zoom level
func update_label():
	ZoomLevel = Camera["ZoomLevel"]
	if ZoomLevel >= ZoomLevelVisibleRange[0] && ZoomLevel <= ZoomLevelVisibleRange[1]:
		self.self_modulate.a = 1
		self.add_theme_font_size_override("font_size", 60 / ZoomLevel)
		OnScreenNotifier.rect = Rect2(0,0,self.size.x, self.size.y)
	else:
		self.self_modulate.a = 0
