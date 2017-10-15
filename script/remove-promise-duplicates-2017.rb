require 'open-uri'
require 'json'

rows = JSON.parse(open("https://files.holderdeord.no/gdrive/1bTTs7Z2KVNv2FpQIbQDJ3H2QPoCjR0tVYF9FOdylGtY.json").read)['data']['Sheet1']

ids = rows.map { |e| Integer(e['ID1']) }
Promise.where(id: ids).destroy_all
