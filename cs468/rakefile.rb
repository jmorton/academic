require 'rake'
require 'spec/rake/spectask'

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('rr') do |t|
  t.spec_files = FileList['*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--include', 'sdes.rb',
                 '--exclude','*_spec.rb'
                ]
end