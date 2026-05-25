extends Object
class_name NpcPhysics

## Physics layer 1 = world, layer 3 = npc (project.godot 2d_physics layer names).
## NPC bodies collide with world only, not with each other or the player body.
const COLLISION_LAYER_NPC: int = 4
const COLLISION_MASK_WORLD: int = 1


static func apply_body_collision(body: CharacterBody2D) -> void:
	body.collision_layer = COLLISION_LAYER_NPC
	body.collision_mask = COLLISION_MASK_WORLD


static func disable_body_collision(body: CharacterBody2D) -> void:
	body.collision_layer = 0
	body.collision_mask = 0
