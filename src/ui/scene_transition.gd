class_name SceneTransition
extends ColorRect
# Full-screen fade used by UI.fade_to_scene() to cover a scene change.
# Mirrors overlay.gd's ui_scale compensation so the fade always covers the
# full visible viewport, regardless of the current UI scale/offset.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()
	_hook_ui_scale_changed.call_deferred()


func fade_out(duration: float) -> void:
	show()
	move_to_front()
	var tween: Tween = create_tween()
	tween.tween_property(self, "color:a", 1.0, duration)
	await tween.finished


func fade_in(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, duration)
	await tween.finished
	hide()


func _hook_ui_scale_changed() -> void:
	var ui: Node = get_parent()
	if is_instance_valid(ui) and ui is UI:
		ui.scale_changed.connect(_on_ui_scale_changed)


func _on_ui_scale_changed() -> void:
	var ui: Node = get_parent()
	if is_instance_valid(ui) and ui is UI:
		scale = Vector2.ONE / ui.scale
		position = -ui.offset / ui.scale
