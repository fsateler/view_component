# frozen_string_literal: true

require "test_helper"

class ViewComponent::Base::UnitTest < Minitest::Test
  def test_templates_parses_all_types_of_paths
    file_path = [
      "/Users/fake.user/path/to.templates/component/test_component.html+phone.erb",
      "/_underscore-dash./component/test_component.html+desktop.slim",
      "/tilda~/component/test_component.html.haml"
    ]
    expected = [
      { variant: :phone, handler: "erb" },
      { variant: :desktop, handler: "slim" },
      { variant: nil, handler: "haml" }
    ]

    compiler = ViewComponent::Compiler.new(ViewComponent::Base)

    ViewComponent::Base.stub(:_sidecar_files, file_path) do
      templates = compiler.send(:templates)

      templates.each_with_index do |template, index|
        assert_equal(template[:path], file_path[index])
        assert_equal(template[:variant], expected[index][:variant])
        assert_equal(template[:handler], expected[index][:handler])
      end
    end
  end

  def test_calling_helpers_outside_render_raises
    component = ViewComponent::Base.new
    err =
      assert_raises ViewComponent::Base::ViewContextCalledBeforeRenderError do
        component.helpers
      end
    assert_includes err.message, "cannot be used during initialization"
  end

  def test_calling_controller_outside_render_raises
    component = ViewComponent::Base.new
    err =
      assert_raises ViewComponent::Base::ViewContextCalledBeforeRenderError do
        component.controller
      end

    assert_includes err.message, "cannot be used during initialization"
  end

  def test_sidecar_files
    root = ViewComponent::Engine.root.join("test/sandbox")

    assert_equal(
      [
        "#{root}/app/components/template_and_sidecar_directory_template_component.html.erb",
        "#{root}/app/components/template_and_sidecar_directory_template_component/" \
        "template_and_sidecar_directory_template_component.html.erb",
      ],
      TemplateAndSidecarDirectoryTemplateComponent._sidecar_files(["erb"])
    )

    assert_equal(
      [
        "#{root}/app/components/css_sidecar_file_component.css",
        "#{root}/app/components/css_sidecar_file_component.html.erb",
      ],
      CssSidecarFileComponent._sidecar_files(["css", "erb"])
    )

    assert_equal(
      ["#{root}/app/components/css_sidecar_file_component.css"],
      CssSidecarFileComponent._sidecar_files(["css"])
    )

    assert_equal(
      ["#{root}/app/components/translatable_component.yml"],
      TranslatableComponent._sidecar_files(["yml"])
    )
  end

  def test_template_arguments_validates_existence
    error = assert_raises ArgumentError do
      Class.new(ViewComponent::Base) do
        def self._sidecar_files(*)
          [
            "/Users/fake.user/path/to.templates/component/test_component/test_component.html.erb",
            "/Users/fake.user/path/to.templates/component/test_component/sidecar.html.erb",
          ]
        end
        template_arguments :non_existing, [:foo]
      end
    end
    assert_equal "Template does not exist: non_existing", error.message
  end

  def test_template_arguments_validates_duplicates
    error = assert_raises ArgumentError do
      Class.new(ViewComponent::Base) do
        def self._sidecar_files(*)
          [
            "/Users/fake.user/path/to.templates/component/test_component/test_component.html.erb",
            "/Users/fake.user/path/to.templates/component/test_component/sidecar.html.erb",
          ]
        end
        template_arguments :sidecar, [:foo]
        template_arguments :sidecar, [:bar]
      end
    end
    assert_equal "Arguments already defined for template sidecar", error.message
  end
end
