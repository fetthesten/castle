tool
extends Control

var tile_drawz = []

func _process(delta):
	update()
	
func _draw():
	for tile in tile_drawz:
		draw_polygon(tile['points'], tile['colors'])

