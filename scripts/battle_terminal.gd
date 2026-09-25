class_name EnemyTerminal extends NinePatchRect

@onready var outp:RichTextLabel = $RichTextLabel
var queue:Array = []
var writing := false
signal finished_writing

func _ready() -> void:
	visible = false
	outp.text = ""
	
func write(inp: String):
	writing = true
	outp.text = ""
	for i in inp:
		outp.text+= i
		if i not in [" ", "\n"]:
			await get_tree().create_timer(.01).timeout
	await get_tree().create_timer(.4).timeout
	writing = false
	finished_writing.emit()
	
func queue_write(inp:String):
	queue.append(inp)
	
func _process(delta: float) -> void:
	if queue.size() > 0:
		if writing == false:
			visible = true
			write(queue[0])
			queue.remove_at(0)
	else:
		if writing == false:
			visible = false
