cukes2csv
============

Take cucumber feature files and convert them to a csv that can be used for as a test script.  

**Installation:**

Assuming you have ruby installed:

        git clone git@github.com:jarbarker/cukes2csv.git
        cd cukes2csv
        gem install bundler (you may need to use sudo here depending on your ruby installation)
        bundle install

        
**Test run:**

To run the converter that takes cucumber cumcumber feature files and converts the output file **features.csv** you can then import into a spreadsheet application, type the following:

        bundle exec ruby cukes2csv.rb


**Usage:**

ruby cukes2csv.rb --help

Usage: csv_extractor.rb [options]

    -t, --tag tag                    tag (all, smoke)
    
    -f, --features features          Features Location
    
    -o, --output output              Output Location
    
    -s, --[no-]steps                 With Steps
    
    -p, --platforms x,y,z            Platforms to test on.  Eg: --p Firefox,Safari,Chrome,IE

**Features:**

 * create test script to test against multiple platforms: ruby cukes2csv.rb --platforms Firefox,Safari,Chrome,IE
 * create full regression test scripts: ruby cukes2csv.rb --tag all
 * filter on tests with a specific tag.  Eg, create smoke test scripts: ruby cukes2csv.rb --tag smoke
 * include full steps: ruby cukes2csv.rb --steps
 * do not include steps: ruby cukes2csv.rb --no-steps
 * automation coverage for each feature and all features
    

