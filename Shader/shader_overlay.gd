extends CanvasLayer

var color_schemes: Dictionary = {
	"default": Palette.new(0x000000ff,0xffffffff),

	# Mono Colour Palette
#	"red":     Palette.new(0x3c1010ff,0xe33838ff),
#	"green":   Palette.new(0x1b3c1bff,0x71d171ff),
#	"cyan":    Palette.new(0x114c4fff,0x71babeff),
#	"blue":    Palette.new(0x090d2eff,0x3d458bff),
#	"purple":  Palette.new(0x270646ff,0x924dd1ff),
#	"pink":    Palette.new(0x410d3eff,0xd187bdff),

	#Friend Colours
	"barny":      Palette.new(0x4c086eff,0x2cbf53ff),
	"santa":      Palette.new(0x4f0109ff,0x4b7a49ff),
	"midas":      Palette.new(0x000000ff,0xe5b80Bff),
	"sky":        Palette.new(0x000000ff,0x73d2d9ff),
	"strawberry": Palette.new(0xad2a77ff,0xfaf689ff),
	"chappell":   Palette.new(0x804066ff,0xffffffff)
}

class Palette:
	var primary:   Color
	var secondary: Color

	func _init(prim:int,seco:int):
		self.primary =   Color.hex(prim)
		self.secondary = Color.hex(seco)

func update_colours(palette:Palette):
	$Overlay.material.set_shader_parameter("primary", palette.primary)
	$Overlay.material.set_shader_parameter("secondary",palette.secondary)
