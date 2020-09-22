module ApplicationHelper
  def format_as_percent(num)
    number_to_percentage(num * 100, precision: 0)
  end
end
