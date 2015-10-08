# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013-2015 the original author or authors.
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

require 'java_buildpack'
require 'rexml/document'
require 'rexml/formatters/pretty'

module JavaBuildpack
  module Container

    # The Jeus +context.xml+ file
    #
    # @return [Pathname] the Jeus +context.xml+ file
    def context_xml
      @droplet.sandbox + 'conf/context.xml'
    end

    # Link a collection of files to a destination directory, using relative paths
    #
    # @param [Array<Pathname>] source the collection of files to link
    # @param [Pathname] destination the destination directory to link to
    # @return [Void]
    def link_to(source, destination)
      FileUtils.mkdir_p destination
      source.each { |path| (destination + path.basename).make_symlink(path.relative_path_from(destination)) }
    end

    # Read an XML file into a +REXML::Document+
    #
    # @param [Pathname] file the file to read
    # @return [REXML::Document] the file parsed into a +REXML::Document+
    def read_xml(file)
      file.open { |f| REXML::Document.new f }
    end

    # The Jeus +server.xml+ file
    #
    # @return [Pathname] The Jeus +server.xml+ file
    def server_xml
      @droplet.sandbox + 'conf/server.xml'
    end

    # The Jeus +lib+ directory
    #
    # @return [Pathname] the Jeus +lib+ directory
    def jeus_lib
      @droplet.sandbox + 'lib'
    end

    # The Jeus +webapps+ directory
    #
    # @return [Pathname] the Jeus +webapps+ directory
    def jeus_webapps
      @droplet.sandbox + 'webapps'
    end

    # Write a properly formatted XML file
    #
    # @param [Pathname] file the file to write
    # @return [Void]
    def write_xml(file, document)
      file.open('w') do |f|
        formatter.write document, f
        f << "\n"
      end
    end

    private

    def formatter
      formatter         = REXML::Formatters::Pretty.new(4)
      formatter.compact = true
      formatter
    end

  end
end
