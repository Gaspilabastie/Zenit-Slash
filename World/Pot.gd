extends Node2D

func _on_Hurtbox_area_entered(_area):
	$AnimationPlayer.play("Broken")
	
