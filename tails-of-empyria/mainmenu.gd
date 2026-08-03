extends Node2D
@onready var MainmenuRootNode = $"."
@onready var TextFX_NG = $Buttons/NewGameButton/MainmenuNewgame/Textanim_NewGame
@onready var TextFX_CT = $Buttons/ContinueButton/MainmenuContinueHoverinactive/Textanim_Continue
@onready var TextFX_QU = $Buttons/QuitButton/Mainmenuquit/Textanim_quit
@onready var Continuebutton = $Buttons/ContinueButton
@onready var CotinueSprite = $Buttons/ContinueButton/MainmenuContinueHoverinactive
@onready var Audioplayer_UI = $AudioStreamPlayer_UI/UiBtnHover
@onready var Audioplayer_UI_Press =	$AudioStreamPlayer_UI/UiMmPress
@onready var vfx_Screenwipe = $Screenwipe/TransitionToBlackScreenwipe/Screen_Transition_Wipetoblack
@onready var vfx_Screenwipe_Sprite = $Screenwipe

### sound fx vars
@onready var hover = $AudioStreamPlayer_UI/UiBtnHover
@onready var press = $AudioStreamPlayer_UI/UiMmPress

var Animbuffer_NG = "Inactive"
var Animbuffer_CT = "Inactive"
var Animbuffer_QU = "Inactive"

var Save_Exists = false


@onready var title = $TitleText
@onready var buttons_root = $Buttons
@onready var buttons := [
	$Buttons/NewGameButton,
	$Buttons/ContinueButton,
	$Buttons/QuitButton
]

var button_spacing := 90  # adjust to taste    

func scale_menu():
	var screen = get_viewport_rect().size
	var base = Vector2(1920, 1080)

	# Reset transform first
	self.position = Vector2.ZERO
	self.rotation = 0
	self.scale = Vector2.ONE

	# Now compute scale
	var scale_factor = max(screen.x / base.x, screen.y / base.y)
	self.scale = Vector2(scale_factor, scale_factor)

func scale_background():
	var screen = get_viewport_rect().size
	var tex_size = $MainmenuBackground.texture.get_size()

	var scale_x = screen.x / tex_size.x
	var scale_y = screen.y / tex_size.y

	$MainmenuBackground.scale = Vector2(scale_x, scale_y)

func arrange_menu():
	var screen_size = get_viewport_rect().size

	# Center the title
	title.position = Vector2(
		screen_size.x / 2,
		screen_size.y * 0.25
	)

	# Center the button group
	var start_y = screen_size.y * 0.45

	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.position = Vector2(
			screen_size.x / 2,
			start_y + i * button_spacing
		)


func _on_new_game_mouse_entered() -> void:
	Audioplayer_UI.play()
	TextFX_NG.play("InactiveToActicve")
	if Input.is_action_just_pressed("ui_click"):
		Audioplayer_UI_Press.play()
		vfx_Screenwipe_Sprite.visible = true
		vfx_Screenwipe.current_animation = "WipeEffect"
		vfx_Screenwipe.play()
	



func _on_new_game_mouse_exited() -> void:
	Audioplayer_UI.play()
	TextFX_NG.play_backwards("InactiveToActicve")
	

func _on_textanim_new_game_animation_finished(anim_name: StringName) -> void:
	if anim_name == "InactiveToActicve" and Animbuffer_NG == "Inactive":
		TextFX_NG.play("Hover_Active")
		Animbuffer_NG = "Active" 
	elif anim_name == "InactiveToActicve" and Animbuffer_NG == "Active":
		TextFX_NG.play("Hover_Inactive")
		Animbuffer_NG = "Inactive"


func _on_continue_mouse_entered() -> void:
	Audioplayer_UI.play()
	TextFX_CT.play("InactiveToActicve")
	if Input.is_action_just_pressed("ui_click"):
		Audioplayer_UI_Press.play()
		vfx_Screenwipe_Sprite.visible = true
		vfx_Screenwipe.current_animation = "WipeEffect"
		vfx_Screenwipe.play()

func _on_continue_mouse_exited() -> void:
	TextFX_CT.play_backwards("InactiveToActicve")


func _on_textanim_continue_animation_finished(anim_name: StringName) -> void:
	if anim_name == "InactiveToActicve" and Animbuffer_CT == "Inactive":
		TextFX_CT.play("Hover_Active")
		Animbuffer_CT = "Active" 
	elif anim_name == "InactiveToActicve" and Animbuffer_CT == "Active":
		TextFX_CT.play("Hover_Inactive")
		Animbuffer_CT = "Inactive"


func _on_quit_mouse_entered() -> void:
	Audioplayer_UI.play()
	TextFX_QU.play("InactiveToActicve")



func _on_quit_mouse_exited() -> void:
	TextFX_QU.play_backwards("InactiveToActicve")
	


func _on_textanim_quit_animation_finished(anim_name: StringName) -> void:
	if anim_name == "InactiveToActicve" and Animbuffer_CT == "Inactive":
		TextFX_QU.play("Hover_Active")
		Animbuffer_QU = "Active" 
	elif anim_name == "InactiveToActicve" and Animbuffer_CT == "Active":
		TextFX_QU.play("Hover_Inactive")
		Animbuffer_QU = "Inactive"

func _ready() -> void:
	self.position = Vector2.ZERO
	self.rotation = 0
	self.scale = Vector2.ONE

	#scale_menu()
	#scale_background()
	#arrange_menu()
	
	vfx_Screenwipe_Sprite.visible = false
	TextFX_NG.current_animation = "Hover_Inactive"
	TextFX_NG.current_animation = "Hover_Inactive"
	TextFX_CT.current_animation = "Hover_Inactive"
	TextFX_QU.current_animation = "Hover_Inactive"
	if Save_Exists == true:
		Continuebutton.show()
		CotinueSprite.show()
	else:
		Continuebutton.hide()
		CotinueSprite.hide()


func _on_screen_transition_wipetoblack_animation_finished(anim_name: StringName) -> void:
	if anim_name == "WipeEffect" :
		get_tree().quit(0)
		


func _on_quit_box_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
		if event.is_action_pressed("ui_click"):
			Audioplayer_UI_Press.play()
			vfx_Screenwipe_Sprite.visible = true
			vfx_Screenwipe.current_animation = "WipeEffect"
			vfx_Screenwipe.play()
