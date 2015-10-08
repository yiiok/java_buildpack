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

require 'java_buildpack/component/modular_component'
require 'java_buildpack/container'
require 'java_buildpack/container/jeus/jeus_insight_support'
require 'java_buildpack/container/jeus/jeus_instance'
require 'java_buildpack/container/jeus/jeus_lifecycle_support'
require 'java_buildpack/container/jeus/jeus_logging_support'
require 'java_buildpack/container/jeus/jeus_access_logging_support'
require 'java_buildpack/container/jeus/jeus_redis_store'
require 'java_buildpack/container/jeus/jeus_gemfire_store'
require 'java_buildpack/util/java_main_utils'

module JavaBuildpack
  module Container

    # Encapsulates the detect, compile, and release functionality for Jeus applications.
    class Jeus < JavaBuildpack::Component::ModularComponent

      protected

      # (see JavaBuildpack::Component::ModularComponent#command)
      def command
        @droplet.java_opts.add_system_property 'http.port', '$PORT'

        [
          @droplet.java_home.as_env_var,
          @droplet.java_opts.as_env_var,
          "$PWD/#{(@droplet.sandbox + 'bin/catalina.sh').relative_path_from(@droplet.root)}",
          'run'
        ].flatten.compact.join(' ')
      end

      # (see JavaBuildpack::Component::ModularComponent#sub_components)
      def sub_components(context)
        [
          JeusInstance.new(sub_configuration_context(context, 'jeus')),
          JeusLifecycleSupport.new(sub_configuration_context(context, 'lifecycle_support')),
          JeusLoggingSupport.new(sub_configuration_context(context, 'logging_support')),
          JeusAccessLoggingSupport.new(sub_configuration_context(context, 'access_logging_support')),
          JeusRedisStore.new(sub_configuration_context(context, 'redis_store')),
          JeusGemfireStore.new(sub_configuration_context(context, 'gemfire_store')),
          JeusInsightSupport.new(context)
        ]
      end

      # (see JavaBuildpack::Component::ModularComponent#supports?)
      def supports?
        web_inf? && !JavaBuildpack::Util::JavaMainUtils.main_class(@application)
      end

      private

      def web_inf?
        (@application.root + 'WEB-INF').exist?
      end

    end

  end
end
