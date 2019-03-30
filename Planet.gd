extends Spatial

export var planet_radius = 50.0
export var atmosphere_radius = 51.25
export var wavelength = Vector3(0.65, 0.57, 0.475)
export var ground_color = Color(0.5, 0.3, 0.2)
export var kr = 0.0025
export var km = 0.001
export var sun_strength = 20
var scale_depth = 0.25 #should be constant for now
export var n_samples = 2
export var g = -0.99
export(bool) var make_random = true
var gen_seed = 0

func _ready():
	if make_random:
		randomize()
		planet_radius = 10.0+randf()*90.0
		atmosphere_radius = planet_radius*1.025
		wavelength = Vector3(randf()*0.7+0.3, randf()*0.7+0.3, randf()*0.7+0.3)
		gen_seed = randf()
		var gc = Vector3(randf(), randf(), randf()).normalized()
		ground_color = Color(gc.x, gc.y, gc.z)
		$Ground/ColorRect.material.set_shader_param("seed", gen_seed)
	$Ground/ColorRect.material.set_shader_param("wavelength", wavelength)
	$Ground/ColorRect.material.set_shader_param("ground", ground_color)

	$Surface.mesh.radial_segments = 256
	$Surface.mesh.rings = 256
	$Atmosphere.mesh.radial_segments = 256
	$Atmosphere.mesh.rings = 256
	$Surface.mesh.radius = planet_radius
	$Surface.mesh.height = planet_radius*2.0
	$Atmosphere.mesh.radius = atmosphere_radius
	$Atmosphere.mesh.height = atmosphere_radius*2.0
	$Surface.material_override.set_shader_param("texture_albedo", $Ground.get_texture())
	$Ground.get_texture().flags = 7


	set_init_params($Surface.material_override)
	set_init_params($Atmosphere.material_override)

func set_atmosphere_properties(cam, light):
	set_params($Surface.material_override, cam, light)
	set_params($Atmosphere.material_override, cam, light)
	
func set_params(mat, cam, light):
	mat.set_shader_param("v3CameraPos", -cam)
	mat.set_shader_param("fCameraHeight2", cam.length_squared())
	mat.set_shader_param("v3LightPos", -light.normalized())

func set_init_params(mat):
	mat.set_shader_param("fOuterRadius", atmosphere_radius)
	mat.set_shader_param("fOuterRadius2", atmosphere_radius*atmosphere_radius)
	mat.set_shader_param("fInnerRadius", planet_radius)
	mat.set_shader_param("fInnerRadius2", planet_radius*planet_radius)
	mat.set_shader_param("fScale", 1.0/(atmosphere_radius-planet_radius))
	mat.set_shader_param("fScaleOverScaleDepth", (1.0/(atmosphere_radius-planet_radius))/scale_depth)
	mat.set_shader_param("fScaleDepth", scale_depth)
	mat.set_shader_param("v3InvWavelength", Vector3(1.0/pow(wavelength.x, 4.0),1.0/pow(wavelength.y, 4.0),1.0/pow(wavelength.z, 4.0)))
	mat.set_shader_param("fKrESun", kr*sun_strength)
	mat.set_shader_param("fKmESun", km*sun_strength)
	mat.set_shader_param("fKr4PI", kr*4.0*PI)
	mat.set_shader_param("fKm4PI", km*4.0*PI)
	mat.set_shader_param("nSamples", n_samples)
	mat.set_shader_param("fSamples", float(n_samples))
	mat.set_shader_param("g", g)
	mat.set_shader_param("g2", g*g)

func _process(delta):
	var cam = translation - $Camera.translation
	var light = translation - $Star.translation
	set_atmosphere_properties(cam, light)
