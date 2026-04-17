extends Node2D

@onready var TextFX_NG = $Newgamebutton/NewGame/Textanim_NewGame
@onready var TextFX_CT = $continuebutton/Continue/Textanim_Continue
@onready var TextFX_QU = $QuitButton/Quit/Textanim_quit
@onready var Continuebutton = $continuebutton
@onready var CotinueSprite = $continuebutton/Continue/Textanim_Continue/MainmenuContinueHoverinactive
@onready var Audioplayer_UI = $AudioStreamPlayer_UI
@onready var Audioplayer_UI_Press = $AudioStreamPlayer_UI/UiMmPress
@onready var vfx_Screenwipe = $TransitionToBlackScreenwipe/Screen_Transition_Wipetoblack
@onready var vfx_Screenwipe_Sprite = $TransitionToBlackScreenwipe


### sound fx vars
@onready var hover = $AudioStreamPlayer_UI/UiBtnHover
@onready var press = $AudioStreamPlayer_UI/UiMmPress

var Animbuffer_NG = "Inactive"
var Animbuffer_CT = "Inactive"
var Animbuffer_QU = "Inactive"

var Save_Exists = false
 
func _on_new_game_mouse_entered() -> void:
	TextFX_NG.play("InactiveToActicve")
	Audioplayer_UI.play()
	
	



func _on_new_game_mouse_exited() -> void:
	TextFX_NG.play_backwards("InactiveToActicve")


func _on_textanim_new_game_animation_finished(anim_name: StringName) -> void:
	if anim_name == "InactiveToActicve" and Animbuffer_NG == "Inactive":
		TextFX_NG.play("Hover_Active")
		Animbuffer_NG = "Active" 
	elif anim_name == "InactiveToActicve" and Animbuffer_NG == "Active":
		TextFX_NG.play("Hover_Inactive")
		Animbuffer_NG = "Inactive"


func _on_continue_mouse_entered() -> void:
	TextFX_CT.play("InactiveToActicve")

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
	TextFX_QU.play("InactiveToActicve")
	Audioplayer_UI.play()
	


func _on_quit_mouse_exited() -> void:
	TextFX_QU.play_backwards("InactiveToActicve")
	


func _on_textanim_quit_animation_finished(anim_name: StringName) -> void:
	if anim_name == "InactiveToActicve" and Animbuffer_CT == "Inactive":
		TextFX_QU.play("Hover_Active")
		Animbuffer_QU = "Active" 
	elif anim_name == "InactiveToActicve" and Animbuffer_CT == "Active":
		TextFX_QU.play("Hover_Inactive")
		Animbuffer_QU = "Inactive"

func _on_quit_pressed() -> void:
	Audioplayer_UI_Press.play()
	vfx_Screenwipe_Sprite.visible = true
	vfx_Screenwipe.current_animation = "WipeEffect"
	vfx_Screenwipe.play()

		
func _ready() -> void:
	vfx_Screenwipe_Sprite.visible = false
	if Save_Exists == true:
		Continuebutton.visible = true
		CotinueSprite.visible = true
	else:
		Continuebutton.visible = false
		CotinueSprite.visible = false


func _on_screen_transition_wipetoblack_animation_finished(anim_name: StringName) -> void:
	if anim_name == "WipeEffect" :
		get_tree().quit(0)
		
