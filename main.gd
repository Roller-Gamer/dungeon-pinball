extends Node2D

# A deliberately lightweight vertical pinball combat prototype. The round
# characters are textures; the table, medieval UI and effects stay code-drawn.

const WARRIOR_TEXTURE := preload("res://assets/warrior.png")
const GOBLIN_TEXTURE := preload("res://assets/goblin.png")
const SFX_WALL := preload("res://assets/sfx/wall_hit.wav")
const SFX_FLIPPER := preload("res://assets/sfx/flipper_hit.wav")
const SFX_ENEMY_HIT := preload("res://assets/sfx/enemy_hit.wav")
const SFX_MIGHT := preload("res://assets/sfx/might_activate.wav")
const SFX_WAR_CRY := preload("res://assets/sfx/war cry.wav")
const SFX_MOMENTUM := preload("res://assets/sfx/momentum_chimes.wav")
const SFX_GUARD := preload("res://assets/sfx/guard_barrel.wav")
const SFX_CHARGE := preload("res://assets/sfx/charge_activate.wav")
const SFX_GATE := preload("res://assets/sfx/gate_hit.wav")
const SFX_EXPLOSION := preload("res://assets/sfx/explosion.wav")
const SFX_AXE_THROW := preload("res://assets/sfx/axe_throw.wav")
const SFX_HERO_HIT := preload("res://assets/sfx/hero_hit.wav")
const SFX_SHIELD_BLOCK := preload("res://assets/sfx/shield_block.wav")
const SFX_GOBLIN_GRUMP := preload("res://assets/sfx/goblin_grump.wav")
const SFX_ELITE_GOBLIN_DEATH := preload("res://assets/sfx/elite_goblin_die.wav")
const SFX_WARLORD_DEATH := preload("res://assets/sfx/boss1_die.wav")
const BGM_NORMAL_LEVEL := preload("res://assets/music/normal level.ogg")
const BGM_HARD_FIGHT := preload("res://assets/music/hard_fight_action.ogg")

const SCREEN := Vector2(1440.0, 900.0)
const FIELD_LEFT := 350.0
const FIELD_RIGHT := 1090.0
const FIELD_TOP := 32.0
const FIELD_BOTTOM := 886.0

const BALL_RADIUS := 14.0
const GRAVITY := 690.0
const MAX_SPEED := 1320.0
const BALL_DROP_SPEED := 120.0
const LAUNCH_Y := 570.0
const LAUNCH_MIN_X := 550.0
const LAUNCH_MAX_X := 890.0
const WORLD_RESTITUTION := 0.86
const FLIPPER_POWERED_RESTITUTION := 0.82
const FLIPPER_IDLE_RESTITUTION := 0.34
const FLIPPER_UP_SPEED := 12.5
const FLIPPER_RETURN_SPEED := 6.5
const FLIPPER_GRACE_DRIVE := 9.0
const FLIPPER_POWER_WINDOW := 0.14
const FLIPPER_LENGTH := 135.0
const LEFT_FLIPPER_PIVOT := Vector2(560.0, 790.0)
const RIGHT_FLIPPER_PIVOT := Vector2(880.0, 790.0)
const CHARGE_MIN_SPEED := 1120.0
const ENERGY_MAX := 100.0
const HERO_MAX_HP := 100
const ROOM_CLEAR_HEAL := 10
const SHIELD_MAX := 50
const GUARD_SHIELD_GAIN := 25
const ENEMY_ATTACK_INTERVAL := 0.42
const MIGHT_DURATION := 5.0
const MIGHT_COLLISION_SCALE := 1.20
const MIGHT_VISUAL_SCALE := 1.30
const WAR_CRY_DAMAGE_MULTIPLIER := 1.40
const IMPACT_PROC_BASE_COOLDOWN := 10.0
const IMPACT_PROC_MIN_COOLDOWN := 1.0
const IMPACT_COOLDOWN_REDUCTION_PER_LEVEL := 0.10
const EXPLOSION_BASE_RADIUS := 225.0
const EXPLOSION_RADIUS_PER_LEVEL := 0.20
const FINAL_ROOM := 5
const MAGE_SHIELD_PIERCE := 0.50
const WARLORD_MAX_HP := 150
const WARLORD_BASE_ATTACK := 10
const WARLORD_MINION_HEAL := 15
const WARLORD_RAGE_PER_MINION := 0.15
const WARLORD_MAX_RAGE_STACKS := 4
const WARLORD_GUARD_ORBIT_RADIUS := 88.0
const WARLORD_GUARD_ARC := deg_to_rad(28.0)
const WARLORD_GUARD_THICKNESS := 14.0
const WARLORD_GUARD_ROTATION_SPEED := deg_to_rad(18.0)
const BGM_NORMAL_VOLUME_DB := -18.0
const BGM_BOSS_VOLUME_DB := -19.0
const IRON_OATH_SHIELD_PER_HIT := 2
const IRON_OATH_SHIELD_PER_BALL_CAP := 20
const HEAVY_STRIKE_REQUIRED_HITS := 3
const HEAVY_STRIKE_DAMAGE_BONUS := 0.40
const FURY_CORE_BONUS := 5.0

const COMBAT_ART_UNLOCK_POOL := [
	{"id": "blast_impact", "name": "RUNE BLAST", "type": "COMBAT ART", "line_1": "Non-flipper bounces can explode", "line_2": "for 5 damage in 225px. CD 10s.", "color": "f18b45", "max_level": 1},
	{"id": "throwing_axe", "name": "THROWING AXE", "type": "COMBAT ART", "line_1": "Any solid bounce throws an axe", "line_2": "at a foe for 6 damage. CD 10s.", "color": "d6b679", "max_level": 1},
	{"id": "spiked_shield", "name": "SPIKED SHIELD", "type": "COMBAT ART", "line_1": "Reflect 50% of blocked damage", "line_2": "back to the attacker.", "color": "78c97a", "max_level": 1},
]

const COMBAT_ART_UPGRADE_POOL := [
	{"id": "blast_damage", "requires": "blast_impact", "name": "VOLATILE RUNES", "type": "BLAST DAMAGE", "line_1": "Rune Blast damage +25%", "line_2": "Stacks from its base damage.", "color": "f18b45", "max_level": 9},
	{"id": "blast_radius", "requires": "blast_impact", "name": "WIDENING SIGIL", "type": "BLAST AREA", "line_1": "Rune Blast radius +20%", "line_2": "Maximum three area upgrades.", "color": "ffad55", "max_level": 3},
	{"id": "blast_cooldown", "requires": "blast_impact", "name": "RAPID INSCRIPTION", "type": "BLAST COOLDOWN", "line_1": "Base cooldown -10% (-1s)", "line_2": "Can reach a minimum of 1 second.", "color": "ffcf66", "max_level": 9},
	{"id": "moving_aftershock", "requires": "blast_impact", "name": "MARCHING AFTERSHOCK", "type": "BLAST MECHANISM", "line_1": "After 0.4s, explode at the warrior", "line_2": "40% damage, 70% area; follows the ball.", "color": "ffd166", "max_level": 1},
	{"id": "axe_damage", "requires": "throwing_axe", "name": "HEAVY AXEHEAD", "type": "AXE DAMAGE", "line_1": "Throwing Axe damage +25%", "line_2": "Stacks from its base damage.", "color": "d6b679", "max_level": 9},
	{"id": "axe_count", "requires": "throwing_axe", "name": "AXE VOLLEY", "type": "AXE QUANTITY", "line_1": "Throw one additional axe", "line_2": "at another available enemy.", "color": "e3c990", "max_level": 4},
	{"id": "axe_cooldown", "requires": "throwing_axe", "name": "QUICK DRAW", "type": "AXE COOLDOWN", "line_1": "Base cooldown -10% (-1s)", "line_2": "Can reach a minimum of 1 second.", "color": "efbd61", "max_level": 9},
	{"id": "returning_axe", "requires": "throwing_axe", "name": "RETURNING AXE", "type": "AXE MECHANISM", "line_1": "Axe returns toward the moving warrior", "line_2": "and may hit another foe for 60% damage.", "color": "9ed6a0", "max_level": 1},
	{"id": "spike_damage", "requires": "spiked_shield", "name": "SHARPENED SPIKES", "type": "THORNS DAMAGE", "line_1": "All thorns damage +25%", "line_2": "Also improves Shieldbreak Retort.", "color": "78c97a", "max_level": 9},
	{"id": "spike_scatter", "requires": "spiked_shield", "name": "SCATTERING BARBS", "type": "THORNS TARGETS", "line_1": "Reflections strike +1 nearby foe", "line_2": "for 50% damage within 220px.", "color": "9bdb83", "max_level": 4},
	{"id": "shieldbreak_retort", "requires": "spiked_shield", "name": "SHIELDBREAK RETORT", "type": "THORNS MECHANISM", "line_1": "First shield break each enemy phase", "line_2": "deals 3 damage to every enemy.", "color": "b9efa7", "max_level": 1},
	{"id": "shield_bash", "requires": "spiked_shield", "name": "SHIELD BASH", "type": "THORNS MECHANISM", "line_1": "Direct hits gain +1 per 10 Shield", "line_2": "Maximum +5; Shield is not consumed.", "color": "d8e7a5", "max_level": 1},
]

const TRAINING_POOL := [
	{"id": "sharpened_blade", "name": "SHARPENED BLADE", "type": "POWER TRAINING", "line_1": "Direct impact damage +25%", "line_2": "A reliable additive increase.", "color": "e66f4f", "max_level": 9},
	{"id": "windrunner_boots", "name": "WINDRUNNER BOOTS", "type": "MOMENTUM TRAINING", "line_1": "Flipper force and speed cap +8%", "line_2": "More speed, more impact damage.", "color": "65d5e8", "max_level": 9},
	{"id": "giants_belt", "name": "GIANT'S BELT", "type": "MIGHT TRAINING", "line_1": "Permanent size +10%", "line_2": "Size also adds impact damage.", "color": "efbd61", "max_level": 6},
	{"id": "shield_training", "name": "SHIELD TRAINING", "type": "GUARD TRAINING", "line_1": "All Shield gained +25%", "line_2": "Applies to Iron Oath and GUARD.", "color": "78c97a", "max_level": 9},
	{"id": "residual_shield", "name": "HOLD THE LINE", "type": "SHIELD RETENTION", "line_1": "Keep Shield after the enemy phase", "line_2": "25% first, then +10% each level.", "color": "9cc7bd", "max_level": 9},
]

const STARTING_STYLES := [
	{"id": "iron_oath", "name": "IRON OATH", "type": "GUARDIAN", "line_1": "Direct enemy hits grant +2 Shield.", "line_2": "Maximum 20 Shield gained each ball.", "color": "78c97a"},
	{"id": "heavy_strike", "name": "HEAVY STRIKE", "type": "ASSAULT", "line_1": "After 3 direct hits, arm one heavy blow.", "line_2": "Next direct hit deals +40% damage.", "color": "efbd61"},
	{"id": "fury_core", "name": "FURY CORE", "type": "TACTICS", "line_1": "Direct enemy hits gain +5 extra Fury.", "line_2": "Reach GUARD and CHARGE more often.", "color": "65d5e8"},
]

const BG := Color("120f0d")
const PANEL := Color("2a211a")
const FIELD_BG := Color("182622")
const CYAN := Color("65d5e8")
const BLUE := Color("497ca5")
const GOLD := Color("efbd61")
const RED := Color("d95249")
const GREEN := Color("78c97a")
const MUTED := Color("b7aa8e")
const STONE_DARK := Color("252a28")
const STONE := Color("3d4540")
const WOOD_DARK := Color("2a1710")
const WOOD := Color("68402a")
const PARCHMENT := Color("d1b77e")
const PARCHMENT_DARK := Color("8d7047")
const BRONZE := Color("a8793b")
const RUNE := Color("79deed")
const ARCANE := Color("b77be8")

var walls: Array[Dictionary] = []
var gate_panels: Array[Dictionary] = []
var bumpers: Array[Dictionary] = []
var diamond_deflectors: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var skill_panels: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var floating_text: Array[Dictionary] = []
var shockwaves: Array[Dictionary] = []
var explosions: Array[Dictionary] = []
var pending_aftershocks: Array[Dictionary] = []
var flying_axes: Array[Dictionary] = []
var warlord_soul_streams: Array[Dictionary] = []
var warlord_guard_rotation := 0.0
var warlord_guard_hit_cooldown := 0.0
var trail: Array[Vector2] = []

var ball_position := Vector2(720.0, LAUNCH_Y)
var ball_velocity := Vector2.ZERO
var ball_active := false
var waiting_for_launch := true
var launch_x := 720.0
var board_hover_type := ""
var board_hover_index := -1
var board_hover_mouse := Vector2.ZERO

var left_angle := 0.34
var right_angle := -0.34
var left_angular_velocity := 0.0
var right_angular_velocity := 0.0
var left_active := false
var right_active := false
var left_power_timer := 0.0
var right_power_timer := 0.0
var flipper_contact_lock := 0.0

var energy := 0.0
var charge_timer := 0.0
var dash_fx_timer := 0.0
var might_timer := 0.0
var war_cry_ready := false
var hero_hp := HERO_MAX_HP
var last_room_heal := 0
var shield := 0
var score := 0
var wave := 1
var stage_room := 1
var combo := 0
var combo_timer := 0.0
var wave_clear_timer := -1.0
var screen_flash := 0.0
var screen_shake_timer := 0.0
var screen_shake_strength := 0.0
var screen_shake_offset := Vector2.ZERO
var damage_vignette := 0.0
var status_text := ""
var status_timer := 0.0
var game_over := false
var run_complete := false
var enemy_phase_active := false
var enemy_phase_timer := 0.0
var enemy_attack_queue: Array[Dictionary] = []
var enemy_attack_index := 0
var enemy_phase_incoming_total := 0

var smoke_mode := false
var smoke_frames := 0
var passive_test_mode := false
var passive_test_frames := 0
var passive_enemy_phase_seen := false
var passive_expected_hp := HERO_MAX_HP
var upgrade_preview_mode := false
var mechanism_preview_mode := false
var effects_preview_mode := false
var mage_preview_mode := false
var boss_preview_mode := false
var progression_test_mode := false
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_cursor := 0
var bgm_player: AudioStreamPlayer
var bgm_normal_stream: AudioStreamOggVorbis
var bgm_boss_stream: AudioStreamOggVorbis
var current_bgm_id := ""
var wall_sfx_cooldown := 0.0
var gate_hit_cooldown := 0.0
var gate_hit_timer := 0.0

var upgrade_levels: Dictionary = {}
var upgrade_history: Array[String] = []
var upgrade_selection_active := false
var upgrade_selection_timer := 0.0
var upgrade_exit_timer := -1.0
var upgrade_selected_index := -1
var upgrade_hover_index := -1
var upgrade_choices: Array[Dictionary] = []
var upgrade_reward_kind := ""

var starting_style_id := ""
var starting_style_selection_active := false
var starting_style_selection_timer := 0.0
var starting_style_carousel_index := 0
var starting_style_carousel_anim := 0.0
var starting_style_carousel_direction := 0
var starting_style_hover_direction := 0
var starting_style_confirm_hover := false
var shield_gained_this_ball := 0
var heavy_strike_hits := 0
var heavy_strike_ready := false

var attack_power_multiplier := 1.0
var speed_upgrade_bonus := 0.0
var permanent_size_scale := 1.0
var spring_plate_level := 0
var spring_rebound_ready := false
var blast_impact_level := 0
var blast_impact_cooldown := 0.0
var blast_damage_level := 0
var blast_radius_level := 0
var blast_cooldown_level := 0
var moving_aftershock_level := 0
var throwing_axe_level := 0
var throwing_axe_cooldown := 0.0
var axe_damage_level := 0
var axe_count_level := 0
var axe_cooldown_level := 0
var returning_axe_level := 0
var spiked_shield_level := 0
var spike_damage_level := 0
var spike_scatter_level := 0
var shieldbreak_retort_level := 0
var shield_bash_level := 0
var shieldbreak_triggered_this_phase := false
var shield_training_level := 0
var residual_shield_level := 0
var shield_gain_fraction := 0.0


func _ready() -> void:
	_setup_audio()
	_setup_table()
	restart_run()
	var command_line := OS.get_cmdline_user_args()
	smoke_mode = "--smoke-test" in command_line
	passive_test_mode = "--passive-test" in command_line
	upgrade_preview_mode = "--upgrade-preview" in command_line
	mechanism_preview_mode = "--mechanism-preview" in command_line
	effects_preview_mode = "--effects-preview" in command_line
	mage_preview_mode = "--mage-preview" in command_line
	boss_preview_mode = "--boss-preview" in command_line
	progression_test_mode = "--progression-test" in command_line
	if smoke_mode:
		_select_starting_style(2)
		energy = ENERGY_MAX
		launch_ball()
	elif passive_test_mode:
		_select_starting_style(2)
		shield = GUARD_SHIELD_GAIN
		launch_ball()
	elif upgrade_preview_mode:
		starting_style_selection_active = false
		enemies.clear()
		_show_upgrade_selection()
		upgrade_choices = [
			_upgrade_definition("blast_impact"),
			_upgrade_definition("throwing_axe"),
			_upgrade_definition("spiked_shield"),
		]
	elif mechanism_preview_mode:
		starting_style_selection_active = false
		enemies.clear()
		_show_upgrade_selection()
		upgrade_reward_kind = "ART_UPGRADE"
		upgrade_choices = [
			_upgrade_definition("moving_aftershock"),
			_upgrade_definition("returning_axe"),
			_upgrade_definition("shield_bash"),
		]
	elif effects_preview_mode:
		starting_style_selection_active = false
		waiting_for_launch = false
		ball_active = false
		blast_impact_level = 1
		moving_aftershock_level = 1
		throwing_axe_level = 1
		returning_axe_level = 1
		_trigger_blast_impact(Vector2(720.0, 350.0))
		_launch_throwing_axes(enemies[0].pos)
	elif mage_preview_mode:
		_select_starting_style(0)
		stage_room = 3
		wave = 3
		_spawn_wave()
		prepare_ball()
		_update_board_hover(enemies[1].pos)
	elif boss_preview_mode:
		_select_starting_style(1)
		stage_room = 5
		wave = 5
		_spawn_wave()
		prepare_ball()
	elif progression_test_mode:
		call_deferred("_run_progression_test")
	queue_redraw()


func _upgrade_definition(id: String) -> Dictionary:
	for pool in [COMBAT_ART_UNLOCK_POOL, COMBAT_ART_UPGRADE_POOL, TRAINING_POOL]:
		for definition in pool:
			if String(definition.id) == id:
				return definition.duplicate(true)
	return {}


func _run_progression_test() -> void:
	if enemies.size() != 5 or stage_room != 1 or current_bgm_id != "normal" or bgm_player == null or bgm_player.stream != bgm_normal_stream or not bgm_normal_stream.loop or not bgm_boss_stream.loop or _enemy_death_sfx_id(enemies[0]) != "elite" or _enemy_death_sfx_id(enemies[1]) != "grunt" or COMBAT_ART_UNLOCK_POOL.size() != 3 or COMBAT_ART_UPGRADE_POOL.size() != 12 or TRAINING_POOL.size() != 5 or _goblin_gate_active() or bumpers.size() != 2 or String(bumpers[0].id) != "momentum" or not diamond_deflectors.is_empty() or walls[9].a != Vector2(620, 285) or walls[10].a != Vector2(820, 285):
		push_error("Progression test failed: invalid stage 1 setup")
		_quit_test(2)
		return
	if not starting_style_selection_active or STARTING_STYLES.size() != 3:
		push_error("Progression test failed: starting style selection missing")
		_quit_test(2)
		return
	starting_style_selection_timer = 0.30
	var carousel_click := InputEventMouseButton.new()
	carousel_click.button_index = MOUSE_BUTTON_LEFT
	carousel_click.pressed = true
	carousel_click.position = _starting_style_side_rect(1).get_center()
	_unhandled_input(carousel_click)
	if not starting_style_selection_active or starting_style_carousel_index != 1 or not starting_style_id.is_empty():
		push_error("Progression test failed: carousel side preview selected instead of focusing")
		_quit_test(2)
		return
	carousel_click.position = _starting_style_confirm_rect().get_center()
	_unhandled_input(carousel_click)
	if starting_style_selection_active or starting_style_id != "heavy_strike":
		push_error("Progression test failed: carousel confirmation did not select style")
		_quit_test(2)
		return
	var style_test_enemy: Dictionary = enemies[0]
	ball_velocity = Vector2(400.0, 0.0)
	combo = 0
	energy = 0.0
	for _hit in HEAVY_STRIKE_REQUIRED_HITS:
		_damage_enemy(style_test_enemy)
	if not heavy_strike_ready or heavy_strike_hits != HEAVY_STRIKE_REQUIRED_HITS:
		push_error("Progression test failed: Heavy Strike did not arm")
		_quit_test(2)
		return
	var hp_before_heavy := int(style_test_enemy.hp)
	_damage_enemy(style_test_enemy)
	var heavy_damage := hp_before_heavy - int(style_test_enemy.hp)
	if heavy_damage != 13 or heavy_strike_ready or heavy_strike_hits != 0:
		push_error("Progression test failed: Heavy Strike damage=%d ready=%s hits=%d" % [heavy_damage, heavy_strike_ready, heavy_strike_hits])
		_quit_test(2)
		return
	starting_style_id = "iron_oath"
	shield = 0
	shield_gained_this_ball = 0
	style_test_enemy.hp = style_test_enemy.max_hp
	_damage_enemy(style_test_enemy)
	if shield != IRON_OATH_SHIELD_PER_HIT or shield_gained_this_ball != IRON_OATH_SHIELD_PER_HIT:
		push_error("Progression test failed: Iron Oath shield=%d" % shield)
		_quit_test(2)
		return
	starting_style_id = "fury_core"
	combo = 0
	energy = 0.0
	style_test_enemy.hp = style_test_enemy.max_hp
	_damage_enemy(style_test_enemy)
	var fury_gain := energy
	if absf(fury_gain - 16.5) > 0.01:
		push_error("Progression test failed: Fury Core gain=%.1f" % fury_gain)
		_quit_test(2)
		return
	starting_style_id = "heavy_strike"
	style_test_enemy.hp = style_test_enemy.max_hp
	style_test_enemy.dead = false
	style_test_enemy.hit_cooldown = 0.0
	combo = 0
	combo_timer = 0.0
	energy = 0.0
	shield = 0
	score = 0
	particles.clear()
	floating_text.clear()
	prepare_ball()
	for requested_x in [0.0, SCREEN.x]:
		_set_launch_x(requested_x)
		var expected_x := LAUNCH_MIN_X if requested_x <= 0.0 else LAUNCH_MAX_X
		if absf(ball_position.x - expected_x) > 0.01 or absf(ball_position.y - LAUNCH_Y) > 0.01:
			push_error("Progression test failed: mouse launch clamp")
			_quit_test(2)
			return
		# Combat-art procs may remove defeated enemies while this pass is running;
		# iterate a shallow copy so the remaining collision checks stay stable.
		for enemy in enemies.duplicate():
			if ball_position.distance_to(enemy.pos) <= BALL_RADIUS + float(enemy.radius):
				push_error("Progression test failed: launch position overlaps enemy")
				_quit_test(2)
				return
		for panel in skill_panels:
			if ball_position.distance_to(panel.pos) <= BALL_RADIUS + float(panel.radius):
				push_error("Progression test failed: launch position overlaps skill panel")
				_quit_test(2)
				return
	var trigger_test_velocity := Vector2(320.0, -240.0)
	var momentum_test: Dictionary = bumpers[0]
	var momentum_test_pos: Vector2 = momentum_test.pos
	momentum_test.inside = false
	momentum_test.cooldown = 0.0
	ball_position = momentum_test.pos
	ball_velocity = trigger_test_velocity
	_update_combat_rune_trigger(momentum_test)
	if ball_position != momentum_test_pos or ball_velocity.normalized().dot(trigger_test_velocity.normalized()) < 0.999 or absf(ball_velocity.length() - trigger_test_velocity.length() * 1.30) > 0.01:
		push_error("Progression test failed: Momentum trigger blocked or deflected the ball")
		_quit_test(2)
		return
	var guard_test: Dictionary = skill_panels[0]
	var guard_test_pos: Vector2 = guard_test.pos
	guard_test.inside = false
	guard_test.cooldown = 0.0
	energy = ENERGY_MAX
	shield = 0
	ball_position = guard_test.pos
	ball_velocity = trigger_test_velocity
	_update_fury_skill_trigger(guard_test)
	if ball_position != guard_test_pos or not ball_velocity.is_equal_approx(trigger_test_velocity) or shield != GUARD_SHIELD_GAIN or energy > 0.01:
		push_error("Progression test failed: Guard trigger blocked or deflected the ball")
		_quit_test(2)
		return
	momentum_test.cooldown = 0.0
	momentum_test.inside = false
	guard_test.cooldown = 0.0
	guard_test.inside = false
	energy = 0.0
	shield = 0
	score = 0
	particles.clear()
	floating_text.clear()
	var deflector_faces_reflected := 0
	prepare_ball()
	_update_board_hover(bumpers[0].pos)
	var rune_hover_info := _board_hover_info()
	if board_hover_type != "combat_rune" or String(rune_hover_info.get("title", "")) != "MOMENTUM":
		push_error("Progression test failed: combat rune hover info")
		_quit_test(2)
		return
	_update_board_hover(enemies[0].pos)
	if board_hover_type != "enemy" or _board_hover_info().is_empty():
		push_error("Progression test failed: enemy hover info")
		_quit_test(2)
		return
	var launch_click := InputEventMouseButton.new()
	launch_click.button_index = MOUSE_BUTTON_LEFT
	launch_click.pressed = true
	launch_click.position = Vector2(720.0, LAUNCH_Y)
	_unhandled_input(launch_click)
	if waiting_for_launch or not ball_active or absf(ball_position.x - 720.0) > 0.01 or ball_velocity.y <= 0.0 or absf(ball_velocity.x) > 0.01:
		push_error("Progression test failed: left click did not release ball straight down")
		_quit_test(2)
		return
	_debug_clear_stage()
	if not enemies.is_empty() or wave_clear_timer < 0.0:
		push_error("Progression test failed: K shortcut clear")
		_quit_test(2)
		return
	wave_clear_timer = -1.0
	hero_hp = HERO_MAX_HP - 16
	_finish_room_clear()
	if upgrade_reward_kind != "ART_UNLOCK" or hero_hp != HERO_MAX_HP - 6 or last_room_heal != ROOM_CLEAR_HEAL:
		push_error("Progression test failed: first reward or room-clear healing")
		_quit_test(2)
		return
	upgrade_choices = [_upgrade_definition("blast_impact"), _upgrade_definition("throwing_axe"), _upgrade_definition("spiked_shield")]
	var offered_count := upgrade_choices.size()
	if offered_count != 3:
		push_error("Progression test failed: reward choice count")
		_quit_test(2)
		return
	_select_upgrade(0)
	if blast_impact_level != 1 or upgrade_history.size() != 1:
		push_error("Progression test failed: reward not applied")
		_quit_test(2)
		return
	_advance_to_next_room()
	var soldier_count := 0
	for stage_two_enemy in enemies:
		if String(stage_two_enemy.kind) == "soldier":
			soldier_count += 1
	if stage_room != 2 or enemies.size() != 5 or soldier_count != 2 or blast_impact_level != 1 or diamond_deflectors.size() != 1 or _goblin_gate_active():
		push_error("Progression test failed: stage 1-2 transition")
		_quit_test(2)
		return
	var test_deflector: Dictionary = diamond_deflectors[0]
	var test_deflector_center: Vector2 = test_deflector.pos
	var test_deflector_points := _diamond_deflector_points(test_deflector)
	for edge_index in 4:
		var edge_start: Vector2 = test_deflector_points[edge_index]
		var edge_end: Vector2 = test_deflector_points[(edge_index + 1) % 4]
		var midpoint := edge_start.lerp(edge_end, 0.5)
		var outward := (midpoint - test_deflector_center).normalized()
		ball_position = midpoint + outward * (_current_ball_radius() + float(test_deflector.thickness) * 0.5 - 0.5)
		ball_velocity = -outward * 400.0
		if _collide_segment(edge_start, edge_end, float(test_deflector.thickness), float(test_deflector.restitution), 0.02) and ball_velocity.dot(outward) > 0.0:
			deflector_faces_reflected += 1
	if deflector_faces_reflected != 4:
		push_error("Progression test failed: stage 1-2 diamond reflected %d/4 faces" % deflector_faces_reflected)
		_quit_test(2)
		return
	explosions.clear()
	flying_axes.clear()
	blast_impact_cooldown = 0.0
	hero_hp = HERO_MAX_HP
	last_room_heal = 0
	shield = 0
	ball_velocity = Vector2(800.0, 0.0)
	_damage_enemy(enemies[0])
	if blast_impact_cooldown > 0.0 or not explosions.is_empty():
		push_error("Progression test failed: enemy collision still triggered blast")
		_quit_test(2)
		return
	throwing_axe_level = 1
	blast_damage_level = 1
	blast_cooldown_level = 9
	axe_damage_level = 1
	axe_count_level = 2
	axe_cooldown_level = 9
	_on_ball_bounce(Vector2(720.0, 760.0), false)
	if not explosions.is_empty() or blast_impact_cooldown > 0.0 or flying_axes.size() != 3:
		push_error("Progression test failed: flipper proc filtering")
		_quit_test(2)
		return
	flying_axes.clear()
	throwing_axe_cooldown = 0.0
	var blast_hp_before: Array[int] = []
	for blast_target in enemies:
		blast_hp_before.append(int(blast_target.hp))
	_on_ball_bounce(Vector2(720.0, 350.0))
	if absf(blast_impact_cooldown - 1.0) > 0.001 or absf(throwing_axe_cooldown - 1.0) > 0.001:
		push_error("Progression test failed: proc cooldowns")
		_quit_test(2)
		return
	if explosions.is_empty() or flying_axes.size() != 3:
		push_error("Progression test failed: proc animations")
		_quit_test(2)
		return
	var blast_targets_hit := 0
	for blast_index in enemies.size():
		if int(enemies[blast_index].hp) < blast_hp_before[blast_index]:
			blast_targets_hit += 1
	if blast_targets_hit != 3:
		push_error("Progression test failed: rune blast hit %d targets instead of 3" % blast_targets_hit)
		_quit_test(2)
		return

	# Marching Aftershock deliberately stores no origin. Move the warrior after
	# the first blast and verify that the delayed explosion resolves at the new
	# position, damaging a target that was nowhere near the original impact.
	explosions.clear()
	flying_axes.clear()
	pending_aftershocks.clear()
	moving_aftershock_level = 1
	var aftershock_target: Dictionary = enemies[-1]
	aftershock_target.hp = aftershock_target.max_hp
	var aftershock_hp_before := int(aftershock_target.hp)
	_trigger_blast_impact(Vector2(FIELD_LEFT + 20.0, FIELD_BOTTOM - 20.0))
	if pending_aftershocks.size() != 1:
		push_error("Progression test failed: moving aftershock was not scheduled")
		_quit_test(2)
		return
	ball_position = aftershock_target.pos
	_update_effects(0.41)
	if not pending_aftershocks.is_empty() or explosions.is_empty() or String(explosions[-1].get("kind", "")) != "aftershock" or Vector2(explosions[-1].pos) != ball_position or int(aftershock_target.hp) >= aftershock_hp_before:
		push_error("Progression test failed: aftershock did not follow the warrior")
		_quit_test(2)
		return

	# The outbound axe remembers only which foe it already hit. Its return end
	# follows ball_position and may strike one different enemy along the way.
	flying_axes.clear()
	pending_aftershocks.clear()
	returning_axe_level = 1
	var saved_axe_count := axe_count_level
	axe_count_level = 0
	var outbound_enemy: Dictionary = enemies[0]
	var return_enemy: Dictionary = enemies[1]
	outbound_enemy.hp = outbound_enemy.max_hp
	return_enemy.hp = return_enemy.max_hp
	throwing_axe_cooldown = 0.0
	_launch_throwing_axes(outbound_enemy.pos)
	_update_effects(1.0)
	if flying_axes.size() != 1 or String(flying_axes[0].get("phase", "")) != "return":
		push_error("Progression test failed: axe did not begin its return")
		_quit_test(2)
		return
	var return_hp_before := int(return_enemy.hp)
	ball_position = return_enemy.pos
	_update_effects(1.0)
	if not flying_axes.is_empty() or int(return_enemy.hp) >= return_hp_before:
		push_error("Progression test failed: returning axe did not follow/hit a second foe")
		_quit_test(2)
		return
	axe_count_level = saved_axe_count

	# Shield Bash is additive direct-hit damage based on current Shield. It must
	# neither spend Shield nor leak into blast/axe secondary damage.
	var bash_target: Dictionary = enemies[0]
	bash_target.hp = bash_target.max_hp
	bash_target.dead = false
	ball_velocity = Vector2(400.0, 0.0)
	heavy_strike_hits = 0
	heavy_strike_ready = false
	shield_bash_level = 0
	var base_hp_before := int(bash_target.hp)
	_damage_enemy(bash_target)
	var base_direct_damage := base_hp_before - int(bash_target.hp)
	bash_target.hp = bash_target.max_hp
	bash_target.dead = false
	heavy_strike_hits = 0
	heavy_strike_ready = false
	shield_bash_level = 1
	shield = SHIELD_MAX
	var bash_hp_before := int(bash_target.hp)
	_damage_enemy(bash_target)
	var bash_damage := bash_hp_before - int(bash_target.hp)
	if bash_damage != base_direct_damage + 5 or shield != SHIELD_MAX:
		push_error("Progression test failed: shield bash damage=%d base=%d shield=%d" % [bash_damage, base_direct_damage, shield])
		_quit_test(2)
		return

	spiked_shield_level = 1
	shield = 10
	var reflected_target: Dictionary = enemies[0]
	var hp_before_reflect := int(reflected_target.hp)
	_resolve_enemy_attack({"from": reflected_target.pos, "damage": 10, "kind": reflected_target.kind, "effect": reflected_target.attack_effect})
	if hero_hp != HERO_MAX_HP or shield != 0 or int(reflected_target.hp) != hp_before_reflect - 5:
		push_error("Progression test failed: spiked shield reflection")
		_quit_test(2)
		return
	_spawn_wave()
	spike_damage_level = 1
	spike_scatter_level = 1
	shieldbreak_retort_level = 1
	shieldbreak_triggered_this_phase = false
	shield = 10
	hero_hp = HERO_MAX_HP
	var retort_hp_before: Array[int] = []
	for retort_enemy in enemies:
		retort_hp_before.append(int(retort_enemy.hp))
	_resolve_enemy_attack({"from": enemies[0].pos, "damage": 10, "kind": enemies[0].kind, "effect": enemies[0].attack_effect})
	var retort_targets_hit := 0
	for retort_index in enemies.size():
		if int(enemies[retort_index].hp) < retort_hp_before[retort_index]:
			retort_targets_hit += 1
	if retort_targets_hit != 5 or not shieldbreak_triggered_this_phase:
		push_error("Progression test failed: full-screen shieldbreak hit %d targets" % retort_targets_hit)
		_quit_test(2)
		return
	shield_training_level = 1
	shield_gain_fraction = 0.0
	shield = 0
	var trained_gain_one := _gain_shield(2)
	var trained_gain_two := _gain_shield(2)
	if trained_gain_one != 2 or trained_gain_two != 3 or shield != 5:
		push_error("Progression test failed: fractional shield training %d/%d" % [trained_gain_one, trained_gain_two])
		_quit_test(2)
		return
	residual_shield_level = 1
	shield = 20
	_finish_enemy_phase()
	var first_retained_shield := shield
	residual_shield_level = 2
	shield = 20
	_finish_enemy_phase()
	var second_retained_shield := shield
	if first_retained_shield != 5 or second_retained_shield != 7:
		push_error("Progression test failed: residual shield %d/%d" % [first_retained_shield, second_retained_shield])
		_quit_test(2)
		return
	# Walk the remaining reward cadence and verify the requested room variants.
	residual_shield_level = 0
	for expected_room in [3, 4, 5]:
		_show_upgrade_selection()
		var expected_reward_kind := "TRAINING" if stage_room == 3 else "ART_UPGRADE"
		if upgrade_reward_kind != expected_reward_kind:
			push_error("Progression test failed: reward cadence at 1-%d" % stage_room)
			_quit_test(2)
			return
		upgrade_choices.clear()
		if upgrade_reward_kind == "TRAINING":
			upgrade_choices.append(_upgrade_definition("residual_shield"))
		else:
			upgrade_choices.append(_upgrade_definition("blast_damage"))
		_select_upgrade(0)
		_advance_to_next_room()
		var later_mages := 0
		var later_soldiers := 0
		var later_warlords := 0
		var centre_melee_count := 0
		for later_enemy in enemies:
			if String(later_enemy.kind) == "mage":
				later_mages += 1
			if String(later_enemy.kind) == "soldier":
				later_soldiers += 1
			if bool(later_enemy.get("is_warlord", false)):
				later_warlords += 1
			if String(later_enemy.kind) == "grunt" and later_enemy.pos == Vector2(720, 395):
				centre_melee_count += 1
		var expected_enemy_count := 6 if expected_room == 3 else 5
		var expected_diamond_count := 1 if expected_room == 4 else 0
		var expected_centre_melee := 1 if expected_room == 3 else 0
		var expected_warlords := 1 if expected_room == 5 else 0
		var expected_soldiers := 2 if expected_room == 5 else 0
		if stage_room != expected_room or enemies.size() != expected_enemy_count or later_mages != 2 or later_soldiers != expected_soldiers or later_warlords != expected_warlords or diamond_deflectors.size() != expected_diamond_count or centre_melee_count != expected_centre_melee or _goblin_gate_active():
			push_error("Progression test failed: room 1-%d layout/roster" % expected_room)
			_quit_test(2)
			return
		if expected_room == 3:
			var mage_enemy: Dictionary = {}
			for candidate in enemies:
				if String(candidate.kind) == "mage":
					mage_enemy = candidate
					break
			_update_board_hover(mage_enemy.pos)
			var mage_hover_info := _board_hover_info()
			if board_hover_type != "enemy" or not String(mage_hover_info.get("line_2", "")).contains("50%"):
				push_error("Progression test failed: stage 1-3 mage hover info")
				_quit_test(2)
				return
			shield = 10
			hero_hp = HERO_MAX_HP
			var mage_damage := int(mage_enemy.attack)
			var expected_pierce := int(round(float(mage_damage) * MAGE_SHIELD_PIERCE))
			var expected_blocked := mini(10, mage_damage - expected_pierce)
			_resolve_enemy_attack({"from": mage_enemy.pos, "damage": mage_damage, "shield_pierce": float(mage_enemy.shield_pierce), "kind": mage_enemy.kind, "effect": mage_enemy.attack_effect})
			if hero_hp != HERO_MAX_HP - expected_pierce or shield != 10 - expected_blocked:
				push_error("Progression test failed: stage 1-3 mage shield pierce")
				_quit_test(2)
				return
			hero_hp = HERO_MAX_HP
			shield = 0
		elif expected_room == 5:
			var warlord := _living_warlord()
			if warlord.is_empty() or warlord.pos != Vector2(720, 395) or int(warlord.max_hp) != WARLORD_MAX_HP or int(warlord.attack) != WARLORD_BASE_ATTACK or _warlord_guard_count() != 4 or _enemy_death_sfx_id(warlord) != "boss" or current_bgm_id != "boss" or bgm_player.stream != bgm_boss_stream:
				push_error("Progression test failed: final warlord setup")
				_quit_test(2)
				return
			# A direct warrior approach must rebound from the bound guard without
			# damaging the Warlord. Secondary combat-art damage bypasses the arc.
			warlord_guard_rotation = 0.0
			var guard_segment := _warlord_guard_segment(warlord, 0)
			var guard_outward: Vector2 = (guard_segment.centre - warlord.pos).normalized()
			ball_position = guard_segment.centre + guard_outward * (_current_ball_radius() + WARLORD_GUARD_THICKNESS * 0.5 - 0.5)
			ball_velocity = -guard_outward * 400.0
			blast_impact_cooldown = 1.0
			throwing_axe_cooldown = 1.0
			var guarded_hp := int(warlord.hp)
			if not _collide_warlord_guards() or ball_velocity.dot(guard_outward) <= 0.0 or int(warlord.hp) != guarded_hp:
				push_error("Progression test failed: Warlord guard direct block")
				_quit_test(2)
				return
			_deal_secondary_damage(warlord, 5, Color("e8c985"), "TEST ART")
			if int(warlord.hp) != guarded_hp - 5:
				push_error("Progression test failed: combat art guard bypass")
				_quit_test(2)
				return
			warlord.hp = 90
			var warlord_minions: Array[Dictionary] = []
			for boss_room_enemy in enemies:
				if not bool(boss_room_enemy.get("is_warlord", false)):
					warlord_minions.append(boss_room_enemy)
			for boss_minion in warlord_minions:
				_deal_secondary_damage(boss_minion, int(boss_minion.hp), Color("e8c985"), "TEST")
			_remove_dead_enemies()
			_update_board_hover(warlord.pos)
			var warlord_hover := _board_hover_info()
			if enemies.size() != 1 or _warlord_guard_count() != 0 or int(warlord.hp) != WARLORD_MAX_HP or int(warlord.rage_stacks) != WARLORD_MAX_RAGE_STACKS or int(warlord.attack) != 16 or warlord_soul_streams.size() != WARLORD_MAX_RAGE_STACKS or not String(warlord_hover.get("line_2", "")).contains("+15 HP") or not String(warlord_hover.get("role", "")).contains("GUARD 0/4"):
				push_error("Progression test failed: warlord Blood Tribute")
				_quit_test(2)
				return
			_deal_secondary_damage(warlord, int(warlord.hp), Color("e8c985"), "TEST")
			_remove_dead_enemies()
	_finish_room_clear()
	if not run_complete:
		push_error("Progression test failed: final room completion")
		_quit_test(2)
		return
	print("PROGRESSION_OK stage=1-%d layouts=empty,soldiers,centre-melee,mages,warlord diamond_faces=%d styles=3 heavy=%d oath=%d fury=%.1f rewards=split blast_targets=%d aftershock=follows axe_return=second-target shield_bash=+5 axes=%d cooldown_min=%.1f thorns=5 retort_targets=%d shield_gain=2+3 retain=%d/%d warlord=150hp+15x4/rage60%% guards=4>0 direct=blocked arts=bypass bgm=normal>boss deaths=grunt/elite/boss" % [stage_room, deflector_faces_reflected, heavy_damage, IRON_OATH_SHIELD_PER_HIT, fury_gain, blast_targets_hit, 1 + axe_count_level, _impact_proc_cooldown(9), retort_targets_hit, first_retained_shield, second_retained_shield])
	for player in sfx_players:
		player.stop()
		player.stream = null
	if bgm_player != null:
		bgm_player.stop()
		bgm_player.stream = null
	await get_tree().create_timer(0.75).timeout
	get_tree().quit(0)


func _setup_audio() -> void:
	# A small voice pool allows a shield clang and body impact to overlap while
	# keeping every effect routed through one reusable playback function.
	for _index in 8:
		var player := AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		sfx_players.append(player)
	# Music uses one dedicated voice so it never consumes an impact channel.
	# Both supplied tracks are long-form loops; stage 1-1 through 1-4 share the
	# normal track without restarting it, and only the boss-room identity swaps it.
	# Duplicate imported resources before enabling loops; preloaded constants are
	# immutable in GDScript and should not be edited in place.
	bgm_normal_stream = BGM_NORMAL_LEVEL.duplicate() as AudioStreamOggVorbis
	bgm_boss_stream = BGM_HARD_FIGHT.duplicate() as AudioStreamOggVorbis
	bgm_normal_stream.loop = true
	bgm_boss_stream.loop = true
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = &"Master"
	add_child(bgm_player)


func _sync_bgm() -> void:
	if bgm_player == null:
		return
	var desired_id := "boss" if stage_room == FINAL_ROOM else "normal"
	if current_bgm_id == desired_id and bgm_player.playing:
		return
	bgm_player.stop()
	if desired_id == "boss":
		bgm_player.stream = bgm_boss_stream
		bgm_player.volume_db = BGM_BOSS_VOLUME_DB
	else:
		bgm_player.stream = bgm_normal_stream
		bgm_player.volume_db = BGM_NORMAL_VOLUME_DB
	bgm_player.play()
	current_bgm_id = desired_id


func _play_sfx(stream: AudioStream, volume_db: float, pitch_min: float = 1.0, pitch_max: float = 1.0) -> void:
	if sfx_players.is_empty():
		return
	var chosen := sfx_players[sfx_cursor]
	for offset in sfx_players.size():
		var candidate := sfx_players[(sfx_cursor + offset) % sfx_players.size()]
		if not candidate.playing:
			chosen = candidate
			sfx_cursor = (sfx_cursor + offset + 1) % sfx_players.size()
			break
	chosen.stop()
	chosen.stream = stream
	chosen.volume_db = volume_db
	chosen.pitch_scale = randf_range(pitch_min, pitch_max)
	chosen.play()


func _play_wall_sfx(impact_speed: float) -> void:
	if wall_sfx_cooldown > 0.0 or impact_speed < 75.0:
		return
	var strength := clampf((impact_speed - 75.0) / 850.0, 0.0, 1.0)
	var pitch := lerpf(0.84, 1.14, strength)
	_play_sfx(SFX_WALL, lerpf(-17.0, -5.0, strength), pitch - 0.035, pitch + 0.035)
	wall_sfx_cooldown = lerpf(0.060, 0.035, strength)


func _play_gate_impact(contact_point: Vector2, impact_speed: float) -> void:
	if gate_hit_cooldown > 0.0 or impact_speed < 75.0:
		return
	var strength := clampf((impact_speed - 75.0) / 850.0, 0.0, 1.0)
	gate_hit_cooldown = 0.11
	gate_hit_timer = 0.20
	_play_sfx(SFX_GATE, lerpf(-8.0, -2.5, strength), 0.93, 1.03)
	_spawn_burst(contact_point, Color("b08a5d"), 7)


func _quit_test(exit_code: int) -> void:
	for player in sfx_players:
		player.stop()
		player.stream = null
	if bgm_player != null:
		bgm_player.stop()
		bgm_player.stream = null
	get_tree().quit(exit_code)


func _setup_table() -> void:
	# The raised lower edges of this V-shaped gate are the only colliders. A
	# straight centre shot is routed back down-left or down-right, while the broad
	# side lanes remain open toward the upper enemies.
	gate_panels = [
		{"a": Vector2(650, 382), "b": Vector2(720, 434)},
		{"a": Vector2(720, 434), "b": Vector2(790, 382)},
	]
	walls = [
		{"a": Vector2(380, 105), "b": Vector2(470, 48)},
		{"a": Vector2(470, 48), "b": Vector2(970, 48)},
		{"a": Vector2(970, 48), "b": Vector2(1060, 105)},
		{"a": Vector2(380, 105), "b": Vector2(380, 640)},
		{"a": Vector2(1060, 105), "b": Vector2(1060, 640)},
		# A lower, shallower start turns side-lane falls inward toward the
		# flippers instead of continuing to funnel them into the outer drains.
		{"a": Vector2(380, 640), "b": Vector2(505, 755)},
		{"a": Vector2(1060, 640), "b": Vector2(935, 755)},
		{"a": Vector2(505, 755), "b": Vector2(520, 835)},
		{"a": Vector2(935, 755), "b": Vector2(920, 835)},
		# The upper banks are rotated and placed diagonally below the small enemies.
		# This keeps them visually separate from the enemy tokens and avoids making
		# a narrow pocket between the captain and the back line.
		{"a": Vector2(620, 285), "b": Vector2(560, 355), "friction": 0.24},
		{"a": Vector2(820, 285), "b": Vector2(880, 355), "friction": 0.24},
		# Lower slingshot guides.
		{"a": Vector2(505, 625), "b": Vector2(585, 690), "friction": 0.30},
		{"a": Vector2(935, 625), "b": Vector2(855, 690), "friction": 0.30},
	]

	bumpers = [
		{"id": "momentum", "name": "MOMENTUM  +30%", "pos": Vector2(460, 340), "radius": 22.0, "visual_radius": 27.0, "color": RUNE, "implemented": true, "activation_cooldown": 3.0, "cooldown": 0.0, "pulse": 0.0, "inside": false},
		{"id": "war_cry", "name": "WAR CRY  +40%", "pos": Vector2(980, 340), "radius": 20.0, "visual_radius": 25.0, "color": Color("e46b4f"), "implemented": true, "activation_cooldown": 4.0, "cooldown": 0.0, "pulse": 0.0, "inside": false},
	]
	diamond_deflectors = [
		{"id": "centre_diamond", "pos": Vector2(720, 395), "half_diagonal": 42.0, "thickness": 10.0, "restitution": 0.92, "cooldown": 0.0, "pulse": 0.0},
	]

	# These are floor trigger zones rather than physical bumpers. Entering one
	# while Fury is full activates it without changing the ball's path.
	skill_panels = [
		{
			"id": "guard",
			"name": "GUARD",
			"pos": Vector2(455, 570),
			"radius": 25.0,
			"color": GREEN,
			"cooldown": 0.0,
			"pulse": 0.0,
			"inside": false,
		},
		{
			"id": "charge",
			"name": "CHARGE",
			"pos": Vector2(985, 570),
			"radius": 25.0,
			"color": GOLD,
			"cooldown": 0.0,
			"pulse": 0.0,
			"inside": false,
		},
	]


func restart_run() -> void:
	energy = 0.0
	charge_timer = 0.0
	might_timer = 0.0
	war_cry_ready = false
	hero_hp = HERO_MAX_HP
	last_room_heal = 0
	shield = 0
	score = 0
	wave = 1
	stage_room = 1
	combo = 0
	combo_timer = 0.0
	wave_clear_timer = -1.0
	game_over = false
	run_complete = false
	upgrade_selection_active = false
	upgrade_selection_timer = 0.0
	upgrade_exit_timer = -1.0
	upgrade_selected_index = -1
	upgrade_hover_index = -1
	upgrade_choices.clear()
	upgrade_reward_kind = ""
	starting_style_id = ""
	starting_style_selection_active = false
	starting_style_selection_timer = 0.0
	starting_style_carousel_index = 0
	starting_style_carousel_anim = 0.0
	starting_style_carousel_direction = 0
	starting_style_hover_direction = 0
	starting_style_confirm_hover = false
	shield_gained_this_ball = 0
	heavy_strike_hits = 0
	heavy_strike_ready = false
	upgrade_levels.clear()
	upgrade_history.clear()
	attack_power_multiplier = 1.0
	speed_upgrade_bonus = 0.0
	permanent_size_scale = 1.0
	spring_plate_level = 0
	spring_rebound_ready = false
	blast_impact_level = 0
	blast_impact_cooldown = 0.0
	blast_damage_level = 0
	blast_radius_level = 0
	blast_cooldown_level = 0
	moving_aftershock_level = 0
	throwing_axe_level = 0
	throwing_axe_cooldown = 0.0
	axe_damage_level = 0
	axe_count_level = 0
	axe_cooldown_level = 0
	returning_axe_level = 0
	spiked_shield_level = 0
	spike_damage_level = 0
	spike_scatter_level = 0
	shieldbreak_retort_level = 0
	shield_bash_level = 0
	shieldbreak_triggered_this_phase = false
	shield_training_level = 0
	residual_shield_level = 0
	shield_gain_fraction = 0.0
	launch_x = 720.0
	_clear_board_hover()
	enemy_phase_active = false
	enemy_phase_timer = 0.0
	enemy_attack_queue.clear()
	enemy_attack_index = 0
	enemy_phase_incoming_total = 0
	passive_enemy_phase_seen = false
	passive_expected_hp = HERO_MAX_HP
	left_power_timer = 0.0
	right_power_timer = 0.0
	particles.clear()
	floating_text.clear()
	shockwaves.clear()
	explosions.clear()
	pending_aftershocks.clear()
	flying_axes.clear()
	warlord_soul_streams.clear()
	warlord_guard_rotation = 0.0
	warlord_guard_hit_cooldown = 0.0
	screen_shake_timer = 0.0
	screen_shake_strength = 0.0
	screen_shake_offset = Vector2.ZERO
	damage_vignette = 0.0
	gate_hit_cooldown = 0.0
	gate_hit_timer = 0.0
	for deflector in diamond_deflectors:
		deflector.cooldown = 0.0
		deflector.pulse = 0.0
	trail.clear()
	_spawn_wave()
	prepare_ball()
	_show_starting_style_selection()


func prepare_ball() -> void:
	ball_active = false
	waiting_for_launch = true
	ball_position = Vector2(launch_x, LAUNCH_Y)
	ball_velocity = Vector2.ZERO
	might_timer = 0.0
	war_cry_ready = false
	shield_gained_this_ball = 0
	heavy_strike_hits = 0
	heavy_strike_ready = false
	dash_fx_timer = 0.0
	spring_rebound_ready = false
	left_power_timer = 0.0
	right_power_timer = 0.0
	for bumper in bumpers:
		bumper.inside = false
	for panel in skill_panels:
		panel.inside = false
	trail.clear()
	_clear_board_hover()


func launch_ball() -> void:
	if game_over or run_complete or upgrade_selection_active or starting_style_selection_active or not waiting_for_launch:
		return
	waiting_for_launch = false
	ball_active = true
	ball_position = Vector2(launch_x, LAUNCH_Y)
	# Placement chooses only the horizontal drop point. The first meaningful
	# upward impulse should come from the player's flippers.
	ball_velocity = Vector2(0.0, BALL_DROP_SPEED)
	_clear_board_hover()
	_show_status("BRAVE, DROP!", 0.8)


func _set_launch_x(mouse_x: float) -> void:
	if not waiting_for_launch or game_over or run_complete or upgrade_selection_active or starting_style_selection_active:
		return
	launch_x = clampf(mouse_x, LAUNCH_MIN_X, LAUNCH_MAX_X)
	ball_position = Vector2(launch_x, LAUNCH_Y)
	queue_redraw()


func _clear_board_hover() -> void:
	board_hover_type = ""
	board_hover_index = -1


func _update_board_hover(mouse_position: Vector2) -> void:
	board_hover_mouse = mouse_position
	_clear_board_hover()
	if not waiting_for_launch or game_over or run_complete or upgrade_selection_active or starting_style_selection_active:
		return
	for enemy_index in enemies.size():
		var enemy: Dictionary = enemies[enemy_index]
		if mouse_position.distance_to(enemy.pos) <= float(enemy.radius) + 10.0:
			board_hover_type = "enemy"
			board_hover_index = enemy_index
			queue_redraw()
			return
	for bumper_index in bumpers.size():
		var bumper: Dictionary = bumpers[bumper_index]
		if mouse_position.distance_to(bumper.pos) <= float(bumper.get("visual_radius", bumper.radius)) + 10.0:
			board_hover_type = "combat_rune"
			board_hover_index = bumper_index
			queue_redraw()
			return
	for panel_index in skill_panels.size():
		var panel: Dictionary = skill_panels[panel_index]
		if mouse_position.distance_to(panel.pos) <= float(panel.radius) + 12.0:
			board_hover_type = "fury_skill"
			board_hover_index = panel_index
			queue_redraw()
			return
	queue_redraw()


func _enemy_hover_info(enemy: Dictionary) -> Dictionary:
	var kind := String(enemy.kind)
	var is_warlord := bool(enemy.get("is_warlord", false))
	var title := "GOBLIN RAIDER"
	var role := "ENEMY  /  MELEE"
	var ability := "MELEE STRIKE: STANDARD DAMAGE"
	var advice := "A basic member of the war band."
	var color := RED
	match kind:
		"boss":
			if is_warlord:
				title = "GOBLIN WARLORD"
				role = "BOSS  /  RAGE %d/%d  /  GUARD %d/4" % [int(enemy.rage_stacks), WARLORD_MAX_RAGE_STACKS, _warlord_guard_count()]
				ability = "BLOOD TRIBUTE: MINION +15 HP / +15% ATK"
				advice = "Orbiting guards block direct hits; combat arts bypass."
				color = Color("ef5a3c")
			else:
				title = "GOBLIN CAPTAIN"
				role = "ENEMY  /  HEAVY"
				ability = "HEAVY SLAM: HIGH DAMAGE"
				advice = "Tough, dangerous, and hard to remove."
				color = GOLD
		"soldier":
			title = "GOBLIN SOLDIER"
			role = "ENEMY  /  MELEE"
			ability = "MELEE STRIKE: MODERATE DAMAGE"
			advice = "A tougher ordinary member of the war band."
		"mage":
			title = "GOBLIN HEXER"
			role = "ENEMY  /  LOW HP CASTER"
			ability = "ARCANE PIERCE: 50% IGNORES SHIELD"
			advice = "Fragile. Destroy it before the drain."
			color = ARCANE
	if stage_room == FINAL_ROOM and int(enemy.get("guard_slot", -1)) >= 0:
		advice = "Bound guard: its death shatters one Warlord shield."
	return {
		"title": title,
		"role": role,
		"line_1": "HP %d / %d     ATTACK %d" % [int(enemy.hp), int(enemy.max_hp), int(enemy.attack)],
		"line_2": ability,
		"line_3": advice,
		"color": color,
		"pos": enemy.pos,
		"radius": float(enemy.radius),
	}


func _combat_rune_hover_info(bumper: Dictionary) -> Dictionary:
	var info := {
		"title": String(bumper.name),
		"role": "COMBAT RUNE  /  PASS-THROUGH",
		"line_1": "Activates when crossed. Does not cost Fury.",
		"line_2": "",
		"line_3": "Cooldown %.0fs." % float(bumper.activation_cooldown),
		"color": Color(bumper.color),
		"pos": bumper.pos,
		"radius": float(bumper.get("visual_radius", bumper.radius)),
	}
	match String(bumper.id):
		"might":
			info.title = "MIGHT"
			info.line_2 = "Grow for 5s; size also improves damage."
			info.line_3 = "Cannot refresh while active. 6s cooldown."
		"war_cry":
			info.title = "WAR CRY"
			info.line_2 = "Your next enemy hit deals +40% damage."
			info.line_3 = "Cannot stack. 4s cooldown."
		_:
			info.title = "MOMENTUM"
			info.line_2 = "Instantly increases current speed by 30%."
			info.line_3 = "Preserves direction. 3s cooldown."
	return info


func _fury_skill_hover_info(panel: Dictionary) -> Dictionary:
	var info := {
		"title": String(panel.name),
		"role": "FURY SKILL  /  COST 100",
		"line_1": "Pass-through rune. Requires full Battle Fury.",
		"line_2": "",
		"line_3": "Triggers immediately on contact.",
		"color": Color(panel.color),
		"pos": panel.pos,
		"radius": float(panel.radius),
	}
	if String(panel.id) == "guard":
		info.line_2 = "Gain 25 Shield for the next retaliation."
		info.line_3 = "Unused Shield fades after the enemy phase."
	else:
		info.line_2 = "+30% speed and +25% damage for 3s."
	return info


func _board_hover_info() -> Dictionary:
	match board_hover_type:
		"enemy":
			if board_hover_index >= 0 and board_hover_index < enemies.size():
				return _enemy_hover_info(enemies[board_hover_index])
		"combat_rune":
			if board_hover_index >= 0 and board_hover_index < bumpers.size():
				return _combat_rune_hover_info(bumpers[board_hover_index])
		"fury_skill":
			if board_hover_index >= 0 and board_hover_index < skill_panels.size():
				return _fury_skill_hover_info(skill_panels[board_hover_index])
	return {}


func _spawn_wave() -> void:
	enemies.clear()
	_configure_room_layout()
	_sync_bgm()
	warlord_guard_rotation = 0.0
	warlord_guard_hit_cooldown = 0.0
	var hp_scale := 1.0 + float(wave - 1) * 0.16
	if stage_room == FINAL_ROOM:
		# The final arena replaces the upper captain and centre diamond with one
		# warlord surrounded by the four familiar minion positions.
		_add_enemy(Vector2(720, 395), 60.0, WARLORD_MAX_HP, "boss")
		var warlord: Dictionary = enemies[-1]
		warlord.is_warlord = true
		warlord.base_attack = WARLORD_BASE_ATTACK
		warlord.attack = WARLORD_BASE_ATTACK
		warlord.rage_stacks = 0
		_add_enemy(Vector2(540, 245), 28.0, int(18.0 * hp_scale), "mage")
		enemies[-1].guard_slot = 0
		_add_enemy(Vector2(900, 245), 28.0, int(18.0 * hp_scale), "mage")
		enemies[-1].guard_slot = 1
		_add_enemy(Vector2(510, 455), 25.0, int(20.0 * hp_scale), "soldier")
		enemies[-1].guard_slot = 2
		_add_enemy(Vector2(930, 455), 25.0, int(20.0 * hp_scale), "soldier")
		enemies[-1].guard_slot = 3
		_show_status("BOSS STAGE 1-5", 1.4)
		return
	_add_enemy(Vector2(720, 145), 52.0, int(68.0 * hp_scale), "boss")
	var upper_kind := "mage" if stage_room >= 3 else "soldier"
	var upper_hp := 18.0 if upper_kind == "mage" else 24.0
	_add_enemy(Vector2(540, 245), 28.0, int(upper_hp * hp_scale), upper_kind)
	_add_enemy(Vector2(900, 245), 28.0, int(upper_hp * hp_scale), upper_kind)
	_add_enemy(Vector2(510, 455), 25.0, int(20.0 * hp_scale), "grunt")
	_add_enemy(Vector2(930, 455), 25.0, int(20.0 * hp_scale), "grunt")
	if stage_room == 3:
		# Room 1-3 replaces the centre diamond with an extra melee target.
		_add_enemy(Vector2(720, 395), 27.0, int(24.0 * hp_scale), "grunt")
	_show_status("STAGE 1-%d" % stage_room, 1.4)


func _configure_room_layout() -> void:
	diamond_deflectors.clear()
	if stage_room in [2, 4]:
		diamond_deflectors.append({
			"id": "centre_diamond",
			"pos": Vector2(720, 395),
			"half_diagonal": 42.0,
			"thickness": 10.0,
			"restitution": 0.92,
			"cooldown": 0.0,
			"pulse": 0.0,
		})


func _add_enemy(pos: Vector2, radius: float, hp: int, kind: String) -> void:
	var base_attack := 4
	match kind:
		"boss":
			base_attack = 10
		"soldier":
			base_attack = 6
		"mage":
			base_attack = 8
	var attack_scale := int(floor(float(wave - 1) / 2.0))
	enemies.append({
		"pos": pos,
		"radius": radius,
		"hp": hp,
		"max_hp": hp,
		"kind": kind,
		"attack": base_attack + attack_scale,
		"base_attack": base_attack + attack_scale,
		"is_warlord": false,
		"rage_stacks": 0,
		"guard_slot": -1,
		"shield_pierce": MAGE_SHIELD_PIERCE if kind == "mage" else 0.0,
		"attack_effect": _attack_effect_for_kind(kind),
		"attack_fx_timer": 0.0,
		"attack_fx_duration": 0.0,
		"hit_cooldown": 0.0,
		"pulse": 0.0,
		"dead": false,
	})


func _unhandled_input(event: InputEvent) -> void:
	if starting_style_selection_active:
		if event is InputEventMouseMotion:
			var style_mouse_position := (event as InputEventMouseMotion).position
			starting_style_hover_direction = _starting_style_navigation_at_position(style_mouse_position)
			starting_style_confirm_hover = _starting_style_confirm_rect().has_point(style_mouse_position)
			queue_redraw()
			return
		if event is InputEventMouseButton:
			var style_mouse_event := event as InputEventMouseButton
			if style_mouse_event.button_index == MOUSE_BUTTON_LEFT and style_mouse_event.pressed:
				if starting_style_selection_timer >= 0.22 and _starting_style_confirm_rect().has_point(style_mouse_event.position):
					_select_starting_style(starting_style_carousel_index)
				else:
					var navigation_direction := _starting_style_navigation_at_position(style_mouse_event.position)
					if navigation_direction != 0:
						_rotate_starting_style(navigation_direction)
			return
		if event is InputEventKey:
			var style_key_event := event as InputEventKey
			if not style_key_event.pressed or style_key_event.echo:
				return
			if style_key_event.keycode == KEY_R:
				restart_run()
			elif style_key_event.keycode in [KEY_LEFT, KEY_A]:
				_rotate_starting_style(-1)
			elif style_key_event.keycode in [KEY_RIGHT, KEY_D]:
				_rotate_starting_style(1)
			elif style_key_event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
				_select_starting_style(starting_style_carousel_index)
			elif style_key_event.keycode >= KEY_1 and style_key_event.keycode <= KEY_3:
				_focus_starting_style(int(style_key_event.keycode - KEY_1))
			return

	if upgrade_selection_active:
		if event is InputEventMouseMotion:
			upgrade_hover_index = _upgrade_card_at_position((event as InputEventMouseMotion).position)
			queue_redraw()
			return
		if event is InputEventMouseButton:
			var mouse_event := event as InputEventMouseButton
			if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
				_select_upgrade(_upgrade_card_at_position(mouse_event.position))
			return
		if event is InputEventKey:
			var selection_key := event as InputEventKey
			if not selection_key.pressed or selection_key.echo:
				return
			if selection_key.keycode == KEY_R:
				restart_run()
			elif selection_key.keycode >= KEY_1 and selection_key.keycode <= KEY_3:
				_select_upgrade(int(selection_key.keycode - KEY_1))
			return

	if waiting_for_launch and event is InputEventMouseMotion:
		var hover_motion := event as InputEventMouseMotion
		_set_launch_x(hover_motion.position.x)
		_update_board_hover(hover_motion.position)
		return
	if waiting_for_launch and event is InputEventMouseButton:
		var launch_click := event as InputEventMouseButton
		if launch_click.button_index == MOUSE_BUTTON_LEFT and launch_click.pressed:
			_set_launch_x(launch_click.position.x)
			launch_ball()
		return

	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_SPACE:
			launch_ball()
		KEY_R:
			restart_run()
		KEY_F:
			# Prototype helper: lets the skill-target loop be tested immediately.
			if not game_over:
				energy = ENERGY_MAX
				_show_status("SKILLS READY", 1.0)
		KEY_K:
			_debug_clear_stage()


func _debug_clear_stage() -> void:
	if game_over or run_complete or upgrade_selection_active or starting_style_selection_active:
		return
	ball_active = false
	waiting_for_launch = false
	enemy_phase_active = false
	enemy_phase_timer = 0.0
	enemy_attack_queue.clear()
	enemy_attack_index = 0
	enemy_phase_incoming_total = 0
	for enemy in enemies:
		enemy.dead = true
	enemies.clear()
	explosions.clear()
	pending_aftershocks.clear()
	flying_axes.clear()
	warlord_soul_streams.clear()
	wave_clear_timer = -1.0
	_begin_wave_clear()
	# Keep the normal clear/reward flow, but shorten its pause for test iteration.
	wave_clear_timer = 0.35


func _physics_process(delta: float) -> void:
	var previous_left_active := left_active
	var previous_right_active := right_active
	left_active = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	right_active = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	if upgrade_selection_active or starting_style_selection_active or run_complete:
		left_active = false
		right_active = false

	if smoke_mode:
		smoke_frames += 1
		# A crude automated player for runtime tests. It reacts to descending balls
		# near the flippers instead of trying to prove any particular game balance.
		left_active = ball_active and ball_velocity.y > 0.0 and ball_position.y > 690.0 and ball_position.x < 745.0
		right_active = ball_active and ball_velocity.y > 0.0 and ball_position.y > 690.0 and ball_position.x >= 695.0
		if waiting_for_launch and not game_over and not upgrade_selection_active and not starting_style_selection_active and not run_complete:
			launch_ball()
		if upgrade_selection_active and upgrade_selection_timer > 0.65 and upgrade_selected_index < 0:
			_select_upgrade(0)
		if smoke_frames == 3 and (walls.size() < 10 or enemies.size() < 5):
			push_error("Smoke test failed: table setup incomplete")
			_quit_test(2)
		if smoke_frames >= 720:
			print("SMOKE_OK score=%d wave=%d hp=%d shield=%d energy=%.1f" % [score, wave, hero_hp, shield, energy])
			_quit_test(0)
	elif passive_test_mode:
		passive_test_frames += 1
		left_active = false
		right_active = false
	if waiting_for_launch:
		# Before launch the mouse owns placement; flipper keys should not create a
		# hidden powered window that affects the first shot.
		left_active = false
		right_active = false

	# A fresh press opens a short powered window. Holding a stationary flipper
	# no longer supplies energy forever; the next useful strike needs a new press.
	if left_active and not previous_left_active:
		left_power_timer = FLIPPER_POWER_WINDOW
	if right_active and not previous_right_active:
		right_power_timer = FLIPPER_POWER_WINDOW

	var left_target := -0.46 if left_active else 0.34
	var right_target := 0.46 if right_active else -0.34
	var previous_left_angle := left_angle
	var previous_right_angle := right_angle
	var left_rotation_speed := FLIPPER_UP_SPEED if left_active else FLIPPER_RETURN_SPEED
	var right_rotation_speed := FLIPPER_UP_SPEED if right_active else FLIPPER_RETURN_SPEED
	left_angle = move_toward(left_angle, left_target, left_rotation_speed * delta)
	right_angle = move_toward(right_angle, right_target, right_rotation_speed * delta)
	left_angular_velocity = (left_angle - previous_left_angle) / maxf(delta, 0.0001)
	right_angular_velocity = (right_angle - previous_right_angle) / maxf(delta, 0.0001)

	flipper_contact_lock = maxf(0.0, flipper_contact_lock - delta)
	warlord_guard_hit_cooldown = maxf(0.0, warlord_guard_hit_cooldown - delta)
	if stage_room == FINAL_ROOM and not _living_warlord().is_empty():
		warlord_guard_rotation = fmod(warlord_guard_rotation + WARLORD_GUARD_ROTATION_SPEED * delta, TAU)
	wall_sfx_cooldown = maxf(0.0, wall_sfx_cooldown - delta)
	gate_hit_cooldown = maxf(0.0, gate_hit_cooldown - delta)
	gate_hit_timer = maxf(0.0, gate_hit_timer - delta)
	left_power_timer = maxf(0.0, left_power_timer - delta)
	right_power_timer = maxf(0.0, right_power_timer - delta)
	charge_timer = maxf(0.0, charge_timer - delta)
	dash_fx_timer = maxf(0.0, dash_fx_timer - delta)
	might_timer = maxf(0.0, might_timer - delta)
	blast_impact_cooldown = maxf(0.0, blast_impact_cooldown - delta)
	throwing_axe_cooldown = maxf(0.0, throwing_axe_cooldown - delta)
	if starting_style_selection_active:
		starting_style_selection_timer += delta
		starting_style_carousel_anim = maxf(0.0, starting_style_carousel_anim - delta)
	if upgrade_selection_active:
		upgrade_selection_timer += delta
		if upgrade_exit_timer >= 0.0:
			upgrade_exit_timer -= delta
			if upgrade_exit_timer <= 0.0:
				_advance_to_next_room()
	combo_timer = maxf(0.0, combo_timer - delta)
	if combo_timer <= 0.0:
		combo = 0
	status_timer = maxf(0.0, status_timer - delta)
	screen_flash = maxf(0.0, screen_flash - delta * 2.8)
	damage_vignette = maxf(0.0, damage_vignette - delta * 2.6)
	screen_shake_timer = maxf(0.0, screen_shake_timer - delta)
	if screen_shake_timer > 0.0:
		var shake_decay := clampf(screen_shake_timer / 0.28, 0.0, 1.0)
		var shake_phase := float(Time.get_ticks_msec()) * 0.075
		screen_shake_offset = Vector2(sin(shake_phase * 1.7), cos(shake_phase * 2.3)) * screen_shake_strength * shake_decay
	else:
		screen_shake_offset = Vector2.ZERO

	for bumper in bumpers:
		bumper.cooldown = maxf(0.0, bumper.cooldown - delta)
		bumper.pulse = maxf(0.0, bumper.pulse - delta * 3.0)
	for deflector in diamond_deflectors:
		deflector.cooldown = maxf(0.0, deflector.cooldown - delta)
		deflector.pulse = maxf(0.0, deflector.pulse - delta * 4.0)
	for panel in skill_panels:
		panel.cooldown = maxf(0.0, panel.cooldown - delta)
		panel.pulse = maxf(0.0, panel.pulse - delta * 2.5)
	for enemy in enemies:
		enemy.hit_cooldown = maxf(0.0, enemy.hit_cooldown - delta)
		enemy.pulse = maxf(0.0, enemy.pulse - delta * 3.5)
		enemy.attack_fx_timer = maxf(0.0, enemy.attack_fx_timer - delta)

	_update_effects(delta)
	if enemy_phase_active and not game_over and not upgrade_selection_active:
		_update_enemy_phase(delta)

	if ball_active and not game_over and not upgrade_selection_active and not run_complete:
		_simulate_ball(delta)
		trail.push_front(ball_position)
		if trail.size() > 28:
			trail.pop_back()

	if passive_test_mode:
		if passive_enemy_phase_seen and not enemy_phase_active and waiting_for_launch:
			if hero_hp != passive_expected_hp or shield != 0:
				push_error("Passive turn result mismatch: hp=%d expected=%d shield=%d" % [hero_hp, passive_expected_hp, shield])
				_quit_test(2)
			else:
				print("PASSIVE_TURN_OK frames=%d hp=%d absorbed=%d" % [passive_test_frames, hero_hp, GUARD_SHIELD_GAIN])
				_quit_test(0)
		elif passive_test_frames >= 1440:
			push_error("Passive drain test failed: pos=%s vel=%s speed=%.1f" % [ball_position, ball_velocity, ball_velocity.length()])
			_quit_test(2)

	if enemies.is_empty() and wave_clear_timer < 0.0 and not game_over and not enemy_phase_active and not upgrade_selection_active and not run_complete:
		_begin_wave_clear()
	if wave_clear_timer >= 0.0:
		wave_clear_timer -= delta
		if wave_clear_timer <= 0.0:
			wave_clear_timer = -1.0
			_finish_room_clear()

	queue_redraw()


func _simulate_ball(delta: float) -> void:
	# Several substeps keep the small hero from tunnelling through targets at charge speed.
	const SUBSTEPS := 4
	var step := delta / float(SUBSTEPS)
	for _substep in SUBSTEPS:
		ball_velocity.y += GRAVITY * step
		ball_position += ball_velocity * step

		for wall in walls:
			var wall_kick := float(wall.get("kick", 0.0))
			var wall_friction := float(wall.get("friction", 0.015))
			_collide_segment(wall.a, wall.b, 14.0, WORLD_RESTITUTION, wall_friction, wall_kick)

		if _goblin_gate_active():
			for gate_panel in gate_panels:
				_collide_segment(gate_panel.a, gate_panel.b, 18.0, 0.72, 0.10, 0.0, "gate")

		for deflector in diamond_deflectors:
			var deflector_points := _diamond_deflector_points(deflector)
			var deflector_hit := false
			for edge_index in 4:
				var edge_start: Vector2 = deflector_points[edge_index]
				var edge_end: Vector2 = deflector_points[(edge_index + 1) % 4]
				if _collide_segment(edge_start, edge_end, float(deflector.thickness), float(deflector.restitution), 0.02):
					deflector_hit = true
					break
			if deflector_hit and float(deflector.cooldown) <= 0.0:
				deflector.cooldown = 0.08
				deflector.pulse = 1.0
				_spawn_burst(deflector.pos, Color("d6b679"), 5)

		_collide_flippers()

		for bumper in bumpers:
			_update_combat_rune_trigger(bumper)

		for panel in skill_panels:
			_update_fury_skill_trigger(panel)

		# Each living boss-room minion maintains one physical shield arc. These
		# intercept the warrior before the central Warlord's collision circle,
		# while secondary combat arts remain free to damage through the formation.
		if stage_room == FINAL_ROOM:
			_collide_warlord_guards()

		# A rebound proc can defeat and remove targets during this pass.
		for enemy in enemies.duplicate():
			if enemy.dead:
				continue
			if _collide_circle(enemy.pos, enemy.radius, WORLD_RESTITUTION):
				if enemy.hit_cooldown <= 0.0:
					_damage_enemy(enemy)
				_on_ball_bounce(ball_position)

		var speed := ball_velocity.length()
		var max_speed := _current_max_speed()
		if speed > max_speed:
			ball_velocity = ball_velocity / speed * max_speed

	_remove_dead_enemies()
	if ball_position.y > FIELD_BOTTOM + 45.0:
		_ball_drained()


func _current_ball_radius() -> float:
	var radius := BALL_RADIUS * permanent_size_scale
	return radius * MIGHT_COLLISION_SCALE if might_timer > 0.0 else radius


func _diamond_deflector_points(deflector: Dictionary) -> PackedVector2Array:
	var center: Vector2 = deflector.pos
	var half_diagonal := float(deflector.half_diagonal)
	return PackedVector2Array([
		center + Vector2(0.0, -half_diagonal),
		center + Vector2(half_diagonal, 0.0),
		center + Vector2(0.0, half_diagonal),
		center + Vector2(-half_diagonal, 0.0),
	])


func _current_max_speed() -> float:
	return MAX_SPEED * (1.0 + speed_upgrade_bonus)


func _goblin_gate_active() -> bool:
	# The trap-like V gate is disabled for all five prototype rooms. Keeping the
	# predicate lets a later map reactivate it without restoring hidden collision.
	return stage_room > FINAL_ROOM


func _combat_rune_can_activate(id: String) -> bool:
	match id:
		"might":
			return might_timer <= 0.0
		"war_cry":
			return not war_cry_ready
		_:
			return true


func _ball_over_trigger(trigger_position: Vector2, trigger_radius: float) -> bool:
	return ball_position.distance_squared_to(trigger_position) <= pow(_current_ball_radius() + trigger_radius, 2.0)


func _update_combat_rune_trigger(bumper: Dictionary) -> void:
	var touching := _ball_over_trigger(bumper.pos, float(bumper.radius))
	var entered := touching and not bool(bumper.get("inside", false))
	bumper.inside = touching
	if not entered:
		return
	var incoming_speed := ball_velocity.length()
	if bumper.implemented and float(bumper.cooldown) <= 0.0 and _combat_rune_can_activate(String(bumper.id)):
		bumper.cooldown = float(bumper.activation_cooldown)
		bumper.pulse = 1.0
		_activate_combat_rune(String(bumper.id), bumper.pos, incoming_speed, bumper.color)


func _update_fury_skill_trigger(panel: Dictionary) -> void:
	var touching := _ball_over_trigger(panel.pos, float(panel.radius))
	var entered := touching and not bool(panel.get("inside", false))
	panel.inside = touching
	if not entered or float(panel.cooldown) > 0.0:
		return
	if energy >= ENERGY_MAX - 0.01:
		panel.cooldown = 0.42
		panel.pulse = 1.0
		_activate_skill(panel.id, panel.pos, panel.color)


func _collide_segment(a: Vector2, b: Vector2, thickness: float, restitution: float, friction: float = 0.0, kick: float = 0.0, surface_kind: String = "wall") -> bool:
	var ab := b - a
	var ab_len_sq := ab.length_squared()
	if ab_len_sq <= 0.001:
		return false
	var t := clampf((ball_position - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var closest := a + ab * t
	var delta_pos := ball_position - closest
	var min_distance := _current_ball_radius() + thickness * 0.5
	var distance := delta_pos.length()
	if distance >= min_distance:
		return false

	var normal: Vector2
	if distance < 0.001:
		normal = ab.orthogonal().normalized()
		if ball_velocity.dot(normal) > 0.0:
			normal = -normal
	else:
		normal = delta_pos / distance
	ball_position += normal * (min_distance - distance + 0.15)
	var normal_speed := ball_velocity.dot(normal)
	if normal_speed < 0.0:
		var incoming_total_speed := ball_velocity.length()
		var impact_speed := -normal_speed
		ball_velocity -= normal * normal_speed * (1.0 + restitution)
		# Approximate rubber friction from the collision impulse. This removes a
		# portion of tangential sliding without damping free-flight speed.
		var tangent := normal.orthogonal()
		var tangent_speed := ball_velocity.dot(tangent)
		var max_friction_change := absf(normal_speed) * (1.0 + restitution) * friction
		ball_velocity -= tangent * clampf(tangent_speed, -max_friction_change, max_friction_change)
		if kick > 0.0:
			ball_velocity += normal * kick
		if surface_kind == "gate":
			_play_gate_impact(closest, impact_speed)
		elif surface_kind == "warlord_guard":
			if warlord_guard_hit_cooldown <= 0.0:
				_play_sfx(SFX_SHIELD_BLOCK, -5.0, 0.92, 1.02)
		else:
			_play_wall_sfx(impact_speed)
		if spring_plate_level > 0 and spring_rebound_ready:
			var retention := minf(0.97, 0.92 + float(spring_plate_level - 1) * 0.025)
			var retained_speed := minf(_current_max_speed(), incoming_total_speed * retention)
			if ball_velocity.length() > 0.1 and ball_velocity.length() < retained_speed:
				ball_velocity = ball_velocity.normalized() * retained_speed
			spring_rebound_ready = false
			_show_status("SPRING REBOUND", 0.55)
			_spawn_burst(closest, Color("a9d8c8"), 8)
		_on_ball_bounce(closest)
		return true
	return false


func _collide_circle(center: Vector2, radius: float, restitution: float) -> bool:
	var delta_pos := ball_position - center
	var min_distance := _current_ball_radius() + radius
	var distance := delta_pos.length()
	if distance >= min_distance:
		return false
	var normal := Vector2.UP if distance < 0.001 else delta_pos / distance
	ball_position += normal * (min_distance - distance + 0.15)
	var normal_speed := ball_velocity.dot(normal)
	if normal_speed < 0.0:
		ball_velocity -= normal * normal_speed * (1.0 + restitution)
		return true
	return false


func _collide_flippers() -> void:
	var left_pivot := LEFT_FLIPPER_PIVOT
	var right_pivot := RIGHT_FLIPPER_PIVOT
	var left_tip := left_pivot + Vector2(FLIPPER_LENGTH, 0).rotated(left_angle)
	var right_tip := right_pivot + Vector2(-FLIPPER_LENGTH, 0).rotated(right_angle)

	# The brief grace window keeps slightly early presses useful, but it expires
	# even while the key remains held. A motionless flipper is therefore passive.
	var left_powered := left_power_timer > 0.0
	var right_powered := right_power_timer > 0.0
	var left_drive := minf(left_angular_velocity, -FLIPPER_GRACE_DRIVE) if left_powered else left_angular_velocity
	var right_drive := maxf(right_angular_velocity, FLIPPER_GRACE_DRIVE) if right_powered else right_angular_velocity
	var hit_left := _collide_moving_segment(left_pivot, left_tip, left_drive, left_powered)
	var hit_right := _collide_moving_segment(right_pivot, right_tip, right_drive, right_powered)
	var powered := (hit_left and left_powered) or (hit_right and right_powered)
	if hit_left and left_powered:
		left_power_timer = 0.0
	if hit_right and right_powered:
		right_power_timer = 0.0
	if flipper_contact_lock > 0.0:
		return

	if not powered:
		return

	flipper_contact_lock = 0.10
	combo = maxi(1, combo)
	combo_timer = 2.2
	_add_energy(6.0)
	if spring_plate_level > 0:
		spring_rebound_ready = true
	_play_sfx(SFX_FLIPPER, -4.0, 0.95, 1.06)
	_spawn_burst(ball_position, GOLD if charge_timer > 0.0 else CYAN, 7)


func _collide_moving_segment(pivot: Vector2, tip: Vector2, angular_velocity: float, powered: bool) -> bool:
	var segment := tip - pivot
	var segment_length_sq := segment.length_squared()
	if segment_length_sq <= 0.001:
		return false
	var t := clampf((ball_position - pivot).dot(segment) / segment_length_sq, 0.0, 1.0)
	var contact_point := pivot + segment * t
	var delta_pos := ball_position - contact_point
	var min_distance := _current_ball_radius() + 12.5
	var distance := delta_pos.length()
	if distance >= min_distance:
		return false

	var normal: Vector2
	if distance < 0.001:
		normal = segment.orthogonal().normalized()
		if ball_velocity.dot(normal) > 0.0:
			normal = -normal
	else:
		normal = delta_pos / distance
	ball_position += normal * (min_distance - distance + 0.15)

	# Tangential speed of a rotating surface is omega x radius. Resolve the
	# bounce in the flipper's moving reference frame, then transform it back.
	# This naturally makes the tip stronger than the area near the pivot.
	var contact_radius := contact_point - pivot
	# A small virtual lever floor is an accessibility concession. Without it,
	# balls routed onto the hinge receive almost zero energy even on a good press.
	var effective_lever_length := maxf(contact_radius.length(), 62.0)
	var effective_contact_radius := segment.normalized() * effective_lever_length
	# Godot's Vector2.orthogonal() uses the screen-space clockwise perpendicular;
	# negate it to obtain d(radius)/dt for the angle convention used here.
	var surface_velocity := -effective_contact_radius.orthogonal() * angular_velocity * (1.0 + speed_upgrade_bonus)
	var relative_velocity := ball_velocity - surface_velocity
	var relative_normal_speed := relative_velocity.dot(normal)
	if relative_normal_speed < 0.0:
		var restitution := FLIPPER_POWERED_RESTITUTION if powered else FLIPPER_IDLE_RESTITUTION
		relative_velocity -= normal * relative_normal_speed * (1.0 + restitution)
		ball_velocity = relative_velocity + surface_velocity
		var charge_floor := CHARGE_MIN_SPEED * (1.0 + speed_upgrade_bonus * 0.65)
		if charge_timer > 0.0 and ball_velocity.length() > 0.1 and ball_velocity.length() < charge_floor:
			ball_velocity = ball_velocity.normalized() * charge_floor
		# A controlled flipper is the warrior's launcher, not an impact target:
		# it may throw an axe, but it cannot discharge Rune Blast.
		_on_ball_bounce(contact_point, false)
		return true
	return false


func _shield_bash_bonus() -> int:
	if shield_bash_level <= 0 or shield <= 0:
		return 0
	return mini(5, int(floor(float(shield) / 10.0)))


func _damage_enemy(enemy: Dictionary) -> void:
	var speed_multiplier := _speed_damage_multiplier(ball_velocity.length())
	var charge_multiplier := 1.25 if charge_timer > 0.0 else 1.0
	var war_cry_empowered := war_cry_ready
	var heavy_strike_empowered := starting_style_id == "heavy_strike" and heavy_strike_ready
	# One-shot bonuses add together, so Heavy Strike and War Cry make a readable
	# +80% hit instead of multiplying into an unexpected +96% spike.
	var one_shot_multiplier := 1.0
	if war_cry_empowered:
		one_shot_multiplier += WAR_CRY_DAMAGE_MULTIPLIER - 1.0
	if heavy_strike_empowered:
		one_shot_multiplier += HEAVY_STRIKE_DAMAGE_BONUS
	var size_damage_multiplier := 1.0 + (permanent_size_scale - 1.0) * 0.75
	var shield_bash_bonus := _shield_bash_bonus()
	var damage := maxi(1, int(round(9.0 * speed_multiplier * charge_multiplier * one_shot_multiplier * attack_power_multiplier * size_damage_multiplier))) + shield_bash_bonus
	if war_cry_empowered:
		war_cry_ready = false
	if heavy_strike_empowered:
		heavy_strike_ready = false
		heavy_strike_hits = 0
	if war_cry_empowered or heavy_strike_empowered:
		screen_flash = maxf(screen_flash, 0.38)
		if war_cry_empowered and heavy_strike_empowered:
			_show_status("WAR CRY + HEAVY STRIKE!  +80%", 0.82)
		elif heavy_strike_empowered:
			_show_status("HEAVY STRIKE!  +40%", 0.72)
		else:
			_show_status("WAR CRY STRIKE!  +40%", 0.72)
	var hit_pitch := 0.84 if String(enemy.kind) == "boss" else 1.0
	_play_sfx(SFX_ENEMY_HIT, -2.5, hit_pitch - 0.055, hit_pitch + 0.055)
	enemy.hp -= damage
	enemy.hit_cooldown = 0.18
	enemy.pulse = 1.0
	combo += 1
	combo_timer = 2.0
	var combo_bonus := mini(combo, 12)
	score += damage * 10 + combo_bonus * 3
	var energy_gain := 11.0 + minf(5.0, float(combo) * 0.5)
	if starting_style_id == "fury_core":
		energy_gain += FURY_CORE_BONUS
	_add_energy(energy_gain)
	if starting_style_id == "iron_oath" and shield_gained_this_ball < IRON_OATH_SHIELD_PER_BALL_CAP and shield < SHIELD_MAX:
		var shield_gain := _gain_shield(IRON_OATH_SHIELD_PER_HIT, IRON_OATH_SHIELD_PER_BALL_CAP - shield_gained_this_ball)
		shield_gained_this_ball += shield_gain
		_add_floating_text(ball_position + Vector2(-26, -30), "+%d SHIELD" % shield_gain, GREEN)
		_spawn_burst(ball_position, GREEN, 4)
	if starting_style_id == "heavy_strike" and not heavy_strike_empowered:
		heavy_strike_hits = mini(HEAVY_STRIKE_REQUIRED_HITS, heavy_strike_hits + 1)
		if heavy_strike_hits >= HEAVY_STRIKE_REQUIRED_HITS:
			heavy_strike_ready = true
			screen_flash = maxf(screen_flash, 0.22)
			_show_status("HEAVY STRIKE READY", 0.86)
			_add_floating_text(ball_position + Vector2(-46, -34), "HEAVY READY", GOLD)
	var empowered_hit := war_cry_empowered or heavy_strike_empowered
	var hit_color := Color("ff9f59") if empowered_hit else (GOLD if charge_timer > 0.0 else Color.WHITE)
	_add_floating_text(enemy.pos + Vector2(0, -enemy.radius - 8), "-%d" % damage, hit_color)
	_spawn_burst(enemy.pos, Color("ff744f") if empowered_hit else (RED if enemy.kind != "boss" else GOLD), 12 if empowered_hit else 7)
	if shield_bash_bonus > 0:
		_add_floating_text(ball_position + Vector2(-34, 32), "BASH +%d" % shield_bash_bonus, Color("d8e7a5"))
		_spawn_burst(ball_position, Color("d8e7a5"), 5)
	if enemy.hp <= 0:
		enemy.dead = true
		score += 250 if enemy.kind == "boss" else 90
		_add_energy(15.0)
		_spawn_burst(enemy.pos, GOLD, 16)
		_on_enemy_defeated(enemy)


func _deal_secondary_damage(enemy: Dictionary, damage: int, color: Color, label: String) -> void:
	if enemy.is_empty() or enemy.dead:
		return
	enemy.hp -= damage
	enemy.hit_cooldown = maxf(float(enemy.hit_cooldown), 0.12)
	enemy.pulse = 1.0
	score += damage * 8
	_add_floating_text(enemy.pos + Vector2(-10, -enemy.radius - 8), "%s -%d" % [label, damage], color)
	_spawn_burst(enemy.pos, color, 9)
	if enemy.hp <= 0:
		enemy.dead = true
		score += 250 if enemy.kind == "boss" else 90
		_add_energy(12.0)
		_spawn_burst(enemy.pos, GOLD, 14)
		_on_enemy_defeated(enemy)


func _living_warlord() -> Dictionary:
	for candidate in enemies:
		if bool(candidate.get("is_warlord", false)) and not bool(candidate.dead) and int(candidate.hp) > 0:
			return candidate
	return {}


func _warlord_guard_count() -> int:
	var guard_count := 0
	for candidate in enemies:
		if not bool(candidate.dead) and int(candidate.get("guard_slot", -1)) >= 0:
			guard_count += 1
	return guard_count


func _warlord_guard_base_angle(slot: int) -> float:
	match slot:
		0:
			return -PI * 0.75
		1:
			return -PI * 0.25
		2:
			return PI * 0.75
		_:
			return PI * 0.25


func _warlord_guard_segment(warlord: Dictionary, guard_slot: int) -> Dictionary:
	var angle := _warlord_guard_base_angle(guard_slot) + warlord_guard_rotation
	var radial := Vector2.from_angle(angle)
	var centre: Vector2 = warlord.pos + radial * WARLORD_GUARD_ORBIT_RADIUS
	var tangent := radial.orthogonal()
	var half_chord := WARLORD_GUARD_ORBIT_RADIUS * sin(WARLORD_GUARD_ARC * 0.5)
	return {
		"a": centre - tangent * half_chord,
		"b": centre + tangent * half_chord,
		"centre": centre,
		"angle": angle,
	}


func _collide_warlord_guards() -> bool:
	var warlord := _living_warlord()
	if warlord.is_empty():
		return false
	for guard_source in enemies.duplicate():
		var guard_slot := int(guard_source.get("guard_slot", -1))
		if bool(guard_source.dead) or guard_slot < 0:
			continue
		var guard_segment := _warlord_guard_segment(warlord, guard_slot)
		if _collide_segment(guard_segment.a, guard_segment.b, WARLORD_GUARD_THICKNESS, 0.82, 0.08, 0.0, "warlord_guard"):
			if warlord_guard_hit_cooldown <= 0.0:
				warlord_guard_hit_cooldown = 0.09
				_spawn_burst(guard_segment.centre, BRONZE, 7)
				_add_floating_text(guard_segment.centre + Vector2(-34, -22), "BLOCKED", Color("f2d18a"))
			return true
	return false


func _enemy_death_sfx_id(defeated_enemy: Dictionary) -> String:
	if bool(defeated_enemy.get("is_warlord", false)):
		return "boss"
	if String(defeated_enemy.kind) == "boss":
		return "elite"
	return "grunt"


func _play_enemy_death_sfx(defeated_enemy: Dictionary) -> void:
	match _enemy_death_sfx_id(defeated_enemy):
		"boss":
			_play_sfx(SFX_WARLORD_DEATH, -3.0, 0.98, 1.02)
		"elite":
			_play_sfx(SFX_ELITE_GOBLIN_DEATH, -5.0, 0.97, 1.03)
		_:
			# A little pitch variation keeps groups of ordinary goblins from
			# sounding like the exact same recording fired repeatedly.
			_play_sfx(SFX_GOBLIN_GRUMP, -3.5, 0.93, 1.07)


func _on_enemy_defeated(defeated_enemy: Dictionary) -> void:
	_play_enemy_death_sfx(defeated_enemy)
	if stage_room != FINAL_ROOM or bool(defeated_enemy.get("is_warlord", false)):
		return
	var warlord := _living_warlord()
	if warlord.is_empty():
		return
	var previous_hp := int(warlord.hp)
	warlord.rage_stacks = mini(WARLORD_MAX_RAGE_STACKS, int(warlord.rage_stacks) + 1)
	warlord.hp = mini(int(warlord.max_hp), previous_hp + WARLORD_MINION_HEAL)
	var rage_multiplier := 1.0 + float(warlord.rage_stacks) * WARLORD_RAGE_PER_MINION
	warlord.attack = int(round(float(warlord.base_attack) * rage_multiplier))
	warlord.pulse = 1.0
	var healed := int(warlord.hp) - previous_hp
	var guard_slot := int(defeated_enemy.get("guard_slot", -1))
	if guard_slot >= 0:
		var broken_guard := _warlord_guard_segment(warlord, guard_slot)
		_spawn_burst(broken_guard.centre, Color("e2bd78"), 15)
		_add_floating_text(broken_guard.centre + Vector2(-54, -24), "GUARD BROKEN", Color("f2d18a"))
	warlord_soul_streams.append({
		"start": Vector2(defeated_enemy.pos),
		"end": Vector2(warlord.pos),
		"life": 0.76,
		"max_life": 0.76,
		"curve": -1.0 if float(defeated_enemy.pos.x) < float(warlord.pos.x) else 1.0,
	})
	shockwaves.append({"pos": warlord.pos, "life": 0.56, "max_life": 0.56, "color": Color("ef5a3c")})
	_spawn_burst(warlord.pos, Color("ef5a3c"), 14)
	if healed > 0:
		_add_floating_text(warlord.pos + Vector2(-48, -72), "+%d HP" % healed, GREEN)
	else:
		_add_floating_text(warlord.pos + Vector2(-42, -72), "HP FULL", GREEN)
	_add_floating_text(warlord.pos + Vector2(-58, 82), "RAGE +15%", Color("ff7250"))
	screen_flash = maxf(screen_flash, 0.24)
	_show_status("WARLORD RAGE %d/%d" % [int(warlord.rage_stacks), WARLORD_MAX_RAGE_STACKS], 0.86)


func _impact_proc_cooldown(cooldown_level: int) -> float:
	return maxf(IMPACT_PROC_MIN_COOLDOWN, IMPACT_PROC_BASE_COOLDOWN * (1.0 - float(cooldown_level) * IMPACT_COOLDOWN_REDUCTION_PER_LEVEL))


func _current_explosion_radius() -> float:
	return EXPLOSION_BASE_RADIUS * (1.0 + float(blast_radius_level) * EXPLOSION_RADIUS_PER_LEVEL)


func _on_ball_bounce(origin: Vector2, allow_blast: bool = true) -> void:
	# Pass-through floor runes never call this function. Controlled flippers pass
	# allow_blast=false so the player's own launch action cannot cause explosions.
	if allow_blast and blast_impact_level > 0 and blast_impact_cooldown <= 0.0:
		_trigger_blast_impact(origin)
	if throwing_axe_level > 0 and throwing_axe_cooldown <= 0.0:
		_launch_throwing_axes(origin)


func _trigger_blast_impact(origin: Vector2) -> void:
	blast_impact_cooldown = _impact_proc_cooldown(blast_cooldown_level)
	var size_damage_multiplier := 1.0 + (permanent_size_scale - 1.0) * 0.75
	var blast_damage := maxi(2, int(round(5.0 * (1.0 + float(blast_damage_level) * 0.25) * attack_power_multiplier * size_damage_multiplier)))
	var explosion_radius := _current_explosion_radius()
	explosions.append({
		"pos": origin,
		"life": 0.58,
		"max_life": 0.58,
		"radius": explosion_radius,
		"kind": "blast",
	})
	_play_sfx(SFX_EXPLOSION, -3.5, 0.95, 1.04)
	screen_flash = maxf(screen_flash, 0.34)
	var targets_hit := 0
	_spawn_burst(origin, Color("ff9a45"), 30)
	for enemy in enemies:
		if not enemy.dead and enemy.pos.distance_to(origin) <= explosion_radius:
			_deal_secondary_damage(enemy, blast_damage, Color("ff9a45"), "BLAST")
			targets_hit += 1
	if moving_aftershock_level > 0:
		# Store only the delayed strength, never the first blast's position. When
		# the timer expires, the aftershock samples ball_position so it travels
		# with the warrior instead of repeating at a stale impact point.
		pending_aftershocks.append({
			"timer": 0.40,
			"damage": maxi(1, int(round(float(blast_damage) * 0.40))),
			"radius": explosion_radius * 0.70,
		})
	_show_status("RUNE BLAST  x%d" % targets_hit, 0.72)
	_remove_dead_enemies()


func _trigger_moving_aftershock(damage: int, radius: float) -> void:
	var origin := ball_position
	explosions.append({
		"pos": origin,
		"life": 0.48,
		"max_life": 0.48,
		"radius": radius,
		"kind": "aftershock",
	})
	_play_sfx(SFX_EXPLOSION, -6.0, 1.10, 1.18)
	screen_flash = maxf(screen_flash, 0.22)
	_spawn_burst(origin, Color("ffd166"), 20)
	var targets_hit := 0
	for enemy in enemies:
		if not enemy.dead and enemy.pos.distance_to(origin) <= radius:
			_deal_secondary_damage(enemy, damage, Color("ffd166"), "ECHO")
			targets_hit += 1
	_show_status("MARCHING AFTERSHOCK  x%d" % targets_hit, 0.64)
	_remove_dead_enemies()


func _nearest_other_enemy(origin: Vector2, excluded_enemy: Dictionary) -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_distance: float = INF
	for candidate in enemies:
		if candidate.dead or (not excluded_enemy.is_empty() and candidate.pos == excluded_enemy.pos):
			continue
		var distance: float = candidate.pos.distance_squared_to(origin)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest


func _launch_throwing_axes(origin: Vector2) -> void:
	var available_targets: Array[Dictionary] = []
	for enemy in enemies:
		if not enemy.dead:
			available_targets.append(enemy)
	if available_targets.is_empty():
		return
	throwing_axe_cooldown = _impact_proc_cooldown(axe_cooldown_level)
	var size_damage_multiplier := 1.0 + (permanent_size_scale - 1.0) * 0.75
	var axe_damage := maxi(2, int(round(6.0 * (1.0 + float(axe_damage_level) * 0.25) * attack_power_multiplier * size_damage_multiplier)))
	var axes_to_throw := mini(1 + axe_count_level, available_targets.size())
	for _axe_index in axes_to_throw:
		var target_index := 0
		var nearest_distance := INF
		for candidate_index in available_targets.size():
			var candidate_distance := origin.distance_squared_to(available_targets[candidate_index].pos)
			if candidate_distance < nearest_distance:
				nearest_distance = candidate_distance
				target_index = candidate_index
		var target: Dictionary = available_targets[target_index]
		available_targets.remove_at(target_index)
		var duration := clampf(origin.distance_to(target.pos) / 680.0, 0.24, 0.72)
		flying_axes.append({
			"start": origin,
			"pos": origin,
			"target": target,
			"target_pos": target.pos,
			"phase": "outbound",
			"return_hit": false,
			"elapsed": 0.0,
			"duration": duration,
			"angle": 0.0,
			"damage": axe_damage,
		})
	_play_sfx(SFX_AXE_THROW, -5.0, 0.96, 1.05)
	_add_floating_text(origin + Vector2(-28, -42), "AXE x%d" % axes_to_throw, Color("e5c487"))


func _remove_dead_enemies() -> void:
	var survivors: Array[Dictionary] = []
	for enemy in enemies:
		if not enemy.dead:
			survivors.append(enemy)
	enemies = survivors


func _speed_damage_multiplier(speed: float) -> float:
	if speed >= 930.0:
		return 1.60
	if speed >= 760.0:
		return 1.30
	return 1.0


func _add_energy(amount: float) -> void:
	var was_ready := energy >= ENERGY_MAX - 0.01
	energy = minf(ENERGY_MAX, energy + amount)
	if not was_ready and energy >= ENERGY_MAX - 0.01:
		_show_status("SKILL TARGETS ONLINE", 1.2)
		screen_flash = 0.22


func _gain_shield(base_amount: int, gain_cap: int = SHIELD_MAX) -> int:
	var scaled_gain := float(base_amount) * (1.0 + float(shield_training_level) * 0.25) + shield_gain_fraction
	var whole_gain := int(floor(scaled_gain))
	shield_gain_fraction = scaled_gain - float(whole_gain)
	var actual_gain := mini(whole_gain, mini(gain_cap, SHIELD_MAX - shield))
	shield += actual_gain
	return actual_gain


func _activate_skill(id: String, pos: Vector2, color: Color) -> void:
	if id == "guard" and shield >= SHIELD_MAX:
		_show_status("SHIELD ALREADY FULL", 0.8)
		return
	energy = 0.0
	screen_flash = 0.42
	if id == "charge":
		charge_timer = 3.0
		if ball_velocity.length() > 0.1:
			var charge_floor := CHARGE_MIN_SPEED * (1.0 + speed_upgrade_bonus * 0.65)
			ball_velocity = ball_velocity.normalized() * minf(_current_max_speed(), maxf(charge_floor, ball_velocity.length() * 1.30))
		_show_status("CHARGE!  3.0s", 1.0)
		_play_sfx(SFX_CHARGE, -4.5, 0.98, 1.04)
	else:
		var guard_gain := _gain_shield(GUARD_SHIELD_GAIN)
		_show_status("GUARD  +%d SHIELD" % guard_gain, 1.0)
		_play_sfx(SFX_GUARD, -3.5, 0.94, 1.05)
	_spawn_burst(pos, color, 22)


func _activate_combat_rune(id: String, pos: Vector2, incoming_speed: float, color: Color) -> void:
	match id:
		"might":
			might_timer = MIGHT_DURATION
			score += 25
			_show_status("MIGHT!  BIGGER FOR 5s", 0.82)
			_add_floating_text(pos + Vector2(-34, -46), "MIGHT", GOLD)
			_play_sfx(SFX_MIGHT, -6.0, 0.97, 1.03)
		"war_cry":
			war_cry_ready = true
			score += 25
			_show_status("WAR CRY!  NEXT HIT +40%", 0.82)
			_add_floating_text(pos + Vector2(-44, -46), "NEXT HIT +40%", color)
			_play_sfx(SFX_WAR_CRY, -3.0, 0.96, 1.02)
		_:
			# Preserve the reflected direction, but calculate from pre-impact speed
			# so restitution does not reduce the advertised one-time boost.
			if ball_velocity.length() > 0.1 and incoming_speed > 0.1:
				ball_velocity = ball_velocity.normalized() * minf(_current_max_speed(), incoming_speed * 1.30)
			dash_fx_timer = 0.52
			score += 40
			_show_status("MOMENTUM  +30% SPEED", 0.68)
			_add_floating_text(pos + Vector2(-42, -46), "+30% SPEED", color)
			_play_sfx(SFX_MOMENTUM, -7.0, 0.98, 1.03)
	screen_flash = maxf(screen_flash, 0.26)
	_spawn_burst(pos, color, 18)
	shockwaves.append({"pos": pos, "life": 0.52, "max_life": 0.52, "color": color})


func _ball_drained() -> void:
	if enemy_phase_active or game_over:
		return
	ball_active = false
	waiting_for_launch = false
	trail.clear()
	combo = 0
	charge_timer = 0.0
	might_timer = 0.0
	war_cry_ready = false
	explosions.clear()
	pending_aftershocks.clear()
	flying_axes.clear()
	if enemies.is_empty():
		_begin_wave_clear()
	else:
		_start_enemy_phase()


func _begin_wave_clear() -> void:
	if wave_clear_timer >= 0.0:
		return
	ball_active = false
	waiting_for_launch = false
	trail.clear()
	charge_timer = 0.0
	might_timer = 0.0
	war_cry_ready = false
	wave_clear_timer = 1.35
	_show_status("STAGE 1-%d CLEAR" % stage_room, 1.2)


func _finish_room_clear() -> void:
	var hp_before_rest := hero_hp
	hero_hp = mini(HERO_MAX_HP, hero_hp + ROOM_CLEAR_HEAL)
	last_room_heal = hero_hp - hp_before_rest
	if stage_room < FINAL_ROOM:
		_show_upgrade_selection()
	else:
		run_complete = true
		waiting_for_launch = false
		ball_active = false
		score += 500
		_show_status("ACT I COMPLETE", 99.0)


func _show_starting_style_selection() -> void:
	starting_style_selection_active = true
	starting_style_selection_timer = 0.0
	starting_style_carousel_index = 0
	starting_style_carousel_anim = 0.0
	starting_style_carousel_direction = 0
	starting_style_hover_direction = 0
	starting_style_confirm_hover = false
	waiting_for_launch = true
	ball_active = false
	status_timer = 0.0


func _starting_style_center_rect() -> Rect2:
	var appear := clampf((starting_style_selection_timer - 0.06) / 0.34, 0.0, 1.0)
	appear = 1.0 - pow(1.0 - appear, 3.0)
	var slide := float(starting_style_carousel_direction) * 34.0 * clampf(starting_style_carousel_anim / 0.22, 0.0, 1.0)
	return Rect2(480.0 + slide, 226.0 + (1.0 - appear) * 125.0, 480.0, 405.0)


func _starting_style_side_rect(direction: int) -> Rect2:
	var appear := clampf((starting_style_selection_timer - 0.14) / 0.34, 0.0, 1.0)
	appear = 1.0 - pow(1.0 - appear, 3.0)
	var x := 170.0 if direction < 0 else 1040.0
	return Rect2(x, 316.0 + (1.0 - appear) * 95.0, 230.0, 255.0)


func _starting_style_confirm_rect() -> Rect2:
	return Rect2(570.0, 665.0, 300.0, 56.0)


func _starting_style_navigation_at_position(position: Vector2) -> int:
	if starting_style_selection_timer < 0.22:
		return 0
	# Include the chevron beside each preview in the same generous hit target.
	if Rect2(150.0, 292.0, 315.0, 310.0).has_point(position):
		return -1
	if Rect2(975.0, 292.0, 315.0, 310.0).has_point(position):
		return 1
	return 0


func _focus_starting_style(index: int) -> void:
	if index < 0 or index >= STARTING_STYLES.size() or index == starting_style_carousel_index:
		return
	var clockwise_distance := wrapi(index - starting_style_carousel_index, 0, STARTING_STYLES.size())
	starting_style_carousel_direction = 1 if clockwise_distance == 1 else -1
	starting_style_carousel_index = index
	starting_style_carousel_anim = 0.22
	starting_style_hover_direction = 0
	starting_style_confirm_hover = false
	queue_redraw()


func _rotate_starting_style(direction: int) -> void:
	if direction == 0:
		return
	var next_index := wrapi(starting_style_carousel_index + direction, 0, STARTING_STYLES.size())
	_focus_starting_style(next_index)
	starting_style_carousel_direction = signi(direction)


func _select_starting_style(index: int) -> void:
	if not starting_style_selection_active or index < 0 or index >= STARTING_STYLES.size():
		return
	var style: Dictionary = STARTING_STYLES[index]
	starting_style_id = String(style.id)
	starting_style_selection_active = false
	starting_style_selection_timer = 0.0
	starting_style_carousel_anim = 0.0
	starting_style_carousel_direction = 0
	starting_style_hover_direction = 0
	starting_style_confirm_hover = false
	prepare_ball()
	screen_flash = maxf(screen_flash, 0.34)
	_play_sfx(SFX_MIGHT, -7.0, 0.98, 1.04)
	_show_status("%s SELECTED" % String(style.name), 1.2)


func _show_upgrade_selection() -> void:
	upgrade_choices.clear()
	var available: Array[Dictionary] = []
	var source_pool: Array = []
	if stage_room == 1:
		upgrade_reward_kind = "ART_UNLOCK"
		source_pool = COMBAT_ART_UNLOCK_POOL
	elif stage_room == 3:
		upgrade_reward_kind = "TRAINING"
		source_pool = TRAINING_POOL
	else:
		upgrade_reward_kind = "ART_UPGRADE"
		source_pool = COMBAT_ART_UPGRADE_POOL.duplicate()
		# Later combat-art rewards may deepen an owned art or unlock another one.
		# This keeps every mechanism obtainable without ever mixing in stat cards.
		for unlock_definition in COMBAT_ART_UNLOCK_POOL:
			source_pool.append(unlock_definition)
	for definition in source_pool:
		var id := String(definition.id)
		var required_art := String(definition.get("requires", ""))
		if not required_art.is_empty() and int(upgrade_levels.get(required_art, 0)) <= 0:
			continue
		var current_level := int(upgrade_levels.get(id, 0))
		if current_level < int(definition.max_level):
			available.append(definition.duplicate(true))
	# A defensive fallback keeps a malformed/debug run from opening an empty
	# reward screen, without mixing categories during the normal five rooms.
	if available.is_empty() and upgrade_reward_kind == "ART_UPGRADE":
		upgrade_reward_kind = "ART_UNLOCK"
		for definition in COMBAT_ART_UNLOCK_POOL:
			if int(upgrade_levels.get(String(definition.id), 0)) < int(definition.max_level):
				available.append(definition.duplicate(true))
	available.shuffle()
	for index in mini(3, available.size()):
		upgrade_choices.append(available[index])
	upgrade_selection_active = true
	upgrade_selection_timer = 0.0
	upgrade_exit_timer = -1.0
	upgrade_selected_index = -1
	upgrade_hover_index = -1
	waiting_for_launch = false
	ball_active = false
	status_timer = 0.0


func _upgrade_card_rect(index: int) -> Rect2:
	var delay := float(index) * 0.10
	var appear := clampf((upgrade_selection_timer - delay) / 0.34, 0.0, 1.0)
	appear = 1.0 - pow(1.0 - appear, 3.0)
	return Rect2(245.0 + float(index) * 315.0, 235.0 + (1.0 - appear) * 150.0, 290.0, 410.0)


func _upgrade_card_at_position(position: Vector2) -> int:
	if upgrade_selected_index >= 0 or upgrade_selection_timer < 0.22:
		return -1
	for index in upgrade_choices.size():
		if _upgrade_card_rect(index).has_point(position):
			return index
	return -1


func _select_upgrade(index: int) -> void:
	if not upgrade_selection_active or upgrade_selected_index >= 0:
		return
	if index < 0 or index >= upgrade_choices.size():
		return
	upgrade_selected_index = index
	upgrade_exit_timer = 0.58
	var choice := upgrade_choices[index]
	_apply_upgrade(choice)
	upgrade_history.append(String(choice.name))
	screen_flash = maxf(screen_flash, 0.55)
	_play_sfx(SFX_MIGHT, -5.0, 1.04, 1.10)


func _apply_upgrade(upgrade: Dictionary) -> void:
	var id := String(upgrade.id)
	var new_level := int(upgrade_levels.get(id, 0)) + 1
	upgrade_levels[id] = new_level
	match id:
		"sharpened_blade":
			attack_power_multiplier = 1.0 + float(new_level) * 0.25
		"windrunner_boots":
			speed_upgrade_bonus += 0.08
		"giants_belt":
			permanent_size_scale += 0.10
		"spring_plate":
			spring_plate_level = new_level
		"blast_impact":
			blast_impact_level = new_level
			blast_impact_cooldown = 0.0
		"blast_damage":
			blast_damage_level = new_level
		"blast_radius":
			blast_radius_level = new_level
		"blast_cooldown":
			blast_cooldown_level = new_level
			blast_impact_cooldown = minf(blast_impact_cooldown, _impact_proc_cooldown(blast_cooldown_level))
		"moving_aftershock":
			moving_aftershock_level = new_level
		"throwing_axe":
			throwing_axe_level = new_level
			throwing_axe_cooldown = 0.0
		"axe_damage":
			axe_damage_level = new_level
		"axe_count":
			axe_count_level = new_level
		"axe_cooldown":
			axe_cooldown_level = new_level
			throwing_axe_cooldown = minf(throwing_axe_cooldown, _impact_proc_cooldown(axe_cooldown_level))
		"returning_axe":
			returning_axe_level = new_level
		"spiked_shield":
			spiked_shield_level = new_level
		"spike_damage":
			spike_damage_level = new_level
		"spike_scatter":
			spike_scatter_level = new_level
		"shieldbreak_retort":
			shieldbreak_retort_level = new_level
		"shield_bash":
			shield_bash_level = new_level
		"shield_training":
			shield_training_level = new_level
		"residual_shield":
			residual_shield_level = new_level
	_show_status("ACQUIRED: %s" % String(upgrade.name), 1.0)


func _advance_to_next_room() -> void:
	upgrade_selection_active = false
	upgrade_selection_timer = 0.0
	upgrade_exit_timer = -1.0
	upgrade_selected_index = -1
	upgrade_hover_index = -1
	upgrade_choices.clear()
	stage_room += 1
	wave = stage_room
	energy = minf(ENERGY_MAX, energy + 30.0)
	particles.clear()
	floating_text.clear()
	shockwaves.clear()
	explosions.clear()
	pending_aftershocks.clear()
	flying_axes.clear()
	warlord_soul_streams.clear()
	_spawn_wave()
	prepare_ball()
	screen_flash = 0.42
	_show_status("ENTER STAGE 1-%d" % stage_room, 1.2)


func _start_enemy_phase() -> void:
	enemy_attack_queue.clear()
	enemy_phase_incoming_total = 0
	shieldbreak_triggered_this_phase = false
	for enemy in enemies:
		var attack := {
			"from": enemy.pos,
			"damage": int(enemy.attack),
			"shield_pierce": float(enemy.get("shield_pierce", 0.0)),
			"kind": enemy.kind,
			"effect": enemy.attack_effect,
		}
		enemy_attack_queue.append(attack)
		enemy_phase_incoming_total += int(enemy.attack)
	if enemy_attack_queue.is_empty():
		_begin_wave_clear()
		return
	enemy_phase_active = true
	enemy_attack_index = 0
	enemy_phase_timer = 0.62
	if passive_test_mode:
		passive_enemy_phase_seen = true
		passive_expected_hp = HERO_MAX_HP - maxi(0, enemy_phase_incoming_total - shield)
	_show_status("INCOMING  %d DAMAGE" % enemy_phase_incoming_total, 1.0)


func _update_enemy_phase(delta: float) -> void:
	enemy_phase_timer -= delta
	if enemy_phase_timer > 0.0:
		return
	if enemy_attack_index < enemy_attack_queue.size() and hero_hp > 0:
		var queued_attack: Dictionary = enemy_attack_queue[enemy_attack_index]
		var attacker_still_alive := false
		for enemy in enemies:
			if not enemy.dead and enemy.pos == queued_attack.from:
				attacker_still_alive = true
				break
		if attacker_still_alive:
			_resolve_enemy_attack(queued_attack)
		enemy_attack_index += 1
		enemy_phase_timer = ENEMY_ATTACK_INTERVAL if attacker_still_alive else 0.04
		return
	_finish_enemy_phase()


func _resolve_enemy_attack(attack: Dictionary) -> void:
	var raw_damage := int(attack.damage)
	var triggered_retort := false
	var pierce_ratio := clampf(float(attack.get("shield_pierce", 0.0)), 0.0, 1.0)
	var piercing_damage := clampi(int(round(float(raw_damage) * pierce_ratio)), 0, raw_damage)
	var shieldable_damage := raw_damage - piercing_damage
	var shield_before_hit := shield
	var blocked := mini(shield, shieldable_damage)
	var hp_damage := piercing_damage + shieldable_damage - blocked
	shield -= blocked
	hero_hp = maxi(0, hero_hp - hp_damage)
	var attacking_enemy: Dictionary = {}
	for enemy in enemies:
		if enemy.pos == attack.from:
			enemy.pulse = 1.0
			attacking_enemy = enemy
			break
	var target := Vector2(720, 810)
	_play_enemy_attack_effect(attacking_enemy, String(attack.effect), hp_damage)
	if blocked > 0:
		_play_sfx(SFX_SHIELD_BLOCK, -3.5, 0.94, 1.04)
	if hp_damage > 0:
		var hurt_pitch := 0.88 if String(attack.kind) == "boss" else 1.0
		_play_sfx(SFX_HERO_HIT, -2.0, hurt_pitch - 0.045, hurt_pitch + 0.045)
	_spawn_burst(target, GREEN if hp_damage == 0 else RED, 10)
	if blocked > 0:
		_add_floating_text(target + Vector2(-78, -18), "BLOCK %d" % blocked, GREEN)
	if piercing_damage > 0:
		_add_floating_text(target + Vector2(-44, 12), "PIERCE %d" % piercing_damage, ARCANE)
	if hp_damage > 0:
		_add_floating_text(target + Vector2(20, -18), "-%d HP" % hp_damage, RED)
	if blocked > 0 and spiked_shield_level > 0 and not attacking_enemy.is_empty():
		var reflect_ratio := 0.50 * (1.0 + float(spike_damage_level) * 0.25)
		var reflected_damage := maxi(1, int(round(float(blocked) * reflect_ratio)))
		_deal_secondary_damage(attacking_enemy, reflected_damage, GREEN, "THORNS")
		_add_floating_text(target + Vector2(-30, 11), "REFLECT %d" % reflected_damage, Color("b9efa7"))
		_spawn_burst(attacking_enemy.pos, GREEN, 12)
		if spike_scatter_level > 0:
			var scattered := 0
			var scatter_damage := maxi(1, int(round(float(reflected_damage) * 0.50)))
			for candidate in enemies:
				if scattered >= spike_scatter_level:
					break
				if candidate.dead or candidate.pos == attacking_enemy.pos or candidate.pos.distance_to(attacking_enemy.pos) > 220.0:
					continue
				_deal_secondary_damage(candidate, scatter_damage, Color("9bdb83"), "BARBS")
				scattered += 1
		_remove_dead_enemies()
	if shieldbreak_retort_level > 0 and not shieldbreak_triggered_this_phase and shield_before_hit > 0 and shield <= 0:
		shieldbreak_triggered_this_phase = true
		triggered_retort = true
		var retort_damage := maxi(1, int(round(3.0 * (1.0 + float(spike_damage_level) * 0.25) * attack_power_multiplier)))
		for retort_target in enemies:
			if not retort_target.dead:
				_deal_secondary_damage(retort_target, retort_damage, Color("b9efa7"), "RETORT")
				_spawn_burst(retort_target.pos, GREEN, 7)
		screen_flash = maxf(screen_flash, 0.24)
		_show_status("SHIELDBREAK RETORT  ALL -%d" % retort_damage, 0.82)
		_remove_dead_enemies()
	if triggered_retort:
		pass
	elif piercing_damage > 0:
		_show_status("PIERCE %d   BLOCK %d   HP -%d" % [piercing_damage, blocked, hp_damage], 0.72)
	else:
		_show_status("BLOCK %d   HP -%d" % [blocked, hp_damage], 0.55)


func _attack_effect_for_kind(kind: String) -> String:
	match kind:
		"boss":
			return "boss_slam"
		"soldier":
			return "grunt_lunge"
		"mage":
			return "mage_cast"
		_:
			return "grunt_lunge"


func _attack_effect_profile(effect_id: String) -> Dictionary:
	# New attack presentations are registered here, then selected per enemy with
	# its attack_effect field. Combat resolution never needs to know the visuals.
	match effect_id:
		"boss_slam":
			return {"duration": 0.36, "local_strength": 18.0, "screen_strength": 11.0, "vignette": 0.90, "particle_color": GOLD, "particles": 12}
		"ranger_recoil":
			return {"duration": 0.30, "local_strength": 10.0, "screen_strength": 6.0, "vignette": 0.72, "particle_color": Color("e98555"), "particles": 7}
		"mage_cast":
			return {"duration": 0.36, "local_strength": 9.0, "screen_strength": 6.0, "vignette": 0.76, "particle_color": ARCANE, "particles": 11}
		"grunt_lunge":
			return {"duration": 0.28, "local_strength": 13.0, "screen_strength": 7.0, "vignette": 0.78, "particle_color": RED, "particles": 8}
		_:
			return {"duration": 0.24, "local_strength": 7.0, "screen_strength": 5.0, "vignette": 0.65, "particle_color": RED, "particles": 6}


func _play_enemy_attack_effect(attacker: Dictionary, effect_id: String, hp_damage: int) -> void:
	var profile := _attack_effect_profile(effect_id)
	var duration := float(profile.duration)
	var impact_strength := float(profile.screen_strength)
	var vignette_strength := float(profile.vignette)
	if hp_damage == 0:
		impact_strength *= 0.72
		vignette_strength *= 0.65
	screen_shake_strength = maxf(screen_shake_strength, impact_strength)
	screen_shake_timer = maxf(screen_shake_timer, minf(0.32, duration))
	damage_vignette = maxf(damage_vignette, vignette_strength)
	if not attacker.is_empty():
		attacker.attack_fx_timer = duration
		attacker.attack_fx_duration = duration
		var particle_color: Color = profile.particle_color
		_spawn_burst(attacker.pos, particle_color, int(profile.particles))


func _finish_enemy_phase() -> void:
	enemy_phase_active = false
	enemy_phase_timer = 0.0
	enemy_attack_queue.clear()
	enemy_phase_incoming_total = 0
	# HOLD THE LINE keeps 25% at rank one, then adds ten percentage points per
	# later rank until a completed shield build reaches full retention.
	var shield_retention := 0.0
	if residual_shield_level > 0:
		shield_retention = minf(1.0, 0.25 + float(residual_shield_level - 1) * 0.10)
	shield = int(floor(float(shield) * shield_retention))
	if hero_hp <= 0:
		game_over = true
		waiting_for_launch = false
		_show_status("THE HERO HAS FALLEN", 99.0)
	else:
		prepare_ball()
		_show_status("YOUR TURN", 0.9)


func _show_status(text: String, duration: float) -> void:
	status_text = text
	status_timer = duration


func _spawn_burst(pos: Vector2, color: Color, count: int) -> void:
	for index in count:
		var angle := TAU * float(index) / float(count) + randf_range(-0.18, 0.18)
		var speed := randf_range(65.0, 220.0)
		particles.append({
			"pos": pos,
			"vel": Vector2.from_angle(angle) * speed,
			"life": randf_range(0.22, 0.56),
			"max_life": 0.56,
			"color": color,
		})


func _add_floating_text(pos: Vector2, text: String, color: Color) -> void:
	floating_text.append({"pos": pos, "text": text, "color": color, "life": 0.72})


func _update_effects(delta: float) -> void:
	var live_particles: Array[Dictionary] = []
	for particle in particles:
		particle.life -= delta
		if particle.life > 0.0:
			particle.pos += particle.vel * delta
			particle.vel *= pow(0.05, delta)
			live_particles.append(particle)
	particles = live_particles

	var live_shockwaves: Array[Dictionary] = []
	for wave_fx in shockwaves:
		wave_fx.life -= delta
		if wave_fx.life > 0.0:
			live_shockwaves.append(wave_fx)
	shockwaves = live_shockwaves

	var live_explosions: Array[Dictionary] = []
	for explosion in explosions:
		explosion.life -= delta
		if explosion.life > 0.0:
			live_explosions.append(explosion)
	explosions = live_explosions

	var live_aftershocks: Array[Dictionary] = []
	for aftershock in pending_aftershocks:
		aftershock.timer -= delta
		if aftershock.timer <= 0.0:
			_trigger_moving_aftershock(int(aftershock.damage), float(aftershock.radius))
		else:
			live_aftershocks.append(aftershock)
	pending_aftershocks = live_aftershocks

	var live_soul_streams: Array[Dictionary] = []
	for soul_stream in warlord_soul_streams:
		soul_stream.life -= delta
		if soul_stream.life > 0.0:
			live_soul_streams.append(soul_stream)
	warlord_soul_streams = live_soul_streams

	var live_axes: Array[Dictionary] = []
	var axe_resolved := false
	for axe in flying_axes:
		axe.elapsed += delta
		axe.angle += delta * 17.0
		var phase := String(axe.get("phase", "outbound"))
		var progress := clampf(float(axe.elapsed) / float(axe.duration), 0.0, 1.0)
		if phase == "return":
			# The endpoint is sampled every frame, so the return path curves toward
			# the warrior's live position rather than its position at launch time.
			var return_target := ball_position
			axe.pos = Vector2(axe.start).lerp(return_target, progress) + Vector2(0, -sin(progress * PI) * 30.0)
			if not bool(axe.get("return_hit", false)):
				var outbound_target_pos := Vector2(axe.get("outbound_target_pos", Vector2(-10000, -10000)))
				for candidate in enemies.duplicate():
					if candidate.dead or candidate.pos == outbound_target_pos:
						continue
					if candidate.pos.distance_to(Vector2(axe.pos)) <= float(candidate.radius) + 16.0:
						var return_damage := maxi(1, int(round(float(axe.damage) * 0.60)))
						_deal_secondary_damage(candidate, return_damage, Color("9ed6a0"), "RETURN")
						_play_sfx(SFX_ENEMY_HIT, -6.0, 1.12, 1.20)
						axe.return_hit = true
						axe_resolved = true
						break
			if progress < 1.0:
				live_axes.append(axe)
			continue

		var target: Dictionary = axe.target
		var target_pos: Vector2 = axe.target_pos
		if not target.is_empty() and not target.dead:
			target_pos = target.pos
			axe.target_pos = target_pos
		axe.pos = Vector2(axe.start).lerp(target_pos, progress) + Vector2(0, -sin(progress * PI) * 52.0)
		if progress >= 1.0:
			if target.is_empty() or target.dead:
				target = _nearest_other_enemy(target_pos, {})
			if not target.is_empty():
				target_pos = target.pos
				_deal_secondary_damage(target, int(axe.damage), Color("e8c985"), "AXE")
				_play_sfx(SFX_ENEMY_HIT, -5.5, 1.05, 1.14)
				if returning_axe_level > 0:
					axe.phase = "return"
					axe.start = target_pos
					axe.pos = target_pos
					axe.outbound_target_pos = target_pos
					axe.elapsed = 0.0
					axe.duration = clampf(target_pos.distance_to(ball_position) / 720.0, 0.24, 0.72)
					axe.return_hit = false
					live_axes.append(axe)
			axe_resolved = true
		else:
			live_axes.append(axe)
	flying_axes = live_axes
	if axe_resolved:
		_remove_dead_enemies()

	var live_text: Array[Dictionary] = []
	for item in floating_text:
		item.life -= delta
		if item.life > 0.0:
			item.pos.y -= 38.0 * delta
			live_text.append(item)
	floating_text = live_text


func _draw() -> void:
	draw_set_transform(screen_shake_offset)
	_draw_castle_background()
	_draw_side_panels()
	_draw_playfield()
	_draw_table_objects()
	_draw_ball()
	_draw_overlay()
	draw_set_transform(Vector2.ZERO)
	_draw_damage_vignette()


func _draw_damage_vignette() -> void:
	if damage_vignette <= 0.0:
		return
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(RED, damage_vignette * 0.025), true)
	for band in range(8):
		var inset := float(band) * 10.0
		var alpha := damage_vignette * (0.070 - float(band) * 0.007)
		draw_rect(Rect2(inset, inset, SCREEN.x - inset * 2.0, SCREEN.y - inset * 2.0), Color(RED, alpha), false, 12.0)


func _draw_castle_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN).grow(18.0), BG)
	# Large offset blocks make the screen behind the cabinet read as a castle wall.
	for row in range(9):
		var y := float(row * 104 - 12)
		var row_offset := -62.0 if row % 2 == 0 else 0.0
		for column in range(9):
			var block := Rect2(row_offset + float(column) * 188.0, y, 182.0, 98.0)
			draw_rect(block, Color("1c1916"), true)
			draw_line(block.position + Vector2(0, block.size.y), block.end, Color("080706"), 3.0)
			draw_line(block.position + Vector2(block.size.x, 0), block.end, Color("2c261f"), 2.0)

	# Warm pools of torchlight keep the medieval palette from becoming flat.
	for torch_x in [326.0, 1114.0]:
		for ring in range(7, 0, -1):
			var radius := float(ring) * 25.0
			draw_circle(Vector2(torch_x, 168), radius, Color(GOLD, 0.006 + float(8 - ring) * 0.003))


func _draw_side_panels() -> void:
	var left_panel := Rect2(24, 24, 292, 852)
	var right_panel := Rect2(1124, 24, 292, 852)
	_draw_medieval_panel(left_panel)
	_draw_medieval_panel(right_panel)

	_draw_banner(Rect2(42, 42, 256, 74), "BRAVEBALL", "STAGE  1-%d" % stage_room)
	_draw_section_title(Vector2(52, 163), "THE WANDERING HERO", 228.0)
	_text(Vector2(52, 207), "HEALTH", 13, MUTED)
	_text(Vector2(190, 207), "%03d / %03d" % [hero_hp, HERO_MAX_HP], 13, Color("fff1c8"))
	_draw_heart(Vector2(270, 194), 0.62, RED)
	_draw_resource_bar(Rect2(52, 218, 236, 18), float(hero_hp) / float(HERO_MAX_HP), RED)
	_text(Vector2(52, 267), "SHIELD", 13, MUTED)
	_text(Vector2(203, 267), "%02d / %02d" % [shield, SHIELD_MAX], 13, GREEN)
	_draw_shield(Vector2(270, 255), 0.58, GREEN)
	_draw_resource_bar(Rect2(52, 278, 236, 18), float(shield) / float(SHIELD_MAX), GREEN)

	_draw_section_title(Vector2(52, 324), "BATTLE FURY", 228.0)
	draw_rect(Rect2(50, 343, 240, 28), WOOD_DARK, true)
	draw_rect(Rect2(52, 345, 236, 24), BRONZE, false, 2.0)
	draw_rect(Rect2(56, 349, 228, 16), Color("19140f"), true)
	var energy_color := GOLD if energy >= ENERGY_MAX else RUNE
	draw_rect(Rect2(56, 349, 228.0 * energy / ENERGY_MAX, 16), Color(energy_color, 0.32), true)
	for pip in range(10):
		var pip_x := 58.0 + float(pip) * 22.5
		if float(pip + 1) * 10.0 <= energy + 0.01:
			draw_rect(Rect2(pip_x, 352, 16, 10), energy_color, true)
	_text(Vector2(52, 400), "%03d / 100" % int(energy), 21, Color("fff1c8"))
	if energy >= ENERGY_MAX:
		_text(Vector2(52, 430), "STRIKE A GLOWING RUNE", 12, GOLD)

	_draw_section_title(Vector2(52, 511), "FLIPPER COMMANDS", 228.0)
	_draw_keycap(Vector2(52, 541), "A / LEFT", 88.0)
	_text(Vector2(164, 558), "LEFT FLIPPER", 13, MUTED)
	_draw_keycap(Vector2(52, 575), "D / RIGHT", 88.0)
	_text(Vector2(164, 592), "RIGHT FLIPPER", 13, MUTED)
	_draw_keycap(Vector2(52, 609), "SPACE", 88.0)
	_text(Vector2(164, 626), "DROP BALL", 13, MUTED)
	_draw_keycap(Vector2(52, 643), "R", 88.0)
	_text(Vector2(164, 660), "RESTART RUN", 13, MUTED)
	_draw_keycap(Vector2(52, 677), "F", 88.0, GOLD)
	_text(Vector2(164, 694), "FILL ENERGY", 13, MUTED)
	_draw_keycap(Vector2(52, 711), "K", 88.0, Color("e66f4f"))
	_text(Vector2(164, 728), "CLEAR STAGE", 13, MUTED)
	_text(Vector2(52, 765), "F fills Fury; K clears the", 11, MUTED)
	_text(Vector2(52, 783), "current stage for testing.", 11, MUTED)
	_text(Vector2(52, 821), "DMG x%.2f   SIZE x%.2f" % [attack_power_multiplier, permanent_size_scale], 11, Color(PARCHMENT, 0.78))
	_text(Vector2(52, 841), "FLIPPER POWER +%d%%" % int(round(speed_upgrade_bonus * 100.0)), 11, Color(PARCHMENT, 0.78))

	_draw_banner(Rect2(1142, 42, 256, 74), "ADVENTURE", "STAGE  1-%d" % stage_room)
	_draw_section_title(Vector2(1152, 147), "GOBLIN WAR BAND", 228.0)
	_text(Vector2(1152, 195), "STAGE", 13, MUTED)
	_text(Vector2(1253, 198), "1-%d" % stage_room, 28, Color("fff1c8"))
	_text(Vector2(1152, 247), "SCORE", 13, MUTED)
	_text(Vector2(1152, 280), "%07d" % score, 25, GOLD)
	_text(Vector2(1152, 326), "COMBO", 13, MUTED)
	_text(Vector2(1152, 361), "x%d" % combo, 29, CYAN if combo > 1 else Color("fff1c8"))

	_draw_section_title(Vector2(1152, 410), "HERO MOMENTUM", 228.0)
	var speed := ball_velocity.length() if ball_active else 0.0
	_text(Vector2(1152, 460), "%04d" % int(speed), 25, _speed_color(speed))
	_text(Vector2(1152, 495), _speed_tier_name(speed), 13, _speed_color(speed))
	_draw_section_title(Vector2(1152, 532), "ACTIVE BOONS", 228.0)
	var boon_y := 574.0
	var boon_count := 0
	match starting_style_id:
		"iron_oath":
			_text(Vector2(1152, boon_y), "IRON OATH   %d / %d" % [shield_gained_this_ball, IRON_OATH_SHIELD_PER_BALL_CAP], 11, GREEN)
			boon_y += 18.0
			boon_count += 1
		"heavy_strike":
			var heavy_label := "READY  +40%" if heavy_strike_ready else "%d / %d HITS" % [heavy_strike_hits, HEAVY_STRIKE_REQUIRED_HITS]
			_text(Vector2(1152, boon_y), "HEAVY STRIKE   %s" % heavy_label, 11, GOLD if heavy_strike_ready else Color(PARCHMENT, 0.88))
			boon_y += 18.0
			boon_count += 1
		"fury_core":
			_text(Vector2(1152, boon_y), "FURY CORE   +5 / HIT", 11, CYAN)
			boon_y += 18.0
			boon_count += 1
	if might_timer > 0.0:
		_text(Vector2(1152, boon_y), "MIGHT   BIG  %.1fs" % might_timer, 11, GOLD)
		boon_y += 18.0
		boon_count += 1
	if war_cry_ready:
		_text(Vector2(1152, boon_y), "WAR CRY   NEXT HIT +40%", 11, Color("ff8a61"))
		boon_y += 18.0
		boon_count += 1
	if charge_timer > 0.0:
		_text(Vector2(1152, boon_y), "CHARGE   %.1fs" % charge_timer, 11, GOLD)
		boon_y += 18.0
		boon_count += 1
	if spring_rebound_ready:
		_text(Vector2(1152, boon_y), "SPRING   REBOUND ARMED", 11, Color("a9d8c8"))
		boon_y += 18.0
		boon_count += 1
	if blast_impact_level > 0:
		var blast_label := "READY" if blast_impact_cooldown <= 0.0 else "%.1fs" % blast_impact_cooldown
		var blast_name := "BLAST+ECHO" if moving_aftershock_level > 0 else "BLAST"
		_text(Vector2(1152, boon_y), "%s +%d%% R%d  %s" % [blast_name, blast_damage_level * 25, int(_current_explosion_radius()), blast_label], 10, Color("f18b45") if blast_impact_cooldown <= 0.0 else MUTED)
		boon_y += 18.0
		boon_count += 1
	if throwing_axe_level > 0:
		var axe_label := "READY" if throwing_axe_cooldown <= 0.0 else "%.1fs" % throwing_axe_cooldown
		var axe_name := "RETURN AXE" if returning_axe_level > 0 else "AXE"
		_text(Vector2(1152, boon_y), "%s x%d +%d%%  %s" % [axe_name, 1 + axe_count_level, axe_damage_level * 25, axe_label], 10, Color("d6b679") if throwing_axe_cooldown <= 0.0 else MUTED)
		boon_y += 18.0
		boon_count += 1
	if spiked_shield_level > 0:
		var thorn_ratio := int(round(50.0 * (1.0 + float(spike_damage_level) * 0.25)))
		var bash_label := "  BASH +%d" % _shield_bash_bonus() if shield_bash_level > 0 else ""
		_text(Vector2(1152, boon_y), "THORNS %d%%  S+%d%s" % [thorn_ratio, spike_scatter_level, bash_label], 10, GREEN)
		boon_y += 18.0
		boon_count += 1
	if shield_training_level > 0:
		_text(Vector2(1152, boon_y), "SHIELD GAIN  +%d%%" % (shield_training_level * 25), 10, GREEN)
		boon_y += 18.0
		boon_count += 1
	if residual_shield_level > 0:
		var retention_percent := mini(100, 25 + (residual_shield_level - 1) * 10)
		_text(Vector2(1152, boon_y), "SHIELD RETAIN  %d%%" % retention_percent, 10, Color("9cc7bd"))
		boon_count += 1
	if boon_count == 0:
		_text(Vector2(1152, boon_y), "NO ACTIVE BOONS", 11, MUTED)

	_draw_section_title(Vector2(1152, 690), "RUN UPGRADES", 228.0)
	if upgrade_history.is_empty():
		_text(Vector2(1152, 735), "NO BATTLE SPOILS YET", 11, MUTED)
		_text(Vector2(1152, 760), "Clear 1-1 to choose one.", 11, Color(PARCHMENT, 0.72))
	else:
		var history_y := 735.0
		for history_index in range(maxi(0, upgrade_history.size() - 4), upgrade_history.size()):
			var acquired_name := upgrade_history[history_index]
			_text(Vector2(1152, history_y), "•  %s" % acquired_name, 11, Color("fff1c8"))
			history_y += 22.0


func _draw_playfield() -> void:
	var field_rect := Rect2(FIELD_LEFT, FIELD_TOP, FIELD_RIGHT - FIELD_LEFT, FIELD_BOTTOM - FIELD_TOP)
	draw_rect(field_rect.grow(10), WOOD_DARK, true)
	draw_rect(field_rect.grow(6), BRONZE, false, 4.0)
	draw_rect(field_rect, FIELD_BG, true)
	# Uneven dungeon flagstones, intentionally decorative only.
	for row in range(12):
		var stone_y := FIELD_TOP + float(row) * 72.0
		var row_shift := 54.0 if row % 2 == 0 else 0.0
		for column in range(7):
			var stone_x := FIELD_LEFT - row_shift + float(column) * 108.0
			# Clamp every decorative tile to the inner playfield. The staggered
			# negative first column previously leaked over the left cabinet edge.
			var stone_left := maxf(FIELD_LEFT + 3.0, stone_x + 3.0)
			var stone_right := minf(FIELD_RIGHT - 3.0, stone_x + 105.0)
			var stone_top := maxf(FIELD_TOP + 3.0, stone_y + 3.0)
			var stone_bottom := minf(FIELD_BOTTOM - 3.0, stone_y + 69.0)
			if stone_right <= stone_left or stone_bottom <= stone_top:
				continue
			var stone_rect := Rect2(stone_left, stone_top, stone_right - stone_left, stone_bottom - stone_top)
			var tint := Color("1c2c27") if (row + column) % 3 == 0 else Color("1a2925")
			draw_rect(stone_rect, tint, true)
			draw_line(stone_rect.position, stone_rect.position + Vector2(stone_rect.size.x, 0), Color("304038"), 1.0)

	# Small wall banners frame the goblin captain at the top of the table.
	_draw_table_banner(Vector2(420, 76), Color("6f2723"))
	_draw_table_banner(Vector2(990, 76), Color("6f2723"))

	# Drain warning area.
	var drain_poly := PackedVector2Array([
		Vector2(520, 835), Vector2(920, 835), Vector2(995, 890), Vector2(445, 890)
	])
	draw_colored_polygon(drain_poly, Color("231111"))
	draw_line(Vector2(470, 879), Vector2(970, 879), Color(BRONZE, 0.34), 2.0)
	draw_line(Vector2(655, 855), Vector2(785, 855), Color(RED, 0.55), 3.0)
	_text(Vector2(676, 879), "THE ABYSS", 12, Color(RED, 0.78))


func _draw_table_objects() -> void:
	for wall in walls:
		# Bronze-bound oak rails replace the former neon machine parts.
		draw_line(wall.a, wall.b, Color("0d0907a8"), 27.0, true)
		draw_line(wall.a, wall.b, BRONZE, 20.0, true)
		draw_line(wall.a, wall.b, WOOD, 13.0, true)
		draw_line(wall.a, wall.b, Color("b98750"), 3.0, true)
		draw_circle(wall.a, 5.0, Color("d2a85d"))
		draw_circle(wall.b, 5.0, Color("d2a85d"))

	if _goblin_gate_active():
		_draw_goblin_gate()

	for bumper in bumpers:
		var pulse_scale: float = 1.0 + bumper.pulse * 0.20
		var breathe := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.009 + bumper.pos.x)
		var rune_color: Color = bumper.color if bumper.implemented else Color(bumper.color, 0.34)
		var core_radius: float = bumper.radius
		var visual_radius: float = float(bumper.get("visual_radius", core_radius))
		if bumper.implemented:
			draw_circle(bumper.pos, visual_radius * (1.45 + breathe * 0.12) * pulse_scale, Color(rune_color, 0.07 + breathe * 0.045))
		# A thin inlaid rim makes this read as a floor trigger rather than a raised
		# bumper. It has an activation radius but no physical collision.
		draw_circle(bumper.pos, visual_radius * 1.10 * pulse_scale, Color(rune_color, 0.035))
		draw_arc(bumper.pos, visual_radius * 1.10 * pulse_scale, 0, TAU, 40, Color(BRONZE, 0.48), 1.5, true)
		draw_circle(bumper.pos, core_radius * pulse_scale, Color(STONE_DARK, 0.72))
		draw_arc(bumper.pos, core_radius * 0.80, 0, TAU, 36, rune_color, 2.5, true)
		match bumper.id:
			"might":
				_draw_might_glyph(bumper.pos, rune_color)
			"war_cry":
				_draw_war_cry_glyph(bumper.pos, rune_color)
			_:
				_draw_rune_mark(bumper.pos, 0.0, 0.82, Color("d8f8f5"))
		var rune_label_color: Color = rune_color if bumper.implemented else Color(MUTED, 0.78)
		_text_center(bumper.pos + Vector2(-55, visual_radius + 18), 110.0, bumper.name, 10, rune_label_color)

	for deflector in diamond_deflectors:
		_draw_diamond_deflector(deflector)

	for wave_fx in shockwaves:
		var progress: float = 1.0 - wave_fx.life / wave_fx.max_life
		var wave_radius: float = 28.0 + progress * 105.0
		draw_arc(wave_fx.pos, wave_radius, 0, TAU, 48, Color(wave_fx.color, (1.0 - progress) * 0.72), 5.0 - progress * 3.0, true)

	for panel in skill_panels:
		_draw_skill_panel(panel)

	for soul_stream in warlord_soul_streams:
		_draw_warlord_soul_stream(soul_stream)
	_draw_warlord_guard_tethers()
	for enemy in enemies:
		_draw_enemy(enemy)
	_draw_warlord_guards()
	for explosion in explosions:
		_draw_explosion(explosion)
	for axe in flying_axes:
		_draw_flying_axe(axe)

	_draw_flippers()

	for particle in particles:
		var alpha: float = clampf(particle.life / particle.max_life, 0.0, 1.0)
		draw_circle(particle.pos, 3.5 * alpha + 1.0, Color(particle.color, alpha))
	for item in floating_text:
		_text(item.pos, item.text, 16, Color(item.color, clampf(item.life / 0.72, 0.0, 1.0)))


func _draw_warlord_soul_stream(soul_stream: Dictionary) -> void:
	var start: Vector2 = soul_stream.start
	var finish: Vector2 = soul_stream.end
	var max_life := float(soul_stream.max_life)
	var progress := clampf(1.0 - float(soul_stream.life) / max_life, 0.0, 1.0)
	var curve := float(soul_stream.curve)
	var points := PackedVector2Array()
	var tail_start := maxf(0.0, progress - 0.34)
	for point_index in 9:
		var fraction := float(point_index) / 8.0
		var travel := lerpf(tail_start, progress, fraction)
		var point := start.lerp(finish, travel)
		point += Vector2(curve * sin(travel * PI) * 34.0, -sin(travel * PI) * 42.0)
		points.append(point)
	var alpha := minf(1.0, float(soul_stream.life) / 0.18)
	if points.size() > 1:
		draw_polyline(points, Color(GREEN, 0.24 * alpha), 9.0, true)
		draw_polyline(points, Color("b9efa7", 0.82 * alpha), 3.0, true)
	var head := points[points.size() - 1]
	draw_circle(head, 11.0, Color(GREEN, 0.12 * alpha))
	draw_circle(head, 5.0, Color("e7ffd6", 0.92 * alpha))


func _draw_warlord_guard_tethers() -> void:
	var warlord := _living_warlord()
	if warlord.is_empty():
		return
	for guard_source in enemies:
		var guard_slot := int(guard_source.get("guard_slot", -1))
		if bool(guard_source.dead) or guard_slot < 0:
			continue
		var segment := _warlord_guard_segment(warlord, guard_slot)
		var source_color := ARCANE if String(guard_source.kind) == "mage" else Color("e06449")
		draw_line(guard_source.pos, segment.centre, Color(source_color, 0.09), 5.0, true)
		draw_line(guard_source.pos, segment.centre, Color(source_color, 0.24), 1.5, true)


func _draw_warlord_guards() -> void:
	var warlord := _living_warlord()
	if warlord.is_empty():
		return
	for guard_source in enemies:
		var guard_slot := int(guard_source.get("guard_slot", -1))
		if bool(guard_source.dead) or guard_slot < 0:
			continue
		var segment := _warlord_guard_segment(warlord, guard_slot)
		var angle := float(segment.angle)
		var start_angle := angle - WARLORD_GUARD_ARC * 0.5
		var end_angle := angle + WARLORD_GUARD_ARC * 0.5
		var source_color := ARCANE if String(guard_source.kind) == "mage" else Color("e06449")
		# The painted arc matches the tangent collision chord closely enough to
		# make its block area readable without becoming a full circular wall.
		draw_arc(warlord.pos, WARLORD_GUARD_ORBIT_RADIUS, start_angle, end_angle, 12, Color("130b08d9"), 22.0, true)
		draw_arc(warlord.pos, WARLORD_GUARD_ORBIT_RADIUS, start_angle, end_angle, 12, BRONZE, 16.0, true)
		draw_arc(warlord.pos, WARLORD_GUARD_ORBIT_RADIUS, start_angle, end_angle, 12, source_color, 7.0, true)
		draw_arc(warlord.pos, WARLORD_GUARD_ORBIT_RADIUS - 4.0, start_angle, end_angle, 12, Color("ffe4a3", 0.66), 2.0, true)
		draw_circle(segment.a, 4.0, Color("f1cd78"))
		draw_circle(segment.b, 4.0, Color("f1cd78"))
		_draw_shield(segment.centre, 0.36, source_color.lightened(0.18))


func _draw_diamond_deflector(deflector: Dictionary) -> void:
	var points := _diamond_deflector_points(deflector)
	var center: Vector2 = deflector.pos
	var pulse := float(deflector.pulse)
	var shadow := PackedVector2Array()
	for point in points:
		shadow.append(point + Vector2(0.0, 6.0))
	draw_colored_polygon(shadow, Color("0c0806b8"))
	draw_colored_polygon(points, BRONZE.lightened(pulse * 0.16))
	var inner := PackedVector2Array()
	for point in points:
		inner.append(center.lerp(point, 0.73))
	draw_colored_polygon(inner, STONE.lightened(pulse * 0.12))
	var closed_points := PackedVector2Array([points[0], points[1], points[2], points[3], points[0]])
	draw_polyline(closed_points, Color("e2b56b"), 3.0, true)
	for point in points:
		draw_circle(center.lerp(point, 0.83), 3.5, Color("d7ac62"))
	var core := PackedVector2Array([
		center + Vector2(0.0, -8.0),
		center + Vector2(8.0, 0.0),
		center + Vector2(0.0, 8.0),
		center + Vector2(-8.0, 0.0),
	])
	draw_colored_polygon(core, Color("705238"))
	if pulse > 0.0:
		draw_polyline(closed_points, Color(GOLD, pulse * 0.72), 5.0, true)


func _draw_explosion(explosion: Dictionary) -> void:
	var progress := clampf(1.0 - float(explosion.life) / float(explosion.max_life), 0.0, 1.0)
	var fade := 1.0 - progress
	var radius := float(explosion.radius) * (0.18 + progress * 0.82)
	var center: Vector2 = explosion.pos
	var is_aftershock := String(explosion.get("kind", "blast")) == "aftershock"
	var outer_color := Color("ffe28a") if is_aftershock else Color("ffbd58")
	var inner_color := Color("d9a934") if is_aftershock else Color("f06732")
	draw_circle(center, radius * 0.72, Color("ffd166", 0.11 * fade) if is_aftershock else Color("ef4f27", 0.10 * fade))
	draw_arc(center, radius, 0.0, TAU, 64, Color(outer_color, 0.92 * fade), 7.0 - progress * 4.0, true)
	draw_arc(center, radius * 0.72, 0.0, TAU, 48, Color(inner_color, 0.72 * fade), 3.0, true)
	for spark_index in range(12):
		var angle := TAU * float(spark_index) / 12.0 + progress * 0.42
		var uneven := 0.78 + 0.22 * sin(float(spark_index) * 4.71)
		var inner := center + Vector2.from_angle(angle) * radius * 0.28
		var outer := center + Vector2.from_angle(angle) * radius * uneven
		draw_line(inner, outer, Color("fff0a5", 0.86 * fade) if is_aftershock else Color("ff8a3d", 0.86 * fade), 5.0 * fade + 1.0, true)
	var core_radius := maxf(2.0, 34.0 * (1.0 - progress) + 8.0)
	draw_circle(center, core_radius, Color("fff0a5", 0.94 * fade))
	draw_circle(center, core_radius * 0.48, Color("ffffff", 0.90 * fade))


func _draw_flying_axe(axe: Dictionary) -> void:
	var center: Vector2 = axe.pos
	var angle := float(axe.angle)
	var progress := clampf(float(axe.elapsed) / float(axe.duration), 0.0, 1.0)
	var trail_start: Vector2 = axe.start.lerp(center, 0.62)
	var is_returning := String(axe.get("phase", "outbound")) == "return"
	var axe_color := Color("9ed6a0") if is_returning else Color("e8c985")
	draw_line(trail_start, center, Color(axe_color, 0.42 if is_returning else 0.34), 5.0, true)
	draw_circle(center, 24.0, Color(axe_color, 0.12 if is_returning else 0.08))
	_draw_axe_shape(center, angle, 1.0, Color("ddd5be"))


func _draw_axe_shape(center: Vector2, angle: float, scale: float, blade_color: Color) -> void:
	var forward := Vector2.from_angle(angle)
	var side := forward.orthogonal()
	var handle_start := center - forward * 17.0 * scale
	var handle_end := center + forward * 16.0 * scale
	draw_line(handle_start, handle_end, Color("2a1710"), 7.0 * scale, true)
	draw_line(handle_start, handle_end, Color("a66a3e"), 3.5 * scale, true)
	var head_center := center + forward * 11.0 * scale
	var left_blade := PackedVector2Array([
		head_center - forward * 7.0 * scale,
		head_center + side * 5.0 * scale,
		head_center + forward * 8.0 * scale + side * 15.0 * scale,
		head_center + forward * 12.0 * scale + side * 4.0 * scale,
	])
	var right_blade := PackedVector2Array([
		head_center - forward * 7.0 * scale,
		head_center - side * 5.0 * scale,
		head_center + forward * 8.0 * scale - side * 15.0 * scale,
		head_center + forward * 12.0 * scale - side * 4.0 * scale,
	])
	draw_colored_polygon(left_blade, blade_color)
	draw_colored_polygon(right_blade, blade_color.darkened(0.14))
	draw_polyline(left_blade, Color("fff0c5"), 1.5 * scale, true)
	draw_polyline(right_blade, Color("fff0c5"), 1.5 * scale, true)


func _draw_goblin_gate() -> void:
	var offset := Vector2.ZERO
	if gate_hit_timer > 0.0:
		var decay := clampf(gate_hit_timer / 0.20, 0.0, 1.0)
		var phase := float(Time.get_ticks_msec()) * 0.16
		offset = Vector2(sin(phase) * 3.2, cos(phase * 1.3) * 1.6) * decay

	# The large pointed arch is a flat floor relief. It fills the arena visually
	# without adding invisible collision around the useful side routes.
	var arch := PackedVector2Array([
		Vector2(630, 424),
		Vector2(630, 350),
		Vector2(650, 319),
		Vector2(684, 296),
		Vector2(720, 282),
		Vector2(756, 296),
		Vector2(790, 319),
		Vector2(810, 350),
		Vector2(810, 424),
	])
	for index in arch.size():
		arch[index] += offset
	draw_polyline(arch, Color("111916b8"), 18.0, true)
	draw_polyline(arch, Color(STONE, 0.78), 11.0, true)
	draw_polyline(arch, Color(BRONZE, 0.58), 2.0, true)
	_text_center(Vector2(656, 306) + offset, 128.0, "GOBLIN GATE", 11, Color(PARCHMENT, 0.84))

	# Hanging chains make the two sloped deflectors read as door leaves rather
	# than another pair of ordinary table rails.
	for chain_x in [676.0, 764.0]:
		var chain_start := Vector2(chain_x, 319) + offset
		var chain_end := Vector2(696 if chain_x < 720.0 else 744, 412) + offset
		draw_line(chain_start, chain_end, Color("17100c"), 6.0, true)
		draw_line(chain_start, chain_end, Color(BRONZE, 0.82), 2.2, true)
		for link_index in range(1, 6):
			var link_pos := chain_start.lerp(chain_end, float(link_index) / 6.0)
			draw_circle(link_pos, 3.0, Color("d0a251"))

	for gate_panel in gate_panels:
		var a: Vector2 = gate_panel.a + offset
		var b: Vector2 = gate_panel.b + offset
		draw_line(a, b, Color("0d0907c8"), 34.0, true)
		draw_line(a, b, BRONZE, 28.0, true)
		draw_line(a, b, Color("74482d"), 21.0, true)
		draw_line(a + Vector2(0, -3), b + Vector2(0, -3), Color("b17a4d"), 3.0, true)
		for stud_t in [0.16, 0.48, 0.80]:
			var stud := a.lerp(b, stud_t)
			draw_circle(stud, 4.0, Color("342016"))
			draw_circle(stud, 2.2, Color("d0a251"))

	var lock_pos := Vector2(720, 434) + offset
	draw_circle(lock_pos, 14.0, Color("120d0a"))
	draw_arc(lock_pos, 14.0, 0, TAU, 28, BRONZE, 4.0, true)
	draw_rect(Rect2(lock_pos - Vector2(5, 1), Vector2(10, 9)), Color("d0a251"), true)
	draw_arc(lock_pos - Vector2(0, 3), 6.0, PI, TAU, 16, Color("f2d28b"), 2.2, true)


func _draw_skill_panel(panel: Dictionary) -> void:
	var energy_ready: bool = energy >= ENERGY_MAX - 0.01
	var ready: bool = energy_ready and not (panel.id == "guard" and shield >= SHIELD_MAX)
	var color: Color = panel.color
	var pulse: float = panel.pulse
	if ready:
		var breathe := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.008)
		draw_circle(panel.pos, panel.radius * (1.55 + breathe * 0.14), Color(color, 0.10 + breathe * 0.09))
	draw_circle(panel.pos, panel.radius * (1.08 + pulse * 0.10), Color(color, 0.035 + pulse * 0.06))
	draw_arc(panel.pos, panel.radius * 1.08, 0, TAU, 44, Color(BRONZE, 0.52), 1.8, true)
	draw_circle(panel.pos, panel.radius * 0.96, Color("26302c9c"))
	draw_arc(panel.pos, panel.radius * 0.82, 0, TAU, 40, color if ready else Color(MUTED, 0.42), 3.0, true)
	if panel.id == "guard":
		_draw_shield(panel.pos + Vector2(0, -2), 0.88, color if ready else Color("5b5d54"))
	else:
		_draw_charge_glyph(panel.pos, color if ready else Color("5b5d54"))
	_text(panel.pos + Vector2(-31 if panel.id == "guard" else -39, 56), panel.name, 12, color if ready else MUTED)
	if ready:
		_text(panel.pos + Vector2(-20, 73), "READY", 10, Color("fff4d6"))
	elif energy_ready and panel.id == "guard":
		_text(panel.pos + Vector2(-15, 73), "FULL", 10, GREEN)


func _enemy_attack_draw_offset(enemy: Dictionary) -> Vector2:
	var timer := float(enemy.attack_fx_timer)
	var duration := float(enemy.attack_fx_duration)
	if timer <= 0.0 or duration <= 0.0:
		return Vector2.ZERO
	var progress := clampf(1.0 - timer / duration, 0.0, 1.0)
	var profile := _attack_effect_profile(String(enemy.attack_effect))
	var strength := float(profile.local_strength)
	var origin: Vector2 = enemy.pos
	var toward_hero := (Vector2(720, 810) - origin).normalized()
	var sideways := toward_hero.orthogonal()
	match String(enemy.attack_effect):
		"boss_slam":
			return toward_hero * sin(progress * PI) * strength + sideways * sin(progress * TAU * 3.0) * 2.5
		"ranger_recoil":
			return sideways * sin(progress * TAU * 4.0) * strength * 0.60 - toward_hero * sin(progress * PI) * strength * 0.35
		"mage_cast":
			return Vector2(0.0, -absf(sin(progress * PI)) * strength * 0.55) + sideways * sin(progress * TAU * 3.0) * 1.8
		"grunt_lunge":
			return toward_hero * sin(progress * PI) * strength + sideways * sin(progress * TAU * 2.0) * 2.0
		_:
			return sideways * sin(progress * TAU * 4.0) * strength


func _draw_enemy(enemy: Dictionary) -> void:
	# Attack movement is draw-only: it identifies the acting enemy without moving
	# its collision circle or changing the turn-resolution data.
	var pos: Vector2 = enemy.pos + _enemy_attack_draw_offset(enemy)
	var radius: float = enemy.radius
	var is_warlord := bool(enemy.get("is_warlord", false))
	if is_warlord:
		var rage_stacks := int(enemy.rage_stacks)
		for aura_index in range(rage_stacks, 0, -1):
			var aura_radius := radius + 7.0 + float(aura_index) * 5.0
			var breathe := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.010 + float(aura_index))
			draw_arc(pos, aura_radius + breathe * 2.0, -PI * 0.85, PI * 0.35, 34, Color("ef5a3c", 0.16 + breathe * 0.10), 3.0, true)
	draw_circle(pos, radius * 1.38, Color(RED, 0.065))
	draw_circle(pos, radius * 1.10, Color("17100c"))
	draw_arc(pos, radius * 1.10, 0, TAU, 44, BRONZE, 5.0, true)
	draw_circle(pos, radius, Color("142316"))
	var sprite_modulate := Color.WHITE.lerp(Color("fff1bd"), enemy.pulse * 0.72)
	var sprite_rect := Rect2(pos - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0))
	draw_texture_rect(GOBLIN_TEXTURE, sprite_rect, false, sprite_modulate)
	if String(enemy.kind) == "mage":
		_draw_mage_adornment(pos, radius, enemy)
	if is_warlord:
		_draw_warlord_adornment(pos, radius, enemy)
	var ring_color := Color("ef5a3c") if is_warlord else (GOLD if enemy.kind == "boss" else (ARCANE if enemy.kind == "mage" else Color("b84b3f")))
	draw_arc(pos, radius, 0, TAU, 40, ring_color, 3.0, true)
	if enemy.kind == "boss" and not is_warlord:
		_draw_crown(pos + Vector2(0, -radius - 26), 0.72)
	var bar_width := radius * 2.0
	draw_rect(Rect2(pos.x - radius - 2, pos.y - radius - 15, bar_width + 4, 9), WOOD_DARK, true)
	draw_rect(Rect2(pos.x - radius, pos.y - radius - 13, bar_width * maxf(0.0, float(enemy.hp) / float(enemy.max_hp)), 5), ring_color, true)
	var attack_label := "RAGE %d/%d  ATK %d" % [int(enemy.rage_stacks), WARLORD_MAX_RAGE_STACKS, int(enemy.attack)] if is_warlord else ("ARCANE %d" % int(enemy.attack) if enemy.kind == "mage" else "ATK %d" % int(enemy.attack))
	_text_center(Vector2(pos.x - radius - 8, pos.y + radius + 18), bar_width + 16.0, attack_label, 10, Color(ring_color, 0.94))


func _draw_warlord_adornment(pos: Vector2, radius: float, enemy: Dictionary) -> void:
	# Heavy shoulders, a horned helm and an axe keep the circular boss readable
	# while separating him from the smaller crowned captains.
	var rage_stacks := int(enemy.rage_stacks)
	var rage_glow := float(rage_stacks) / float(WARLORD_MAX_RAGE_STACKS)
	draw_arc(pos + Vector2(-radius * 0.44, radius * 0.03), radius * 0.42, PI * 0.65, PI * 1.38, 16, Color("9e3028"), 9.0, true)
	draw_arc(pos + Vector2(radius * 0.44, radius * 0.03), radius * 0.42, -PI * 0.38, PI * 0.35, 16, Color("9e3028"), 9.0, true)
	var helm := PackedVector2Array([
		pos + Vector2(-radius * 0.50, -radius * 0.18),
		pos + Vector2(-radius * 0.31, -radius * 0.68),
		pos + Vector2(0.0, -radius * 0.83),
		pos + Vector2(radius * 0.31, -radius * 0.68),
		pos + Vector2(radius * 0.50, -radius * 0.18),
	])
	draw_colored_polygon(helm, Color("35241d"))
	draw_polyline(helm, Color("d49a55"), 3.0, true)
	var left_horn := PackedVector2Array([
		pos + Vector2(-radius * 0.30, -radius * 0.62),
		pos + Vector2(-radius * 0.78, -radius * 0.94),
		pos + Vector2(-radius * 0.52, -radius * 0.48),
	])
	var right_horn := PackedVector2Array([
		pos + Vector2(radius * 0.30, -radius * 0.62),
		pos + Vector2(radius * 0.78, -radius * 0.94),
		pos + Vector2(radius * 0.52, -radius * 0.48),
	])
	draw_colored_polygon(left_horn, Color("e7d29f"))
	draw_colored_polygon(right_horn, Color("e7d29f"))
	var axe_bottom := pos + Vector2(radius * 0.66, radius * 0.65)
	var axe_top := pos + Vector2(radius * 0.84, -radius * 0.43)
	draw_line(axe_bottom, axe_top, Color("2a1710"), 8.0, true)
	draw_line(axe_bottom, axe_top, Color("a96e3f"), 4.0, true)
	var axe_blade := PackedVector2Array([
		axe_top + Vector2(-3, -7),
		axe_top + Vector2(22, -17),
		axe_top + Vector2(19, 10),
		axe_top + Vector2(-2, 8),
	])
	draw_colored_polygon(axe_blade, Color("e0d1b2").lerp(Color("ff7652"), rage_glow * 0.42))
	draw_polyline(axe_blade, Color("5d2a20"), 2.0, true)
	for stack_index in WARLORD_MAX_RAGE_STACKS:
		var pip_pos := pos + Vector2(-27.0 + float(stack_index) * 18.0, radius + 35.0)
		var active := stack_index < rage_stacks
		draw_circle(pip_pos, 4.5, Color("ef5a3c") if active else Color("49302a"))
		draw_arc(pip_pos, 5.5, 0.0, TAU, 14, Color(GOLD, 0.82 if active else 0.28), 1.5, true)


func _draw_mage_adornment(pos: Vector2, radius: float, enemy: Dictionary) -> void:
	# The mage keeps the same circular collision/readability as other enemies;
	# a compact hat, staff and arcane glow make the role distinct at a glance.
	var cast_ratio := 0.0
	if float(enemy.attack_fx_duration) > 0.0:
		cast_ratio = clampf(float(enemy.attack_fx_timer) / float(enemy.attack_fx_duration), 0.0, 1.0)
	var glow := maxf(float(enemy.pulse) * 0.55, cast_ratio)
	var staff_bottom := pos + Vector2(radius * 0.64, radius * 0.58)
	var staff_top := pos + Vector2(radius * 0.72, -radius * 0.54)
	draw_line(staff_bottom, staff_top, Color("25160f"), 6.0, true)
	draw_line(staff_bottom, staff_top, Color("a87545"), 3.0, true)
	for glow_ring in range(3, 0, -1):
		draw_circle(staff_top, 4.0 + float(glow_ring) * 3.0 + glow * 4.0, Color(ARCANE, 0.025 + glow * 0.035))
	draw_circle(staff_top, 5.0 + glow * 2.0, ARCANE)
	draw_circle(staff_top - Vector2(1.5, 1.5), 1.8, Color("f4ddff"))
	var hat := PackedVector2Array([
		pos + Vector2(-radius * 0.72, -radius * 0.18),
		pos + Vector2(-radius * 0.10, -radius * 0.94),
		pos + Vector2(radius * 0.47, -radius * 0.22),
	])
	draw_colored_polygon(hat, Color("59316f"))
	draw_polyline(PackedVector2Array([hat[0], hat[1], hat[2]]), Color("d19af3"), 2.0, true)
	draw_line(pos + Vector2(-radius * 0.72, -radius * 0.17), pos + Vector2(radius * 0.50, -radius * 0.17), Color("c487e7"), 4.0, true)
	if cast_ratio > 0.0:
		var orbit_radius := radius * (1.18 + (1.0 - cast_ratio) * 0.18)
		draw_arc(pos, orbit_radius, -PI * 0.9, PI * 0.45, 24, Color(ARCANE, 0.45 + cast_ratio * 0.4), 2.5, true)


func _draw_flippers() -> void:
	var left_pivot := LEFT_FLIPPER_PIVOT
	var right_pivot := RIGHT_FLIPPER_PIVOT
	var left_tip := left_pivot + Vector2(FLIPPER_LENGTH, 0).rotated(left_angle)
	var right_tip := right_pivot + Vector2(-FLIPPER_LENGTH, 0).rotated(right_angle)
	for pair in [[left_pivot, left_tip, left_active], [right_pivot, right_tip, right_active]]:
		var color := GOLD if pair[2] else RUNE
		draw_line(pair[0], pair[1], Color(color, 0.12), 38.0, true)
		draw_line(pair[0], pair[1], BRONZE, 29.0, true)
		draw_line(pair[0], pair[1], WOOD, 21.0, true)
		draw_line(pair[0], pair[1], Color("ae7547"), 4.0, true)
		draw_circle(pair[0], 18.0, Color("17110d"))
		draw_arc(pair[0], 18.0, 0, TAU, 24, BRONZE, 5.0, true)
		draw_circle(pair[0], 7.0, color)


func _draw_ball() -> void:
	if not ball_active and not waiting_for_launch:
		return
	if waiting_for_launch:
		_draw_launch_placement_guide()
	var base_visual_radius := BALL_RADIUS * permanent_size_scale
	var visual_radius := base_visual_radius * MIGHT_VISUAL_SCALE if might_timer > 0.0 else base_visual_radius
	var hero_color := Color("e46b4f") if war_cry_ready else (GOLD if charge_timer > 0.0 or might_timer > 0.0 or heavy_strike_ready else RUNE)
	for index in range(trail.size() - 1, -1, -1):
		var boosted_fx := charge_timer > 0.0 or dash_fx_timer > 0.0 or might_timer > 0.0 or war_cry_ready or heavy_strike_ready
		var alpha := (1.0 - float(index) / float(maxi(1, trail.size()))) * (0.48 if boosted_fx else 0.22)
		var radius := visual_radius * (1.0 - float(index) / float(maxi(1, trail.size())) * 0.55)
		draw_circle(trail[index], radius, Color(hero_color, alpha))

	var glow_scale := 2.35 if dash_fx_timer > 0.0 else 1.85
	draw_circle(ball_position, visual_radius * glow_scale, Color(hero_color, 0.16 if dash_fx_timer > 0.0 else 0.10))
	draw_circle(ball_position, visual_radius * 1.16, Color("16100c"))
	draw_arc(ball_position, visual_radius * 1.16, 0, TAU, 32, BRONZE, 2.0, true)
	var sprite_radius := visual_radius * 1.08
	var warrior_rect := Rect2(ball_position - Vector2(sprite_radius, sprite_radius), Vector2(sprite_radius * 2.0, sprite_radius * 2.0))
	draw_texture_rect(WARRIOR_TEXTURE, warrior_rect, false, Color("fff4ca") if charge_timer > 0.0 else Color.WHITE)
	draw_arc(ball_position, visual_radius, 0, TAU, 30, hero_color, 3.0, true)
	if not pending_aftershocks.is_empty():
		var aftershock_time := float(pending_aftershocks[0].timer)
		var countdown := clampf(1.0 - aftershock_time / 0.40, 0.0, 1.0)
		draw_arc(ball_position, visual_radius + 12.0, -PI * 0.5, -PI * 0.5 + TAU * countdown, 28, Color("ffd166", 0.92), 3.0, true)
		var rune_pos := ball_position + Vector2.from_angle(-PI * 0.5 + TAU * countdown) * (visual_radius + 12.0)
		draw_circle(rune_pos, 4.5, Color("fff0a5"))
	if might_timer > 0.0:
		draw_arc(ball_position, visual_radius + 4.0, -PI * 0.85, PI * 0.35, 22, Color(GOLD, 0.82), 2.0, true)
	if war_cry_ready:
		draw_arc(ball_position, visual_radius + 5.0, -0.65, 0.65, 14, Color("ff9f59"), 2.0, true)
	if starting_style_id == "heavy_strike":
		for pip_index in HEAVY_STRIKE_REQUIRED_HITS:
			var angle := -PI * 0.78 + float(pip_index) * PI * 0.28
			var pip_pos := ball_position + Vector2.from_angle(angle) * (visual_radius + 11.0)
			var pip_filled := heavy_strike_ready or pip_index < heavy_strike_hits
			draw_circle(pip_pos, 4.4, Color("17110d"))
			draw_circle(pip_pos, 2.8, GOLD if pip_filled else Color(MUTED, 0.42))
		if heavy_strike_ready:
			draw_circle(ball_position, visual_radius * 2.55, Color(GOLD, 0.08))
			draw_arc(ball_position, visual_radius + 8.0, 0.0, TAU, 32, Color(GOLD, 0.86), 2.5, true)


func _draw_launch_placement_guide() -> void:
	var guide_y := LAUNCH_Y
	var dash_length := 18.0
	var gap_length := 12.0
	var dash_x := LAUNCH_MIN_X
	while dash_x < LAUNCH_MAX_X:
		var dash_end := minf(dash_x + dash_length, LAUNCH_MAX_X)
		draw_line(Vector2(dash_x, guide_y), Vector2(dash_end, guide_y), Color(CYAN, 0.42), 2.0, true)
		dash_x += dash_length + gap_length


func _draw_board_hover_tooltip() -> void:
	var info := _board_hover_info()
	if info.is_empty():
		return
	var accent: Color = info.color
	var target_pos: Vector2 = info.pos
	var target_radius := float(info.radius)
	draw_circle(target_pos, target_radius + 12.0, Color(accent, 0.09))
	draw_arc(target_pos, target_radius + 9.0, 0.0, TAU, 40, Color(accent, 0.92), 2.5, true)

	var card_size := Vector2(314.0, 138.0)
	var card_position := board_hover_mouse + Vector2(20.0, 20.0)
	if card_position.x + card_size.x > FIELD_RIGHT - 12.0:
		card_position.x = board_hover_mouse.x - card_size.x - 20.0
	if board_hover_mouse.y > 480.0:
		card_position.y = board_hover_mouse.y - card_size.y - 20.0
	card_position.x = clampf(card_position.x, FIELD_LEFT + 14.0, FIELD_RIGHT - card_size.x - 14.0)
	card_position.y = clampf(card_position.y, FIELD_TOP + 14.0, FIELD_BOTTOM - card_size.y - 14.0)
	var card := Rect2(card_position, card_size)
	draw_rect(card.grow(6.0), Color("090706dd"), true)
	draw_rect(card, Color("2d2119f5"), true)
	draw_rect(card, accent, false, 3.0)
	draw_rect(Rect2(card.position + Vector2(3.0, 3.0), Vector2(7.0, card.size.y - 6.0)), Color(accent, 0.72), true)
	_draw_corner_rivets(card)
	_text(card.position + Vector2(24.0, 29.0), String(info.title), 18, Color("fff2d0"))
	_text(card.position + Vector2(24.0, 50.0), String(info.role), 10, Color(accent, 0.92))
	draw_line(card.position + Vector2(22.0, 61.0), card.position + Vector2(card.size.x - 18.0, 61.0), Color(accent, 0.34), 1.0)
	_text(card.position + Vector2(24.0, 81.0), String(info.line_1), 11, Color(PARCHMENT, 0.94))
	_text(card.position + Vector2(24.0, 101.0), String(info.line_2), 11, Color("fff2d0"))
	_text(card.position + Vector2(24.0, 121.0), String(info.line_3), 10, MUTED)


func _draw_overlay() -> void:
	if screen_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(GOLD, screen_flash * 0.16), true)

	if status_timer > 0.0 and not status_text.is_empty():
		var box := Rect2(44, 445, 252, 48)
		draw_rect(box.grow(5), WOOD_DARK, true)
		draw_rect(box, Color("2b2119ed"), true)
		draw_rect(box, BRONZE, false, 3.0)
		_draw_corner_rivets(box)
		_text_center(Vector2(box.position.x, 476), box.size.x, status_text, 16, GOLD if "CHARGE" in status_text or "READY" in status_text else Color("fff2d0"))

	if enemy_phase_active:
		var phase_box := Rect2(555, 356, 330, 82)
		draw_rect(phase_box.grow(7), WOOD_DARK, true)
		draw_rect(phase_box, Color("351814ef"), true)
		draw_rect(phase_box, RED, false, 3.0)
		_draw_corner_rivets(phase_box)
		_text_center(Vector2(phase_box.position.x, 389), phase_box.size.x, "ENEMY PHASE", 24, Color("ffd5b0"))
		_text_center(Vector2(phase_box.position.x, 418), phase_box.size.x, "INCOMING %d   ATTACK %d/%d" % [enemy_phase_incoming_total, mini(enemy_attack_index + 1, enemy_attack_queue.size()), enemy_attack_queue.size()], 12, MUTED)

	if waiting_for_launch and not game_over and not starting_style_selection_active:
		var launch_box := Rect2(520, 700, 400, 58)
		draw_rect(launch_box.grow(4), WOOD_DARK, true)
		draw_rect(launch_box, Color("3b2b1edc"), true)
		draw_rect(launch_box, BRONZE, false, 2.0)
		_text_center(Vector2(launch_box.position.x, 723), launch_box.size.x, "MOVE MOUSE  -  CHOOSE START X", 13, Color(PARCHMENT, 0.92))
		_text_center(Vector2(launch_box.position.x, 748), launch_box.size.x, "SPACE OR LEFT CLICK  -  DROP", 15, Color("fff2d0"))
		_draw_board_hover_tooltip()
	if game_over:
		var over_box := Rect2(475, 330, 490, 170)
		draw_rect(over_box.grow(8), WOOD_DARK, true)
		draw_rect(over_box, Color("2b1c17f2"), true)
		draw_rect(over_box, RED, false, 3.0)
		_draw_corner_rivets(over_box)
		_text(Vector2(593, 390), "THE HERO HAS FALLEN", 30, RED)
		_text(Vector2(613, 438), "SCORE  %07d" % score, 20, Color("fff2d0"))
		_text(Vector2(636, 476), "PRESS R TO RETRY", 15, MUTED)

	if starting_style_selection_active:
		_draw_starting_style_selection()
	elif upgrade_selection_active:
		_draw_upgrade_selection()
	elif run_complete:
		_draw_run_complete()


func _draw_starting_style_selection() -> void:
	var reveal := clampf(starting_style_selection_timer / 0.26, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("100806", 0.90 * reveal), true)
	for glow_index in range(5, 0, -1):
		var glow_radius := float(glow_index) * 96.0
		draw_circle(Vector2(720, 400), glow_radius, Color("b9432f", reveal * (0.006 + float(6 - glow_index) * 0.005)))
	_text_center(Vector2(0, 100), SCREEN.x, "BEFORE STAGE  1-1", 17, Color(PARCHMENT, reveal))
	_text_center(Vector2(0, 147), SCREEN.x, "CHOOSE YOUR WARRIOR'S OATH", 34, Color("fff1c8", reveal))
	_text_center(Vector2(0, 182), SCREEN.x, "One fighting discipline shapes the entire run", 13, Color(MUTED, reveal))
	draw_line(Vector2(420, 204), Vector2(1020, 204), Color("b9432f", 0.58 * reveal), 3.0)
	draw_line(Vector2(505, 211), Vector2(935, 211), Color(GOLD, 0.42 * reveal), 1.0)

	var previous_index := wrapi(starting_style_carousel_index - 1, 0, STARTING_STYLES.size())
	var next_index := wrapi(starting_style_carousel_index + 1, 0, STARTING_STYLES.size())
	_draw_starting_style_preview(STARTING_STYLES[previous_index], _starting_style_side_rect(-1), -1)
	_draw_starting_style_preview(STARTING_STYLES[next_index], _starting_style_side_rect(1), 1)
	_draw_starting_style_arrow(Vector2(438, 444), -1, starting_style_hover_direction == -1)
	_draw_starting_style_arrow(Vector2(1002, 444), 1, starting_style_hover_direction == 1)
	_draw_starting_style_banner(STARTING_STYLES[starting_style_carousel_index], _starting_style_center_rect())

	var confirm_rect := _starting_style_confirm_rect()
	var confirm_color := Color("c34a32") if starting_style_confirm_hover else Color("8f3429")
	draw_rect(confirm_rect.grow(5.0), Color("080503d9"), true)
	draw_rect(confirm_rect, Color("351713"), true)
	draw_rect(confirm_rect, confirm_color, false, 3.0)
	draw_rect(Rect2(confirm_rect.position + Vector2(7, 7), Vector2(confirm_rect.size.x - 14, 5)), Color(GOLD, 0.72), true)
	_draw_corner_rivets(confirm_rect.grow(-8.0))
	_text_center(Vector2(confirm_rect.position.x, confirm_rect.position.y + 36), confirm_rect.size.x, "TAKE THIS OATH", 16, Color("fff1c8"))

	for index in STARTING_STYLES.size():
		var dot_color := GOLD if index == starting_style_carousel_index else Color(BRONZE, 0.42)
		draw_circle(Vector2(700.0 + float(index) * 20.0, 744.0), 4.5 if index == starting_style_carousel_index else 3.0, dot_color)
	_text_center(Vector2(0, 775), SCREEN.x, "CLICK A SIDE BANNER OR USE A / D  •  ENTER TO CONFIRM", 13, Color(PARCHMENT, reveal))
	_text_center(Vector2(0, 807), SCREEN.x, "Only direct warrior impacts trigger these innate abilities", 11, Color(MUTED, reveal * 0.82))


func _starting_style_banner_points(rect: Rect2, tail_depth: float) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		Vector2(rect.end.x, rect.end.y - tail_depth),
		Vector2(rect.position.x + rect.size.x * 0.5 + tail_depth, rect.end.y - tail_depth),
		Vector2(rect.position.x + rect.size.x * 0.5, rect.end.y),
		Vector2(rect.position.x + rect.size.x * 0.5 - tail_depth, rect.end.y - tail_depth),
		Vector2(rect.position.x, rect.end.y - tail_depth),
	])


func _draw_closed_polyline(points: PackedVector2Array, color: Color, width: float) -> void:
	var closed_points := points.duplicate()
	closed_points.append(points[0])
	draw_polyline(closed_points, color, width, true)


func _draw_starting_style_banner(style: Dictionary, rect: Rect2) -> void:
	var id := String(style.id)
	var accent := Color(String(style.color))
	var outer_points := _starting_style_banner_points(rect, 44.0)
	var inner_rect := Rect2(rect.position + Vector2(10, 11), rect.size - Vector2(20, 22))
	var inner_points := _starting_style_banner_points(inner_rect, 37.0)
	draw_colored_polygon(outer_points, Color("130806e8"))
	draw_colored_polygon(inner_points, Color("4a1d18f5"))
	_draw_closed_polyline(outer_points, BRONZE, 5.0)
	_draw_closed_polyline(inner_points, Color("b9432f"), 2.0)
	draw_line(Vector2(rect.position.x - 18, rect.position.y + 4), Vector2(rect.end.x + 18, rect.position.y + 4), Color("2b160f"), 13.0, true)
	draw_line(Vector2(rect.position.x - 18, rect.position.y + 4), Vector2(rect.end.x + 18, rect.position.y + 4), GOLD, 4.0, true)
	draw_circle(Vector2(rect.position.x - 18, rect.position.y + 4), 7.0, BRONZE)
	draw_circle(Vector2(rect.end.x + 18, rect.position.y + 4), 7.0, BRONZE)
	_text_center(Vector2(rect.position.x, rect.position.y + 42), rect.size.x, "WARRIOR DISCIPLINE  •  %s" % String(style.type), 12, Color(GOLD, 0.88))
	_draw_starting_style_icon(id, rect.position + Vector2(rect.size.x * 0.5, 119), accent)
	_text_center(Vector2(rect.position.x + 12, rect.position.y + 198), rect.size.x - 24, String(style.name), 27, Color("fff1c8"))
	draw_line(rect.position + Vector2(72, 220), Vector2(rect.end.x - 72, rect.position.y + 220), Color(accent, 0.58), 3.0)
	_text_center(Vector2(rect.position.x + 20, rect.position.y + 260), rect.size.x - 40, String(style.line_1), 13, Color("f0ddbc"))
	_text_center(Vector2(rect.position.x + 20, rect.position.y + 292), rect.size.x - 40, String(style.line_2), 13, Color("d4bfa5"))
	_text_center(Vector2(rect.position.x + 20, rect.position.y + 337), rect.size.x - 40, "INNATE  •  ACTIVE FOR THE ENTIRE RUN", 11, Color(accent, 0.92))


func _draw_starting_style_preview(style: Dictionary, rect: Rect2, direction: int) -> void:
	var accent := Color(String(style.color))
	var hovered := starting_style_hover_direction == direction
	var alpha := 0.92 if hovered else 0.62
	var points := _starting_style_banner_points(rect, 27.0)
	draw_colored_polygon(points, Color("351713", alpha))
	_draw_closed_polyline(points, Color("9e4a37", alpha), 3.0 if hovered else 2.0)
	draw_line(Vector2(rect.position.x - 7, rect.position.y + 3), Vector2(rect.end.x + 7, rect.position.y + 3), Color(BRONZE, alpha), 6.0, true)
	_text_center(Vector2(rect.position.x, rect.position.y + 35), rect.size.x, "PREVIOUS" if direction < 0 else "NEXT", 10, Color(GOLD, alpha))
	_draw_starting_style_icon(String(style.id), rect.position + Vector2(rect.size.x * 0.5, 101), Color(accent, alpha))
	_text_center(Vector2(rect.position.x + 10, rect.position.y + 174), rect.size.x - 20, String(style.name), 17, Color("f5dfbd", alpha))
	_text_center(Vector2(rect.position.x + 10, rect.position.y + 205), rect.size.x - 20, String(style.type), 10, Color(accent, alpha))
	_text_center(Vector2(rect.position.x + 10, rect.position.y + 233), rect.size.x - 20, "CLICK TO VIEW", 10, Color(MUTED, alpha))


func _draw_starting_style_arrow(center: Vector2, direction: int, hovered: bool) -> void:
	var color := GOLD if hovered else Color(BRONZE, 0.72)
	draw_circle(center, 25.0 if hovered else 22.0, Color("4a1d18", 0.88))
	draw_arc(center, 25.0 if hovered else 22.0, 0.0, TAU, 28, color, 2.5, true)
	var tip := center + Vector2(11.0 * float(direction), 0.0)
	var back_x := -8.0 * float(direction)
	var chevron := PackedVector2Array([center + Vector2(back_x, -11.0), tip, center + Vector2(back_x, 11.0)])
	draw_polyline(chevron, color, 4.0, true)


func _draw_starting_style_icon(id: String, center: Vector2, color: Color) -> void:
	draw_circle(center, 46.0, Color(color, 0.08))
	draw_arc(center, 43.0, 0.0, TAU, 42, Color(color, 0.52), 2.0, true)
	match id:
		"iron_oath":
			_draw_shield(center, 1.45, color)
		"heavy_strike":
			draw_line(center + Vector2(-19, 23), center + Vector2(16, -19), Color("17110d"), 10.0, true)
			draw_line(center + Vector2(-19, 23), center + Vector2(16, -19), Color("fff1c8"), 5.0, true)
			var blade := PackedVector2Array([center + Vector2(10, -16), center + Vector2(27, -31), center + Vector2(20, -8)])
			draw_colored_polygon(blade, color)
			draw_line(center + Vector2(-28, 13), center + Vector2(-9, 29), Color("b9844d"), 7.0, true)
			for pip_index in HEAVY_STRIKE_REQUIRED_HITS:
				draw_circle(center + Vector2(-18.0 + float(pip_index) * 18.0, 37.0), 3.5, color)
		_:
			_draw_war_cry_glyph(center + Vector2(4, 0), color)
			for ray_index in 4:
				var direction := Vector2.from_angle(-PI * 0.75 + float(ray_index) * PI * 0.50)
				draw_line(center + direction * 27.0, center + direction * 36.0, color, 3.0, true)


func _draw_upgrade_selection() -> void:
	var reveal := clampf(upgrade_selection_timer / 0.26, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("070806", 0.82 * reveal), true)
	for glow_index in range(5, 0, -1):
		var glow_radius := float(glow_index) * 85.0
		draw_circle(Vector2(720, 166), glow_radius, Color(GOLD, reveal * (0.006 + float(6 - glow_index) * 0.004)))
	var reward_title := "EXPAND YOUR COMBAT ARTS"
	var reward_subtitle := "Unlock another art or enhance any one you own"
	if upgrade_reward_kind == "ART_UNLOCK":
		reward_title = "CHOOSE A COMBAT ART"
		reward_subtitle = "Unlock a rebound-powered combat mechanism"
	elif upgrade_reward_kind == "TRAINING":
		reward_title = "CHOOSE BATTLE TRAINING"
		reward_subtitle = "Training improves the warrior's underlying numbers"
	var rest_text := "REST +%d HP" % last_room_heal if last_room_heal > 0 else "REST • HEALTH FULL"
	_text_center(Vector2(0, 100), SCREEN.x, "STAGE  1-%d  CLEARED" % stage_room, 17, Color(PARCHMENT, reveal))
	_text_center(Vector2(0, 151), SCREEN.x, reward_title, 34, Color("fff1c8", reveal))
	_text_center(Vector2(0, 184), SCREEN.x, "%s  •  %s  •  NEXT: STAGE 1-%d" % [reward_subtitle, rest_text, stage_room + 1], 13, Color(MUTED, reveal))
	draw_line(Vector2(445, 204), Vector2(995, 204), Color(BRONZE, 0.66 * reveal), 2.0)

	for index in upgrade_choices.size():
		_draw_upgrade_card(index, upgrade_choices[index], _upgrade_card_rect(index))

	_text_center(Vector2(0, 698), SCREEN.x, "CLICK A CARD  •  OR PRESS 1 / 2 / 3", 14, Color(PARCHMENT, reveal))
	_text_center(Vector2(0, 733), SCREEN.x, "The battle pauses while spoils are chosen", 11, Color(MUTED, reveal * 0.82))


func _draw_upgrade_card(index: int, upgrade: Dictionary, rect: Rect2) -> void:
	var id := String(upgrade.id)
	var accent := Color(String(upgrade.color))
	var is_hovered := index == upgrade_hover_index and upgrade_selected_index < 0
	var is_selected := index == upgrade_selected_index
	var pulse := 0.5 + 0.5 * sin(upgrade_selection_timer * 14.0)
	var border := accent.lightened(0.22) if is_hovered or is_selected else BRONZE
	var grow := (2.0 + pulse * 3.0) if is_selected else (3.0 if is_hovered else 0.0)
	var card_rect := rect.grow(grow)
	draw_rect(card_rect.grow(7), Color("080604d9"), true)
	if is_selected:
		draw_rect(card_rect.grow(12 + pulse * 4.0), Color(accent, 0.20 * (1.0 - pulse * 0.35)), false, 5.0)
	draw_rect(card_rect, Color("33271f"), true)
	draw_rect(card_rect.grow(-7), Color("1d1d19"), true)
	draw_rect(card_rect, border, false, 4.0 if is_hovered or is_selected else 2.0)
	draw_rect(Rect2(card_rect.position + Vector2(7, 7), Vector2(card_rect.size.x - 14, 8)), accent, true)
	_draw_corner_rivets(card_rect.grow(-9))
	_text_center(Vector2(card_rect.position.x, card_rect.position.y + 38), card_rect.size.x, "%d" % (index + 1), 13, accent)
	_text_center(Vector2(card_rect.position.x, card_rect.position.y + 63), card_rect.size.x, String(upgrade.type), 11, Color(accent, 0.92))
	_draw_reward_icon(id, card_rect.position + Vector2(card_rect.size.x * 0.5, 121), accent)
	_text_center(Vector2(card_rect.position.x + 10, card_rect.position.y + 195), card_rect.size.x - 20, String(upgrade.name), 21, Color("fff1c8"))
	draw_line(card_rect.position + Vector2(35, 216), Vector2(card_rect.end.x - 35, card_rect.position.y + 216), Color(accent, 0.46), 2.0)
	_text_center(Vector2(card_rect.position.x + 18, card_rect.position.y + 258), card_rect.size.x - 36, String(upgrade.line_1), 13, Color("f0ddbc"))
	_text_center(Vector2(card_rect.position.x + 18, card_rect.position.y + 287), card_rect.size.x - 36, String(upgrade.line_2), 12, MUTED)
	var shown_level := int(upgrade_levels.get(id, 0))
	if not is_selected:
		shown_level += 1
	_text_center(Vector2(card_rect.position.x + 18, card_rect.position.y + 340), card_rect.size.x - 36, "LEVEL %d / %d" % [shown_level, int(upgrade.max_level)], 12, Color(accent, 0.90))
	if is_selected:
		draw_rect(Rect2(card_rect.position + Vector2(38, 361), Vector2(card_rect.size.x - 76, 31)), Color(accent, 0.22), true)
		_text_center(Vector2(card_rect.position.x + 38, card_rect.position.y + 383), card_rect.size.x - 76, "CHOSEN", 14, Color("fff7d6"))
	elif is_hovered:
		_text_center(Vector2(card_rect.position.x + 18, card_rect.position.y + 383), card_rect.size.x - 36, "TAKE THIS SPOIL", 12, accent)
	else:
		_text_center(Vector2(card_rect.position.x + 18, card_rect.position.y + 383), card_rect.size.x - 36, "CHOOSE", 12, Color(MUTED, 0.72))
	if upgrade_selected_index >= 0 and not is_selected:
		draw_rect(card_rect, Color("090a08a6"), true)


func _draw_reward_icon(id: String, center: Vector2, color: Color) -> void:
	draw_circle(center, 46.0, Color(color, 0.08))
	draw_arc(center, 43.0, 0.0, TAU, 42, Color(color, 0.52), 2.0, true)
	match id:
		"sharpened_blade":
			draw_line(center + Vector2(-19, 24), center + Vector2(15, -19), Color("fff1c8"), 7.0, true)
			var blade := PackedVector2Array([center + Vector2(10, -16), center + Vector2(27, -31), center + Vector2(20, -8)])
			draw_colored_polygon(blade, color)
			draw_line(center + Vector2(-25, 18), center + Vector2(-9, 31), Color("b9844d"), 6.0, true)
		"windrunner_boots":
			var boot := PackedVector2Array([center + Vector2(-15, -25), center + Vector2(5, -25), center + Vector2(5, 8), center + Vector2(28, 18), center + Vector2(25, 30), center + Vector2(-13, 28), center + Vector2(-22, 12)])
			draw_colored_polygon(boot, Color(color, 0.80))
			draw_polyline(boot, Color("fff1c8"), 2.0, true)
			for streak_y in [-13.0, 0.0, 13.0]:
				draw_line(center + Vector2(-42, streak_y), center + Vector2(-26, streak_y - 4), color, 3.0, true)
		"giants_belt":
			draw_line(center + Vector2(-34, 0), center + Vector2(34, 0), Color("8b5135"), 18.0, true)
			draw_rect(Rect2(center - Vector2(15, 15), Vector2(30, 30)), color, true)
			draw_rect(Rect2(center - Vector2(8, 8), Vector2(16, 16)), Color("36251b"), true)
		"spring_plate":
			var spring_points := PackedVector2Array([center + Vector2(-30, -22), center + Vector2(-12, -7), center + Vector2(-29, 7), center + Vector2(-10, 22), center + Vector2(9, 7), center + Vector2(-7, -7), center + Vector2(12, -22), center + Vector2(30, -7)])
			draw_polyline(spring_points, color, 7.0, true)
			draw_line(center + Vector2(-34, 31), center + Vector2(34, 31), Color("fff1c8"), 5.0, true)
		"moving_aftershock":
			for ring_index in range(2):
				var ring_center := center + Vector2(-13.0 + float(ring_index) * 26.0, 0.0)
				draw_arc(ring_center, 17.0, 0.0, TAU, 24, color, 4.0, true)
				draw_circle(ring_center, 6.0, Color("fff0a5"))
			draw_line(center + Vector2(-5, -25), center + Vector2(15, -25), Color("fff1c8"), 3.0, true)
			draw_line(center + Vector2(15, -25), center + Vector2(8, -32), Color("fff1c8"), 3.0, true)
		"blast_impact", "blast_damage", "blast_radius", "blast_cooldown":
			for ray in range(10):
				var direction := Vector2.from_angle(TAU * float(ray) / 10.0)
				draw_line(center + direction * 13.0, center + direction * (28.0 + float(ray % 3) * 5.0), color, 5.0, true)
			draw_circle(center, 17.0, Color("fff0a5"))
			draw_circle(center, 8.0, Color("f15c35"))
		"returning_axe":
			_draw_axe_shape(center, -0.72, 1.18, Color("ddd5be"))
			draw_arc(center, 36.0, -PI * 0.10, PI * 1.30, 24, color, 4.0, true)
			var arrow_tip := center + Vector2.from_angle(PI * 1.30) * 36.0
			draw_line(arrow_tip, arrow_tip + Vector2(12, -2), color, 4.0, true)
			draw_line(arrow_tip, arrow_tip + Vector2(3, 11), color, 4.0, true)
		"throwing_axe", "axe_damage", "axe_count", "axe_cooldown":
			_draw_axe_shape(center, -0.72, 1.35, Color("ddd5be"))
		"shield_bash":
			_draw_shield(center + Vector2(-5, 0), 1.32, color)
			for ray_y in [-18.0, 0.0, 18.0]:
				draw_line(center + Vector2(22, ray_y * 0.62), center + Vector2(39, ray_y), Color("fff1c8"), 4.0, true)
		"spiked_shield", "spike_damage", "spike_scatter", "shieldbreak_retort":
			_draw_shield(center, 1.40, color)
			# Eight evenly readable contact points wrap the complete shield. The
			# previous list stopped on the lower-right, leaving the middle-left and
			# lower-left edges visibly bare.
			for spike_angle in [-2.55, -1.85, -1.29, -0.59, 0.24, 0.88, 2.26, 2.90]:
				var spike_direction := Vector2.from_angle(spike_angle)
				draw_line(center + spike_direction * 20.0, center + spike_direction * 31.0, Color("fff1c8"), 4.0, true)
		"shield_training", "residual_shield":
			_draw_shield(center, 1.45, color)


func _draw_run_complete() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("070806d9"), true)
	var victory_box := Rect2(440, 245, 560, 330)
	draw_rect(victory_box.grow(10), Color("080604e8"), true)
	draw_rect(victory_box, Color("2b251c"), true)
	draw_rect(victory_box, GOLD, false, 4.0)
	_draw_corner_rivets(victory_box.grow(-12))
	_draw_crown(Vector2(720, 296), 1.20)
	_text_center(Vector2(victory_box.position.x, 358), victory_box.size.x, "ACT I COMPLETE", 36, Color("fff1c8"))
	_text_center(Vector2(victory_box.position.x, 399), victory_box.size.x, "STAGES 1-1  THROUGH  1-5 CLEARED", 15, GOLD)
	var final_rest_text := "FINAL REST  +%d HP" % last_room_heal if last_room_heal > 0 else "FINAL REST  •  HEALTH FULL"
	_text_center(Vector2(victory_box.position.x, 429), victory_box.size.x, final_rest_text, 11, GREEN)
	var spoil_text := "NO SPOILS" if upgrade_history.is_empty() else "SPOIL:  %s" % upgrade_history[-1]
	_text_center(Vector2(victory_box.position.x + 25, 455), victory_box.size.x - 50, spoil_text, 13, Color(PARCHMENT, 0.90))
	_text_center(Vector2(victory_box.position.x, 501), victory_box.size.x, "SCORE  %07d" % score, 22, Color("fff4d6"))
	_text_center(Vector2(victory_box.position.x, 548), victory_box.size.x, "PRESS R TO BEGIN A NEW RUN", 13, MUTED)


func _draw_medieval_panel(rect: Rect2) -> void:
	draw_rect(rect.grow(5), Color("090705b8"), true)
	draw_rect(rect, WOOD_DARK, true)
	draw_rect(rect.grow(-7), BRONZE, false, 3.0)
	draw_rect(rect.grow(-12), PANEL, true)
	# Leather-grain lines and small rivets sell the cabinet without using assets.
	for grain_y in range(int(rect.position.y + 28), int(rect.end.y - 20), 56):
		draw_line(Vector2(rect.position.x + 18, grain_y), Vector2(rect.end.x - 18, grain_y + 4), Color(PARCHMENT, 0.025), 2.0)
	_draw_corner_rivets(rect.grow(-10))


func _draw_banner(rect: Rect2, title: String, subtitle: String) -> void:
	var tail_left := PackedVector2Array([
		Vector2(rect.position.x - 8, rect.position.y + 12),
		Vector2(rect.position.x + 18, rect.position.y + 20),
		Vector2(rect.position.x + 18, rect.end.y - 8),
		Vector2(rect.position.x - 8, rect.end.y),
	])
	var tail_right := PackedVector2Array([
		Vector2(rect.end.x + 8, rect.position.y + 12),
		Vector2(rect.end.x - 18, rect.position.y + 20),
		Vector2(rect.end.x - 18, rect.end.y - 8),
		Vector2(rect.end.x + 8, rect.end.y),
	])
	draw_colored_polygon(tail_left, Color("54231f"))
	draw_colored_polygon(tail_right, Color("54231f"))
	draw_rect(rect, Color("6b2b25"), true)
	draw_rect(rect, BRONZE, false, 3.0)
	draw_line(Vector2(rect.position.x + 16, rect.position.y + 48), Vector2(rect.end.x - 16, rect.position.y + 48), Color(GOLD, 0.42), 1.0)
	_text_center(Vector2(rect.position.x, rect.position.y + 34), rect.size.x, title, 25, Color("fff1c8"))
	_text_center(Vector2(rect.position.x, rect.position.y + 63), rect.size.x, subtitle, 11, Color(PARCHMENT, 0.88))


func _draw_section_title(pos: Vector2, title: String, width: float) -> void:
	draw_line(pos + Vector2(0, 10), pos + Vector2(width, 10), Color(BRONZE, 0.48), 2.0)
	draw_rect(Rect2(pos.x, pos.y - 11, minf(width, 178.0), 24), PANEL, true)
	_text(pos + Vector2(0, 5), title, 14, GOLD)


func _draw_keycap(pos: Vector2, label: String, width: float, label_color: Color = Color("fff1c8")) -> void:
	var key_rect := Rect2(pos, Vector2(width, 24))
	draw_rect(key_rect, WOOD_DARK, true)
	draw_rect(key_rect.grow(-2), Color("493122"), true)
	draw_rect(key_rect, BRONZE, false, 2.0)
	_text_center(pos + Vector2(0, 17), width, label, 12, label_color)


func _draw_resource_bar(rect: Rect2, ratio: float, color: Color) -> void:
	draw_rect(rect, WOOD_DARK, true)
	draw_rect(rect.grow(-2), Color("17120f"), true)
	var inner := rect.grow(-4)
	draw_rect(Rect2(inner.position, Vector2(inner.size.x * clampf(ratio, 0.0, 1.0), inner.size.y)), color, true)
	draw_rect(rect, BRONZE, false, 2.0)
	for tick in range(1, 5):
		var tick_x := rect.position.x + rect.size.x * float(tick) / 5.0
		draw_line(Vector2(tick_x, rect.position.y + 3), Vector2(tick_x, rect.end.y - 3), Color("17120f80"), 1.0)


func _draw_corner_rivets(rect: Rect2) -> void:
	for rivet in [
		rect.position + Vector2(7, 7),
		Vector2(rect.end.x - 7, rect.position.y + 7),
		Vector2(rect.position.x + 7, rect.end.y - 7),
		rect.end - Vector2(7, 7),
	]:
		draw_circle(rivet, 3.5, Color("d0a251"))
		draw_circle(rivet - Vector2(0.8, 0.8), 1.2, Color("ffe1a0"))


func _draw_heart(center: Vector2, scale: float, color: Color) -> void:
	draw_circle(center + Vector2(-7, -4) * scale, 8.0 * scale, color)
	draw_circle(center + Vector2(7, -4) * scale, 8.0 * scale, color)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-15, -1) * scale,
		center + Vector2(15, -1) * scale,
		center + Vector2(0, 19) * scale,
	]), color)
	draw_line(center + Vector2(-5, -8) * scale, center + Vector2(2, -8) * scale, Color("ffc1a5"), 2.0 * scale, true)


func _draw_shield(center: Vector2, scale: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(-14, -17) * scale,
		center + Vector2(14, -17) * scale,
		center + Vector2(13, 4) * scale,
		center + Vector2(0, 20) * scale,
		center + Vector2(-13, 4) * scale,
	])
	draw_colored_polygon(points, Color(color, 0.72))
	# draw_polyline does not close a PackedVector2Array automatically. Reusing the
	# explicit closing helper restores the final lower-left-to-upper-left border
	# everywhere this shared icon is used (HUD, GUARD rune, rewards and boss ward).
	_draw_closed_polyline(points, Color("f4e1aa"), 2.0 * scale)
	draw_line(center + Vector2(0, -13) * scale, center + Vector2(0, 12) * scale, Color("f4e1aa"), 2.0 * scale, true)


func _draw_charge_glyph(center: Vector2, color: Color) -> void:
	var bolt := PackedVector2Array([
		center + Vector2(4, -22),
		center + Vector2(-12, 1),
		center + Vector2(-2, 1),
		center + Vector2(-7, 22),
		center + Vector2(14, -5),
		center + Vector2(3, -5),
	])
	draw_colored_polygon(bolt, color)
	draw_polyline(bolt, Color("fff1c8"), 2.0, true)


func _draw_crown(center: Vector2, scale: float) -> void:
	var crown := PackedVector2Array([
		center + Vector2(-18, 8) * scale,
		center + Vector2(-17, -10) * scale,
		center + Vector2(-7, 0) * scale,
		center + Vector2(0, -14) * scale,
		center + Vector2(8, 0) * scale,
		center + Vector2(18, -10) * scale,
		center + Vector2(17, 8) * scale,
	])
	draw_colored_polygon(crown, GOLD)
	draw_polyline(crown, Color("fff0a8"), 2.0, true)


func _draw_rune_mark(center: Vector2, rotation: float, scale: float, color: Color) -> void:
	var up := Vector2(0, -12).rotated(rotation) * scale
	var left := Vector2(-10, 2).rotated(rotation) * scale
	var right := Vector2(10, 2).rotated(rotation) * scale
	var stem := Vector2(0, 14).rotated(rotation) * scale
	draw_line(center + left, center + up, color, 3.0 * scale, true)
	draw_line(center + up, center + right, color, 3.0 * scale, true)
	draw_line(center + up * 0.25, center + stem, color, 3.0 * scale, true)


func _draw_might_glyph(center: Vector2, color: Color) -> void:
	# A compact war-hammer silhouette reads clearly at bumper scale.
	draw_line(center + Vector2(-7, 15), center + Vector2(5, -5), Color("fff1c8"), 5.0, true)
	var hammer_head := PackedVector2Array([
		center + Vector2(-6, -15),
		center + Vector2(13, -4),
		center + Vector2(8, 5),
		center + Vector2(-11, -6),
	])
	draw_colored_polygon(hammer_head, Color(color, 0.88))
	draw_polyline(hammer_head, Color("fff1c8"), 2.0, true)


func _draw_war_cry_glyph(center: Vector2, color: Color) -> void:
	# A voice point with expanding arcs: a warrior shout, not an elemental spell.
	draw_circle(center + Vector2(-11, 0), 5.0, color)
	for radius in [9.0, 15.0, 21.0]:
		draw_arc(center + Vector2(-10, 0), radius, -0.72, 0.72, 14, color, 2.5, true)


func _draw_table_banner(center: Vector2, color: Color) -> void:
	draw_line(center + Vector2(-23, -10), center + Vector2(-23, 48), BRONZE, 3.0)
	var cloth := PackedVector2Array([
		center + Vector2(-20, -5),
		center + Vector2(20, -5),
		center + Vector2(20, 38),
		center,
		center + Vector2(-20, 38),
	])
	draw_colored_polygon(cloth, color)
	draw_polyline(cloth, Color(BRONZE, 0.72), 2.0, true)
	_draw_rune_mark(center + Vector2(0, 14), 0.0, 0.55, Color(GOLD, 0.82))


func _speed_color(speed: float) -> Color:
	if speed >= 930.0:
		return GOLD
	if speed >= 760.0:
		return CYAN
	return Color.WHITE


func _speed_tier_name(speed: float) -> String:
	if speed >= 930.0:
		return "CHARGED  x1.60 DMG"
	if speed >= 760.0:
		return "FAST  x1.30 DMG"
	return "NORMAL  x1.00 DMG"


func _text(pos: Vector2, text: String, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _text_center(pos: Vector2, width: float, text: String, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, width, size, color)
