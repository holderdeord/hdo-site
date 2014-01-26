class QuestionsDecorator < Draper::CollectionDecorator
  delegate :limit_value,
           :current_page,
           :total_pages,
           :model_name,
           :total_count,
           :offset_value,
           :last_page?
end