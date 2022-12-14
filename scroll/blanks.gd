extends Control

var notevals = [0, 2, 4, 2, 0, -1, -3, -5, 0, 2, 0, 2, 4, 2, 0, 7, 9, 7, 5, 4, 2, -1, 0]

var notepos =  [0, 1, 2, 1, 0, -1, -2, -3, 0, 1, 0, 1, 2, 1, 0, 4, 5, 4, 3, 2, 1, -1, 0]

var toput = preload("res://scroll/toput.tscn")
var fly = preload("res://scroll/fly.tscn")
onready var flypos = $"../flypos"
onready var base = get_node("/root/base")
onready var pianonote = $"../pianonote"

var pianosounds = [preload("res://audio/piano/-3.wav"), preload("res://audio/piano/-2.wav"), preload("res://audio/piano/-1.wav"), preload("res://audio/piano/0.wav"), preload("res://audio/piano/1.wav"), preload("res://audio/piano/2.wav"), preload("res://audio/piano/3.wav"), preload("res://audio/piano/4.wav"), preload("res://audio/piano/5.wav")]

onready var particles = $"../Particles2D"
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0, 23):
		var curput = toput.instance()
		curput.note_num = i
		curput.note_val = notepos[i]
		curput.position.x = 220 + 33 * i
		curput.position.y = 346 - 38 * curput.note_val
		curput.name = "note" + str(i)
		add_child(curput)
	
	get_node("note0").can_put = true

func _on_toput_put_note(note_num):
	var noterange = get_range(notevals[note_num-1], notevals[note_num])
	
	if note_num < 22:
		get_node("note" + str(note_num + 1)).can_put = true
		
	if note_num == 22:
		get_node("note" + str(note_num)).put()
		
	if base.seconds < noterange.size() || note_num == 22:
		get_node("note" + str(note_num)).can_put = true
		particles.global_position = Vector2(174, 157)
		var tween = get_tree().create_tween()
		particles.visible = true
		tween.tween_property(particles, "global_position", Vector2(220 + 33 * note_num, particles.global_position.y), 0.6 * note_num)
		base.finish_scroll()
		return
	
		
	if note_num != 0:
		base.seconds -= noterange.size()
		# ok get the range of nums between the values.... hm
		var flies = []
		
		for num in noterange:
			var cur = fly.instance()
			add_child(cur)
			cur.global_position = flypos.global_position
			flies.append(cur)
			
			var tween = get_tree().create_tween()
			tween.tween_property(cur, "global_position", get_node("../pos/" + str(num)).global_position, 0.2)
			
			yield(tween, "finished")
			
		for cur in flies:
			var tween = get_tree().create_tween()
			tween.tween_property(cur, "global_position", get_node("../pos/" + str(notevals[note_num])).global_position, 0.1)
			yield(tween, "finished")
		
		for cur in flies:
			if cur != flies[-1]:
				cur.queue_free()
		pianonote.stream = pianosounds[notepos[note_num] + 3]
		pianonote.play()
		var tween = get_tree().create_tween()
		tween.tween_property(flies[-1], "global_position", Vector2(220 + 33 * note_num, flies[-1].global_position.y), 0.2)
		yield(tween, "finished")
		flies[-1].queue_free()
		
	if note_num == 0:
		pianonote.stream = pianosounds[notepos[note_num] + 3]
		pianonote.play()
		
	get_node("note" + str(note_num)).put()
	


func get_range(x, y): # 3 -4 -> [2 1 0 -1 -2 -3 -4]
	var ans = []
	while x-1 >= y:
		x = x - 1
		ans.append(x)
	while x+1 <= y:
		x = x + 1
		ans.append(x)
	return ans
		
