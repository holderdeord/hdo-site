old_categories = Category.all

data_source = Hdo::StortingImporter::ParsingDataSource.new(Hdo::StortingImporter::ApiDataSource.default)
new_categories = data_source.categories.sort_by { |e| e.name }
new_categories_by_external_id = new_categories.map { |c| [c, c.children] }.flatten.group_by { |e| e.external_id }

# File.open("new_categories.json", "w") { |file| file << new_categories.to_json }

def summarize_change(cat, parent = nil)
  main = !parent
  old = Category.find_by_external_id(cat.external_id)
  changes = []

  if old
    old_main      = old.main?
    main_mismatch = old_main != main
    name_mismatch = old.name != cat.name


    if old_main && !main
      changes << {type: 'no-longer-main', text: "Ikke lenger hovedkategori, nå underkategori av #{parent.name}"}
    end

    if main && !old_main
      changes << {type: 'upgrade-to-main', text: "Oppgradert til hovedkategori, ikke lenger underkategori av #{old.parent.name}"}
    end

    if !main && !old_main && parent.external_id != old.parent.external_id
      changes << {type: 'new-parent', text: "Flyttet fra #{old.parent.name} til #{parent.name}"}
    end

    if name_mismatch
      changes << { type: 'name-changed', text: "Navn endret fra #{old.name} til #{cat.name}", old: old.name, new: cat.name}
    end
  else
    changes << { type: 'new-category', text: "Helt ny #{main ? 'hovedkategori' : "underkategori av #{parent.name}"}", name: cat.name }
  end

  return { category: cat, parent: parent, main: main, changes: changes }
end

result = []

new_categories.each do |main|
  result << summarize_change(main)

  main.children.each do |subcat|
    result << summarize_change(subcat, main)
  end
end

old_categories.each do |cat|
  unless new_categories_by_external_id[cat.external_id]
    result << {category: cat, changes: [{type: 'deleted', text: 'Slettet'}]}
  end
end

c = []

result.each do |item|
  next if item[:changes].empty?

  puts item[:category].name

  item[:changes].each do |change|
    puts "\t#{change[:text]}"
  end

  if item[:changes].empty?
    puts "\tIngen endringer."
  end
end

to_create = result.select { |e| e[:changes].find { |c| c[:type] == 'new-category' }}
to_delete = result.select { |e| e[:changes].find { |c| c[:type] == 'deleted' }}

to_delete.each do |item|
  Category.find_by_external_id(item[:category].external_id).delete
end

to_create.each do |item|
  cat = item[:category]

  create             = Category.new
  create.external_id = cat.external_id
  create.name        = cat.name
  create.main        = item[:main]
  create.parent      = item[:parent] ? Category.find_by_external_id(item[:parent].external_id) : nil

  create.save!
end

p deleted: to_delete.length, created: to_create.length

result.each do |item|
  changes = item[:changes]
  category = item[:category]

  next if changes.empty?
  next if changes.size == 1 && (changes[0][:type] == 'new-category' || changes[0][:type] == 'deleted')

  model = Category.find_by_external_id(category.external_id)
  parent_model = item[:parent] ? Category.find_by_external_id(item[:parent].external_id) : nil

  changes.each do |change|
    case change[:type]
    when 'name-changed'
      model.update_attributes!(:name => category.name)
    when 'no-longer-main'
      model.parent = parent_model
      model.main = false
      model.save!
    when 'new-parent'
      model.parent = parent_model
      model.save!
    when 'upgrade-to-main'
      model.parent = nil
      model.main = true
      model.save!
    else
      raise "unknown change type: #{change[:type]}"
    end
  end
end

# File.open("categories.tsv", "w") { |file|
#   file << CSV.generate(col_sep: "\t") do |csv|
#     csv << ['id', 'stortingskategori', 'overkategori']

#     Category.all_with_children.each do |cat|
#       csv << [cat.external_id, cat.name, cat.parent ? cat.parent.name : '']

#       cat.children.each do |subcat|
#         csv << [subcat.external_id, subcat.name, subcat.parent ? subcat.parent.name : '']
#       end
#     end
#   end
# }

