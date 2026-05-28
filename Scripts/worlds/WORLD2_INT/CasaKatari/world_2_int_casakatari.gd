extends Node3D

var final: String =""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(d_ended)
	
	WorldFunc.cutscene=true
	$Pp.set_busy()
	$Pp.velocidad_mov=0.3
	$Pp.set_external_direction(Vector3.FORWARD)
	var awela = $Level/npcs/Remedios
	var sprite_remedios=load("res://Sprites/Chars/remedios/remedios_sprt.png")
	awela.walk=sprite_remedios
	awela.set_busy()
	awela.set_external_direction(Vector3.BACK)
	awela.velocidad_mov=0.3
	await get_tree().create_timer(1).timeout
	$Pp.set_external_direction(Vector3.ZERO)
	awela.set_external_direction(Vector3.ZERO)
	if PartyData.inventario["aji en salsa"]["cantidad"]==1:
		if PartyData.inventario["cilantro"]["cantidad"]==1:
			$Pp.set_current_npc(awela)
			final ="logrado"
			DialogueManager.show_dialogue_balloon(load("res://Dialogues/worlds/World2/INT/casakatari.dialogue"),"logrado",[self])
	else:
		$Pp.set_current_npc(awela)
		final ="no_logrado"
		DialogueManager.show_dialogue_balloon(load("res://Dialogues/worlds/World2/INT/casakatari.dialogue"),"no_logrado",[self])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func d_ended(dialog):
	if final=="logrado":
		FadeLayer.fade_out(2.0)
	elif final=="no_logrado":
		FadeLayer.fade_out(2.0)
##_----------anuimaciones

func salto(nodo:String):
	if nodo=="":
		$Pp.velocity.y=2
	else:
		var nodet = $Level/npcs.get_node(nodo)
		nodet.velocity.y +=2

func mover_frente(nodo:String):
	if nodo=="":
		$Pp.velocity.z+=2
	else:
		var nodet = $Level/npcs.get_node(nodo)
		
func mirar(nodo:String,dir:String):
	if nodo=="":
		$Pp.velocity.y+=2
	else:
		var nodet = $Level/npcs.get_node(nodo)
		match dir:
			"derecha": nodet.external_look=Vector3.RIGHT
			"izquierda": nodet.external_look=Vector3.LEFT
			"arriba": nodet.external_look=Vector3.FORWARD
			"abajo": nodet.external_look=Vector3.BACK

func cambio_npc(nodo:String):
	if nodo=="":
		$Pp.current_npc=null
	else:
		var nodet = $Level/npcs.get_node(nodo)
		$Pp.current_npc=nodet
		$Pp.d_started(null)
