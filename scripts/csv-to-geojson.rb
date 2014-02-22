require 'csv'
require 'json'

organisationTypes = [
	'CCG',
	'Clinics',
	'Dentists',
	'GP',
	'GPPractices',
	'GSD',
	'HealthAuthority',
	'Hospital',
	'LAT',
	'MIU',
	'Optician',
	'Pharmacy',
	'SCL',
	'SCP',
	'Trust',
	'WIC'
]

organisationTypes.each do |organisationType|
	features = []
	csv = File.expand_path("../../sources/#{organisationType}.csv", __FILE__)
	geojson = File.expand_path("../../#{organisationType}.geojson", __FILE__)
	CSV.foreach(csv, encoding:'iso-8859-1:utf-8', col_sep: "\u00AC", headers: :first_row) do |row|
		properties = {}
		row.each do |header,value|
			unless value.nil? || header == 'Longitude' || header == 'Latitude' || header == 'OrganisationID'
				properties[header] = value
			end
		end
		feature = {
			:type => 'Feature',
			:id => row['OrganisationID'],
			:geometry => {
				:type => 'Point',
				:coordinates => [row['Longitude'].to_f, row['Latitude'].to_f]
			},
			:properties => properties
		}
		features.push(feature)
	end
	collection = {
		:type => 'FeatureCollection',
		:features => features
	}
	File.open(geojson, 'w+') do |geojson|
		geojson.puts collection.to_json
	end
end

