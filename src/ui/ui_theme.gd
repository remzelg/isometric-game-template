@tool
extends EditorScript
# Defines and generates res://src/ui/ui_theme.tres, the project's default theme.
# Run this script via File > Run (or the editor's "Run" toolbar button while
# this file is open) to regenerate the .tres after editing define_theme() below.
#
# The generator engine below (everything under "ThemeGen engine") is inlined
# from the ThemeGen addon (https://github.com/Inspiaaa/ThemeGen) by Inspiaaa,
# MIT licensed, since addons/theme_gen/ was removed from this project.
# stylebox_* helpers return plain Dictionary objects, not StyleBox.

const DEFAULT_FONT_SIZE: int = 8


@warning_ignore("integer_division")
# The project's default theme is set to res://ui/ui_theme.tres
func setup() -> void:
	set_save_path("res://src/ui/ui_theme.tres")


# TODO: Consider defining the UI theme below with ThemeGen or manually edit res://ui/ui_theme.tres
func define_theme() -> void:
	#define_default_font(load("res://src/ui/assets/fonts/Lato-Black.ttf"))
	define_default_font(load("res://src/ui/assets/fonts/pixelFont-2-5x5-sproutLands.ttf"))
	define_default_font_size(DEFAULT_FONT_SIZE)

	# Uncomment to set splash and clear colors in settings.
	# Not technically part of the theme, but usually changed together
	ProjectSettings.set_setting("rendering/environment/defaults/default_clear_color", Color.BLACK)
	ProjectSettings.set_setting("application/boot_splash/bg_color", Color.BLACK)
	ProjectSettings.save()

#region Control Styles
	#define_style("BoxContainer", {})
	#define_style("Button", {})
	define_variant_style("Play_button", "Button", {
		font_size = 2 * DEFAULT_FONT_SIZE,
	})
	# define_style("CheckBox", {})
	#define_style("CheckButton", {})
	#define_style("CodeEdit", {})

	# Leaving out the Color* styling

	#define_style("FlatButton", {})
	#define_style("FlatMenuButton", {})
	#define_style("FlowContainer", {})
	#define_style("FoldableContainer", {})

	# Leaving out the Graph* styling

	#define_style("GridContainer", {})

	# Grouping H* & V* nodes
	#define_style("HBoxContainer", {})
	#define_style("VBoxContainer", {})
	#define_style("HFlowContainer", {})
	#define_style("VFlowContainer", {})
	#define_style("HScrollBar", {})
	#define_style("VScrollBar", {})
	#define_style("HSeparator", {})
	#define_style("VSeparator", {})
	#define_style("HSlider", {})
	#define_style("VSlider", {})
	#define_style("HSplitContainer", {})
	#define_style("VSplitContainer", {})
	#define_style("ItemList", {})
	#define_style("Label", {})
	#define_style("LineEdit", {})
	#define_style("LinkButton", {})
	#define_style("MarginContainer", {})
	#define_style("MenuBar", {})
	#define_style("MenuButton", {})
	#define_style("OptionButton", {})
	#define_style("Panel", {})
	#define_style("PanelContainer", {})
	#define_style("ProgressBar", {})
	#define_style("RichTextLabel", {})
	#define_style("ScrollContainer", {})
	#define_style("SpinBox", {})
	#define_style("SplitContainer", {})
	#define_style("TabBar", {})
	#define_style("TabContainer", {})
	#define_style("TextEdit", {})

	# Styling for default tooltip
	#define_style("TooltipLabel", {})
	#define_style("TooltipPanel", {})

	#define_style("Tree", {})
#endregion

#region Window Styles
	#define_style("AcceptDialog", {})
	#define_style("FileDialog", {})
	#define_style("PopupDialog", {})
	#define_style("PopupMenu", {})
	#define_style("PopupPanel", {})
	#define_style("Window", {})
#endregion

#region Template remapping controls styling
	# Buttons used for remapping controls are styled to have just a border for hover and focus
	var sb_remap_button_focused: Dictionary = stylebox_flat(
		{
			border_ = border_width(2),
			border_color = Color.WHITE,
			corners_ = corner_radius(0),
			bg_color = Color.TRANSPARENT,
		}
	)
	define_variant_style(
		"RemapButton",
		"Button",
		{
			normal = stylebox_empty({}),
			focus = sb_remap_button_focused,
			pressed = sb_remap_button_focused,
			hover =
			inherit(sb_remap_button_focused, stylebox_flat({border_color = Color.DIM_GRAY})),
		}
	)
	# Empty style to prevent other style changes from affecting controls UI... but does it?
	define_variant_style("RemapRichTextLabel", "RichTextLabel", {})
#endregion


#region ThemeGen engine (inlined from addons/theme_gen/programmatic_theme.gd)
var _styles_by_name: Dictionary = {}
var _variant_to_parent_type_name: Dictionary = {}

var _default_font: Font = null
var _default_font_size = null
var _save_path = null

# The function that is run to generate the theme. Defaults to define_theme().
var _theme_generator = null

# Used to get the base type for each theme variation.
var _default_theme: Theme
# Current theme instance used by the generator, while define_theme() runs.
var _current_theme: Theme


func set_save_path(path: String) -> void:
	_save_path = path


func define_style(style_name: String, style: Dictionary) -> void:
	_styles_by_name[style_name] = style


func define_variant_style(
	style_name: String, base_type_name: String, style: Dictionary = {}
) -> void:
	_variant_to_parent_type_name[style_name] = base_type_name
	define_style(style_name, style)


func define_default_font(font: Font) -> void:
	_default_font = font


func define_default_font_size(size: int) -> void:
	_default_font_size = size


func inherit(
	base_style: Dictionary,
	style2 = null,
	style3 = null,
	style4 = null,
	style5 = null,
	style6 = null,
	style7 = null,
	style8 = null
) -> Dictionary:
	var inherited_style: Dictionary = base_style.duplicate()
	for style in [style2, style3, style4, style5, style6, style7, style8]:
		if style != null:
			inherited_style.merge(style, true)
	return inherited_style


func stylebox_flat(style: Dictionary) -> Dictionary:
	var as_dictionary: Dictionary = {"type": "stylebox_flat"}
	as_dictionary.merge(style)
	return as_dictionary


func stylebox_line(style: Dictionary) -> Dictionary:
	var as_dictionary: Dictionary = {"type": "stylebox_line"}
	as_dictionary.merge(style)
	return as_dictionary


func stylebox_empty(style: Dictionary) -> Dictionary:
	var as_dictionary: Dictionary = {"type": "stylebox_empty"}
	as_dictionary.merge(style)
	return as_dictionary


func stylebox_texture(style: Dictionary) -> Dictionary:
	var as_dictionary: Dictionary = {"type": "stylebox_texture"}
	as_dictionary.merge(style)
	return as_dictionary


func border_width(left: int, top = null, right = null, bottom = null) -> Dictionary:
	if top == null:
		top = left
	if right == null:
		right = left
	if bottom == null:
		bottom = top
	return {
		"border_width_left": left,
		"border_width_top": top,
		"border_width_right": right,
		"border_width_bottom": bottom,
	}


func corner_radius(
	top_left: int, top_right = null, bottom_right = null, bottom_left = null
) -> Dictionary:
	if top_right == null:
		top_right = top_left
	if bottom_right == null:
		bottom_right = top_right
	if bottom_left == null:
		bottom_left = top_left
	return {
		"corner_radius_top_left": top_left,
		"corner_radius_top_right": top_right,
		"corner_radius_bottom_right": bottom_right,
		"corner_radius_bottom_left": bottom_left,
	}


func expand_margins(left: int, top = null, right = null, bottom = null) -> Dictionary:
	if top == null:
		top = left
	if right == null:
		right = left
	if bottom == null:
		bottom = top
	return {
		"expand_margin_left": left,
		"expand_margin_top": top,
		"expand_margin_right": right,
		"expand_margin_bottom": bottom,
	}


func content_margins(left: int, top = null, right = null, bottom = null) -> Dictionary:
	if top == null:
		top = left
	if right == null:
		right = left
	if bottom == null:
		bottom = top
	return {
		"content_margin_left": left,
		"content_margin_top": top,
		"content_margin_right": right,
		"content_margin_bottom": bottom,
	}


func texture_margins(left: int, top = null, right = null, bottom = null) -> Dictionary:
	if top == null:
		top = left
	if right == null:
		right = left
	if bottom == null:
		bottom = top
	return {
		"texture_margin_left": left,
		"texture_margin_top": top,
		"texture_margin_right": right,
		"texture_margin_bottom": bottom,
	}


func _run() -> void:
	_default_theme = ThemeDB.get_default_theme()
	var setup_functions: Array = _discover_theme_setup_functions()
	for setup_function: Callable in setup_functions:
		_generate_theme(setup_function)


func _discover_theme_setup_functions() -> Array:
	var setup_function_names: Array = []
	for method in get_method_list():
		if method.name.begins_with("setup") and method.flags == METHOD_FLAG_NORMAL:
			setup_function_names.append(method.name)

	var unique_function_names: Array = []
	for method_name in setup_function_names:
		if method_name not in unique_function_names:
			unique_function_names.append(method_name)

	return unique_function_names.map(get)


func _generate_theme(setup_function: Callable) -> void:
	_reset()
	setup_function.call()

	if _save_path == null:
		push_error("Save path must be set before generating the theme. (See set_save_path(...))")
		return

	var theme: Theme = Theme.new()

	# Make the current theme instance available during define_theme().
	_current_theme = theme
	_theme_generator.call()
	_current_theme = null

	_load_default_font(theme)
	_load_variants(theme)

	for type_name in _styles_by_name:
		var style: Dictionary = (_styles_by_name[type_name] as Dictionary).duplicate(true)
		_preprocess_style(style)
		_load_style(theme, type_name, style)

	_save_theme(theme)


func _reset() -> void:
	_styles_by_name = {}
	_variant_to_parent_type_name = {}

	_default_font = null
	_default_font_size = null
	_save_path = null
	_current_theme = null
	_theme_generator = define_theme


func _save_theme(theme: Theme) -> void:
	_update_existing_theme_instance(theme)
	ResourceSaver.save(theme, _save_path)


func _update_existing_theme_instance(new_theme: Theme) -> void:
	# When the editor uses the generated theme file, it loads the resource
	# into memory. To make the editor UI reflect the regenerated theme
	# immediately (instead of only after an editor restart), the cached
	# resource is mutated in-place rather than just re-saved to disk.
	if not ResourceLoader.exists(_save_path):
		return

	var existing_theme = load(_save_path)
	if not existing_theme is Theme:
		return

	existing_theme.clear()
	existing_theme.merge_with(new_theme)


func _load_default_font(theme: Theme) -> void:
	if _default_font != null:
		theme.default_font = _default_font
	if _default_font_size != null:
		theme.default_font_size = _default_font_size


func _load_variants(theme: Theme) -> void:
	for variant_name in _variant_to_parent_type_name:
		theme.add_type(variant_name)

	for variant_name in _variant_to_parent_type_name:
		var parent_name = _variant_to_parent_type_name[variant_name]
		theme.set_type_variation(variant_name, parent_name)


func _load_style(theme: Theme, type_name: String, style: Dictionary) -> void:
	theme.add_type(type_name)
	for item_name in style:
		_load_style_item(theme, type_name, item_name, style[item_name])


func _preprocess_style(style: Dictionary) -> void:
	# Copy the keys, as the dictionary is modified in-place during iteration.
	var keys: Array = style.keys()
	for key in keys:
		var value = style[key]
		if value is Dictionary:
			_preprocess_style(value)

		if (key as String).ends_with("_"):
			_merge_sub_dict_into_main_dict(style, key)


func _merge_sub_dict_into_main_dict(main_dict: Dictionary, sub_dict_name: String) -> void:
	var sub_dict = main_dict[sub_dict_name]
	if not sub_dict is Dictionary:
		return

	for key in sub_dict:
		main_dict[key] = sub_dict[key]

	main_dict.erase(sub_dict_name)


func _load_style_item(theme: Theme, type_name: String, item_name: String, value) -> void:
	var data_type: int = _get_data_type_for_value(_default_theme, theme, type_name, item_name)
	if data_type == -1:
		push_error("Item name '%s' not recognized for type '%s'." % [item_name, type_name])
		return

	if data_type == Theme.DATA_TYPE_STYLEBOX:
		value = _create_stylebox_from_dict(value)

	theme.set_theme_item(data_type, item_name, type_name, value)


func _create_stylebox_from_dict(data: Dictionary) -> StyleBox:
	var stylebox: StyleBox
	match data["type"]:
		"stylebox_flat":
			stylebox = StyleBoxFlat.new()
		"stylebox_line":
			stylebox = StyleBoxLine.new()
		"stylebox_empty":
			stylebox = StyleBoxEmpty.new()
		"stylebox_texture":
			stylebox = StyleBoxTexture.new()

	for attribute in data:
		if attribute == "type":
			continue
		stylebox.set(attribute, data[attribute])

	return stylebox


func _get_data_type_for_value(
	default_theme: Theme, theme: Theme, type_name: String, item_name: String
) -> int:
	if _type_has_property(type_name, "theme_override_colors/" + item_name):
		return Theme.DATA_TYPE_COLOR
	if _type_has_property(type_name, "theme_override_constants/" + item_name):
		return Theme.DATA_TYPE_CONSTANT
	if _type_has_property(type_name, "theme_override_fonts/" + item_name):
		return Theme.DATA_TYPE_FONT
	if _type_has_property(type_name, "theme_override_font_sizes/" + item_name):
		return Theme.DATA_TYPE_FONT_SIZE
	if _type_has_property(type_name, "theme_override_icons/" + item_name):
		return Theme.DATA_TYPE_ICON
	if _type_has_property(type_name, "theme_override_styles/" + item_name):
		return Theme.DATA_TYPE_STYLEBOX

	# This type does not contain this item. Check the parent type.
	var parent: String = theme.get_type_variation_base(type_name)
	if parent == "":
		parent = default_theme.get_type_variation_base(type_name)
	if parent == "":
		return -1

	return _get_data_type_for_value(default_theme, theme, parent, item_name)


func _type_has_property(type_name: String, property_name: String) -> bool:
	if not ClassDB.class_exists(type_name):
		return false

	var properties: Array = ClassDB.instantiate(type_name).get_property_list()
	return properties.any(func(property): return property.name == property_name)
#endregion
