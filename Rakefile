# IBM WebSphere Application Server Liberty Buildpack
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.options = ['--no-stats']
end

require 'rubocop/rake_task'
Rubocop::RakeTask.new

require 'open3'
task :check_api_doc do
  puts "\nChecking API documentation..."
  output = Open3.capture3("yard stats --list-undoc")[0]
  if output !~ /100.00% documented/
  	puts "\nFailed due to undocumented public API:\n\n#{output}"
  	exit 1
  else
  	puts "\n#{output}\n"
  end
end

require 'rake/clean'
CLEAN.include %w(.yardoc coverage)
CLOBBER.include %w(doc pkg)

task :default => [ :rubocop, :check_api_doc, :yard, :spec ]

desc "Package buildpack together with admin cache"
task :package, [:zipfile] do |t, args|
  source = File.dirname(__FILE__)
  basename = File.basename(source)
  if args.zipfile.nil?
    zipfile = File.expand_path(File.join('..', "#{basename}.zip"), source)
  else
    zipfile = args.zipfile
    zipfile << ".zip" unless zipfile.end_with? (".zip")
  end
  puts "Using #{zipfile} as a buildpack zip output file"
  if File.exists? (zipfile)
    puts "The output file already exists. Change the output location."
    exit 1
  end
  require 'tmpdir'
  Dir.mktmpdir do |root|
    $LOAD_PATH.unshift File.expand_path(File.join('..', 'resources'), __FILE__)
    require 'download_buildpack_cache'

    FileUtils.cp_r(source, root)
    dest = File.join(root, basename)
    bc = BuildpackCache.new(File.join(dest, 'admin_cache'))
    configs = bc.collect_configs
    bc.download_cache(configs)
    system("cd #{dest} && zip -r #{zipfile} .")
  end
end

