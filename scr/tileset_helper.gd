tool
extends Node

export(bool) var reset = false setget on_reset

# config
export(int) var tile_width = 16
export(int) var tile_height = 16
export(int) var tile_spacing = 1
export var tilesheet = preload('res://gfx/roguelikeSheet_transparent.png')

func on_reset(is_triggered):
	if is_triggered:
		reset = false
		
	var tex_size = tilesheet.get_size()
	
	var xstep = tile_width + tile_spacing
	var ystep = tile_height + tile_spacing
	
	for y in range(0, tex_size.y, ystep):
		for x in range(0, tex_size.x, xstep):
			var tile = Sprite.new()
			add_child(tile)
			var tile_rect = Rect2(x, y, tile_width, tile_height)
			tile.set_owner(self)
			tile.name = 't' + str(x/xstep) + '-' + str(y/ystep)
			tile.texture = tilesheet
			tile.region_enabled = true
			tile.region_rect = tile_rect
			tile.global_position = tile_rect.position