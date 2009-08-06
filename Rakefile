require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run specs.'
task :default => :spec

desc 'Spec the asset_types plugin.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc 'Run specs with rcov'
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
  end
end

desc 'Generate documentation for the asset_types plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AssetTypes'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
