extends Label

@onready var scene: SceneBreakout = $"../../../"

func _ready() -> void:
	self.scene.score_changed.connect(self._update_score_text)
	self._update_score_text(self.scene.score)

func _update_score_text(new_score: int) -> void:
	self.text = str(new_score)
