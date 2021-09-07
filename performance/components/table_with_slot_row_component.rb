# frozen_string_literal: true

class TableWithSlotRowComponent < ViewComponent::Base
  def initialize(item:, columns:, **some_more_options)
    @item = item
    @columns = columns
    @options = some_more_options
  end

  def row_options
    @options
  end
end
