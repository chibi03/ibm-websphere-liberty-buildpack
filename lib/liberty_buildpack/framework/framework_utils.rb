# Encoding: utf-8
# IBM WebSphere Application Server Liberty Buildpack
# Copyright 2013 the original author or authors.
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

require 'fileutils'
require 'liberty_buildpack/container'
require 'liberty_buildpack/diagnostics/logger_factory'
require 'liberty_buildpack/framework'

module LibertyBuildpack::Framework

  class FrameworkUtils

    def self.find(app_dir, pattern)
      apps = []
      matches = Dir["#{app_dir}/**/#{pattern}"]
      LibertyBuildpack::Diagnostics::LoggerFactory.get_logger.info("Apps with pattern found #{matches}")
      matches.each do |path|
        ['.ear', '.war', "\/WEB-INF"].each do |app|
          if path.include? app
            if app.include?('.ear') || app.include?('.war')
              apps.concat(path.scan(/.*\w+#{Regexp.quote(app)}/))
            else
              path.scan(/.*\w+#{Regexp.quote(app)}/) { |match| apps.concat(match.scan(/.*\w+\//)) }
            end
            break
          else
            apps.concat(path.scan(/^(.*)\/.*\w+\//))
          end
        end
      end
      LibertyBuildpack::Diagnostics::LoggerFactory.get_logger.info("Apps with pattern returned #{apps}")
      apps
    end

    def self.application_within_archive?(app_dir, pattern)
      list = ''
      archives = Dir.glob(File.join(app_dir, '**', '*.jar'))
      archives.each do |file|
        IO.popen("unzip -l -qq #{file}") do |io|
          line = io.gets
          list << "#{line}" while line
        end
      end
      list.include? pattern
    end

    def self.create_lib_dir(start_dir)
      if Liberty.web_inf(start_dir)
        FileUtils.mkdir_p(File.join(start_dir, 'WEB_INF', 'lib'))
      elsif Liberty.meta_inf(start_dir)
        FileUtils.mkdir_p(File.join(start_dir, 'lib'))
      end
    end

    def self.link_libs(apps, lib_dir)
      apps.each do |app_dir|
        libs = LibertyBuildpack::Container::ContainerUtils.libs(app_dir, lib_dir)
        if libs
          if LibertyBuildpack::Container::Liberty.web_inf(app_dir)
            app_web_inf_lib = web_inf_lib(app_dir)
            FileUtils.mkdir_p(app_web_inf_lib) unless File.exists?(app_web_inf_lib)
            app_web_inf_lib_path = Pathname.new(app_web_inf_lib)
            Pathname.glob(File.join(lib_dir, '*.jar')) do |jar|
              FileUtils.ln_sf(jar.relative_path_from(app_web_inf_lib_path), app_web_inf_lib)
            end
          elsif LibertyBuildpack::Container::Liberty.meta_inf(app_dir)
            ear_lib_path = Pathname.new(ear_lib)
            FileUtils.mkdir_p(ear_lib) unless File.exists?(ear_lib)
            Pathname.glob(File.join(lib_dir, '*.jar')) do |jar|
              FileUtils.ln_sf(jar.relative_path_from(ear_lib_path), ear_lib)
            end
          end
        end
      end
    end

    def self.web_inf_lib(app_dir)
      File.join app_dir, 'WEB-INF', 'lib'
    end

    def self.ear_lib(app_dir)
      File.join app_dir, 'lib'
    end

  end

end