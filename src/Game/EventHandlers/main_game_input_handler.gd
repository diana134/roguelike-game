extends BaseInputHandler

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

const inventory_menu_scene = preload("res://src/GUI/InventoryMenu/inventory_menu.tscn")

@export var reticle: Reticle

func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
	
	if Input.is_action_just_pressed("wait"):
		action = WaitAction.new(player)
		
	if Input.is_action_just_pressed("view_history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
		
	if Input.is_action_just_pressed("pickup"):
		action = PickupAction.new(player)
		
	if Input.is_action_just_pressed("drop"):
		var selected_item: Entity = await get_item("Select an item to drop", player.inventory_component)
		action = DropItemAction.new(player, selected_item)
		
	if Input.is_action_just_pressed("activate"):
		var selected_item: Entity = await get_item("Select an item to use", player.inventory_component)
		action = ItemAction.new(player, selected_item)
	
	if Input.is_action_just_pressed("quit"):
		action = EscapeAction.new(player)
		
	if Input.is_action_just_pressed("look"):
		await get_grid_position(player, 0)
	
	return action

func get_item(window_title: String, inventory: InventoryComponent) -> Entity:
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
	add_child(inventory_menu)
	inventory_menu.build(window_title, inventory)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_item: Entity = await inventory_menu.item_selected
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_item

func get_grid_position(player: Entity, radius: int) -> Vector2i:
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_position: Vector2i = await reticle.select_position(player, radius)
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_position
