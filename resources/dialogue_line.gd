extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information and optional choices.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []  # Empty = no choice, just advance


static func make_lines(speaker: String, texts: Array) -> Array[DialogueLine]:
	var lines: Array[DialogueLine] = []
	for t in texts:
		var line := DialogueLine.new()
		line.speaker_name = speaker
		line.text = t
		lines.append(line)
	return lines
