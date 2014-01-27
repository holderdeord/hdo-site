class QuestionsDecorator < Draper::CollectionDecorator
  delegate :current_page, :current_page, :offset_value, :total_count, :total_pages, :limit_value, :last_page?, :model_name
end