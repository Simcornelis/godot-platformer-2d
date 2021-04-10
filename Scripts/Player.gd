extends KinematicBody2D

export var score : int = 0

export var speed : int = 300
export var jumpForce : int = 700
export var doubleJumpForce : int = 600
export var gravity : int = 2300
export var wallGravity : int = 300

var doubleJumpAvailable : bool = true
var vel : Vector2 = Vector2()

onready var sprite : AnimatedSprite = get_node("Anim")
onready var playerCollision : CollisionShape2D = get_node("CollisionShape2D")
onready var cam : Camera2D = get_node("Camera2D")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# animation states
	if Input.is_action_pressed("move_right"):
		selectAnim("running", false)
	elif Input.is_action_pressed("move_left"):
		selectAnim("running", true)
	else:
		selectAnim("idle", false)
	
	# quit game
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# fullscreen toggle
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	# restart level
	if Input.is_action_just_pressed("restart") or position.y > 5000:
		get_tree().reload_current_scene()

func _physics_process(delta):
	vel.x = 0
	
	# movement inputs
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
	if Input.is_action_pressed("move_right"):
		vel.x += speed
	
	# applying the velocity
	vel = move_and_slide(vel, Vector2.UP)
	
	# gravity
	if is_on_wall() and vel.y > 0:
		vel.y += wallGravity * delta
	else:
		vel.y += gravity * delta
	
	# jump
	if is_on_floor() or is_on_wall():
		doubleJumpAvailable = true
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or is_on_wall():
			vel.y = -jumpForce
		elif doubleJumpAvailable:
			doubleJumpAvailable = false
			vel.y = -jumpForce
	
	stopPlayerAtBorders()


# selects the requested animation
func selectAnim(name, flipped):
	sprite.animation = name
	sprite.flip_h = flipped


func stopPlayerAtBorders():
	var leftBorder = cam.limit_left + playerCollision.shape.get("extents").x
	var rightBorder = cam.limit_right - playerCollision.shape.get("extents").x
	var topBorder = cam.limit_top + playerCollision.shape.get("extents").y
	
	if position.x < leftBorder:
		position = Vector2(leftBorder, position.y)
	if position.x > rightBorder:
		position = Vector2(rightBorder, position.y)
	if position.y < topBorder:
		position = Vector2(position.x, topBorder)
