# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Sim Importer Exporter Script
# Handles the saving and loading of the simulation
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------

extends Node
# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
var ImporterExporterConverter: ClassResourceConverter = ClassResourceConverter.new()

# ---------------------------------------------------------------------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------------------------------------------------------------------
@onready var DataImporterExporter = $".."

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
# Connecting the signals
func _ready() -> void:
	pass
	#DataImporterExporter.SAVE_FILE.connect(save_file)
	#DataImporterExporter.LOAD_FILE.connect(load_file)

## Saves the data it recives in the specified file location
#func save_file(NetworkToSave: NetworkStructure, SaveLocation: String):
	#var simulationSaveFileData: SimulationDataFile = SimulationDataFile.new()
	#simulationSaveFileData.SavedNetwork = ImporterExporterConverter.convert_to_resources(NetworkToSave)
#
	#ResourceSaver.save(simulationSaveFileData, SaveLocation)
	
## Loads the specified data from the specified file location
func load_file(SaveLocation: String):
	if FileAccess.file_exists(SaveLocation):
		var simulationSaveFileData: SimulationDataFile = ResourceLoader.load(SaveLocation).duplicate(true)
		
		#DataImporterExporter.DATA_IMPORTER_FINISHED.emit(ImporterExporterConverter.convert_to_classes(simulationSaveFileData.SavedNetwork))
	
	else:
		print("ERROR: File does not exist")
		return null
