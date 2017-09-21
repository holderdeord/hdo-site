data_source = Hdo::StortingImporter::ParsingDataSource.new(Hdo::StortingImporter::ApiDataSource.default)
new_categories = data_source.categories.sort_by { |e| e.name }

File.open("new_categories.json", "w") { |file| file << new_categories.to_json }

def summarize_change(cat, parent = nil)
  main = !parent
  old = Category.find_by_external_id(cat.external_id)

  if old
    main_mismatch = old.main? != main
    name_mismatch = old.name != cat.name

    changes = []

    if old.main? && !main
      changes << "Ikke lenger hovedkategori, nå underkategori av #{parent.name}"
    end

    if main && !old.main?
      changes << "Oppgradert til hovedkategori, ikke lenger underkategori av #{old.parent.name}"
    end

    if name_mismatch
      changes << "Navn endret fra #{old.name} til #{cat.name}"
    end

    if changes.any?
      puts cat.name
      puts "\t#{changes.join("\n\t")}"
    end
  else
    puts cat.name
    puts "\tHelt ny #{main ? 'hovedkategori' : "underkategori av #{parent.name}"}"
  end
end

new_categories.each do |main|
  summarize_change main

  main.children.each do |subcat|
    summarize_change subcat, main
  end

end
