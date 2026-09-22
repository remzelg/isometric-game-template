# Godot 4 Jam Template

An opinionated quick-start Godot 4.4+ template for game jams. See the plain template in action at [https://hatmix.itch.io/godot-4-jam-template](https://hatmix.itch.io/godot-4-jam-template) (password `hatmix`).

A styled and modified example (for Godot 4.3) can be found at [https://hatmix.itch.io/game-jam-starter-template](https://hatmix.itch.io/game-jam-starter-template). This is an example of what the template can look like with customization. The code can be found in the release-promo branch.

Features:
* Web, Windows, Linux and macOS exports configured for maximum jam
* Github workflows for automatic uploads to Itch.io
* Premade minimal UI for main menu, pause menu, settings (with keyboard/mouse control remapping), and a thank-you screen
* Simple control audio effects and animation example (animation only on buttons, but extendable in `ui_fx.gd`)
* [G.U.I.D.E](https://godotneers.github.io/G.U.I.D.E/) for input and keyboard/mouse remapping
* Settings persisted across sessions (where `user://` filesystem is writable)
* ATTRIBUTION.md for crediting third-party assets/addons (inspired by [Maaack](https://github.com/Maaack/Godot-Game-Template/blob/main/ATTRIBUTION.md)'s approach)

> [!CAUTION]
> Note that G.U.I.D.E's approach to input handling can complicate using other addons that also deal with input!

Don't just settle for the first template you find! This template was inspired by many other examples created by the Godot community.  Compare the alternatives and decide which best fits your desired feature set, coding style, and approach to game development.

Alternatives:
* [https://github.com/Maaack/Godot-Game-Template](https://github.com/Maaack/Godot-Game-Template)
* [https://github.com/bitbrain/godot-gamejam](https://github.com/bitbrain/godot-gamejam)
* [https://github.com/nezvers/Godot-GameTemplate](https://github.com/nezvers/Godot-GameTemplate)
* [And many more...](https://godotengine.org/asset-library/asset?filter=template&category=&godot_version=&cost=&sort=updated)

This template is intended to be used at project start. While it is possible to apply updates made to the template to projects created from earlier versions of the template, it is not designed for that. Other templates may be easier to upgrade or add to an existing project.

## Getting started

There are a few ways to get started.
* The "Use this template" link in Github
* Clone the repository
* Download a zip file of the source

Once the Godot project files are saved locally, open `res://src/game/game.tscn` and create your game!

## Folder structure

`res://exports/` has folders for each pre-configured export platform

`res://media/` is intended for screenshots and other items used for documentation or the Itch.io page for the project. (See section [Publishing on Itch.io](#publishing-on-itch-io))

`res://src/autoloads/` contains scripts added to the Godot project's globals/autoloads. (See section [Settings Persistence](#settings-persistence))

`res://src/game/` you should build a game in here

`res://src/input/` contains a default G.U.I.D.E action and context mapping. (See [G.U.I.D.E documentation](https://godotneers.github.io/G.U.I.D.E/) for how to add new actions, etc.)

`res://src/ui/` is where most of the template's work is done (See section [UI](#ui)).

`res://src/ui/game/` is intended for the game UI/HUD and what comes with the template should be replaced when building your project.

It's up to your preference and the type of project whether the separation of `res://src/ui/game` and `res://src/game` makes sense.

>[!Tip]
> Save a some time while developing the game by changing Project Settings: application/run/main_scene to `res://src/game/game.tscn`. Then, change it back to `res://src/main.tscn` when the game is done. Or maybe don't. Follow your heart.

## UI

The main UI scene `res://src/ui/ui.tscn` treats its direct children extended from UiPage as components to show or hide. They might be an entire screen or just a widget in the corner. The main UI scene includes basic UI for all of the template's menus, and a stub in-game UI with pause screen.

UI components are contained in directories under `res://src/ui`. The intended approach is to keep all UI in `res://ui/ui.tscn` which is an autoload. Then, use `UI.go_to(page)`, `UI.show_ui(page)`, and `UI.hide_ui(page)` from scripts.

UiPage defines basic functions for show_ui() and hide_ui() that can be overridden/customized for animating the UI reveal.

```
├───src
│   └───ui
│       ├───assets
│       │   ├───audio
│       │   ├───fonts
│       │   └───icons
│       ├───confirmation
│       ├───controls
│       ├───game
│       ├───game_over
│       ├───level_complete
│       ├───main_menu
│       ├───pause_menu
│       ├───settings
│       ├───ui_fx
│       └───ui_page
```

The `assets` folder is for non-scene/non-code files used in the UI. `controls` holds the shared components (remap button, input-detection popup) used by the Settings page's control-remapping section.

The UI canvas layer is set `PROCESS_MODE_ALWAYS` with children inheriting the mode. The `InGameMenuOverlay` will appear when `get_tree().paused == true`. In games where pausing the tree should not hide the game area, either remove that node or have the `PauseMenu` show and hide the overaly.

UI screen borders are preserved by the UiPage MarginContainer. A second MarginContiner allows a convenient way to set screen margins for each page (with @export vars). Scaling can be tricky for fonts. Using font MSDF is recommended if the font looks good with it (Signika is one example of a font that gets bad artifacting when used with Godot's MSDF).

The project default theme is `res://src/ui/ui_theme.tres`, generated by running `res://src/ui/ui_theme.gd` in the editor (File > Run). That script inlines a small [ThemeGen](https://github.com/Inspiaaa/ThemeGen)-derived generator engine (see the file's header comment) rather than depending on the ThemeGen addon. A variant style is used for remapping controls.

Input icons are generated by G.U.I.D.E and displayed by a RichTextLabel.

## UI Navigation

The template UI is designed to work with keyboard and mouse. `Tab` and `shift+tab` move focus. Any controller input will also grab focus except where this is prevented with `UiPage.prevent_joypad_focus_capture` which is used by the game ui page.

## Settings Persistence

Settings are saved in `user://settings.cfg` and control mappings in `user://controls.tres`. Saving and loading are handled by `res://autoloads/settings.gd`.

## _Todo_ and _Fixme_ comments

Stay organized with TODO and FIXME comments in scripts and markdown files.

## Github Workflows (CI/CD)

Don't struggle to export games in the last hour before the submission deadline. Use Github workflows to do all of that for you!

The template includes a [Github action](https://docs.github.com/actions) for optionally deploying to itch.io on pushes to the main branch.

On succesful export, and if configured, the deploy workflow uses [butler](https://itch.io/docs/butler/) to deploy the game to [itch.io](https://itch.io).  Setup these secrets in your Github repository to enable push:
* ITCHIO_USERNAME
* ITCHIO_GAME
* BUTLER_API_KEY

Note that for butler uploads to work, the game page must already be created on Itch.io with one file manually uploaded. After that, butler can perform all the updates. (See [butler's documentation](https://itch.io/docs/butler/))

## Publishing on Itch.io

Publishing your game on Itch.io is not the end of your jam journey. A good looking game page will create a strong first impression before your game is played. Jannik Boysen's Easy-Releasy .png templates are included in the `media` folder to simplify making a great looking page for your game.
