# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# OSM Importer Script
# Handles the HTTP requests, and the data conversion for getting OSM data and converting it into a format the simulation understands
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Would prob be a good idea to multithread this whole thing at some point, at the very least, make it run on a thread in the background so the graphics can still work
# On second through, this might actually be relativley difficult to mulithread. Or atleas, it'll need a complete rewrite

extends Node

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
var RequestorOutput: Dictionary

# ---------------------------------------------------------------------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------------------------------------------------------------------
@onready var HTTPRequestNode = $HTTPRequest
@onready var DataImporterExporter = $".."

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
# Connecting the signals
func _ready() -> void:
	DataImporterExporter.IMPORT_OSM_FILE.connect(import_osm_file)
	
## Constructs the API query, calls the HTTP request, converts the data and then sends a DATA_IMPORTER_FINISHED signal
func import_osm_file(BboxCoordinatesForImport: String, BboxCoordinatesForScale: Vector4, ScreenCoordinates: Vector4):	
	# Setting up the HTTP requestor
	var OverpassAPIHTTPRequestor: HTTPRequestor = HTTPRequestor.new(HTTPRequestNode, 10, 1.5)
	OverpassAPIHTTPRequestor.NameOfRequest = "Map Import HTTP Request"
	OverpassAPIHTTPRequestor.Header = "https://overpass-api.de/api/interpreter"
	OverpassAPIHTTPRequestor.ContentType = "application/x-www-form-urlencoded"
	OverpassAPIHTTPRequestor.BusyCodes = [429, 504, 502, 503]
	
	# Setting up the http requestor signal connections
	OverpassAPIHTTPRequestor.status_changed.connect(print_out_http_status)
	OverpassAPIHTTPRequestor.http_request_finished.connect(request_complete)
	
	# Setting up the map import query
	OverpassAPIHTTPRequestor.Query = """
		[out:json][timeout:200];
		(
		  way["place"~"^(island)$"]({0});
		  relation["place"~"^(island)$"]({0});
		  way["landuse"~"^(residential|industrial|commercial|retail|construction)$"]({0}); 
		  node["name"]["place"~"^(country|island|city|town|village|hamlet|suburb|neighborhood)$"]({0});
		); 
		out geom;
	""".format([BboxCoordinatesForImport])
	
	# Making the call and waiting for the result
	OverpassAPIHTTPRequestor.send_http_request_post()
	await OverpassAPIHTTPRequestor.http_request_finished
	
	# Setting up the map constructor
	var topLeftReferencePoint: ReferencePoint = ReferencePoint.new(ScreenCoordinates[0], ScreenCoordinates[1], BboxCoordinatesForScale[2], BboxCoordinatesForScale[1])
	var bottomRightReferencePoint: ReferencePoint = ReferencePoint.new(ScreenCoordinates[2], ScreenCoordinates[3], BboxCoordinatesForScale[0], BboxCoordinatesForScale[3])
	var WorldMapConstructor: MapConstructor = MapConstructor.new(topLeftReferencePoint, bottomRightReferencePoint, %WorldMap)
	
	# Converting the data to the sim format
	WorldMapConstructor.construct_map(RequestorOutput)
	
	# Sending the DATA_IMPORTER_FINISHED signal
	#DataImporterExporter.DATA_IMPORTER_FINISHED.emit(SimulationNetworkStructure)
	
# -----------------------------------------------------------------------------------------------------------------------------------------------------
# A few functions for keeping track of the progress and checking if the HTTP request worked
# -----------------------------------------------------------------------------------------------------------------------------------------------------
## Prints out the current status of the HTTP request, temporary, will be replaced with a UI element
func print_out_http_status(newStatus: String):
	print(newStatus)
	
## Called when the HTTP request is fully complete
func request_complete(success: bool, result: Dictionary):
	if success == true:
		RequestorOutput = result
	if success == false:
		print("FAILED HTTP REQUEST SEE ERROR LOG")
