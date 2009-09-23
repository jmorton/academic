require 'sdes'
require 'rake'
require 'spec/rake/spectask'

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('rr') do |t|
  t.spec_files = FileList['spec//*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--include', 'sdes.rb',
                 '--exclude','spec/*_spec.rb']
end

desc "Decrypt the files in the current directory"
task :process do |t|
  output = SDES::IO.process("cs468-filelist.txt")
  output.each { |path| puts "Created #{path}" }
end