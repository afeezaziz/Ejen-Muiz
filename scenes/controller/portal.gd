# Portal.gd
extends Area3D

## Export variable to set the target scene path in the Godot Editor's Inspector.
## This makes the portal reusable for different destinations.
@export_file("*.tscn") var target_scene_path: String = ""

# This signal is built into Area3D. It emits when a PhysicsBody3D or RigidBody3D enters.
# CharacterBody3D is a type of PhysicsBody3D.
func _on_body_entered(body: Node3D):
	# Check if the body that entered is the player.
	# It's good practice to check by name, group, or class_name.
	# Using name is simplest for MVP if your player node is consistently named "EjenMuiz".
	if body.name == "EjenMuiz":
		print("Ejen Muiz entered portal to: ", target_scene_path)

		if target_scene_path.is_empty():
			printerr("Portal Error: Target scene path is not set for this portal instance!")
			return
		
		# Optional: Check if the file actually exists before trying to change scene
		# In Godot 4, FileAccess.file_exists() is preferred.
		# In Godot 3, new_file.file_exists() was common.
		if not FileAccess.file_exists(target_scene_path): # Godot 4
		# if not ResourceLoader.exists(target_scene_path): # Alternative check, also works
			printerr("Portal Error: Target scene file does not exist: ", target_scene_path)
			return

		# --- IMPORTANT: Load Topic Data BEFORE Changing Scene ---
		# This is where you'd tell your GlobalContentManager (or similar)
		# which topic to load based on which portal was entered.
		# This logic will depend on how you structure your topic selection.
		# Example (you'll need to adapt this):
		# if target_scene_path.contains("Fungsi_ImejObjek_Learn"):
		#     GlobalContentManager.load_topic_data("F4_B1_ImejObjek")
		# elif target_scene_path.contains("SukatanMembulat_Learn"):
		#     GlobalContentManager.load_topic_data("F5_B1_SukatanMembulat_Radian")
		# else:
		#     print("Portal: No specific topic data loaded for this scene path.")
		# A better way is to have another @export var in Portal.gd for topic_id:
		# @export var topic_to_load: String = ""
		# if !topic_to_load.is_empty():
		#    GlobalContentManager.load_topic_data(topic_to_load)


		# Change to the target scene
		var error = get_tree().change_scene_to_file(target_scene_path)
		if error != OK:
			printerr("Error changing scene to '", target_scene_path, "': ", error)

# You don't strictly need _ready() for this basic portal,
# as the signal connection can be done in the editor.
# However, if you prefer connecting in code:
# func _ready():
#    body_entered.connect(self._on_body_entered) # Godot 4
#    # For Godot 3.x: body_entered.connect("_on_body_entered")
