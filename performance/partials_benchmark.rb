# frozen_string_literal: true

# Run `bundle exec rake benchmark` to execute benchmark.
# This is very much a work-in-progress. Please feel free to make/suggest improvements!

require "benchmark/ips"

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "production"
require File.expand_path("../test/sandbox/config/environment.rb", __dir__)

require_relative "components/table_with_slot_component.rb"
require_relative "components/table_with_slot_row_component.rb"
require_relative "components/table_with_partial_component.rb"

class BenchmarksController < ActionController::Base
end

BenchmarksController.view_paths = [File.expand_path("./views", __dir__)]
controller_view = BenchmarksController.new.view_context

DataStruct = Struct.new(:id)

rows = 10.times.map { |i| DataStruct.new(i) }

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report("slot:") { controller_view.render(TableWithSlotComponent.new(rows: rows)) { |c| c.column(attribute: :id) } }
  x.report("partial:") { controller_view.render(TableWithPartialComponent.new(rows: rows)) { |c| c.column(attribute: :id) } }

  x.compare!
end
