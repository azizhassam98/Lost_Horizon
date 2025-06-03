extends Node
const level_1 = preload("res://levels/level_1.tscn")
const PAUSE_MENU_SCREEN = preload("res://ui/pause_menu_screen.tscn")
const MAIN_MENU_SCREEN = preload("res://ui/main_menu_screen.tscn")


func _ready():
	RenderingServer.set_default_clear_color(Color(0.44,0.12,0.53,1.00))
	SettingsManager.load_settings()

func start_game():
	if get_tree().paused:
		continue_game()
		return
	SceneManager.transition_to_scene("Level1")
	
func pause_game():
	get_tree().paused = true
	
	var pause_menu_screen_instance = PAUSE_MENU_SCREEN.instantiate()
	get_tree().get_root().add_child(pause_menu_screen_instance)

func continue_game():
	get_tree().paused = false

func main_menu():
	var main_menu_screen_instance = MAIN_MENU_SCREEN.instantiate()
	get_tree().get_root().add_child(main_menu_screen_instance)

func exit_game():
	get_tree().quit()












# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 
