# frozen_string_literal: true

require 'yard'
require 'rubocop'
require 'rubocop-rails'

YARD::Rake::YardocTask.new(:yard_for_generate_documentation) do |task|
  task.files = ['lib/rubocop/cop/**/*.rb']
  task.options = ['--no-output']
end

desc 'Generate docs of all cops departments'
task generate_cops_documentation: :yard_for_generate_documentation do
  def cops_of_department(cops, department)
    cops.with_department(department).sort!
  end

  def cops_body(config, cop, description, examples_objects, pars)
    content = h2(cop.cop_name)
    content << properties(config, cop)
    content << "#{description}\n"
    content << examples(examples_objects) if examples_objects.count > 0
    content << configurations(pars)
    content << references(config, cop)
    content
  end

  def examples(examples_object)
    examples_object.each_with_object(h3('Examples').dup) do |example, content|
      content << h4(example.name) unless example.name == ''
      content << code_example(example)
    end
  end

  def properties(config, cop)
    header = ['Enabled by default', 'Supports autocorrection']
    enabled_by_default = config.for_cop(cop).fetch('Enabled')
    content = [[
      enabled_by_default ? 'Enabled' : 'Disabled',
      cop.new.support_autocorrect? ? 'Yes' : 'No'
    ]]
    to_table(header, content) + "\n"
  end

  def h2(title)
    content = "\n".dup
    content << "## #{title}\n"
    content << "\n"
    content
  end

  def h3(title)
    content = "\n".dup
    content << "### #{title}\n"
    content << "\n"
    content
  end

  def h4(title)
    content = "#### #{title}\n".dup
    content << "\n"
    content
  end

  def code_example(ruby_code)
    content = "```ruby\n".dup
    content << ruby_code.text
               .gsub('@good', '# good').gsub('@bad', '# bad').strip
    content << "\n```\n"
    content
  end

  def configurations(pars)
    return '' if pars.empty?

    header = ['Name', 'Default value', 'Configurable values']
    configs = pars.each_key.reject { |key| key.start_with?('Supported') }
    content = configs.map do |name|
      configurable = configurable_values(pars, name)
      default = format_table_value(pars[name])
      [name, default, configurable]
    end

    h3('Configurable attributes') + to_table(header, content)
  end

  # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
  def configurable_values(pars, name)
    case name
    when /^Enforced/
      supported_style_name = RuboCop::Cop::Util.to_supported_styles(name)
      format_table_value(pars[supported_style_name])
    when 'IndentationWidth'
      'Integer'
    else
      case pars[name]
      when String
        'String'
      when Integer
        'Integer'
      when Float
        'Float'
      when true, false
        'Boolean'
      when Array
        'Array'
      else
        ''
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity,Metrics/MethodLength

  def to_table(header, content)
    table = [
      header.join(' | '),
      Array.new(header.size, '---').join(' | ')
    ]
    table.concat(content.map { |c| c.join(' | ') })
    table.join("\n") + "\n"
  end

  def format_table_value(val)
    value =
      case val
      when Array
        if val.empty?
          '`[]`'
        else
          val.map { |config| format_table_value(config) }.join(', ')
        end
      else
        "`#{val.nil? ? '<none>' : val}`"
      end
    value.gsub("#{Dir.pwd}/", '').rstrip
  end

  def references(config, cop)
    cop_config = config.for_cop(cop)
    urls = RuboCop::Cop::MessageAnnotator.new(config, cop_config, {}).urls
    return '' if urls.empty?

    content = h3('References')
    content << urls.map { |url| "* [#{url}](#{url})" }.join("\n")
    content << "\n"
    content
  end

  def print_cops_of_department(cops, department, config)
    selected_cops = cops_of_department(cops, department).select do |cop|
      cop.to_s.start_with?('RuboCop::Cop::Rails')
    end
    return if selected_cops.empty?

    content = "# #{department}\n".dup
    selected_cops.each do |cop|
      content << print_cop_with_doc(cop, config)
    end
    file_name = "#{Dir.pwd}/manual/cops_#{department.downcase}.md"
    File.open(file_name, 'w') do |file|
      puts "* generated #{file_name}"
      file.write(content.strip + "\n")
    end
  end

  def print_cop_with_doc(cop, config)
    t = config.for_cop(cop)
    non_display_keys = %w[Description Enabled StyleGuide Reference]
    pars = t.reject { |k| non_display_keys.include? k }
    description = 'No documentation'
    examples_object = []
    YARD::Registry.all(:class).detect do |code_object|
      next unless RuboCop::Cop::Badge.for(code_object.to_s) == cop.badge

      description = code_object.docstring unless code_object.docstring.blank?
      examples_object = code_object.tags('example')
    end
    cops_body(config, cop, description, examples_object, pars)
  end

  # rubocop:disable Metrics/AbcSize
  def table_of_content_for_department(cops, department)
    selected_cops = cops_of_department(cops, department.to_sym).select do |cop|
      cop.to_s.start_with?('RuboCop::Cop::Rails')
    end
    return if selected_cops.empty?

    type_title = department[0].upcase + department[1..-1]
    filename = "cops_#{department.downcase}.md"
    content = "#### Department [#{type_title}](#{filename})\n\n".dup
    selected_cops.each do |cop|
      anchor = cop.cop_name.sub('/', '').downcase
      content << "* [#{cop.cop_name}](#{filename}##{anchor})\n"
    end

    content
  end
  # rubocop:enable Metrics/AbcSize

  def print_table_of_contents(cops)
    path = "#{Dir.pwd}/manual/cops.md"
    original = File.read(path)
    content = "<!-- START_COP_LIST -->\n".dup

    content << table_contents(cops)

    content << "\n<!-- END_COP_LIST -->"

    content = original.sub(
      /<!-- START_COP_LIST -->.+<!-- END_COP_LIST -->/m, content
    )
    File.write(path, content)
  end

  def table_contents(cops)
    cops
      .departments
      .map(&:to_s)
      .sort
      .map { |department| table_of_content_for_department(cops, department) }
      .reject(&:nil?)
      .join("\n")
  end

  def main
    cops   = RuboCop::Cop::Cop.registry
    config = RuboCop::ConfigLoader.load_file('config/default.yml')

    YARD::Registry.load!
    cops.departments.sort!.each do |department|
      print_cops_of_department(cops, department, config)
    end

    print_table_of_contents(cops)
  ensure
    RuboCop::ConfigLoader.default_configuration = nil
  end

  main
end

desc 'Syntax check for the documentation comments'
task documentation_syntax_check: :yard_for_generate_documentation do
  require 'parser/ruby25'

  ok = true
  YARD::Registry.load!
  cops = RuboCop::Cop::Cop.registry
  cops.each do |cop|
    examples = YARD::Registry.all(:class).find do |code_object|
      next unless RuboCop::Cop::Badge.for(code_object.to_s) == cop.badge

      break code_object.tags('example')
    end

    examples.to_a.each do |example|
      begin
        buffer = Parser::Source::Buffer.new('<code>', 1)
        buffer.source = example.text
        parser = Parser::Ruby25.new(RuboCop::AST::Builder.new)
        parser.diagnostics.all_errors_are_fatal = true
        parser.parse(buffer)
      rescue Parser::SyntaxError => ex
        path = example.object.file
        puts "#{path}: Syntax Error in an example. #{ex}"
        ok = false
      end
    end
  end
  abort unless ok
end
