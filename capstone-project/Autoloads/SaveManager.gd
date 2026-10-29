extends Node
#Holds the game state in memory and writes it to / reads it from disk.
#World objects (bosses, doors, pickups) call set_flag() / get_flag()
#the moment something happens, so state survives level swaps.
#Save stations (or the debug key for now) call save_game().
#The main menu "Continue" calls load_game(), then asks SceneManager
#to load the level stored in game_state["last_checkpoint"].

const SAVE_PATH := "user://save.json"

#Everything that needs to survive a level swap or a quit lives in here.
var game_state: Dictionary = {}


func _ready() -> void:
	new_game()



#The starting values for a brand new game.
#Add new fields here as the team needs them.
func get_default_state() -> Dictionary:
	return {
		"last_checkpoint": "",      # ID of the save station last used
		"last_scene": "",           # scene path for that checkpoint
		"player": {
			"max_health": 5,
			"has_double_jump": true,
			"has_dash": false,
			"has_air_attack": false
		},
		"flags": {},                # e.g. "bulky_01_defeated": true
	}



#Resets in-memory state to a fresh game. Does NOT touch the save file.
func new_game() -> void:
	game_state = get_default_state()



#Flags (one-time world events: bosses, doors, items)
func set_flag(flag_name: String, value: bool = true) -> void:
	game_state["flags"][flag_name] = value
	
#Returns false for any flag that was never set.
func get_flag(flag_name: String) -> bool:
	return game_state["flags"].get(flag_name, false)



# Player values (stats and unlocks)
func set_player_value(key: String, value) -> void:
	game_state["player"][key] = value

func get_player_value(key: String, default_value = null):
	return game_state["player"].get(key, default_value)


#Checkpoints
#Called by a save station (later) before save_game().
func set_checkpoint(checkpoint_id: String, scene_path: String) -> void:
	game_state["last_checkpoint"] = checkpoint_id
	game_state["last_scene"] = scene_path



# Disk

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


# Writes the current in-memory state to the save file.
func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not open save file for writing")
		return
	# "\t" pretty-prints the JSON so the file is readable when debugging.
	file.store_string(JSON.stringify(game_state, "\t"))
	file.close()
	print("SaveManager: game saved to ", ProjectSettings.globalize_path(SAVE_PATH))


#Reads the save file into memory. Returns true if it worked.
#This only fills game_state; reloading the level is SceneManager's job.
func load_game() -> bool:
	if not has_save():
		print("SaveManager: no save file found")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		push_error("SaveManager: save file is corrupted or unreadable")
		return false

	# Start from defaults and lay the saved data on top, so a save made
	# before a new field was added still loads with that field present.
	game_state = get_default_state()
	for section in data:
		if game_state.get(section) is Dictionary and data[section] is Dictionary:
			game_state[section].merge(data[section], true)
		else:
			game_state[section] = data[section]

	print("SaveManager: game loaded")
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)


# ---------------------------------------------------------------------------
# Debug keys (temporary, remove once save stations exist)
# ---------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			save_game()
		elif event.keycode == KEY_F9:
			if load_game():
				# TODO: replace with a SceneManager call that loads
				# game_state["last_scene"] and spawns at the checkpoint.
				get_tree().reload_current_scene()
