versions = {
	'src/ConfigHandler':     '1.1.3'
	'src/DataHandler':       '1.0.3'
	'src/DataWrapper':       '1.0.2'
	'src/Line':              '1.4.3'
	'src/LineCollection':    '1.1.1'
	'src/Log':               '1.0.0'
	'src/Math':              '1.0.0'
	'src/MotionHandler':     '1.1.3'
	'src/ShakeShapeHandler': '1.0.1'
	'src/Statistics':        '0.1.2'
	'src/Tags':              '1.3.1'
	'src/Transform':         '1.2.3'
	'src/TrimHandler':       '1.0.2'
	'Aegisub-Motion':        '1.0.0'
}
nameMap = {
	CONFIGHANDLER:     'src/ConfigHandler'
	DATAHANDLER:       'src/DataHandler'
	DATAWRAPPER:       'src/DataWrapper'
	LINE:              'src/Line'
	LINECOLLECTION:    'src/LineCollection'
	LOG:               'src/Log'
	MATH:              'src/Math'
	MOTIONHANDLER:     'src/MotionHandler'
	SHAKESHAPEHANDLER: 'src/ShakeShapeHandler'
	STATISTICS:        'src/Statistics'
	TAGS:              'src/Tags'
	TRANSFORM:         'src/Transform'
	TRIMHANDLER:       'src/TrimHandler'
	'AEGISUB-MOTION':  'Aegisub-Motion'
}

for name, version in pairs versions
	filename = name .. '.moon'
	file = io.open filename
	contents = file\read '*a'
	file\close!
	contents = contents\gsub '##__([A-Z-]+)_VERSION__##', ( template ) ->
		print "#{filename}: replacing #{template}_VERSION with #{versions[nameMap[template]]}"
		return versions[nameMap[template]]

	-- file = io.open filename, 'w'
	-- file\write contents
	-- file\close!

filename = 'DependencyControl.json'
file = io.open filename
contents = file\read '*a'
file\close!

contents = contents\gsub '##__([A-Z-]+)_VERSION__##', ( template ) ->
	print "#{filename}: replacing #{template}_VERSION with #{versions[nameMap[template]]}"
	return versions[nameMap[template]]

contents = contents\gsub '##__([A-Z-]+)_HASH__##', ( template ) ->
	hashFilename = nameMap[template] .. '.moon'
	hashFile = io.popen 'shasum ' .. hashFilename
	hash = hashFile\read '*a'
	hash = hash\sub( 1, 40 )\upper!
	hashFile\close!
	print "#{filename}: replacing #{template}_HASH with #{hash}"
	return hash

-- file = io.open filename, 'w'
-- file\write contents
-- file\close!
