# frozen_string_literal: true

class TableWithSlotComponent < ViewComponent::Base
  renders_many :columns, "ColumnComponent"
  # @api private
  renders_many :rows, "TableWithSlotRowComponent"

  def initialize(rows:)
    @rows = rows
  end

  def before_render
    rows(@rows.map{ |item| { item: item, columns: columns } })
  end

  class ColumnComponent < ViewComponent::Base # This one actually doesn't need to be a component :)
    def initialize(attribute:)
      @attribute = attribute
    end

    def render_value(model)
      model.send(@attribute) # for brevity, we don't implement other ways of rendering the value
    end
  end
end
