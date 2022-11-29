extends RemoteTransform2D

func _ready():
	set_remote_node(self.owner.owner.Camera2D)
