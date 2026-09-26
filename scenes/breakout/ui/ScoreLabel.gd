extends Label

@onready var scene: SceneBreakout = $"../../../"

func _ready() -> void:
	scene.score_changed.connect(_update_score_text.bind(self))
	_update_score_text(scene.score)

func _update_score_text(new_score: int):
	self.text = str(new_score)
