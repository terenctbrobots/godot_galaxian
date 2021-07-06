var dive_timer_start:float = 6.0
var dive_timer_mid:float = 4.0
var dive_timer_end:float = 3.0
var attack_phase_mid:float = 0.8
var attack_phase_end:float = 0.6

func _init(json):
	if json.has("dive_timer_start"):
		dive_timer_start = json["dive_timer_start"]
		
	if json.has("dive_timer_mid"):	
		dive_timer_mid = json["dive_timer_mid"]
		
	if json.has("dive_timer_end"):
		dive_timer_end = json["dive_timer_end"]

	if json.has("attack_phase_mid"):
		attack_phase_mid = json["attack_phase_mid"]
		
	if json.has("attack_phase_end"):
		attack_phase_end = json["attack_phase_end"]		
