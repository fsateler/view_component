# frozen_string_literal: true

class TableWithPartialComponent < ViewComponent::Base
  renders_many :columns, "ColumnComponent"

  template_arguments :row, :row

  attr_reader :rows

  def initialize(rows:)
    @rows = rows
  end

  def row_options
    {}
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
