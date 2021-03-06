paths = %w(highline-1.5.1/lib highline-1.5.1/lib/highline)

# Because I cannot rely on the existence of rubygems, nor can I install
# other ruby libraries, I need to add some directories to the LOAD_PATH
# so that requiring 'highline' will succeed.
paths.each { |path| $:.unshift(File.expand_path(path)) }
