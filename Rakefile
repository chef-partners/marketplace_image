# frozen_string_literal: true
#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright (c) 2016, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Rubocop
desc 'Run Rubocop style checks'
RuboCop::RakeTask.new(:rubocop) do |cop|
  cop.fail_on_error = true
end

# RSpec
desc 'Run RSpec/ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

desc 'Default task: run all tests'
task default: [:rubocop, :spec]
