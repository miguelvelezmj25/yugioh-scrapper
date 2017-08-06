require 'nokogiri'
require 'open-uri'

@rarities = {'common' => 'C', 'gold rare' => 'GR', 'gold secret' => 'GS', 'platinum rare' => 'PR', 'rare' => 'R',
	'secret rare' => 'SE', 'super rare' => 'SR', 'ultra rare' => 'UR'
}
@types = { 'normal monster' => 'Monster', 'effect monster' => 'Monster', 'gemini monster' => 'Monster',
           'xyz monster' => 'XYZ', 'pendulum monster' => 'Pendulum', 'fusion monster' => 'Fusion',
           'synchro monster'=> 'Synchro', 'token monster'=> 'Token', 'ritual monster' => 'Ritual',
           'trap card' => 'Trap', 'spell card' => 'Spell', 'tuner monster' => 'Monster', 'union monster' => 'Monster',
           'flip monster' => 'Monster'
}

@special_types = {'slifer the sky dragon' => 'Divine', 'obelisk the tormentor' => 'Divine',
                  'the winged dragon of ra' => 'Divine'}

def resolve_rarity(rarity)
  rarity = rarity.downcase
	if @rarities.has_key?(rarity)
		@rarities[rarity]
	else
		'TODO'
	end
end


def resolve_type(type, name)
  type = type.downcase
  name = name.downcase

  if @special_types.has_key?(name)
    @special_types[name]
  else
    words = type.strip.split(' ')
    type = words[-2] + ' ' + words[-1]
    if @types.has_key?(type)
      @types[type]
    else
      'TODO'
    end
  end
end

FILE_NAME = 'query.sql'

File.open(FILE_NAME, 'w')
url = 'http://yugioh.wikia.com/wiki/Set_Card_Lists:Structure_Deck:_Yugi_Muto_(TCG-EN)'
data = Nokogiri::HTML(open(url))
table = data.css('table.card-list')
rows = table.css('tr')

puts (rows.length - 1)
rows.each do |row|
	columns = row.css('td')

	if columns.length == 0
		next
	end

  query = 'INSERT INTO cards (pack_id, id, name, edition_id, rarity_id, type) VALUES ('
	string = ''

	value = columns[0].text.strip
	string += "'#{value.split('-')[0].strip}', "
	string += "'#{value.split('-')[1].strip}', "

  name = columns[1].text.strip

 	string += '"' + "#{name}" + '", '
  string += "'TODO', "
 	string += "'#{resolve_rarity(columns[2].text.strip.to_s)}', "
 	string += "'#{resolve_type(columns[3].text.strip, name)}'"
 	
	query += string + ');'

  File.open(FILE_NAME, 'a') do |f|
    f.write(query)
    f.write("\n")
  end
end
