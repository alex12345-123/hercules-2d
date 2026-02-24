extends Control



@onready var contador: Control = $CanvasLayer/Contador

# Contador de monedas
var monedas: int = 0


# Agregamos al player al grupo de jugadores
func _ready() -> void:
	add_to_group("jugadores")
	contador.actualizar(0)
	

# Agrega una moneda al contador del jugador
func add_moneda():
	monedas+=1
	contador.actualizar(monedas)
