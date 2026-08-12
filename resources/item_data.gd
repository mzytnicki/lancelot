extends Resource
class_name ItemData
## Data definition for an inventory item.

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }
enum EquipSlot { NONE, WEAPON, ARMOR, ACCESSORY }

@export var id: String = ""  ## Unique identifier; match the .tres filename (e.g., "potion")
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D  ## Leave empty for now; we'll add item icons later
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var equip_slot: EquipSlot = EquipSlot.NONE

@export_group("Consumable Effects")
@export var hp_restore: int = 0
@export var mp_restore: int = 0

@export_group("Equipment Stats")
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var speed_bonus: int = 0

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
