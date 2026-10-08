extends Node2D

var gravity_speed = 4
var speed = 300
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200,200)

var idle_timer = 0.0
var is_idling = false

var is_dragging = false
var drag_offset = Vector2()

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

func maybe_idle():	
	if randf() < 0.3:
		is_idling = true
		idle_timer = randf_range(1.0, 4.0)
		var r = randi() % 1
		if r == 0:
			animated_sprite.play("BlueIdle")
			speed = 0
		#elif r = 1:
			

func _on_area_input(_viewport, event, _shape_idx):	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
			animated_sprite.play("BlueIdle")
		else: 
			is_dragging = false
			animated_sprite.play("BlueWalkRight")

func _ready():
	animated_sprite.play("BlueWalkRight")
	var screen_size = Vector2(DisplayServer.screen_get_size())
	#print("screen size y:", screen_size.y)
	#print("window size y:", window_size.y)
	var window_position = Vector2(DisplayServer.window_get_position())
	#print("clamp(window_position.y, 0, screen_size.y-window_size.y(=", screen_size.y-window_size.y,")):", clamp(window_position.y, 0, screen_size.y-window_size.y))
	area.input_event.connect(_on_area_input)

func _physics_process(delta:float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	var screen_size = Vector2(DisplayServer.screen_get_size())

	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
		
	if window_position.y < screen_size.y - window_size.y:
		animated_sprite.play("BlueIdle")
		window_position.y += speed*gravity_speed*delta
		DisplayServer.window_set_position(Vector2i(window_position))
		if window_position.y >= screen_size.y - window_size.y:
			animated_sprite.play("BlueWalkRight")
		return
		
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 300
			animated_sprite.play("BlueWalkRight")
		return
		
	#var screen_size = Vector2(DisplayServer.screen_get_size())
	#print(screen_size, "screen size")
	#var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction*speed*delta
	print(window_position)
	#print(screen_size, "screen size")
	window_position.x = clamp(window_position.x, 0, screen_size.x-window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y-window_size.y)
	#print(window_position, " etter clamp")
	DisplayServer.window_set_position(Vector2i(window_position))
	
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
		

		
