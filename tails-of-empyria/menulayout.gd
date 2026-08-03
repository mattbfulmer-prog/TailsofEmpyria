extends Control

@onready var title_label = $"../Container/TextureRect2"
@onready var button_container = $"../Container/buttonContainer"

func arrange_layout():
	# Make sure the root fills the screen
	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	# Center the title at the top
	title_label.anchor_left = 0.5
	title_label.anchor_right = 0.5
	title_label.anchor_top = 0.15
	title_label.anchor_bottom = 0.15
	title_label.offset_left = -title_label.size.x / 2
	title_label.offset_right = title_label.size.x / 2
	title_label.offset_top = -title_label.size.y / 2
	title_label.offset_bottom = title_label.size.y / 2

	# Center the button container
	button_container.anchor_left = 0.5
	button_container.anchor_right = 0.5
	button_container.anchor_top = 0.45
	button_container.anchor_bottom = 0.45

	button_container.offset_left = -button_container.size.x / 2
	button_container.offset_right = button_container.size.x / 2
	button_container.offset_top = -button_container.size.y / 2
	button_container.offset_bottom = button_container.size.y / 2

	# Optional: adjust spacing based on screen height
	var screen_h = get_viewport_rect().size.y
	button_container.add_theme_constant_override("separation", screen_h * 0.03)


func _ready():
	arrange_layout()
