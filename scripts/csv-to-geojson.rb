require 'csv'
require 'json'

organisationTypes = [
	# 'CCG',
	# 'Clinics',
	'Dentists'
	# 'GP',
	# 'GPPractices',
	# 'GSD',
	# 'HealthAuthority',
	# 'Hospital',
	# 'LAT',
	# 'MIU',
	# 'Optician',
	# 'Pharmacy',
	# 'SCL',
	# 'SCP',
	# 'Trust',
	# 'WIC'
]

organisationTypes.each do |organisationType|
	openingTimes = {}
	staff = {}
	if organisationType == 'Dentists'
		csv = File.expand_path("../../sources/DentistOpeningTimes.csv", __FILE__)
		CSV.foreach(csv, encoding:'iso-8859-1:utf-8', col_sep: "\u00AC", headers: :first_row) do |row|
			orgID = row['OrganisationId']
			details = {
				:WeekDay => row['WeekDay'],
				:Times => row['Times'],
				:IsOpen => row['IsOpen'] == 'True',
				:OpeningTimeType => row['OpeningTimeType']
			}
			details['AdditionalOpeningDate'] = row['AdditonalOpeningDate'] unless row['AdditonalOpeningDate'].nil?
			openingTimes[orgID] = [] unless openingTimes[orgID]
			openingTimes[orgID].push(details)
		end
		csv = File.expand_path("../../sources/DentistStaff.csv", __FILE__)
		CSV.foreach(csv, encoding:'iso-8859-1:utf-8', col_sep: "\u00AC", headers: :first_row) do |row|
			orgID = row['OrganisationID']
			details = {
				:Title => row['Title'],
				:GivenName => row['GivenName'],
				:FamilyName => row['FamilyName'],
				:Role => row['Role']
			}
			staff[orgID] = [] unless staff[orgID]
			staff[orgID].push(details)
		end
	end

	features = []
	csv = File.expand_path("../../sources/#{organisationType}.csv", __FILE__)
	geojson = File.expand_path("../../#{organisationType}.geojson", __FILE__)
	CSV.foreach(csv, encoding:'iso-8859-1:utf-8', col_sep: "\u00AC", headers: :first_row) do |row|
		unless row['Longitude'].nil?
			properties = {}
			row.each do |header,value|
				unless value.nil? || header == 'Longitude' || header == 'Latitude' || header == 'OrganisationID'
					properties[header] = value
				end
			end
			properties['openingTimes'] = openingTimes[row['OrganisationID']]
			properties['staff'] = staff[row['OrganisationID']]
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
	end
	collection = {
		:type => 'FeatureCollection',
		:features => features
	}
	File.open(geojson, 'w+') do |geojson|
		geojson.puts collection.to_json
	end
end

