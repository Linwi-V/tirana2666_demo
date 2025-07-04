extends Node

enum State {
	OVERWORLD,
	BATTLE,
	DANCE
}

var current_state: State = State.OVERWORLD
var state_nodes: Dictionary

func _ready():
	
	##no sombra aqui
	$OW/Pp/Sprite3D.alpha_cut=2
	
	state_nodes = {
		State.OVERWORLD: $OW,
		State.BATTLE: $BTL,
		State.DANCE: $DNC,
	}
	_change_state(current_state)

func _change_state(new_state: State):
	for state in state_nodes.keys():
		state_nodes[state].visible = false
	state_nodes[new_state].visible = true
	current_state = new_state

func enter_battle():
	_change_state(State.BATTLE)

func enter_dance():
	_change_state(State.DANCE)

func return_to_overworld():
	_change_state(State.OVERWORLD)
