require 'optparse'
require 'date'
require 'mechanize'
require 'yaml'

require_relative 'scma_gcal/error'
require_relative 'scma_gcal/application'
require_relative 'scma_gcal/option_parser'
require_relative 'scma_gcal/input/web'
require_relative 'scma_gcal/input/yaml'
require_relative 'scma_gcal/model/event'
require_relative 'scma_gcal/output/csv'
require_relative 'scma_gcal/output/yaml'
require_relative 'scma_gcal/core_extensions'

String.include CoreExtensions::String::RemoveNBSP
String.include CoreExtensions::String::CollapseWhitespace
MatchData.include CoreExtensions::MatchData::ToHash
