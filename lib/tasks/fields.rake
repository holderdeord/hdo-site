namespace :fields do 
  desc 'Seed fields with initial list.'
  task :reset_and_initial_seed => :environment do
    initial_fields_list = [
      "Offentlig forvaltning",
      "Familie og tro",
      "Kultur",
      "Helse og sosial",
      "Sj\u00f8 og landbruk",
      "Energi og milj\u00f8",
      "Utenriks og sikkerhet",
      "Utdanning og forskning",
      "Finanser og n\u00e6ringsliv",
      "Arbeidsliv",
      "Transport og komm.",
      "Diverse"
    ]
    puts 'Deleting all fields!'
    Field.find_each(&:delete)

    initial_fields_list.each do |field_name|
      puts "Creating field #{field_name}"
      Field.create name: field_name
    end
  end
  
end