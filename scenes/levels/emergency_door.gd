extends AnimatedSprite2D

var is_open: bool = false # 状态锁：记录门现在是不是开着的
var fire_active: bool = false

func _ready():
	self.visible = true
	self.frame = 0
	# 确保动画不循环播放
	self.centered = true 
	
	if Engine.has_singleton("FireManager"):
		FireManager.fire_started.connect(_on_fire_started)
		FireManager.fire_ended.connect(_on_fire_ended)

	var zone = get_parent()
	if zone is Area2D:
		zone.body_entered.connect(_on_zone_body_entered)
		zone.body_exited.connect(_on_zone_body_exited)

func _on_fire_started():
	self.visible = true
	fire_active = true
	is_open = false
	self.frame = 0 # 回到关门的第一帧

func _on_fire_ended():
	fire_active = false
	if is_open:
		_close_door()

func _on_zone_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("npc"):
		# --- 关键逻辑：只有在火灾中、且门没开的时候才播放开门 ---
		if fire_active and not is_open:
			is_open = true
			self.play("open") 
			print("DOOR: Opening for the first person.")

func _on_zone_body_exited(body):
	# 演习期间我们不让门自动关上，防止小人被夹住
	# 只有在火灾彻底结束时，才由 _on_fire_ended 触发关门
	pass

func _close_door():
	self.play_backwards("open")
	await self.animation_finished
	# 只有火没再烧了才隐藏
	if not fire_active:
		self.visible = false
		is_open = false
