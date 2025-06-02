extends CharacterBody2D

var enemy_death_effect = preload("res://Enemies/enemy_death_effect.tscn")
@export var damage_amount : int = 1
@export var health_amount : int = 3



func _on_hurtbox_area_entered(area: Area2D):
	print("bullet entered")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("health amount ",health_amount)
		if health_amount <=0 :
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
			
