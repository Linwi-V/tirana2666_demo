extends Sprite2D

@export var key:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if key =="ui_left":
		self.frame=16
	elif key =="ui_down":
		self.frame=17
	elif key =="ui_up":
		self.frame=18
	elif key =="ui_right":
		self.frame=19
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.frame<20:
		if Input.is_action_just_pressed(key):
			self.frame+=8
	else:
		if Input.is_action_just_released(key):
			self.frame-=8
	pass
