require 'optparse'
require 'yaml'

require 'gherkin/parser/parser'
require 'gherkin/formatter/json_formatter'
require 'stringio'
require 'json'
require 'csv'

options = {}

options[:tag]=:all
options[:steps]=true
options[:features]="features"
options[:output]="features.csv"
options[:platforms]=["Firefox", "Safari", "Chrome", "IE"]

OptionParser.new do |opts|
  opts.banner = "Usage: csv_extractor.rb [options]"

  opts.on('-t', '--tag tag', [:all, :smoke],
          "tag (all, smoke)") do |d|
    raise OptionParser::InvalidArgument unless ['all', 'smoke'].include?(d.to_s)
    options[:tag] = d
  end

  opts.on('-f', '--features features', 'Features Location') do |features|
    options[:features] = features;
  end

  opts.on('-o', '--output output', 'Output Location') do |output|
    options[:output] = output;
  end

  opts.on('-s', "--[no-]steps", "With Steps") do |s|
    options[:steps] = s
  end

  opts.on("-p x,y,z", "--platforms", Array, "Platforms to test on.  Eg: --p Firefox,Safari,Chrome,IE") do |list|
    options[:platforms] = list
  end


end.parse!

def parse_feature_file_to_hash(feature_file_path)
  io = StringIO.new
  formatter = Gherkin::Formatter::JSONFormatter.new(io)
  parser = Gherkin::Parser::Parser.new(formatter)

  parser.parse(IO.read(feature_file_path), feature_file_path, 0)

  formatter.done
  JSON.load(io.string)
end

def test_padding scenario, platforms
  padding_string = ""
  padding_array = []
  if scenario_automated?(scenario)
    padding_string="(a)"
  else
    padding_string="(-)"
  end

  platforms.each do
    padding_array<<padding_string
  end

  padding_array
end

def scenario_has_tag? scenario, filter_tag
  if scenario["tags"]
    scenario_tags=scenario["tags"].map { |t| t["name"] }
    scenario_tags.include?(filter_tag)
  end
end

def scenario_automated? scenario
  !scenario_has_tag?(scenario, '@wip')
end


feature_files = Dir["#{options[:features]}/*.feature"]

CSV.open(options[:output], 'wb') do |csv|

  csv << ["-- Regression Test: #{Time.now} -- "]

  total_scenario_tests=0
  total_scenario_automated_tests=0

  feature_files.each do |feature|
    begin
      puts "Processing feature file: #{feature}"
      feature_hash = parse_feature_file_to_hash(feature)
    rescue
      puts "Couldn't open or parse the file #{feature}."
      puts "Please make sure that the file exists and that it is a valid feature file."
      next
    end

    feature_rows = [nil]
    feature_rows << ["*** #{feature_hash.first["name"]} ***"]
    feature_rows << ["#{feature_hash.first["description"]}"]

    header = ['Scenario']
    header << 'Step' if options[:steps]
    header += options[:platforms]
    feature_rows << header

    elements = feature_hash.first['elements']

    scenario_tests=0
    scenario_automated_tests=0

    elements.each do |element|

      if element["keyword"]=="Scenario" || element["keyword"]=="Scenario Outline"
        list_scenario_for_tag=false

        if options[:tag]==:all
          list_scenario_for_tag=true
        elsif options[:tag]==:smoke
          list_scenario_for_tag=scenario_has_tag?(element, '@smoke')
        end

        if list_scenario_for_tag

          scenario_tests+=1

          if scenario_automated?(element)
            scenario_automated_tests+=1
          end

          entry = element['name'] + ' ' + element['description']
          entry.gsub!(/\n/, ' ')

          if options[:steps]
            element['steps'].each do |s|
              step = s['keyword'] + s['name']
              row = [entry, step]
              feature_rows << row
              entry = ''
            end

            if element["keyword"]=="Scenario"
              feature_rows<<[nil, "- SCENARIO RESULT: -"] + test_padding(element,options[:platforms])
            end

            if element["keyword"]=="Scenario Outline"
              feature_rows<<[nil, "-  SCENARIO OUTLINE RESULTS: -"]

              raise "No examples found for Scenario Outline" if !element['examples']

              element['examples'].first["rows"].each_with_index do |example, index|
                if index==0
                  feature_rows<<[nil, "|- "+example["cells"].join(" -|- ")+" -|"]
                else
                  feature_rows<<[nil, "| "+example["cells"].join(" | ")+" | "] + test_padding(element,options[:platforms])
                end
              end
            end


            feature_rows << [nil]
          else
            row = [entry] + test_padding(element, options[:platforms])
            feature_rows << row
          end
        end
      end
    end

    puts " - Automated Tests: #{scenario_automated_tests} Scenario Tests: #{scenario_tests}"

    # Only add feature to csv if there are tests available
    if scenario_tests>0
      feature_rows.each do |feature_row|
        if feature_row
          csv<<feature_row
        end
      end
    end

    total_scenario_tests+=scenario_tests
    total_scenario_automated_tests+=scenario_automated_tests

  end
  puts " -- Total Automated Tests: #{total_scenario_automated_tests} Total Scenario Tests: #{total_scenario_tests}"
end

puts "File written to: #{options[:output]}"






