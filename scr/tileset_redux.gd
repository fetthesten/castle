tool
extends Node

var tiles = {}

export(int) var tile_width
export(int) var tile_height
export(int) var tile_spacing
export(Texture) var texture
var xstep
var ystep

const TILE_NO_COLLIDER = 0
const TILE_FULL_COLLIDER = 1
const TILE_PARTIAL_COLLIDER = 2

var tile_colors = [Color(1, 1, 1, 0.2), Color(1, 0.3, 0.1, 0.2), Color(0.1, 0.3, 1, 0.2), Color(1, 0.8, 0.3, 0.5)]

var preview_left_button = false
var preview_right_button = false
var preview_select_start_tile = null
var preview_selected_tiles = []
var preview_updated = false

var root_node
var preview_node

func _enter_tree():
	preview_node = Node.new()
	preview_node.name = 'Preview'
	add_child(preview_node)
	preview_node.set_owner(self)
	root_node = Node.new()
	root_node.name = 'Tilesheet'
	add_child(root_node)
	root_node.set_owner(self)

func update_tile_preview():
	tiles.clear()
	
	tile_width = int($"Control Grid/EWidth".value)
	tile_height = int($"Control Grid/EHeight".value)
	tile_spacing = int($"Control Grid/ESpacing".value)
	ystep =  tile_height + tile_spacing
	xstep =  tile_width + tile_spacing
	for y in range(0, $TileSheetTex.rect_size.y, ystep):
		for x in range(0, $TileSheetTex.rect_size.x, xstep):
			var tile = {}
			tile['rect'] = Rect2(x, y, tile_width, tile_height)
			tile['collider'] = TILE_NO_COLLIDER
			tile['name'] = 't' + str(x) + '-' + str(y)
			tiles[Vector2(x/xstep,y/ystep)] = tile
	update_tile_draw()

func update_tile_draw():
	$TileSheetTex/TilePreview.rect_size = $TileSheetTex.texture.get_size()
	$TileSheetTex/TilePreview.tile_drawz.clear()
	for id in tiles.keys():
		var tile = tiles[id]
		var tdraw = {}
		tdraw['points'] = PoolVector2Array([tile['rect'].position, Vector2(tile['rect'].position.x + tile_width, tile['rect'].position.y), Vector2(tile['rect'].position.x + tile_width, tile['rect'].position.y + tile_height), Vector2(tile['rect'].position.x, tile['rect'].position.y + tile_height)])
		if id in preview_selected_tiles:
			tdraw['colors'] = PoolColorArray([tile_colors[3]])
		else:
			tdraw['colors'] = PoolColorArray([tile_colors[tile['collider']]])
		$TileSheetTex/TilePreview.tile_drawz.append(tdraw)

func tile_preview_input(obj):
	var current_tile = Vector2(int(obj.position.x / xstep), int(obj.position.y / ystep))
	if obj is InputEventMouseButton:
		if obj.button_index == BUTTON_LEFT:
			preview_left_button = obj.pressed
			if preview_left_button:
				preview_select_start_tile = current_tile
			else:
				tile_select(current_tile)
				preview_select_start_tile = null
				preview_updated = true
		elif obj.button_index == BUTTON_RIGHT:
			preview_right_button = obj.pressed
			if preview_right_button:
				preview_select_start_tile = null
				preview_selected_tiles.clear()
				preview_updated = true
	elif obj is InputEventMouseMotion:
		$TileSheetTex/TilePopup.visible = true
		$TileSheetTex/TilePopup/Tx.text = tiles[current_tile]['name']
		$TileSheetTex/TilePopup.rect_position = obj.position + Vector2(16,0)
		$TileSheetTex/TilePopup.rect_size = $TileSheetTex/TilePopup/Tx.rect_size
		$TileSheetTex/PopupTimer.stop()
		$TileSheetTex/PopupTimer.start()
		if preview_left_button:
			tile_select(current_tile)
			preview_updated = true
		if preview_updated:
			update_tile_draw()
			preview_updated = false
		

func tile_select(current_tile):
	for y in range(preview_select_start_tile.y, current_tile.y):
		for x in range(preview_select_start_tile.x, current_tile.x):
			var t = Vector2(x,y)
			if not t in preview_selected_tiles:
				preview_selected_tiles.append(t)

func create_tilesheet():
	for tile in tiles.values():
		var tile_node = Sprite.new()
		root_node.add_child(tile_node)
		tile_node.set_owner(root_node)
		tile_node.texture = $TileSheetTex.texture
		tile_node.region_enabled = true
		tile_node.region_rect = tile['rect']
		tile_node.global_position = tile['rect'].position
		tile_node.name = tile['name']
		if tile['collider'] == TILE_FULL_COLLIDER:
			var collider = tile_node.add_child(StaticBody2D.new())
			var collision_shape = collider.add_child(CollisionShape2D)
			collision_shape.shape = RectangleShape2D.new()
			collision_shape.shape.extents = Vector2(tile_width / 2, tile_height / 2)
	
func save_tilesheet():
	var save_file = PackedScene.new()
	save_file.pack(root_node)
	ResourceSaver.save('res://tilesheet.tscn', save_file)
	
	
func edit_selected_tiles():
	var name = $"Tile Preview Grid/EName".text
	var namecount = 0
	var collider = $"Tile Preview Grid/ECollider".pressed
	for tile in preview_selected_tiles:
		tiles[tile]['name'] = name + str(namecount)
		namecount += 1
		tiles[tile]['collider'] = 1 if collider else 0
